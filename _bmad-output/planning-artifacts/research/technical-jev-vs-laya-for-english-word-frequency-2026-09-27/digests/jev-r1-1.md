# JEV / System One for English word and phrase frequency — research digest

Research date / access date: **2026-09-27**  
Scope: public evidence about JEV (Jev 1.13 / System One), specifically whether it supplies objective English word/phrase corpus frequency and what capability would have to be preserved when replacing it with a local Laya model. Project files were not used as evidence.

## Decision summary

**JEV has no documented corpus-frequency contract.** Its public contract is a hosted, text-input decision API: caller supplies state plus bounded natural-language questions, and JEV returns a Choice distribution, an ordinal Score distribution/expectation, or a yes/no probability (Noul). These are model judgments over caller-defined alternatives—not occurrence counts, frequency-per-million, corpus rank, corpus identity, sampling period, or genre/register distributions.

Therefore, a local Laya model can replace JEV **without losing an objective corpus-frequency function, because no such JEV function could be confirmed**. It can only be considered functionally equivalent for a softer task such as “which expression seems more common?” or “bucket this expression from rare to common,” and then only after task-specific evaluation and recalibration. If the product requirement is objective/reproducible English frequency, neither JEV nor an unaugmented local generative model is an adequate source: use a versioned corpus/frequency table (with normalization, corpus provenance, date, dialect/register and phrase-counting rules) and deterministic local lookup/counting. A model may help normalize or disambiguate candidates, but should not invent the frequency.

## Claims

### C1 — The actual API contract is bounded decision-making, not retrieval or free-form generation

- **Claim:** `POST https://api.typesafe.ai/v1/systemone` accepts `state`, `model`, and named typed `questions`. Question types are exactly Noul, Choice, and Score. Noul returns a probability in `[0,1]`; Choice returns the highest-probability caller-defined option, the full distribution, and confidence; Score returns a probability-weighted position over 2–10 caller-described ordinal levels, their distribution/legend, and confidence. Choice supports at most 255 options.
- **Evidence:** TypeSafe API reference documents the complete request/response union and endpoint. The Choice and Score pages include recorded response examples and explain that Score is a weighted mean of level indices, not an independently measured quantity.
- **Source:** https://docs.typesafe.ai/api ; https://docs.typesafe.ai/primitives/choice ; https://docs.typesafe.ai/primitives/score
- **Publisher:** TypeSafe AI
- **Publication date:** not stated (live documentation); accessed 2026-09-27
- **Confidence:** high
- **Class:** fact / primary documentation

### C2 — JEV probabilities are answers to natural-language decisions, not objective corpus frequencies

- **Claim:** The documented probabilities belong to the alternatives/levels supplied in the question. `confidence` is derived from how concentrated that returned distribution is. Noul is specifically the probability that the answer to a proposition is “yes.” Nothing in the public contract identifies a reference corpus, exposes token/phrase counts, frequency per million, Zipf score, corpus rank, document frequency, or time/register/dialect breakdown.
- **Evidence:** TypeSafe defines Choice probability as a distribution across caller options; Score probability as a distribution across caller levels; Noul as probability of “yes”; and confidence as a statistic derived from those distributions. The model page says the same shared weights serve all accounts and domain knowledge/rules are supplied in state/instructions/criteria.
- **Source:** https://docs.typesafe.ai/introduction ; https://docs.typesafe.ai/confidence ; https://docs.typesafe.ai/models
- **Publisher:** TypeSafe AI
- **Publication date:** not stated (live documentation); accessed 2026-09-27
- **Confidence:** high for the positive contract; medium-high for “no documented corpus endpoint” (absence claim based on the official documentation index and API reference)
- **Class:** fact plus bounded negative finding / primary documentation

### C3 — Asking JEV for an exact or corpus-like frequency number is explicitly outside its reliable area

- **Claim:** TypeSafe says Jev 1.13 struggles with numeric precision, is not a calculator, does not count reliably, and should not use Score interpolation to reconstruct exact numbers. Counting belongs in code. This directly undermines treating a JEV Score/Noul output as an empirical word/phrase frequency.
- **Evidence:** The vendor’s “Jev 1.13 jaggedness” page states that counting characters, occurrences in passages, and list items is unreliable; errors grow with size; arithmetic/counting should be done in code. It also warns that score levels are weakly numerically calibrated and should not be used to reconstruct an exact magnitude.
- **Source:** https://docs.typesafe.ai/model-jaggedness/jev-1.13
- **Publisher:** TypeSafe AI
- **Publication date:** last reviewed 2026-09-17; accessed 2026-09-27
- **Confidence:** high
- **Class:** limitation / primary documentation

### C4 — JEV may support a subjective “commonness” judgment, but it is prompt- and rubric-defined

- **Claim:** A caller could define a Choice (`rare`, `uncommon`, `common`) or Score rubric and ask JEV to judge perceived commonness. The result would be a semantic judgment matching the supplied descriptions, not an observed corpus statistic. Rewording levels can change behavior and the vendor requires testing on the user’s own data.
- **Evidence:** The Score docs say levels must be descriptively defined, the model sees descriptions rather than numeric ordering semantics, different wordings can behave differently, and users should test levels on their own data. Confidence is uncertainty about the model’s distribution, not correctness or empirical coverage.
- **Source:** https://docs.typesafe.ai/primitives/score ; https://docs.typesafe.ai/confidence
- **Publisher:** TypeSafe AI
- **Publication date:** not stated; accessed 2026-09-27
- **Confidence:** high
- **Class:** inference directly grounded in documented semantics

### C5 — Stability requires version pinning and application-side calibration

- **Claim:** `jev-latest` and `jev-preview` currently resolve to `jev-1.13.0`, but aliases move and answers can change without client changes. TypeSafe advises pinning a version when thresholds have been tuned. Even within 1.13, semantically related formulations are not guaranteed to obey intuitive probability identities; a threshold tuned for Noul should not be transferred to Choice.
- **Evidence:** The Models page explicitly warns that aliases move and outputs can change. The jaggedness page shows divergent answers for equivalent-looking Noul/Choice or negated formulations and says not to assume structural invariants.
- **Source:** https://docs.typesafe.ai/models ; https://docs.typesafe.ai/model-jaggedness/jev-1.13
- **Publisher:** TypeSafe AI
- **Publication date:** Models page undated; jaggedness last reviewed 2026-09-17; accessed 2026-09-27
- **Confidence:** high
- **Class:** operational constraint / primary documentation

### C6 — Price and latency are attractive but vendor-reported; service maturity is early

- **Claim:** Jev 1.13 is listed at **$0.042 per million input tokens**, output tokens free, with 64k total request context / 32k state-plus-longest-question constraint, 250k tokens/s and 1,200 requests/minute. TypeSafe reports **70–500 ms** end-to-end latency. The launch was early access, rate limits may change without notice, and the vendor acknowledges its headline workflow speed/cost gains are likely at the high end and based on internally authored workflows/reference-model probabilities rather than corpus-frequency ground truth.
- **Evidence:** Models page provides current price/limits/context and warns limits are dynamic. The launch article provides latency and pricing and qualifies benchmark design/bias and early-access status.
- **Source:** https://docs.typesafe.ai/models ; https://typesafe.ai/blog/introducing-system-one-models-and-jev
- **Publisher:** TypeSafe AI; author Diogo Almeida for launch article
- **Publication date:** launch article 2026-09-15; Models page undated; accessed 2026-09-27
- **Confidence:** high for published price/limits; medium for real-world latency/general performance because figures are vendor-reported
- **Class:** commercial/operational fact plus vendor benchmark claim

### C7 — JEV itself is not evidenced as a locally licensed/open-weight model

- **Claim:** Official public materials expose a hosted bearer-authenticated API and open-source MIT SDKs/adapters. The official GitHub organization lists SDKs, skills and an LLM-backed adapter, but no JEV weights or inference repository. This supports treating JEV as a hosted proprietary dependency for planning; however, no explicit public “closed-weight license” statement was found, so the weights/licensing conclusion remains an inference rather than a confirmed legal fact.
- **Evidence:** API docs require the hosted TypeSafe endpoint/API key. The official GitHub organization distinguishes public client libraries and adapter projects; the Python/JS SDKs are MIT-licensed, which licenses clients, not model weights.
- **Source:** https://docs.typesafe.ai/api ; https://github.com/typesafe-ai
- **Publisher:** TypeSafe AI / official GitHub organization
- **Publication date:** GitHub repositories updated through 2026-09-26; API docs undated; accessed 2026-09-27
- **Confidence:** high that SDKs are open and hosted API exists; medium that JEV is unavailable for local self-hosting (negative finding, no explicit model-license page found)
- **Class:** fact plus inference / primary sources

## Replacement test for local Laya

| Required behavior | Does JEV actually promise it? | Can local Laya replace it? | Recommended implementation |
|---|---:|---|---|
| Exact corpus count / occurrences per million | No | “Replacing JEV” is the wrong comparison; neither model is sufficient alone | Versioned local corpus/frequency table and deterministic lookup/counting |
| Stable frequency rank / Zipf-like score | No | Only if backed by the same explicit local dataset and formula | Precompute rank/Zipf score; record corpus/version/normalization |
| Relative/commonness label (`rare`…`common`) | Yes only as a generic caller-defined judgment, not as a frequency product | Plausibly, after a labelled head-to-head test; no equivalence can be inferred from model identity | Define rubric; benchmark both against corpus-derived labels; calibrate per model/version |
| “Is this phrase familiar/natural/common in context?” | Fits JEV’s bounded semantic-decision shape | Plausibly, after evaluation | Treat as semantic acceptability, not frequency; retain uncertainty threshold/fallback |
| Offline/on-device operation | No public JEV self-hosting contract found | Yes, if the chosen Laya build/license/hardware permit it | Verify Laya-specific license, memory, latency and reproducibility separately |

Minimum acceptance test for a Laya substitution: freeze a labelled English word/phrase set stratified by frequency, phrase length, inflection, casing, punctuation, dialect/register and out-of-vocabulary items; derive labels from the chosen corpus; run pinned JEV and pinned local Laya prompts; compare rank correlation, bucket accuracy, calibration/error by stratum, repeatability and latency. Do not use JEV’s own probabilities as ground truth.

## Contradictions and tensions

1. **“Zero hallucinations” vs correctness.** The launch material says JEV “can’t hallucinate,” but the technical documentation states confidence is not a guarantee of correctness and catalogues wrong-answer modes. These can be reconciled only by reading “zero hallucinations” narrowly as schema/type validity: the model cannot emit an out-of-set answer, but it can select the wrong in-set answer with high confidence.
2. **“Calibrated” vs structural inconsistency.** Marketing says higher confidence means higher accuracy and similar inputs get similar outputs. The jaggedness guide warns that logically related formulations (Noul vs Choice, a proposition vs its negation) need not obey expected identities. Calibration must therefore be established per task, primitive, wording and pinned version.
3. **Stable low price/latency vs early service volatility.** Current price is explicit, but the vendor says sustainability can only be shown over time; rate limits are dynamic, and benchmark gains are internally designed and likely high-end.

## Leads for follow-up

- Obtain a live JEV key and run a small preregistered word/phrase commonness benchmark. Record the resolved model version, exact state/questions, raw distributions, latency and repeat runs.
- Research Laya separately: exact checkpoint, model card/training data, license, quantization, deterministic decoding, device memory/latency, and whether it exposes token log-probabilities. Token probability is still not corpus frequency, but it may be a repeatable proxy under a fixed tokenizer/model.
- Select an authoritative frequency source matched to product needs (general contemporary English vs spoken, web, books, learner vocabulary, regional English). Define lemma vs surface-form treatment and an n-gram policy before evaluating either model.
- Ask TypeSafe directly whether JEV has any unpublished frequency benchmark/training objective, deterministic mode/seed, retention tier for the intended plan, SLA, and commercial terms for pinned model availability.

## What could not be confirmed

- Any JEV endpoint or output field for objective word/phrase frequency, corpus counts, document frequency, rank, Zipf score, or corpus provenance.
- Any vendor claim that JEV was trained on, calibrated to, or benchmarked against a named English frequency corpus.
- A public JEV model card disclosing architecture size, training-data composition/cutoff, weights license, or a self-host/on-device distribution.
- A deterministic/seeded inference mode or exact repeatability guarantee.
- Independent, large-sample reproduction of the vendor’s 70–500 ms latency, calibration, or headline cost/speed comparisons.
- Whether local Laya meets the semantic commonness task: that requires Laya-specific primary-source research and an empirical benchmark, outside this JEV-only evidence slice.

## Sources actually used (8, primary-first)

1. TypeSafe API reference — https://docs.typesafe.ai/api
2. TypeSafe Models — https://docs.typesafe.ai/models
3. TypeSafe Choice — https://docs.typesafe.ai/primitives/choice
4. TypeSafe Score — https://docs.typesafe.ai/primitives/score
5. TypeSafe Confidence — https://docs.typesafe.ai/confidence
6. TypeSafe Jev 1.13 jaggedness — https://docs.typesafe.ai/model-jaggedness/jev-1.13
7. TypeSafe launch article, “Introducing System One Models & Jev” — https://typesafe.ai/blog/introducing-system-one-models-and-jev
8. TypeSafe official GitHub organization (including links to official SDK repositories) — https://github.com/typesafe-ai
