# Digest voice-r1-3: how learners choose words to save; frustrations

Method: iTunes RSS customerreviews (US storefront, most-recent pages 1-3, i.e. latest ~100-150 reviews per app) for Anki, LingQ, Memrise, Clozemaster, Lingvist; filtered rating 1-3 + keywords. Readlang, Quizlet, WordUp not fetched (no app id given; budget). Google Play not attempted. All app reviews are US App Store, mostly NOT English-learner-specific (target languages Spanish/Japanese/Chinese etc.). Counts below are distinct review texts (one review = one reviewer; usernames not recorded).

## Findings

1. claim: Of ~600 recent reviews scanned (Anki 100, LingQ 150, Memrise 100, Clozemaster 150, Lingvist 100), 71 were rated 1-3 and matched keywords; only ~7 of those speak to "which words/content are worth learning". The rest are about pricing, bugs, UI, AI quality. Acute felt pain for "which words to save" is NOT prominent in app-store text. | source: https://itunes.apple.com/us/rss/customerreviews/id=<APPID>/sortby=mostrecent/json (ids 373493387, 379385811, 635966718, 1149199075, 969093402) | publisher: Apple App Store reviews | pub_date: 2023-2026 | accessed=2026-10-01 | confidence: med (RSS shows only latest pages; keyword filter crude) | class: counting/negative-evidence

2. claim: Junk/irrelevant content in app-chosen word lists is complained about (app-curated, not user-saved). Within last 12 months: 3 distinct reviewers. Memrise, 3 stars, 2026-09-17: lesson "filled with words I would never use" (cussing). Memrise, 1 star, 2026-04-12: taught slang/brand phrase before basics ("Kellogg's corn"). Clozemaster, 3 stars, 2026-04-26: "non-sensical vocabulary words like 'Bob' and 'Mary' and 'Smith'". Clozemaster, 2 stars, 2025-12-10: TTS sentence about "Eyjafjallajökull", "how is this sentence relevant". (4 reviewers incl. Clozemaster 2025-12.) | source: RSS endpoints above | publisher: App Store | accessed=2026-10-01 | confidence: med | class: user-voice, relevance-of-content

3. claim: Older (>12 mo) relevance/frequency complaints: Lingvist 2-star 2023-06-22: claims "most frequently used" words but "mostly obscure corporate terms", suspects newspaper corpus; Lingvist 2-star 2023-09-04: words taught for one specific situation, not generic; Clozemaster 2-star 2025-07-29: "everyday Spanish" collection contains Spanglish, cannot edit collections on free plan. 3 distinct reviewers, all outside 12-month window. Direct evidence of distrust in an algorithmic "frequency" claim (n=1, Lingvist 2023). | source: RSS endpoints | publisher: App Store | confidence: low-med | class: user-voice, trust-in-labels

4. claim: Deck bloat/backlog in review apps: Anki 2-star 2026-01-04 "review hell" (seeing words 10-12 times, not retaining); Anki 1-star 2025-12-16: 2,000-word deck, "must review 1,999 words to get back to the word I am learning as new"; Lingvist 3-star 2023-04-02: app "worthless" after reaching 5000 words (list exhausted). 2 distinct reviewers in window, 1 outside. | source: RSS Anki/Lingvist | confidence: med | class: user-voice, deck-bloat

5. claim: Auto-added vocabulary the user did not want: LingQ 3-star 2026-07-21: "app shouldn't be trying to add pinyin words to my voc[abulary]" (truncated in feed). Also LingQ 2-star 2026-08-06: flashcards show same info on both sides, "worthless". 2 reviewers. | source: https://itunes.apple.com/us/rss/customerreviews/id=379385811/sortby=mostrecent/json | confidence: med | class: user-voice

6. claim: Trust in AI-generated explanations/translations is low among reviewers of LingQ (2026-08-19, 2026-03-26, 2026-09-27), Clozemaster (2026-08-11, 2025-01-08): "not reliable enough for me to invest in". 5 distinct reviewers; relevant to trusting algorithmic labels. | source: RSS | confidence: med | class: user-voice, trust

7. claim: Learner-blog/forum consensus: be selective; don't capture every unknown word. Anki forum thread (Jul 22, 2025) replies: "You don't have to learn everything. I would suggest suspending cards that are leech or are very rare." and "Drop the paranoia/FOMO." Another poster: add words while reading, stop if exhausted by reviews. Selection criteria named: useful, interesting, common. 3+ posters. Language not specified. | source: https://forums.ankiweb.net/t/how-to-you-create-a-card-to-learn-new-vocabulary-after-you-finish-reading-a-book/64370 | publisher: Anki forums | pub_date: 2025-07-22 | confidence: med | class: user-voice, selection-method

8. claim: Over-saving causes quitting: "Too many cards" is stated as primary reason people abandon Anki ("canonical Anki death spiral"); advice "start by ankifying what you absolutely have to know". Author opinion, not user research. | source: https://www.lesswrong.com/posts/7Q7DPSk4iGFJd8DRk/an-opinionated-guide-to-using-anki-correctly | publisher: LessWrong | pub_date: 2025-07-08 | confidence: med | class: expert-opinion

9. claim: Search-result snippets (not read in full) report people overwhelmed after adding every unknown word, and some suspending decks once immersion sufficed. Unverified at primary level. | source: web search results for "stopped using Anki vocabulary too many cards" (threads on wanikani community, chinese-forums, japaneselevelup) | confidence: low | class: secondary snippet

10. claim: LLM-generated Anki cards flooded a deck with "low yield" items not examined (exam context, not vocabulary). | source: https://forums.ankiweb.net/t/turns-out-llms-made-cards-flooded-my-anki-too-much-low-yield-cards-i-didnt-use-anki-much-for-my-final-exam/62266 | pub_date: 2025-06-06 | confidence: med | class: user-voice, adjacent

11. claim: Readlang (reading + auto-flashcard tool) blog: "learners on Readlang have been asking for an easy way to control which words get converted into flashcards" — vendor-reported demand for control over what is saved. | source: https://blog.readlang.com/2023/06/09/delete-on-untranslate.html | publisher: Readlang | pub_date: 2023-06-09 | confidence: med | class: vendor-reported demand

12. claim: A niche app "Tech English for Developers" exists, built on vocabulary from error messages, GitHub issues, docs (store description); shows supply for domain vocabulary but no user-demand evidence. | source: https://apps.apple.com/rs/app/tech-english-for-developers/id6742486115 | publisher: App Store listing (marketing) | confidence: low | class: marketing

## Leads worth chasing
- Readlang, Quizlet, WordUp, LingQ, Language Reactor reviews (Google Play / Chrome Web Store) and Reddit r/EnglishLearning, r/Anki threads on "what to mine" (not fetched).
- Readlang blog follow-ups on flashcard control; Migaku blog on Anki language guide.
- Full text of WaniKani/chinese-forums "too many flashcards" threads for selection criteria and quit reasons.
- English-specific: Reddit/HelloTalk; Chrome Web Store reviews of Language Reactor / Lingua.

## Looked for and could not find
- English-learner-specific app-store reviews about choosing which words to save (none seen in the pages fetched).
- Personal Medium/dev.to/Substack posts on technical English vocabulary workflow (search returned vendor/academic pages only).
- Reviewer wishes explicitly asking for hints on "which words matter" (zero direct instances; nearest are #3 and #11).
- Google Play reviews (not attempted), YouTube comments (not attempted).
- Count of reviews total mentioning domain/profession vocabulary: 1 indirect (Lingvist 2023 "corporate terms").
