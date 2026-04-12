# Domain 3 — Claude Code Configuration

**Exam weight: 20%**

---

## Opening Hook

> **Instructor — persona-voiced framing. Deliver this before touching any documentation.**

*Practitioner:* "You've been running inside a Claude Code configuration this entire course. That CLAUDE.md you loaded at session start — the one that knows your persona, reads your progress file, and greets you by name — that's not magic. It's a bootstrap script. This domain is about how it works and how to build your own."

*Socratic:* "Think about everything that happened when you started this session. Claude knew your persona. It knew where you left off. It knew what to say. Before I explain any of it — where do you think that information is coming from? What mechanism makes that possible?"

*Coach:* "Here's something exciting — you've already been using Claude Code configuration this whole time. The instructor personas, the progress tracking, the session flow — all of that is running on CLAUDE.md and the patterns you're about to learn. By the end of this domain, you'll understand exactly how your own course works."

*Challenger:* "You've spent multiple sessions inside a live Claude Code configuration without understanding what's driving it. That ends here. This domain covers 20% of the exam — and the teaching example is the course you're sitting in right now. Pay close attention."

---

## Exercise First: Before We Read Anything

**Do this before reading any documentation.**

Open the course `CLAUDE.md` at your repo root right now. Read it completely. Then answer these questions in writing:

1. What does Step 1 do, and what happens differently on first run vs. returning run?
2. What would break if you deleted the `.student_cca/student.md` template section?
3. What does "persona switching" actually do — where is the state stored?
4. The file creates two other files. What are they, and what do they contain?
5. What behavior is NOT in CLAUDE.md that you'd expect to find there? Why might it be missing?

> **Instructor note:** Do not explain anything until the student has written answers. This exercise surfaces misconceptions before concepts are introduced — which is exactly when they're most useful. A student who says "I don't know" is in a better position than one who skips this step.

After the student writes answers, confirm or correct in persona voice, then proceed.

---

## Directed Reading

Before the concept walkthrough, read these official Anthropic sources. The walkthrough will reference them directly.

- [Claude Code Overview](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Claude Code Configuration](https://docs.anthropic.com/en/docs/claude-code/configuration)
- [Claude Code Settings](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)

> **Instructor note:** Prompt the student to read with a specific question in mind: "While you read — look for anything that explains what you observed in the CLAUDE.md exercise. Annotate where the documentation maps to what you already read."

---

## Concept Walkthrough

### 1. The CLAUDE.md Hierarchy

Claude Code resolves CLAUDE.md files in a specific order. Understanding this order is required for the exam.

**Resolution order (precedence from highest to lowest):**

1. **Home directory** — `~/.claude/CLAUDE.md` — applies to every Claude Code session regardless of project
2. **Repo root** — `<project-root>/CLAUDE.md` — the primary project-level configuration you've been working with
3. **Subdirectory** — `<subdirectory>/CLAUDE.md` — applies only when Claude Code is operating in or below that directory

All three can be active simultaneously. They compose — they don't replace each other. If a home-level rule conflicts with a repo-level rule, the more specific (lower) level takes precedence.

**The course CLAUDE.md is a repo-root file.** It applies to every session started from this project root. If you had a `~/CLAUDE.md`, those instructions would also be active — silently layered in. That's a common source of unexpected behavior in production.

> **Knowledge Check:**
>
> A developer has a `~/.claude/CLAUDE.md` that says "always respond in formal English." The project's `CLAUDE.md` says "use casual language." Which wins?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The CCA exam tests whether you know that *more specific wins* — the repo-level instruction takes precedence over the home-level one. But both are active. The answer isn't "home wins" or "repo wins" — it's "they compose, more specific takes precedence on direct conflicts."

---

### 2. What Belongs in CLAUDE.md

CLAUDE.md is a system-level prompt prepended to every conversation in a project. It's not a README. It's not documentation. It's runtime instruction.

**What belongs:**
- **Conventions** — naming patterns, file structure rules, code style that Claude needs to follow
- **Constraints** — what Claude should not do (e.g., "never modify the `main` branch directly")
- **Bootstrap logic** — stateful initialization sequences like the course's "first-time vs. returning" check
- **Role definitions** — who Claude is in this context, what its job is
- **Critical context** — information about the codebase, team, or domain that would otherwise need to be re-established every session

**What doesn't belong:**
- **Full documentation** — CLAUDE.md is loaded into the context window every session; large files waste tokens on content rarely needed
- **One-time setup instructions** — if it only runs once, it doesn't need to be in every session's context
- **Information already in code** — CLAUDE.md should reference where to find things, not duplicate them
- **Secrets or credentials** — CLAUDE.md is committed to version control in most setups; treat it as public

**The course CLAUDE.md gets this right.** It's 74 lines. It contains bootstrap logic, persona definitions, and file templates. It doesn't contain course content, domain summaries, or documentation — those live in `domains/`. Every line in that file runs every session.

> **Knowledge Check:**
>
> A team's CLAUDE.md is 800 lines and contains the full architecture diagram, every API endpoint, and three pages of team norms. What are the two most significant problems with this approach?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The exam tests whether you can identify (1) context window cost — 800 lines is prepended to every session regardless of whether that context is needed, which crowds out working context and increases cost; and (2) maintenance burden — a stale 800-line CLAUDE.md is worse than no CLAUDE.md because it actively misleads Claude about the current state of the project.

---

### 3. Custom Slash Commands

Slash commands are reusable, invocable commands defined in your project. They're distinct from skills (more on that below).

**Creating a slash command:**

Create a markdown file in `.claude/commands/`:

```
.claude/
  commands/
    review-pr.md
    run-tests.md
    deploy-check.md
```

Each file contains the prompt or instruction that runs when the command is invoked. The file name becomes the command name: `/review-pr`, `/run-tests`, `/deploy-check`.

**Scoping:**
- `.claude/commands/` in your project root — project-scoped, committed to the repo, shared with your team
- `~/.claude/commands/` — personal commands, available in all your projects, not shared

**Invoking:**
Type `/command-name` in Claude Code. Claude executes the file's contents as a prompt.

**When to use slash commands vs. skills:**
- **Slash commands** — project-specific workflows (run this test suite, check this PR format, generate this type of file). They travel with the project.
- **Skills** — cross-project capabilities that need structured logic, references to other files, or complex behavior. Skills can reference other skills and contain executable reasoning patterns.

The course's persona switching (`switch to [persona_name] persona`) is defined in CLAUDE.md directly rather than as a slash command because it's a simple phrase-triggered behavior, not an invocable command. That's a design choice — it could have been `/switch-persona practitioner`.

---

### 4. Skills

Skills are reusable behavior packages invoked via the Skill tool. They extend Claude Code's capabilities beyond what's possible with a simple slash command.

**Key properties:**
- Skills can reference other files, including other skills
- Skills contain structured reasoning instructions
- Skills are invoked by the harness via the `Skill` tool
- Skills can carry preconditions, references, and multi-step logic

**In this course:** The `worktree-setup` skill, the `spec` skill, the `merge-worktrees` skill — these are all skills in the course environment. When an instructor invokes `/worktree-setup`, the harness loads that skill and executes its instructions.

**Exam pattern:** Know the distinction between a slash command (simple prompt file in `.claude/commands/`) and a skill (structured capability invoked via Skill tool). The exam tests whether you know which mechanism to use for which problem.

---

### 5. Path-Specific Rules

For monorepos or complex projects, you can scope configuration to specific directories by adding CLAUDE.md files at the subdirectory level.

**Example: monorepo structure**

```
project/
  CLAUDE.md                    ← applies everywhere
  frontend/
    CLAUDE.md                  ← applies only in frontend/ and below
  backend/
    CLAUDE.md                  ← applies only in backend/ and below
  infrastructure/
    CLAUDE.md                  ← applies only in infrastructure/ and below
```

When Claude Code is working in `frontend/`, it receives: home-level + root-level + frontend-level instructions. The backend CLAUDE.md is not loaded.

**This course uses path-specific rules in the lab.** You'll create a `exercises/CLAUDE.md` that applies only when Claude is working in the exercises directory.

> **Knowledge Check:**
>
> A monorepo has a root CLAUDE.md that says "all tests use Jest." The `backend/` subdirectory has a CLAUDE.md that says "all tests use pytest." A developer asks Claude to write tests for a file in `backend/`. Which test framework does Claude use?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The subdirectory-level CLAUDE.md is more specific and takes precedence for files within that directory. Claude writes pytest tests. The exam frequently uses monorepo scenarios to test whether you understand that specificity wins, not recency or file size.

---

### 6. Plan Mode

Plan mode changes how Claude Code operates before taking action. Instead of immediately executing, Claude presents a plan and waits for approval.

**When to use:**
- Destructive operations (deleting files, modifying a database, deploying to production)
- Ambiguous tasks where the implementation approach needs human review
- Multi-step operations where an early misstep is expensive to reverse
- Any context where you want to verify Claude's interpretation before it acts

**How it changes agent behavior:**
In plan mode, Claude produces a structured plan (what it intends to do, in what order, with what tools) before taking any action. The human reviews and approves, modifies, or rejects the plan. Only after approval does execution begin.

**Exam patterns:**
- Plan mode is a safety mechanism, not a performance mechanism — it slows execution deliberately
- The exam asks when plan mode is appropriate. The answer centers on reversibility: if the action is hard to undo, use plan mode.
- Plan mode doesn't prevent errors — it creates a review checkpoint before they happen

---

### 7. CI/CD Integration

Claude Code can run non-interactively, which enables CI/CD pipeline integration.

**The `--print` flag:**
```bash
claude --print "Run the test suite and report failures"
```

`--print` outputs Claude's response to stdout and exits. No interactive session. Usable in scripts, GitHub Actions, CI pipelines.

**Headless mode:**
Claude Code without a user interface, receiving input from stdin or flags, writing output to stdout. Used for automated review, automated code generation, automated testing.

**`--dangerously-skip-permissions`:**
In automated environments, Claude Code's permission prompts would block execution. `--dangerously-skip-permissions` bypasses them. This flag's name is intentional — it signals that this should only be used in controlled, sandboxed CI environments where the blast radius of an unexpected action is bounded.

**From the course's own launch script (`launch-worktrees.sh`):**
```bash
claude --dangerously-skip-permissions
```
The course uses this flag in its auto-launch mode. This is appropriate because the worktree environment is sandboxed and the course agents have well-defined, bounded tasks. It would not be appropriate for a general-purpose agent with access to production systems.

---

### 8. Permission Model

Claude Code operates with configurable permissions that determine what it can and cannot do.

**Default behavior:** Claude Code requests permission before running shell commands, modifying files outside the project, or taking actions with external side effects.

**Permission levels:**
- **Tool-by-tool** — Claude asks before each action
- **Session-wide approval** — "yes to all" for a category of actions during a session
- **`--dangerously-skip-permissions`** — bypass all prompts; appropriate only in controlled CI environments

**What Claude Code can do:**
- Read and write files (within approved scope)
- Run shell commands (with permission)
- Make network requests (with permission)
- Invoke tools registered in the session

**What Claude Code cannot do:**
- Override the model's core safety behaviors
- Access resources outside the approved scope without explicit permission grants
- Persist state across sessions without writing to files

**Design principle:** The permission model is a trust boundary. In interactive development, prompts give you oversight. In automated pipelines, `--dangerously-skip-permissions` shifts trust to the environment design — the pipeline itself must be the safety layer.

---

## Domain Checkpoint

> **Instructor:** Run this sequence at the end of Domain 3.

**Step 1 — Confidence assessment per topic**

Ask the student to rate each topic: High / Medium / Low

1. CLAUDE.md hierarchy (home vs. repo vs. subdirectory)
2. What belongs in CLAUDE.md
3. Custom slash commands — creating, scoping, invoking
4. Skills — what they are and when to use them
5. Path-specific rules for monorepos
6. Plan mode — when to use it
7. CI/CD integration — `--print` and headless mode
8. Permission model — `--dangerously-skip-permissions`

**Step 2 — Update `.student_cca/progress.md`**

Write the following to `.student_cca/progress.md`:

- Domain 3 row: **Status** → `Complete`
- Domain 3 row: **Confidence** → student's self-assessment (High / Medium / Low — use the lowest rating given if mixed)
- **Confusion Log** → add any topics rated Low or that the student flagged as unclear, with a one-line description of the specific confusion
- **Last session note:** → "Completed Domain 3 (Claude Code Configuration). [Student's lowest-confidence topic] flagged for review. [One sentence on what the student did well or the key insight from this session.]"

**Step 3 — Surface weak areas**

For any topic rated Low or Medium, tell the student:
- What specifically to re-read in the Anthropic documentation
- Which concept from the domain connects to that topic
- Whether Domain 4 or Domain 5 will revisit this (flag if so)

**Step 4 — Transition**

*Practitioner:* "Domain 3 done. You now understand the configuration layer your agentic systems run on. Domain 4 is prompt engineering — the instructions you put inside those systems. Open `domains/domain-4-prompt-engineering.md`."

*Socratic:* "Before we move on — what's one thing about CLAUDE.md or Claude Code configuration that you'd design differently if you were building this course from scratch? Hold that thought. Domain 4 will give you more tools to answer it. Open `domains/domain-4-prompt-engineering.md`."

*Coach:* "That's Domain 3 complete! You've gone from 'I don't know how CLAUDE.md works' to 'I understand the full configuration layer.' That's a significant move. Ready for Domain 4? Open `domains/domain-4-prompt-engineering.md`."

*Challenger:* "Domain 3. You've learned the mechanisms. Domain 4 is where we test whether you can use them. The prompt engineering domain will expose any gaps in your understanding of how instructions actually work. Open `domains/domain-4-prompt-engineering.md`."
