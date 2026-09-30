# Frequency validity: Jev vs Laya for English words and phrases

Accessed: 2026-09-27  
Decision: whether Jev or Laya can replace a corpus-backed source for English “frequency per million” (fpm), and what claim/metric remains defensible if used.

## Bottom line

Do **not** replace a corpus-backed frequency source with either Jev or base Laya and continue calling the output “frequency per million.” Fpm is an empirical corpus statistic,

`fpm = observed occurrences / observed corpus tokens * 1,000,000`,

conditioned on corpus, period, register, locale, tokenization, case, and whether the unit is a surface form, lemma, or n-gram. Jev and Laya expose typed decisions/scores and confidence probabilities, not corpus counts. Their confidence is confidence in an answer under a decision task; it is not the probability that a token or phrase occurs in English.

Before task-specific validation, the strongest honest product label is **model-estimated commonness** or an **ordinal frequency band**. After validation against a named reference corpus, the defensible continuous label becomes **estimated Zipf frequency relative to [corpus/version]**, with error and coverage reported. Calling it “frequency per million” is defensible only when the value is calculated from counts (or when a learned estimator has been explicitly calibrated to those counts and is clearly labelled as an estimate, not an observation).

For phrases, the distinction is especially important: `wordfreq` does not generally return observed phrase counts. Its current multi-token path combines individual-token frequencies using `1/f = 1/f1 + 1/f2 + ...`; that is a heuristic, not n-gram frequency. Use observed COCA/custom-corpus n-gram counts as phrase gold data.

## Evidence claims

### Claim 1 — Fpm and Zipf are corpus-derived quantities, not semantic judgments

- **claim:** SUBTLEX-US defines word frequency per million as a normalized count from a 51-million-word American subtitle corpus. It separately reports contextual diversity (percentage of films containing the word), demonstrating that total frequency and spread are distinct measurements. The site also warns that names can be overestimated.
- **URL/source:** https://www.ugent.be/pp/experimentele-psychologie/en/research/documents/subtlexus
- **publisher:** Ghent University, Department of Experimental Psychology
- **pub_date:** 2009 dataset/paper; current university page
- **accessed:** 2026-09-27
- **confidence:** high
- **class:** primary academic corpus methodology

### Claim 2 — The Zipf scale is a log transform of fpm, and corpus suitability matters

- **claim:** Van Heuven et al. define `Zipf = log10(frequency per billion) = log10(fpm) + 3`; thus 1 fpm is Zipf 3. Their British-English validation shows that a region/register-matched corpus predicts lexical decisions better than mismatched alternatives, and notes American/British usage divergence. They also show that most word types are below 1 fpm, making raw-scale errors and zeros particularly problematic.
- **URL/source:** https://journals.sagepub.com/doi/10.1080/17470218.2013.850521
- **publisher:** Quarterly Journal of Experimental Psychology / SAGE
- **pub_date:** 2014-06-01
- **accessed:** 2026-09-27
- **confidence:** high
- **class:** primary academic measurement/validation

### Claim 3 — Contextual diversity carries information not captured by raw count

- **claim:** In spoken-word recognition experiments, contextual diversity (number of documents containing a word) and semantic distinctiveness explained variance beyond raw word frequency; raw frequency alone explained little unique variance in those datasets. Therefore, a single fpm value should not be treated as universal familiarity or learnability.
- **URL/source:** https://pmc.ncbi.nlm.nih.gov/articles/PMC3401190/
- **publisher:** PubMed Central / U.S. National Library of Medicine (archived journal article)
- **pub_date:** 2012
- **accessed:** 2026-09-27
- **confidence:** high
- **class:** primary academic psycholinguistic validation

### Claim 4 — COCA supports observed words and phrases, with genre/time breakdowns

- **claim:** COCA contains about one billion words from roughly 500,000 texts across eight genres and 1990–2019, supports searches for words, exact/fuzzy phrases, lemmas and constructions, and reports results by genre and period. Its downloadable data include observed 2–5-grams occurring at least four times. It is therefore a plausible general-American-English reference, but not a timeless or domain-neutral oracle; genre/time strata must be retained.
- **URL/source:** https://www.english-corpora.org/coca/help/tour.asp and https://www.english-corpora.org/coca/help/download.asp
- **publisher:** English-Corpora.org / Mark Davies
- **pub_date:** 2020 corpus release/help material
- **accessed:** 2026-09-27
- **confidence:** high for corpus composition/features; medium for suitability to any particular product population
- **class:** primary corpus documentation

### Claim 5 — `wordfreq` is useful for single-word baselines but its phrase result is not phrase fpm

- **claim:** The current `wordfreq` implementation defines Zipf consistently (`10^Zipf` occurrences per billion; Zipf 3 = 1 per million) and builds English lists from multiple sources. For multi-token input it does not look up an observed n-gram count; it combines token frequencies by the reciprocal-sum formula, returns the minimum if any token is missing, and quantizes output to 0.01 Zipf. Therefore it is an appropriate general-purpose single-word comparison baseline, but not ground truth for phrase frequency or very new/OOV items.
- **URL/source:** https://github.com/rspeer/wordfreq/blob/master/wordfreq/__init__.py
- **publisher:** `rspeer/wordfreq` (Robyn Speer), GitHub
- **pub_date:** n.d., current `master`
- **accessed:** 2026-09-27
- **confidence:** high
- **class:** primary software implementation

### Claim 6 — Jev’s native task is typed probabilistic decision-making, not frequency estimation

- **claim:** TypeSafe describes Jev as “unstructured state in, typed probabilistic decisions out,” optimized for classify/route/score/extract/branch workflows. Its published evaluations compare answers to reference decisions and explicitly acknowledge workflow-author bias and reference-model dependence. Nothing in the read source establishes corpus-count recovery, lexical frequency regression, phrase-frequency measurement, or neologism coverage.
- **URL/source:** https://typesafe.ai/blog/introducing-system-one-models-and-jev
- **publisher:** TypeSafe AI
- **pub_date:** 2026-09-15
- **accessed:** 2026-09-27
- **confidence:** high for capability contract; low for vendor performance generalization
- **class:** primary vendor documentation

### Claim 7 — Base Laya is also a decision model; fine-tuned gains do not establish zero-shot frequency validity

- **claim:** Laya is a 421M-parameter ModernBERT-based decision encoder with choice/score/noul heads. Its own model card says the base English checkpoint scores 0.362 on its typed-decisions benchmark versus 0.766 after fine-tuning on that benchmark’s training split, and documents high-cardinality/token-budget failures. No frequency-specific training or evaluation is reported. This supports using Laya only after task-specific training/validation, not treating the base encoder’s intuition as a corpus statistic.
- **URL/source:** https://huggingface.co/convaiinnovations/laya/blob/main/README.md
- **publisher:** Convai Innovations, Hugging Face model card
- **pub_date:** 2026-09, continuously updated
- **accessed:** 2026-09-27
- **confidence:** high for architecture and disclosed limitations; medium for self-reported benchmark figures
- **class:** primary model documentation

### Claim 8 — Independent Jev-vs-Laya evidence exists, but it is classification evidence and is task-dependent

- **claim:** `sysone-bench` evaluates byte-identical inputs and reports Jev 1.13.0 accuracy 0.9065 versus Laya 0.3.11 accuracy 0.6863 across 1,240 scored decisions, with reproducible artifacts and statistical testing. However, the labels were corrected by one reviewer from AI drafts, with no second reviewer or adjudication, and the suites are decision/classification tasks—not corpus-frequency estimation. It establishes the need for a same-input, target-task benchmark, not Jev’s validity for fpm.
- **URL/source:** https://github.com/instax-dutta/sysone-bench
- **publisher:** instax-dutta, GitHub
- **pub_date:** 2026-09
- **accessed:** 2026-09-27
- **confidence:** medium
- **class:** independent reproducible benchmark

## Contradictions and reconciliation

1. **Laya vendor comparison vs independent head-to-head.** Laya’s model card reports a fine-tuned Laya checkpoint ahead of Jev on its typed-decisions benchmark (0.766 vs 0.727), but it also says the Jev number came from third parties and prompts/samples differed. `sysone-bench`, using byte-identical inputs, reports Jev ahead (0.9065 vs 0.6863). These are not directly commensurable model rankings. Reconciliation: performance is benchmark-, prompt-, version-, and fine-tuning-dependent; only an identical-input frequency benchmark can decide this use case.
2. **“Calibrated probability” vs occurrence probability.** Jev/Laya training aims to calibrate confidence in discrete/ordinal answers. Corpus probability is a different estimand. A calibrated 0.8 answer confidence cannot be converted into 800,000 occurrences per million.
3. **General frequency vs target-population frequency.** SUBTLEX favors conversational subtitle exposure; COCA balances several written/spoken/media registers; domain corpora can differ sharply. There is no contradiction once every result is named by corpus, time window, locale, and unit.
4. **Phrase support.** COCA provides observed n-grams; `wordfreq` multi-token output is a token-frequency heuristic. They answer different questions and must not share an “fpm” label.
5. **Structured output vs semantic correctness.** Jev’s inability to emit malformed free text and Laya’s non-generative head reduce output-format failure; neither prevents a wrong semantic decision. Independent accuracy below 1.0 demonstrates the distinction.

## Proposed pre-replacement benchmark

### 1. Freeze the estimand first

Declare all of: American or British English; reference period; target registers and weights; surface form vs lemma; case sensitivity; tokenization; punctuation/hyphen policy; and phrase matching rules. Separate:

- **general contemporary American word-form frequency**;
- **conversational exposure** (SUBTLEX-like);
- **domain frequency** (product-specific corpus);
- **exact contiguous phrase frequency**;
- **meaning/sense frequency** (requires sense-annotated evidence and is not a surface-count problem).

### 2. Build gold labels from counts, never from another model

- Single words: use a frozen, licensed COCA export/query snapshot for general American English; keep SUBTLEX-US as an external-register test rather than mixing the two without weights.
- Phrases: use exact 2–5-gram counts or count them in the frozen corpus. Do not use `wordfreq` phrase output as gold.
- New terms: add a separately dated recent-web/news/social slice. A zero in an older corpus means “not observed in this corpus,” not “frequency is zero in current English.”
- Preserve count, denominator, number of documents, genre/time distribution, and a sampling/bootstrapped uncertainty interval.

### 3. Stratify before sampling

Evaluate separately by Zipf/fpm band, single word vs 2–5-gram, lemma vs inflection, capitalization/proper-name status, spelling variant, genre concentration, neologism/OOV status, and domain jargon. Include adversarial minimal pairs and plausible nonexistent strings. Keep a final sealed test set that is never used for prompt design, fine-tuning, temperature fitting, or threshold selection.

### 4. Compare like-for-like systems

- Pin Jev version, Laya checkpoint/commit, prompt/question schema, temperature/calibrator, and runtime.
- Evaluate zero-shot Jev, zero-shot base Laya, and a task-fine-tuned Laya separately; do not transfer the fine-tuned result to the base model.
- Baselines: corpus lookup (oracle when covered), `wordfreq` for single words, corpus-band majority, and a simple supervised regressor on lexical/corpus features if replacement latency is the concern.
- Give both models byte-identical input and output bins; repeat calls if the hosted model is stochastic or silently versioned.

### 5. Report metrics that match the claim

For a **continuous estimate**, predict Zipf rather than raw fpm and report:

- MAE and RMSE in Zipf units;
- median absolute error and 90th/95th-percentile absolute error;
- Spearman rank correlation;
- coverage within ±0.5 and ±1.0 Zipf;
- document-cluster bootstrap confidence intervals;
- the same metrics for every stratum above.

Raw-fpm MAE is dominated by a few extremely common terms; raw-fpm MAPE is unstable near zero. Convert an estimated Zipf back to estimated fpm only for display, preserving the “estimated” label.

For an **ordinal band** (`<0.1`, `0.1–1`, `1–10`, `10–100`, `100+` fpm, or equivalent Zipf bands), report macro-F1, balanced accuracy, ordinal MAE, and confusion by adjacent/non-adjacent band. If the model returns confidence, report Brier score/ECE for **band correctness or threshold events**, not as token occurrence probability. Add risk–coverage curves for an abstain/fallback-to-corpus policy.

### 6. Replacement gate

Do not approve replacement from overall accuracy alone. Pre-register product tolerances and require the candidate’s held-out error/coverage to be non-inferior to the current source in every load-bearing stratum, especially phrases, rare terms, recent terms, and domain jargon. Revalidate after model-version, prompt, calibration, corpus, or target-population changes.

## Metric/label decision

| Situation | Honest metric/label |
|---|---|
| Direct corpus count | “frequency per million in `<corpus, version, slice>`” |
| Log-transform of direct count | “Zipf frequency in `<corpus, version, slice>`” |
| Validated continuous Jev/Laya output | “estimated Zipf frequency relative to `<corpus>`,” plus Zipf MAE/interval and coverage |
| Validated categorical Jev/Laya output | “estimated frequency band/commonness class,” plus macro-F1/ordinal MAE and calibration of correctness |
| Unvalidated model output | “model-estimated commonness score”; no fpm/Zipf claim |
| `wordfreq` multi-token output | “token-frequency heuristic”; not observed phrase fpm |

## Gaps / what was not found

- No independent Jev-vs-Laya benchmark for word or phrase frequency estimation was found in this run.
- No evidence was found that Jev’s training target, or base Laya’s training target, includes recovery of corpus counts/fpm or Zipf regression.
- No evidence was found for either model’s validity on neologisms, rare/OOV terms, proper names, domain jargon, or exact phrase counts.
- Jev is a closed hosted model, so training-corpus overlap and silent-version risk cannot be independently audited from the sources read.
- COCA’s balanced 1990–2019 snapshot and SUBTLEX-US’s older subtitle corpus are valuable references but cannot alone establish 2026 usage or a product-specific domain distribution.
- Low-count phrase estimates need explicit censoring/uncertainty treatment; the COCA downloadable n-gram list’s four-occurrence floor means “absent from list” is not an exact zero.

## Recommendation

Retain corpus lookup/counting as the source of truth. If latency, licensing, or coverage motivates a model layer, use Jev or a fine-tuned Laya only as a **fallback estimator with abstention**, calibrated to a frozen corpus and reported as estimated Zipf/band. On evidence read here, Jev is the more credible zero-shot candidate for a pilot because the only same-input independent decision benchmark favors it; Laya is the more controllable candidate when local inference, inspectable weights, and task-specific fine-tuning matter. Neither has earned an fpm claim without the proposed target benchmark.
