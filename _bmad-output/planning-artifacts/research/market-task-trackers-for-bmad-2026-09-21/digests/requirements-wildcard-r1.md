# Requirements and wildcard tracker — round 1 digest

**Decision:** Choose at most one credible wildcard task-tracker finalist for a BMAD product-development workflow, outside Linear, GitHub Projects, Jira, and YouTrack.  
**Evidence window:** screening evidence published/crawled within six months; feature and pricing evidence live/current or updated within three months. Accessed 2026-09-21.  
**Verdict:** **Advance ClickUp as the sole wildcard finalist.** Plane is the closest alternative, but its explicitly enforced `Epic → Story → Task` type hierarchy is Enterprise Grid-only, and the evidence found does not establish first-class Markdown task descriptions or Markdown work-item export. ClickUp clears every hard gate with current official documentation, though its flexibility creates setup complexity and its task-type hierarchy is conventional rather than type-enforced.

## BMAD's actual artifact and workflow model

- Current BMAD is a four-phase artifact pipeline: analysis outputs inform a PRD; UX and architecture add constraints; `bmad-create-epics-and-stories` produces epic files with stories; sprint planning creates `sprint-status.yaml`; implementation then runs one story at a time and leaves code/tests plus review and retrospective evidence [S1]. **Confidence: high. Class: BMAD-workflow.**
- BMAD's durable implementation hierarchy is primarily **epic → story**, not necessarily epic → story → separately tracked task. An epic is described as a stack of stories; in the spec-backed path `stories.yaml` is the epic inventory and `stories/<id>-*.md` records each story's completion state [S2]. Tasks and acceptance criteria can live inside a spec/story artifact, but current official sources reviewed here do not establish “task” as a third mandatory tracker object [S2]. **Confidence: high. Class: BMAD-artifact-model.**
- Therefore, the tracker should preserve BMAD's Markdown artifacts as source context, model epics and stories cleanly, support the requested third task level without forcing BMAD files into a proprietary editor, and automate status/link synchronization rather than replace `sprint-status.yaml` silently. **Confidence: medium (decision inference from S1–S2 plus the user-supplied hard gates). Class: requirement-inference.**

## Hard gates translated into tests

| Gate | Evidence test |
|---|---|
| Epic → story → task | Three nestable work levels; preferably named types and preserved parent IDs on export. |
| Configurable workflow | Custom statuses at minimum; automation or transition control earns preference credit. |
| API/CLI | Supported write-capable API or maintained CLI. Absence of a first-party CLI is acceptable when the API is documented. |
| GitHub linkage | Direct commit/branch/PR association and preferably status automation. |
| Export | Structured export preserving identifiers and hierarchy, or complete API extraction. |
| Markdown usability | Markdown accepted or returned for task/spec content, and Markdown documents exportable or linkable. |

## Wildcard screen and cuts

| Candidate | Gate screen | Decision |
|---|---|---|
| **ClickUp** | Nested subtasks can be layered freely; custom task types can represent Epic/Story/Task; custom statuses are configurable; the public API accepts `markdown_description`; GitHub links commits, branches, PRs, and can update status; CSV exports include task type, parent ID, subtask IDs, description, status, comments, and attachments; Docs export to Markdown [S3–S7]. | **Advance as the only wildcard finalist.** All gates have direct current official evidence. |
| **Plane** | Strong near-fit: work-item types include Epic/Story/Task; states are configurable; workflows, API, two-way GitHub sync, and CSV/Excel/JSON exports are documented [S8–S10]. However, the explicit typed `Epic → Story → Task` hierarchy is Enterprise Grid-only, a one-way enablement, and current pricing is quote-only for that tier [S8]. The reviewed API exposes Page content as HTML and the product describes a rich-text editor; no first-class Markdown task field or Markdown work-item export was established. | **Cut at gate-risk stage.** It may pass in an Enterprise pilot, but hierarchy cost and Markdown portability remain load-bearing unknowns. |
| **OpenProject** | Official current docs show arbitrarily deep parent/child work-package hierarchy, configurable types/status workflows, GitHub PR linkage, API use, and CSV/XLS/PDF/Atom exports [S11]. | **Cut.** Within the source budget, no current official evidence established Markdown-native task/spec handling or a maintained CLI; its richer administration model also offers no demonstrated simplicity advantage over the finalist. |
| **Shortcut / Taiga / other wildcards** | Searched for current official hierarchy, workflow, GitHub, export, API/CLI, and Markdown evidence. | **Not advanced.** No candidate assembled a better, fully evidenced gate case within the freshness and source budget; this is absence of sufficient evidence, not proof of incapability. |

## Finalist evidence: ClickUp

### Hard-gate evidence

1. **Hierarchy — pass.** ClickUp permits tasks, subtasks, and nested subtasks to be dragged between hierarchy layers; custom task types are unlimited on paid plans and usable through the API. A practical mapping is Epic (task) → Story (subtask) → Task (nested subtask) [S3]. **Confidence: high. Class: feature.** Caveat: current docs do not show type-level parent/child enforcement, so naming discipline or automation is required.
2. **Configurable workflow — pass.** Custom statuses can be created at Space, Folder, Subfolder, and List levels and saved as templates; task types can participate in automation triggers, conditions, and actions [S4]. **Confidence: high. Class: feature.** Caveat: subtasks inherit their home List's statuses, so distinct Epic/Story/Task state machines are not demonstrated.
3. **API/CLI — pass by API.** ClickUp documents token/OAuth authentication; its task API creates and updates tasks, parent relationships, fields, and `markdown_description`. The current pricing matrix lists 100 API calls/minute on Free, Unlimited, and Business, and 10,000/minute on Enterprise [S5][S7]. **Confidence: high. Class: automation/API.** No maintained first-party general-purpose CLI was found.
4. **GitHub linkage — pass.** The integration is available on every plan, links Spaces to repositories, associates commits/branches/PRs with tasks through task IDs, creates GitHub objects from ClickUp, and can change task status from commit/PR text or GitHub Automations [S6]. **Confidence: high. Class: integration.**
5. **Export — pass.** Workspace task CSV exports include task type, IDs, parent ID, subtask IDs, description, status, attachments, comments, and other fields; API export is also supported. Docs export to Markdown, though bulk export of all Docs is not currently available [S7]. **Confidence: high. Class: portability/export.**
6. **Markdown usability — pass with caveat.** The task API supports `markdown_description`, and the Docs API/import-export path supports Markdown; however, richer ClickUp document features do not round-trip perfectly through Markdown [S5][S7]. **Confidence: high. Class: Markdown-interoperability.**

### Weighted score (0–5)

| Preference | Weight | Score | Weighted | Evidence/rationale |
|---|---:|---:|---:|---|
| BMAD fit | 30% | 4.3 | 1.29 | Direct Epic/Story/Task mapping, Markdown descriptions, custom statuses, and hierarchy-preserving export fit BMAD's epic/story artifacts [S1–S5][S7]. Deduction: types are not shown as hierarchy-enforced. |
| Automation | 20% | 4.5 | 0.90 | Public API, OAuth/tokens, GitHub status updates, webhooks/automation integrations, and up to 5,000 monthly automations on Business [S5–S7]. |
| Simplicity | 15% | 2.8 | 0.42 | One product can cover the model, but status scopes, custom types, hierarchy locations, and automations create configuration surface [S3–S4]. This score is an evidence-based judgment, not a measured usability result. |
| Git integration | 15% | 4.6 | 0.69 | All-plan GitHub integration with commits, branches, PRs, issue creation, activity sync, and status updates [S6]. |
| Price | 10% | 4.0 | 0.40 | Unlimited is $7/user/month annually ($10 monthly); Business is $12 annually ($19 monthly) and adds 5,000 automations/month plus custom exporting [S7]. Unlimited appears sufficient for gates; Business is the safer automation/export tier. |
| Portability | 10% | 4.1 | 0.41 | CSV carries hierarchy IDs and core fields, API extraction is available, and Docs export to Markdown [S7]. Deduction: no bulk export of all Docs and no verified lossless Markdown round-trip. |
| **Total** | **100%** |  | **4.11 / 5** | Advance to finalist comparison. |

## Recommended BMAD mapping for a pilot

- Create custom task types `Epic`, `Story`, and `Task`; map an epic to a top-level task, stories to subtasks, and implementation tasks to nested subtasks [S3]. **Confidence: high. Class: implementation-inference.**
- Use one status template aligned to BMAD story progression (for example Backlog → Ready → In progress → Review → Done), because the evidence does not establish separate state machines by task type [S4]. **Confidence: medium. Class: implementation-inference.**
- Keep BMAD Markdown files in the repository as authoritative artifacts; put stable repository links and concise acceptance summaries in ClickUp rather than duplicating entire specs. Use the API to synchronize identifiers/status and export a periodic CSV exit snapshot. **Confidence: medium. Class: reversibility-recommendation.**

## Risks and contradictions

- **BMAD hierarchy mismatch:** the requested three levels exceed BMAD's clearly evidenced durable epic/story model. Treat ClickUp Tasks as optional implementation decomposition, not a new source of product truth [S1–S2].
- **No type-enforced hierarchy:** ClickUp can express three levels but the reviewed official material does not prove that an Epic can be restricted to Story children or a Story to Task children. Plane can enforce this, but only on Enterprise Grid [S3][S8].
- **Markdown fidelity:** ClickUp explicitly supports Markdown input/export, yet some rich document structures are not supported in Markdown interchange and all Docs cannot be bulk-exported [S5][S7]. Keep canonical BMAD artifacts in Git.
- **Vendor-source bias:** capability and pricing claims are first-party. No independent hands-on usability evidence was added because the brief prioritized official sources and constrained the source/round budget. Scores for simplicity are therefore medium confidence.
- **Pricing boundary:** the $7 Unlimited tier clears core data-model/API/Git gates, but Business ($12 annually) is the safer choice if the workflow depends on larger automation quotas and custom exporting [S7]. Exact tax, regional billing, and future repricing were not assessed.

## Searched but not found

- A maintained first-party ClickUp general-purpose CLI.
- ClickUp rules that enforce allowed parent/child combinations by custom task type.
- Separate workflow transitions per ClickUp custom task type.
- A lossless bulk Markdown export for all ClickUp task descriptions and Docs.
- Public Plane Enterprise Grid pricing for its enforced three-level typed hierarchy.
- First-class Markdown work-item input/export in Plane's current official docs.
- Enough fresh official evidence to make Shortcut or Taiga a stronger wildcard than ClickUp within this round's budget.

## Sources

- **[S1]** [Workflow Map](https://docs.bmad-method.org/reference/workflow-map/), BMAD Method / BMad Code, live documentation, publication/update date not displayed; accessed 2026-09-21. Supports phases, artifact flow, epic/story creation, `sprint-status.yaml`, per-story implementation. **Confidence: high. Class: official-method-doc.**
- **[S2]** [Finish an Epic](https://docs.bmad-method.org/build/finish-an-epic/), BMAD Method / BMad Code, live documentation, publication/update date not displayed; accessed 2026-09-21. Supports epic-as-stack-of-stories, sprint-tracked versus spec-backed inputs, `stories.yaml`, and story records. **Confidence: high. Class: official-method-doc.**
- **[S3]** [Create nested subtasks](https://help.clickup.com/hc/en-us/articles/6304431740055-Create-nested-subtasks) and [Custom task types](https://help.clickup.com/hc/en-us/articles/30661182619671-Custom-task-types-feature-availability-and-limits), ClickUp, live help pages crawled 2026-09-21, publication/update date not displayed; accessed 2026-09-21. Supports arbitrary nested layers and paid-plan custom task types. **Confidence: high. Class: official-feature-doc.**
- **[S4]** [Manage task statuses](https://help.clickup.com/hc/en-us/articles/6309452618647-Manage-task-statuses) and [Custom task types](https://help.clickup.com/hc/en-us/articles/17564381376919-Custom-task-types), ClickUp, live help pages crawled 2026-09-21, publication/update date not displayed; accessed 2026-09-21. Supports status scopes/templates and task-type automation. **Confidence: high. Class: official-feature-doc.**
- **[S5]** [Tasks API guide](https://developer.clickup.com/docs/tasks), ClickUp, updated approximately 2025 (page reports “about 1 year ago”); [Authentication](https://developer.clickup.com/docs/authentication), updated approximately 2026-03; accessed 2026-09-21. Supports task CRUD concepts, parent field, Markdown descriptions, personal tokens, and OAuth. **Confidence: high. Class: official-API-doc.**
- **[S6]** [GitHub integration](https://help.clickup.com/hc/en-us/articles/6305771568791-GitHub-integration), ClickUp, live help page crawled 2026-09-21, publication/update date not displayed; accessed 2026-09-21. Supports all-plan availability, repository mapping, commit/branch/PR links, object creation, and status updates. **Confidence: high. Class: official-integration-doc.**
- **[S7]** [ClickUp pricing](https://clickup.com/pricing), ClickUp, live pricing page ©2026 and crawled 2026-09-21; [Workspace export options](https://help.clickup.com/hc/en-us/articles/6310786693015-How-do-I-export-my-Workspace-s-data), ClickUp, live help page crawled 2026-09-21; accessed 2026-09-21. Supports current plan prices, API/automation quotas, CSV/API exports, and Markdown Docs export limitations. **Confidence: high. Class: official-pricing-and-export.**
- **[S8]** [Introducing Workspace Work Item Types and Hierarchy](https://plane.so/blog/introducing-workspace-work-item-types-hierarchy), Plane, 2026-06-09; [Plane Commercial v3.0.0](https://plane.so/changelog/release-v3-0-0-desktop-app-smarter-workflows-powerful-plane-ai-upgrades), Plane, 2026-07-14; accessed 2026-09-21. Supports explicit `Epic → Story → Task` hierarchy, Enterprise Grid availability, and one-way enablement. **Confidence: high. Class: official-release-and-feature.**
- **[S9]** [Workflows and Approvals](https://docs.plane.so/workflows-and-approvals/workflows), [Plane API](https://developers.plane.so/api-reference/introduction), and [GitHub integration](https://docs.plane.so/integrations/github), Plane, live docs crawled 2026-09-21, publication/update dates not displayed; accessed 2026-09-21. Supports configurable transitions, API resources, bidirectional issue/comment sync, and PR-state automation. **Confidence: high. Class: official-feature-and-API-doc.**
- **[S10]** [Export data](https://docs.plane.so/core-concepts/export), Plane, live docs crawled 2026-09-21, publication/update date not displayed; [Plane repository](https://github.com/makeplane/plane), Plane/GitHub, live repository accessed 2026-09-21. Supports CSV/Excel/JSON work-item export, open-source AGPL community edition, self-hosting, and rich-text editor positioning. **Confidence: high. Class: official-export-and-repository.**
- **[S11]** [Work packages](https://www.openproject.org/docs/user-guide/work-packages/), [work-package relations and hierarchies](https://www.openproject.org/docs/user-guide/work-packages/work-package-relations-hierarchies/), [GitHub integration](https://www.openproject.org/docs/system-admin-guide/integrations/github-integration/), and [exporting](https://www.openproject.org/docs/user-guide/work-packages/exporting/), OpenProject, live official docs crawled 2026-09-21, publication/update dates not displayed; accessed 2026-09-21. Supports types, deeper parent/child hierarchy, GitHub PR linkage, and structured exports. **Confidence: high. Class: official-screening-doc.**

