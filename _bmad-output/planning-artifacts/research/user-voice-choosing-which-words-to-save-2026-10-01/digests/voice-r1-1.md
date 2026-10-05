# voice-r1-1 digest: how B1-B2 learners decide which words to save (HN-centric)

Coverage caveat: Reddit (old.reddit.com) and the Stack Exchange API were blocked by the fetch tool (not retried). Anki forum search returned an empty placeholder page. HN Algolia worked but is a developer/polyglot audience, mostly NOT B1-B2 English learners. Evidence is thin; none of it is from English-as-target learners.

## Findings
1. claim: Readlang's own design prioritises flashcards by word-frequency lists "so you learn the most useful words first" (a product-side answer to the which-words problem; stated by the maker, not a learner demand).
 source: https://news.ycombinator.com/item?id=9707190 (Show HN: Readlang) | publisher: HN | pub_date: 2015-06-13 | accessed=2026-10-01 | confidence: med | class: competitor-behaviour
2. claim: Readlang maker's stance: collecting too many words is low-harm; "the decision on which words to keep... shouldn't take up valuable brain cycles" i.e. save liberally, let the system sort it (opposite of curating up front). Same line recurs in a 2023 HN thread on effective SRS (35511440), so it circulates as received wisdom.
 source: https://news.ycombinator.com/item?id=9710393 and https://news.ycombinator.com/item?id=35511440 | publisher: HN | pub_date: 2015-06-13 / 2023-04-10 | accessed=2026-10-01 | confidence: med | class: user-heuristic (save-everything)
3. claim: Effective-SRS thread, 4 distinct voices (2023-04-10/11): (a) redundancy is harmless, "you'll just hit 'I remember'"; (b) keep material "+1 in difficulty", remove too-easy cards; (c) big review backlogs discourage; (d) prune cards that are no longer personally relevant ("I don't think that'll change" and remove it). Shows pruning/overload exist as concerns, but generic SRS, not vocabulary choice.
 source: https://news.ycombinator.com/item?id=35511440 | publisher: HN | pub_date: 2023-04-10 | accessed=2026-10-01 | confidence: med | class: overload/workaround (weak, not language specific)
4. claim: "Learning Languages with the Help of Algorithms" thread, 3 distinct voices (2025-09-21): one advises accounting for which words you already know rather than just removing stopwords, picking sentences per word from most to least common; author says sorting by frequency/rarity is automated but "choosing one sentence and turning it into an Anki flashcard is manual". Indicates demand for known-word-aware prioritisation among tinkerers; the final save decision stays human. No distrust of the algorithm expressed.
 source: https://news.ycombinator.com/item?id=45320854 | publisher: HN | pub_date: 2025-09-21 | accessed=2026-10-01 | confidence: med | class: priority-hint demand (weak) / DIY workaround
5. claim: Several HN voices say frequency-ordered core learning (first ~1000-3000 words) is where Anki shines (threads 44977258, 44023302, 40338154, 2024-2025); one says shared decks they found were poor or backwards (46869116, 2026-02-03). Frequency list = the default "which words" rule at A1-A2, not B1-B2. Only search snippets seen (not full threads); counts unverified.
 source: https://news.ycombinator.com/item?id=44977258 ; 44023302 ; 40338154 ; 46869116 | publisher: HN | pub_date: 2024-05 to 2026-02 | accessed=2026-10-01 | confidence: low | class: user-heuristic (frequency)
6. claim: One 2014 voice disliked running many decks at once and found per-book decks a "huge pain" (deck-organisation friction).
 source: https://news.ycombinator.com/item?id=8191010 | publisher: HN | pub_date: 2014-08-18 | accessed=2026-10-01 | confidence: low | class: overload (old, snippet only)
7. claim: One 2024 voice advises only creating flashcards when something comes up organically, keeping early sessions short.
 source: https://news.ycombinator.com/item?id=39166130 | publisher: HN | pub_date: 2024-01-28 | accessed=2026-10-01 | confidence: low | class: user-heuristic (organic encounter)

Distinct voices counted on-topic (HN, distinct comments): ~12 (3 + 4 + readlang maker + ~4 snippet voices), almost none B1-B2 English learners.

## By research question
(a) deciding: save-liberally-and-let-SRS-sort; frequency lists for core words; encounter-driven. (b) overload: backlog discouragement, pruning irrelevant cards (generic SRS). (c) profession vocabulary: nothing found; one 2020 HN comment notes specialised terms lack established vocabulary in other languages (not on-topic). (d) priority hint wanted: weak, 1-2 voices (known-word-aware frequency). (e) trust/distrust of AI word-difficulty scores: nothing found.

## Leads worth chasing
- ELL / Language Learning Stack Exchange and r/EnglishLearning, r/Anki, r/LearnEnglish via a route that is not blocked (browser tool, Pushshift-like archives).
- Readlang, LingQ, Language Reactor forums directly (LingQ "known words" and "too many yellow/blue words" complaints).
- Lemmy language-learning communities; Anki forum threads by direct URL.

## Looked for and could not find
- Any English-learner (B1-B2) voice on choosing words; any developer/medical/business vocabulary-saving thread; any explicit complaint "I don't know which words are worth saving"; any distrust/trust of AI difficulty scores. Blocked: old.reddit.com, api.stackexchange.com. Empty: forums.ankiweb.net search. HN queries "technical english vocabulary non-native developers", "anki ... junk cards", "readlang OR lingq ..." returned 0 hits.
