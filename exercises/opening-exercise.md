# Opening Exercise — Live Agentic System Demo

> **Instructor note:** This is the course hook. Run it entirely in the student's chosen persona voice. Every narration block has persona-specific guidance. The Socratic questions are mandatory — wait for a real answer before continuing. If the Task tool fails, use the Failure Fallback section and keep going.

---

## Setup

You're about to watch a real agentic system execute inside this environment.

Not a diagram. Not pseudocode. An actual coordinator agent decomposing a task, spinning up two subagents in parallel, and synthesizing their results — right here in Claude Code.

Your job right now is to **observe and think**. The instructor will narrate each step as it happens. At three points you'll be asked a question — answer it before the narration continues. The answers you give will tell us a lot about where to focus first in Domain 1.

**What you're about to see:**
- A coordinator receiving a real task
- Task decomposition: breaking the work into bounded subtasks
- Subagent invocation: two agents spawned via the Task tool
- Parallel execution: both agents working simultaneously
- Result synthesis: coordinator collecting and combining outputs
- Debrief: mapping everything to Domain 1 CCA exam concepts

Ready? Let's go.

---

## The Scenario

**Enterprise context: FinClearance Corp**

FinClearance Corp is a mid-size financial services firm with 200+ employees. They've recently been flagged by their compliance team for inconsistent regulatory language across three internal policy documents. The documents govern how employees handle client data under GDPR, SOC 2, and their internal InfoSec policy. Each document was written by a different team. The language doesn't contradict — but it doesn't align either. Regulators want consistency before the next audit.

**The task assigned to our coordinator:**

> "Analyze the three FinClearance compliance documents for terminology consistency. Identify: (1) terms that mean the same thing but are named differently across documents, and (2) gaps — where one document covers something the others don't. Produce a reconciliation summary."

---

> **Instructor — persona-voiced task introduction:**
>
> *Practitioner:* "This is a real coordination problem. The task is too broad for one pass — it requires focused parallel analysis before synthesis is even possible. Watch what the coordinator does with it."
>
> *Socratic:* "Take a look at that task. It's asking for two different things. Before we run anything — what would *you* do first if you received this?"
>
> *Coach:* "This is a great scenario to start with because it mirrors real enterprise problems. Notice what's in that task — there are actually two distinct deliverables. Keep that in mind as you watch."
>
> *Challenger:* "Read the task carefully. There's more than one thing being asked here. If you had to break it into parts before delegating — where would you cut it?"

**Collect student background (before running the system):**

Ask the student:
1. "What's your current background with agentic systems — have you built with them before, or is this new territory?"
2. "Is there a domain or industry (finance, healthcare, security, engineering) where you'd most like to apply these patterns?"

> Use their answers to personalize narration throughout the exercise. If they're a practitioner, lean into production realities. If they're new, lean into first-principles explanations.

---

## Watch: Task Decomposition

> **Instructor — narrate before running:**
>
> *Practitioner:* "Before the coordinator does anything, it has to decide: what are the atomic units of this task? You can't parallelize work that isn't clearly bounded. Watch the decomposition."
>
> *Socratic:* "Before I show you what the coordinator does — what do you think it should do first? Given that task, what's the first decision a well-designed coordinator makes?"
>
> *Coach:* "Here's where it gets interesting! The coordinator's first job isn't to answer the question — it's to decide how to break it apart. Think about: what would make this task parallelizable?"
>
> *Challenger:* "Stop. Before we run anything: what do you think the coordinator should do first? I want a specific answer — not 'figure out the task' or 'plan.' What is the actual first operation?"

**[SOCRATIC QUESTION — wait for student response before continuing]**

> "Before I show you — what do you think the coordinator should do first when it receives a complex, multi-part task like this one?"

After student answers, provide feedback in persona voice, then continue.

**The coordinator's decomposition:**

The coordinator receives the FinClearance task and breaks it into two bounded subtasks:

- **Subtask A — Terminology Mapping:** "Read all three documents. Extract every defined term or recurring phrase. Flag where the same concept appears under different names."
- **Subtask B — Gap Analysis:** "Read all three documents. Identify topics that appear in one or two documents but are absent or underdeveloped in others. List gaps with document references."

These are parallel-safe: neither subtask's output depends on the other being done first. Both can run simultaneously.

> **Instructor note:** Point out explicitly that the coordinator has done something important here — it has scoped each subtask so that a subagent can complete it with *only* the task description and the documents. No coordinator context is needed. This is the key design property.

---

## Watch: Subagent Invocation

> **Instructor — narrate before invoking:**
>
> *Practitioner:* "Now the coordinator delegates. Each subagent gets exactly what it needs and nothing more. No shared state. No awareness of the other subagent. This is intentional — and it's what makes the system reliable."
>
> *Socratic:* "Two subagents are about to be spawned. Why do you think this was split into two separate agents rather than one agent doing both tasks sequentially?"
>
> *Coach:* "This is the moment where it becomes a real multi-agent system! Notice the coordinator doesn't do the work itself — it *delegates*. Pay attention to how each subagent's task is scoped."
>
> *Challenger:* "Two subagents. Why? What would break — or what would get worse — if this were one agent doing both tasks in sequence? I want a specific answer."

**[SOCRATIC QUESTION — wait for student response before continuing]**

> "Why do you think these were split into separate agents rather than handled by a single agent sequentially?"

After student answers, provide feedback in persona voice, then continue.

**Invoking the coordinator + subagents via Task tool:**

> **Instructor action:** Now invoke the live system. Use the Task tool to spawn both subagents. If the Task tool is unavailable, skip to the Failure Fallback section — do not block course progress.

The coordinator dispatches the following Task invocations (demonstrate this live):

**Task 1 — Terminology Mapping Subagent:**
```
Task: You are a terminology mapping analyst working on a compliance documentation project for FinClearance Corp, a financial services firm. 

Your specific job: Analyze three compliance policy documents (GDPR policy, SOC 2 policy, InfoSec policy) for terminology consistency. 

Deliverable: A structured list of terms where the same concept appears under different names across documents. For each entry, note: (1) the term variants found, (2) which document uses each variant, (3) your recommended canonical term.

Context: You are one of two parallel analysts. The other analyst is doing gap analysis. You are doing terminology mapping only. Do not attempt gap analysis.

Input data: [The three FinClearance policy documents are fictional for this exercise. Generate plausible regulatory terminology — GDPR, SOC 2, and InfoSec overlap terms — as if you had read the actual documents. This is a teaching exercise demonstrating subagent invocation and scope isolation.]

Return your findings as a structured markdown table.
```

**Task 2 — Gap Analysis Subagent:**
```
Task: You are a compliance gap analyst working on a documentation audit for FinClearance Corp, a financial services firm.

Your specific job: Analyze three compliance policy documents (GDPR policy, SOC 2 policy, InfoSec policy) for coverage gaps.

Deliverable: A structured list of topics where one document covers something the others don't — or where coverage is significantly uneven. For each gap: (1) the topic, (2) which document(s) cover it, (3) which document(s) are missing it, (4) severity assessment (Critical / Moderate / Minor).

Context: You are one of two parallel analysts. The other analyst is doing terminology mapping. You are doing gap analysis only. Do not attempt terminology mapping.

Input data: [The three FinClearance policy documents are fictional for this exercise. Generate plausible compliance gap findings — GDPR, SOC 2, and InfoSec coverage differences — as if you had read the actual documents. This is a teaching exercise demonstrating subagent invocation and scope isolation.]

Return your findings as a structured markdown table.
```

> **Instructor — narrate as Tasks are invoked:**
>
> *Practitioner:* "Watch the scope on those task descriptions. Each subagent gets the full context it needs — role, deliverable, constraints, what the other agent is doing — but nothing it doesn't need. That's explicit context isolation. The coordinator doesn't leak its full task context into each subagent."
>
> *Socratic:* "Look at the task descriptions. What did the coordinator include that you might not have thought to include? What's in there specifically to prevent the subagents from going out of scope?"
>
> *Coach:* "Notice how the coordinator tells each subagent about the other one? That's a coordination technique — it sets scope boundaries without requiring the subagents to communicate with each other directly."
>
> *Challenger:* "What's missing from those task descriptions? What would you add? What's in there that you'd remove? These are real design choices — not default behavior."

---

## Watch: Parallel Execution

Both subagents are now running simultaneously.

> **Instructor — narrate during execution:**
>
> *Practitioner:* "In a real deployment, these would be running as parallel API calls. Each subagent has its own context window — completely isolated. If one fails, the coordinator can handle it independently without the other being affected."
>
> *Socratic:* "While these are running — what would it mean for one subagent to 'fail'? What are the different ways a subagent can fail, and which ones can a coordinator recover from?"
>
> *Coach:* "This is what makes agentic systems powerful — parallelism. These two analysts are working at the same time. In a real system, this could mean significantly faster task completion. How does that change what kinds of problems are worth using agents for?"
>
> *Challenger:* "Parallel execution introduces a category of failure that sequential execution doesn't have. What is it? Think about what happens when you try to combine two results that were generated without awareness of each other."

**Key concept to surface:** Each subagent has its own isolated context. They cannot see each other's work. They cannot share state. The coordinator is the only entity that will see both results. This is both the power and the constraint of the coordinator pattern.

---

## Watch: Result Synthesis

The subagents have returned their results. Now the coordinator synthesizes.

> **Instructor — narrate before synthesis:**
>
> *Practitioner:* "The coordinator now has two structured outputs and needs to produce one coherent deliverable. This is the synthesis step — and it's where most coordinator implementations get sloppy."
>
> *Socratic:* "Before I show you the coordinator's synthesis — what did the coordinator need to know in order to combine these two results correctly? What information was required at synthesis time that wasn't in either subagent's output?"
>
> *Coach:* "Here's the final step — bringing it all together! Think about what the coordinator has to do here that neither subagent could do on its own."
>
> *Challenger:* "What did the coordinator need to know to combine these results? I want a specific answer about what information was required that only the coordinator had access to."

**[SOCRATIC QUESTION — wait for student response before continuing]**

> "What did the coordinator need to know to combine these two results into a single reconciliation summary?"

After student answers, provide feedback in persona voice, then continue.

**The coordinator synthesizes:**

The coordinator receives both subagent outputs and produces the final reconciliation summary by:
1. Cross-referencing the terminology mapping against the gap analysis — some gaps may be caused by terminology inconsistency
2. Prioritizing findings by severity (Critical gaps first, then Moderate, then Minor)
3. Generating the reconciliation summary as a single coherent document, noting where terminology decisions would also resolve identified gaps

> Present the coordinator's combined output as the final deliverable.

---

## Debrief

You just watched a complete agentic loop execute. Now let's map what you observed to the Domain 1 CCA exam concepts.

---

### The Agentic Loop

The full loop: **receive task → plan → act → observe → plan again → synthesize**

What you saw:
- *Receive:* Coordinator got the FinClearance compliance task
- *Plan:* Coordinator decomposed it into two parallel subtasks
- *Act:* Coordinator invoked two subagents via the Task tool
- *Observe:* Coordinator received both subagent results
- *Synthesize:* Coordinator produced the reconciliation summary

The loop can be as short as one iteration (what you saw) or many — in complex systems, a coordinator might observe results and decide to spawn additional subagents based on what it finds.

---

### The Coordinator's 4 Jobs

The CCA exam tests whether you know what a coordinator *actually does*. It is not a "smart router." It has four distinct responsibilities:

1. **Decompose** — Break the task into bounded, parallelizable subtasks. Each subtask must be completable by an isolated agent with no shared state.
2. **Delegate** — Assign subtasks to subagents with precise, scoped instructions. The coordinator controls what context each subagent receives.
3. **Synthesize** — Collect results and combine them into a coherent output. The coordinator is the only entity with visibility across all subagent outputs.
4. **Decide** — Handle cases where results are incomplete, conflicting, or require judgment. The coordinator decides whether to re-delegate, escalate, or proceed.

In the FinClearance exercise, you saw all four — though "Decide" was simple because both subagents returned clean results. In production, the decide step is where most failures surface.

---

### Subagent Invocation

Subagents in Claude Code are invoked via the **Task tool**. Each invocation:
- Creates a new isolated agent context
- Receives only the task description the coordinator provides
- Has no access to the coordinator's context or other subagents' state
- Returns a result to the coordinator

This isolation is a feature, not a limitation. It keeps each subagent's job bounded and its failures contained.

---

### Task Decomposition

A well-decomposed task has three properties:
1. **Bounded scope** — The subagent can complete it without needing to know about the rest of the system
2. **Parallel-safe** — The subtask's output doesn't depend on another subtask's output
3. **Explicitly delegated context** — The coordinator includes everything the subagent needs; nothing is assumed

The FinClearance decomposition had all three. Most poorly-designed multi-agent systems fail on #1 or #3.

---

> **Instructor — closing debrief in persona voice:**
>
> *Practitioner:* "That's the pattern. Coordinator receives, decomposes, delegates, synthesizes, decides. Every agentic architecture question on the CCA exam is testing some variant of whether you understand that loop and what breaks at each step. Domain 1 is going to go deep on all of it."
>
> *Socratic:* "Before we move on — what surprised you? What worked the way you expected, and what didn't? What question do you have that we haven't answered yet?"
>
> *Coach:* "You just ran your first live agentic system! Let's take stock of what you now understand: the agentic loop, the coordinator's four jobs, subagent isolation, and task decomposition. That's the core of Domain 1. Excellent start."
>
> *Challenger:* "You've seen the happy path. Domain 1 is mostly about what happens when it breaks. What's the first thing that breaks in this system if the terminology mapping subagent returns incomplete results? Think carefully."

---

## Failure Fallback

> **Use this section if the Task tool is unavailable or invocation fails.**

If the Task tool isn't available in your current Claude Code setup, here's what *would* have happened — and why that matters for the exam:

**What would have happened:**

The coordinator would have sent two Task tool calls. Each would have spawned an isolated agent context with the task description you saw above. Both agents would have run in parallel, each analyzing the FinClearance documents from their assigned angle. The coordinator would have received two structured markdown tables — one with terminology mapping findings, one with gap analysis findings — and combined them into the reconciliation summary.

The interaction pattern would look identical to what you see in a standard Claude Code session, except the work would be distributed and the context would be isolated. You would see both agents' outputs appear in your terminal as they completed.

**Why it still counts:**

The exam doesn't test whether you've run the Task tool in this specific exercise. It tests whether you understand the invocation pattern, what isolation means, and how coordinators synthesize multi-agent outputs. You've seen the structure. The concepts map the same way.

**What to note:**

- Check that `ANTHROPIC_API_KEY` is set correctly: `echo $ANTHROPIC_API_KEY`
- Confirm you're running Claude Code with the correct permissions for Task tool invocation
- This exercise can be re-run once your setup is confirmed — and that's worth doing, because watching it execute live is more valuable than reading about it

The course continues. This doesn't block anything in Domain 1.

---

## What's Next

You've completed the opening exercise. Here's where that content maps in the course:

- **Domain 1: Agentic Architecture (27%)** — Everything you just saw in depth. The agentic loop, coordinator patterns, subagent design, failure modes, orchestration decisions.
- **Domain 2: Tool Design (18%)** — The tools those subagents used. How to design tool schemas. When to use tools vs. context.
- **Domain 3: Claude Code (20%)** — The environment you're running in right now. CLAUDE.md, worktrees, hooks, permissions.
- **Domain 4: Prompt Engineering (20%)** — The task descriptions you just saw delegated to subagents. That was prompt engineering. We're going to analyze exactly what made them work.
- **Domain 5: Context & Reliability (15%)** — Why those subagents were isolated. Context window management. How to build systems that don't fail as tasks get longer.

> **Instructor:** Transition to `domains/domain-1-agentic-architecture.md`.
>
> In persona voice, set up Domain 1:
>
> *Practitioner:* "Let's go deeper. Open `domains/domain-1-agentic-architecture.md`."
>
> *Socratic:* "One question before Domain 1: based on what you just saw — what do you think is the hardest design decision a coordinator architect has to make? Hold that thought. Open `domains/domain-1-agentic-architecture.md`."
>
> *Coach:* "You're ready for Domain 1! Everything you just experienced is what Domain 1 is built on. Open `domains/domain-1-agentic-architecture.md` and let's keep building."
>
> *Challenger:* "Domain 1. You've seen the happy path. Now let's find out how much of it you actually understood. Open `domains/domain-1-agentic-architecture.md`."
