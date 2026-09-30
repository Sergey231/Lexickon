# Laya research digest — English word/phrase frequency

- Research date / accessed: 2026-09-27
- Scope: publicly available web evidence only; project files were not used as evidence.
- Sources read: 7, primary-first (official repository, model cards, documentation, and source code).
- Decision: **Laya cannot be treated as a drop-in, evidence-backed replacement for Jev for estimating English word/phrase frequency.** It can replace Jev's transport and typed-decision interface, but the shipped checkpoints do not natively estimate lexical/corpus frequency. A production replacement would require a frequency definition, labelled corpus-derived targets, task-specific fitting/fine-tuning (or at minimum calibrated ordinal buckets), and held-out evaluation against Jev/ground truth.

## Claims

### C1 — Laya is an encoder decision model, not a generative LM or native frequency estimator

- Claim: The English checkpoint is a 421M-parameter bidirectional model: ModernBERT-large (395M) plus a learned decision head with two transformer layers, option-marker scoring and an act/escalate head. Each option is scored at a `[MASK]` marker and normalized with softmax. The official model card exposes only three output primitives: categorical `choice`, ordinal `score`, and boolean probability `noul`. No native word-frequency, token-likelihood, corpus-count, percentile, Zipf-frequency, or continuous-regression output is documented.
- Implication: A prompt such as “how frequent is this phrase?” can only be mapped to supplied categories/ordinal levels; its output is a learned judgment over those labels, not an observed frequency or a probability derived from corpus counts. Training-data exposure alone is not evidence that this judgment is accurate.
- URL: https://huggingface.co/convaiinnovations/laya/blob/cce578c3df804585aea413f0413db0baa43dafc7/README.md
- Publisher: Convai Innovations / Hugging Face
- Pub date: not stated in card; revision `cce578c3` retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high
- Class: primary — official model card

### C2 — Output semantics are typed probabilities, with `score` explicitly ordinal

- Claim: `choice` returns a top label, per-option probabilities and confidence; `score` returns the expected level over an ordered rubric plus a distribution and confidence; `noul` returns calibrated P(true). The repository describes `score` use cases as severity/urgency/frustration, not arbitrary numeric regression.
- Implication: Laya could classify words/phrases into predeclared bins such as rare/common/very common. It does not natively return occurrences-per-million, a Zipf score, document frequency, or a corpus rank. Treating the expected ordinal level as an absolute frequency without task-specific calibration would change the meaning of the output.
- URL: https://github.com/NandhaKishorM/laya
- Publisher: Nandakishor M / Convai Innovations, GitHub
- Pub date: living repository; current page retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high
- Class: primary — official repository documentation

### C3 — Zero-shot transfer exists but is materially weaker and calibration is task-dependent

- Claim: The English model card reports macro accuracy 0.838 / ECE 0.060 for in-task test sets versus zero-shot held-out-task-family macro accuracy 0.651 / ECE 0.207. It explicitly tells users to evaluate calibration on their own distribution. The official benchmark guide says the base checkpoints can underperform a majority-class baseline on a specialized benchmark while a checkpoint fine-tuned on that benchmark reaches 0.766, and warns that this does not establish performance on a new domain.
- Implication: A zero-shot frequency rubric is technically callable but not validated for frequency. It is unsuitable as a silent Jev replacement until tested against labelled frequency data. A calibrated/fine-tuned head is the evidence-aligned path.
- URLs:
  - https://huggingface.co/convaiinnovations/laya/blob/cce578c3df804585aea413f0413db0baa43dafc7/README.md
  - https://nandhakishorm.github.io/laya/benchmarks/
- Publisher: Convai Innovations / Laya maintainers
- Pub date: not stated; current pages retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high
- Class: primary — official model card and official benchmark documentation

### C4 — Task specialization requires labelled examples and post-hoc calibration

- Claim: The maintainers' fine-tuning example uses labelled task examples, trains the Laya RLCD recipe, then performs post-hoc temperature calibration and held-out evaluation. The guide emphasizes that input/option representation can matter more than changing data and reports task-specific results rather than universal transfer.
- Implication: For lexical frequency, labels should be derived from a named corpus and metric (for example occurrences per million or Zipf scale), with phrase normalization/tokenization specified. Depending on desired output, either train ordinal bins and calibrate them, or add a genuine regression/ranking head; the shipped decision head alone does not supply the ground truth.
- URL: https://github.com/NandhaKishorM/laya/blob/main/docs/finetune_browser_agent.md
- Publisher: Nandakishor M / Convai Innovations, GitHub
- Pub date: living documentation; retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high for the general specialization workflow; medium for the recommended frequency-head design (engineering inference)
- Class: primary evidence + explicit engineering inference

### C5 — The available model family has three main variants, none frequency-specific

- Claim: Official model documentation lists: English `convaiinnovations/laya` (ModernBERT-large, 421M, 512-token input), multilingual `laya-multilingual` (mmBERT-base, 322M, default 1,024 tokens, optionally up to 8,192), and English `laya-typed-decisions` (ModernBERT-large, 421M, 1,024 tokens) specialized for four typed-decision workflow families. No frequency-specialized checkpoint is listed.
- Implication: For English lexical frequency the general English checkpoint is the nearest starting encoder, but none of the released variants supplies task-specific frequency supervision.
- URLs:
  - https://huggingface.co/convaiinnovations/laya-multilingual/blame/main/README.md
  - https://huggingface.co/convaiinnovations/laya-typed-decisions
- Publisher: Convai Innovations / Hugging Face
- Pub date: not stated; current cards retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high
- Class: primary — official model cards

### C6 — API compatibility with Jev is strong, semantic compatibility for frequency is unproven

- Claim: The official self-hosted server exposes `POST /v1/systemone` and states that Laya's answer payload is schema-compatible with Jev for `choice`, `score`, `noul`, and usage fields. Existing clients can repoint the base URL. The server honors explicit Laya checkpoint names or routes automatically.
- Implication: Integration replacement can be low-friction if the existing Jev use already consumes those typed primitives. This only proves wire compatibility; it does not prove equivalent decisions, calibration, or frequency accuracy.
- URL: https://github.com/NandhaKishorM/laya/blob/main/laya/serve.py
- Publisher: Nandakishor M / Convai Innovations, GitHub
- Pub date: living source; retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high
- Class: primary — official source code

### C7 — Local operation, hardware and latency are favorable but workload-sensitive

- Claim: The repository reports warm/preloaded latency of about 32.8 ms for the multilingual checkpoint and 39.5 ms for English on a Tesla T4, versus 193–464 ms on CPU. Cold checkpoint construction costs seconds; switching with only one resident checkpoint was measured at 7.4 s median on CPU and 10.3 s on T4. The Docker guide asks for 8 GB RAM and 10 GB disk for the CPU quickstart. The package supports PyTorch CPU/CUDA/MPS and optional ONNX dependencies.
- Implication: Laya is viable for local low-latency inference when preloaded, but production sizing must be benchmarked with the selected checkpoint, phrase length, batch shape and precision. Its operational advantage does not resolve task validity.
- URLs:
  - https://github.com/NandhaKishorM/laya
  - https://nandhakishorm.github.io/laya/docker/
  - https://github.com/NandhaKishorM/laya/blob/main/pyproject.toml
- Publisher: Laya maintainers / Convai Innovations
- Pub date: living docs/package metadata; package version 0.3.20 visible on 2026-09-27
- Accessed: 2026-09-27
- Confidence: high for reported measurements; medium for transfer to another host
- Class: primary — official docs and package metadata

### C8 — Inference avoids sampling, but cross-device/dtype bitwise determinism is not established

- Claim: Laya is non-autoregressive and performs a single forward pass. Official documentation reports that CUDA bf16 versus fp32 can move probabilities by as much as 0.073 and flipped 3 of 864 argmaxes in one parity suite; fp16 stayed within 0.019 and flipped none in that test. Fixed-seed benchmark inputs do not establish identical outputs across hardware.
- Implication: Repeated calls on one pinned model/runtime/device are expected to be stable absent hooks or changing inputs, but the reviewed sources do not provide a formal determinism guarantee. Pin checkpoint revision, package versions, device and AMP dtype; regression-test exact/epsilon behavior. Do not promise cross-platform bitwise equality.
- URL: https://github.com/NandhaKishorM/laya
- Publisher: Nandakishor M / Convai Innovations, GitHub
- Pub date: living repository; retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high on dtype sensitivity; medium on same-runtime stability because no explicit guarantee was found
- Class: primary evidence + bounded inference

### C9 — License permits local/commercial integration

- Claim: Model cards and package metadata declare Apache-2.0; the package is marked beta and supports Python 3.10–3.13.
- Implication: Licensing is not an apparent blocker for self-hosted replacement, subject to normal Apache-2.0 notice/compliance review and review of any separately packaged runtime/quantization dependencies.
- URLs:
  - https://huggingface.co/convaiinnovations/laya/blob/cce578c3df804585aea413f0413db0baa43dafc7/README.md
  - https://github.com/NandhaKishorM/laya/blob/main/pyproject.toml
- Publisher: Convai Innovations / Laya maintainers
- Pub date: living metadata; retrieved 2026-09-27
- Accessed: 2026-09-27
- Confidence: high
- Class: primary — official model/package metadata

## Replacement assessment

| Requirement | Evidence-based assessment |
|---|---|
| Local/offline execution | Yes after weights are downloaded; CPU/GPU/MPS deployment is documented. |
| Jev client/API compatibility | Yes at the `/v1/systemone` typed-decision wire level. |
| Native numeric word/phrase frequency | No evidence; shipped outputs are categorical, ordinal, or boolean probabilities. |
| Zero-shot qualitative frequency buckets | Technically possible, but unvalidated and not safe as an equivalent replacement. |
| Absolute/continuous frequency | Requires a defined corpus metric and a trained/calibrated task-specific model/head. |
| Deterministic production behavior | Pin the full runtime; no cross-device/dtype determinism guarantee was found. |
| Practical recommendation | **Conditional no for direct replacement; conditional yes only as a local encoder/runtime after a frequency-specific training and validation project.** |

## Contradictions / tensions

1. The project describes probabilities as mathematically calibrated, while its own model card reports much worse zero-shot ECE (0.207) than in-task ECE (0.060), and benchmark docs say base checkpoints can be over-confident or under-confident depending on task. Resolution: calibration is empirical and distribution-specific, not a universal guarantee.
2. Laya is described as Jev-compatible, but the same repository documents option-budget differences and task/precision-dependent output differences. Resolution: compatibility means request/response schema, not behavioral equivalence.
3. Marketing-level “single forward pass / ~33 ms” statements coexist with CPU latencies of 193–464 ms and multi-second cold reloads. Resolution: the low figure is warm GPU inference; deployment state and hardware must be named.
4. Non-autoregressive inference suggests repeatability, yet official parity data shows dtype-dependent probability and occasional argmax changes. Resolution: avoid treating non-sampling as proof of cross-runtime determinism.

## Leads for validation

1. Define the target precisely: corpus, year/domain, lemma vs surface form, case handling, word vs n-gram, raw frequency vs occurrences-per-million vs Zipf/log frequency.
2. Build a held-out benchmark from authoritative frequency tables, including multiword expressions, inflections, spelling variants, proper nouns, rare/OOV items, and domain-shift slices.
3. Run three arms on identical labels: zero-shot ordinal Laya, a lightweight fitted head over frozen Laya embeddings, and full Laya fine-tuning; compare against current Jev output and corpus truth using MAE/Spearman/calibration/risk-coverage.
4. If exact corpus frequency is available locally, test whether direct lookup plus normalization is simpler and more accurate than either neural model; reserve Laya for fallback/generalization to unseen forms.
5. Pin a checkpoint revision and serving dtype, then test repeatability across CPU, MPS and the intended production accelerator.

## Gaps

- No official evaluation of Laya on English lexical frequency, phrase frequency, Zipf estimation, corpus rank, or n-gram counts was found.
- No evidence was found that Jev's current frequency behavior and Laya's typed outputs are semantically equivalent, even though the API schemas align.
- No official ready-made frequency head/checkpoint or frequency-labelled training recipe was found.
- No formal guarantee of bitwise deterministic output across calls, threads, operating systems, hardware backends or precision modes was found.
- Exact checkpoint memory footprint/throughput under the intended production device and concurrency was not established by the reviewed sources.
- Model-card results are largely maintainer-reported; an independent, controlled head-to-head on the target frequency dataset remains necessary.

## Source inventory (7 read)

1. Official GitHub repository/README — https://github.com/NandhaKishorM/laya
2. Official English checkpoint model card — https://huggingface.co/convaiinnovations/laya/blob/cce578c3df804585aea413f0413db0baa43dafc7/README.md
3. Official multilingual checkpoint model card — https://huggingface.co/convaiinnovations/laya-multilingual/blame/main/README.md
4. Official typed-decisions checkpoint model card — https://huggingface.co/convaiinnovations/laya-typed-decisions
5. Official Jev-compatible server source — https://github.com/NandhaKishorM/laya/blob/main/laya/serve.py
6. Official benchmark/limitations guide — https://nandhakishorm.github.io/laya/benchmarks/
7. Official fine-tuning guide — https://github.com/NandhaKishorM/laya/blob/main/docs/finetune_browser_agent.md

