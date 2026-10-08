#!/usr/bin/env python3
"""Пилот KR-12: сравнение уровней полезности JEV с частотами Lemma Atlas.

План пилота: _bmad-output/planning-artifacts/prds/prd-Lexickon-2026-09-26/addendum.md, §A.1.

Шаги:
  sample   выбрать слова из Lemma Atlas и записать эталонный уровень по частоте
  run      отправить слова в JEV (с повторами для проверки стабильности)
  report   посчитать совпадение, стабильность, задержку и собрать лист слепой оценки
  judge    после ручной разметки листа посчитать «ценность сверх частоты»

Ключ JEV читается только из переменной окружения JEV_API_KEY и никуда не пишется.
Только стандартная библиотека Python 3.9+.
"""

import argparse
import csv
import json
import os
import random
import statistics
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

JEV_URL = "https://api.typesafe.ai/v1/systemone"
DEFAULT_MODEL = "jev-latest"

LEVELS = ["low", "limited", "medium", "high", "very_high"]  # индексы 0..4, как в ответе JEV

LEMMA_ATLAS = Path(os.environ.get("LEMMA_ATLAS_DIR", Path.home() / "Documents/Repositories/LemmaAtlas"))

# Пороги Zipf для перевода частоты в уровень (нижняя граница уровня, включительно).
# Зафиксированы в приложении PRD §A.1 «Диапазоны частот» (2026-10-07) и после формального прогона не меняются.
# Эталон для программирования — частота в домене, без поправки на специфичность.
ZIPF_THRESHOLDS = {
    "general": {"very_high": 5.0, "high": 4.0, "medium": 3.0, "limited": 2.0},
    "programming": {"very_high": 5.0, "high": 4.0, "medium": 3.0, "limited": 2.5},
}

CONTENT_POS = {"NOUN", "VERB", "ADJ", "ADV"}

# Отсекает артефакты корпуса (опечатки, склеенные идентификаторы, чужие языки):
# в выборку идут только слова из системного словаря английского.
DICTIONARY = Path("/usr/share/dict/words")

DOMAINS = {
    "general": {
        "index": "data/core/artifacts/core_frequency_index.json",
        "metadata": "data/core/artifacts/core_frequency_metadata.json",
        "instructions": (
            "How useful is it for an adult English learner (native language Russian) "
            "to learn this English word for reading everyday English: news, books, websites and conversation?"
        ),
        "criteria": [
            "A word the learner will almost never meet in everyday reading or conversation; learning it now is wasted effort.",
            "A word met only occasionally, mostly in literary, formal or specialised texts; worth learning only for advanced readers.",
            "A word met regularly in newspapers, books and websites; an intermediate learner benefits from knowing it.",
            "A word met often in everyday texts and conversation; not knowing it frequently blocks understanding.",
            "A core word found in almost every text; the learner needs it from the very start.",
        ],
    },
    "programming": {
        "index": "data/domains/programming/artifacts/domain_frequency_index.json",
        "metadata": "data/domains/programming/artifacts/domain_frequency_metadata.json",
        "instructions": (
            "How useful is it for a software developer learning English (native language Russian) "
            "to learn this English word for reading programming material: documentation, Stack Overflow, "
            "GitHub READMEs and technical books?"
        ),
        "criteria": [
            "A word the developer will almost never meet in programming documentation or discussions; learning it for work is wasted effort.",
            "A word met only occasionally in programming material, in narrow topics or rare phrasing.",
            "A word met regularly in documentation and technical discussions; a developer benefits from knowing it.",
            "A word met often in documentation, errors, APIs and discussions; not knowing it frequently blocks understanding.",
            "A core word found in almost every piece of programming documentation or code discussion.",
        ],
    },
}


def frequency_level(domain, zipf):
    if zipf is None:
        return "low"
    for level in ("very_high", "high", "medium", "limited"):
        if zipf >= ZIPF_THRESHOLDS[domain][level]:
            return level
    return "low"


def write_csv(path, rows, fields):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def read_csv(path):
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


# ---------- sample ----------

def load_dictionary():
    if not DICTIONARY.exists():
        sys.exit(f"Нет словаря {DICTIONARY}")
    return {w.strip().lower() for w in DICTIONARY.read_text(encoding="utf-8").splitlines()}


def load_index(domain):
    """Индекс Lemma Atlas (тот же, что читает tools/lemmaatlas_cli.py): частота по лемме целиком.

    Возвращает {lemma: {zipf, pos, core_zipf, specificity}}; pos — часть речи с лучшим рангом.
    """
    with open(LEMMA_ATLAS / DOMAINS[domain]["index"], encoding="utf-8") as f:
        index = json.load(f)
    entries = {}
    for lemma, data in index.items():
        if "domain" in data:  # доменный индекс: частота в домене + core + specificity
            core = data.get("core") or {}
            entry = {
                "zipf": data["domain"]["zipf"],
                "core_zipf": core["zipf"] if core.get("band") not in (None, "missing") else None,
                "specificity": (data.get("specificity") or {}).get("label", ""),
            }
        else:
            entry = {"zipf": data["zipf"], "core_zipf": None, "specificity": ""}
        pos = data.get("pos") or {}
        entry["pos"] = min(pos, key=lambda p: pos[p]["rank"]) if pos else ""
        entries[lemma] = entry
    return entries


def dataset_version(domain):
    with open(LEMMA_ATLAS / DOMAINS[domain]["metadata"], encoding="utf-8") as f:
        meta = json.load(f)
    return {"index": DOMAINS[domain]["index"], "version": meta.get("version"), "generated_at": meta.get("generated_at")}


def load_candidates(domain, dictionary):
    candidates = []
    for lemma, entry in load_index(domain).items():
        if not (lemma.isascii() and lemma.isalpha() and len(lemma) >= 3) or lemma != lemma.lower() \
                or lemma not in dictionary or entry["pos"] not in CONTENT_POS:
            continue
        candidates.append({"lemma": lemma, **entry})
    return candidates


def cmd_sample(args):
    rng = random.Random(args.seed)
    dictionary = load_dictionary()
    out = []
    for domain in args.domains:
        by_level = {level: [] for level in LEVELS}
        for c in load_candidates(domain, dictionary):
            by_level[frequency_level(domain, c["zipf"])].append(c)
        # Стратифицированная выборка: поровну на уровень, чтобы проверить всю шкалу.
        per_level, extra = divmod(args.per_domain, len(LEVELS))
        for i, level in enumerate(LEVELS):
            pool = by_level[level]
            k = per_level + (1 if i < extra else 0)
            if len(pool) < k:
                sys.exit(f"{domain}: в уровне {level} только {len(pool)} слов, нужно {k}")
            for c in rng.sample(pool, k):
                out.append({"domain": domain, "lemma": c["lemma"], "pos": c["pos"],
                            "zipf": f"{c['zipf']:.3f}", "freq_level": level,
                            "core_zipf": "" if c["core_zipf"] is None else f"{c['core_zipf']:.3f}",
                            "specificity": c["specificity"]})
    write_csv(args.out / "sample.csv", out,
              ["domain", "lemma", "pos", "zipf", "freq_level", "core_zipf", "specificity"])
    (args.out / "thresholds.json").write_text(json.dumps(ZIPF_THRESHOLDS, indent=2), encoding="utf-8")
    datasets = {domain: dataset_version(domain) for domain in args.domains}
    (args.out / "datasets.json").write_text(json.dumps(datasets, indent=2), encoding="utf-8")
    print(f"sample: {len(out)} слов -> {args.out / 'sample.csv'}")


# ---------- run ----------

def call_jev(key, model, domain, lemma, timeout=30.0):
    spec = DOMAINS[domain]
    body = {
        "state": f"English word: {lemma}",
        "model": model,
        "questions": {
            "usefulness": {"type": "score", "instructions": spec["instructions"], "criteria": spec["criteria"]},
        },
    }
    request = urllib.request.Request(
        JEV_URL,
        data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        method="POST",
    )
    delay = 1.0
    for attempt in range(6):
        started = time.monotonic()
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                payload = json.load(response)
            return payload, (time.monotonic() - started) * 1000
        except urllib.error.HTTPError as e:
            if e.code in (429, 529) and attempt < 5:
                time.sleep(delay)
                delay *= 2
                continue
            detail = e.read().decode("utf-8", "replace")[:500]
            raise RuntimeError(f"JEV {e.code} для '{lemma}' ({domain}): {detail}") from None
    raise RuntimeError("JEV: попытки исчерпаны")


def cmd_run(args):
    key = os.environ.get("JEV_API_KEY")
    if not key:
        sys.exit("Задайте ключ: export JEV_API_KEY=...")
    sample = read_csv(args.out / "sample.csv")
    raw_path = args.out / "jev_raw.jsonl"
    done = set()
    if raw_path.exists():
        for line in raw_path.read_text(encoding="utf-8").splitlines():
            r = json.loads(line)
            done.add((r["domain"], r["lemma"], r["repeat"]))
    jobs = [(row["domain"], row["lemma"], repeat) for row in sample for repeat in range(args.repeats)
            if (row["domain"], row["lemma"], repeat) not in done]
    print(f"run: {len(jobs)} вызовов ({len(done)} уже есть), потоков: {args.workers}")
    errors = []
    # Вызовы идут параллельно, а в файл пишет только главный поток; прерванный прогон продолжается с места остановки.
    with open(raw_path, "a", encoding="utf-8") as raw, ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {pool.submit(call_jev, key, args.model, domain, lemma): (domain, lemma, repeat)
                   for domain, lemma, repeat in jobs}
        for i, future in enumerate(as_completed(futures), 1):
            domain, lemma, repeat = futures[future]
            try:
                payload, latency_ms = future.result()
            except Exception as e:  # noqa: BLE001 — одна ошибка не должна терять остальные ответы
                errors.append(str(e))
                print(f"ошибка: {e}", file=sys.stderr)
                continue
            answer = payload["answers"]["usefulness"]
            raw.write(json.dumps({
                "domain": domain, "lemma": lemma, "repeat": repeat,
                "model": payload.get("model"), "latency_ms": round(latency_ms, 1),
                "score": answer["score"], "confidence": answer["confidence"],
                "probabilities": answer["probabilities"], "usage": payload.get("usage"),
            }, ensure_ascii=False) + "\n")
            raw.flush()
            if args.verbose or i % 50 == 0 or i == len(jobs):
                print(f"[{i}/{len(jobs)}] {domain:12} {lemma:20} #{repeat} score={answer['score']:.2f} "
                      f"conf={answer['confidence']:.2f} {latency_ms:.0f} ms")
    if errors:
        sys.exit(f"{len(errors)} вызовов с ошибкой; запустите run ещё раз, чтобы дозапросить их")


# ---------- report ----------

def jev_level(answer):
    # Уровень — самый вероятный, а не округлённый средний score: среднее размазывает бимодальные ответы.
    probs = answer["probabilities"]
    return LEVELS[int(max(probs, key=lambda k: probs[k]))]


def cmd_report(args):
    sample = {(r["domain"], r["lemma"]): r for r in read_csv(args.out / "sample.csv")}
    calls = {}
    for line in (args.out / "jev_raw.jsonl").read_text(encoding="utf-8").splitlines():
        r = json.loads(line)
        calls.setdefault((r["domain"], r["lemma"]), []).append(r)

    rows, latencies, models = [], [], set()
    for key, s in sample.items():
        runs = sorted(calls.get(key, []), key=lambda r: r["repeat"])
        if not runs:
            continue
        levels = [jev_level(r) for r in runs]
        latencies += [r["latency_ms"] for r in runs]
        models |= {r["model"] for r in runs}
        first = runs[0]
        rows.append({
            "domain": s["domain"], "lemma": s["lemma"], "pos": s["pos"], "zipf": s["zipf"],
            "freq_level": s["freq_level"], "core_zipf": s.get("core_zipf", ""),
            "specificity": s.get("specificity", ""), "jev_level": levels[0],
            "match": int(levels[0] == s["freq_level"]),
            "distance": LEVELS.index(levels[0]) - LEVELS.index(s["freq_level"]),
            "jev_score": f"{first['score']:.2f}", "jev_confidence": f"{first['confidence']:.2f}",
            "repeats": len(levels), "stable": int(len(set(levels)) == 1), "repeat_levels": " ".join(levels),
        })
    write_csv(args.out / "comparison.csv", rows, list(rows[0].keys()))

    lines = [f"# Пилот KR-12: отчёт ({args.out.name})", "",
             f"Модель JEV: {', '.join(sorted(m for m in models if m))}"]
    datasets_path = args.out / "datasets.json"
    if datasets_path.exists():
        for domain, info in json.loads(datasets_path.read_text(encoding="utf-8")).items():
            lines.append(f"Эталон {domain}: Lemma Atlas {info['version']} ({info['index']})")
    else:
        lines.append("Эталон: версия Lemma Atlas не записана (прогон до перехода на индексы)")
    lines.append("")
    for domain in sorted({r["domain"] for r in rows}):
        d = [r for r in rows if r["domain"] == domain]
        n = len(d)
        match = sum(r["match"] for r in d) / n
        within_one = sum(abs(r["distance"]) <= 1 for r in d) / n
        stable = sum(r["stable"] for r in d) / n
        mismatches = n - sum(r["match"] for r in d)
        upper = 1 - 20 / n
        lines += [
            f"## {domain} ({n} слов)", "",
            f"- Точное совпадение уровня: **{match:.0%}** ("
            + (f"критерий: окно 80% … {upper:.0%})" if n >= 100 else "окно 80% … 1−20/N определено только при N ≥ 100; это пробный прогон)"),
            f"- Совпадение с точностью до одного уровня: {within_one:.0%}",
            f"- Расхождений для слепой оценки: {mismatches} (критерий: не менее 20)",
            f"- Стабильность повторов: **{stable:.0%}** (критерий: не менее 95%)",
            f"- Средний сдвиг JEV относительно частоты: {statistics.mean(r['distance'] for r in d):+.2f} уровня",
        ]
        has_specificity = any(r["specificity"] for r in d)
        if has_specificity:
            lines += ["", "| слово | Zipf | Zipf core | специфичность | частота | JEV | conf | повторы |",
                      "|---|---|---|---|---|---|---|---|"]
        else:
            lines += ["", "| слово | Zipf | частота | JEV | conf | повторы |", "|---|---|---|---|---|---|"]
        for r in sorted(d, key=lambda r: -float(r["zipf"])):
            mark = "" if r["match"] else " ≠"
            extra = f"{r['core_zipf'] or '—'} | {r['specificity']} | " if has_specificity else ""
            lines.append(f"| {r['lemma']} | {r['zipf']} | {extra}{r['freq_level']} | {r['jev_level']}{mark} | "
                         f"{r['jev_confidence']} | {r['repeat_levels']} |")
        lines.append("")
    if latencies:
        p95 = sorted(latencies)[max(0, int(round(0.95 * len(latencies))) - 1)]
        lines += [f"Задержка: медиана {statistics.median(latencies):.0f} мс, p95 {p95:.0f} мс "
                  f"({len(latencies)} вызовов)", ""]
    (args.out / "report.md").write_text("\n".join(lines), encoding="utf-8")

    # Лист слепой оценки: только расхождения, оценки перемешаны под A/B.
    rng = random.Random(args.seed)
    blind, key_rows = [], []
    for r in [r for r in rows if not r["match"]]:
        options = [("jev", r["jev_level"]), ("freq", r["freq_level"])]
        rng.shuffle(options)
        blind.append({"domain": r["domain"], "lemma": r["lemma"], "A": options[0][1], "B": options[1][1],
                      "choice": ""})
        key_rows.append({"domain": r["domain"], "lemma": r["lemma"], "A": options[0][0], "B": options[1][0]})
    rng.shuffle(blind)
    write_csv(args.out / "blind_judging.csv", blind, ["domain", "lemma", "A", "B", "choice"])
    write_csv(args.out / ".blind_key.csv", key_rows, ["domain", "lemma", "A", "B"])
    print((args.out / "report.md").read_text(encoding="utf-8"))
    print(f"Слепая оценка: заполните колонку choice (A / B / =) в {args.out / 'blind_judging.csv'}, "
          f"не открывая .blind_key.csv, затем запустите judge.")


# ---------- judge ----------

def cmd_judge(args):
    key = {(r["domain"], r["lemma"]): r for r in read_csv(args.out / ".blind_key.csv")}
    by_domain = {}
    for r in read_csv(args.out / "blind_judging.csv"):
        choice = r["choice"].strip().upper()
        if choice not in ("A", "B", "="):
            sys.exit(f"Не заполнено или неверно: {r['domain']}/{r['lemma']} -> '{r['choice']}'")
        winner = "tie" if choice == "=" else key[(r["domain"], r["lemma"])][choice]
        by_domain.setdefault(r["domain"], []).append(winner)
    for domain, winners in sorted(by_domain.items()):
        n = len(winners)
        jev = winners.count("jev") / n
        print(f"{domain}: JEV точнее {winners.count('jev')}, частота точнее {winners.count('freq')}, "
              f"равноценно {winners.count('tie')} из {n} -> JEV {jev:.0%} (критерий: не менее 70% при n ≥ 20)")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["sample", "run", "report", "judge"])
    parser.add_argument("--out", type=Path, required=True, help="папка прогона")
    parser.add_argument("--domains", nargs="+", default=["general", "programming"], choices=list(DOMAINS))
    parser.add_argument("--per-domain", type=int, default=10)
    parser.add_argument("--repeats", type=int, default=3, help="вызовов на слово (стабильность, A-4)")
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--workers", type=int, default=8, help="параллельных вызовов JEV (лимит JEV ~1200 в минуту)")
    parser.add_argument("--verbose", action="store_true", help="печатать каждый вызов")
    parser.add_argument("--seed", type=int, default=12)
    args = parser.parse_args()
    {"sample": cmd_sample, "run": cmd_run, "report": cmd_report, "judge": cmd_judge}[args.command](args)


if __name__ == "__main__":
    main()
