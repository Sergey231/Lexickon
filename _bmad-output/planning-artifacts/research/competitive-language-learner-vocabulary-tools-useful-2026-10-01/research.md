---
title: 'competitive research: Language-learner vocabulary tools: do they assess word usefulness before saving'
type: 'competitive'
topic: 'Language-learner vocabulary tools: do they assess word usefulness before saving'
decision: 'Whether Lexickon differs enough from existing tools to justify the beta, and what to borrow'
source: 'native'
status: complete
preset: 'standard'
validation: 'normal'
created: '2026-10-01'
updated: '2026-10-01'
---

# competitive research: Language-learner vocabulary tools: do they assess word usefulness before saving

**Decision this research serves:** Whether Lexickon differs enough from existing tools to justify the beta, and what to borrow

_Sections are appended per the approved research plan; the executive summary is written last and placed here, first._

## Краткое резюме

**Вывод.** Ниша «оценка полезности слова по домену до сохранения» в проверенном круге инструментов свободна. Ни один из ~25 просмотренных продуктов не показывает уровень полезности слова для профессионального домена с уверенностью до добавления карточки. Это отрицательный результат по ~35 поискам, а не доказательство отсутствия (confidence: medium). Тезис брифа выдерживает проверку по конкурентам, но голос пользователей не подтверждён: данных об этом прочитать не удалось.

Три находки, определяющие вывод:
1. **Ближайшие аналоги дают общую, а не доменную подсказку.** Language Reactor показывает частотный ранг слова, LingQ и Migaku — процент и статус неизвестных слов, VocabMint и пара расширений — CEFR-уровень [6][7][8][11][12]. Все они общеязыковые.
2. **Доменная лексика продаётся готовыми колодами.** Тематические ESP-приложения (IT, медицина) и Lingvist for Business дают фиксированные наборы без оценки отдельного слова [2][13][15]. Доменная статистика есть у Sketch Engine и Lextutor, но на уровне текста и корпуса, для преподавателей, без связи с карточками [9][10].
3. **Ближайшее заявление «важно для предмета» — маркетинг.** OpenEduCat отбирает термины по «subject relevance» из вставленного текста, но не показывает уровень и уверенность и нацелен на школьные предметы [14].

**Главная оговорка.** Конкуренты закрывают пробел лишь частично, и это закрывается дёшево: LLM-расширение или обновление Language Reactor способны добавить подобный сигнал. Отсутствие аналога сегодня не гарантирует защиту завтра. Доказательства голоса пользователей их конкурентов в этом прогоне практически не получены (Reddit, Trustpilot, App Store заблокированы для поиска).

## 1. Возможности и тирдаун

| Инструмент | Пре-добавочный сигнал полезности | Домен | Фразы | iOS | Источники |
|---|---|---|---|---|---|
| Anki | нет встроенного; частотные add-ons только для японского, работают после добавления | колоды сообщества (не подтверждено) | любой формат | да (AnkiMobile) | [17] |
| Clozemaster | порядок «Most Common Words», это порядок подачи, а не оценка | не найдено | предложения | да | [16] |
| Memrise | не найдено | пользовательские списки слов (2026) | — | да | [5] |
| Vocabulary.com | не найдено | — | — | да | — |
| Duolingo | не найдено, курс ведёт сам | — | — | да | — |
| Readlang | не найдено | не найдено | до 12 слов | да | [1] |
| LingQ | % новых слов в уроке, статусы слов | не найдено | — | да | [3][7] |
| Migaku | пять статусов слов, понимание страницы в % | не найдено | предложения | да | [8] |
| Language Reactor | частотный ранг слова (общий язык), фильтр видео по уровню | не найдено | только строки субтитров | нет (Chrome) | [6][20] |
| Lingvist | не найдено | только B2B, кастомные курсы | — | да | [2] |
| VocabMint, Oxford-расширения | CEFR-метка | нет | — | расширения, синхронизация | [11][12] |
| ESP-приложения (IT, медицина) | нет, фиксированная колода | да | — | да | [13][15] |
| Sketch Engine, Lextutor | ключевые слова корпуса / полосы AWL | да (корпус пользователя) | да (термины) | веб | [9][10] |

Confidence: **medium** для общей картины; **low** там, где источник — сниппет поиска (Anki, Clozemaster, ESP-приложения). Многое подтверждено только отсутствием в найденном: страницы Migaku, LingQ и Language Reactor частично не читались.

Что не подтвердилось: утверждение «Memrise убрал сообщество в 2026» опровергнуто. Курсы сообщества убрали из основного приложения 2024-03-31, в 2026 вернули как списки слов (~800 курсов) [5]; confidence high, первоисточник.

## 2. Цены и пакеты

- **Подтверждено по App Store (US):** LingQ Premium $14.99/мес, $119.99/год; Premium Plus $29.99/мес, $269.99/год [3]. Memrise $24.99/мес, $61.99/год, пожизненно $329.99 [4] (medium: странная дублирующая запись).
- **Подтверждено официально:** Readlang $0 / $6 / $15 в месяц, без нового тарифа ниже [1]; Lingvist — тарифы Annual/Monthly/Business, суммы на официальной странице не показаны [2].
- **Только вторичные источники (low):** Migaku ~$96/год, Language Reactor Pro ~$5/мес, Duolingo Super $6.99, Max $29.99, Clozemaster $12.99/мес, год $69.99 (веб) против $79.99 (iOS) — конфликт, не усреднён [21]. Цена Vocabulary.com не найдена.
- **Вывод:** диапазон платных подписок $5–15/мес для инструментов чтения и карточек. Lexickon задуман бесплатным, поэтому цены конкурентов нужны как контекст, а не как якорь.

## 3. Позиционирование и разрыв «заявлено/реально»

- Readlang — самостоятельное чтение с контекстом [1]; LingQ — погружение, порог 10–15% неизвестных слов (рекомендация вендора) [3][7]; Migaku — медиа-майнинг [8]; Clozemaster — средний уровень, реальные предложения [16]; Lingvist — повседневная лексика, B2B для отраслей [2].
- **Разрыв у ESP-приложений:** заявляют «важные термины» (напр. «high-frequency clinical terms»), но это курация автора колоды, оценки на слово нет [15]. Tech English for Developers захватывает слова при чтении кода («Word Seeds»), но без оценки полезности; последнее обновление 2024-08, цена €1.99 за отключение рекламы [13].
- **Смысловая близость:** OpenEduCat — единственный с формулировкой «relevance to subject»; это маркетинг и школьные предметы, не профессиональные домены [14].

## 4. Голос пользователей конкурентов (тонкий)

Читаемых пользовательских источников за последние 12 месяцев получено **ноль**. Reddit и Trustpilot недоступны для поиска, страницы App Store не читались напрямую [19]. Что есть, и всё с low confidence:
- перегрузка новыми карточками в Anki (1 голос, 2023-12) [18];
- выгорание от очереди и нехватка новых слов после ~3000 слов в Lingvist, через агрегатор [19];
- Clozemaster воспринимается как базис, дополняют своими словами (1–2 голоса, вероятно старше года) [22].

**Не найдено:** запроса на оценку полезности слова до добавления; запроса на доменную лексику (кроме слабого замечания о бизнес-уклоне Lingvist). Отсутствие отражает ограничения доступа, а не отсутствие спроса. Эту часть должен закрыть отдельный прогон user-voice с браузером для Reddit.

## Межизмерные выводы

- **Сигналы есть, но разделены.** Частота и CEFR (общий язык) живут в словарях и расширениях; домен — в готовых колодах и корпусных инструментах; карточки — в SRS-приложениях. Никто не соединяет все три в одном шаге «сомнение → оценка → решение». Это и есть заявленное отличие Lexickon.
- **Риск пустой ниши.** Свободная ниша может означать как невостребованность, так и то, что задачу решают вручную (список AWL, ChatGPT-запрос). Конкуренты-заменители стоят за пределами категории приложений, а голос пользователей, который мог бы это уточнить, получить не удалось.

## Рекомендации

1. **Сохранить тезис брифа о пре-добавочной оценке по доменам** (бриф, раздел «Ценность и отличие»). Основание: ни один проверенный продукт не показывает доменный уровень с уверенностью до сохранения; confidence medium (отрицательный результат).
2. **Сформулировать отличие как «соединение трёх шагов», а не как «первую оценку полезности».** Общая частота и CEFR уже есть у Language Reactor, LingQ и расширений [6][7][11]; заявлять приоритет в частотности нельзя (PRD, раздел о дифференциации).
3. **Рассмотреть заимствования:** статусы слов и процент новых слов в тексте (LingQ, Migaku) [7][8]; захват слова при чтении (Tech English for Developers) [13]; фразы до 12 слов (Readlang) [1]. Основание: medium.
4. **Проверить пилотом KR-12, что оценка модели отличается от бесплатной альтернативы** («спросить ChatGPT про слово»). Это ближайший заменитель вне категории приложений, которого здесь не исследовали.
5. **Закрыть пробел голоса пользователей** отдельным прогоном user-voice (запущу следом) с чтением Reddit через браузер.

## Открытые вопросы

- Достаточно ли острая проблема у пользователей, чтобы оценка меняла решение? Нужен голос пользователей (следующий прогон, браузерный доступ).
- Не появился ли за последние месяцы LLM-инструмент «worth learning» (одна слабая попытка поиска)? Нужен повтор поиска и обзор расширений.
- Lingvist for Business, Toucan, Beelinguapp, Reverso, Youglish, AntConc, OpenWords (iOS) не проверены.
- Официальные цены Migaku, Language Reactor, Duolingo, Clozemaster, Vocabulary.com — через App Store и Wayback.
- Официальная справка Language Reactor о частотных функциях (сейчас только форум).

## Приложение источников

| # | Что подтверждает | Издатель | Дата | Доступ | Уверенность |
|---|---|---|---|---|---|
| [1] | Возможности, цены, фразы Readlang | [Readlang](https://readlang.com) | н/д | 2026-10-01 | high |
| [2] | Тарифы Lingvist, B2B-курсы | [Lingvist](https://lingvist.com/pricing/) | н/д | 2026-10-01 | high |
| [3] | Цены LingQ (iOS) | [Apple App Store](https://apps.apple.com/us/app/lingq-fast-language-learning/id379385811) | live | 2026-10-01 | high |
| [4] | Цены Memrise (iOS) | [Apple App Store](https://apps.apple.com/us/app/memrise-language-learning/id635966718) | live | 2026-10-01 | medium |
| [5] | Курсы сообщества Memrise | [Memrise](https://explore.memrise.com/community-courses) | 2024/2026 | 2026-10-01 | high |
| [6] | Частотный ранг и уровни Language Reactor | [LR форум](https://forum.languagelearningwithnetflix.com/t/how-do-you-know-the-frequency-number-of-a-word/11990) | 2021–2023 | 2026-10-01 | medium |
| [7] | % новых слов, статусы LingQ | [LingQ поддержка](https://lingq-support.groovehq.com/help/how-do-you-know-which-words-are-new-to-me) | н/д | 2026-10-01 | medium |
| [8] | Статусы слов Migaku | [Migaku](https://migaku.com/starter-guide) | н/д | 2026-10-01 | medium |
| [9] | Lextutor VocabProfilers | [Lextutor](https://lextutor.ca/vp) | н/д | 2026-10-01 | medium |
| [10] | Keywords/terms в Sketch Engine | [Sketch Engine](https://www.sketchengine.eu/user-guide/terminologists-terminology-extraction/) | н/д | 2026-10-01 | medium |
| [11] | VocabMint: CEFR при клике | [Mozilla Add-ons](https://addons.mozilla.org/de/firefox/addon/vocabmint/) | 2026-08-10 | 2026-10-01 | medium |
| [12] | Oxford-расширение с CEFR | [Chrome Web Store](https://chromewebstore.google.com/detail/fdkakkbaelbhkgkpjkoanipgpfcagdke) | 2026-04-24 | 2026-10-01 | medium |
| [13] | Tech English for Developers | [Apple App Store](https://apps.apple.com/rs/app/tech-english-for-developers/id6742486115) | 2024-08-03 | 2026-10-01 | high |
| [14] | OpenEduCat «subject relevance» | [OpenEduCat](https://openeducat.org/de/ai/tools/vocabulary-flashcards/) | н/д | 2026-10-01 | low-medium |
| [15] | ESP-приложения (медицина, IT) | [Product Hunt](https://www.producthunt.com/products/medical-english-vocabulary-app) / App Store | ~2025–26 | 2026-10-01 | low-medium |
| [16] | Clozemaster Pro | [Clozemaster](https://www.clozemaster.com/pro) | н/д | 2026-10-01 | medium |
| [17] | Частотные add-ons Anki (японский) | [WaniKani community](https://community.wanikani.com/t/anki-word-frequency-inserter-learn-most-common-words-first/53407) | 2021-09-07 | 2026-10-01 | medium |
| [18] | Перегрузка карточек Anki | [Anki forums](https://forums.ankiweb.net/t/too-many-learning-cards-at-once/38017) | 2023-12-04 | 2026-10-01 | medium |
| [19] | Отзывы Lingvist | [justuseapp](https://justuseapp.com/en/app/969093402/lingvist-learn-languages/reviews) | н/д | 2026-10-01 | low |
| [20] | Фразы Language Reactor | [Mezzoguild](https://www.mezzoguild.com/language-reactor-review/) | н/д | 2026-10-01 | medium |
| [21] | Цены Migaku, LR, Duolingo, Clozemaster | агрегаторы (aipicks, subger, langoly, storylearning) | 2026 | 2026-10-01 | low |
| [22] | Clozemaster как базис | [Clozemaster форум](https://forum.clozemaster.com/t/clozemaster-vocabulary-vs-harry-potter/10039) | ~2019–2020 | 2026-10-01 | low |

## Карта устаревания

Цены и функции — перепроверять через 3 месяца (до 2027-01-01); настроения пользователей — через 12 месяцев. Ближайшее: цены Migaku, LR, Duolingo, Clozemaster, Vocabulary.com (low, подтвердить по App Store) и официальная справка Language Reactor о частоте.
