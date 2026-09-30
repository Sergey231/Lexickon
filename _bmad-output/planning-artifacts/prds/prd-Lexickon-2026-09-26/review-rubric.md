# PRD Quality Review — prd-Lexickon-2026-09-26

*Run 2026-09-28 against the updated `prd.md` (status: draft) and reconciled `addendum.md`. Supersedes the earlier review, which was written against the pre-proxy version. Inputs cross-checked: product brief + brief addendum (2026-09-20/21), technical research "JEV vs Laya" (2026-09-27).*

## Overall verdict
The PRD is well structured, its FRs mostly carry testable bounds, and the open decisions are now honestly tracked in §1.1. But two upstream inputs contradict its core: the JEV research says the published JEV API does not return `frequency_per_million` at all (the whole of FR-1 rests on that field), and the product brief defines a different product (developer audience, two side-by-side usefulness assessments on a four-level scale, no LLM card builder). Until both are reconciled the PRD is not safe to feed UX, architecture or epics.

## Decision-readiness — thin
Decisions are now stated as decisions (§1.1: KR-2, KR-5, KR-9, KR-10 decided; KR-6 assumed). The proxy architecture is confirmed and consistent between PRD and addendum. What holds the dimension back is that the central decision, "frequency lookup returns `frequency_per_million`", was made against a contract nobody has verified, and the research (`research.md`, "Резюме решения") states the published contracts do not support it. KR-1 is listed as an open question, but the PRD body treats its answer as settled (FR-1 response fields, UJ-1 "Common / 120 per million").

### Findings
- **[critical]** Core metric contradicts the research (§4.1 FR-1, §2.3 UJ-1, §3 Glossary "Frequency Metric", §7 SM-2) — FR-1 requires `frequency_per_million` and `confidence` from JEV; the research concludes JEV `/v1/systemone` returns choice / ordinal score / probability over caller-defined levels, not a corpus count, and recommends a corpus-based frequency source with JEV or Laya as an auxiliary component. *Fix:* decide the frequency source (corpus data, JEV ordinal score, or a hybrid), then rewrite FR-1, UJ-1, the Glossary entry and the shared-cache semantics (FR-9) to match.
- **[high]** KR-1 is open but downstream text presumes its answer (§1.1 KR-1 vs §4.1 FR-1 consequences) — *Fix:* until KR-1 is resolved, mark the FR-1 response fields as provisional or restate them at the level the source actually supports.

## Substance over theater — adequate
One persona (Maria) with concrete context; NFRs carry numbers (3 s p95, 100 ms write, 2 s LLM call); differentiation is stated. The persona, however, does not match the brief (see Strategic coherence), so it is content that is specific but possibly for the wrong user.

### Findings
- **[medium]** Vision is generic across language apps (§1) — "type, see, decide, learn" would fit any vocabulary app. The brief's real differentiator (transparent dual assessment: general English vs developer written English) is absent. *Fix:* restate the thesis after the brief reconciliation.

## Strategic coherence — thin
The PRD has an internal thesis (on-demand frequency + LLM-adaptive SRS replaces packs), but it diverges from the brief on nearly every axis:

| | Brief (2026-09-20/21) | PRD (2026-09-26/28) |
|---|---|---|
| First user | Developer reading docs and technical articles | Maria, linguistics PhD student reading novels |
| Core value | Two independent, explainable usefulness assessments (general English; developer written English), four levels, confidence, short explanation, no total score | One `frequency_per_million` number plus confidence |
| Cards | Simple card, user may edit | LLM generates 1–3 cards with examples and audio hint; brief lists "умный конструктор карточек" as out of V1 |
| Validation | 2-week baseline + 4-week personal experiment, then beta with 20–30 developers, explicit thresholds | Generic retention/save-rate metrics (SM-1…SM-5) with no experiment or beta plan |
| Excluded | Android, extra domains, feed, role/stack specialization, voice AI | Same exclusions, but adds LLM difficulty scoring and Russian translation |

### Findings
- **[critical]** PRD and brief describe different products (§1, §2, §4, §7 vs brief "Первая версия", "Проверка идеи") — no document records a decision to drop the developer audience, the dual-domain assessment, or the personal-experiment validation plan. *Fix:* decide explicitly which document wins; either update the PRD to the brief's product or amend the brief and log why the thesis changed.
- **[high]** Success Metrics do not test the brief's hypotheses (§7) — SM-1…SM-5 measure activity; the brief's criteria (decision time −30%, confidence +1, decision changed in ≥20% of cases) are missing. *Fix:* carry the brief's criteria into §7 or state why they were replaced.
- **[medium]** Brief addendum flags unresolved planning items (phrase scoring, sense / part-of-speech handling, operational definition of usefulness) that the PRD neither resolves nor lists (§8). *Fix:* add them to §8 or defer them explicitly in §6.2.

## Done-ness clarity — adequate
Most FRs have bounded consequences (FR-1 timeouts and errors, FR-6 100 ms, FR-8 30 days / 500 entries). Weak spots are contradictions between journeys and FRs and dependence on unresolved KRs.

### Findings
- **[high]** LLM difficulty timing contradicts itself (§2.3 UJ-2 step 5 vs §4.2 FR-7) — UJ-2 says the LLM assesses difficulty for each rating plus history; FR-7 says difficulty is assessed once per card on first review and cached. *Fix:* pick one behavior and align both.
- **[medium]** FR-2 "Translation appears within 500 ms" has no source (KR-4 open, KR-1 unresolved on whether JEV returns translation). *Fix:* keep the bound but mark it conditional on the provider.
- **[medium]** Audio scope is inconsistent (§4.1 FR-3 "optional TTS audio hint", UJ-2 "audio play button", §5 "Audio is TTS hint only", §6.2 "Text-to-speech … NON-GOAL for MVP"). *Fix:* decide whether any audio ships in v1 and remove the rest.
- **[low]** FR-5 VoiceOver spec omits the frequency badge (§4.2 FR-5). *Fix:* add it to the announced labels.

## Scope honesty — adequate
Non-goals are explicit and the Assumptions Index roundtrips. Open-items density is high for a green-light PRD: five open KRs (KR-1, 3, 4, 7, 8), six Open Questions in §8, and several `[NOTE FOR PM]` callouts, all owned by one person with target dates "at architecture".

### Findings
- **[medium]** Open Questions in §8 predate the KR table and partly overlap it (§8 items 1, 2 vs KR-1, KR-6) — *Fix:* merge or cross-reference so each open item lives in one place.
- **[low]** Target dates for open KRs are "At architecture" rather than dates (§1.1). *Fix:* acceptable for now; set dates when architecture starts.

## Downstream usability — adequate
Glossary present, FR-1…FR-10 contiguous, UJ-1/UJ-2 have a named protagonist, addendum now consistent with the PRD.

### Findings
- **[medium]** Glossary drifts from the brief's vocabulary (§3) — the brief uses "полезность" / usefulness levels; the PRD uses "Frequency Metric". Whatever the reconciliation decides, one term must be used across PRD, UX and stories. *Fix:* settle the term with the frequency-source decision.

## Shape fit — adequate
Consumer product with two journeys: UJs are load-bearing, shape is right. Brownfield aspects (existing backend and auth) live in the addendum (§D–E), which is acceptable; the PRD body only notes "Auth: existing".

### Findings
- **[low]** Brownfield baseline is thin in the body (§6.1 "Auth … (existing)") — KR-7 asks what auth already has. *Fix:* inventory the backend's current auth in the same pass that closes KR-7.

## Mechanical notes
- Assumptions Index: inline `[ASSUMPTION]` tags (FR-1 ×2, FR-7 ×1) all indexed; revised entries for #5, #6, #7 and KR-6 added.
- ID continuity: FR-1…FR-10, UJ-1/2, SM-1…SM-5, SM-C1/C2, KR-1…KR-10 contiguous; no unresolved cross-references found.
- Naming: "Jeff" fully replaced by JEV in PRD and addendum; addendum enum `.remote` replaces `.jeff`.
- §9 lists the memlog assumptions as "Memlog assumption #n"; the numbering refers to an internal log, not to a document the reader can open. Consider renaming to "Assumption A-n".
- The deletion of `epics.md` and `stage-7-stories.md` leaves no reference in the PRD; nothing to fix.
