# Domain 5 — Context Management & Reliability

> **Instructor note:** This is the capstone domain. Students arrive here having completed all four prior domains. Frame everything through the lens of "you've built it — now let's talk about shipping it and keeping it running." Every concept in this domain connects back to something the student already knows. Make those connections explicit throughout.
>
> Exam weight: **15%**

---

## Opening Hook

> *Practitioner:* "You've built a coordinator. You've designed tools. You've configured Claude Code. You've engineered your prompts. Now here's the question nobody asks until 2am when the system is in production and something is silently failing: how do you know it's working? How do you know when it broke? And how do you make it recover without you?"
>
> *Socratic:* "You've completed four domains. Before we go any further — think about the system you've been building in your head throughout this course. What's the first thing that breaks when it runs for real, under real load, with real data? Don't give me a technical answer yet. Just: what worries you most?"
>
> *Coach:* "You've made it to the final domain — and this one is where everything comes together. Domain 5 isn't a separate topic. It's the layer that makes everything you've already learned actually work in production. Let's talk about reliability, context management, and how to build systems that don't require you to babysit them."
>
> *Challenger:* "You've built all the pieces. Here's the real question: would you bet your job on this system running correctly for 30 days without you touching it? If the answer is no — and for most first-pass agentic architectures, it is — that's what Domain 5 is about. Let's find out where your system would fail."

---

## Exercise First: Before We Read Anything

**Do this before reading any further.**

Here is a description of a multi-agent system a team just shipped to production:

---

**BuildOps Inc — Automated Infrastructure Audit System**

BuildOps Inc operates a multi-agent infrastructure auditing system. The coordinator receives audit requests and routes them to three specialized subagents:

- **Config Auditor** — scans infrastructure configs for policy compliance, returns findings as JSON
- **Cost Analyzer** — queries cloud spend APIs and returns a cost breakdown for the past 30 days
- **Security Scanner** — runs vulnerability checks across specified resources

The system is deployed with these characteristics:
- All three subagents run in parallel for every audit request
- Each subagent gets passed the full audit request plus the last 30 days of conversation history between the coordinator and the requesting engineer
- The coordinator waits for all three subagents to complete before synthesizing results
- If any subagent returns an error, the coordinator retries the whole audit from the start
- The system logs the final coordinator output to a file but does not log subagent outputs or intermediate states
- Audit requests are sometimes large: one engineering team submitted a 200-page infrastructure specification as part of the request

---

**Your task — answer all four questions before continuing:**

1. Where is this system at risk of context overflow? Be specific — which component, what causes it?
2. What happens operationally when an audit fails? What's wrong with the current failure handling?
3. If this system behaves incorrectly in production, how easy is it to diagnose? What's missing?
4. What would you change first, and why?

> **Take 5 minutes and write your answers before scrolling. This is not a trick question — there are multiple valid answers and the goal is to surface your current mental model before the domain teaches you the correct vocabulary.**

---

*After you've written your answers:*

> *Practitioner:* "Good. Keep those answers nearby — we'll come back to them at the end. You probably identified some real problems. The question is whether you have the vocabulary to fix them and the patterns to prevent them next time."
>
> *Socratic:* "What did you find? I want to hear your answer to question 1 before we go any further. What specifically is at risk of context overflow, and why?"
>
> *Coach:* "Write down your answers — even rough notes count. This exercise does something important: it activates your prior knowledge before new content arrives. Whatever you identified, right or wrong, you'll remember it better after the domain explains it. Nice work getting this far in the course."
>
> *Challenger:* "Four answers. All four. Vague answers don't count. If you wrote 'context is too big' for question 1, write it again — more specifically. Which component? What data causes the overflow? When does it happen?"

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "Before I explain the problems in that system: what's the most serious failure mode you identified, and what would you do first to fix it?"

---

## Directed Reading

Before the concept walkthrough, read the following official Anthropic documentation. These are the primary sources for Domain 5 CCA exam questions.

**Read in this order:**

1. **Context windows** — understand limits, what consumes tokens, cost of large contexts
   https://docs.anthropic.com/en/docs/build-with-claude/context-windows

2. **Prompt caching** — mechanics, what gets cached, cache invalidation, cost model
   https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching

3. **Building reliable pipelines** — retry patterns, fallbacks, degradation strategies
   https://docs.anthropic.com/en/docs/build-with-claude/agents#building-reliable-pipelines

4. **API errors** — error codes, what each means, what to retry vs. not
   https://docs.anthropic.com/en/api/errors

> **Instructor note:** These four URLs are the canonical source for Domain 5 exam questions. Students should have them open in a second window throughout this domain. If content on this page conflicts with official docs, the official docs are authoritative.

---

## Concept Walkthrough

### 1. Context Window Management

Every conversation with Claude has a context window — a hard limit on the total tokens it can process in a single request. This includes the system prompt, the full conversation history, any documents passed in, tool definitions, and the response Claude is generating.

The limit is not a performance guideline. It is a hard boundary. When you exceed it, the request fails.

**What consumes your context budget:**
- System prompt (often 500–2,000 tokens; more with detailed instructions)
- Conversation history (grows unbounded if you're not managing it)
- Documents and data passed as context (often the biggest consumer)
- Tool definitions (each tool schema costs tokens)
- The response itself (output tokens count against the context limit)

**The BuildOps problem:**

In the BuildOps system you analyzed, the Config Auditor receives "the last 30 days of conversation history" plus the audit request. An engineering team submitted a 200-page specification. That's roughly 100,000+ tokens of input — potentially exceeding the context limit before the subagent has generated a single token of output.

The system doesn't check for this. It doesn't fail gracefully. It just fails.

---

> **Knowledge Check:**
>
> A subagent is designed to process large infrastructure documents. On most requests it works fine. On requests from one specific team it always fails with a context length error. The coordinator logs the failure and retries. The retry also fails.
>
> **What is the correct fix, and why doesn't retrying help here?**
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The CCA exam tests whether you understand that context overflow is deterministic — the same oversized input will always fail. Retry logic solves transient failures (network issues, rate limits, model unavailability). It does not solve structural failures caused by design decisions. The correct fix is truncation, summarization, or chunking — not retry.

---

### 2. Conversation History Strategies

Context windows fill up. Conversation history is the main culprit in long-running agentic systems. Here are the three strategies and when each applies:

**Truncation — remove the oldest turns**

The simplest approach. Keep the N most recent turns and drop the rest. Fast, cheap, predictable.

*When it works:* Tasks where recent context is more relevant than early context. Short-to-medium conversations. Stateless subagents that don't need to remember early decisions.

*When it breaks:* Tasks where early decisions constrain later actions. Workflows where the initial instructions are critical and appear only once. Any scenario where "I told you this 50 turns ago" matters.

**Summarization — compress history into a summary**

Before passing history to a subagent (or at a checkpoint), compress old turns into a dense summary. The subagent receives the summary plus recent turns.

*When it works:* Long workflows where the history captures an evolving understanding. Coordinator-to-subagent handoffs where the subagent needs to understand prior reasoning but not every exchange.

*When it breaks:* When the summarization model misses important details. When you need exact prior outputs (a subagent's JSON response) rather than a summary of it. When the summary itself grows too large over time.

**Selective retention — keep only what matters**

Extract and preserve specific information from the conversation (decisions made, constraints established, facts confirmed) and discard the rest. More expensive to implement — requires you to identify what's worth keeping.

*When it works:* Long-running workflows with identifiable "anchor facts" that must persist. Coordinator patterns where you track a decision log rather than full history.

*When it breaks:* When you can't reliably identify what's important in advance. When important context is implicit in the conversation flow rather than explicit facts.

---

> **Knowledge Check:**
>
> A coordinator is running a multi-day infrastructure migration workflow. On day 1, the engineer said "do not modify the production database until we confirm the staging migration is successful." On day 7, the conversation history has grown to 85,000 tokens — approaching the limit. The team is considering using truncation to manage context.
>
> **What is the risk of using truncation here, and what should they use instead?**
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The CCA exam tests whether you can identify when historical context carries critical constraints. The day-1 instruction is a constraint, not just context. Truncation would silently remove it. The correct pattern is selective retention for critical constraints, plus summarization for background context. The exam often presents scenarios where one strategy seems obvious but has a subtle failure mode — read carefully.

---

### 3. Memory Patterns

Context window = what the agent knows right now. Memory = what the agent can retrieve when needed. These are not the same thing.

**In-context memory**

The agent knows it because it's in the active context window. Fast, zero-latency. Limited by context window size.

*Use when:* The information is needed for this request and the context budget allows it. Short sessions. Bounded tasks.

*Don't use when:* The information must persist across multiple sessions or requests. The information is large relative to your context budget. You're building a system that accumulates knowledge over time.

**External memory**

Information stored outside the context window — in a database, file, vector store, or knowledge graph. Retrieved by the agent when needed and injected into context at query time.

*Use when:* Information must persist across sessions. Your knowledge base is large (customer records, documentation libraries, accumulated findings). You need semantic search over past outputs.

*Don't use when:* Retrieval latency is unacceptable for your use case. The retrieved content frequently returns irrelevant results (retrieval quality problem). The overhead of managing retrieval exceeds the problem it's solving.

**The hybrid pattern**

Most production agentic systems use both. External memory stores the persistent knowledge base. In-context memory holds the retrieved subset plus the current working context. The coordinator decides what to retrieve and when.

This is what makes the BuildOps agent's design problematic: it passes all conversation history in-context instead of using selective retrieval. The system grows linearly more expensive (and eventually fails) as conversations extend — a problem that compounds over weeks in production.

---

### 4. Prompt Caching

Prompt caching is an optimization that saves and reuses a portion of your prompt across multiple requests. When you send the same prefix repeatedly (a large system prompt, a document library, few-shot examples), caching eliminates the cost of re-encoding that content on every request.

**How it works:**

You mark a portion of your prompt with a cache control breakpoint. Anthropic caches the KV state of that prefix. Subsequent requests that hit the same cached prefix pay a cache read cost (much lower than input token cost) instead of full processing cost.

**What can be cached:**
- Large system prompts
- Document libraries passed as context
- Long few-shot example sets
- Tool definitions that don't change between requests

**What cannot be cached:**
- Content that changes between requests (the user's actual query, dynamic data)
- Anything after the last cache breakpoint

**Cost model:**

Cache writes cost slightly more than normal input tokens (one-time cost). Cache reads cost significantly less than normal input tokens. If you have a 10,000-token system prompt used in 100 requests, the break-even point for caching is roughly the first few requests — after that, pure savings.

**Cache invalidation:**

The cache is invalidated when the prefix content changes. If you're inserting dynamic content (dates, request IDs, user-specific instructions) before your cacheable content, the cache will never hit. Structure your prompts: static content first, dynamic content last.

---

> **Knowledge Check:**
>
> An agentic system uses a 15,000-token system prompt containing detailed instructions, a policy library, and 20 few-shot examples. The system processes 500 requests per day. The current prompt structure is: `[15,000 token static content] + [user query] + [session-specific instructions]`. The team wants to add caching to reduce costs.
>
> **What change must they make to the prompt structure first, and what is the expected cost impact?**
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The CCA exam tests prompt structure knowledge as a prerequisite for caching. The session-specific instructions must be moved after the user query, or — if they precede the static content — the cache will never hit (cache only covers prefixes, not arbitrary segments). With correct structure: 500 requests/day × 15,000 tokens × (read rate vs. full input rate) = substantial daily cost reduction. The exam may ask you to identify the structural error before asking about cost impact.

---

### 5. Reliability Patterns

Agentic systems fail. The question is not whether — it's how you design for failure.

**Retries and exponential backoff**

Transient failures (rate limits, network timeouts, temporary model unavailability) should trigger retries. Non-transient failures (context overflow, invalid tool schemas, authentication failures) should not.

Standard pattern:
```
attempt 1 → fail → wait 1s → attempt 2 → fail → wait 2s → attempt 3 → fail → wait 4s → give up
```

*What to retry:* HTTP 429 (rate limit), HTTP 503 (service unavailable), network timeouts.
*What not to retry:* HTTP 400 (bad request — your input is wrong), HTTP 401 (auth failure), context length exceeded.

**The BuildOps mistake:** Retrying on all errors means a context overflow error (deterministic, structural) triggers a full audit restart — consuming more tokens, more API budget, and more time before failing in exactly the same way.

**Fallbacks and degradation**

Design for partial success. If the Cost Analyzer subagent times out, the coordinator should be able to return Config Auditor and Security Scanner results with a note that Cost Analysis is pending — not fail the entire audit.

Graceful degradation requires:
1. Independent subagent tasks (no subagent's result depends on another's)
2. Coordinator logic that handles partial results explicitly
3. Clear signaling to the end user about what was and wasn't completed

**Timeouts**

Every subagent invocation should have a timeout. Without it, a single slow subagent can hold up the entire coordinator indefinitely. Set timeouts based on task complexity with margin. Build coordinator logic that handles timeout responses the same way it handles explicit failures.

**Circuit breakers**

For production systems that call external tools or APIs repeatedly, implement circuit breakers: if a dependency fails N times in a row, stop calling it and return a known-failure response immediately. This prevents cascading failures where one slow upstream service blocks your entire agent fleet.

---

### 6. Testing Agentic Systems

Testing non-deterministic systems is genuinely hard. Here's the honest framework:

**Unit-level: tool functions are deterministic**

Test your tool implementations in isolation. A tool that queries a database, runs a script, or calls an API has deterministic behavior for deterministic inputs. These tests are standard — write them.

**Integration-level: test agent behavior on known inputs**

Create a set of representative test inputs with known-good outputs. Run your agent against them. Compare outputs for structural correctness (does the response have the expected fields? does the agent use the expected tools?) rather than exact string matching.

**Behavioral testing: test what matters, not what's literal**

For LLM outputs, test properties, not values:
- Does the agent call the correct tool for this input?
- Does the agent handle a tool error without crashing?
- Does the coordinator produce a synthesis that includes results from all subagents?
- Does the system degrade gracefully when one component fails?

**Regression testing: capture and replay**

Record production interactions (input, tool calls, outputs). Use them as regression fixtures. When you change your prompt or add tools, run the regression suite. You're not checking for identical outputs — you're checking that the agent's behavior on known inputs hasn't regressed in ways that matter.

**The non-determinism problem**

The same input may produce different outputs on different runs. Strategies:
- Run tests multiple times and check statistical properties (the agent does the right thing in at least 9/10 runs)
- Use temperature 0 for deterministic testing where you need exact comparisons
- Test at the behavior level (did the right tool get called?) rather than output level (was this the exact response string?)

---

### 7. Observability

You cannot debug what you cannot observe. Agentic systems have more failure surfaces than standard software: the LLM's reasoning, the tool execution, the coordinator logic, the context construction, and the subagent results — any of these can fail silently if you're not logging them.

**What to log in an agentic system:**

| What | Why |
|------|-----|
| Every tool call with its full input | Reproduce any failure by replaying the exact inputs |
| Every tool response (success and error) | Identify tool-level failures vs. agent reasoning failures |
| Context size at each request | Detect context growth trends before they cause failures |
| Every subagent invocation and result | Debug coordinator logic and identify subagent failures |
| Model used and version | Track behavior changes after model upgrades |
| Request latency per component | Find performance bottlenecks; identify timeout candidates |
| Cost per request | Budget management and anomaly detection |

**The BuildOps observability problem:**

The system only logs the final coordinator output. If a subagent returns an unexpected result, there's no log of what it received or what it returned. If the coordinator synthesizes incorrectly, there's no trace of the synthesis logic. Debugging requires reproducing the failure from scratch — which means re-running expensive API calls against a live system.

**Structured logging over free-text**

Log as structured data, not narrative strings. A structured log entry for a tool call should capture: timestamp, request ID, tool name, input parameters, output, latency, and error if any — as a JSON object or equivalent. This makes logs queryable and makes anomaly detection automatable.

**Distributed tracing for multi-agent systems**

In systems with parallel subagents, use trace IDs to correlate events across the coordinator and all subagents. When a coordinator request fails, you need to know which subagent failed and what it was doing — not just that the coordinator produced an error.

---

### 8. Production Considerations

**Rate limits**

Anthropic's API enforces rate limits on tokens per minute and requests per minute. Multi-agent systems that run subagents in parallel multiply your API consumption proportionally. A coordinator with 10 parallel subagents may burst into rate limit violations that a single-agent system never sees.

Design for this: implement exponential backoff for rate limit errors, stagger parallel invocations when possible, and monitor your API usage dashboard for consumption patterns.

**Cost management**

Agentic systems can spend unexpectedly. A coordinator that spawns 5 subagents per request at 10,000 tokens each costs 50,000 tokens per request — 50x more than a simple chat interaction. In production systems, instrument cost at the request level and set budget alerts.

Watch for: unnecessarily large context passed to subagents, recursive agents that spawn more agents than intended, retry logic that multiplies failed request costs, lack of caching on expensive repeated content.

**Model versioning**

Models are updated. When Anthropic releases a new Claude version, behavior may change even for identical prompts. Production systems should:
- Pin the model version (`claude-3-5-sonnet-20241022` vs. `claude-3-5-sonnet-latest`)
- Run regression tests when upgrading to a new version
- Maintain a rollback path to the previous version

**Graceful degradation under load**

Design your system to degrade, not fail, when under load:
- Return partial results with clear signaling rather than blocking on full completion
- Set per-request timeouts so slow requests don't block the queue
- Implement request queuing so traffic spikes don't drop requests
- Define which subagents are required for a useful result and which are optional enhancements

---

## Capstone Synthesis: Connecting All 5 Domains

This is Domain 5 — and it's also the capstone of the course. Here's how what you learned in each domain connects to reliability:

**Domain 1: Agentic Architecture → Reliability starts at the design level**

A coordinator that waits for all subagents before synthesizing is fragile — one failure blocks everything. The architectural pattern of independent subtasks with explicit failure handling isn't just an efficiency choice — it's what makes graceful degradation possible. You can't fix a brittle architecture with better retry logic.

**Domain 2: Tool Design → Poorly designed tools fail in non-obvious ways**

A tool that returns unstructured error messages makes it impossible for the coordinator to distinguish transient failures from structural ones. Tool schemas that allow ambiguous inputs produce inconsistent tool calls that are hard to log and replay. Reliable systems require tools designed with failure modes as first-class concerns.

**Domain 3: Claude Code → Configuration is your first line of defense**

CLAUDE.md is where you establish operating boundaries before a single agent runs. Hooks are where you add pre-request and post-request instrumentation without modifying agent code. Worktrees let you test reliability changes in isolation without risking production behavior. The Claude Code configuration layer is where reliability policy lives.

**Domain 4: Prompt Engineering → Prompts affect failure modes**

A vague task description produces inconsistent subagent behavior that's hard to test. Prompts that don't explicitly handle edge cases produce agents that invent behavior when the edge case arrives. The investment in precise prompt engineering you made in Domain 4 directly reduces the number of behavioral surprises you'll have to debug in production.

---

## Domain Checkpoint

**Instructions for Claude:**

Run the following checkpoint sequence with the student now. Do not skip steps.

**Step 1 — Confidence check per topic**

Ask the student to rate their confidence on each of the 8 core topics:
- Context window management
- Conversation history strategies
- Memory patterns (in-context vs. external)
- Prompt caching
- Reliability patterns (retries, fallbacks, timeouts)
- Testing agentic systems
- Observability
- Production considerations (rate limits, cost, versioning)

For each topic, collect: **High / Medium / Low**

**Step 2 — Update `.student_cca/progress.md`**

Write the following to the Domain 5 row:
- `Status` → `Complete`
- `Confidence` → student's overall self-assessment (summarize the per-topic ratings — if majority High, mark High; any Low, surface it)

**Step 3 — Confusion Log**

Ask: "Is there anything from Domain 5 that felt unclear or that you want to flag for review before the exam?"

Append any flagged items to the `## Confusion Log` section of `.student_cca/progress.md`.

**Step 4 — Last session note**

Write to `Last session note:` in `.student_cca/progress.md`:
> "Completed Domain 5 (Context & Reliability). Capstone domain. [Brief summary of student's confidence pattern and any flagged confusion.]"

**Step 5 — Check all 5 domains**

Read the full domain table in `.student_cca/progress.md`. Check the Status column for all five domains.

*If all 5 domains show Status = `Complete`:*

> "All 5 domains are now complete. You've covered the full CCA Foundations curriculum: Agentic Architecture, Tool Design, Claude Code, Prompt Engineering, and Context & Reliability. Ready to generate your readiness report? Say **'generate my readiness report'** when you are."

When the student requests the readiness report:
1. Read `.student_cca/progress.md` in full
2. Check if `reports/readiness-report-template.md` exists — if so, use that template
3. If no template exists, generate a structured readiness report with:
   - Per-domain confidence summary
   - Top 3 flagged confusion areas from the Confusion Log
   - Exam weight-adjusted readiness assessment (weight high-confidence domains by their exam percentage)
   - Recommended focus areas before sitting the exam
   - Final readiness recommendation: **Ready / Review Recommended / Not Yet Ready**

*If any domains are not yet complete:*

> "Domain 5 is complete. Remaining domains: [list incomplete domains with their exam weights]. Consider completing those before generating your readiness report — the report is most useful with full-course data."

**Step 6 — Surface weak areas**

Across the full Confusion Log (all domains), identify any recurring themes or high-weight domains with Low confidence. Flag these explicitly:

> "Before you wrap up: [Domain X] carries [Y]% of the exam and your Confusion Log has entries on [topic]. That's worth a second pass before exam day."

---

## Returning to the Opening Exercise

Go back to the four answers you wrote before the domain walkthrough. For each answer:

1. Was your identification of the context overflow risk correct? Did you name the specific component and the specific data that causes it?
2. Did you identify the retry problem (retrying structural failures) or only the symptom?
3. Did you identify the observability gap — or just the missing logs?
4. Was your "fix first" answer the right one given what you now know?

> *Practitioner:* "If your answers were mostly right, that's a good sign — you had the right instincts, and this domain gave you the vocabulary to implement them. If you missed some, that's also exactly what this exercise is for: now you know specifically what to revisit."
>
> *Socratic:* "What did you get right that surprised you? What did you miss that you wish you'd caught? Both are useful data."
>
> *Coach:* "Comparing your pre-domain answers to your post-domain understanding is one of the best ways to see how much you just learned. Don't skip this step — it's worth a few minutes."
>
> *Challenger:* "Were your answers specific enough? 'Context is too big' is not the same as 'the Config Auditor receives 100,000+ tokens of conversation history plus a 200-page specification, exceeding the context limit.' Specificity is what the exam rewards."
