# Lexickon Product Brief — Addendum

## Parked future direction

- A voice AI coach may eventually analyze a user's speech, identify recurring errors, and create personalized learning decks around the highest-value growth areas. This remains outside the initial product thesis until its connection to usefulness-based vocabulary selection is validated.

## Planning reconciliation

- The chosen V1 includes usefulness assessment for words and phrases, card creation, and spaced repetition. The current iOS MVP implementation plan ends at frequency lookup and does not yet define card, deck, or SRS stages; downstream planning must reconcile that scope.
- Current contracts do not yet settle side-by-side general/domain scoring, phrase scoring, sense or part-of-speech handling, or the operational definition of usefulness. These remain open after the 2026-09-30 update and must be settled in the PRD and architecture.
- The PRD's frequency source (KR-1) is unresolved: the published JEV API returns choice / ordinal score / probability over caller-defined levels, not a corpus frequency. The four-level usefulness scale fits that shape, but per-domain evaluation, phrase handling and per-domain cost (KR-6 lookup cap) must be verified.

## 2026-09-30 thesis update: rationale

- Why the brief changed: the PRD (2026-09-26/28) describes a wider product than the 2026-09-21 brief. The user decided the PRD is the master document (KR-11) and merged the two: audience framing and translation from the PRD; usefulness thesis, validation plan, simple card and plain interval SRS from the brief.
- Domain model: usefulness assessments are a list per domain, not fixed "general" and "development" fields. Adding a domain is data and configuration work. The extended domain catalog is post-beta; the domain-selection setting and a short domain list move to before beta (see the beta scope update below).
- Promise wording: "обоснованная уверенность" (level, confidence, short basis, honest insufficient-data state) replaces any claim that a word "will definitely be useful", consistent with the brief's principle that usefulness is an explainable signal, not objective truth.
- Terminology: the user-facing term is "полезность". Frequency, corpus data or model output are only the source of the signal. Downstream documents (PRD glossary, UX, stories) should use one term.
- Validation caveat: the personal experiment runs on the development domain because it already exists and the author is the first tester. This does not prove demand in other domains; the public beta covers that (see the beta scope update below).

## Superseded from the 2026-09-21 brief

- First user narrowed to a software developer (now: job-based description, developers first).
- Differentiation as a side-by-side "general English versus software development" score (now: usefulness across user-chosen domains).

## 2026-09-30 beta scope update

- The user decided the public beta should test the whole idea rather than one professional domain, so it runs on people who learn English and read materials in it, not only developers. The personal experiment stays on the development domain (author is the first tester).
- Consequence: the domain-selection setting and a short list of 3–4 domains (for example development, science, business, medicine) move from post-V1 to "before beta". The extended domain catalog stays post-beta.
- Planning impact: PRD and architecture must cover per-domain data for several domains by beta, per-domain cost against the lookup cap (KR-6), and a settings screen for domain selection. The "V1 = one domain" wording applies to the personal experiment only.

## Details moved out of the brief (2026-09-30)

- Summary of changes: thesis widened from "general English vs development" to usefulness across user-chosen domains; first user described by job, not profession; Russian translation added to V1; public beta moved to a general audience with domain choice from a short list.
- Personal experiment, full measurement list: the number of items met, the decision taken, decision time, confidence (1–5), cards created, review queue state.
- Personal experiment, additional criterion moved out of the brief: the review queue does not grow faster than in the recorded self-assessment of the usual process, at comparable reading volume.
- Personal experiment, self-assessment recorded before the start: average time per word decision, confidence (1–5), queue growth at normal reading volume. Baseline replaces the earlier separate two-week observation period because the author already uses another card app with no usefulness scoring.
- Secondary signal: repeat encounters with learned vocabulary in real reading are recorded, but four weeks may be too short for a reliable conclusion.
- Public beta, full list of questions: do participants recognise the problem of choosing useful vocabulary; do they go from checking a real word or phrase to the first card; do the assessments change their decisions; do they choose domains and find domain assessments useful; do they return to checking new vocabulary and to reviews in week two; do they find the assessments understandable and trustworthy; do they want to keep using the product after the beta. Thresholds are set after the personal experiment; willingness to pay is tested separately after repeat use is confirmed.
- Risk moved out of the brief: the development domain is broad (documentation, interviews, team communication, individual stacks); wording may differ noticeably.

## 2026-09-30 reconciliation decisions (KR-11)

- Cards and SRS: the brief wins over the PRD for V1 — simple user-built card, plain interval algorithm, no LLM card generation and no LLM difficulty. This reverses the PRD's FR-3, FR-7 and the decided KR-2 (SM-2 with LLM modifier) for V1; the PRD must be edited. LLM generation and difficulty stay possible later (stage after beta). Rationale: the thesis under test is the usefulness decision, and LLM features add cost and an undecided provider (KR-3) to the experiment.
- Domain thesis: the brief keeps usefulness per domain; the PRD has no domain concept and must gain one (affects FR-1, KR-1, glossary, UJ-1).
- Metrics: the brief's validation plan (personal experiment, then beta) stands; PRD metrics SM-1…SM-5 (week-1 retention 40%, lookup-to-save 25%, cache hit rates) are not brief gates and are revisited after the beta.
