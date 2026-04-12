# Domain 1 Lab — Build Your Own Coordinator + Subagents System

> **Instructor note:** This is the hands-on build exercise for Domain 1. The student designs and runs their own mini-orchestration system from scratch. They choose one of four enterprise scenarios, write the coordinator prompt and two subagent prompts, identify parallel-safe vs sequential tasks, specify context requirements, run the system, and debrief against their predictions. Run this entirely in the student's current persona. The lab is self-paced — check in at each stage gate, not before.

---

## Overview

You have watched a coordinator + subagents system run twice: in the opening exercise (FinClearance Corp compliance analysis) and in the Domain 1 demo (BuildOps Inc project status reporting). Both times, you observed someone else's design decisions.

Now you make your own.

In this lab, you will:
1. Choose an enterprise scenario
2. Decompose the task into subtasks
3. Write the coordinator prompt and two subagent prompts
4. Identify which tasks are parallel-safe and which are sequential
5. Specify what context each subagent needs
6. Run the system
7. Compare what happened against what you predicted
8. Debrief: what worked, what broke, what you'd change

**Estimated time:** 45–60 minutes for a thorough lab. Do not rush the design phase. Most mistakes happen before the first Task tool call.

---

## Stage 1 — Choose Your Scenario

Pick one of the four enterprise scenarios below. Choose the one closest to a domain you know or find most interesting — you'll do better work on problems you have intuitions about.

---

**Scenario A: FinClearance Corp — Compliance Risk Scoring**

FinClearance Corp (the financial services firm from the opening exercise) needs an automated compliance risk scoring system for new vendor onboarding. When a new vendor is submitted, the system must: (1) screen the vendor against a regulatory exclusion list, (2) analyze the vendor's proposed contract for compliance risk clauses, and (3) generate a risk score with recommended next steps.

*The task assigned to your coordinator:*
> "Perform a full compliance risk assessment for new vendor submission #V-2847 (CloudData Analytics). Generate a risk score and recommended approval/rejection/escalation decision."

---

**Scenario B: BuildOps Inc — Subcontractor Bid Analysis**

BuildOps Inc (the construction platform from the demo) receives multiple competing bids for each project phase. The procurement team needs an automated bid analysis system that: (1) compares bids on cost, timeline, and experience criteria, (2) flags any bids that are unusually low (potential quality risk) or unusually high (budget risk), and (3) produces a ranked recommendation with justification.

*The task assigned to your coordinator:*
> "Analyze the three subcontractor bids received for Phase 2 of the Riverside Commons project. Rank them and produce a procurement recommendation."

---

**Scenario C: MedCore Health — Patient Discharge Summary**

MedCore Health is a regional hospital network. Their clinical documentation system needs an automated discharge summary generator. When a patient is discharged, the system must: (1) synthesize the clinical encounter notes into a medical history summary, (2) generate medication reconciliation — confirm all medications from admission, identify any changes, and flag interactions, (3) produce a patient-facing care instructions document.

*The task assigned to your coordinator:*
> "Generate a complete discharge package for patient encounter #MH-9921. Include clinical summary, medication reconciliation, and patient care instructions."

---

**Scenario D: DataVault Systems — Security Incident Report**

DataVault Systems is a cloud data platform. Their security operations team needs an automated incident report generator. When a security alert is triggered, the system must: (1) analyze the alert logs to characterize the incident type, severity, and affected systems, (2) review the affected systems' recent access logs for anomalous patterns, (3) produce an incident report with recommended containment and remediation actions.

*The task assigned to your coordinator:*
> "Generate a full incident report for security alert #SIR-7741 triggered at 02:34 UTC. Include incident characterization, access log analysis, and containment recommendations."

---

> **Instructor — scenario selection in persona voice:**
>
> *Practitioner:* "Pick the scenario closest to problems you've actually worked on. Domain knowledge helps you make better decomposition decisions. If you're equally unfamiliar with all four, pick Scenario A — FinClearance is the one you've seen most context on already."
>
> *Socratic:* "Before you choose — which of these tasks do you think would be hardest to decompose cleanly? Which one has the most hidden dependencies? Your answer tells me something about your current mental model."
>
> *Coach:* "All four scenarios are well-suited for this lab. Choose the one that feels most interesting to you — you'll do better work when you're engaged with the domain. There's no wrong choice here."
>
> *Challenger:* "Choose the scenario where you feel least confident about the domain. The decomposition patterns are the same regardless of domain — and your unfamiliarity will force you to think structurally rather than relying on domain intuition."

**Write down your choice before continuing.**

---

## Stage 2 — Design Before You Build

This stage is design-only. Do not write any prompts yet. Write your design in your editor or on paper.

### 2A — Task Analysis

Answer these questions for your chosen scenario:

1. What are the distinct subtasks in this coordinator task?
2. For each subtask: Is it parallel-safe, or does it depend on another subtask's output?
3. How many subagents will you use? Why?
4. Which subtask(s) — if any — should the coordinator handle itself rather than delegating?

### 2B — Context Mapping

For each subagent you plan to use, answer:

1. What role does this subagent play? (One sentence)
2. What is its deliverable — exactly? (Format, structure, content)
3. What scope constraints does it need? (What should it NOT do?)
4. What data or context does it need to complete its work?
5. Should it know about the other subagent(s)? If yes, what should it be told?

### 2C — Synthesis Planning

Answer:

1. What will the coordinator need to do in the synthesis step?
2. Is there any information that neither subagent will produce that the coordinator needs to add?
3. What would make synthesis fail? Name one realistic failure mode.
4. What should the coordinator do if one of the subagents returns an incomplete or error response?

> **Instructor — design gate:**
>
> *Practitioner:* "Before you write a single prompt: have you written down your answers to 2A, 2B, and 2C? Design-before-build isn't a formality — it's the discipline that separates agentic systems that work from ones that technically run but produce garbage."
>
> *Socratic:* "Walk me through your design. Don't tell me about the prompts yet — tell me about the structure. How many subagents, and why that number? What's the coordinator handling itself? What surprised you when you answered 2C?"
>
> **[SOCRATIC QUESTION — Wait for student response before continuing]**
>
> "Walk me through your design decisions. How many subagents, which tasks are parallel-safe, and what's the coordinator's synthesis job?"
>
> After student walks through design, provide feedback in persona voice, then continue.
>
> *Coach:* "Great! Before we move to writing prompts — let's sanity-check your design together. Walk me through it at a high level. I want to hear your decomposition logic before you commit to it in prompt form."
>
> *Challenger:* "Tell me your design before you write the prompts. I'm going to ask you to defend every choice. Why that number of subagents? Why is that task parallel-safe? What specifically makes your synthesis step non-trivial? I want specifics."

---

## Stage 3 — Write the Coordinator Prompt

Now write the coordinator's system prompt or initial task context.

**The coordinator prompt must include:**

1. **The task** — exactly as described in your chosen scenario
2. **The decomposition decision** — brief statement of how the task will be divided
3. **The delegation plan** — which subagents will be invoked and in what order (parallel or sequential)
4. **The synthesis instructions** — what the coordinator will do with the subagent results
5. **The failure handling instructions** — what the coordinator should do if a subagent fails or returns incomplete results

**Format guidance:** Write the coordinator prompt as you would write a system prompt for Claude — in second person, clear instructions, no ambiguity about what the coordinator's job is.

**Reference:** Look back at the opening exercise and Domain 1 demo task descriptions for examples of well-formed prompts. Do not copy them — use them as structural reference only.

> **Instructor — prompt writing in persona voice:**
>
> *Practitioner:* "The coordinator prompt is your architecture document. If someone reads only this prompt, they should be able to understand what the system does, how it's structured, and what it does when things go wrong. Write it at that level of clarity."
>
> *Socratic:* "As you write the coordinator prompt — what's the hardest instruction to write? What do you find yourself struggling to specify precisely? That difficulty is telling you something about your design."
>
> *Coach:* "Take your time writing the coordinator prompt! This is the most important document in your system. A clear coordinator prompt makes everything downstream easier. If you're unsure about a section, write your best version and flag it — we'll revisit it in the debrief."
>
> *Challenger:* "Write the coordinator prompt. Then re-read it and ask: if an agent followed only these instructions, would the synthesis step actually work? Would the failure handling actually prevent silent degradation? Be honest."

---

## Stage 4 — Write the Subagent Prompts

Write the task description for each of your two subagents. These are the exact text you will pass to the Task tool.

**Each subagent task description must include:**

1. **Role definition** — What kind of agent is this? One sentence.
2. **Deliverable specification** — Exactly what it must produce. Include format.
3. **Scope constraints** — What it must NOT do. Be explicit.
4. **Parallel context** — If applicable, a brief note on what the other subagent is doing and why this subagent's scope is distinct from it.
5. **Input data** — Any data the subagent needs. For this lab exercise, include a note that it should generate plausible data consistent with the scenario if actual data is unavailable.

**Self-contained test:** After writing each task description, ask: Could an isolated agent, with no other context, complete this task using only this description? If no — something is missing.

> **Instructor — subagent prompt review in persona voice:**
>
> *Practitioner:* "Read each task description aloud — literally. If any sentence is ambiguous when you hear it, it's ambiguous to the agent too. Fix it before running."
>
> *Socratic:* "For each subagent task description: what's the most important sentence? The one that, if removed, would cause the subagent to either go out of scope or produce unusable output. Identify it before we run."
>
> *Coach:* "You're almost ready to run! Before invoking the Tasks — read each task description and ask yourself: would a fresh agent, with no context, be able to complete this? If yes: you're ready. If something feels missing: add it now."
>
> *Challenger:* "Find the weakest part of each task description. What's the sentence that's doing too much work — relying on the agent to infer something that should be explicit? Fix it before running. Weak prompts are the most common lab failure mode."

---

## Stage 5 — Predict Before Running

Before you invoke any Task tool calls, write down your predictions.

**Answer these questions before running:**

1. What will each subagent return? (Rough structure — not exact content)
2. Will there be any inconsistencies between the two subagents' outputs? If yes, what kind?
3. Will the coordinator's synthesis step encounter any edge cases not covered by your instructions?
4. What's the most likely failure mode in your system?

Write these predictions down. You will compare them against what actually happens.

> **Instructor:**
>
> *Practitioner:* "Writing predictions before running is a professional discipline. It tells you whether your design is clear enough that you can predict the output — and it turns the run into a diagnostic, not just an execution."
>
> *Socratic:* "What did you predict, and why? I'm particularly interested in failure predictions — where do you think your design has the weakest seams?"
>
> *Coach:* "This is a great habit to build! Predicting before running makes the results much more informative. Even if everything goes exactly as planned, you'll understand why it worked — not just that it worked."
>
> *Challenger:* "I want your predictions before you run. Specifically: where does your design fail? Every design has a failure mode. If you can't identify it before running, you didn't think about it hard enough in Stage 2."

---

## Stage 6 — Run the System

Now invoke your coordinator and subagents via the Task tool.

**Running order:**

1. Start the coordinator (or invoke both subagent Tasks directly, in parallel, as the coordinator would)
2. If your subtasks are parallel-safe: invoke both Task tool calls simultaneously
3. If your synthesis step is sequential: wait for both subagent results before synthesizing

> **Instructor action:** Support the student in invoking the Task tool. If the Task tool is unavailable, use the Failure Fallback section at the end of this file.

> **Instructor — narrate during execution:**
>
> *Practitioner:* "Watch the output carefully. You're looking for: did the subagent stay in scope? Did it return the format you specified? Is there anything in the output you didn't predict? These are the signals."
>
> *Socratic:* "While the subagents are running — go back to your predictions. Are you expecting this to go exactly as planned? If yes: why? What did you design well? If no: what are you watching for?"
>
> *Coach:* "Your system is running! This is the exciting part — watching your design execute. Take notes on anything that surprises you. The surprises are your best learning material for the debrief."
>
> *Challenger:* "Watch critically. Not 'did it work' — but 'did it do what I actually specified?' There's a difference. An agent can complete a task and still not follow your instructions exactly. Watch for that."

---

## Stage 7 — Compare and Analyze

Your subagents have returned results. Before synthesis, compare against your predictions.

**Answer these questions:**

1. Did each subagent return the format you specified? If not — what did it return instead, and why?
2. Did either subagent go out of scope? If yes — which instruction (or missing instruction) caused it?
3. Are the two outputs consistent with each other, or do they contain implicit contradictions?
4. Does your coordinator's synthesis plan still work given what the subagents actually returned?

**Common findings at this stage:**

- Subagent returned a different format than specified (markdown prose instead of a table, or vice versa)
- Subagent added content beyond its scope (attempted to write part of the executive summary)
- Two subagents made different assumptions about the same entity (e.g., Project A classified differently in each)
- Coordinator's synthesis instructions don't cover an edge case that appeared in the actual results

If you found any of these: note them. You'll address them in the debrief.

> **Instructor:**
>
> *Practitioner:* "Run through each of those four questions now. Be specific. This analysis is the diagnostic that tells you where your design was strong and where it had gaps."
>
> *Socratic:* "What surprised you most about the results? I don't mean 'it worked' or 'it didn't work' — I mean what was different from what you predicted? What does that difference tell you about your design?"
>
> *Coach:* "Great run! Now let's look at the results critically. Even if it went well, there's always something to learn from comparing what you predicted vs. what actually happened. What did you notice?"
>
> *Challenger:* "Go through the four questions. Where did your design hold and where did it fail? I want the failures — that's where the learning is. Anyone can tell me what worked."

---

## Stage 8 — Synthesize the Final Output

Complete the synthesis step: combine your subagents' outputs into the final deliverable for your chosen scenario.

If your coordinator has synthesis instructions: follow them now.

If you found inconsistencies in Stage 7: decide how to handle them as part of synthesis. Document your decision.

> **Instructor:**
>
> *Practitioner:* "If the synthesis is clean: great. If you're encountering edge cases your instructions didn't cover: that's the exam content in action. You're doing the Decide job right now."
>
> *Socratic:* "As you synthesize — are you making decisions that your coordinator instructions didn't cover? What are you inferring that you should have specified? Note those gaps."
>
> *Coach:* "This is the final step! You're almost done. If the synthesis is smooth: that means your design was solid. If you're having to make judgment calls: that's valuable feedback for the debrief."
>
> *Challenger:* "Synthesize the output. But before you finalize it — be honest: are you making decisions in this step that your coordinator instructions didn't specify? Those are the gaps in your design."

---

## Stage 9 — Lab Debrief

You've built, run, and synthesized a coordinator + subagents system. Now debrief.

### Debrief Question Set

Answer each of these. There are no right answers — the debrief is about understanding what your design choices produced.

**On decomposition:**
1. Was your decomposition correct? Would you change the number of subagents or how you split the task?
2. Were all your subtasks truly parallel-safe? Did any hidden dependency surface during the run?

**On delegation:**
3. Which subagent task description was strongest? Which was weakest? What made the difference?
4. If any subagent went out of scope: which missing instruction caused it?
5. Did the scope constraint on "what NOT to do" work as intended? What would you add or change?

**On context boundaries:**
6. Was there information either subagent needed that you forgot to include?
7. Was there information you included that turned out to be unnecessary?

**On synthesis:**
8. Did your synthesis instructions cover everything that actually came up in the results?
9. Did you encounter any inconsistencies between subagent outputs? How did you handle them?

**On the system as a whole:**
10. Was this task worth multi-agent orchestration? Or could a single agent have done it just as well?
11. What's the one design change that would most improve this system's reliability?

> **Instructor — debrief in persona voice:**
>
> *Practitioner:* "Run through those questions. The debrief is where you convert your lab experience into exam knowledge. Every question maps directly to a Domain 1 concept — most of them will appear in some form on the CCA exam."
>
> *Socratic:* "Question 10 is the most important: was this worth multi-agent orchestration? What would have to be different about this task for the answer to be 'no'? And what does that tell you about when agents are the wrong tool?"
>
> *Coach:* "You built a real system and ran it! The debrief questions are designed to help you extract the maximum learning from that experience. Take your time with them — every answer is one fewer gap on the exam."
>
> *Challenger:* "I want honest answers to questions 3, 9, and 10. Those are the hardest — they require you to admit what didn't work and to question whether the whole architecture was justified. The students who answer those honestly are the ones who are ready for the exam."

---

## Optional Extension: Rebuild with Improvements

If your debrief identified significant gaps in your design, apply them now.

Rewrite the weakest task description and re-run that single subagent. Compare the new output against the original. Did the improvement produce the result you expected?

This loop — design, run, debrief, revise, re-run — is the core skill tested in Domain 1. The exam will present systems that have already been designed and ask you to identify the flaw, predict the failure mode, or select the correct fix. The faster you can run this loop, the higher your exam performance.

---

## Domain 1 Lab Complete

You've completed the hands-on portion of Domain 1.

**What you built:**
- A coordinator prompt with decomposition logic, delegation plan, synthesis instructions, and failure handling
- Two subagent task descriptions with role definitions, deliverable specs, scope constraints, parallel context, and input data
- A live run with a real agentic system
- A structured debrief that maps your experience to exam concepts

**What to carry forward:**
- The task descriptions you wrote in this lab are direct practice for prompt engineering questions in Domain 4
- The error handling decisions you made in synthesis are direct practice for Domain 5's reliability concepts
- If you found yourself wanting the subagents to use tools (to retrieve real data), that's Domain 2

> **Instructor — close the lab in persona voice:**
>
> *Practitioner:* "Lab complete. You've built a coordinator + subagents system end to end. The design decisions you made — and the ones that didn't work — are your exam preparation. Open `domains/domain-1-agentic-architecture.md` to close out Domain 1 with the concept walkthrough."
>
> *Socratic:* "One question to close: what's the most important thing you learned from building this that you couldn't have learned from reading about it? Hold that. Open `domains/domain-1-agentic-architecture.md`."
>
> *Coach:* "Lab complete — and you built something real! That experience is worth more than any diagram. Open `domains/domain-1-agentic-architecture.md` to solidify the concepts behind what you just built."
>
> *Challenger:* "Lab done. What would break in your system if the task size scaled by 10x? That's not rhetorical — it's a question you should be able to answer right now, from your lab experience. Open `domains/domain-1-agentic-architecture.md`."

---

## Failure Fallback

> **Use this section if the Task tool is unavailable.**

If the Task tool isn't available in your current Claude Code setup, complete the lab in simulation mode:

1. **Complete Stages 1–5** (choose scenario, design, write prompts, predict) — all of these are design work and do not require the Task tool.

2. **For Stage 6 (Run):** Instead of invoking Task tool calls, ask Claude directly with each subagent's task description as the prompt. Claude will respond as the subagent would have. This produces equivalent output for the purposes of the lab.

3. **Continue Stages 7–9** (analyze, synthesize, debrief) as normal using the responses you received.

**Note:** The design and analysis work in this lab is the primary learning content. The Task tool execution demonstrates the invocation pattern — but the architectural thinking, prompt design, and debrief analysis work the same way regardless of how the agents are invoked.

Check your Task tool availability: confirm `ANTHROPIC_API_KEY` is set and Claude Code has Task tool permissions. This lab is worth re-running once your setup is confirmed.
