# Product fit, round 1: Linear vs GitHub Projects

**Decision:** choose the task tracker best suited to an artifact-driven BMAD product-development workflow.  
**As of / accessed:** 2026-09-21. **Round:** 1 plus one targeted follow-up verification. **Sources used:** nine, all first-party.  
**Hard gates:** epic→story→task hierarchy; configurable workflow; API/CLI; GitHub linkage; export; Markdown usability.  
**Weights:** BMAD fit 30%; automation 20%; simplicity 15%; Git integration 15%; price 10%; portability 10%.

## Compact verdict

Both candidates pass all hard gates. **GitHub Projects is the narrow weighted pick (4.49/5 vs Linear 4.42/5)** after follow-up verification confirmed that any user who can access a project can export a project view directly as TSV. Linear remains the stronger choice when explicit BMAD planning semantics and rich Markdown handoffs matter most; GitHub wins the stated weighting through automation, native code proximity, price, and now verified turnkey export.

The margin is narrow and partly judgment-based: “simplicity” and “BMAD fit” are reasoned assessments from the documented product models, not independently measured usability. A short pilot using one BMAD epic is the cheapest reversibility hedge. **Correction:** the initial round incorrectly reported that no first-party one-click GitHub Projects export was found; official GitHub documentation retrieved in the permitted follow-up proves that a view can be exported as `.tsv`. Recalculating also corrected arithmetic inconsistencies in the initially stated totals so the totals now equal the displayed score cells and weights.

## Findings as claims

### Linear

- **L1 — hierarchy/model:** Linear exposes Initiatives, Projects, Issues, and parent/sub-issues. Its docs describe Projects as outcome-oriented units composed of issues, while the documentation index explicitly identifies Initiatives, Projects, and parent/sub-issues. A direct BMAD mapping is therefore Initiative (program/goal) → Project (epic) → Issue (story) → Sub-issue (task). This is a mapping inference, not Linear’s prescribed BMAD vocabulary. **Confidence: high. Class: product model / official product documentation.** Sources: [S1], [S2].
- **L2 — workflow:** Linear documents custom issue workflows and workflow statuses; its pricing page includes Issues, Projects, Cycles, and Initiatives across the plan comparison. This clears the configurable-workflow gate, although the fixed higher-level entity semantics are more opinionated than GitHub’s field-based model. **Confidence: medium-high. Class: workflow capability / official product documentation.** Sources: [S1], [S2].
- **L3 — Markdown/docs:** Linear supports copying issues and documents as structured Markdown, including an issue’s title, description, comments, and customer requests. This is unusually well aligned with BMAD’s file-like artifacts and LLM handoffs. **Confidence: high. Class: artifact handling / official product documentation.** Source: [S4].
- **L4 — GitHub/PR integration:** Linear links issues to PRs and commits, can move issue status from PR/commit activity with branch-specific rules, exposes review state, and supports one- or two-way GitHub Issues sync. **Confidence: high. Class: integration capability / official product documentation.** Source: [S3].
- **L5 — API/automation:** Linear advertises API and webhook access across its plan matrix; its export documentation also states that issues, projects, and other data can be exported through the API and used through webhooks. The retrieved evidence establishes availability, but not CLI parity with `gh`; treat Linear CLI-based operation as weaker unless a separate CLI is selected or built. **Confidence: high for API/webhooks; medium for operational ergonomics. Class: automation capability / official documentation and pricing.** Sources: [S1], [S4].
- **L6 — export/migration:** Admins can export workspace issues to CSV; members/admins can export issue views and project/initiative lists, while issue descriptions retain attachment links but attachment files are excluded. Markdown copy and API export improve portability, but a CSV-only workspace export is not a complete fidelity-preserving backup of all collaboration data. **Confidence: high. Class: portability / official product documentation.** Source: [S4].
- **L7 — pricing:** Current listed annual-billing prices are Free $0 (250 issues, 2 teams), Basic $10/user/month (unlimited issues, 5 teams), Business $16/user/month, and Enterprise custom. Core planning, API/webhooks, and import/export appear in the comparison table; advanced capabilities vary by tier. **Confidence: high. Class: current pricing (≤3 months) / official live pricing.** Source: [S1].

### GitHub Projects

- **G1 — hierarchy/model:** GitHub Issues supports nested sub-issues up to eight levels and 100 direct sub-issues per parent; the CLI can create issues with `--parent` and add/remove sub-issues. Epic → Story → Task can therefore be modeled as nested issues, while Projects is the planning/view layer rather than an “epic” object. **Confidence: high. Class: product model / official product documentation.** Source: [S6].
- **G2 — workflow:** Projects offers table, board, and roadmap views; filters/grouping; custom text, number, date, single-select, and iteration fields; templates; status updates; and built-in workflows that set fields, auto-add matching items, and archive matching items. This clears the configurable-workflow gate but requires more local conventions to preserve BMAD semantics. **Confidence: high. Class: workflow capability / official product documentation.** Source: [S5].
- **G3 — Markdown/docs:** Project status updates support Markdown and Projects have a README; issue descriptions are the content objects used by the nested hierarchy and API. GitHub is naturally Markdown-centric, but BMAD long-form artifacts remain repository files or issue bodies rather than a dedicated tracker document type. **Confidence: medium-high. Class: artifact handling / official product documentation plus model inference.** Sources: [S5], [S7].
- **G4 — Git/PR integration:** Project items are direct references to GitHub issues and pull requests, so code linkage is native rather than a third-party synchronization layer. **Confidence: high. Class: integration capability / official product documentation.** Source: [S5].
- **G5 — API/CLI/automation:** Projects can be automated with built-in workflows, GitHub Actions, and GraphQL. The official API guide documents read/write scopes and mutations for adding items and updating project fields, and uses `gh api graphql` examples. **Confidence: high. Class: automation capability / official product documentation.** Sources: [S5], [S7].
- **G6 — export/migration (corrected in follow-up):** Anyone who can access a GitHub Project can export the current project view directly as a `.tsv` file through **View → Export view data**. GraphQL additionally provides structured access suitable for custom, higher-fidelity export. This overturns the initial round’s “no one-click export found” statement; GitHub has a turnkey tabular export, although the selected documentation does not establish that TSV preserves comments, attachments, or the complete nested hierarchy. **Confidence: high for TSV export; medium for full-fidelity migration. Class: portability / official product documentation.** Sources: [S7], [S9].
- **G7 — pricing:** GitHub’s live pricing page lists Free at $0, Team at $4/user/month, and Enterprise at $21/user/month; paid usage such as Actions can add variable cost. The retrieved pricing page does not itemize a separate Projects charge, so the price score assumes Projects is used within the selected GitHub plan, not that every desired governance feature is free. **Confidence: high for plan prices; medium for marginal-cost inference. Class: current pricing (≤3 months) / official live pricing.** Source: [S8].

## Hard-gate screen

| Gate | Linear | GitHub Projects |
|---|---|---|
| Epic→story→task hierarchy | **Pass:** Project → Issue → Sub-issue; Initiative adds a level [L1] | **Pass:** nested typed/convention-based issues, up to 8 levels [G1] |
| Configurable workflow | **Pass:** custom issue workflows/statuses [L2] | **Pass:** fields, views, templates, built-in workflows [G2] |
| API/CLI | **Pass:** API + webhooks; CLI ergonomics weaker [L5] | **Pass:** GraphQL + `gh api`; Actions [G5] |
| GitHub linkage | **Pass:** PR/commit links, automations, issue sync [L4] | **Pass:** native issues/PR project items [G4] |
| Export | **Pass:** CSV, Markdown copy, API [L6] | **Pass:** one-click view export as TSV plus GraphQL/custom export [G6] |
| Markdown usability | **Pass:** Markdown input/copy for issues/docs [L3] | **Pass:** Markdown status/README and issue bodies [G3] |

## Weighted candidate score evidence

Scores are 1–5. Weighted total = Σ(score × weight). Subjective scores are explicitly reasoned from the sourced capabilities.

| Criterion | Weight | Linear | Evidence | GitHub Projects | Evidence |
|---|---:|---:|---|---:|---|
| BMAD fit | 30% | **4.8** | Explicit multi-level planning model plus Markdown documents/exports [L1, L3] | **4.2** | Deep hierarchy works, but BMAD levels are conventions on generic issues [G1, G3] |
| Automation | 20% | **4.4** | API, webhooks, and strong PR-driven state automation [L4, L5] | **5.0** | Built-ins + GraphQL + Actions + CLI path [G2, G5] |
| Simplicity | 15% | **4.5** | Opinionated planning entities reduce schema design; inference from model [L1, L2] | **3.5** | Flexible primitives require conventions/field setup; inference from model [G1, G2] |
| Git integration | 15% | **4.5** | Deep third-party GitHub integration and optional issue sync [L4] | **5.0** | Issues and PRs are native project items [G4] |
| Price | 10% | **3.2** | Useful free trial ceiling; practical unlimited tier starts $10/user/month [L7] | **5.0** | $0 Free and $4 Team; no separately listed Projects price [G7] |
| Portability | 10% | **4.3** | CSV + Markdown copy + API, with attachment/full-fidelity caveats [L6] | **4.5** | One-click TSV view export plus GraphQL; full-fidelity limits remain unverified [G6] |
| **Weighted total** | **100%** | **4.42** |  | **4.49** |  |

## Disqualifiers and material risks

- **No hard-gate disqualifier found for either candidate.**
- **Linear:** the free plan’s 250-issue cap makes it a pilot tier, not a durable BMAD program archive; API/webhook availability does not equal a mature first-party general-purpose CLI; CSV exports omit attachment files and do not prove full-fidelity export of every collaboration object [L5–L7].
- **GitHub Projects:** “epic,” “story,” and “task” are not separate planning entities in the evidence reviewed; governance depends on issue types/conventions, fields, and templates. Long-form BMAD documents are more naturally kept in the repository than in Projects. TSV reduces reporting and exit friction, but the retrieved export documentation does not promise a full-fidelity archive of comments, attachments, workflow configuration, or hierarchy [G1–G3, G6].
- **Both:** the scores do not measure real team adoption, mobile UX, search quality, or the effort of keeping repository Markdown artifacts synchronized with tracker state.

## Leads / contradictions

- **Follow-up correction resolved a load-bearing absence claim:** official GitHub documentation establishes native TSV view export [G6, S9]. The hierarchy difference remains conceptual, not factual: Linear supplies distinct planning entities; GitHub supplies a deep generic issue tree plus a configurable project view.
- If further research is authorized, verify only two remaining load-bearing uncertainties: (1) current GitHub Projects entitlements/limits by plan and the exact fidelity of TSV export for nested relationships; (2) Linear’s current first-party CLI/MCP coverage and whether documents/comments can be exported at full fidelity through the public API.
- Independent practitioner evidence could test the subjective simplicity scores, but it was not necessary to establish the hard gates and would exceed this round’s eight-source cap.

## Searched but not found

- Whether GitHub’s TSV export preserves nested hierarchy, comments, attachments, and workflow configuration sufficiently for full-fidelity migration; the official page confirms view-data export but does not document those semantics.
- A first-party Linear CLI with breadth comparable to `gh project` in the selected official sources.
- Fresh, independent (≤3 months) comparative evidence measuring adoption effort or usability for artifact-driven product teams.
- A native BMAD-specific integration or prescribed BMAD schema for either product.

## Source register

All URLs were accessed 2026-09-21. Where the publisher exposes no page publication/update date, it is recorded as **n.d. (live documentation)**; freshness is based on the live page retrieval date, not an invented publication date.

| ID | Source | Publisher | Publication/update date | Confidence | Class |
|---|---|---|---|---|---|
| S1 | [Linear Pricing](https://linear.app/pricing) | Linear | n.d.; live pricing retrieved 2026-09-21 | High | Official current pricing and plan matrix |
| S2 | [Linear Docs index](https://linear.app/docs) | Linear | n.d.; live docs retrieved 2026-09-21 | High | Official product documentation |
| S3 | [GitHub integration](https://linear.app/docs/github-integration) | Linear | n.d.; live docs retrieved 2026-09-21 | High | Official integration documentation |
| S4 | [Exporting Data](https://linear.app/docs/exporting-data) | Linear | n.d.; live docs retrieved 2026-09-21 | High | Official export/portability documentation |
| S5 | [About Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects) | GitHub | n.d.; live docs retrieved 2026-09-21 | High | Official product documentation |
| S6 | [Adding sub-issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues) | GitHub | n.d.; live docs retrieved 2026-09-21 | High | Official hierarchy/CLI documentation |
| S7 | [Using the API to manage Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects) | GitHub | n.d.; live docs retrieved 2026-09-21 | High | Official API/automation documentation |
| S8 | [GitHub Pricing](https://github.com/pricing) | GitHub | n.d.; live pricing retrieved 2026-09-21 | High | Official current pricing |
| S9 | [Exporting your project data](https://docs.github.com/en/issues/planning-and-tracking-with-projects/managing-your-project/exporting-your-projects-data) | GitHub | n.d.; live docs retrieved 2026-09-21 | High | Official export/portability documentation; targeted follow-up correction |
