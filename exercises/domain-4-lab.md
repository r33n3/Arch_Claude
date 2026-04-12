# Domain 4 — Lab: Engineering a Structured Output Prompt

> **Instructor note:** This lab is student-driven. The instructor's role is to ask the right questions at each step, not to show the answers. Each step has a deliverable the student produces before moving on. The final debrief maps the lab directly to CCA exam question patterns.

---

## Lab Overview

**What you'll build:** A complete, production-ready prompt for a structured output task — including explicit criteria, a JSON output schema, two few-shot examples, and a validation step.

**Estimated time:** 45–60 minutes

**What you need:** Claude Code or a Claude API session. No other tools required.

**Scenario:** SecurePath Systems has expanded their automated analysis beyond alert classification. Their threat intelligence team receives daily vendor security bulletins — PDFs and plain-text emails describing newly disclosed vulnerabilities. Right now, analysts read each bulletin manually and enter data into a tracking spreadsheet. There are 30–50 bulletins per day.

Your job: engineer a prompt that extracts structured data from vendor security bulletins reliably enough to automate that spreadsheet entry.

---

## The Raw Data

Here is a fictional vendor bulletin. You'll use this as your test case throughout the lab.

```
BULLETIN: Vendor Advisory #VA-2024-0892
Source: Meridian Network Appliances
Date: 2024-04-09
Product: MeriGate Firewall OS, versions 7.1.x through 7.4.x

SUMMARY:
A remotely exploitable buffer overflow vulnerability has been identified in the 
MeriGate web management interface. An unauthenticated attacker with network 
access to the management port (default: TCP 8443) can trigger arbitrary code 
execution. CVSS v3 Base Score: 9.8 (Critical).

AFFECTED:
- MeriGate Firewall OS 7.1.0 through 7.1.9
- MeriGate Firewall OS 7.2.x (all versions)
- MeriGate Firewall OS 7.3.x (all versions)
- MeriGate Firewall OS 7.4.0 through 7.4.2
NOT AFFECTED: Versions 7.4.3 and later, all 8.x releases

REMEDIATION:
Upgrade to version 7.4.3 or later. If immediate upgrade is not possible, 
disable remote access to the management interface or restrict management 
port access to a trusted IP allowlist.

CVE: CVE-2024-31847
CVSS: 9.8 Critical
Patch available: Yes
Workaround available: Yes
```

And a second bulletin to use for your second few-shot example:

```
BULLETIN: Product Notice #PN-1204
Source: ClearPath Authentication Solutions
Date: 2024-04-07
Product: ClearPath SSO Agent for Windows, version 4.2.1

SUMMARY:
An information disclosure vulnerability in the ClearPath SSO Agent debug logging 
feature may expose session tokens to the local filesystem in plaintext. 
This issue requires local access and is only triggered when debug logging is 
enabled. CVSS v3 Base Score: 4.3 (Medium).

AFFECTED:
- ClearPath SSO Agent for Windows, version 4.2.1 only

REMEDIATION:
Disable debug logging in production environments. A patch (version 4.2.2) 
is available and resolves the issue.

CVE: CVE-2024-29104
CVSS: 4.3 Medium
Patch available: Yes
Workaround available: Yes (disable debug logging)
```

---

## Step 1 — Observe Before You Design

Before writing any prompt, run the raw ask.

**Your prompt (use this exactly):**

```
Extract the key information from this security bulletin:

[paste Bulletin VA-2024-0892]
```

Run it. Read the output carefully.

**Deliverable — answer these three questions in writing before moving on:**

1. What format did Claude use for the output?
2. Which fields would you need for a database or spreadsheet? Are all of them present?
3. If you ran this 50 times on different bulletins, what would vary between runs?

> **Instructor:**
>
> *Practitioner:* "Write those answers down — not in your head. You'll compare them to your final prompt's output at the end of the lab."
>
> *Socratic:* "Before you move on: what's the most important field that might be missing from that output? Think about what SecurePath analysts need to make a decision about each bulletin."
>
> *Coach:* "Great first step — you've established a baseline. Everything you build from here is measured against that raw output. Keep it handy."
>
> *Challenger:* "Three questions, specific answers. Don't summarize — name the exact fields that are or aren't there. 'It gave a summary' is not an answer. What were the actual field names?"

---

## Step 2 — Design the Output Schema

Before writing your prompt, design the output schema. This is a design decision, not a prompt-writing task.

**The question:** What fields does SecurePath's tracking spreadsheet need?

Based on the bulletin above, design a JSON schema with at least 8 fields. Your schema should capture everything an analyst would need to:
- Prioritize which bulletins to address first
- Know which SecurePath systems are affected
- Know what action to take and how urgently
- Have an audit trail of when the bulletin was processed

**Deliverable — write your schema here before continuing:**

```json
{
  // Your schema here
  // Each field should have a name, type, and allowed values where applicable
}
```

**Guidance — fields to consider (do not copy these; use them as a starting point):**

- Bulletin identifier
- Source vendor
- Affected product name and version range
- CVE identifier
- CVSS score and severity label
- Exploitation requirements (remote/local? authenticated/unauthenticated?)
- Patch available (boolean)
- Workaround available (boolean)
- Recommended action (upgrade / disable feature / restrict access / monitor)
- Urgency level for SecurePath (this is a judgment call — define what drives it)
- Date received or bulletin date

> **Instructor:**
>
> *Practitioner:* "Don't over-engineer the schema. Start with what the analyst actually uses to make a decision. Every field you add is a field that can be wrong."
>
> *Socratic:* "What's the difference between 'CVSS score' and 'urgency level for SecurePath'? They're related — but not the same. What might make a 9.8 CVSS bulletin lower urgency for SecurePath specifically?"
>
> *Coach:* "This is a real design skill — figuring out what data you actually need before you write a single line of prompt. You're doing the work an architect does before implementation."
>
> *Challenger:* "Is 'urgency level' something Claude should derive from the bulletin data, or something an analyst should set? If Claude derives it, what criteria would you give it? If it's analyst-set, what's in the schema for it?"

---

## Step 3 — Write the Prompt with Explicit Criteria

Now write the full prompt. It must include:

- [ ] The output schema (from Step 2) embedded directly in the prompt
- [ ] Explicit definitions for any enumerated fields (e.g., what does "Critical urgency" mean for SecurePath?)
- [ ] Instructions for handling missing data (what if the bulletin doesn't include a CVE?)
- [ ] Output format constraint ("Return only the JSON. No preamble.")

**Your prompt:**

```
[Write your full prompt here]
```

**Test it on Bulletin VA-2024-0892.** Paste the bulletin at the end of your prompt. Run it.

**Deliverable — evaluate your output against these criteria:**

1. Does the JSON parse without errors? (Try pasting it into a JSON validator)
2. Are all required fields present?
3. Is the urgency level consistent with what an analyst would assign?
4. If the output had a field missing, what would you change in the prompt?

> **Instructor:**
>
> *Practitioner:* "Run your prompt, then try to break it. Submit a bulletin that's missing the CVE. Submit one where the CVSS score isn't stated explicitly. Those edge cases are what will fail in production."
>
> *Socratic:* "What did you have to define explicitly that you assumed Claude would 'just know'? What assumption did you have to make explicit to get consistent output?"
>
> *Coach:* "If the JSON didn't parse, that's actually a great learning moment — it tells you exactly where the schema instruction wasn't specific enough. Look at what Claude did instead of what you asked for."
>
> *Challenger:* "If your prompt produced valid JSON — that's step one, not step done. Run it twice. Did you get the same output both times? If not, what's varying? That variation is your next fix target."

---

## Step 4 — Add Two Few-Shot Examples

Take your prompt from Step 3. Add two few-shot examples before the bulletin you want classified.

**Requirements for your examples:**
- Example 1 must be a high-severity bulletin (use Bulletin VA-2024-0892)
- Example 2 must be a lower-severity bulletin (use Bulletin PN-1204)
- Each example must show the complete expected JSON output (not a partial output)
- The examples must use the same schema as your main prompt

**Your updated prompt structure:**

```
[Your criteria and schema from Step 3]

Examples:

Input: [Bulletin VA-2024-0892 text]
Output: [Complete JSON output for VA-2024-0892]

Input: [Bulletin PN-1204 text]
Output: [Complete JSON output for PN-1204]

Now process:

Input: [New bulletin to classify]
Output:
```

**Test bulletin — use this as your new input (do not use one of your examples):**

```
BULLETIN: Security Notice #SN-0441
Source: Fortress Database Systems  
Date: 2024-04-10
Product: Fortress DB Enterprise, version 12.0 – 12.3.1

SUMMARY:
A SQL injection vulnerability in the Fortress DB administrative console allows
an authenticated administrator to execute arbitrary SQL commands against the
underlying database engine. Exploitation requires valid admin credentials.
CVSS v3 Base Score: 6.5 (Medium).

AFFECTED:
- Fortress DB Enterprise versions 12.0 through 12.3.1
NOT AFFECTED: Version 12.3.2 and later

REMEDIATION:
Upgrade to version 12.3.2. No workaround available for the SQL injection;
limit admin console access to trusted networks.

CVE: CVE-2024-30012
CVSS: 6.5 Medium
Patch available: Yes
Workaround available: Partial (network restriction)
```

**Deliverable — answer these questions:**

1. What changed in the output quality compared to your Step 3 prompt (no examples)?
2. Did the examples calibrate the urgency level for the medium-severity case? Is it consistent with what an analyst would expect?
3. What would a third example add — and what type of bulletin would you choose for it?

> **Instructor:**
>
> *Practitioner:* "The second example is as important as the first. If you only have a Critical example, the model has no calibration for Medium or Low. Distribution matters."
>
> *Socratic:* "The test bulletin is Medium-severity. Your examples were Critical and Low-Medium. How well-calibrated is the model for a true Medium case? What does the output tell you?"
>
> *Coach:* "You now have a few-shot calibrated prompt. This is production-grade. Notice the difference from Step 1 — that's the full arc of prompt engineering in one lab."
>
> *Challenger:* "The test bulletin has a 'partial' workaround. Your schema probably has a boolean for 'workaround available.' How did Claude handle that? Is the output correct? What schema change would make that field more precise?"

---

## Step 5 — Add a Validation Step

Write a reviewer prompt that checks the output of your main prompt.

**Your reviewer prompt must:**
- Accept the original bulletin text AND the structured output from your main prompt as inputs
- Check: are all required fields present and correctly derived from the bulletin?
- Check: is the urgency level consistent with the CVSS score and exploitation requirements?
- Return a JSON verdict: `{valid: true/false, issues: [...], corrected_fields: {...}}`

**Template to adapt:**

```
You are reviewing an automated extraction of a security bulletin for accuracy.

Below is the original bulletin and the structured output that was generated from it.

Your job: verify that the structured output is accurate and complete.

Check:
1. Are all required fields present?
2. Are the field values correctly derived from the bulletin? (not invented or incorrect)
3. Is the urgency level consistent with the CVSS score and exploitation requirements?

Return a JSON object:
{
  "valid": true | false,
  "issues": ["<issue 1>", "<issue 2>"],
  "corrected_fields": {
    "<field_name>": "<corrected_value>"
  }
}

If no issues are found, return {"valid": true, "issues": [], "corrected_fields": {}}.
Return only the JSON.

Original bulletin:
[paste bulletin]

Structured output to review:
[paste your main prompt's output]
```

**Run the validator** on the test bulletin's output from Step 4.

**Deliverable — answer these questions:**

1. Did the validator find any issues? If yes, what were they?
2. What would you do with a `valid: false` response in a production pipeline?
3. At what point in the process would you trigger the validator — on every bulletin, or only when the main prompt's output is uncertain?

> **Instructor:**
>
> *Practitioner:* "In production at SecurePath: the validator runs on every bulletin where urgency is Critical or High. For Medium and Low, it's sampled — maybe 10%. You calibrate that based on the error rate you observe."
>
> *Socratic:* "Think about what the validator is checking versus what it can't check. It can verify that fields are present and values are plausible. What can it NOT verify? What would require a human to catch?"
>
> *Coach:* "You've now built a complete two-pass system. The main prompt extracts; the validator reviews. That's the validation loop pattern from the domain content — you built it yourself. How does it feel different having built it versus having read about it?"
>
> *Challenger:* "The validator prompt you wrote — what are its failure modes? Under what conditions would it report 'valid: true' for an output that's actually wrong? Describe a specific example."

---

## Step 6 — Iteration: Explain What You Changed and Why

Based on your testing across Steps 3–5, you've probably made changes to your prompt. This step makes the iteration process explicit.

**Deliverable — write a brief iteration log:**

```
## Iteration Log

### Change 1
What I changed: 
Why I changed it: 
What I observed that triggered the change:

### Change 2
What I changed:
Why I changed it:
What I observed that triggered the change:

[Add more as needed]
```

If you haven't made any changes yet — go back and deliberately try to break your prompt. Submit a bulletin that's missing a field. Submit one with an unusual format. Note what breaks and fix it.

> **Instructor:**
>
> *Practitioner:* "The iteration log is the most valuable artifact you'll produce in this lab. It's the engineering decision record for your prompt. In a team, this is how you hand off a prompt to someone else without them having to rediscover every edge case."
>
> *Socratic:* "What was the hardest edge case you encountered? What about the bulletin data made it hard? And what would the prompt need to handle it correctly?"
>
> *Coach:* "Iteration is the job. Nobody writes a perfect prompt on the first try — the skill is knowing what to observe and what to fix. You've practiced that skill in this lab."
>
> *Challenger:* "If you handed this prompt to a junior analyst with no context and asked them to maintain it — what would they get wrong? What's implicit in your design that needs to be made explicit?"

---

## Lab Debrief

Map your lab work to the CCA exam question patterns. For each pattern, note where in your lab you encountered it.

> **Instructor — lead the debrief in persona voice:**
>
> *Practitioner:* "CCA exam questions in Domain 4 are applied — they give you a broken system and ask you to diagnose it. Let me show you the patterns."
>
> *Socratic:* "Before I show you the exam patterns — can you map each of your lab steps to a Domain 4 concept? Which concept did each step practice?"
>
> *Coach:* "Let's connect what you built to what the exam tests. Every step you completed maps to at least one exam concept."
>
> *Challenger:* "I'm going to show you the exam patterns. For each one, tell me: which step in your lab was the direct practice for that pattern? Specific step number."

**CCA Exam Pattern Mapping:**

| Exam pattern | What it tests | Your lab step |
|---|---|---|
| "A prompt returns inconsistent output across similar inputs. What's the most likely cause?" | Underspecified criteria; missing explicit definitions | Step 1 observation → Step 3 fix |
| "A structured output prompt returns extra fields not in the schema. How do you prevent this?" | Schema constraint instructions; explicit "return only these fields" | Step 3 schema design |
| "You need to process 10,000 documents overnight. Which API pattern is appropriate?" | Batch API vs. real-time; latency vs. cost trade-off | Domain 4 content (Batch API section) |
| "A reviewer prompt agrees with an incorrect classification. What's the most likely cause?" | Correlated failure modes; same system prompt in both calls | Step 5 validation design |
| "User-supplied content in a prompt causes the model to ignore its instructions. What is this attack?" | Prompt injection; structural separation defense | Step 3 (if you added structural separation) |
| "A classification prompt has good results in testing but fails on live data. What changed?" | Distribution shift; test examples don't match production data | Step 4 few-shot calibration |
| "What belongs in the system prompt vs. the user turn?" | Persistent vs. session-level instructions; security boundary | Step 3 prompt structure |

**Final question for the student:**

> "Which of your lab steps do you feel least confident about? That's the one to review in the domain content before the exam. Look at the Concept Walkthrough section for that topic and re-read it with your lab experience in mind."

---

## Checkpoint

When you've completed all six steps and the debrief:

1. Save your final prompt, your two few-shot examples, and your validation prompt somewhere accessible
2. Keep your iteration log — it's the best study material for Domain 4 exam questions
3. Return to `domains/domain-4-prompt-engineering.md` and complete the Domain Checkpoint section

The checkpoint will update your `.student_cca/progress.md` and surface any weak areas to revisit before moving to Domain 5.
