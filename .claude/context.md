# Session Context

## Domain
education / agentic-architecture / claude-code

## Topic
CCA Foundations course — agentic instructor flow built in Claude Code using the Noctua pattern

## What Emerged

- This is a **course product**, not personal exam prep — designed for students to consume
- Primary audience: practitioners; secondary: beginners
- **Exercise-first** engagement model — get students doing something fast before reading/lectures
- Opening is a **Day 1 onboarding**: explain the course, what will be covered, course flow overview
- Then start with **Domain 1** (27% exam weight — Agentic Architecture)
- The opening exercise uses **Claude Code + subagents** to demonstrate agentic fundamentals — the medium is the message
- **Reading layer is Anthropic-owned** — learn.anthropic.com, Claude Code docs, Claude SDK docs, public GitHub repos — no content to build or maintain
- You build the **agentic instructor flow**: CLAUDE.md bootstrap, persona selection, domain scaffolding, checkpoints
- **One instructor persona per student for the whole course** — picked at onboarding
- Student can switch at any time by saying: `switch to [persona_name] persona`
- Persona changes **how** content is delivered, not what is covered (same material, different voice/style)
- **Built-in feedback loop** — course tracks strengths, weaknesses, and areas to focus as student progresses
- Prerequisites section gates the course — students must be fully set up before first exercise

## Instructor Personas (from Noctua)
- **The Practitioner** — Direct, real-world focus. "Here's how this works in production."
- **The Socratic** — Question-driven. Makes you reason it out before explaining.
- **The Coach** — Encouraging. Checks in frequently. Celebrates progress.
- **The Challenger** — Pushes back. Demands precision. High standards.

## Course Structure (high level)
- Prerequisites & lab setup
- Day 1 onboarding: course overview, flow, persona selection
- Domain 1 → Domain 2 → Domain 3 → Domain 4 → Domain 5
- Each domain: exercise-first, then directed reading (Anthropic sources), then knowledge checks, then checkpoint
- Progress tracking: strengths/weaknesses surfaced per domain, areas to focus

## Open Threads
- None — context is ready for spec

## Course Output
- Generates a **readiness report** at course completion
- All reports follow the visual styling of https://www.anthropic.com/learn (Anthropic's own learn platform aesthetic)

## Resolved
- Persona delivery mechanics → leave to spec to propose
- Opening subagent exercise → coordinator + subagents solving a task, with live narration/commentary as it executes so student understands what is happening and why
- Progress storage → `.student_cca/` directory (flat markdown, gitignored, local to each student)

## Spec Status
Not started

## Think Sessions
- 2026-04-11: Established course is a product (not personal prep), exercise-first with Day 1 onboarding, Noctua instructor pattern adapted for CCA, reading layer = Anthropic docs, one persona per student with voice switching, built-in progress feedback
