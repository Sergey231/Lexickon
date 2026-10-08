#!/usr/bin/env python3
"""Частоты фраз (2–3 слова) по корпусу программирования Lemma Atlas — эталон для пилота фраз.

Lemma Atlas не считает многословные выражения (final_cleanup_policy.md), но хранит очищенные тексты
домена: data/domains/programming/cleaned/*/clean_segments.jsonl. Скрипт считает по ним n-граммы
словоформ внутри сегмента и взвешивает источники так же, как Lemma Atlas для слов.

  count    посчитать n-граммы, отфильтровать кандидатов -> phrase_counts.csv
  stats    распределение частот и устойчивости кандидатов (для выбора порогов)
  sample   стратифицированная выборка фраз по уровням частоты и устойчивости -> sample.csv
  replace  заменить вычеркнутые вручную фразы новыми из той же клетки
  run      вызвать JEV: (а) полезность по трём уровням, (б) «устойчивое выражение?» -> jev_raw.jsonl
  report   критерии приложения PRD §A.3 -> report.md, comparison.csv

Устойчивость — NPMI (нормированная поточечная взаимная информация, от −1 до 1): насколько чаще слова
встречаются вместе, чем порознь. Для триграмм — минимум NPMI по двум разбиениям.
"""

import argparse
import collections
import csv
import json
import math
import os
import random
import re
import sys
import statistics
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pilot import post_jev  # noqa: E402

LEMMA_ATLAS = Path(os.environ.get("LEMMA_ATLAS_DIR", Path.home() / "Documents/Repositories/LemmaAtlas"))
DOMAIN_DIR = LEMMA_ATLAS / "data/domains/programming"
DICTIONARY = Path("/usr/share/dict/words")

TOKEN = re.compile(r"[a-z]+(?:'[a-z]+)?")

# Служебные слова: фраза не начинается и не заканчивается ими (кроме частиц фразовых глаголов в конце).
FUNCTION_WORDS = set("""
a an the this that these those it its it's i you he she we they me him her us them my your our their
is are was were be been being am do does did done has have had having will would shall should can could
may might must not no and or but if then else so as of to in on at by for with from into onto about
than too very just also there here what which who whom whose when where why how all any some each
every both either neither one ones s t
however example eg ie etc also still yet already even though although while whether
because since after before itself only actually always
""".split())
PARTICLES = {"up", "out", "down", "off", "back", "over", "away", "through", "around", "on", "in", "into"}

MIN_COUNT = 5        # не меньше 5 употреблений во всём корпусе
MIN_SOURCES = 2      # и не меньше двух источников из четырёх (отсекает шаблонный текст одного сайта)
MIN_TOKEN_ZIPF = 3.0  # слово вне системного словаря допускается, если оно частое в домене (async, repo)

LEVELS = ["low", "medium", "high"]  # индексы 0..2, как в ответе JEV

# Формулировки зафиксированы 2026-10-08 до первого вызова JEV на фразах (PRD §A.3); после прогона не меняются.
USEFULNESS = {
    "type": "score",
    "instructions": (
        "How useful is it for a software developer learning English (native language Russian) "
        "to learn this English phrase for reading programming material: documentation, Stack Overflow, "
        "GitHub READMEs and technical books?"
    ),
    "criteria": [
        "A phrase the developer will rarely or never meet in programming documentation or discussions; "
        "learning it for work is wasted effort.",
        "A phrase met from time to time in programming material, mostly within particular topics, tools "
        "or kinds of documents.",
        "A phrase met constantly across programming documentation, error messages and discussions; "
        "a developer reads it again and again.",
    ],
}
FIXED_EXPRESSION = {
    "type": "noul",
    "instructions": (
        "Is this phrase a fixed expression that developers habitually use as a whole, rather than an "
        "ordinary combination of words put together for one sentence?"
    ),
    "criteria": {
        "true": "A set expression developers reuse as a whole: a technical term, collocation, idiom or "
                "phrasal verb (for example \"pull request\", \"race condition\").",
        "false": "An ordinary combination of words put together for one sentence, whose words are not "
                 "habitually used together (for example \"new file\", \"read the value\").",
    },
}


def load_sources():
    meta = json.loads((DOMAIN_DIR / "artifacts/domain_frequency_metadata.json").read_text(encoding="utf-8"))
    return meta["source_weights_normalized"], meta.get("version")


def segments(source):
    with open(DOMAIN_DIR / "cleaned" / source / "clean_segments.jsonl", encoding="utf-8") as f:
        for line in f:
            yield TOKEN.findall(json.loads(line)["clean_text"].lower())


def top_pos(entry):
    pos = entry.get("pos") or {}
    return min(pos, key=lambda p: pos[p]["rank"]) if pos else ""


def vocabulary():
    """Допустимые слова фраз и множество глаголов (для фраз с частицей на конце)."""
    # Только слова в нижнем регистре: имена собственные в словаре с заглавной (Raymond, Guido) не проходят.
    dictionary = {w.strip() for w in DICTIONARY.read_text(encoding="utf-8").splitlines() if w.strip().islower()}
    index = json.loads((DOMAIN_DIR / "artifacts/domain_frequency_index.json").read_text(encoding="utf-8"))
    # Частые в домене слова вне словаря (async, repo) допускаются, если это не имя собственное.
    frequent = {lemma.lower() for lemma, d in index.items()
                if d["domain"]["zipf"] >= MIN_TOKEN_ZIPF and top_pos(d) != "PROPN"}
    proper = {lemma.lower() for lemma, d in index.items() if top_pos(d) == "PROPN"} - dictionary
    verbs = {lemma.lower() for lemma, d in index.items() if "VERB" in (d.get("pos") or {})
             and d["pos"]["VERB"]["rank"] <= min(p["rank"] for p in d["pos"].values()) * 3}
    return (dictionary | frequent) - proper, verbs


def verb_form(token, verbs):
    """Грубо: словоформа глагола (set, sets, setting, settled, tried) по списку лемм-глаголов."""
    candidates = {token}
    for suffix in ("ing", "ed", "es", "s", "d"):
        if token.endswith(suffix):
            stem = token[: -len(suffix)]
            candidates |= {stem, stem + "e", stem[:-1] if len(stem) > 2 and stem[-1] == stem[-2] else stem}
    if token.endswith("ied"):
        candidates.add(token[:-3] + "y")
    return bool(candidates & verbs)


def is_candidate(gram, vocab):
    allowed, verbs = vocab
    if any(t not in allowed or "'" in t or len(t) < 2 for t in gram):
        return False
    first, last = gram[0], gram[-1]
    if first in FUNCTION_WORDS or any(t in ("however", "example", "eg", "ie", "etc") for t in gram):
        return False
    if last in FUNCTION_WORDS:
        # Частица на конце допустима только во фразовом глаголе: set up, fall back, run out.
        if last not in PARTICLES or not verb_form(first, verbs):
            return False
    if len(set(gram)) < len(gram):  # "very very", "test test test"
        return False
    return True


def cmd_count(args):
    weights, version = load_sources()
    vocab = vocabulary()
    tokens = {}
    counts = {n: collections.defaultdict(collections.Counter) for n in (1, 2, 3)}
    for source in weights:
        total = 0
        for toks in segments(source):
            total += len(toks)
            for n in (1, 2, 3):
                c = counts[n][source]
                for i in range(len(toks) - n + 1):
                    c[tuple(toks[i:i + n])] += 1
        tokens[source] = total
        print(f"{source}: {total} токенов", file=sys.stderr)

    def fpm(gram, n):
        return sum(w * counts[n][s][gram] / tokens[s] * 1e6 for s, w in weights.items())

    def prob(gram):
        # Вероятности для NPMI — по взвешенной частоте (доля на токен).
        return fpm(gram, len(gram)) / 1e6

    def npmi(left, right, joint):
        p_joint, p_left, p_right = prob(joint), prob(left), prob(right)
        if min(p_joint, p_left, p_right) <= 0 or p_joint >= 1:
            return -1.0
        return math.log(p_joint / (p_left * p_right)) / -math.log(p_joint)

    rows = []
    for n in (2, 3):
        pooled = collections.Counter()
        for s in weights:
            pooled.update(counts[n][s])
        for gram, total in pooled.items():
            if total < MIN_COUNT or not is_candidate(gram, vocab):
                continue
            sources_seen = sum(1 for s in weights if counts[n][s][gram])
            if sources_seen < MIN_SOURCES:
                continue
            f = fpm(gram, n)
            if n == 2:
                assoc = npmi(gram[:1], gram[1:], gram)
            else:
                assoc = min(npmi(gram[:1], gram[1:], gram), npmi(gram[:2], gram[2:], gram))
            rows.append({"phrase": " ".join(gram), "n": n, "count": total, "sources_seen": sources_seen,
                         "freq_per_million": f"{f:.4f}", "zipf": f"{math.log10(f * 1000):.3f}",
                         "npmi": f"{assoc:.3f}"})
    rows.sort(key=lambda r: -float(r["zipf"]))
    out = args.out / "phrase_counts.csv"
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    (args.out / "phrase_corpus.json").write_text(json.dumps({
        "lemma_atlas_programming_version": version, "source_weights": weights, "source_tokens": tokens,
        "min_count": MIN_COUNT, "min_sources": MIN_SOURCES, "min_token_zipf": MIN_TOKEN_ZIPF,
    }, indent=2), encoding="utf-8")
    print(f"{len(rows)} кандидатов -> {out}")


def read_counts(out):
    with open(out / "phrase_counts.csv", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def cmd_stats(args):
    rows = read_counts(args.out)
    for n in ("2", "3"):
        z = sorted(float(r["zipf"]) for r in rows if r["n"] == n)
        q = [z[int(len(z) * p)] for p in (0.1, 0.25, 0.5, 0.75, 0.9, 0.99)]
        print(f"{n}-граммы: {len(z)}; Zipf p10/25/50/75/90/99: " + " / ".join(f"{x:.2f}" for x in q))
    for lo, hi in ((4.0, 9), (3.0, 4.0), (2.5, 3.0), (2.0, 2.5), (0, 2.0)):
        band = [r for r in rows if lo <= float(r["zipf"]) < hi]
        top = sorted(band, key=lambda r: -float(r["npmi"]))[:8]
        print(f"Zipf [{lo}, {hi}): {len(band)}; самые устойчивые: {', '.join(r['phrase'] for r in top)}")


def cmd_sample(args):
    rows = read_counts(args.out)
    thresholds = json.loads(args.thresholds)
    rng = random.Random(args.seed)

    def level(z):
        if z >= thresholds["high"]:
            return "high"
        if z >= thresholds["medium"]:
            return "medium"
        return "low"

    # Внутри уровня — поровну устойчивых и свободных сочетаний, чтобы проверить и вопрос «учить целиком».
    out = []
    per_cell = args.per_level // 2
    for lvl in ("high", "medium", "low"):
        band = [r for r in rows if level(float(r["zipf"])) == lvl]
        fixed = [r for r in band if float(r["npmi"]) >= args.npmi_fixed]
        free = [r for r in band if float(r["npmi"]) < args.npmi_free]
        for kind, pool in (("fixed", fixed), ("free", free)):
            if len(pool) < per_cell:
                sys.exit(f"{lvl}/{kind}: только {len(pool)} фраз, нужно {per_cell}")
            for r in rng.sample(pool, per_cell):
                out.append({**r, "freq_level": lvl, "assoc_class": kind})
    with open(args.out / "sample.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(out[0].keys()))
        writer.writeheader()
        writer.writerows(out)
    (args.out / "thresholds.json").write_text(json.dumps(
        {"zipf": thresholds, "npmi_fixed": args.npmi_fixed, "npmi_free": args.npmi_free, "seed": args.seed}, indent=2), encoding="utf-8")
    print(f"sample: {len(out)} фраз -> {args.out / 'sample.csv'}")


def cmd_replace(args):
    """Заменить вычеркнутые вручную фразы (файл --exclude: «фраза<TAB>причина») на новые из той же клетки."""
    rows = read_counts(args.out)
    params = json.loads((args.out / "thresholds.json").read_text(encoding="utf-8"))
    excluded = {}
    for line in Path(args.exclude).read_text(encoding="utf-8").splitlines():
        if line.strip() and not line.startswith("#"):
            phrase, _, reason = line.partition("\t")
            excluded[phrase.strip()] = reason.strip()
    with open(args.out / "sample.csv", newline="", encoding="utf-8") as f:
        sample = list(csv.DictReader(f))
    in_sample = {r["phrase"] for r in sample}
    rng = random.Random(params["seed"] + len(excluded))
    z = params["zipf"]

    def cell(r):
        zipf, assoc = float(r["zipf"]), float(r["npmi"])
        lvl = "high" if zipf >= z["high"] else "medium" if zipf >= z["medium"] else "low"
        kind = "fixed" if assoc >= params["npmi_fixed"] else "free" if assoc < params["npmi_free"] else None
        return lvl, kind

    replaced = []
    for i, r in enumerate(sample):
        if r["phrase"] not in excluded:
            continue
        target = (r["freq_level"], r["assoc_class"])
        pool = [c for c in rows if cell(c) == target and c["phrase"] not in in_sample and c["phrase"] not in excluded]
        new = rng.choice(pool)
        in_sample.add(new["phrase"])
        sample[i] = {**new, "freq_level": target[0], "assoc_class": target[1]}
        replaced.append((r["phrase"], new["phrase"]))
    with open(args.out / "sample.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(sample[0].keys()))
        writer.writeheader()
        writer.writerows(sample)
    for old, new in replaced:
        print(f"{old} -> {new}")
    print(f"заменено {len(replaced)}; в файле исключений {len(excluded)}")


# ---------- run ----------

def cmd_run(args):
    key = os.environ.get("JEV_API_KEY")
    if not key:
        sys.exit("Задайте ключ: export JEV_API_KEY=...")
    with open(args.out / "sample.csv", newline="", encoding="utf-8") as f:
        sample = list(csv.DictReader(f))
    raw_path = args.out / "jev_raw.jsonl"
    done = set()
    if raw_path.exists():
        for line in raw_path.read_text(encoding="utf-8").splitlines():
            r = json.loads(line)
            done.add((r["phrase"], r["repeat"]))
    jobs = [(r["phrase"], k) for r in sample for k in range(args.repeats) if (r["phrase"], k) not in done]
    print(f"run: {len(jobs)} вызовов ({len(done)} уже есть), потоков: {args.workers}")

    def call(phrase):
        body = {"state": f"English phrase: {phrase}", "model": args.model,
                "questions": {"usefulness": USEFULNESS, "fixed_expression": FIXED_EXPRESSION}}
        return post_jev(key, body, f"'{phrase}'")

    errors = []
    # Оба вопроса в одном запросе; в файл пишет только главный поток, прерванный прогон продолжается.
    with open(raw_path, "a", encoding="utf-8") as raw, ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {pool.submit(call, phrase): (phrase, k) for phrase, k in jobs}
        for i, future in enumerate(as_completed(futures), 1):
            phrase, k = futures[future]
            try:
                payload, latency_ms = future.result()
            except Exception as e:  # noqa: BLE001 — одна ошибка не должна терять остальные ответы
                errors.append(str(e))
                print(f"ошибка: {e}", file=sys.stderr)
                continue
            usefulness = payload["answers"]["usefulness"]
            raw.write(json.dumps({
                "phrase": phrase, "repeat": k, "model": payload.get("model"),
                "latency_ms": round(latency_ms, 1), "score": usefulness["score"],
                "confidence": usefulness["confidence"], "probabilities": usefulness["probabilities"],
                "noul": payload["answers"]["fixed_expression"]["noul"], "usage": payload.get("usage"),
            }, ensure_ascii=False) + "\n")
            raw.flush()
            if i % 50 == 0 or i == len(jobs):
                print(f"[{i}/{len(jobs)}] {phrase:30} score={usefulness['score']:.2f} "
                      f"noul={payload['answers']['fixed_expression']['noul']:.2f} {latency_ms:.0f} ms")
    if errors:
        sys.exit(f"{len(errors)} вызовов с ошибкой; запустите run ещё раз, чтобы дозапросить их")


# ---------- report ----------

def ranks(values):
    """Ранги с усреднением для равных значений (для Spearman)."""
    order = sorted(range(len(values)), key=lambda i: values[i])
    result = [0.0] * len(values)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and values[order[j + 1]] == values[order[i]]:
            j += 1
        for k in range(i, j + 1):
            result[order[k]] = (i + j) / 2
        i = j + 1
    return result


def spearman(a, b):
    ra, rb = ranks(a), ranks(b)
    ma, mb = statistics.mean(ra), statistics.mean(rb)
    cov = sum((x - ma) * (y - mb) for x, y in zip(ra, rb))
    return cov / math.sqrt(sum((x - ma) ** 2 for x in ra) * sum((y - mb) ** 2 for y in rb))


def auc(positive, negative):
    wins = sum((p > n) + 0.5 * (p == n) for p in positive for n in negative)
    return wins / (len(positive) * len(negative))


def calibrate(scores, reference):
    """Перевод оценок в три точки по долям эталона: сколько фраз в эталоне высокие — столько лучших оценок высокие."""
    shares = collections.Counter(reference)
    order = sorted(range(len(scores)), key=lambda i: (-scores[i], i))
    levels, pos = [None] * len(scores), 0
    for level in reversed(LEVELS):
        for i in order[pos:pos + shares[level]]:
            levels[i] = level
        pos += shares[level]
    return levels


def word_zipf_index():
    index = json.loads((DOMAIN_DIR / "artifacts/domain_frequency_index.json").read_text(encoding="utf-8"))
    return {lemma.lower(): d["domain"]["zipf"] for lemma, d in index.items()}


def word_zipf(token, index):
    """Zipf слова в домене по лемме; словоформа приводится грубо (files -> file, used -> use). Нет в индексе — 0."""
    candidates = [token]
    for suffix in ("ing", "ies", "ied", "es", "ed", "s", "d"):
        if token.endswith(suffix) and len(token) > len(suffix) + 2:
            stem = token[: -len(suffix)]
            candidates += [stem, stem + "e", stem + "y"]
            if len(stem) > 2 and stem[-1] == stem[-2]:
                candidates.append(stem[:-1])
    return max((index[c] for c in candidates if c in index), default=0.0)


def cmd_report(args):
    with open(args.out / "sample.csv", newline="", encoding="utf-8") as f:
        sample = list(csv.DictReader(f))
    calls = collections.defaultdict(list)
    for line in (args.out / "jev_raw.jsonl").read_text(encoding="utf-8").splitlines():
        r = json.loads(line)
        calls[r["phrase"]].append(r)
    sample = [r for r in sample if calls.get(r["phrase"])]
    index = word_zipf_index()

    def jev_level(answer):
        probs = answer["probabilities"]
        return LEVELS[int(max(probs, key=lambda k: probs[k]))]

    rows = []
    for r in sample:
        runs = sorted(calls[r["phrase"]], key=lambda x: x["repeat"])
        levels = [jev_level(x) for x in runs]
        yes = [x["noul"] >= 0.5 for x in runs]
        rows.append({
            "phrase": r["phrase"], "zipf": float(r["zipf"]), "npmi": float(r["npmi"]),
            "freq_level": r["freq_level"], "assoc_class": r["assoc_class"],
            "jev_score": statistics.mean(x["score"] for x in runs), "jev_level_raw": levels[0],
            "noul": statistics.mean(x["noul"] for x in runs),
            "baseline": min(word_zipf(t, index) for t in r["phrase"].split()),
            "stable_level": len(set(levels)) == 1, "stable_noul": len(set(yes)) == 1,
            "repeats": len(runs), "latency_ms": [x["latency_ms"] for x in runs], "model": runs[0]["model"],
        })
    reference = [r["freq_level"] for r in rows]
    jev_cal = calibrate([r["jev_score"] for r in rows], reference)
    base_cal = calibrate([r["baseline"] for r in rows], reference)
    for r, j, b in zip(rows, jev_cal, base_cal):
        r["jev_level"], r["baseline_level"] = j, b
    n = len(rows)

    zipf = [r["zipf"] for r in rows]
    rho_jev = spearman([r["jev_score"] for r in rows], zipf)
    rho_base = spearman([r["baseline"] for r in rows], zipf)
    agree_jev = sum(r["jev_level"] == r["freq_level"] for r in rows) / n
    agree_base = sum(r["baseline_level"] == r["freq_level"] for r in rows) / n
    gross = sum({r["jev_level"], r["freq_level"]} == {"high", "low"} for r in rows) / n
    gross_raw = sum({r["jev_level_raw"], r["freq_level"]} == {"high", "low"} for r in rows) / n
    agree_raw = sum(r["jev_level_raw"] == r["freq_level"] for r in rows) / n
    fixed = [r["noul"] for r in rows if r["assoc_class"] == "fixed"]
    free = [r["noul"] for r in rows if r["assoc_class"] == "free"]
    auc_noul = auc(fixed, free)
    stable_level = sum(r["stable_level"] for r in rows) / n
    stable_noul = sum(r["stable_noul"] for r in rows) / n
    latencies = sorted(x for r in rows for x in r["latency_ms"])

    def verdict(ok):
        return "пройден" if ok else "**не пройден**"

    checks = [
        ("(а) Порядок: Spearman JEV − Spearman правила ≥ 0.05",
         f"{rho_jev:.3f} − {rho_base:.3f} = {rho_jev - rho_base:+.3f}", rho_jev - rho_base >= 0.05),
        ("(а) Совпадение точки (калибровка по долям) ≥ 60% и выше правила",
         f"JEV {agree_jev:.0%}, правило {agree_base:.0%}", agree_jev >= 0.60 and agree_jev > agree_base),
        ("(а) Грубые ошибки (высокая ↔ низкая) ≤ 10%", f"{gross:.0%}", gross <= 0.10),
        ("(б) AUC «устойчивое выражение» ≥ 0.80", f"{auc_noul:.3f}", auc_noul >= 0.80),
        ("Стабильность (а) ≥ 95%", f"{stable_level:.0%}", stable_level >= 0.95),
        ("Стабильность (б) ≥ 95%", f"{stable_noul:.0%}", stable_noul >= 0.95),
    ]
    lines = [f"# Пилот фраз (домен разработки): отчёт ({args.out.name})", "",
             f"Модель JEV: {', '.join(sorted({r['model'] for r in rows}))}; фраз: {n}; "
             f"повторов на фразу: {min(r['repeats'] for r in rows)}–{max(r['repeats'] for r in rows)}",
             "Критерии: приложение PRD §A.3.", "",
             "| Критерий | Значение | Итог |", "|---|---|---|"]
    lines += [f"| {name} | {value} | {verdict(ok)} |" for name, value, ok in checks]
    lines += ["",
              f"Справочно: совпадение по собственным уровням JEV (без калибровки) {agree_raw:.0%}, "
              f"грубые ошибки без калибровки {gross_raw:.0%}.",
              f"Задержка: медиана {statistics.median(latencies):.0f} мс, "
              f"p95 {latencies[max(0, int(round(0.95 * len(latencies))) - 1)]:.0f} мс.", "",
              "## Матрица (эталон × JEV после калибровки)", "",
              "| эталон \\ JEV | low | medium | high |", "|---|---|---|---|"]
    for ref in LEVELS:
        cells = [sum(1 for r in rows if r["freq_level"] == ref and r["jev_level"] == j) for j in LEVELS]
        lines.append(f"| {ref} | " + " | ".join(map(str, cells)) + " |")
    lines += ["", "## Устойчивость: средняя вероятность «да» по клеткам", "",
              "| частота | устойчивые | свободные |", "|---|---|---|"]
    for lvl in reversed(LEVELS):
        cell = {k: [r["noul"] for r in rows if r["freq_level"] == lvl and r["assoc_class"] == k]
                for k in ("fixed", "free")}
        lines.append(f"| {lvl} | {statistics.mean(cell['fixed']):.2f} | {statistics.mean(cell['free']):.2f} |")
    lines += ["", "## Фразы", "",
              "| фраза | Zipf | частота | JEV | правило | NPMI | класс | «да» |", "|---|---|---|---|---|---|---|---|"]
    for r in sorted(rows, key=lambda r: -r["zipf"]):
        mark = "" if r["jev_level"] == r["freq_level"] else " ≠"
        lines.append(f"| {r['phrase']} | {r['zipf']:.2f} | {r['freq_level']} | {r['jev_level']}{mark} | "
                     f"{r['baseline_level']} | {r['npmi']:.2f} | {r['assoc_class']} | {r['noul']:.2f} |")
    (args.out / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    fields = ["phrase", "zipf", "freq_level", "jev_level", "jev_level_raw", "jev_score", "baseline",
              "baseline_level", "npmi", "assoc_class", "noul", "stable_level", "stable_noul"]
    with open(args.out / "comparison.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
    print("\n".join(lines[:lines.index("## Матрица (эталон × JEV после калибровки)")]))
    print(f"Полный отчёт: {args.out / 'report.md'}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["count", "stats", "sample", "replace", "run", "report"])
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--per-level", type=int, default=50)
    parser.add_argument("--thresholds", default='{"high": 4.0, "medium": 3.4}',
                        help='JSON с нижними границами Zipf: {"high": .., "medium": ..}')
    parser.add_argument("--npmi-fixed", type=float, default=0.5, help="устойчивое сочетание: NPMI не ниже")
    parser.add_argument("--npmi-free", type=float, default=0.3, help="свободное сочетание: NPMI ниже")
    parser.add_argument("--seed", type=int, default=12)
    parser.add_argument("--exclude", help="для replace: файл вычеркнутых фраз")
    parser.add_argument("--repeats", type=int, default=3, help="вызовов на фразу (стабильность)")
    parser.add_argument("--model", default="jev-latest")
    parser.add_argument("--workers", type=int, default=8)
    args = parser.parse_args()
    {"count": cmd_count, "stats": cmd_stats, "sample": cmd_sample, "replace": cmd_replace,
     "run": cmd_run, "report": cmd_report}[args.command](args)


if __name__ == "__main__":
    main()
