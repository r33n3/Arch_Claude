# SPEC — CCA Foundations Interactive Course

> Last updated: 2026-04-11
> Status: Draft

---

## Overview

An agentic instructor flow for the Claude Certified Architect (CCA) Foundations exam, delivered entirely inside Claude Code. Students choose an instructor persona and work through all 5 exam domains via exercise-first learning — building and running real agentic systems as the primary teaching mechanism. Reading is directed to Anthropic's own documentation. The course produces a readiness report at completion.

**Audience:** Primarily practitioners who already build with Claude and agentic systems. Secondarily, motivated beginners. The course accommodates both without branching content.

---

## Goals

- Get students immediately doing something (exercise-first) before any reading or lecture
- Teach CCA domains by having students *use* the patterns being examined, not just read about them
- Let students choose their instructor persona and switch at any time
- Track per-domain strengths and weaknesses as the student progresses
- Produce a readiness report styled after learn.anthropic.com at course completion

---

## Constraints

- No backend, no database — all student state stored locally in `.student_cca/` (gitignored)
- Reading layer = Anthropic-owned documentation only (no content to build or maintain)
- Must work with Claude Code as the sole runtime environment
- Prerequisites must be clearly gated before first exercise
- Course structure mirrors Noctua: CLAUDE.md bootstrap, persona selection, progress in flat markdown

---

## Out of Scope (this version)

- LMS integration or hosted delivery
- Multi-student cohort tracking
- Grading or official certification pathways
- Any non-Anthropic reading material
- Mobile or web app interface

---

## Architecture

```
CCA-Foundations/
├── CLAUDE.md                         # Bootstrap: session detection, persona load, orientation
├── README.md                         # Prerequisites and lab setup
├── .gitignore                        # .student_cca/ stays local
├── .student_cca/                     # Gitignored — local to each student
│   ├── student.md                    # Persona choice, learning style, switch instructions
│   └── progress.md                   # Per-domain progress, strengths, weaknesses, notes
├── domains/
│   ├── day-0-onboarding.md           # Course overview, persona selection, prereq confirmation
│   ├── domain-1-agentic-architecture.md   # 27% exam weight
│   ├── domain-2-tool-design.md            # 18% exam weight
│   ├── domain-3-claude-code.md            # 20% exam weight
│   ├── domain-4-prompt-engineering.md     # 20% exam weight
│   └── domain-5-context-reliability.md    # 15% exam weight
├── exercises/
│   ├── opening-exercise.md           # Coordinator + subagents live demo w/ narration
│   └── domain-N-exercises.md         # Hands-on per domain
├── patterns/
│   ├── decision-frameworks.md        # Exam-pattern quick reference
│   └── anti-patterns.md             # What NOT to do (exam traps)
└── reports/
    └── readiness-report-template.md  # learn.anthropic.com styled output
```

**Runtime:** Claude Code reads CLAUDE.md on session start. Claude acts as the instructor — loading the student's chosen persona, checking progress, and driving the session interactively.

---

## Features

### Feature: CLAUDE.md Bootstrap
**Status:** Planned
**Priority:** Critical

Auto-loads on every Claude Code session start. Detects first-time vs. returning student. Loads persona and progress. Greets student and orients to where they left off.

**Acceptance criteria:**
- [ ] First-time: runs Day 0 onboarding flow, creates `.student_cca/` files
- [ ] Returning: reads persona + progress, greets with context ("Last session you completed Domain 1 Day 2...")
- [ ] `switch to [persona_name] persona` command works at any point in session
- [ ] CLAUDE.md stays under 80 lines — no lesson logic lives here

**Key files:**
- `CLAUDE.md` — bootstrap entry point

---

### Feature: Day 0 Onboarding
**Status:** Planned
**Priority:** Critical

First session experience. Explains the course, what will be covered, how to navigate, and how the instructor system works. Confirms prerequisites are in place. Student selects their instructor persona.

**Acceptance criteria:**
- [ ] Course overview delivered before any domain content
- [ ] All 5 domains explained with exam weight percentages
- [ ] Instructor persona options presented with clear descriptions
- [ ] Student makes a selection and it is saved to `.student_cca/student.md`
- [ ] Prereqs confirmed before proceeding to Domain 1
- [ ] Leads directly into Domain 1 opening exercise after onboarding

**Key files:**
- `domains/day-0-onboarding.md`
- `.student_cca/student.md` (created here)

---

### Feature: Instructor Persona Engine
**Status:** Planned
**Priority:** Critical

Four distinct instructor personas that change how all content is delivered — tone, pacing, question style, and feedback approach. Same content, different voice. Switchable at any time.

**Personas:**
- **The Practitioner** — Direct, real-world. "Here's how this works in a real deployment."
- **The Socratic** — Question-driven. Makes the student reason before explaining.
- **The Coach** — Encouraging. Frequent check-ins. Celebrates progress.
- **The Challenger** — Pushes back. Demands precision. High standards.

**Acceptance criteria:**
- [ ] Each persona has defined delivery mechanics (documented in student.md)
- [ ] `switch to [persona_name] persona` updates `.student_cca/student.md` and takes effect immediately
- [ ] Persona change is acknowledged explicitly ("Switching to The Challenger. No more hand-holding.")
- [ ] All 4 personas produce clearly different but content-identical sessions

**Key files:**
- `.student_cca/student.md`

---

### Feature: Opening Agentic Exercise
**Status:** Planned
**Priority:** Critical

The course hook. Before any reading, the student watches (and interacts with) a live coordinator + subagents workflow executing inside Claude Code. The instructor narrates what is happening at each step — connecting the live behavior to the CCA concepts being demonstrated.

**Acceptance criteria:**
- [ ] Exercise spins up a coordinator agent + minimum 2 subagents via the Task tool
- [ ] Each step of the execution is narrated in the student's chosen persona style
- [ ] Student is asked questions during execution ("What do you think this agent's job is?")
- [ ] Debrief maps observed behavior to Domain 1 concepts (agentic loop, coordinator role, subagent invocation)
- [ ] Works with student's existing Claude Code + API setup (prereqs already confirmed)

**Key files:**
- `exercises/opening-exercise.md`

---

### Feature: Domain Content Scaffolding (5 Domains)
**Status:** Planned
**Priority:** Critical

Each domain file follows a consistent structure: exercise-first engagement, directed reading (links to Anthropic docs), knowledge checks embedded at key moments, and a checkpoint that writes to progress tracking.

**Structure per domain:**
1. Opening hook (persona-voiced framing of the domain)
2. Hands-on exercise (do something before reading)
3. Directed reading (links to Anthropic documentation)
4. Concept walkthrough (instructor-led, persona-styled)
5. Knowledge checks (embedded questions, not end-of-chapter quizzes)
6. Domain checkpoint (writes to `.student_cca/progress.md`)

**Acceptance criteria:**
- [ ] All 5 domain files follow consistent structure
- [ ] Every domain has at least one hands-on exercise using real Claude Code tooling
- [ ] Directed reading links to official Anthropic sources only
- [ ] Knowledge checks are embedded mid-content, not batched at the end
- [ ] Domain checkpoint updates progress.md with confidence level and notes
- [ ] Weak areas flagged automatically for review in later sessions

**Key files:**
- `domains/domain-1-agentic-architecture.md`
- `domains/domain-2-tool-design.md`
- `domains/domain-3-claude-code.md`
- `domains/domain-4-prompt-engineering.md`
- `domains/domain-5-context-reliability.md`

---

### Feature: Progress Tracking & Feedback Loop
**Status:** Planned
**Priority:** High

Tracks student progress across all domains. Surfaces strengths, weaknesses, and recommended focus areas after each domain checkpoint. Student can ask "how am I doing?" at any time.

**Acceptance criteria:**
- [ ] `.student_cca/progress.md` created on first checkpoint, updated after each
- [ ] Confidence levels tracked per domain section (High / Medium / Low)
- [ ] Weak areas flagged and surfaced proactively at session start
- [ ] Student can ask "what should I focus on?" and get a data-driven answer from progress.md
- [ ] Review sessions logged separately from first-pass sessions

**Key files:**
- `.student_cca/progress.md`

---

### Feature: Pattern Recognition Library
**Status:** Planned
**Priority:** Medium

Quick-reference page of exam decision frameworks and anti-patterns. Consulted by the instructor during knowledge checks and by the student for exam prep.

**Acceptance criteria:**
- [ ] Decision frameworks formatted as "If question asks X → answer is Y" patterns
- [ ] Anti-patterns list clearly states what NOT to do and why
- [ ] Instructor references these during knowledge checks (not just a static page)

**Key files:**
- `patterns/decision-frameworks.md`
- `patterns/anti-patterns.md`

---

### Feature: Progress Report (on-demand)
**Status:** Planned
**Priority:** High

Student can request a progress report at any time during the course. Styled after learn.anthropic.com. Shows completed domains, per-domain confidence, and current weak areas to focus on.

**Acceptance criteria:**
- [ ] Student can trigger with "generate my progress report" or equivalent at any point
- [ ] Report reflects all completed checkpoints in `.student_cca/progress.md`
- [ ] Shows completed vs. remaining domains
- [ ] Highlights weak areas with recommended focus
- [ ] Visual styling matches learn.anthropic.com
- [ ] Saved to `.student_cca/progress-report-[date].md`

**Key files:**
- `reports/readiness-report-template.md`
- `.student_cca/progress-report-[date].md` (generated)

---

### Feature: Final Readiness Report
**Status:** Planned
**Priority:** High

Available after all 5 domains are complete. Same styling as progress report but includes a readiness recommendation and exam-sitting guidance.

**Acceptance criteria:**
- [ ] Only available (or full recommendation unlocked) after all 5 domains are completed
- [ ] Per-domain confidence summary from `.student_cca/progress.md`
- [ ] Readiness recommendation: Ready to sit / Review these areas first / Needs more time
- [ ] Visual styling matches learn.anthropic.com
- [ ] Saved to `.student_cca/readiness-report-final.md`

**Key files:**
- `reports/readiness-report-template.md`
- `.student_cca/readiness-report-final.md` (generated)

---

### Feature: Domain Labs & Live Agent Demos (all 5 domains)
**Status:** Planned
**Priority:** Critical

Every domain includes hands-on labs and at least one live agent demo where Claude spins up real subagents to demonstrate the domain's core concepts. The instructor narrates execution in the student's chosen persona.

**Acceptance criteria:**
- [ ] Each domain has a minimum of 1 live agent demo relevant to its content
- [ ] Each domain has at least 1 lab exercise the student works through
- [ ] Demo narration maps observed behavior to the domain's CCA exam concepts
- [ ] Labs build progressively — later domains can reference patterns from earlier ones
- [ ] All demos work within standard Claude Code + API prereq setup

**Key files:**
- `exercises/domain-N-demo.md` (one per domain)
- `exercises/domain-N-lab.md` (one or more per domain)

---

## Known Tech Debt

None at spec time.

---

## Open Questions

None — context is fully resolved.
