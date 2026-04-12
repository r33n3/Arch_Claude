# sprint-progress.md — Agent Completion Status

The main session uses this file to coordinate PR merges in order.
Agents: update your row when you raise your PR. Do not modify other rows.

| Agent | Status | PR | Notes |
|---|---|---|---|
| foundation | committed | no-remote (local repo only) | All files committed on worktree-foundation branch. No GitHub remote configured — PR cannot be raised. Merge manually: git checkout main && git merge worktree-foundation |
| onboarding | committed | no-remote (local repo only) | domains/day-0-onboarding.md and exercises/opening-exercise.md committed on worktree-onboarding. Used FinClearance Corp scenario (financial services, regulatory doc analysis). Task tool invocation uses two parallel agents: terminology-mapping subagent and gap-analysis subagent, each with explicitly scoped task descriptions. Failure fallback documented. Merge manually: git checkout main && git merge worktree-onboarding |

## Merge order
1. foundation (must merge before onboarding starts deep work)
2. onboarding

## Memory captures (agents fill in — main session writes to memory after merge)

If you made a non-obvious decision, found a gotcha, or discovered something future agents
should know — add it here before raising your PR.

| Agent | What to remember |
|---|---|
| foundation | CLAUDE.md embeds both template files inline (student.md + progress.md). On first run, Claude creates `.student_cca/` and writes those templates from the embedded content — no separate template files are committed. Domain agents reading CLAUDE.md: the bootstrap logic is in Steps 1–3 + persona switch section. The `.gitignore` must exist on the foundation branch (not inherited from main) because worktrees use the branch's own tracked files. |
| onboarding | Enterprise scenario: FinClearance Corp (financial services, regulatory doc analysis) — most universally relatable across practitioner backgrounds. Task tool pattern: coordinator invokes two parallel Tasks, each with a self-contained task description including role, deliverable, scope constraints, and a note about what the parallel agent is doing (prevents scope drift). Persona delivery pattern for domain agents: each narration block must have 4 variants keyed to the persona name; Socratic questions must be marked as blocking (wait for student response); Challenger persona always demands a specific answer before continuing. Failure fallback: narrate what would have happened, never block course progress on tool failure. |

## Memory updates (main session fills this after each merge)
<!-- Record what shipped and any open items that carry forward -->
