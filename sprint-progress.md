# sprint-progress.md — Agent Completion Status

The main session uses this file to coordinate PR merges in order.
Agents: update your row when you raise your PR. Do not modify other rows.

## Sprint 1 — Complete

| Agent | Status | PR | Notes |
|---|---|---|---|
| foundation | merged | direct | CLAUDE.md 74 lines, templates embedded inline |
| onboarding | merged | direct | FinClearance Corp scenario, Task tool pattern documented |

## Sprint 2 — In Progress

| Agent | Status | PR | Notes |
|---|---|---|---|
| domain-1 | committed | — | domains/domain-1-agentic-architecture.md, exercises/domain-1-demo.md, exercises/domain-1-lab.md. BuildOps Inc (construction PM) used as primary scenario throughout; FinClearance Corp referenced as continuity from opening exercise. Exercise-first structure: student decomposes BuildOps task before any reading. 4 knowledge checks embedded mid-content (agentic loop, coordinator job 4, task decomposition, error handling). Demo exposes coordinator internals via explicit narration of each decision point. Lab has 9-stage scaffolded build with Stage 2 design gate enforced before prompt writing. |
| domain-2 | in-progress | — | — |
| domain-3 | committed | — | domains/domain-3-claude-code.md, exercises/domain-3-demo.md, exercises/domain-3-lab.md. Meta angle: course CLAUDE.md used as primary teaching example throughout. Subdirectory CLAUDE.md hierarchy tested via Meridian Analytics demo scenario. |
| domain-4 | committed | — | domains/domain-4-prompt-engineering.md, exercises/domain-4-demo.md, exercises/domain-4-lab.md. SecurePath Systems (threat classification) scenario used throughout. Demo shows 4-step prompt progression (raw → format → JSON schema → few-shot) plus live validation loop. Lab uses vendor security bulletins as data source; 6-step scaffolded build with iteration log. |
| domain-5 | committed | worktree-domain-5 | Capstone domain; context summarization, graceful degradation, retry/backoff, observability, testing, production ops; all-5-domains readiness report trigger |

## Merge order (Sprint 2 — all parallel, merge in numeric order)
1. domain-1
2. domain-2
3. domain-3
4. domain-4
5. domain-5

## Memory captures (agents fill in — main session writes to memory after merge)

If you made a non-obvious decision, found a gotcha, or discovered something future agents
should know — add it here before raising your PR.

| Agent | What to remember |
|---|---|
| foundation | CLAUDE.md embeds both template files inline (student.md + progress.md). On first run, Claude creates `.student_cca/` and writes those templates from the embedded content — no separate template files are committed. Domain agents reading CLAUDE.md: the bootstrap logic is in Steps 1–3 + persona switch section. The `.gitignore` must exist on the foundation branch (not inherited from main) because worktrees use the branch's own tracked files. |
| onboarding | Enterprise scenario: FinClearance Corp (financial services, regulatory doc analysis) — most universally relatable across practitioner backgrounds. Task tool pattern: coordinator invokes two parallel Tasks, each with a self-contained task description including role, deliverable, scope constraints, and a note about what the parallel agent is doing (prevents scope drift). Persona delivery pattern for domain agents: each narration block must have 4 variants keyed to the persona name; Socratic questions must be marked as blocking (wait for student response); Challenger persona always demands a specific answer before continuing. Failure fallback: narrate what would have happened, never block course progress on tool failure. |
| domain-1 | BuildOps Inc (construction PM) used throughout — distinct from FinClearance Corp (opening exercise) to avoid scenario fatigue across domains. 4 knowledge checks embedded mid-content, not end-of-domain — one per major concept cluster. Domain checkpoint uses exact field names from CLAUDE.md template: Status, Confidence, Confusion Log, Last session note. Lab Stage 2 design gate (design-before-build) is a mandatory enforced checkpoint — adopt this pattern in other domain labs. ASCII context boundary diagram in demo proved effective for making isolation concrete; reuse in Domain 5 context window section. "When NOT to use agents" is a deliberate exam trap section — place equivalent "when NOT to use X" in Domain 2 (tool design) and Domain 4 (few-shot). All 4 persona variants present in every narration block; Socratic questions marked blocking with explicit "Wait for student response before continuing." |
| domain-4 | Demo progression pattern: 5 steps (raw → format constraint → JSON schema → few-shot → validation loop) is a reusable teaching arc for any structured output domain. Intentionally weakened Step 2 prompt for the validation loop demo — makes the reviewer's value visible. Lab uses iteration log (Step 6) as primary exam study artifact — students generate their own case study. SecurePath threat classification scenario is compatible with domain-1 FinClearance Corp — both enterprise, different industry. Checkpoint writes to .student_cca/progress.md using exact field names from CLAUDE.md template: Status, Confidence, Confusion Log, Last session note. |
| domain-5 | Capstone framing: Domain 5 explicitly ties back to all 4 prior domains in a synthesis section — each prior domain's key concept is mapped to a Domain 5 reliability concern. All-5-complete check lives in the Domain Checkpoint section of domain-5-context-reliability.md; it reads progress.md and triggers readiness report prompt if all Status fields = Complete. Readiness report logic: check for reports/readiness-report-template.md first; generate structured summary with per-domain confidence, top 3 confusions, weight-adjusted readiness, and Ready/Review/Not Yet recommendation if absent. SecurePath Systems scenario used in the lab for continuity with Domain 4. Lab answer key is embedded (instructor-only section) to support self-assessment. |

## Sprint 3 — In Progress

| Agent | Status | PR | Notes |
|---|---|---|---|
| reports | committed | worktree-reports | reports/readiness-report-template.md. Two-variant template (Progress Report on-demand, Final Readiness Report on completion). Claude-fill mechanics: comment-block instructions, {{PLACEHOLDER}} markers, conditional section logic, 3-tier readiness criteria. Styled after learn.anthropic.com (oat/heather/cactus color semantics, confidence symbols ●◑○). Reads exact field names from .student_cca/progress.md: Status, Confidence, Confusion Log, Last session note. Save targets: progress-report-YYYYMMDD.md and readiness-report-final.md. |
| patterns | committed | — | patterns/decision-frameworks.md, patterns/anti-patterns.md. All 5 domains covered. Decision frameworks formatted as "If X → Y" scannable tables (6–7 entries per domain). Anti-patterns as 4-field entries: name, what it looks like, why it fails, what to do instead (4 per domain, 16 total). Cross-references to domain files throughout. |

## Memory updates (main session fills this after each merge)
<!-- Record what shipped and any open items that carry forward -->
