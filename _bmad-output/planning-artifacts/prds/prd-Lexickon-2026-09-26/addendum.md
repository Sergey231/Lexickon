# Lexickon PRD Addendum
*Supplemental depth for downstream workflows (architecture, UX, stories). Not required for PRD decision-readiness.*

*Reconciled 2026-09-28 with the PRD: the iOS client reaches JEV only through the Lexickon backend proxy (client never holds the IP key); deployment target is iOS 18; brand name is JEV.*

---

## A. JEV Upstream Contract Sketch (INVALIDATED 2026-09-28: not derived from JEV's real API; kept only as a record, do not design against it, see KR-1)

*The published JEV API is System One (`/v1/systemone`: choice / ordinal score / probability over caller-defined levels); see `research/technical-jev-vs-laya-for-english-word-frequency-2026-09-27/research.md`. The request and response below were an assumption and do not describe a real endpoint.*

### Request (backend → JEV)
```http
POST /v1/frequency
Authorization: Bearer <IP_KEY>   # server-side only
Content-Type: application/json

{
  "text": "transformer architecture",
  "language": "en",           // optional; auto-detect if omitted
  "context": "general"        // optional: "general" | "academic" | "technical" | "social"
}
```

### Response (success)
```json
{
  "frequency_per_million": 12.4,
  "confidence": 0.87,
  "language_detected": "en",
  "tokenization": ["transformer", "architecture"],
  "metadata": {
    "model_version": "jev-2026-09",
    "corpus": "common-crawl-2024",
    "request_id": "req_abc123"
  }
}
```

### Response (error)
```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded. Retry after 60s.",
    "retry_after_seconds": 60
  }
}
```

### Open Items for Architecture
- [ ] Confirm endpoint path, auth header name (`Authorization: Bearer` vs `X-IP-Key`)
- [ ] Rate limits: requests/minute, burst allowance
- [ ] Supported languages list
- [ ] Whether `context` parameter affects output
- [ ] SLA: latency p50/p95/p99, availability target
- [ ] IP key rotation procedure
- [ ] Whether JEV returns translation (if yes, can drop separate translation service)

---

## B. SRS Algorithm Detail (for Architecture/Stories)

*Decision (KR-2): SM-2 is the base algorithm; the LLM difficulty score modulates the interval; fallback difficulty 0.5; all parameters come from remote config. The values below are the strawman starting point for those parameters.*

### Current Formula (Strawman)
```
interval_days = base_interval * ease_factor^(repetition - 1) * difficulty_multiplier

where:
- base_interval = 1 (first review), 6 (second), then exponential
- ease_factor ∈ [1.3, 2.5] per card, updated per rating
- difficulty_multiplier = 1 + (difficulty_score - 0.5) * 0.5  // ∈ [0.75, 1.25]
- difficulty_score ∈ [0.0, 1.0] from LLM assessment
```

### Rating → Ease Factor Delta
| Rating | Ease Factor Delta |
|--------|-------------------|
| Unknown | -0.2 |
| Poor | -0.05 |
| Good | 0.0 |
| Excellent | +0.05 |

### LLM Difficulty Prompt (Draft)
```
You are assessing the intrinsic memorability of a flashcard for a Russian-speaking English learner.

Card:
- Target: "transformer architecture"
- Translation: "трансформерная архитектура"
- Example 1: "The transformer architecture revolutionized NLP."
- Example 2: "BERT uses a transformer architecture with bidirectional attention."
- User history: 2 reviews, ratings: Good, Excellent

Output JSON only:
{
  "difficulty_score": 0.35,
  "reasoning": "Technical term, but transparent morphology ('transformer' + 'architecture'). High cognate potential for Russian speaker. Examples provide clear context."
}
```

### Leech Handling
- `lapsed_count > 3` → card flagged as "Leeched"
- Leeched cards: interval reset to 1 day, ease_factor = 1.3, shown at session end
- User can "Suspend" leeched cards (move to suspended deck)

---

## C. Data Model (for Architecture/Stories)

### Flashcard (SwiftData / SQLite)
```swift
struct Flashcard {
  let id: UUID
  var front: String              // target term/phrase
  var backTranslation: String
  var exampleSentences: [String] // 1-2
  var frequencyPerMillion: Double?  // nil for manual cards
  var confidence: Double?        // from JEV
  var source: Source             // .lookup | .manual
  var createdAt: Date
  var srs: SRSMetadata
}

struct SRSMetadata {
  var intervalDays: Int          // 0 = new
  var easeFactor: Double         // 1.3 - 2.5
  var repetitions: Int           // successful reviews
  var lapses: Int                // times rated Unknown/Poor
  var nextReviewDate: Date
  var difficultyScore: Double?   // LLM-assessed, cached
  var lastRating: Rating?        // for streak tracking
  var difficultyAssessedAt: Date?
}
```

### Lookup Cache
```swift
struct CachedLookup {
  let queryText: String          // normalized (lowercased, trimmed)
  let response: FrequencyResponse   // backend response, see PRD FR-1
  let cachedAt: Date
  let expiresAt: Date            // cachedAt + 30 days
}
```

---

## D. API Contract Changes (Backend)

### Remove (from current `api_contract.md`)
- `GET /datasets`
- `GET /datasets/{dataset_key}`
- `GET /datasets/manifest`
- `POST /datasets/sync`
- `POST /datasets/versions/{version_id}/download-url`
- All Dataset/Version models and storage adapter

### Add
```http
GET /api/v1/frequency?q=<text>[&language=<ISO 639-1>]
Authorization: Bearer <user session token>   # user token vs anonymous: open, KR-8
```

The backend checks the shared cache (KR-9), calls JEV (Section A) with the server-side IP key on a miss, enforces the per-user lookup cap (KR-6), and returns the fields listed in PRD FR-1 (`frequency_per_million`, `confidence`, `language_detected`, `tokenization`, `cache_hit`, `cache_source`). Path, query parameters, cache headers and auth are finalized under KR-8.

### User Settings Changes
Remove: `selected_domains`, `offline_mode`, `sync_over_cellular`
Keep: `preferred_language` (for UI locale), add `study_reminder_time`, `max_cards_per_session`

---

## E. iOS Architecture Impact (for Architecture/Stories)

### Domain Layer Changes
**Remove:**
- `Dataset`, `DatasetManifest`, `DatasetKey`, `DatasetDomain`, `DatasetVersion`, `DatasetVersionID`, `DatasetCompression`, `AccessPlan`, `DatasetStatus`, `DatasetAvailability`, `DatasetCatalogState`, `InstalledDataset`
- `FrequencyQuery.datasetKey` → replace with `language: LanguageCode?`
- `FrequencyRepository.lookup(query:)` → `lookup(text: String, language: LanguageCode?)`
- `DatasetCatalogRepository`, `InstalledDatasetRepository`, `DatasetSyncPlanner`, `SynchronizeDatasetsUseCase`, `GetDatasetCatalogUseCase`, `GetDatasetDownloadURLUseCase`, `GetInstalledDatasetsUseCase`

**Add/Modify:**
- `FrequencyQuery` → `{ text: String, language: LanguageCode? }`
- `FrequencyResult` → add `source: LookupSource (.remote | .cache | .manual)`, `cached: Bool`
- `LookupFrequencyUseCase` → calls `FrequencyRepository` (talks to the Lexickon backend, never to JEV)
- `FrequencyRepository` protocol: `lookup(text: String, language: LanguageCode?) async throws -> FrequencyResult?`
- `CachedLookupRepository` protocol for offline cache
- `FlashcardRepository` for deck CRUD + SRS metadata
- `StudySessionUseCase` for due card selection, rating submission, schedule update

### Data Layer Changes
**Remove:**
- `Data/Repositories/Dataset/` entire folder
- `Data/DataSources/Remote/API/DTO/Dataset*.swift`
- `DatasetSyncDTOs.swift`, `DatasetManifestDTO.swift`, `DatasetDownloadURLDTO.swift`

**Add:**
- `Data/Repositories/Frequency/FrequencyRepositoryImpl.swift` (existing name may be reused)
- `Data/Repositories/Frequency/CachedLookupRepositoryImpl.swift`
- `Data/Repositories/Flashcard/FlashcardRepositoryImpl.swift`
- `Data/DataSources/Remote/API/` — typed client for the backend frequency endpoint (no JEV client on the device)
- `Data/DataSources/Local/Database/` — SwiftData models for Flashcard, CachedLookup, SRSMetadata

### Presentation Layer Changes
**Remove:**
- Dataset Setup flow (Stage 8)
- Dataset Catalog/Management screens
- Sync/Download progress UI

**Add/Modify:**
- Home tab → FrequencyLookup screen (replaces Dataset Setup as first-launch)
- Study tab → Session screen with 4-grade rating
- Settings → remove dataset sync options, add study preferences

---

## F. Rejected Alternatives (for Architecture Decision Log)

| Alternative | Reason for Rejection |
|-------------|---------------------|
| Keep SQLite packs + add JEV as fallback | Dual maintenance burden; packs become stale; sync complexity remains |
| Client calls JEV directly (earlier draft of this addendum) | IP key would ship inside the app and could be extracted; no shared cache across users; no central rate limiting or per-user cap. Replaced by the backend proxy (decision 2026-09-28) |
| Use Anki SM-2 algorithm unchanged | Doesn't leverage LLM difficulty; fixed parameters don't adapt to card content |
| CloudKit sync for deck (v1) | Scope creep; local-first simpler; sync conflicts with SRS scheduling need resolution |
| Single "Know/Don't Know" binary rating | Loses gradient signal for SRS; 4-grade is standard for adaptive algorithms |

---

## G. Research Notes (for UX/Architecture)

### Competitive Landscape
- **Anki**: SM-2/FSRS, no frequency lookup, manual card creation, steep learning curve
- **Pleco**: Dictionary + flashcards, frequency from built-in corpus, no neural frequency
- **LingQ**: Frequency from web corpus, LingQs (highlighted words), no SRS customization
- **Memrise/Quizlet**: Pre-made decks, basic SRS, no on-demand frequency

### Differentiation
- **JEV neural frequency** > static corpus frequency (handles neologisms, domain shifts)
- **LLM difficulty per card** > fixed ease factors
- **Lookup → instant card generation** > manual entry friction

---

## H. Open Questions for Downstream (tagged for UX/Architecture/Stories)

*Numbering aligned with PRD §1.1 (KR-n) on 2026-09-28. Resolved: KR-2 (SM-2 base; parameters via remote config), KR-5 (iOS 18), KR-9, KR-10.*

| ID | Question | Owner | Blocking? |
|----|----------|-------|-----------|
| KR-1 | JEV API exact contract (endpoint, auth, schema, rate limits) | Sergei | Yes |
| KR-4 | Translation provider selection & cost (check whether JEV returns translation) | Sergei | Yes |
| KR-3 | LLM provider and call path for flashcards/difficulty (cloud vs local; client vs backend) | Sergei | Yes |
| KR-8 | Backend frequency endpoint contract | Sergei | Yes |
| KR-7 | Auth completeness | Sergei | No |
| OQ-4 | SRS parameter values (base intervals, ease bounds, difficulty curve) for remote config | Sergei | No |
| OQ-6 | Telemetry events schema (anonymous, no PII) | PM/Arch | No |
| OQ-7 | iCloud sync design (v1.1) — conflict resolution for SRS state | Arch/UX | No (v2) |
| OQ-8 | Accessibility: VoiceOver labels for frequency badge, rating buttons | UX | No |