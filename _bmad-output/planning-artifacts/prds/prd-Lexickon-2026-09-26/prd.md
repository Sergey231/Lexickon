---
title: Lexickon
created: 2026-09-26
updated: 2026-09-28
status: draft
---

# PRD: Lexickon
*Working title — confirm.*

## 0. Document Purpose
This PRD defines the product requirements for Lexickon, an iOS language learning app that pivots from pre-built SQLite dataset packs to on-demand frequency analysis via the JEV/System One neural network API. It is for the product manager, iOS engineers, backend engineers, and downstream workflow owners (UX, architecture, epic/story creation). The document is structured around two key user journeys (UJ-1, UJ-2) with features grouped by journey, functional requirements (FRs) nested under features with global numbering, and assumptions tagged inline `[ASSUMPTION: ...]` and indexed in §9. This PRD replaces the prior dataset-centric architecture (manifest, sync, download URLs, SQLite pack installation) with a lean JEV-API-centric model.

## 1. Vision
Lexickon helps language learners make confident vocabulary decisions in the moment of encounter. Instead of downloading and managing large offline dataset packs, users type any word or phrase and instantly see its real-world frequency rating from a state-of-the-art neural network (JEV/System One), along with a translation and AI-generated flashcards. Frequency lookups are proxied through a thin backend that provides a shared cache across all users, rate limiting, and IP key protection. The app then uses a custom spaced-repetition algorithm — where each card's difficulty is assessed by an LLM — to schedule reviews efficiently. No pack management, no sync, no schema migrations: just type, see, decide, learn.

## 1.1 Key Risks / Decisions Needed
*Status as of 2026-09-28. Open items block the FRs listed; owner is Sergei for all open items, target dates are set when the work moves to architecture.*

| # | Risk / Decision | Blocks | Status | Owner | Target Date |
|---|-----------------|--------|--------|-------|-------------|
| KR-1 | **Frequency source and JEV contract**: the request/response sketch used for FR-1 (`POST /frequency`, `frequency_per_million`) was not derived from JEV's real API and is **not** a basis for design (decision 2026-09-28). Research (2026-09-27) shows the published JEV API is System One (`/v1/systemone`: choice / ordinal score / probability over caller-defined levels). Decide what signal the app shows, where it comes from, and the real endpoint, auth, schema, rate limits, SLA, languages, and whether translation is available | FR-1, FR-2, FR-3, FR-9 | Open | Sergei | At architecture |
| KR-11 | **PRD and product brief disagree** (audience, dual assessment, LLM card builder, validation plan). Decision 2026-09-28: the PRD is the master document; the brief is to be updated to match and the reason for the changed thesis recorded there | Strategic coherence, SM-1…SM-5 | Open (brief update pending) | Sergei | Before UX / architecture |
| KR-2 | **SRS formula** | FR-6, FR-7 | **Decided:** SM-2 as the base, LLM difficulty score as an interval modifier, fallback difficulty 0.5, parameters via remote config. FSRS deferred. | — | — |
| KR-3 | **LLM provider and call path**: provider (cloud vs local), and whether the client or the backend calls the LLM. Cost, latency, privacy tradeoffs | FR-3, FR-7 | Open | Sergei | At architecture |
| KR-4 | **Translation provider**: separate API or JEV? Cost, latency, quality comparison | FR-2 | Open | Sergei | At architecture (depends on KR-1) |
| KR-5 | **iOS deployment target** | Entire app | **Decided:** iOS 18, for reach among users who have not updated to iOS 26. | — | — |
| KR-6 | **Sustainability** | Business viability | **Assumption for v1:** free app, bounded JEV budget, hard per-user lookup cap (value TBD per JEV terms). Financial model deferred. | — | Revisit before public launch |
| KR-7 | **Auth completeness**: password reset, session token refresh, biometric keychain storage, account deletion, logout behavior | Auth (existing) | Open | Sergei | At architecture (first audit what the backend already has) |
| KR-8 | **Backend frequency endpoint contract**: path, query params, response schema, cache headers, auth (user token vs anonymous) | FR-1 | Open | Sergei | At architecture |
| KR-9 | **Shared cache config** | FR-9 | **Decided:** TTL 7 days by default; size limit and eviction via remote config; invalidate on JEV version change. | — | — |
| KR-10 | **Cache encryption** | FR-8, FR-9 | **Decided for v1:** iOS Data Protection on the local cache; storage-level encryption at rest for the shared cache. SQLCipher deferred. | — | — |

## 2. Target User

### 2.1 Jobs To Be Done
- **Functional**: "When I encounter an unknown word while reading, I want to instantly know if it's worth learning so I don't waste time on rare words."
- **Emotional**: "I want to feel confident that every word I add to my deck is high-value, not a distraction."
- **Social**: "I want to share useful words with study partners without explaining why they matter."
- **Contextual**: "I need this to work on my iPhone while reading a physical book, on the subway, or at a café — occasionally offline."

### 2.2 Non-Users (v1)
- Users needing full offline corpus access without any connectivity (JEV API required for new lookups)
- Teams/organizations needing admin dashboards or shared decks
- Languages not supported by JEV/System One

### 2.3 Key User Journeys

**UJ-1. Maria checks frequency before adding a word to her deck.**
- **Persona + context:** Maria, 28, linguistics PhD student, reads English novels on her commute. She encounters ~5-10 unknown words per session and wants to filter for high-value ones.
- **Entry state:** Authenticated (biometric restore), on Home tab (Frequency Lookup), online or with cached lookups available.
- **Path:**
  1. Opens app → lands on Frequency Lookup screen (first tab).
  2. Types "transformer architecture" → taps Search.
  3. App calls backend frequency endpoint → backend calls JEV API (POST /frequency) with IP key auth, checks shared cache first → returns frequency metric, confidence, metadata.
  4. Screen shows: frequency rating (a level such as "Common", plus a numeric figure if the chosen source provides one; see KR-1), Russian translation, "Generate Flashcards" button.
  5. Taps "Generate Flashcards" → LLM produces 1-3 cards (word + translation + example sentence + audio hint).
  6. Confirms → cards saved to local deck, SRS schedules first review.
- **Climax:** Maria sees the frequency rating instantly and knows "transformer architecture" is domain-specific (low general frequency) — she decides to add it anyway for her specialty, or skips a rare idiom.
- **Resolution:** On Home tab with new cards in deck; "Due for review" badge updates.
- **Edge case:** Offline with no cache → shows "Offline: showing cached results only" banner; allows manual card creation without frequency data.

**UJ-2. Maria reviews due flashcards with adaptive SRS.**
- **Persona + context:** Same Maria, 15 minutes before bed, 10 cards due.
- **Entry state:** Authenticated, on Study tab, 10 cards due (mix of new and review).
- **Path:**
  1. Taps "Start Session" → sees progress "Card 1 of 10".
  2. Card front: "transformer architecture" + audio play button.
  3. Taps to reveal back: translation, example sentence, frequency badge.
  4. Rates recall: "Don't know at all" / "Know poorly" / "Know well" / "Know very well".
  5. App updates local DB immediately and computes the next interval with SM-2 using the card's cached difficulty score (assessed once by the LLM on the card's first review, off the critical path; see FR-7).
  6. Repeats for remaining 9 cards.
  7. Session summary: "10 reviewed, 3 new, 7 reviewed, next review in 2 days".
- **Climax:** Each rating instantly updates the schedule; Maria feels the algorithm adapts to *her* memory, not a fixed curve.
- **Resolution:** Back on Study tab, "Due" count = 0, next session time shown.
- **Edge case:** App backgrounded mid-session → on return, resumes at current card with progress preserved; DB already updated for completed cards.

## 3. Glossary
- **Frequency Lookup** — User-initiated query to backend frequency endpoint for a word/phrase frequency metric.
- **Backend Frequency Endpoint** — HTTP endpoint (GET /api/v1/frequency?q=...) that proxies requests to JEV API, provides shared cache, rate limiting, and auth.
- **JEV API** — Upstream HTTP API of the JEV/System One decision model, authenticated via IP key; called only by the backend. Its real contract is open (KR-1); the earlier `POST /frequency` sketch is not JEV's contract.
- **Frequency Metric** — The frequency signal shown to the user for a word or phrase (a level and, if the chosen source provides it, a numeric value such as occurrences per million) with a confidence indication. Its source and exact form are open (KR-1); the fields named in FR-1 are provisional.
- **Flashcard** — Local learning unit: front (target term), back (translation, example sentence, frequency badge, optional audio), SRS metadata.
- **Deck** — User's personal collection of flashcards, stored locally.
- **SRS (Spaced Repetition System)** — Custom algorithm scheduling card reviews based on 4-grade recall ratings and LLM-assessed difficulty.
- **Recall Rating** — One of four grades: `Unknown`, `Poor`, `Good`, `Excellent`.
- **Card Difficulty** — LLM-derived scalar (0.0-1.0) representing intrinsic memorability of a specific card for this user.
- **Interval** — Days until next review, computed per card from rating history and difficulty.
- **Local Cached Lookup** — Recent backend response stored locally for offline access (TTL: 30 days, max 500 entries).
- **Shared Cache** — Backend-managed cache of JEV responses across all users (TTL: configurable, size: configurable).
- **IP Key** — Static credential identifying the Lexickon backend to JEV API; stored server-side only, never in client.

## 4. Features

### 4.1 Frequency Lookup & Flashcard Generation
**Description:** Core entry point. User types a word/phrase → app calls backend frequency endpoint → backend checks shared cache, calls JEV API if needed → returns frequency metric, translation, and "Generate Flashcards" action. Realizes UJ-1.

**Functional Requirements:**

#### FR-1: Frequency Lookup via Backend
The system must accept a user-entered text string, call the backend frequency endpoint (GET /api/v1/frequency?q=...), which checks shared cache and calls JEV API (POST /frequency) with IP key authentication if needed, and return the frequency metric, confidence, and metadata. Realizes UJ-1.

**Consequences (testable):**
- Request completes within 3s on 4G (p95); timeout at 10s with user-facing error.
- Empty/whitespace input shows inline validation error, no API call.
- Response includes (**provisional, pending KR-1**): a frequency value or level (`frequency_per_million` (float) if the chosen source supports it), `confidence` (0.0-1.0), `language_detected` (ISO 639-1), `tokenization` (how the input was split), `cache_hit` (boolean), `cache_source` (shared|local|none).
- Non-2xx responses map to user-facing states: 429 → "Rate limited, try again", 5xx → "Service unavailable", network error → "Check connection".
- The backend enforces a hard per-user lookup cap; when exceeded it returns 429 and the app shows a message that the limit is reached (cap value TBD per JEV terms, see KR-6).

**Out of Scope:**
- Batch/multi-word lookup in single request (v2).
- Historical lookup trends/analytics (v2).

#### FR-2: Translation Display
The system must display a Russian translation of the queried term using an integrated translation service (or JEV if it provides it). Realizes UJ-1.

**Consequences (testable):**
- Translation appears within 500ms of frequency response (parallel or sequential).
- Missing translation shows "Translation unavailable" not blank.

#### FR-3: Flashcard Generation
The system must generate 1-3 flashcards per lookup using an LLM: each card includes target term, translation, 1-2 example sentences (CEFR-appropriate), and optional TTS audio hint. Realizes UJ-1.

**Consequences (testable):**
- Generation completes within 5s; shows skeleton loader.
- User can regenerate (max 3 attempts) before saving.
- Saved cards persist to local DB with `created_at`, `source_query`, `frequency_metric`.

**Feature-specific NFRs:**
- JEV API IP key never logged, never in crash reports, stored in build-time config only.
- User query text not logged (per logging policy).

**Notes:**
- `[ASSUMPTION: The chosen frequency source yields one primary value or level; if it yields several (count, percentile, etc.), UI shows primary + "Details" expando.]`
- `[ASSUMPTION: Translation service is separate from JEV; if JEV returns translation, use that.]`
- `[NOTE FOR PM: Confirm JEV API contract — endpoint, auth header name, response schema, rate limits, SLA. Confirm backend frequency endpoint contract — path, query params, response schema, cache headers.]`

### 4.2 Spaced Repetition Study Session
**Description:** Due cards presented in a session; 4-grade recall rating; immediate DB update; LLM-assessed difficulty per card drives interval scheduling. Realizes UJ-2.

**Functional Requirements:**

#### FR-4: Due Card Selection
The system must select cards due for review (interval elapsed) plus new cards (never reviewed), ordered by urgency (most overdue first). Realizes UJ-2.

**Consequences (testable):**
- New cards (interval = 0) appear before overdue reviews.
- Max session size: 20 cards (configurable).
- Cards with `lapsed_count > 3` flagged as "Leeches" and deprioritized.

#### FR-5: 4-Grade Recall Rating
The system must present four rating buttons per card: `Unknown`, `Poor`, `Good`, `Excellent`. Realizes UJ-2.

**Consequences (testable):**
- Buttons labeled in Russian: "Не знаю", "Плохо", "Хорошо", "Отлично".
- Rating required before next card; no skip.
- Accessibility: VoiceOver announces current card number, term, rating options.

#### FR-6: Immediate Schedule Update
The system must persist the rating, update the card's interval, ease factor, and next review date in local DB before showing the next card. Realizes UJ-2.

**Consequences (testable):**
- DB write completes within 100ms; UI does not block (async write, optimistic UI).
- App background/foreground mid-session: completed cards stay rated, current card resumes.

#### FR-7: LLM-Based Difficulty Assessment
The system must send card content + rating history to an LLM to compute a difficulty score (0.0-1.0) that modulates the interval formula. Realizes UJ-2.

**Consequences (testable):**
- Difficulty assessed once per card on first review; cached thereafter unless card content changes.
- Fallback: static difficulty = 0.5 if LLM unavailable.
- LLM prompt includes: target term, translation, example sentences, user's native language, previous ratings.

**Feature-specific NFRs:**
- LLM difficulty call: max 2s, cached locally, not on critical path (async after rating).
- SRS algorithm parameters (base intervals, ease factors) configurable via remote config.

**Notes:**
- SRS base is SM-2 (decided, KR-2). The LLM difficulty score modulates the SM-2 interval: interval = base_interval * ease_factor ^ (repetitions - 1) * (1 + difficulty_modifier). Exact base intervals, ease-factor bounds and modifier curve are parameters delivered via remote config; the strawman values are in the addendum (§B).
- `[ASSUMPTION: LLM for difficulty is the same provider as flashcard generation. Provider and call path are open, see KR-3.]`

### 4.3 Caching
**Description:** Two-layer caching: backend shared cache for all users (primary), local device cache for offline access (fallback). Realizes UJ-1.

**Functional Requirements:**

#### FR-8: Local Lookup Cache (Offline)
The system must cache successful backend frequency responses (query text → response) locally with 30-day TTL, max 500 entries, LRU eviction. Realizes UJ-1 edge case (offline).

**Consequences (testable):**
- Cache hit: shows frequency instantly, badge "Cached (local)".
- Cache miss offline: shows "Offline — frequency unavailable", allows manual card creation.
- Cache cleared on app uninstall; not synced across devices (v1).
- Cache file is stored with iOS Data Protection enabled (protection class chosen in architecture); no additional database encryption in v1 (SQLCipher deferred, KR-10).

#### FR-9: Backend Shared Cache
The backend must cache JEV API responses in a shared cache accessible to all users, with configurable TTL (default 7 days) and size limit. Realizes UJ-1 (improved hit rate, cost reduction).

**Consequences (testable):**
- Backend returns `cache_hit: true` + `cache_source: shared` on shared cache hit.
- Shared cache populated on first request for a term; subsequent users get instant response.
- Cache invalidation: TTL expiry, manual purge endpoint, automatic on JEV API version change.
- Metrics: shared cache hit rate, size, eviction count exported for monitoring.
- Cached data is encrypted at rest by the storage layer (KR-10).

#### FR-10: Offline Card Creation
The system must allow manual flashcard creation when offline (user enters term, translation, example manually). Realizes UJ-1.

**Consequences (testable):**
- Offline-created cards marked `source: manual`, `frequency_metric: null`.
- On next online, background sync optionally enriches with backend frequency lookup.

## 5. Non-Goals (Explicit)
- **No dataset packs**: No manifest, sync, download URLs, SQLite pack installation, schema versioning.
- **No multi-device deck sync**: Deck is local-only in v1 (iCloud sync v2).
- **No social/sharing features**: No deck export, share links, community decks.
- **No pronunciation scoring**: Audio is TTS hint only, not speech recognition.
- **No web/Android clients**: iOS only for MVP.
- **No subscription/payments**: Free app, JEV API cost absorbed by team.

## 6. MVP Scope

### 6.1 In Scope
- Platform: iOS 18 and later (KR-5)
- Frequency Lookup screen (Home tab) with backend-proxied JEV integration
- Translation display (integrated service)
- Flashcard generation (LLM) + save to local deck
- Study tab with due card selection, 4-grade rating, session flow
- Custom SRS with LLM difficulty assessment
- Local-only deck storage (SQLite/SwiftData)
- Offline cache for recent lookups (30 days, 500 entries)
- Manual offline card creation
- Auth: email/password + biometric restore (existing)
- Settings: preferred language, dark mode, notifications for due cards

### 6.2 Out of Scope for MVP
- Multi-device sync (iCloud/CloudKit) — `[NOTE FOR PM: high user demand, defer to v1.1]`
- Batch lookup / phrasebook import — `[NON-GOAL for MVP]`
- Advanced stats/analytics (heatmaps, retention curves) — `[NON-GOAL for MVP]`
- Text-to-speech for example sentences (TTS hint only) — `[NON-GOAL for MVP]`
- Custom deck organization (tags, folders) — `[NON-GOAL for MVP]`
- Android / Web clients — `[NON-GOAL for MVP]`
- Subscription / freemium — `[NON-GOAL for MVP]`

## 7. Success Metrics

**Primary**
- **SM-1**: Week-1 retention ≥ 40% — users who complete ≥3 study sessions in first 7 days. Validates FR-1, FR-4, FR-5, FR-6.
- **SM-2**: Lookup-to-save rate ≥ 25% — of frequency lookups, % that result in ≥1 flashcard saved. Validates FR-1, FR-3.

**Secondary**
- **SM-3**: Median session length ≥ 8 cards — users don't quit early. Validates FR-4, FR-5.
- **SM-4**: Local cache hit rate ≥ 15% — of lookups, % served from local cache. Validates FR-8.
- **SM-5**: Shared cache hit rate ≥ 60% — of backend lookups, % served from shared cache. Validates FR-9.

**Counter-metrics (do not optimize)**
- **SM-C1**: JEV API error rate — do not optimize by reducing lookups; keep < 2%. Counterbalances SM-1.
- **SM-C2**: Flashcard generation latency — do not optimize by reducing card quality; keep p95 < 5s. Counterbalances SM-2.

## 8. Open Questions
*Critical blockers are tracked in §1.1 Key Risks. These are remaining design details.*

1. **Frequency metric**: Does JEV return `frequency_per_million` only, or also `raw_count`, `percentile`, `dispersion`? UI design depends on this.
2. **Rate limiting**: JEV API limits per IP key? Backend per-user quota? Client-side throttle needed?
3. **Telemetry**: What anonymous usage events to send (lookup count, session length, error rates, cache source) without PII? Opt-out mechanism?
4. **LLM difficulty prompt**: Exact prompt template for difficulty assessment — include which card history fields?
5. **Flashcard regeneration**: Max 3 attempts — what constitutes "different enough" to allow another retry?
6. **Leech threshold**: `lapsed_count > 3` hardcoded or configurable per user?

## 9. Assumptions Index
- Inline assumption from §4.1 FR-1 — The chosen frequency source yields one primary value or level; if it yields several (count, percentile, etc.), UI shows primary + "Details" expando.
- Inline assumption from §4.1 FR-3 — Translation service is separate from JEV; if JEV returns translation, use that.
- Inline assumption from §4.2 FR-7 — LLM for difficulty is the same provider as flashcard generation; provider and call path open (KR-3).
- Memlog assumption #5 (superseded 2026-09-28) — The earlier assumption that JEV returns a per-million metric is withdrawn; the frequency source and its schema are open (KR-1).
- Memlog assumption #6 (revised 2026-09-28) — No existing users, clean slate migration; deployment target iOS 18 (KR-5), Swift 6, SwiftUI, Swift Concurrency preserved.
- Memlog assumption #7 — Flashcard generation uses LLM (translation + example sentences); SRS is SM-2 based with LLM-determined difficulty per card as a modifier (KR-2); 4-grade scale maps to interval scheduling.
- KR-6 (2026-09-28) — v1 is a free app with a bounded JEV budget and a hard per-user lookup cap; the financial model is deferred to before public launch.

*Resolved and no longer assumptions: shared cache TTL and eviction (KR-9), cache encryption for v1 (KR-10), SRS base algorithm (KR-2), iOS target (KR-5). See §1.1.*