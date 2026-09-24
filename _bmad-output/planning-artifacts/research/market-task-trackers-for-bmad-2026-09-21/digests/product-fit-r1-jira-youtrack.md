# Product-fit digest R1: Jira Cloud vs YouTrack Cloud for BMAD

**As of / accessed:** 2026-09-21  
**Scope:** product model, workflow, Markdown/artifacts, GitHub, API/automation, export, price. Exactly eight first-party web sources are admitted below. Scores are decision support, not vendor benchmarks.

## Decision

**Provisional choice: YouTrack Cloud — 86.5/100 vs Jira Cloud — 74.8/100.** YouTrack is the better small-team BMAD fit because it combines recursively nested parent/subtask work, JavaScript workflow rules, direct CommonMark-style authoring, GitHub/PR linkage, and materially lower/all-features pricing. Jira is stronger in breadth and formalized enterprise planning, but its native hierarchy is *Epic → standard work item (Story or Task) → Subtask*, not literally *Epic → Story → Task*; custom hierarchy levels are Premium/Enterprise and the documented custom levels sit above the standard level. Jira’s API also uses Atlassian Document Format (ADF) for descriptions/comments, adding conversion friction for Markdown-first BMAD artifacts.

## Hard gates

| Gate | Jira Cloud | YouTrack Cloud |
|---|---|---|
| Epic → story → task hierarchy | **Conditional pass.** Default is Epic → Story/Task → Subtask, so a literal Story → Task model needs naming/model adaptation. Custom levels require Premium/Enterprise and hierarchy edits can break relationships irreversibly. | **Pass, high confidence.** Parent/subtask links recurse: the bundled subtask workflow explicitly walks from a changed subtask to its parent and then checks whether that parent is itself a subtask. Epic/Story/Task remain issue types/fields rather than rigid structural classes. |
| Configurable workflow | **Pass, medium-high confidence.** REST v3 exposes workflows, statuses, transition rules and workflow schemes; pricing documents automation quotas by plan. | **Pass, high confidence.** Workflow rules can be implemented in the JavaScript editor; the documented subtask automation changes/open/fixes parent state based on children. |
| API/CLI | **Pass via API; vendor CLI not evidenced.** REST v3 supports scripts, apps and ad-hoc personal automation and publishes OpenAPI/Postman material. | **Pass via product automation; REST/standalone CLI not admitted in the capped evidence set.** JavaScript workflows and VCS commands are evidenced; verify REST auth/coverage in round 2 before implementation. |
| GitHub linkage | **Provisionally pass; feature depth not evidenced in the admitted set.** An official “Integrate Jira Cloud with GitHub” page was found, but its rendered body yielded no substantive text; validate commit/PR behavior in a trial. | **Pass, high confidence.** Native GitHub/GitHub Enterprise integration links branches/commits, applies issue commands from commits, and displays PR status in referenced issues. |
| Export | **Pass at data/API level; portability caveat.** REST is broad, but full-site backup/export behavior was not admitted within the source cap; validate workflow/automation export separately. | **Conditional pass.** Pricing states Cloud can migrate all data to YouTrack Server at any time. Issue-level CSV/JSON export was found in search but omitted from the admitted eight-source set; verify limits before migration design. |
| Markdown usability | **Pass for human authoring only; API friction.** REST v3 represents descriptions, comments and multiline fields in ADF rather than Markdown. A Markdown-first BMAD sync needs a converter and round-trip tests. | **Pass, high confidence.** YouTrack accepts Markdown in descriptions, comments, work-item descriptions and other fields; its implementation follows CommonMark plus checklists, tables, mentions and issue-link extensions. |

## Weighted score evidence

| Criterion (weight) | Jira | YouTrack | Evidence/rationale |
|---|---:|---:|---|
| BMAD fit (30%) | 7.5 → **22.5** | 9.0 → **27.0** | Jira’s rigid default level semantics and ADF add mapping work. YouTrack’s recursive parent/subtask model plus Markdown is closer to artifact-driven Epic/Story/Task work. |
| Automation (20%) | 9.0 → **18.0** | 8.5 → **17.0** | Jira has broad REST resources and 150 free / 400 Standard / 750 Premium / 1,000 Enterprise automation steps (billing units as documented). YouTrack supports code-defined JS workflow automation and commit commands. |
| Simplicity (15%) | 5.5 → **8.25** | 8.0 → **12.0** | Jira exposes schemes, multiple hierarchy semantics, plan tiers and ADF. YouTrack’s flexible issue links, Markdown and one principal feature set reduce setup concepts. This is an evidence-based inference, not a measured usability study. |
| Git integration (15%) | 9.0 → **13.5** *(low confidence in R1)* | 8.0 → **12.0** | Jira has an official GitHub integration entry but R1 did not recover its feature detail. YouTrack’s source explicitly covers commits, branches, PR status and issue commands. |
| Price (10%) | 6.5 → **6.5** | 9.5 → **9.5** | Jira: free ≤10; Standard $7.91/user/month; Premium $14.54/user/month. YouTrack: free ≤10 with all paid functionality except custom logo; paid monthly starts $5.40/user for 11 users, annual effective price starts $4.50/user/month and declines with scale. |
| Portability (10%) | 6.0 → **6.0** | 9.0 → **9.0** | Jira’s REST surface is extensive but rich text is ADF and full export was not verified in the admitted set. YouTrack explicitly supports full Cloud→Server migration; Markdown lowers content lock-in. |
| **Total** | **74.75** | **86.5** | Sensitivity: even raising Jira simplicity and portability by 1 point each only adds 2.5 total points; it does not reverse the result. |

## Disqualifiers and risks

- **Literal hierarchy risk (Jira):** if “Epic → Story → Task” is non-negotiable with Task as a true child type, Jira’s documented default fails that literal model. A naming convention such as “Task” as a subtask type may work, but was not evidenced in R1. **Confidence: high on default mismatch; low on workaround.**
- **Plan-gating risk (Jira):** additional hierarchy configuration is Premium/Enterprise; Premium is $14.54/user/month. Relationship-breaking hierarchy changes are documented as irreversible. **Confidence: high.**
- **Artifact round-trip risk (Jira):** ADF is the API representation for descriptions/comments; Markdown files are therefore not lossless native API payloads. **Confidence: high.**
- **Automation quota risk (Jira):** automation is metered by plan; BMAD agents that update many items can consume quotas. **Confidence: high.**
- **Semantic-governance risk (YouTrack):** flexibility is not the same as enforced Epic/Story/Task typing. Teams should add workflow validation so parent/child combinations remain valid. **Confidence: medium (inference).**
- **CLI/API evidence gap (YouTrack):** a robust REST API is widely documented by JetBrains, but the capped admitted source set did not include its developer page; do not select an implementation library until auth and endpoint coverage are verified. **Confidence: high that evidence is incomplete.**
- **No independent usability evidence in R1:** “simpler” is an architectural inference from fewer transformations/configuration layers, not a user study. **Confidence: medium.**

## Leads / contradictions

- No load-bearing contradiction was found. The strongest tension is that Jira is commonly described as supporting Epic/Story/Task, while its own hierarchy page says Story and Task occupy the *same* standard level. This digest follows the official hierarchy page.
- Round-2 lead only if needed: validate Jira’s GitHub PR UI and workflow export; validate YouTrack REST auth/rate limits and CSV/JSON export ceiling; prototype Markdown round-trips with tables, checklists, code blocks and links in both products.

## Searched but not found / not admitted

- No first-party standalone CLI was established for either product; the gate is satisfied through API/automation, not CLI.
- Jira’s official GitHub integration page rendered only its title/navigation in the research client, so precise commit/branch/PR claims are withheld.
- Jira full-site export and YouTrack issue CSV/JSON export pages were located, but omitted to keep the admitted evidence set at eight distinct sources.
- No current independent head-to-head study was found that was both methodologically useful and more authoritative than the current vendor documentation.

## Evidence ledger (all accessed 2026-09-21)

1. **Atlassian, “Jira pricing: Free, Standard, Premium, Enterprise.”** Current live pricing page; no publication/update date shown. <https://www.atlassian.com/software/jira/pricing> — supports prices, free tier, plan features and automation quotas. **Confidence: high; class: primary/current commercial.**
2. **Atlassian Support, “Configure the work type hierarchy.”** Live Cloud documentation; no update date shown. <https://support.atlassian.com/jira-cloud-administration/docs/configure-the-issue-type-hierarchy/> — supports default hierarchy, Premium/Enterprise custom levels and irreversible relationship impact. **Confidence: high; class: primary/current product docs.**
3. **Atlassian Developer, “The Jira Cloud platform REST API.”** Live REST v3 reference; no update date shown. <https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/> — supports API/scriptability, OpenAPI/Postman, workflow/webhook resources and ADF representation. **Confidence: high; class: primary/current developer docs.**
4. **Atlassian Support, “Integrate Jira Cloud with GitHub.”** Page copyright shown as 2023; accessed current page. <https://support.atlassian.com/jira-cloud-administration/docs/integrate-jira-cloud-with-github/> — supports only existence of an official integration entry because substantive body did not render. **Confidence: low-medium; class: primary product docs.**
5. **JetBrains, “Buy YouTrack.”** Current live pricing page; crawled within one week, no page update date shown. <https://www.jetbrains.com/youtrack/buy/> — supports free tier, all-features statement, paid prices, storage and Cloud→Server migration. **Confidence: high; class: primary/current commercial.**
6. **JetBrains, “Subtasks,” YouTrack Cloud 2026.2 Help.** Updated/published context 2026.2; crawled 2026-09-20. <https://www.jetbrains.com/help/youtrack/cloud/workflow-subtasks.html> — supports recursive parent/subtask behavior and JavaScript workflow rules. **Confidence: high; class: primary/current product docs.**
7. **JetBrains, “VCS Integration,” YouTrack Cloud 2026.2 Help.** Page dated 2026-09-17. <https://www.jetbrains.com/help/youtrack/cloud/integration-with-version-control-systems.html> — supports GitHub/Enterprise integration, issue/commit/branch linking, commit commands and PR status. **Confidence: high; class: primary/current product docs.**
8. **JetBrains, “Markdown Syntax,” YouTrack Cloud 2026.2 Help.** Search index published 2026-09-17. <https://www.jetbrains.com/help/youtrack/cloud/youtrack-markdown-syntax-issues.html> — supports CommonMark-plus Markdown fields and extensions. **Confidence: high; class: primary/current product docs.**
