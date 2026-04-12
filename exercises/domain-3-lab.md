# Domain 3 Lab — Hands-On Claude Code Configuration

> **Instructor note:** This is a hands-on lab. The student does the work. You observe, narrate, and unblock — but you do not write the configuration for them. Where the student gets stuck, ask a Socratic question before offering an answer. The goal is that the student leaves this lab having built something real, not having watched you build something.

---

## Lab Overview

**What you'll build in this lab:**

1. A custom slash command added to the course CLAUDE.md (safely, in your local worktree)
2. A path-specific CLAUDE.md for the `exercises/` directory
3. A headless Claude Code invocation with `--print` to observe non-interactive output
4. A written exam debrief: what a real CCA question about CLAUDE.md hierarchy looks like

**Time estimate:** 45–60 minutes

**Prerequisites:** Domain 3 content walkthrough and demo completed. You should be able to answer: what is the CLAUDE.md hierarchy, what belongs in CLAUDE.md, how do slash commands work.

---

## Lab Setup

You're working in your local worktree for Domain 3 — `worktree-domain-3`. Changes you make here don't affect the main course branch until merged. This is intentional: it's a safe space to experiment with configuration changes without breaking anything for other agents.

Verify your starting state:

```bash
# Confirm you're on the right branch
git branch --show-current
# Expected: worktree-domain-3

# Confirm the course CLAUDE.md is where you expect it
ls CLAUDE.md
```

If `CLAUDE.md` exists, you're ready.

---

## Part 1 — Add a Custom Slash Command

**Your task:** Add a slash command to this course that generates a domain study summary.

**Goal:** When a student types `/domain-summary`, Claude should produce a concise summary of any domain by name — what it covers, its exam weight, and the student's current confidence rating for that domain (pulled from `.student_cca/progress.md`).

**Step 1 — Create the commands directory (if it doesn't exist)**

```bash
mkdir -p .claude/commands
```

**Step 2 — Write the command file**

Create `.claude/commands/domain-summary.md`. Write the prompt yourself — don't copy from the demo. The command should instruct Claude to:

- Ask which domain the student wants a summary of (if not specified)
- Read `.student_cca/progress.md` to find the student's confidence rating for that domain
- Output: domain name, exam weight, 3–5 bullet points of core concepts, current confidence rating, any confusion items logged for that domain

**Step 3 — Verify the command**

In Claude Code, type `/domain-summary domain-3`. If your command is well-formed, Claude runs it. If Claude seems confused about what to do, refine the command file and try again.

> **Instructor note:** If the student's command produces an unexpected result, don't fix it for them immediately. Ask: "What did you expect Claude to do? What did it do instead? What in your command prompt explains the gap?" The debugging process is the learning.

**Debrief question (answer in writing before moving on):**

Why is `/domain-summary` a slash command rather than an instruction in CLAUDE.md? What specifically would break if you put this prompt directly in CLAUDE.md as a standing instruction?

---

## Part 2 — Write a Path-Specific CLAUDE.md for `exercises/`

**Your task:** Create `exercises/CLAUDE.md` that applies additional rules when Claude is working in the exercises directory.

**Context:** The `exercises/` directory contains demo scripts and lab files like this one. When Claude is working here, it should know:
- These are teaching materials — accuracy and clarity matter more than brevity
- Code examples in these files are for illustration, not execution — they may be pseudocode or simplified
- When editing exercises, Claude should never change the Socratic questions (marked with "Wait for student response before continuing") — those are curriculum-controlled
- The persona voice requirements (4 variants per narration block) must be maintained in any edits

**Step 1 — Write the file**

Create `exercises/CLAUDE.md`. Write it yourself. Use what you learned in the demo about what belongs in a subdirectory CLAUDE.md:
- It should not repeat root-level conventions (those are inherited)
- It should only add what's different or elevated for this directory
- Keep it short — every line runs every time Claude works in this directory

**Step 2 — Verify with a test**

Ask Claude to help you improve the wording of a sentence in this lab file. Observe whether it applies the exercises-specific rules. Did it preserve the Socratic question format? Did it apply the teaching materials context?

**Step 3 — Test the hierarchy explicitly**

Ask Claude: "What configuration rules are currently active? Where are they coming from?"

A well-behaved Claude Code instance should be able to identify:
- The root CLAUDE.md (course instructor bootstrap)
- The exercises/CLAUDE.md (the file you just wrote)
- Any home-level CLAUDE.md if you have one

**Debrief question (answer in writing before moving on):**

You have two CLAUDE.md files active when working in `exercises/`. The root says one thing; your exercises file says another (or adds to it). Give a concrete example of a case where both files apply simultaneously without conflict, and a case where the subdirectory file takes precedence over the root.

---

## Part 3 — Run Claude Code in Headless Mode

**Your task:** Use `--print` to run a non-interactive Claude Code invocation and observe the output.

**What you're testing:** Whether Claude Code can operate without a user in the loop — the foundation of CI/CD integration.

**Step 1 — Simple headless invocation**

```bash
claude --print "List the files in the exercises/ directory and summarize what each one covers in one sentence."
```

Observe the output. Note: Claude runs the prompt, returns a result to stdout, and exits. No session. No interactive loop.

**Step 2 — A more structured invocation**

```bash
claude --print "Read .student_cca/progress.md and return only the Domain 3 row as a JSON object with fields: domain, title, exam_weight, status, confidence."
```

This simulates a CI step that reads student state and formats it for a downstream system. If `.student_cca/progress.md` doesn't exist yet, the command will say so — that's also a valid test result.

**Step 3 — With `--dangerously-skip-permissions`**

```bash
claude --print --dangerously-skip-permissions "List the files in domains/ and confirm each one exists."
```

Compare the behavior: does removing permission prompts change what Claude can do in this context? (In most read-only operations, it won't. The difference becomes significant for write operations.)

> **Instructor note:** If the student doesn't have `claude` in their PATH, help them set it up. Do not skip this step — actually running headless mode is more instructive than reading about it. The key insight is that `--print` makes Claude Code scriptable. That changes what's possible.

**Debrief question (answer in writing before moving on):**

A team wants to add Claude Code to their GitHub Actions pipeline to automatically review PRs. The pipeline needs to run without user interaction. Write the shape of the bash command you'd use (you don't need to write the full action YAML, just the claude invocation). What flag is required? What prompt would you pass? What would you do with stdout?

---

## Part 4 — Exam Debrief

This part doesn't require running any code. It requires you to think like a CCA exam question writer.

**The CCA exam tests:**
- Scenario comprehension: given a configuration setup, predict the behavior
- Design judgment: given a problem, choose the right mechanism
- Hierarchy understanding: given overlapping CLAUDE.md files, determine what applies

**Exercise 4A — Write an exam question**

Write a CLAUDE.md hierarchy question that you think could appear on the CCA exam. It should:
- Present a specific scenario (project structure, multiple CLAUDE.md files, a developer task)
- Ask what behavior Claude Code will exhibit
- Have exactly one correct answer
- Have at least two plausible wrong answers

Write your question, then write the correct answer and explain why the wrong answers are wrong.

**Exercise 4B — Answer this question**

> *A developer has the following setup:*
> - `~/.claude/CLAUDE.md`: "Always respond in formal English. Never use contractions."
> - `project/CLAUDE.md`: "This is a startup codebase. Use casual, direct language."
> - `project/docs/CLAUDE.md`: "These are user-facing docs. Match the tone of the existing content, which is professional but approachable."
>
> *The developer asks Claude to edit a sentence in `project/docs/user-guide.md`.*
>
> *Question: Which tone instruction does Claude follow? Rank all three in order of precedence and explain the reasoning.*

Write your answer before the instructor reveals the answer.

> **Instructor — reveal after student answers:**

The correct answer:

1. `project/docs/CLAUDE.md` takes highest precedence — most specific (subdirectory level)
2. `project/CLAUDE.md` takes second precedence — repo root level
3. `~/.claude/CLAUDE.md` takes lowest precedence — home level (least specific)

Claude follows the `project/docs/CLAUDE.md` instruction: "Match the tone of the existing content, which is professional but approachable." The home-level "formal English, no contractions" is overridden by the more specific project-level casual instruction, which is itself overridden by the docs-level tone-matching instruction.

**Key exam insight:** The exam doesn't ask "which CLAUDE.md wins?" — it asks "which instruction applies in this specific context?" The answer depends on where the file being edited lives and which CLAUDE.md files are in scope for that location.

---

## Lab Completion Checklist

Before you close this lab, verify:

- [ ] `.claude/commands/domain-summary.md` created and tested
- [ ] `exercises/CLAUDE.md` created with appropriate subdirectory rules
- [ ] Headless `--print` invocation run and observed
- [ ] Written answers to all three debrief questions
- [ ] Exam question written (Exercise 4A)
- [ ] Hierarchy question answered (Exercise 4B)

When all items are checked, return to `domains/domain-3-claude-code.md` and run the Domain Checkpoint sequence to update your progress file.

---

## What You Built

| Artifact | Type | What it does |
|----------|------|-------------|
| `.claude/commands/domain-summary.md` | Slash command | On-demand domain summary with confidence rating |
| `exercises/CLAUDE.md` | Subdirectory config | Teaching-context rules for the exercises directory |
| Headless invocation | CI/CD pattern | Demonstrated non-interactive Claude Code operation |
| Exam questions | Exam prep | Tested hierarchy comprehension from both sides |

> **Instructor — closing in persona voice:**

*Practitioner:* "You built three real artifacts and tested them. The slash command, the subdirectory CLAUDE.md, and the headless invocation are all patterns you'll use in production. The exam debrief gave you the question-writing muscle that makes hard exam scenarios tractable."

*Socratic:* "Looking at everything you built today — what's the thing you'd most want to revisit before the exam? What's still fuzzy? Name it specifically."

*Coach:* "Lab complete! You wrote a slash command, a path-specific configuration, ran headless mode, and wrote your own exam question. That's a full domain's worth of hands-on work. You're ready for Domain 4."

*Challenger:* "The lab is done. But here's the real question: if someone handed you a production project with no CLAUDE.md and said 'set this up for Claude Code,' could you do it right now? What would you do first, and why?"
