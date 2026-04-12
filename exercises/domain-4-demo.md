# Domain 4 — Live Demo: Prompt Engineering in Action

> **Instructor note:** This demo runs entirely in the student's chosen persona voice. Every narration block has four variants. Socratic questions are mandatory — wait for a real answer before continuing. The demo uses SecurePath Systems (threat classification) as the scenario throughout. Each step shows a real prompt executed live — the progression from unstructured to fully engineered is the point.

---

## Setup

**What you're about to see:**

You're going to watch a single task — classifying a security alert — go through four versions of the same prompt. Each version adds one layer of engineering. By the end, you'll see how output quality, reliability, and parseability change at each step.

Then you'll watch a validation loop catch a real error.

**The scenario:**

SecurePath Systems processes security alerts from their SIEM (Security Information and Event Management) system. Analysts are overwhelmed. They need Claude to pre-classify incoming alerts by severity so analysts can focus on the ones that matter.

**The alert we'll classify throughout this demo:**

```
ALERT-2847: Outbound DNS query to domain registered 3 days ago. 
Query volume: 847 requests in 90 minutes from host WKSTN-114. 
Process origin: svchost.exe. GeoIP: destination resolves to server in Moldova.
No established baseline for this host. User: contractor account (inactive 60 days).
```

This alert has enough ambiguity to be interesting — it could be a misconfigured process or it could be DNS exfiltration. Watch how each prompt version handles that ambiguity.

> **Instructor — persona-voiced setup:**
>
> *Practitioner:* "This is a real analyst pain point. 500 alerts a night, 3 analysts. Without reliable pre-classification, everything looks equally important. Watch what each prompt version does to that ambiguity."
>
> *Socratic:* "Before we run anything — look at that alert. If you had to classify it right now with no guidance, what severity would you assign? And what information would you want before you committed to that answer?"
>
> *Coach:* "This is a great demo scenario because the alert is genuinely ambiguous — it could go multiple ways. That ambiguity is what makes prompt engineering hard and interesting. Notice how each prompt version handles it differently."
>
> *Challenger:* "Look at that alert. Tell me: what's the single most suspicious indicator in it? And what's the most benign explanation for the whole thing? Hold both of those answers — you'll need them when we discuss the validation loop."

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "Before I show you any prompt: what severity would you assign to that alert, and why? Be specific — what's driving your classification?"

After student answers, acknowledge their reasoning and note which indicators they focused on. Then continue.

---

## Step 1 — No Structure: The Raw Ask

**The prompt:**

```
What is the severity of this security alert?

ALERT-2847: Outbound DNS query to domain registered 3 days ago. 
Query volume: 847 requests in 90 minutes from host WKSTN-114. 
Process origin: svchost.exe. GeoIP: destination resolves to server in Moldova.
No established baseline for this host. User: contractor account (inactive 60 days).
```

**Run this live.** Let the student read the output.

> **Instructor — narrate after output appears:**
>
> *Practitioner:* "That output is not usable in a production pipeline. It's readable prose. You can't parse it. You can't store it in a database. If you run this 500 times, you'll get 500 differently-formatted responses. What you have is not a classification system — it's a conversation."
>
> *Socratic:* "What's wrong with that output for SecurePath's use case? Think specifically about what they need to do with this classification downstream — alert routing, database storage, analyst dashboards."
>
> *Coach:* "Notice what Claude did there — it gave a thoughtful answer, but the format is unpredictable. Every response will be structured differently. That's the problem prompt engineering solves."
>
> *Challenger:* "That output is useless for automation. Tell me exactly why. What specific downstream operation would break first if you tried to use this output in a real pipeline?"

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "What specifically makes that output unusable for an automated system? Name the failure point."

After student answers, confirm or correct their reasoning. Then continue.

**What to observe:**
- Output is readable but unstructured
- Length and format varies between runs
- No defined schema = no reliable parsing
- Ambiguity is handled verbally, not structurally

---

## Step 2 — Basic Structure: Adding a Format Constraint

**The prompt:**

```
Classify the severity of this security alert.
Return only one word: Critical, High, Medium, or Low.

ALERT-2847: Outbound DNS query to domain registered 3 days ago. 
Query volume: 847 requests in 90 minutes from host WKSTN-114. 
Process origin: svchost.exe. GeoIP: destination resolves to server in Moldova.
No established baseline for this host. User: contractor account (inactive 60 days).
```

**Run this live.** Let the student read the output.

> **Instructor — narrate after output appears:**
>
> *Practitioner:* "Better. One word. Parseable. But we've lost something — the model can no longer surface ambiguity. If it's uncertain, it gives you an answer anyway and you don't know the difference between a confident classification and a guess."
>
> *Socratic:* "We got a single word back. That's parseable. What did we lose by constraining the format this tightly? What information was in the verbose response that's now gone?"
>
> *Coach:* "See how the format constraint immediately made the output more consistent? That's a real win for automation. But notice the trade-off — we lost the reasoning. The next step adds structure without losing that."
>
> *Challenger:* "That format constraint is too aggressive. What would happen when this alert is genuinely ambiguous and could be either High or Critical? How would you know the difference between a confident High and an uncertain one?"

**What to observe:**
- Output is now parseable (single label)
- Lost: confidence information, reasoning, ambiguity signal
- Classification may be inconsistent run-to-run on ambiguous inputs
- No way to distinguish confident vs. uncertain classifications

---

## Step 3 — JSON Schema: Full Structured Output

**The prompt:**

```
Classify the following security alert. Return a JSON object with this exact structure — no other text:

{
  "alert_id": "<copy from input>",
  "severity": "Critical | High | Medium | Low",
  "confidence": "High | Medium | Low",
  "requires_escalation": true | false,
  "classification_reason": "<one sentence, max 20 words>",
  "ambiguous": false
}

Rules:
- requires_escalation is true if severity is Critical or High
- If the alert is ambiguous between two severity levels, set "ambiguous": true and explain in classification_reason
- Return only the JSON. No preamble. No explanation outside the JSON.

Alert:
ALERT-2847: Outbound DNS query to domain registered 3 days ago. 
Query volume: 847 requests in 90 minutes from host WKSTN-114. 
Process origin: svchost.exe. GeoIP: destination resolves to server in Moldova.
No established baseline for this host. User: contractor account (inactive 60 days).
```

**Run this live.** Let the student read the output.

> **Instructor — narrate after output appears:**
>
> *Practitioner:* "Now we're engineering. Every field is defined. The schema is machine-readable. The ambiguity flag gives us a routing signal — when it's true, we can escalate to human review automatically. This is the difference between a demo and a production system."
>
> *Socratic:* "Look at the output. What does the ambiguity flag tell us that the basic format prompt couldn't? And what would you do with that flag in a real pipeline?"
>
> *Coach:* "Notice that we now have both parseable output AND the model's uncertainty signal. That's the best of both worlds — automation handles the confident cases, humans get the uncertain ones. That's a real system design pattern."
>
> *Challenger:* "The JSON schema is better — but it still has a failure mode. What happens when the model returns a JSON object that has all the required fields but also adds fields you didn't ask for? How do you handle that in production?"

**What to observe:**
- All fields are structured and typed
- Ambiguity is surfaced as a machine-readable signal
- Classification reason is captured but length-constrained
- requires_escalation is derived automatically from severity
- This output can be directly inserted into a database or routing system

---

## Step 4 — Few-Shot Examples: Calibrating the Model

**The prompt:**

```
Classify the following security alert. Return a JSON object with this exact structure — no other text:

{
  "alert_id": "<copy from input>",
  "severity": "Critical | High | Medium | Low",
  "confidence": "High | Medium | Low",
  "requires_escalation": true | false,
  "classification_reason": "<one sentence, max 20 words>",
  "ambiguous": false
}

Rules:
- requires_escalation is true if severity is Critical or High
- If the alert is ambiguous between two severity levels, set "ambiguous": true and explain in classification_reason
- Return only the JSON. No preamble.

Examples:

Alert: ALERT-1102: Scheduled backup completed. 4.2GB written to /backup/archive/. No anomalies.
Output: {"alert_id": "ALERT-1102", "severity": "Low", "confidence": "High", "requires_escalation": false, "classification_reason": "Routine backup with no anomalies.", "ambiguous": false}

Alert: ALERT-1893: Failed login attempt. User: jsmith. 3 attempts in 2 minutes. Source: internal network.
Output: {"alert_id": "ALERT-1893", "severity": "Medium", "confidence": "High", "requires_escalation": false, "classification_reason": "Failed logins from internal source; no compromise confirmed.", "ambiguous": false}

Alert: ALERT-2201: Lateral movement detected. Admin credentials used on 14 workstations in 8 minutes. EDR agent disabled on 3 hosts.
Output: {"alert_id": "ALERT-2201", "severity": "Critical", "confidence": "High", "requires_escalation": true, "classification_reason": "Active lateral movement with EDR disabled; immediate response required.", "ambiguous": false}

Now classify:

Alert: ALERT-2847: Outbound DNS query to domain registered 3 days ago. 
Query volume: 847 requests in 90 minutes from host WKSTN-114. 
Process origin: svchost.exe. GeoIP: destination resolves to server in Moldova.
No established baseline for this host. User: contractor account (inactive 60 days).
```

**Run this live.** Let the student compare the output to Step 3.

> **Instructor — narrate after output appears:**
>
> *Practitioner:* "The few-shot examples did two things: they calibrated what 'Critical' vs. 'High' means for SecurePath's specific alert types, and they set a consistent tone for the classification_reason field. Run this 10 times — you'll get more consistent output than the Step 3 version."
>
> *Socratic:* "Compare this output to Step 3. What changed? And why did the examples change the output — what information did they add that the schema alone didn't have?"
>
> *Coach:* "See how the classification_reason has a similar style to the examples? That's the calibration effect of few-shot prompting. The model is pattern-matching your examples, not just following the schema."
>
> *Challenger:* "Look at the three examples. They're Low, Medium, and Critical. What's missing from the calibration set? If an alert comes in that's genuinely High severity, how well-calibrated is the model for that case?"

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "The examples I chose were Low, Medium, and Critical — no High example. What effect do you think that has on the model's behavior for High-severity alerts?"

After student answers, confirm: the model will interpolate, but that specific class is less calibrated. The fix is to add a High-severity example to the set.

**What to observe:**
- Output consistency increases with examples
- classification_reason style is now calibrated to the examples
- Missing example classes are a real gap — the model will interpolate but with less confidence
- Example quality affects output quality directly

---

## Step 5 — Validation Loop: Catching a Real Error

Now we'll demonstrate a validation loop. We'll intentionally use a slightly weaker prompt for the first call to generate a classification to review, then run a reviewer call.

**Primary classification (Call 1):**

Use the Step 2 prompt (basic format, no schema). Run it on ALERT-2847. Save the output — note the severity label returned.

**Now the reviewer prompt (Call 2):**

```
You are a senior security analyst reviewing an automated alert classification for accuracy.

The alert below was classified as [INSERT SEVERITY FROM CALL 1].

Your job: determine if that classification is correct based on the alert content.

Alert:
ALERT-2847: Outbound DNS query to domain registered 3 days ago. 
Query volume: 847 requests in 90 minutes from host WKSTN-114. 
Process origin: svchost.exe. GeoIP: destination resolves to server in Moldova.
No established baseline for this host. User: contractor account (inactive 60 days).

SecurePath severity definitions:
- Critical: Active exploitation confirmed or imminent; requires immediate escalation
- High: Indicators of compromise present; requires analyst review within 2 hours
- Medium: Anomalous behavior, no confirmed exploitation; review within 24 hours
- Low: Informational; no action required unless pattern repeats

Return a JSON object:
{
  "classification_valid": true | false,
  "original_severity": "[INSERT SEVERITY]",
  "corrected_severity": "Critical | High | Medium | Low | null",
  "reviewer_confidence": "High | Medium | Low",
  "reviewer_note": "<one sentence, max 25 words>"
}

If the classification is valid, set corrected_severity to null.
Return only the JSON.
```

**Run Call 2 live.** Let the student see the reviewer's output.

> **Instructor — narrate after reviewer output appears:**
>
> *Practitioner:* "Notice what just happened. The reviewer was given the definitions that the primary prompt didn't have. That's intentional — the reviewer prompt is calibrated differently. It has criteria; the primary prompt was intentionally weak to create something to review. In a real system, you'd use the reviewer to catch edge cases that the primary prompt misses at scale."
>
> *Socratic:* "Look at what the reviewer did or didn't change. Why do you think the reviewer agreed or disagreed? What information did the reviewer have that influenced the decision?"
>
> *Coach:* "See the pattern? The reviewer isn't re-doing the classification from scratch — it's checking whether the original classification is defensible against the criteria. That's a different cognitive task, and it catches different errors."
>
> *Challenger:* "The reviewer had the severity definitions but the primary classifier didn't. That's an unfair comparison — you rigged it. In a real system, you'd have the same definitions in both prompts. So what would the reviewer actually add in a well-engineered system?"

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "In a real system where both the classifier and reviewer have the same definitions — what errors would the reviewer still catch that the classifier might miss?"

After student answers: the reviewer catches reasoning errors (classifying correctly by label but for wrong reasons), edge case misses (where the model's training data has a gap), and schema drift (fields present but not correctly derived from the alert content).

**What to observe:**
- The validation loop produces a machine-readable verdict
- The reviewer prompt is calibrated with criteria the primary prompt lacked (for demo purposes)
- The reviewer note captures the reasoning — useful for audit trails
- In production: only route to reviewer when primary confidence is Low or ambiguous=true

---

## Debrief

You just watched a single alert go through four prompt engineering iterations and a validation loop. Let's map what you saw to the exam concepts.

**The progression:**

| Step | What changed | What improved | What was lost |
|------|-------------|---------------|---------------|
| 1. Raw ask | Nothing — just a question | Readable output | Parseable output |
| 2. Format constraint | Single-word output required | Parseable output | Reasoning, ambiguity signal |
| 3. JSON schema | Full structured schema defined | All fields captured, ambiguity surfaced | Nothing lost; build on this |
| 4. Few-shot examples | Examples added to calibrate | Consistency, calibrated style | Still missing High example |
| 5. Validation loop | Reviewer call added | Error catching, audit trail | Cost (2 calls); latency |

**The exam connections:**

- **Explicit criteria** — Step 3's severity definitions are what make classifications auditable
- **Few-shot prompting** — Step 4 calibrated the model; missing High example is a real gap
- **Structured output** — Step 3 onward; schema design is testable
- **Validation loops** — Step 5 pattern; exam asks when it's worth the cost
- **Prompt injection** — ALERT-2847 contained benign text, but what if it contained instructions? Step 3's schema would have caught malformed output; structural separation would prevent injection

> **Instructor — closing debrief in persona voice:**
>
> *Practitioner:* "The progression you just saw is how you'd actually build this at SecurePath — start with something that runs, observe where it fails, add structure, add calibration, add validation. No one writes the Step 4 prompt first. You earn it."
>
> *Socratic:* "One question before we move on: if you had to pick the single most impactful change in that progression — which step had the highest return on engineering effort? Why?"
>
> *Coach:* "You just built a complete mental model of prompt engineering progression. Step 1 to Step 4 is a journey you can replicate for any task. The validation loop is your safety net. That's a complete toolkit."
>
> *Challenger:* "Final question: what would break first in that Step 4 prompt if SecurePath switched alert types — say, moving from network alerts to endpoint alerts? Is the prompt portable, or does it need to be rebuilt? Specific answer."

---

## What's Next

The demo showed you the principles in action. The lab puts them in your hands.

Open `exercises/domain-4-lab.md` — you'll engineer a prompt from scratch for a new SecurePath scenario.
