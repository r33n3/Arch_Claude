# Domain 1 — Agentic Architecture & Orchestration

> **Exam weight: 27%** — This is the highest-weighted domain. Budget your time accordingly.
>
> **Instructor note:** Students arrive here directly from the opening exercise. They have already observed a live coordinator + subagents system execute. This domain takes what they observed and builds the conceptual framework beneath it. Start in the student's current persona voice. If no persona has been selected, default to The Practitioner and prompt the student to confirm.

---

## Opening Hook

> *Practitioner:* "You've already run a coordinator + subagents system. Now let's understand exactly what happened — at a level that holds up under exam pressure and in production deployments."
>
> *Socratic:* "You watched a coordinator decompose a task, delegate to subagents, and synthesize results. Before we name any of the concepts — what did the coordinator actually *know* that the subagents didn't? What was the information asymmetry in that system?"
>
> *Coach:* "You ran your first live agentic system in the opening exercise. That was a real accomplishment — and you now have an experience to anchor everything in Domain 1 to. Let's build on what you already saw and make sure it all clicks."
>
> *Challenger:* "You've seen the happy path. The opening exercise was designed to work cleanly. Domain 1 is mostly about what happens when it doesn't. What's the first assumption that system made that wouldn't hold in a real deployment?"

---

## Exercise First: Before We Read Anything

**Do this before reading any concept explanations.**

**The BuildOps Inc scenario:**

BuildOps Inc is a construction project management platform. Their product team needs an automated weekly status report for all active projects. The report must: (1) summarize each project's current status — on-track, at-risk, or delayed — based on recent activity; (2) flag any projects with overdue milestones; (3) identify resource conflicts where the same contractor is double-booked across projects; (4) produce a single executive summary with recommended actions.

**Your task (do this now, before scrolling):**

On paper or in your editor, answer these three questions:

1. Break this task into subtasks. How many subagents would you use? What would each one do?
2. For each subtask you identified — is it parallel-safe, or does it depend on another subtask completing first? Mark each one.
3. What context does each subagent need? Write the minimum required context for one of your subagents.

Write your answers now. You'll compare them against how Claude would decompose this task later in this domain.

> **Instructor — wait here if student is working. Do not continue to the next section until they have made an attempt.**

> *Practitioner:* "Take five minutes. The quality of your decomposition attempt tells us exactly where to focus in this domain."
>
> *Socratic:* "I'll wait. No answer is wrong at this stage — but the attempt is not optional. It will reveal something about your current mental model that we need to work with."
>
> *Coach:* "Take your time with this! There's no wrong answer here. I want to see your thinking, not the right answer. What you write down now tells us what's already solid and what we'll build on."
>
> *Challenger:* "Write down your answers before reading further. If you scroll past this without attempting it, you've already told me something about how you approach hard problems under exam conditions. The exam doesn't let you skip the reasoning."

---

## Directed Reading

Before the concept walkthrough, read the official Anthropic documentation on agents and agentic systems. These links go directly to the primary sources. Do not use paraphrased summaries — read the originals.

**Required reading:**

- **Agentic systems overview:** [https://docs.anthropic.com/en/docs/build-with-claude/agents](https://docs.anthropic.com/en/docs/build-with-claude/agents)
  Read in full. This defines the foundational pattern: what an agent is, what it does, and how orchestration works.

- **Tool use:** [https://docs.anthropic.com/en/docs/agents-and-tools/tool-use](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use)
  Focus on: how tools are invoked, how results are returned, and the role of tools in the agentic loop. The Task tool pattern you saw in the opening exercise is a specific application of this model.

- **Computer use (for agentic context):** [https://docs.anthropic.com/en/docs/agents-and-tools/computer-use](https://docs.anthropic.com/en/docs/agents-and-tools/computer-use)
  Skim this — it is primarily included to show you the outer boundary of what agentic systems can do. The computer-use pattern illustrates extreme agentic autonomy. Useful context for exam questions about agent scope.

> **Instructor:** After reading, ask the student: "What's one thing from the Anthropic docs that you either didn't expect or that you want to dig into further?" Use their answer to calibrate emphasis in the concept walkthrough below.

---

## Concept Walkthrough

### 1. The Agentic Loop

The agentic loop is the fundamental operating cycle of any agent. Understanding it is a prerequisite for everything else in Domain 1.

**The cycle: Perceive → Think → Act → Observe → (repeat)**

- **Perceive** — The agent receives input: a task, a tool result, a user message, or environmental state.
- **Think** — The agent reasons about its current state and decides what to do next. In Claude, this is the model's generation step.
- **Act** — The agent executes an action: calls a tool, invokes a subagent, writes a file, sends an API call.
- **Observe** — The agent receives the result of its action and updates its understanding of the world.
- **Repeat** — Until the task is complete or an exit condition is reached.

**In the BuildOps Inc scenario:**

The coordinator agent's loop looked like this:
1. *Perceive:* Receives the project status reporting task
2. *Think:* Decides the task requires parallel data gathering before synthesis is possible
3. *Act:* Invokes subagents via the Task tool
4. *Observe:* Receives subagent results
5. *Think:* Assesses whether results are complete and consistent
6. *Act:* Synthesizes the executive summary
7. *Observe:* Confirms the deliverable is complete

**How agents maintain state across turns:**

Agents do not have persistent memory between separate sessions by default. Within a session, state is maintained through the context window — the accumulating conversation history that the model can reference. In multi-agent systems, state is passed *explicitly* through tool call results, file writes, or structured handoffs. State does not flow automatically between isolated agents.

> **Knowledge Check 1:**
>
> **Knowledge Check:** An agent is running a multi-step research task. After three tool calls, the agent decides it needs to revise its initial plan because a source turned out to be unavailable. Which step of the agentic loop does this "plan revision" happen in?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** The CCA exam tests whether you understand that agents re-enter the *Think* step after every *Observe*. "Plan revision" isn't a separate step — it's the agent re-evaluating in the Think phase after observing an unexpected result. Exam questions often describe agent behavior and ask you to identify the loop step. Watch for questions that conflate "observe" and "think."

---

### 2. The Coordinator's 4 Jobs

A coordinator is not a router. It is not just a task dispatcher. It has four distinct responsibilities, and the CCA exam will test each one separately.

**Job 1: Decompose**

The coordinator breaks the incoming task into bounded subtasks. A well-formed subtask has three properties:
- **Bounded scope** — the subagent can complete it using only the information given to it
- **Parallel-safe** (when applicable) — the output doesn't depend on another subtask's output
- **Explicitly scoped** — the coordinator has defined what is and is not included

Decomposition failures are the most common source of agentic system errors. Over-decomposition creates coordination overhead. Under-decomposition creates subagents that do too much and fail at synthesis time.

**Job 2: Delegate**

The coordinator assigns each subtask to a subagent with explicit instructions. Delegation is not just "sending the task." The coordinator controls:
- What context the subagent receives
- What scope the subagent is authorized to operate within
- What format the subagent should return results in
- What the subagent should *not* do (scope constraints prevent scope drift)

The coordinator also decides how many subagents to spawn and whether they run in parallel or in sequence.

**Job 3: Synthesize**

The coordinator receives all subagent results and produces the integrated output. This step requires the coordinator to have visibility across all results simultaneously — which is why the coordinator maintains the full context while subagents each work in isolation.

Synthesis failures happen when: results are in incompatible formats, subagents made conflicting assumptions, or the coordinator's synthesis prompt is too vague to handle edge cases in the returned data.

**Job 4: Decide**

The coordinator handles the exception cases: incomplete results, subagent failures, conflicting outputs, results that require judgment to reconcile. The decide step is where most coordinator implementations fail in production.

The coordinator must be designed to answer: "What do I do if a subagent returns nothing? Returns an error? Returns something inconsistent with the other subagents' outputs?"

> **Knowledge Check 2:**
>
> **Knowledge Check:** A coordinator spawns three subagents in parallel. One returns clean results. One returns partial results with a warning. One fails entirely and returns an error. The coordinator then synthesizes the executive report. What is the coordinator's *primary* failure point in this scenario?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** This tests Job 4 — Decide. The coordinator's failure point is the *decide* step: it must handle the incomplete and failed subagent outputs before synthesis. If the coordinator synthesizes without addressing the failure and partial result, it produces a report that silently omits critical data. The exam often presents scenarios where the coordinator "completes" a task but produces degraded or incomplete output — the question is: at which step did the coordinator fail to apply appropriate judgment?

---

### 3. Subagent Invocation

In Claude Code, subagents are invoked via the **Task tool**. Each Task invocation:

- Creates a **new, isolated agent context** — the subagent has its own context window
- Receives **only the task description** the coordinator provides — nothing else from the coordinator's context leaks in automatically
- Has **no access to the coordinator's state** or to other subagents' state
- **Returns a result** to the coordinator when it completes

**When to use subagents:**

- The task has clearly bounded, parallelizable subtasks
- The subtasks are complex enough to benefit from focused, isolated reasoning
- The coordinator can synthesize the results into a coherent output
- The work would otherwise exceed a single context window, or benefits from parallel execution

**When NOT to use subagents:**

This is a key exam trap. Simple, linear tasks do not benefit from multi-agent orchestration. Adding subagents to a simple task introduces:
- Coordination overhead (decompose, delegate, synthesize all require tokens and reasoning)
- Failure surface (each additional agent is a new failure point)
- Context isolation costs (information that should be shared must be explicitly passed)

**Examples of tasks that do NOT warrant subagent invocation:**
- Summarizing a single document
- Answering a factual question with a known source
- Executing a linear sequence of deterministic operations
- Any task where the coordinator would do more work coordinating than the subagents do working

**The isolation property:**

Subagent isolation is a design choice with specific tradeoffs. Isolation means:
- Subagents cannot interfere with each other's state (a benefit for reliability)
- Subagents cannot share information with each other directly (a coordination constraint)
- Each subagent's failures are contained and independently recoverable (a benefit for error handling)
- Context that both subagents need must be explicitly included in both task descriptions (a cost in tokens and prompt design effort)

---

### 4. Task Decomposition

The BuildOps Inc project status reporting task from the opening exercise — let's decompose it now and compare it to what you wrote earlier.

**A well-formed decomposition for BuildOps Inc:**

- **Subagent A — Project Status Collector:** Read all project activity logs for the past 7 days. For each project, determine status (on-track, at-risk, delayed) based on milestone progress and recent activity. Return a structured status record per project. *Parallel-safe: does not depend on other agents.*

- **Subagent B — Milestone Auditor:** Read all project milestone records. Identify milestones with due dates in the past 14 days that have not been marked complete. Return a list of overdue milestones with project references and days-overdue. *Parallel-safe: does not depend on other agents.*

- **Subagent C — Resource Conflict Detector:** Read all resource allocation records for active projects. Identify instances where the same contractor is assigned to two projects on overlapping dates. Return a list of conflicts with contractor, projects, and conflicting dates. *Parallel-safe: does not depend on other agents.*

- **Coordinator (synthesis step):** Receive results from all three subagents. Cross-reference project status with overdue milestones (projects with overdue milestones should be flagged at-risk or delayed). Cross-reference resource conflicts with project status (conflicts affect at-risk projects more severely). Produce the executive summary with recommended actions.

**Parallel-safe vs sequential:**

All three subagent tasks are parallel-safe — none depends on the other's output. The synthesis step is sequential: it must wait for all three before it can run. This is the fan-out/fan-in pattern (covered in Orchestration Patterns below).

**Identifying parallel vs sequential at design time:**

Ask: "Does this subtask need the output of any other subtask to begin?" If no: parallel-safe. If yes: sequential, and the dependent subtask cannot begin until its predecessor completes.

In the BuildOps example: the coordinator could not detect that an at-risk project also has a contractor conflict without first having both the project status and the conflict detection results. The synthesis step correctly depends on both.

> **Knowledge Check 3:**
>
> **Knowledge Check:** You are designing a coordinator that must: (1) retrieve customer data from a CRM, (2) analyze the customer's purchase history for patterns, (3) generate personalized product recommendations based on those patterns, and (4) format the recommendations into an email. Which steps are parallel-safe and which are sequential?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** None of these steps are parallel-safe with respect to each other. This is a linear pipeline: each step depends on the previous step's output. Step 1 must complete before Step 2 can begin; Step 2 before Step 3; Step 3 before Step 4. The CCA exam frequently presents decomposition scenarios and asks whether steps are parallel-safe — the correct answer requires tracing the data dependencies, not just whether the tasks "seem independent." A task is only parallel-safe if it has zero data dependencies on the output of concurrent tasks.

---

### 5. Context Boundaries

This is one of the most testable concepts in Domain 1. Context boundaries define what a subagent knows and doesn't know.

**What subagents inherit:**

When a coordinator invokes a subagent via the Task tool, the subagent receives:
- The task description provided in the Task tool call
- Any data or documents explicitly included in that task description
- Its own system prompt (if the invocation includes one)

**What subagents do NOT inherit:**

- The coordinator's conversation history
- The coordinator's system prompt (unless explicitly duplicated in the task description)
- Any data that other subagents have produced
- Any state the coordinator has accumulated before the invocation

**Why this matters:**

The coordinator is the *sole* information integrator. It is the only entity in the system with visibility across all subagents' work. This means:
- The coordinator bears full responsibility for providing each subagent with the context it needs
- If a subagent needs a piece of information, the coordinator must include it explicitly in the task description
- Subagents cannot "figure out" what the coordinator knows — they only have what they were given

**Designing for context boundaries:**

When writing subagent task descriptions, the coordinator must include:
1. **Role definition** — What kind of agent is this? What domain knowledge should it bring?
2. **Deliverable specification** — What exactly should it produce, and in what format?
3. **Scope constraints** — What should it *not* do? What is explicitly out of scope?
4. **Parallel context** — If relevant, note what other subagents are doing so this subagent doesn't attempt to cover that ground
5. **Necessary data** — Any data, documents, or context the subagent needs to complete its work

The FinClearance Corp task descriptions in the opening exercise demonstrated all five of these properties. Refer back to them as a reference implementation.

---

### 6. Orchestration Patterns

Three primary orchestration patterns appear on the CCA exam:

**Pattern 1: Coordinator/Worker**

The foundational pattern. A coordinator receives a task, delegates to one or more workers (subagents), and synthesizes results. The coordinator makes all routing decisions. Workers are stateless and isolated.

*When to use:* Tasks that can be decomposed into bounded, independently executable subtasks.

*BuildOps Inc* used coordinator/worker: one coordinator, three parallel workers, one synthesis step.

**Pattern 2: Pipeline**

A linear chain where the output of one agent becomes the input to the next. No parallel execution — each agent waits for the previous agent's output.

*When to use:* Tasks where each step transforms the data and the next step depends on the previous step's output. The customer CRM example from Knowledge Check 3 is a pipeline: retrieve → analyze → recommend → format.

*Exam trap:* Students often default to pipeline thinking when coordinator/worker would be more efficient. The pipeline adds latency proportional to the number of steps; coordinator/worker's latency is dominated by the slowest parallel task.

**Pattern 3: Fan-out / Fan-in**

The coordinator fans out to multiple parallel subagents (fan-out), then collects and integrates all results (fan-in). This is coordinator/worker with an emphasis on parallelism.

*When to use:* Tasks where the same type of analysis needs to be run across multiple data sources, documents, or entities simultaneously. The FinClearance Corp compliance analysis (terminology mapping + gap analysis running in parallel) was a fan-out/fan-in pattern.

*Latency property:* Fan-out/fan-in completes in the time of the *slowest* subagent, not the sum of all subagents. This is the key advantage over pipeline for parallelizable work.

**Choosing the right pattern:**

| Scenario | Pattern |
|----------|---------|
| Three independent analyses of the same dataset | Fan-out / Fan-in |
| Fetch data → transform → generate report | Pipeline |
| One complex task split into multiple specialized agents | Coordinator / Worker |
| Multiple datasets that each need independent processing before merging | Fan-out / Fan-in |
| Analysis that must build sequentially on prior step results | Pipeline |

---

### 7. When NOT to Use Agents

This is the most common exam trap in Domain 1. The CCA exam will present scenarios where students are tempted to add orchestration, and the correct answer is to *not use multi-agent architecture*.

**The overhead cost:**

Every multi-agent system adds coordination overhead:
- The coordinator must reason through decomposition (tokens, latency)
- Subagent invocations require Task tool calls (latency, potential API cost)
- Context must be explicitly packaged for each subagent (tokens, prompt engineering effort)
- Results must be synthesized (tokens, potential for synthesis errors)

This overhead is worthwhile when the benefits (parallelism, scope isolation, context window management) outweigh the costs. It is *not* worthwhile when the task is simple enough that a single agent can complete it in one pass.

**Red flags that suggest you don't need agents:**

- The task can be completed in a single, direct response
- There are no parallelizable subtasks — the work is linear and fast
- The data is small enough to fit in one context window
- Adding subagents would require the coordinator to do more work than the subagents
- The subtasks are so interdependent that subagents would need to communicate constantly (which requires explicit handoffs through the coordinator — a pipeline, not parallelism)

**Exam pattern:** Watch for questions that describe an "orchestration system" with many agents doing simple, fast tasks. The correct answer is often: this system is over-engineered. The subagents should be consolidated into a single agent or eliminated in favor of a direct tool call.

---

### 8. Error Handling in Multi-Agent Systems

Distributed systems fail in ways that single-agent systems don't. Domain 1 tests your understanding of the failure modes specific to multi-agent coordination.

**Categories of subagent failure:**

1. **Hard failure** — The subagent returns an error or does not complete. The coordinator receives no usable output.
2. **Partial failure** — The subagent completes but returns incomplete results (missing fields, truncated output, flagged uncertainty).
3. **Silent failure** — The subagent returns well-formed output that is wrong. This is the most dangerous failure mode — the coordinator cannot detect it without validation logic.
4. **Inconsistent results** — Two subagents return results that contradict each other. The coordinator must decide which to trust, how to flag the inconsistency, or whether to re-delegate.

**Coordinator response strategies:**

- **Retry** — Re-invoke the subagent with the same task description. Useful for transient failures, not for systematic errors.
- **Fallback** — Invoke an alternative subagent or use a simplified subtask if the primary subagent fails.
- **Degrade gracefully** — Produce the best possible output from available results, and explicitly note what is missing or uncertain.
- **Escalate** — Surface the failure to the user or calling system rather than producing a degraded output silently. Required when the failure makes the output unreliable.
- **Re-delegate with correction** — If the coordinator can identify why the subagent failed, re-invoke with a modified task description that addresses the root cause.

**Design principle:** A coordinator that silently produces degraded output is more dangerous than one that surfaces failures explicitly. The exam will test whether you know that "completing the task" with silent degradation is not acceptable behavior in a well-designed system.

**Error handling in fan-out/fan-in specifically:**

When one of multiple parallel subagents fails, the coordinator must decide:
- Can the synthesis proceed with the remaining subagents' outputs? (Is the failed subagent's work required for synthesis?)
- Should the coordinator wait and retry, or should it produce a partial result?
- Does the failure affect the integrity of the outputs from the *other* subagents?

If the failed subagent's work is required for synthesis, the coordinator cannot proceed without either a retry or a graceful degradation decision. If it is optional, the coordinator may proceed and note the gap.

> **Knowledge Check 4:**
>
> **Knowledge Check:** A BuildOps Inc coordinator runs three parallel subagents. Subagent A (project status) returns clean results. Subagent B (milestone audit) fails with a timeout error. Subagent C (resource conflicts) returns clean results. The coordinator proceeds to synthesize the executive report using only the outputs from A and C — it does not mention Subagent B's failure or the missing milestone data. What failure mode is this, and what should the coordinator have done instead?
>
> *(Take a moment before scrolling)*
>
> **Exam pattern:** This is silent failure in the synthesis step. The coordinator produced a well-formed report that is missing a critical data category (overdue milestones) without surfacing that omission. The coordinator should have either: (1) retried Subagent B before synthesizing, (2) explicitly flagged in the report that milestone data was unavailable due to a timeout, or (3) escalated to the calling system and declined to produce the executive summary without complete data. The exam tests whether you recognize that producing a report without surfacing the gap is worse than not producing the report at all — executives making decisions on the report have no signal that it is incomplete.

---

### 9. Model Selection for Agentic Systems

> **Instructor — opening narration in persona voice:**
>
> *Practitioner:* "Every architectural decision in a multi-agent system has a cost. Model selection is the one most teams get wrong first — not because they pick the wrong model for a task, but because they don't pick at all. They use the best model everywhere and then wonder why their system costs 10x what they projected. Model selection is an architectural decision, not a configuration detail."
>
> *Socratic:* "You've designed an agentic system with a coordinator and three workers. Before we talk about which models to use — what information would you need to know about each agent's task before you could make that decision? Think about it."
>
> *Coach:* "Here's something that will save you money in production: not every agent needs the same model. The coordinator doing complex decomposition has different requirements than a worker that's just classifying a document into one of five categories. Matching the model to the task is a skill — and it's on the exam."
>
> *Challenger:* "What's the cost of using Claude Opus 4.7 for every agent in a 10-agent system versus a correctly tiered system? If you can't answer that, you're not ready to design production agentic systems. Let's fix that."

---

The Claude 4.x family has three tiers. Each has a different capability ceiling, latency profile, and cost structure. For agentic systems, these differences compound — every agent call is a separate model invocation.

**The Claude 4.x family:**

| Model | Capability tier | Best for in agentic systems |
|---|---|---|
| Claude Opus 4.7 | Highest reasoning | Coordinators doing complex decomposition; novel multi-hop reasoning; tasks where quality is non-negotiable |
| Claude Sonnet 4.6 | Balanced | Default for most agents; general-purpose subagents with moderate reasoning requirements |
| Claude Haiku 4.5 | Fast, lightweight | High-volume simple subagents: classification, extraction, formatting, routing |

**Coordinator vs. worker model patterns:**

The coordinator's job is to reason about the whole problem — decompose it, route subtasks, synthesize results. This benefits from Opus 4.7's reasoning depth.

Workers have bounded, well-defined tasks. A worker that classifies a document into one of five categories does not need Opus. Haiku 4.5 will produce identical output at a fraction of the cost and latency.

**The cost-capability tradeoff at scale:**

A 10-agent system where every agent uses Opus 4.7 costs 5–10x more than the same system with correctly tiered models. At production volume, this difference is not theoretical.

The design principle: match model capability to task complexity. Haiku for simple, well-constrained tasks. Sonnet as the default for general agents. Opus for genuinely complex reasoning.

> **Knowledge Check 5:**
>
> **Knowledge Check:** You're designing an agentic system with 4 agents: (1) a coordinator that decomposes incoming legal documents and routes them to specialists, (2) a contract classifier that assigns each document to one of 8 contract types, (3) a clause extractor that identifies and pulls specific named clauses, (4) a synthesis agent that writes a unified analysis from all specialist outputs. Assign a model to each agent and justify your choices.
>
> *(Take a moment before scrolling)*
>
> **Exam-aligned answer:** Coordinator → Opus 4.7 (complex routing and synthesis logic). Classifier → Haiku 4.5 (bounded classification, 8 categories, no open-ended reasoning). Clause extractor → Haiku 4.5 or Sonnet 4.6 (structured extraction; Haiku if well-defined fields, Sonnet if clauses require interpretation). Synthesis agent → Sonnet 4.6 or Opus 4.7 (cross-document reasoning; Opus if quality is critical).

> **Exam pattern:** The CCA exam presents multi-agent system designs and asks which model configuration is most appropriate. The trap answer is Opus everywhere. The correct answer matches model capability to task complexity and justifies the cost-latency tradeoff. Any answer that ignores cost or treats model selection as a purely capability decision is incomplete.

---

## Domain Checkpoint

You've completed the Domain 1 concept walkthrough. Before we move on, the instructor will assess your understanding and update your progress record.

**The instructor will now:**

1. Ask you to rate your confidence on each Domain 1 topic: High / Medium / Low

2. Update `.student_cca/progress.md` with:
   - Domain 1 Status → "Complete"
   - Domain 1 Confidence → your self-assessed level (High / Medium / Low)
   - Confusion Log → any topics you flagged as Low confidence or explicitly noted confusion on
   - Last session note → a brief summary of where you are and what to pick up next

3. Surface any weak areas:

> *Practitioner:* "Tell me your confidence on each topic — agentic loop, coordinator jobs, subagent invocation, task decomposition, context boundaries, orchestration patterns, when not to use agents, error handling, model selection. I'll update your progress file and we'll revisit anything you're shaky on."
>
> *Socratic:* "Before I update your progress — I want you to tell me which of these topics you could explain right now to someone who had never heard of agents, and which ones still feel fuzzy. That's your confidence self-assessment."
>
> *Coach:* "You've covered a lot in Domain 1! Let's take stock together. For each topic, tell me: High — I could explain this clearly. Medium — I understand it but I'm not confident under pressure. Low — I'd need to review before an exam question. There's no wrong answer here."
>
> *Challenger:* "Confidence ratings. Don't be generous with yourself. High means you can answer an exam question on this topic under time pressure without looking anything up. Give me your honest assessment on each of the nine topics."

**After student provides confidence ratings, write to `.student_cca/progress.md`:**

```
Update the Domain 1 row:
- Status: Complete
- Confidence: [student's self-assessment — if mixed across topics, use the lowest]

Add to Confusion Log (for any Low-confidence topics):
[topic name] — flagged in Domain 1 checkpoint

Update Last session note:
Completed Domain 1 (Agentic Architecture, 27%). Topics covered: agentic loop, coordinator's 4 jobs, subagent invocation, task decomposition, context boundaries, orchestration patterns, when NOT to use agents, error handling, model selection. Confidence: [summary]. Weak areas: [list or "none"]. Next: Domain 2 (Tool Design, 18%).
```

**Surface weak areas in persona voice:**

> *Practitioner:* "You flagged [X] as Low confidence. That maps to [exam question pattern]. We'll revisit it in Domain [Y] when it comes up in context. For now, move to Domain 2."
>
> *Socratic:* "You rated [X] as Low. Before Domain 2 — what specifically feels unclear about it? Give me the most precise description you can of what you don't understand. That's more useful than just reviewing the whole topic."
>
> *Coach:* "You flagged [X] as Low confidence — that's totally fine, it's the most complex topic in Domain 1. We'll build on it in Domain [Y], and by the time you get there, it will feel much clearer. You're making great progress."
>
> *Challenger:* "Low confidence on [X]. That's a gap we need to close. Before Domain 2: tell me the one thing about [X] that, if you understood it clearly, would bring you to Medium confidence. That's what we're going to address right now."

---

## What's Next

Domain 1 complete. Domain 2 covers Tool Design — the tools that agents use to take action in the world. The tool schemas, invocation patterns, and error handling you design in Domain 2 are what make the subagent behaviors in Domain 1 possible.

> **Instructor:** Transition to `domains/domain-2-tool-design.md` when the student is ready.
>
> *Practitioner:* "Domain 2. The tools are what give agents leverage. Open `domains/domain-2-tool-design.md`."
>
> *Socratic:* "One question before Domain 2: in the BuildOps example, what tools would the subagents have needed to actually retrieve the data they analyzed? Hold that thought. Open `domains/domain-2-tool-design.md`."
>
> *Coach:* "Domain 1 — done! You've built the foundation. Domain 2 is where we look at the tools that power everything you just learned. Open `domains/domain-2-tool-design.md` and let's keep going."
>
> *Challenger:* "Domain 2. You've learned what coordinators do — now you'll learn what they use to do it. Open `domains/domain-2-tool-design.md`. We'll see how well Domain 1 actually landed."
