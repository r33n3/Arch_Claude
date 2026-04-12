# Decision Frameworks — CCA Exam Quick Reference

> Format: **If the exam question asks X → the answer is Y**
> Use this file for rapid lookup during exam prep. Not designed for top-to-bottom reading.

---

## Domain 1 — Agentic Architecture
> See `domains/domain-1-agentic-architecture.md` for full concept walkthrough (27% exam weight)

| If the exam question asks… | The answer is… |
|---|---|
| When to use agents vs. a single model call | Use agents when the task requires sequential decisions with unknown steps, tool use across multiple steps, or branching logic that can't be predetermined. Use a single call when the task is bounded, the output structure is fixed, and no environmental feedback loop is needed. |
| When to use subagents vs. tools | Use **subagents** when a subtask requires its own reasoning loop, has distinct scope boundaries, or could run in parallel with other subtasks. Use **tools** when an action is deterministic, atomic, and doesn't require the model to reason about intermediate results. |
| Which orchestration pattern to use: coordinator/worker vs. pipeline vs. fan-out | **Coordinator/worker** → when the coordinator must reason about which workers to invoke and synthesize heterogeneous outputs. **Pipeline** → when each stage transforms the output of the previous stage (linear dependency). **Fan-out** → when the same task is parallelized across many inputs with identical processing. |
| How to identify parallel-safe vs. sequential subtasks | A subtask is **parallel-safe** if its inputs don't depend on the output of any other subtask running in the same batch. A subtask is **sequential** if it requires a prior subtask's result as its input. Mark dependencies explicitly before decomposing. |
| What to do when a subagent fails | Return a structured error result to the coordinator (don't throw silently). The coordinator decides: retry the subtask, skip and proceed, escalate to the user, or abort. Never assume subagents always succeed — missing failure handling is the most exam-tested anti-pattern in Domain 1. |
| When NOT to use agents | Single-step tasks, tasks with fully deterministic outputs, tasks where latency is critical and no feedback loop is needed, tasks where auditability requires a single traceable prompt. |

---

## Domain 2 — Tool Design
> See `domains/domain-2-tool-design.md` for full concept walkthrough (18% exam weight)

| If the exam question asks… | The answer is… |
|---|---|
| When to use `tool_choice: auto` | Default choice. Use when the model should decide whether a tool is needed. Correct for most production use cases. |
| When to use `tool_choice: any` | Use when you want to guarantee the model calls *some* tool (any of the provided tools), but you don't care which one. Useful when any tool response is preferable to a plain text response. |
| When to use `tool_choice: tool` (specific tool) | Use when you must force the model to call a specific tool — e.g., a structured output step where a particular schema is always required. Use sparingly; removes model judgment. |
| When to use built-in tools vs. custom tools vs. MCP | **Built-in tools** (web search, code execution) → when the capability is standard and already supported. **Custom tools** → when you have proprietary data, APIs, or actions specific to your system. **MCP** → when you want to expose tools to multiple agents/clients via a shared protocol without duplicating tool definitions. |
| How to structure a recoverable error response from a tool | Return a structured error object — include an error code, a human-readable message, and a `recoverable: true/false` flag. Do not throw an exception that halts the agentic loop. The model must receive the error as a tool result it can reason about. |
| When tool descriptions change model behavior (and when they don't) | Descriptions **do** change behavior: they influence when the model calls the tool, what values it passes, and how it interprets results. Descriptions **don't** change behavior: when the tool is never invoked (model ignores it), or when `tool_choice` forces a specific tool regardless of description. |
| What makes a tool description reliable | Explicit: what the tool does, when to call it, what values are valid for each parameter (enums, ranges, formats), constraints on when NOT to call it, expected output format. See Domain 2 Version A vs. Version B exercise. |

---

## Domain 3 — Claude Code
> See `domains/domain-3-claude-code.md` for full concept walkthrough (20% exam weight)

| If the exam question asks… | The answer is… |
|---|---|
| CLAUDE.md hierarchy conflict resolution | **More specific wins.** Subdirectory CLAUDE.md overrides repo-root CLAUDE.md on direct conflicts. Repo-root overrides home-directory (`~/.claude/CLAUDE.md`) on direct conflicts. All active files compose — they don't replace each other. |
| What belongs in CLAUDE.md | Runtime instructions: persona, session flow, what to load on startup, how to behave. NOT lesson content, NOT documentation, NOT static reference material. CLAUDE.md is a system-prompt prepended to every conversation — write it accordingly. |
| What belongs in a slash command vs. a skill vs. CLAUDE.md | **CLAUDE.md** → always-on session behavior. **Slash command** → on-demand, user-invoked, single-purpose. **Skill** → reusable, parameterized, composable task that may span multiple steps. Use a skill when the same multi-step pattern recurs across projects. |
| When to use plan mode | Before making changes to complex systems, before executing irreversible actions, when the task scope is unclear, or when the user needs to review and approve an approach before execution begins. |
| `--print` vs. interactive mode in CI/CD | Use `--print` for automation, CI pipelines, and scripted tasks where no human interaction is expected. Use interactive mode for human-in-the-loop sessions. `--print` exits after one response; interactive mode waits for follow-up. |
| When to use `--dangerously-skip-permissions` | Only in fully automated, sandboxed environments where you have reviewed all potential actions and accepted the risk. Never on a developer workstation or on systems with production access. Understand what permissions are being skipped before using this flag. |

---

## Domain 4 — Prompt Engineering
> See `domains/domain-4-prompt-engineering.md` for full concept walkthrough (20% exam weight)

| If the exam question asks… | The answer is… |
|---|---|
| When vague criteria vs. explicit criteria matter | Explicit criteria matter whenever the output will be parsed, fed to another system, reviewed at scale, or used without human review. Vague criteria are acceptable only for one-off, human-reviewed tasks. On the exam: if the scenario involves automation or downstream processing, explicit criteria are required. |
| How many few-shot examples to use | 3–5 examples covers most cases. Quality matters more than quantity: examples must cover the distribution of expected inputs, not just the easy case. Add more examples when the output structure is unusual or when edge cases are likely. Never use one example and expect coverage. |
| What quality threshold for few-shot examples | Each example must be a correct, representative input-output pair. Do NOT include examples that are edge cases if your use case is mostly typical inputs. Do NOT include examples that are subtly wrong — the model will learn the error. See Domain 4 checkpoint: "few-shot without coverage" anti-pattern. |
| Batch API vs. streaming — when to use each | **Batch API** → high-volume, latency-insensitive tasks (overnight processing, bulk classification, dataset labeling). Up to 50% cost reduction. **Streaming** → real-time, user-facing tasks where incremental output improves UX. Not useful for downstream processing that needs the complete response. |
| When to add a validation (reviewer) pass | When first-pass output quality is variable, when the task is high-stakes, when output feeds into automated downstream systems, or when the cost of a bad output exceeds the cost of a second model call. A reviewer pass catches structural errors, hallucinations, and constraint violations. |
| Prompt injection defense patterns | Never trust tool results unconditionally. Treat external data (web content, user-supplied documents, API responses) as potentially hostile. Validate tool outputs against expected schema before processing. Use explicit delimiters to separate instructions from data. Never echo tool output directly back into a prompt without sanitization. |

---

## Domain 5 — Context & Reliability
> See `domains/domain-5-context-reliability.md` for full concept walkthrough (15% exam weight)

| If the exam question asks… | The answer is… |
|---|---|
| Context truncation vs. summarization vs. selective retention | **Truncation** → drop oldest messages; simple but loses history without warning; use only for stateless tasks. **Summarization** → compress prior conversation into a rolling summary; preserves key decisions and state; use for long-running agents. **Selective retention** → keep only messages relevant to current task; requires classification; use when conversation mixes topics. |
| In-context memory vs. external memory — when to use each | **In-context** → use for short-lived sessions where all needed information fits within the context window and latency is critical. **External memory** (vector store, database) → use when information persists across sessions, exceeds context limits, must be retrieved selectively, or must be shared across agents. |
| When to use prompt caching | When the same large prompt prefix (system prompt, few-shot examples, large document) is reused across many requests. Prompt caching reduces latency and cost on repeated prompts. Not useful for single-use prompts or prompts that change significantly per request. |
| Retry: transient vs. structural errors | **Retry** → transient errors: 429 (rate limit), 500/503 (server error), network timeouts. Use exponential backoff with jitter. **Do NOT retry** → structural errors: 400 (bad request), 401 (auth failure), 422 (schema violation). Retrying structural errors wastes resources and will never succeed — fix the request first. |
| Testing: unit vs. integration vs. behavioral for agentic systems | **Unit** → test individual tools and prompt templates in isolation. **Integration** → test subagent + tool combinations with real or realistic responses. **Behavioral** → test the full agentic loop against a scenario; verify the outcome, not just the mechanism. Agentic systems require all three; skipping behavioral testing is the most common gap. |
| What context should a subagent receive | The minimum required to complete its task. Never pass full conversation history to a subagent — pass only the relevant subtask, required parameters, and any output schema. Context leakage (too-broad scope) causes unpredictable behavior and increases token cost. |
