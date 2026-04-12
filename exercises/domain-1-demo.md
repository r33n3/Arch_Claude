# Domain 1 Demo — Live Coordinator Internals: BuildOps Inc Project Status Reporting

> **Instructor note:** This demo builds directly on the opening exercise. The student has already seen a coordinator + subagents system run at the surface level. This demo exposes the internals: the coordinator's decision points, the context boundary mechanics, and the Task tool invocations — all narrated step by step. Run every narration block in the student's current persona. Socratic questions are mandatory — do not continue until the student responds.

---

## Setup

In the opening exercise, you watched an agentic system execute. You saw the output. You saw the structure. What you didn't see was the coordinator's internal decision-making at each step — the choices that determined how the system was decomposed, what each subagent was given, and why the synthesis worked.

This demo runs that same style of system — but this time we narrate every decision as it happens.

**What you'll see in this demo:**
- The coordinator receiving a real task and making the decomposition decision explicitly
- Step-by-step narration of why each subtask was scoped the way it was
- Two subagents spawned via the Task tool, with full task descriptions
- The context boundary made visible: what each subagent knows and what it does not
- Result synthesis: how the coordinator combines the two outputs into one deliverable
- Debrief: mapping every step to the coordinator's 4 jobs

**The scenario: BuildOps Inc**

BuildOps Inc's operations director needs an automated weekly project status report. This report is delivered to the executive team every Monday morning. It must surface: project status per project (on-track, at-risk, delayed), any overdue milestones, resource conflicts, and an executive summary with recommended actions.

The coordinator has been assigned: *"Generate this week's BuildOps executive project status report."*

---

## Step 1 — The Coordinator Receives the Task

The coordinator receives the task. Before doing anything else, it does one thing: reads the task carefully and decides whether it can complete it in a single pass or whether it requires decomposition.

> **Instructor — narrate the coordinator's first decision:**
>
> *Practitioner:* "This is the decomposition gate — the first decision every coordinator makes. Can I do this in one pass? The BuildOps task has four distinct deliverables: project status, milestone audit, resource conflicts, and an executive summary. The first three require pulling from different data sources. The fourth requires synthesizing the first three. That's the decomposition decision made."
>
> *Socratic:* "The coordinator has just read the task. Before it decides anything — what question should it ask itself first? What is the single most important thing to determine before decomposing a task?"
>
> **[SOCRATIC QUESTION — Wait for student response before continuing]**
>
> "Before the coordinator decides how many subagents to use — what's the first question it should ask itself?"
>
> After student answers, provide feedback in persona voice, then continue.
>
> *Coach:* "Watch this first moment carefully — it's where a lot of agentic systems go wrong. The coordinator doesn't just immediately start delegating. It asks: can I do this in one pass? Only when the answer is no does it decompose. That gate is what prevents over-engineering."
>
> *Challenger:* "Stop. Before I narrate anything — you tell me. Given that task: can a single agent complete it in one pass? If yes: why is this demo even happening? If no: what makes it require decomposition? I want a specific answer, not 'it's complex.'"

**The coordinator's decomposition decision:**

The BuildOps task cannot be completed in a single pass for two reasons:
1. The data gathering (project status, milestone audit, resource conflicts) is parallelizable — three independent analyses that can run simultaneously
2. The synthesis (executive summary) requires all three analyses to be complete before it can begin

The coordinator decides: three parallel subagents for data gathering, then a synthesis step.

**What the coordinator does NOT do:**
- It does not spawn a subagent for the executive summary synthesis — that is the coordinator's own job (Job 3: Synthesize)
- It does not create a subagent for "task management" or "coordination" — the coordinator is the coordinator
- It does not add a fourth subagent to "review" the outputs — review is part of synthesis

---

## Step 2 — Task Decomposition Decision

The coordinator now defines the three subtasks explicitly.

> **Instructor — narrate the decomposition:**
>
> *Practitioner:* "Here's what good decomposition looks like: each subtask gets a bounded, self-contained scope. No subtask depends on another. Each one can be handed to an isolated agent that has no idea the other subagents exist — and it should still be able to complete its work."
>
> *Socratic:* "The coordinator is about to define three subtasks. Before I show you what they are — how would you know if a subtask is too broad? What's the test for whether a subtask is correctly bounded?"
>
> *Coach:* "This is the craftsmanship step of agentic architecture! The coordinator isn't just splitting the task — it's designing three isolated analysis jobs. Notice how each subtask is defined so that a fresh agent, with no context about the rest of the system, can complete it on its own."
>
> *Challenger:* "I'm going to show you three subtask definitions. Your job: find the flaw in any of them. A well-formed subtask should be completable by an isolated agent using only what it's given. If you can find a dependency I haven't acknowledged, I want to hear it."

**The coordinator's three subtask definitions:**

**Subtask 1 — Project Status:**
> Analyze project activity logs for the current week. For each active project, determine its current status: on-track (all milestones on schedule, no blockers reported), at-risk (one or more upcoming milestones at risk, or blockers flagged but not critical), or delayed (one or more milestones already overdue, or critical blockers). Return a structured list: Project Name | Status | One-line rationale.

**Subtask 2 — Milestone Audit:**
> Analyze project milestone records. Identify all milestones with a due date within the past 14 days that have not been marked complete. For each: Project Name | Milestone Name | Due Date | Days Overdue | Assigned Owner.

**Subtask 3 — Resource Conflict Detection:**
> Analyze resource allocation records for all active projects. Identify instances where the same contractor or resource is assigned to two or more projects during overlapping time windows in the next 30 days. For each conflict: Contractor Name | Project A | Project B | Overlapping Dates | Severity (Critical if both projects are active that week; Moderate if one is at reduced scope).

**Why these three are parallel-safe:** None of these subtasks uses the output of another. Project Status doesn't need to know about milestones or conflicts to determine status (status is based on its own activity log data). Milestone Audit doesn't need to know about project status or resource allocation. Resource Conflict Detection doesn't need either of the other analyses.

The synthesis step — where we cross-reference these three — is the coordinator's work, not a subagent's.

---

## Step 3 — Subagent Invocation via Task Tool

The coordinator now invokes two Task tool calls. (In a full implementation, it would invoke three — we will demonstrate two in parallel here and note the third.)

> **Instructor — narrate before invoking:**
>
> *Practitioner:* "Watch the task descriptions. Every field in these descriptions is a deliberate design decision. The role definition, the deliverable spec, the scope constraints, the note about what the parallel agent is doing. None of that is boilerplate — all of it controls what the subagent does and prevents it from going out of scope."
>
> *Socratic:* "I'm about to show you the actual task descriptions passed to the subagents. Before you read them — what do you think the coordinator must include in each one? What's the minimum viable task description for a subagent to complete its work reliably?"
>
> *Coach:* "Here's the moment where the coordinator's design choices become real! Look at what's in each task description — and notice what's not in there too. The coordinator has made explicit choices about what each subagent needs and what it doesn't need."
>
> *Challenger:* "Two task descriptions coming up. Find the tradeoffs. What did the coordinator include that you might not have? What might be missing? These are not perfect — no task description is. Where are the risks?"

**Invoking the subagents via Task tool:**

**Task Invocation 1 — Project Status Subagent:**
```
Task: You are a project status analyst for BuildOps Inc, a construction project management platform.

Role: Analyze this week's project activity data and classify each active project's current status.

Deliverable: A structured status table with columns: Project Name | Status (on-track / at-risk / delayed) | One-line rationale. Return this as a markdown table.

Scope: Classify project status based on milestone progress and activity logs only. Do not analyze milestones for overdue status (that is handled separately). Do not analyze resource allocation. Do not write an executive summary.

Parallel context: A separate analyst is simultaneously auditing overdue milestones. You are responsible for current status classification only.

Input data: [BuildOps project activity data — in a live deployment, this would be retrieved from the BuildOps project management system. For this teaching exercise, generate plausible construction project status data: 5-7 active projects in various states, with realistic milestone and blocker patterns.]

Return only your structured markdown table. Do not include preamble or explanation beyond the table.
```

**Task Invocation 2 — Milestone Audit Subagent:**
```
Task: You are a milestone compliance auditor for BuildOps Inc, a construction project management platform.

Role: Identify all project milestones that are currently overdue — due within the past 14 days and not yet marked complete.

Deliverable: A structured table with columns: Project Name | Milestone Name | Due Date | Days Overdue | Assigned Owner. Return as a markdown table. If no overdue milestones are found, return a table with one row stating "No overdue milestones identified."

Scope: Audit milestone completion records only. Do not assess current project status beyond milestone overdue status. Do not analyze resource allocation. Do not write an executive summary.

Parallel context: A separate analyst is simultaneously classifying overall project status. You are responsible for milestone overdue detection only.

Input data: [BuildOps milestone records — in a live deployment, this would be retrieved from the BuildOps project management system. For this teaching exercise, generate plausible construction milestone data: milestones across the 5-7 projects, with some overdue patterns that create narrative consistency with realistic construction project delays.]

Return only your structured markdown table. Do not include preamble or explanation beyond the table.
```

> **Instructor — narrate as Tasks are invoked:**
>
> *Practitioner:* "Notice the explicit scope exclusions. 'Do not analyze milestones for overdue status — that is handled separately.' 'Do not write an executive summary.' These aren't redundant. Without them, agents drift into adjacent scope — they try to be helpful and end up doing work that either duplicates or contradicts the coordinator's synthesis plan."
>
> *Socratic:* "Look at the 'Parallel context' field in each task description. Why is it there? The subagents can't see each other — why does it matter that they know about each other's existence?"
>
> *Coach:* "See how each subagent knows its place in the larger system? Not through shared state — through explicit instruction. The coordinator has given each subagent a map of where it fits. That's intentional design, not convenience."
>
> *Challenger:* "What would happen if you removed the scope exclusions from those task descriptions? Be specific. Which failure mode would appear first — and would it appear during execution or only at synthesis time?"

> **Instructor action:** Invoke both Task tool calls now. The subagents will run in parallel. If the Task tool is unavailable, skip to the Failure Fallback section at the end of this file — do not block course progress.

---

## Step 4 — Context Boundary Visible

While the subagents are running (or have run), the instructor makes the context boundary explicit.

> **Instructor — narrate the context boundary:**
>
> *Practitioner:* "Right now, each subagent has exactly one thing in its context: the task description we gave it. It cannot see the other subagent's work. It cannot see the coordinator's original task. It cannot see the other subagent's output. When it finishes, it will have generated its result entirely from: its task description, its training, and whatever data it synthesized internally. That's the isolation guarantee."
>
> *Socratic:* "Think about this carefully: the two subagents are running in parallel, each in their own isolated context. Neither knows what the other is producing. Is that a problem for the integrity of the final report? Could we get contradictory results from two agents that have no awareness of each other?"
>
> **[SOCRATIC QUESTION — Wait for student response before continuing]**
>
> "Could the isolation between subagents cause them to produce contradictory or inconsistent results? What would cause that, specifically?"
>
> After student answers, provide feedback in persona voice, then continue.
>
> *Coach:* "The isolation is what makes this reliable! Each subagent can't accidentally corrupt the other's work. If one agent produces a wrong answer, it stays contained — it doesn't cascade into the other agent's output. The coordinator is the one who handles any inconsistencies at synthesis time."
>
> *Challenger:* "Here's the key question about isolation: the subagents are generating plausible data independently. They don't share a data source. Is there a risk that Project A appears as 'on-track' in Subagent 1's output but has three overdue milestones in Subagent 2's output? How would the coordinator handle that?"

**The context boundary diagram:**

```
[COORDINATOR CONTEXT]
- Original task: "Generate this week's BuildOps executive project status report"
- Subagent task descriptions (both)
- Subagent results (after completion)
- Synthesis logic

        |                           |
        ↓                           ↓

[SUBAGENT 1 CONTEXT]         [SUBAGENT 2 CONTEXT]
- Task description only      - Task description only
- No coordinator context     - No coordinator context
- No Subagent 2 context     - No Subagent 1 context
- Generates: status table   - Generates: milestone table

        |                           |
        ↓                           ↓

[COORDINATOR receives both results — the ONLY entity with full visibility]
```

This is why the coordinator bears full responsibility for synthesis quality. No subagent can do this integration — only the coordinator has both results in its context simultaneously.

---

## Step 5 — Result Synthesis

The coordinator has received both subagent results. Now it synthesizes.

> **Instructor — narrate before synthesis:**
>
> *Practitioner:* "Synthesis is where coordinators get sloppy. Most implementations just paste the two results together and call it a report. Good synthesis means: cross-referencing, finding relationships between the two outputs, and producing something that couldn't have been generated by either subagent alone."
>
> *Socratic:* "The coordinator now has both tables. What does it need to do that neither subagent could have done? What's the coordinator-only work here — work that required having both results in context simultaneously?"
>
> *Coach:* "Here's the payoff moment! The coordinator is about to combine two focused analyses into one coherent picture. Think about what insights only become possible once you have both analyses together. That's what the coordinator brings to this step."
>
> *Challenger:* "The coordinator has a project status table and a milestone overdue table. Find me one insight that requires both tables to generate. Just one — and make it specific. If you can't, then one of those subagents was redundant."

**The coordinator's synthesis process:**

1. **Cross-reference:** Match each overdue milestone (from Subagent 2) to its project in the status table (from Subagent 1). Flag any projects marked "on-track" that have overdue milestones — this is a data inconsistency the coordinator must resolve or surface.

2. **Elevate status where needed:** Any project with overdue milestones that is currently marked "on-track" should be re-evaluated. The coordinator applies a rule: one overdue milestone by 1-3 days → flag as at-risk; overdue by 7+ days or multiple overdue milestones → flag as delayed.

3. **Generate executive summary:** Produce a brief narrative (4-6 sentences) that states: how many projects are on-track vs. at-risk vs. delayed, what the most critical overdue items are, and what actions are recommended.

4. **Produce final report:** Combine the (updated) project status table, the milestone overdue table, and the executive summary into a single structured document.

> **Instructor action:** Invoke the coordinator's synthesis — produce the final BuildOps weekly status report by combining the subagent outputs.

> **Instructor — narrate after synthesis:**
>
> *Practitioner:* "See what happened there: the coordinator found the inconsistency between 'on-track' status and overdue milestones — and resolved it. That's the Decide job. Neither subagent could have done that. The coordinator had to see both results simultaneously to catch it."
>
> *Socratic:* "We said the coordinator would 'resolve' status inconsistencies. But in a production system — should the coordinator resolve them automatically, or should it surface them to a human for decision? What are the criteria for making that call?"
>
> *Coach:* "The final report is the result of three isolated agents' work, synthesized into a coherent executive deliverable. Notice how much richer this is than what any single agent could have produced — and how the coordinator's synthesis added value beyond just combining the tables."
>
> *Challenger:* "We just had the coordinator auto-resolve a status inconsistency by applying a rule. What assumption does that rule make, and when would it be wrong? I want a specific scenario where the coordinator's rule would produce a wrong status classification."

---

## Step 6 — Debrief: Mapping to the Coordinator's 4 Jobs

You've just watched a complete coordinator + 2 subagents system execute. Let's map every step to the framework.

### Job 1: Decompose

**What we saw:** The coordinator received the BuildOps task, identified that it contained three parallel data gathering subtasks plus one synthesis step, and split them accordingly.

**The test:** Each subtask was completable by an isolated agent with only its task description. None depended on the other's output. The synthesis step was correctly kept by the coordinator (it requires visibility across all results).

**Exam angle:** Decomposition questions ask: is this subtask correctly scoped? Is it parallel-safe? Does the subagent have what it needs? Watch for subtasks that seem independent but actually have hidden data dependencies.

---

### Job 2: Delegate

**What we saw:** The coordinator wrote explicit task descriptions with five components: role definition, deliverable spec, scope constraints, parallel context, and input data. Both subagents were given exactly what they needed — nothing more.

**The test:** The scope exclusions ("do not analyze milestones") prevented scope drift. The parallel context ("a separate analyst is simultaneously...") prevented redundant work. The deliverable format spec ("return as a markdown table") made synthesis tractable.

**Exam angle:** Delegation questions often ask what's wrong with a given task description. Common flaws: missing scope constraints (causes scope drift), missing deliverable format (makes synthesis harder), missing data (subagent can't complete the task), excessive context (wastes tokens, introduces irrelevant information).

---

### Job 3: Synthesize

**What we saw:** The coordinator received two structured tables, cross-referenced them, found and resolved an inconsistency, and produced a final report with an executive narrative.

**The test:** The synthesis added value beyond concatenation — the cross-reference and status elevation were coordinator-only work that required both results in context simultaneously.

**Exam angle:** Synthesis questions ask: what information does the coordinator need to synthesize these results? What would make synthesis fail? Watch for scenarios where the coordinator's synthesis step assumes format consistency that the subagents' task descriptions didn't guarantee.

---

### Job 4: Decide

**What we saw:** The coordinator encountered a data inconsistency (on-track status with overdue milestones) and applied a rule to resolve it. In a well-designed system, it would also have handled the case where a subagent failed or returned incomplete results.

**The test:** The coordinator didn't silently pass through the inconsistency. It detected it and made a decision. This is the Decide job — applied here not to a failure, but to a data inconsistency.

**Exam angle:** Decide questions often involve failure scenarios: subagent timeout, partial result, conflicting outputs. The correct coordinator behavior is always: detect, decide, either resolve or surface. Never silently produce degraded output.

---

> **Instructor — closing debrief in persona voice:**
>
> *Practitioner:* "That's the full loop. Every step maps directly to exam concepts. The agentic loop, the four coordinator jobs, context isolation, fan-out/fan-in, synthesis, decide. You've now seen the internals, not just the output. Domain 1 content will formalize all of it."
>
> *Socratic:* "Before we close the demo — what was the single most interesting design decision the coordinator made? Not 'it decomposed the task' — a specific choice. And what would have gone wrong if it had made a different choice there?"
>
> *Coach:* "You just watched a real agentic system execute, and you understood every step. The decomposition decision, the context boundaries, the synthesis logic — you saw all of it. That's a genuinely strong foundation for Domain 1. Well done."
>
> *Challenger:* "The demo showed the happy path, mostly. One inconsistency, resolved by rule. What's the scenario where this coordinator would produce a catastrophically wrong report and have no idea? That's what Domain 1's error handling section is about. Think about it before we continue."

---

## Failure Fallback

> **Use this section if the Task tool is unavailable or if subagent invocation fails.**

If the Task tool isn't available in your Claude Code setup, here's what would have happened — and why it still counts for the exam.

**What would have happened:**

The coordinator would have sent two Task tool calls simultaneously. Each would have created a new isolated agent context with the task description above. Both agents would have run in parallel — each analyzing BuildOps project data from their assigned angle. The coordinator would have received two structured markdown tables and proceeded to synthesis.

**The context boundary would still have existed** — even though you didn't see it execute live, the architecture is identical to what you would observe. Each agent would have had only its task description; neither would have had visibility into the other's work or the coordinator's original task.

**Why it still counts:**

The exam doesn't test whether you ran these specific Task calls. It tests whether you understand:
- What the Task tool invocation creates (an isolated agent context)
- What the subagent can and cannot access (task description only; no coordinator context)
- How the coordinator synthesizes results it received from isolated agents
- What the coordinator must do when a subagent fails

You have seen the structure, the task descriptions, the decomposition logic, and the synthesis process. The concepts map identically regardless of whether the system executed live.

**Diagnostics if you want to run this live:**
- Confirm `ANTHROPIC_API_KEY` is set: `echo $ANTHROPIC_API_KEY`
- Confirm Task tool is available in your Claude Code permissions
- Re-run this demo once setup is confirmed — live execution is more valuable than walkthrough

Course progress is not blocked. Continue to Domain 1 content.

---

## What's Next

You've completed the Domain 1 demo. This exercise demonstrated the internals of what you observed in the opening exercise — with explicit narration of every coordinator decision.

Continue to the Domain 1 lab (`exercises/domain-1-lab.md`) where you will build your own coordinator + subagents system from scratch.

> *Practitioner:* "You've seen it. Now build it. Open `exercises/domain-1-lab.md`."
>
> *Socratic:* "Before the lab — what's one design decision in this demo that you would make differently? What would you change, and why? Hold that thought for the lab."
>
> *Coach:* "The lab is where everything clicks into place. You've watched the demo — now you'll make your own design choices and see what happens. Open `exercises/domain-1-lab.md`. You're ready for this."
>
> *Challenger:* "Lab. You'll build a coordinator from scratch. The design choices the demo made for you — you'll make them yourself now. Open `exercises/domain-1-lab.md`. Let's see what you actually understood."
