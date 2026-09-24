---
title: 'Market research: task trackers for BMAD'
type: 'market'
topic: 'task trackers for BMAD'
decision: 'Choose the task tracker that best supports a BMAD product-development workflow'
source: 'native web research'
status: complete
preset: 'standard'
validation: 'normal'
created: '2026-09-21'
updated: '2026-09-21'
verified_claims: 1
unverified_claims: 10
---

# Таск-трекеры для BMAD

**Решение:** выбрать трекер, который дополняет BMAD, не превращаясь во второй конкурирующий источник истины.

## Краткий вывод

**Для Lexickon и похожей разработки лучший старт — GitHub Projects.** BMAD хранит PRD, архитектуру, эпики, истории и состояние спринта в Markdown/YAML рядом с кодом. GitHub Issues и Projects добавляют представление для людей без отдельного контура интеграции: задачи, pull-реквесты, GitHub Actions, CLI и API находятся в одной системе [1][2][3][4][5].

**Linear — ближайший конкурент**, если продуктовая работа команды важнее минимизации инструментов. Его Initiative → Project → Issue → Sub-issue почти напрямую отображает программу → эпик → историю → задачу [8], а GitHub-интеграция связывает эту модель с разработкой [9]. Разрыв составляет всего 0,07 балла: 4,42 против 4,49 из 5. **YouTrack — самый выгодный вариант по соотношению цены и возможностей**, особенно если нужны рекурсивная иерархия и программируемые workflow [12], CommonMark [13], GitHub-интеграция [14] или self-hosting [15].

Источником истины остаются BMAD-файлы в Git; трекер хранит идентификатор, краткое описание, статус, связи и ссылку на файл. Решение следует проверить пилотом на одном эпике.

## Рекомендация по внедрению

Сначала определить, нужен ли внешний трекер: если репозиторного представления BMAD достаточно всем участникам, новая система не окупит синхронизацию. В противном случае запустить двухнедельный пилот GitHub Projects на одном эпике:

1. Источником истины остаются BMAD-файлы в Git, включая `sprint-status.yaml`.
2. Эпик, история и задача представлены типами issues GitHub либо согласованными метками и шаблонами; связи между ними — sub-issues.
3. Каждая история содержит ссылку на соответствующий `.md`-файл, а не его полную копию.
4. PR ссылается на историю; после слияния GitHub Actions или workflow проекта переводит историю в статус Review или Done.
5. Синхронизация сначала односторонняя: из Git/BMAD в Project. Обратную запись в YAML добавлять только после проверки конфликтов.
6. В конце пилота экспортировать данные проекта в TSV и проверить возможность восстановить иерархию через GraphQL.

Критерии успеха: не более одного ручного обновления статуса на историю; отсутствие конфликтов с `sprint-status.yaml`; понятность доски без чтения репозитория; активное использование участниками вне команды разработки; восстановление связей из экспорта/API.

**Условие перехода на Linear:** если участники со стороны продукта и UX избегают доски или регулярно нарушают принятую модель, выбрать Linear, сохранив BMAD-файлы в Git источником истины. Это условие важнее разницы 0,07 балла. Двустороннюю запись в `sprint-status.yaml` не включать до подтверждения пользы: она повышает риск конфликтов.

## Что именно нужно BMAD

Официальный поток BMAD идёт от анализа и PRD через UX/архитектуру к эпикам и историям, затем создаёт `sprint-status.yaml`, после чего реализация выполняется по одной истории [1]. Устойчивое ядро иерархии — **эпик → история**; отдельная сущность «задача» полезна, но не обязательна для метода [2].

Из этого следуют требования:

- источником истины остаются BMAD-файлы в Git;
- трекер должен отображать эпики, истории и при необходимости задачи;
- смена статусов должна автоматизироваться через API, CLI, вебхуки или GitHub Actions;
- pull request и коммиты должны связываться с историей без ручного дублирования;
- данные должны экспортироваться в открытом табличном формате или полностью извлекаться через API.

## Метод и итоговая матрица

В финал вошли GitHub Projects, Linear, YouTrack, ClickUp и Jira. Шкала — 1–5. Веса согласованы до исследования: BMAD-fit 30%, автоматизация 20%, простота 15%, Git-интеграция 15%, цена 10%, переносимость 10%.

| Кандидат | BMAD 30% | Автоматизация 20% | Простота 15% | Git 15% | Цена 10% | Переносимость 10% | Итог |
|---|---:|---:|---:|---:|---:|---:|---:|
| **GitHub Projects** | 4,2 | 5,0 | 3,5 | 5,0 | 5,0 | 4,5 | **4,49** |
| **Linear** | 4,8 | 4,4 | 4,5 | 4,5 | 3,2 | 4,3 | **4,42** |
| **YouTrack** | 4,5 | 4,25 | 4,0 | 4,0 | 4,75 | 4,5 | **4,33** |
| **ClickUp** | 4,3 | 4,5 | 2,8 | 4,6 | 4,0 | 4,1 | **4,11** |
| **Jira** | 3,75 | 4,5 | 2,75 | 4,5 | 3,25 | 3,0 | **3,74** |

Числа отражают пригодность под согласованный сценарий, а не абсолютное качество продуктов. Разница между GitHub Projects и Linear меньше возможной погрешности субъективной оценки простоты, поэтому выбор определяется режимом работы команды.

Все финалисты соответствуют базовым критериям, но Jira соответствует критерию иерархии лишь условно: по умолчанию Story и Task находятся на одном уровне под Epic [16]. Plane не вошёл в финал: строгая типизированная иерархия Epic → Story → Task доступна только в Enterprise Grid [23]; публичную цену этого тарифа и Markdown-переносимость work items в рассмотренных материалах подтвердить не удалось. OpenProject не показал преимуществ по Markdown и простоте.

## Почему GitHub Projects победил

GitHub Issues поддерживает многоуровневые sub-issues; Projects добавляет board/table/roadmap, пользовательские поля и встроенные автоматизации [3][4]. GraphQL, `gh api` и GitHub Actions позволяют программно изменять данные Projects [5]; отсюда следует, что синхронизацию со статусами PR и проверок можно настроить, но это нужно доказать пилотом. Представление проекта выгружается в TSV [6], а более полный экспорт можно построить через API [5]. Страница цен перечисляет Issues & Projects в Free; GitHub Team указан по $4 за пользователя в месяц [7].

Для BMAD это создаёт короткий путь:

`BMAD story file → GitHub Issue → Pull Request → Project status`

Не нужны отдельная синхронизация внешнего сервиса с GitHub, отдельная модель пользователей или третий набор идентификаторов. Главный недостаток — GitHub предоставляет гибкие примитивы, но не навязывает семантику BMAD. Команде придётся договориться о типах, шаблонах, статусах и правилах иерархии.

## Когда выбрать другой трекер

- **Linear** — если доской активно пользуются продакт-менеджеры, дизайнеры и другие участники, не работающие с кодом. Его продуктовая иерархия [8] и Markdown-экспорт [10] удобнее, но добавляют второй SaaS-контур. Бесплатный план ограничен 250 issues; Basic стоит $10, Business — $16 за пользователя в месяц при годовой оплате [11].
- **YouTrack** — если нужны рекурсивные parent/subtask связи и JavaScript-workflows [12], CommonMark [13] или путь Cloud → Server [15]. До 10 пользователей YouTrack бесплатен. Затем облачный тариф стоит от $5,40 за пользователя в месяц или от $4,50 за пользователя в месяц при годовой оплате [15]. GitHub/VCS-интеграция подтверждена отдельно [14].
- **ClickUp** — если одна система должна покрывать широкий набор бизнес-процессов. Он поддерживает вложенные subtasks [19], custom task types [24], Markdown API [20], GitHub [21] и структурированный CSV-экспорт [22], но проигрывает из-за объёма настроек и отсутствия доказанного контроля типов в иерархии.
- **Jira** — если она уже является корпоративным стандартом. Для нового BMAD-процесса стандартная иерархия менее удобна, REST API передаёт форматированный текст в Atlassian Document Format, а не в Markdown, а расширенные возможности зависят от тарифа [16][17][18].

## Источники

| № | Что подтверждает | Источник | Дата публикации/обновления | Доступ | Уверенность |
|---:|---|---|---|---|---|
| 1 | Фазы и артефакты BMAD, `sprint-status.yaml` | [BMAD Method — Workflow Map](https://docs.bmad-method.org/reference/workflow-map/) | не указана, актуальная документация | 2026-09-21 | высокая |
| 2 | Epic как набор stories, `stories.yaml` и story files | [BMAD Method — Finish an Epic](https://docs.bmad-method.org/build/finish-an-epic/) | не указана, актуальная документация | 2026-09-21 | высокая |
| 3 | GitHub Projects: views, fields, issues/PR | [GitHub — About Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects) | не указана, актуальная документация | 2026-09-21 | высокая |
| 4 | Многоуровневые sub-issues и CLI | [GitHub — Adding sub-issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues) | не указана, актуальная документация | 2026-09-21 | высокая |
| 5 | GraphQL/CLI-автоматизация Projects | [GitHub — Using the API to manage Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects) | не указана, актуальная документация | 2026-09-21 | высокая |
| 6 | Экспорт представления GitHub Project в TSV | [GitHub — Exporting your project data](https://docs.github.com/en/issues/planning-and-tracking-with-projects/managing-your-project/exporting-your-projects-data) | не указана, актуальная документация | 2026-09-21 | высокая |
| 7 | GitHub Free/Team/Enterprise pricing | [GitHub Pricing](https://github.com/pricing) | актуальная страница цен | 2026-09-21 | высокая |
| 8 | Модель Linear: initiatives/projects/issues/sub-issues | [Linear Docs](https://linear.app/docs) | не указана, актуальная документация | 2026-09-21 | высокая |
| 9 | PR/commit links и status automation Linear | [Linear — GitHub integration](https://linear.app/docs/github-integration) | не указана, актуальная документация | 2026-09-21 | высокая |
| 10 | CSV/API и Markdown export Linear | [Linear — Exporting Data](https://linear.app/docs/exporting-data) | не указана, актуальная документация | 2026-09-21 | высокая |
| 11 | Тарифы Linear | [Linear Pricing](https://linear.app/pricing) | актуальная страница цен | 2026-09-21 | высокая |
| 12 | Рекурсивные parent/subtask и JS-workflows YouTrack | [JetBrains — Subtasks](https://www.jetbrains.com/help/youtrack/cloud/workflow-subtasks.html) | YouTrack Cloud 2026.2 | 2026-09-21 | высокая |
| 13 | CommonMark в YouTrack | [JetBrains — Markdown Syntax](https://www.jetbrains.com/help/youtrack/cloud/youtrack-markdown-syntax-issues.html) | 2026-09-17 | 2026-09-21 | высокая |
| 14 | GitHub/VCS-интеграция YouTrack | [JetBrains — VCS Integration](https://www.jetbrains.com/help/youtrack/cloud/integration-with-version-control-systems.html) | 2026-09-17 | 2026-09-21 | высокая |
| 15 | Цена и Cloud → Server YouTrack | [JetBrains — Buy YouTrack](https://www.jetbrains.com/youtrack/buy/) | актуальная страница цен | 2026-09-21 | высокая |
| 16 | Стандартная и расширенная иерархия Jira | [Atlassian — Configure the work type hierarchy](https://support.atlassian.com/jira-cloud-administration/docs/configure-the-issue-type-hierarchy/) | не указана, актуальная документация | 2026-09-21 | высокая |
| 17 | REST v3 и ADF в Jira | [Atlassian — Jira Cloud REST API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/) | не указана, актуальная документация | 2026-09-21 | высокая |
| 18 | Тарифы и automation quotas Jira | [Atlassian — Jira Pricing](https://www.atlassian.com/software/jira/pricing) | актуальная страница цен | 2026-09-21 | высокая |
| 19 | Вложенные subtasks ClickUp | [ClickUp — Create nested subtasks](https://help.clickup.com/hc/en-us/articles/6304431740055-Create-nested-subtasks) | не указана, актуальная документация | 2026-09-21 | высокая |
| 20 | Markdown descriptions и API ClickUp | [ClickUp — Tasks API](https://developer.clickup.com/docs/tasks) | обновлена примерно в 2025 г. | 2026-09-21 | высокая |
| 21 | GitHub-интеграция ClickUp | [ClickUp — GitHub integration](https://help.clickup.com/hc/en-us/articles/6305771568791-GitHub-integration) | не указана, актуальная документация | 2026-09-21 | высокая |
| 22 | CSV/API/Markdown export ClickUp | [ClickUp — Workspace export options](https://help.clickup.com/hc/en-us/articles/6310786693015-How-do-I-export-my-Workspace-s-data) | не указана, актуальная документация | 2026-09-21 | высокая |
| 23 | Типизированная иерархия Plane и ограничение Enterprise Grid | [Plane — Workspace Work Item Types and Hierarchy](https://plane.so/blog/introducing-workspace-work-item-types-hierarchy) | 2026-06-09 | 2026-09-21 | высокая |
| 24 | Пользовательские типы задач ClickUp | [ClickUp — Custom task types](https://help.clickup.com/hc/en-us/articles/30661182619671-Custom-task-types-feature-availability-and-limits) | не указана, актуальная документация | 2026-09-21 | высокая |

## Карта устаревания

- **Уже требует перепроверки:** ограничение Plane Enterprise Grid основано на публикации от 2026-06-09; если Plane возвращается в шорт-лист, сначала обновить этот факт.
- **Перепроверить до 2026-12-01:** цены, тарифные ограничения, иерархии, экспорт и интеграции всех финалистов, а также актуальную модель артефактов BMAD.

Самая ранняя вычисленная дата перепроверки — **2026-09-01** из-за уже устаревшего факта о Plane. Для действующей рекомендации практический срок обновления — **2026-12-01**.
