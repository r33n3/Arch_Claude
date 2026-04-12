# Domain 3 Demo — Build a CLAUDE.md From Scratch

> **Instructor note:** This is a live build. You are constructing a real CLAUDE.md in real time, explaining each decision in persona voice as you go. The student watches, asks questions, and participates in the Socratic checkpoints. Do not skip the blocking questions — waiting for a student answer is the mechanism that converts observation into learning.

---

## Setup

You're about to watch a real CLAUDE.md get built from nothing.

Not a template being filled in. Not a finished example being explained. A live construction — adding each section deliberately, with a reason for every choice.

**What you're about to see:**
- An empty project directory getting its first CLAUDE.md
- Each section added one at a time, with narration on why it belongs
- A custom slash command added and tested
- A subdirectory CLAUDE.md added to override behavior for a specific path
- The full hierarchy in action: root-level vs. subdirectory-level behavior

**The scenario:**

A small engineering team at **Meridian Analytics** is starting a new data pipeline project. They want Claude Code to understand their conventions, adopt a specific role when working in the project, and have a custom command for generating test data schemas. They also have a `scripts/` directory where Claude should follow stricter rules than the rest of the project.

---

## Step 1 — Start with Nothing

> **Instructor — persona-voiced setup:**

*Practitioner:* "We're starting from an empty directory. No CLAUDE.md. No configuration. Claude Code in this state knows nothing about Meridian Analytics, nothing about their conventions, and will ask permission for everything. We're going to change that — deliberately, one section at a time."

*Socratic:* "Before I write the first line — what's the first thing you'd want Claude to know about a project like this? If you could only tell it one thing before it starts working, what would it be?"

*Coach:* "Exciting starting point — we're building from scratch! This is how every production CLAUDE.md starts: completely empty. By the end of this demo, you'll be able to build one yourself. Let's go."

*Challenger:* "Empty directory. No configuration. What's wrong with this state? What will go wrong the first time a developer asks Claude to do anything non-trivial without a CLAUDE.md? Give me a specific failure mode."

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "What's the first thing you'd want Claude to know about this project — and why that thing first?"

After student answers, provide feedback in persona voice, then continue.

**The empty project:**

```
meridian-analytics/
  src/
    pipeline/
    transforms/
  scripts/
  tests/
  README.md
```

No CLAUDE.md anywhere. Claude Code defaults to general-purpose behavior.

---

## Step 2 — Write the Root CLAUDE.md

Open `meridian-analytics/CLAUDE.md` and write the first section:

```markdown
# Meridian Analytics — Claude Code Configuration

You are a data pipeline engineer working on Meridian Analytics' core ETL system.

## Project context

This project processes financial transaction data for reconciliation reporting.
Data is sensitive — no sample data, real schemas, or connection strings
should ever appear in generated code or tests. Use synthetic data only.

## Conventions

- Python 3.11+. Type annotations on all functions.
- All transforms are pure functions: no side effects, no global state.
- Pipeline stages: ingest → validate → transform → load
- Tests use pytest. Test files mirror source structure in `tests/`.

## Constraints

- Never modify files in `scripts/` without explicit confirmation.
- Never write connection strings or credentials to any file.
- When uncertain about data format, ask before assuming.
```

> **Instructor — narrate each section as you write it:**

*Practitioner:* "Three sections: context, conventions, constraints. The context tells Claude what it is in this project — not just what the project is, but Claude's role. Conventions are the rules Claude needs to follow consistently. Constraints are the guardrails — the things that, if violated, create real problems. Every production CLAUDE.md needs all three."

*Socratic:* "I wrote that the context is sensitive data and synthetic data only. Where does that constraint actually live — in context, conventions, or constraints? Why does placement matter?"

*Coach:* "Notice how specific the conventions are? 'Type annotations on all functions' — not 'use good Python practices.' Specificity is what makes this useful. Vague instructions produce vague behavior."

*Challenger:* "I said 'Never modify files in `scripts/` without explicit confirmation.' Is that the right mechanism? What's a failure mode where that instruction doesn't work, and what would a better approach look like?"

---

## Step 3 — Add a Custom Slash Command

Create `.claude/commands/generate-schema.md`:

```markdown
Generate a synthetic data schema for testing pipeline transforms.

The schema must:
- Include 10–20 realistic field names appropriate for financial transaction data
- Include field types (string, integer, decimal, date, boolean)
- Include nullable flags and example values
- Be formatted as a Python TypedDict
- Use synthetic values only — no real account numbers, names, or institutions

Output the TypedDict definition followed by a sample data factory function
that generates a list of N records using the Faker library.
```

> **Instructor — narrate the command creation:**

*Practitioner:* "That file — `generate-schema.md` in `.claude/commands/` — is now a slash command. Any developer on this project types `/generate-schema` and Claude runs that entire prompt. It's a repeatable, shared workflow. No copy-pasting. No drift between developers."

*Socratic:* "Why put this in a slash command instead of just writing the prompt in CLAUDE.md? What's the difference in behavior, and when would you choose each approach?"

*Coach:* "This is the power of slash commands — team-shared, version-controlled workflows. One developer writes `/generate-schema`, every developer gets exactly the same behavior. That's a force multiplier."

*Challenger:* "That slash command has a specific output format. What breaks if a new developer adds a field to the TypedDict manually and doesn't update the command? How does this create drift, and how would you prevent it?"

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "CLAUDE.md instruction vs. slash command — when would you use each? What's the deciding factor?"

After student answers, confirm or extend in persona voice, then continue.

**Testing the command:**

In Claude Code, type: `/generate-schema`

Claude executes the command file contents and generates the schema. Every invocation produces output consistent with the format — because the format instruction lives in the command, not in the developer's memory.

---

## Step 4 — Add a Subdirectory CLAUDE.md

The `scripts/` directory contains deployment and infrastructure scripts. These are higher-risk than application code — mistakes here affect production systems. The team wants stricter rules for this directory.

Create `meridian-analytics/scripts/CLAUDE.md`:

```markdown
# Scripts Directory — Elevated Caution Zone

You are in the `scripts/` directory. These are production deployment and
infrastructure scripts. The following rules apply here and override the
root-level configuration where they conflict:

## Elevated constraints

- ALWAYS use plan mode before modifying any file in this directory.
- Do not add, remove, or modify any script without stating what it does
  and what the impact of running it is.
- No new scripts without a corresponding `# Usage:` comment at the top.
- Never run scripts directly — only write or analyze them.

## Context

Scripts in this directory include:
- `deploy.sh` — production deployment pipeline (do not touch without approval)
- `migrate.sh` — database migration runner
- `cleanup.sh` — log rotation and temp file cleanup

These scripts run in production environments. Treat every change as potentially
irreversible without careful rollback planning.
```

> **Instructor — narrate the subdirectory override:**

*Practitioner:* "Now we have a two-level configuration. Root-level: project conventions and constraints. Scripts-level: additional rules that apply only here. When Claude Code is working in `scripts/`, it sees both — but the subdirectory rules take precedence when they conflict. The root said 'ask before modifying scripts.' The subdirectory says 'always use plan mode.' Plan mode is more specific — it wins."

*Socratic:* "The root CLAUDE.md already says 'never modify files in `scripts/` without explicit confirmation.' Why add a subdirectory CLAUDE.md? What does the subdirectory file add that the root-level constraint doesn't cover?"

*Coach:* "This is path-specific configuration in action! Notice that the subdirectory CLAUDE.md doesn't repeat the root-level conventions — those are inherited. It only adds what's different or elevated for this specific directory."

*Challenger:* "I said subdirectory rules 'override' root-level rules where they conflict. But they also compose. Give me an example of a case where both the root CLAUDE.md and the scripts CLAUDE.md would be active and neither conflicts — where both apply simultaneously."

---

## Step 5 — Observe the Hierarchy

With both files in place, let's see what Claude actually receives depending on where it's working.

**When Claude works in `src/pipeline/`:**

Active configuration:
- `~/.claude/CLAUDE.md` (if exists — personal layer)
- `meridian-analytics/CLAUDE.md` (root layer)

Claude knows: its role as data pipeline engineer, conventions, constraints. It does NOT have the elevated scripts rules.

**When Claude works in `scripts/`:**

Active configuration:
- `~/.claude/CLAUDE.md` (if exists — personal layer)
- `meridian-analytics/CLAUDE.md` (root layer)
- `meridian-analytics/scripts/CLAUDE.md` (subdirectory layer — takes precedence on conflicts)

Claude knows: everything from the root, PLUS the elevated caution rules, PLUS the scripts directory context.

> **Instructor — narrate the hierarchy observation:**

*Practitioner:* "This is why the hierarchy matters in production. A developer working in the application code and a developer working in the scripts directory get different Claude behaviors — from the same tool, in the same project. That's intentional. Configuration is context."

*Socratic:* "A developer opens Claude Code from the repo root and asks it to look at a file in `scripts/`. Which configuration is active? Why does the working directory of the request matter?"

*Coach:* "You can see the power here: one project, two different Claude behaviors, cleanly managed through file placement. The more complex your project, the more valuable this becomes."

*Challenger:* "A developer has a `~/.claude/CLAUDE.md` that says 'be concise, limit responses to 3 sentences.' In `scripts/`, Claude has to explain what a script does and its production impact — which requires more than 3 sentences. What happens? How would you resolve this conflict?"

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "You've now seen the full hierarchy. What's the most important thing to get right when designing CLAUDE.md files for a monorepo? What's the most common mistake?"

After student answers, confirm or extend in persona voice.

---

## Demo Debrief

You've watched a complete CLAUDE.md ecosystem get built. Let's map what you saw to Domain 3 exam concepts.

### What we built

| File | Level | Scope | Purpose |
|------|-------|-------|---------|
| `meridian-analytics/CLAUDE.md` | Repo root | Entire project | Role, conventions, constraints |
| `.claude/commands/generate-schema.md` | Project commands | Any developer in this project | Repeatable schema generation workflow |
| `meridian-analytics/scripts/CLAUDE.md` | Subdirectory | scripts/ only | Elevated caution rules for production scripts |

### Design decisions made visible

1. **Context before constraints** — We defined role and project context first, then conventions, then constraints. Claude needs to know what it is before it can apply rules consistently.

2. **Slash command vs. CLAUDE.md instruction** — `/generate-schema` is a slash command because it's an on-demand workflow, not a standing rule. Standing rules belong in CLAUDE.md; invocable workflows belong in commands.

3. **Subdirectory for elevated risk** — The `scripts/` CLAUDE.md exists because that directory has a different risk profile than the rest of the project. Path-specific rules are for when "different" needs to be enforced, not just documented.

4. **What we didn't put in CLAUDE.md** — The README, the full data dictionary, the deployment runbook. Those belong in documentation. CLAUDE.md is runtime instruction — every token in it costs context window on every session.

> **Instructor — closing in persona voice:**

*Practitioner:* "That's a real CLAUDE.md pattern. You can take that structure and apply it to any project. Role, conventions, constraints, path-specific escalation where risk demands it. The domain content has the exam concepts — this demo has the build pattern."

*Socratic:* "Looking at everything we built — what would you change? What did you notice that you'd do differently in your own project? What's one thing this CLAUDE.md doesn't cover that yours would need to?"

*Coach:* "You just watched a complete CLAUDE.md ecosystem get built from scratch. You understand the hierarchy, the slash command mechanism, and the path-specific pattern. That's the whole toolbox. Excellent work following along."

*Challenger:* "Final question before we close the demo: what breaks first in this configuration as the project grows? Pick one thing — the CLAUDE.md content, the slash command, or the path-specific rules — and tell me its specific failure mode at scale."
