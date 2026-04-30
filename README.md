# CCA Foundations — Interactive Exam Prep Course

An interactive Claude Certified Architect (CCA) exam prep course delivered inside Claude Code. Work through all 5 exam domains with a live instructor persona, hands-on exercises, and progress tracking — all running locally with no backend required.

---

## Prerequisites

Before starting the course, confirm the following are in place:

### 1. Claude Code installed and authenticated

Install Claude Code and sign in with your Anthropic account:

```bash
npm install -g @anthropic-ai/claude-code
claude
```

Follow the authentication prompts on first launch. You must be authenticated before the course will function.

### 2. Anthropic API key configured

The course exercises spin up real agentic workflows that call the Anthropic API. You need a valid API key set in your environment:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

Add this to your shell profile (`.bashrc`, `.zshrc`, etc.) so it persists across sessions. Without this key, the hands-on agent exercises will not run.

### 3. Recommended two-screen setup

The course is designed for side-by-side use:

- **Screen 1 (or left split):** Claude Code terminal running the course
- **Screen 2 (or right split):** Browser open to [Anthropic documentation](https://docs.anthropic.com)

The instructor will direct you to specific documentation pages during the course. Having them immediately accessible — without switching windows — keeps you in flow.

---

## Quick Start

Once prerequisites are confirmed:

```bash
git clone https://github.com/r33n3/Arch_Claude.git
cd Arch_Claude
claude
```

Claude Code loads `CLAUDE.md` automatically. First-time students are walked through Day 0 onboarding. Returning students are greeted with their progress and pick up where they left off.

---

## Course Structure

| Domain | Title | Exam Weight |
|--------|-------|-------------|
| 0 | Day 0 Onboarding | — |
| 1 | Agentic Architecture | 27% |
| 2 | Tool Design | 18% |
| 3 | Claude Code | 20% |
| 4 | Prompt Engineering | 20% |
| 5 | Context & Reliability | 15% |

## Patterns Library

Two quick-reference files in `patterns/` are designed for use alongside the domains and for final review before the exam:

| File | What it is |
|---|---|
| `patterns/decision-frameworks.md` | If-X-then-Y decision tables for every exam domain. Use this when you need to quickly recall which option to choose in a scenario question. |
| `patterns/anti-patterns.md` | 26 named anti-patterns organized by domain. Each entry describes what the mistake looks like, why it fails, and what to do instead. Review this the morning of the exam. |

The instructor will reference both files during domain checkpoints. You can also open them directly at any time.

---

## Student State

All progress is stored locally in `.student_cca/` (gitignored). Nothing is sent to any server. Your persona choice, domain progress, confidence levels, and session notes stay on your machine.
