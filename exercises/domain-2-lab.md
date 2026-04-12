# Domain 2 Lab — Design a Tool Suite

> **Instructor note:** This is a student-driven lab. Minimal narration. The student does the work; you provide feedback after each stage. Run feedback in the student's current persona voice.

---

## Lab Overview

You've seen tool design in the MedRoute Health scenario. Now you'll apply the same skills in a different context — one you haven't seen before.

This lab has four stages:
1. **Design** — Write tool definitions for a new scenario
2. **Predict** — Forecast how the model will use your tools
3. **Test** — Run the tools and observe actual behavior
4. **Debrief** — Compare prediction to reality; identify what made your descriptions effective or not

**Time estimate:** 45-60 minutes for all four stages.

**What you'll build:** A tool suite of 2-3 tools for SecurePath Systems.

---

## The Scenario: SecurePath Systems

SecurePath Systems is an enterprise security firm that monitors client networks for threats. They're building an automated incident triage agent that:

1. Receives incoming security alerts from monitoring tools
2. Classifies each alert (false positive, low severity, medium severity, high severity, critical)
3. Assigns alerts to the appropriate response team
4. Creates an incident record with investigation notes

The agent needs tools to do its job. Your task: design them.

**System context:**
- Alert sources: firewall logs, endpoint detection, network traffic analysis, user behavior analytics
- Response teams: tier-1-soc (first response), tier-2-soc (investigation), incident-response (active threats), threat-intelligence (pattern analysis), escalation-manager (critical/executive-level)
- Severity levels: false_positive, low, medium, high, critical
- SLA requirement: critical alerts must be assigned within 2 minutes of receipt

---

## Stage 1: Design Your Tool Suite

Design 2-3 tools for the SecurePath incident triage agent. For each tool, write:

### Tool Template

```
## Tool: [tool_name]

### Description
[1-4 sentences. Include: what the tool does, when to call it, when NOT to call it,
any important constraints on inputs, what the model should have determined before calling it]

### Input Schema
Parameters:
- [param_name] ([type], [required/optional]): [description, including valid values or constraints]
- [continue for each parameter]

Required: [list required parameters]

### Error Responses
Recoverable error example:
[JSON showing a recoverable error with suggested_action]

Fatal error example:
[JSON showing a non-recoverable error with escalation path]

### tool_choice
For this tool, I would use: [auto / any / tool]
Reason: [1-2 sentences explaining why]
```

---

**Before you start:** Answer these scoping questions:

1. What are the distinct actions the triage agent needs to take? (List them — these become your tool candidates)
2. Which actions could be combined into one tool? Which must be separate?
3. For each tool you're considering: what's the worst thing that happens if the model calls it incorrectly?

Take 5 minutes to answer these before writing any tool definitions.

---

### Design Constraints

Your tool suite must:
- [ ] Cover the core triage workflow: classify, assign, document
- [ ] Handle the 2-minute SLA requirement for critical alerts (how?)
- [ ] Include at least one enum-constrained parameter
- [ ] Include at least one parameter with a behavioral constraint in the description (not just a type)
- [ ] Have error responses that distinguish recoverable from fatal errors

Your tool suite must NOT:
- Be more than 3 tools (scope discipline — if you need more, your tools are too granular)
- Duplicate functionality across tools
- Have a tool that does more than one distinct thing

---

> **Instructor — feedback prompt after student submits designs:**
>
> *Practitioner:* "Review each tool description against three criteria: (1) Does it tell the model when NOT to call this tool? (2) Are all constrained values explicit in the description or schema? (3) Does the error response give the model enough to recover without hallucinating a recovery path?"
>
> *Socratic:* "Look at your descriptions. For each one: what assumption are you making about what the model already knows? Is that assumption justified, or should it be explicit in the description?"
>
> *Coach:* "Your designs are taking shape! Check each one for the 'completeness test': could a model with no context except the tool definition and the task use this tool correctly? If not, what's missing?"
>
> *Challenger:* "Show me the tool you're least confident about. What's the failure mode you're not sure you've addressed? Let's stress-test it before you move to Stage 2."

---

## Stage 2: Predict Model Behavior

Before running anything, write down your predictions.

For each tool you designed, answer:

### Prediction Template

```
## Tool: [tool_name]

### Test prompt I'll use:
[Write the alert description or scenario you'll pass to the agent]

### My predictions:
1. Will the model call this tool for this prompt? [Yes / No / Maybe — explain]
2. What value will the model provide for [your most important constrained parameter]?
3. What value will the model provide for [your most important behavioral constraint parameter]?
4. Will the model call this tool before or after [another tool in your suite]? Why?

### What would indicate my description is working?
[1-2 specific outcomes that would confirm your description is doing its job]

### What would indicate my description needs revision?
[1-2 specific outcomes that would show a gap in your description]
```

**Why this step matters:** Writing predictions before testing forces you to make your mental model explicit. When prediction and reality diverge, that gap is exactly where you learn.

---

> **Instructor — framing before student writes predictions:**
>
> *Practitioner:* "Prediction before testing is a discipline, not optional. If you skip this step, you'll rationalize whatever the model does as correct. Write specific predictions — not 'the model will route it correctly' but 'the model will call `assign_alert` with severity=critical and team=incident-response.' Specificity is what makes the comparison useful."
>
> *Socratic:* "What's the difference between predicting 'the model will use this tool correctly' and predicting the specific parameter values it will use? Which prediction is testable?"
>
> *Coach:* "Predictions feel uncomfortable because you might be wrong — and that's exactly the point! The places you're wrong are the most valuable learning moments in this lab."
>
> *Challenger:* "Vague predictions are worthless. If your prediction can be confirmed by almost any output, you predicted nothing. Make each prediction falsifiable — specific enough that the model's output either matches it or doesn't."

---

## Stage 3: Test

Now run your tools and compare to your predictions.

### Test Setup

1. Open a Claude Code session (or API session)
2. Define your tools using the schemas you wrote in Stage 1
3. Use this base prompt, replacing `[ALERT_TEXT]` with a realistic security alert:

```
You are SecurePath Systems' incident triage agent. A new security alert has arrived.
Review it and take the appropriate action using the available tools.

Alert received: [ALERT_TEXT]
```

### Test Alerts

Use at least two of these test alerts:

**Alert A — Clear critical threat:**
> `[2026-04-12 14:23:17 UTC] CRITICAL — Endpoint EDR-4471: Ransomware execution detected. Process: svchost.exe spawning encryption activity on C:\Users\*. 847 files encrypted in 90 seconds. Network traffic to 185.220.101.47 (known C2). User: jsmith@securepath.internal. Lateral movement detected to 3 additional hosts.`

**Alert B — Likely false positive:**
> `[2026-04-12 14:31:02 UTC] HIGH — Network IDS: Port scan detected from 10.14.2.88. 254 ports scanned in 60 seconds. Source is internal IP. User context: IT infrastructure team member running authorized vulnerability assessment per ticket SEC-8821.`

**Alert C — Ambiguous medium:**
> `[2026-04-12 15:07:44 UTC] MEDIUM — User behavior analytics: Unusual login pattern for mwilliams@securepath.internal. Login from new geographic location (Frankfurt, DE) while existing session active from Chicago, IL. No MFA challenge triggered. User is Senior Financial Analyst.`

**For each test:**
1. Run the agent with your tool definitions and the alert text
2. Record exactly what the model called — tool name, parameter values, order of calls
3. Compare to your prediction
4. Note every deviation

---

> **Instructor — check-in during testing:**
>
> *Practitioner:* "If the model is doing something unexpected, don't fix the tool description yet — finish the test and record what happened. Premature iteration makes it hard to understand the root cause."
>
> *Socratic:* "When you see a deviation from your prediction — before revising the description, ask: is the model wrong, or was my prediction wrong? Sometimes the model is doing the right thing and your expectation was off."
>
> *Coach:* "Document everything, even the things that work perfectly. 'This parameter was filled in correctly because of X' is just as useful as 'this parameter was wrong because of Y.'"
>
> *Challenger:* "Alert A is the critical ransomware scenario with a 2-minute SLA requirement. Did your tool suite handle the timing constraint? Or is that something your design doesn't address? Be specific."

---

## Stage 4: Debrief

Compare your predictions to your test results. Answer these questions:

### Analysis Questions

**1. Description effectiveness**
- Which tool description produced the most predictable model behavior? What made it effective?
- Which tool description produced the most unexpected behavior? What was missing or ambiguous?

**2. Schema constraints**
- Did your enum constraints prevent the model from using invalid values? (If you tested without enums: what values did the model use?)
- Were there parameter values the model got wrong that better description constraints would have prevented?

**3. Error handling**
- Did any tool calls fail during testing? If so, what did the agent do with the error response you designed?
- If no errors occurred, describe what would happen in the ransomware scenario if the `assign_alert` tool returned a database timeout error.

**4. tool_choice**
- For Alert B (likely false positive), did the model call your classification tool with `false_positive` or did it hedge? What does that tell you about your description?
- Was there a scenario where `tool_choice: any` would have been more appropriate than `tool_choice: auto`? Explain.

**5. The SLA requirement**
- The scenario specifies critical alerts must be assigned within 2 minutes. How did your tool suite address this? Did the model enforce it, or did you have to enforce it at the execution layer?
- What's the right division of responsibility between the tool description and the execution layer for time-sensitive constraints?

---

### Revision Exercise (optional but recommended)

Pick the tool description that produced the most unexpected behavior. Rewrite it based on what you learned.

Then answer: What specific change did you make, and why do you expect it to produce different behavior?

---

> **Instructor — lab closing debrief in persona voice:**
>
> *Practitioner:* "What you just did is the actual skill: design, predict, test, revise. That loop is how you build reliable tools in production — not by getting the description perfect on the first try, but by iterating with evidence. The exam tests whether you understand the principles. The job tests whether you can execute the loop."
>
> *Socratic:* "Looking back at your original designs vs. where you ended up: what assumption did you start with that turned out to be wrong? And what does that assumption reveal about how you were thinking about tool design before this lab?"
>
> *Coach:* "You just designed, tested, and analyzed a real tool suite for a security context. That's genuinely hard work, and you did it. The gap between prediction and reality — that gap is your learning. It's not a failure; it's the data."
>
> *Challenger:* "Give me one specific, actionable change you will make to every tool description you write from now on, based on what you learned in this lab. Not a principle — a practice. Something you'll actually do differently."

---

## Lab Completion

When you've completed all four stages, return to `domains/domain-2-tool-design.md` and run the **Domain Checkpoint** section.

The checkpoint will update your progress record and surface any remaining gaps before you move to Domain 3.
