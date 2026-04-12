# Domain 2 Demo — Tool Design in Action

> **Instructor note:** This is a live demo. Run every narration block in the student's current persona. All 4 persona variants are present at each step. Socratic questions are mandatory — wait for a real student response before continuing. If a live invocation fails, narrate what would have happened and continue.

---

## Setup

You're about to watch tool design choices play out in real time.

Not a diagram. Actual tool definitions, actual agent behavior, actual results — demonstrating how the design choices you make in a tool schema change what an agent does.

You'll see:
- A poorly-designed tool description vs. a well-designed one — and observe the difference in model behavior
- A structured error response in action — tool fails, agent recovers
- `tool_choice` options changing how the agent behaves

**Scenario: MedRoute Health — Patient Intake Triage**

MedRoute Health routes incoming patient intake forms to the correct clinical department. An intake agent reads each form and decides where to route the patient. The routing tool is the critical action in this pipeline.

---

## Step 1: The Poorly-Designed Tool

> **Instructor — narrate before showing the definition:**
>
> *Practitioner:* "Here's what most tool definitions look like in production systems built by developers who haven't thought about how the model reads descriptions. Watch what happens."
>
> *Socratic:* "Before I show you the first tool definition — based on the exercise you did earlier, what do you predict will be missing from a poorly-designed tool description?"
>
> *Coach:* "We're starting with a bad example on purpose. Seeing what goes wrong helps you understand what to avoid. Look at this tool definition and notice what's not there."
>
> *Challenger:* "I'm going to show you a tool definition that will cause real problems in a healthcare routing system. Before I explain what's wrong — identify it yourself."

**[SOCRATIC QUESTION — wait for student response before continuing]**

> "What do you think is missing from a typical first-draft tool description?"

After student responds, acknowledge in persona voice, then show the definition.

---

### Poor Tool Definition

```python
tools = [
    {
        "name": "route_patient",
        "description": "Routes a patient to a department.",
        "input_schema": {
            "type": "object",
            "properties": {
                "patient_id": {"type": "string"},
                "department": {"type": "string"},
                "urgency": {"type": "integer"},
                "reason": {"type": "string"}
            },
            "required": ["patient_id", "department"]
        }
    }
]
```

**Now watch the agent use it.**

Agent prompt: *"Patient intake form received: James Chen, 42yo, chest pain, shortness of breath, onset 30 minutes ago. Patient rates pain 8/10. No known cardiac history."*

**What the agent does with the poor tool:**

The model calls `route_patient` with:
```json
{
  "patient_id": "James Chen",
  "department": "cardiology",
  "urgency": 8,
  "reason": "chest pain"
}
```

**Problems:**
- `patient_id` should be a system identifier, not a name — the model used what was available
- `"cardiology"` is not a valid department in the routing system — the model hallucinated a plausible value
- `urgency: 8` came from the patient's self-reported pain rating, not a clinical assessment
- `"chest pain"` as a reason is two words, not a clinical justification
- `urgency` and `reason` were optional — the model could have omitted them entirely

> **Instructor — debrief in persona voice:**
>
> *Practitioner:* "Every one of those problems is traceable to the description. The model did exactly what an intelligent system would do with underspecified instructions — it made reasonable guesses. In a healthcare routing system, a hallucinated department name means the patient doesn't get routed. A self-reported urgency score misrepresents clinical severity."
>
> *Socratic:* "Which of those problems would you have caught in testing? Which ones would slip through? Think about a test suite — what inputs would you need to expose each failure?"
>
> *Coach:* "Look at how predictable those failures are once you understand how the model reads descriptions. Every gap you leave gets filled with a guess. That's not a model limitation — it's a design constraint. And design constraints are fixable."
>
> *Challenger:* "Four distinct failure modes from one underspecified description. What's the clinical consequence of each one in a live healthcare system? Rank them by severity."

---

## Step 2: The Well-Designed Tool

> **Instructor — narrate before showing:**
>
> *Practitioner:* "Same tool, same task. Watch what changes when the description is designed as an instruction to the model rather than a summary for a developer."
>
> *Socratic:* "Before I show you the improved description — based on the failures you just saw, what would you add to fix each one? Try to write it yourself first."
>
> *Coach:* "Now we see the same scenario done right. Notice every design choice that addresses one of the failure modes we just identified."
>
> *Challenger:* "You saw four failure modes. The improved description should address all four. Keep score."

**[SOCRATIC QUESTION — wait for student response before continuing]**

> "If you were rewriting that description right now, what's the first change you'd make and why?"

After student responds, acknowledge in persona voice, then show the improved definition.

---

### Well-Designed Tool Definition

```python
tools = [
    {
        "name": "route_patient",
        "description": (
            "Routes a confirmed patient intake to a specific clinical department after triage "
            "assessment is complete. Call this tool only after determining the appropriate "
            "department based on the patient's clinical presentation — do not call speculatively. "
            "patient_id must be the system identifier from the intake form header (format: MRH-XXXX), "
            "not the patient's name. "
            "department must be exactly one of: emergency, urgent_care, primary_care, "
            "behavioral_health, specialist_referral. "
            "urgency must reflect clinical assessment (1=routine, 5=life-threatening) — "
            "do not use patient self-reported pain scores. "
            "reason must be a clinical justification of 10-50 words explaining why this routing "
            "decision was made."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "patient_id": {
                    "type": "string",
                    "description": "System patient identifier from intake form header. Format: MRH-XXXX."
                },
                "department": {
                    "type": "string",
                    "enum": ["emergency", "urgent_care", "primary_care", "behavioral_health", "specialist_referral"],
                    "description": "Target clinical department."
                },
                "urgency": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 5,
                    "description": "Clinical urgency score. 1=routine, 5=life-threatening. Based on clinical presentation, not patient self-report."
                },
                "reason": {
                    "type": "string",
                    "minLength": 10,
                    "maxLength": 200,
                    "description": "Clinical justification for this routing decision. 10-50 words."
                }
            },
            "required": ["patient_id", "department", "urgency", "reason"]
        }
    }
]
```

**Same agent prompt:** *"Patient intake form received. Intake ID: MRH-2947. James Chen, 42yo, chest pain, shortness of breath, onset 30 minutes ago. Patient rates pain 8/10. No known cardiac history."*

**What the agent does with the well-designed tool:**

The model calls `route_patient` with:
```json
{
  "patient_id": "MRH-2947",
  "department": "emergency",
  "urgency": 5,
  "reason": "42-year-old male presenting with acute chest pain and shortness of breath, 30-minute onset. Clinical presentation consistent with possible acute coronary syndrome. Requires immediate emergency evaluation."
}
```

**What changed:**
- `patient_id` is now `MRH-2947` — the model found the system ID in the intake form because the description told it to
- `"emergency"` is a valid enum value — the model selected from the constrained set
- `urgency: 5` reflects clinical presentation (possible ACS), not patient self-report
- `reason` is a proper clinical justification at appropriate length
- All four required fields are populated correctly

> **Instructor — debrief in persona voice:**
>
> *Practitioner:* "Same model. Same prompt. Different description. This is why tool design is its own skill — it's not about the model, it's about the specification. Everything in that description was placed there to prevent a specific failure mode you saw in version A."
>
> *Socratic:* "Look at the enum constraint on `department`. The model couldn't hallucinate 'cardiology' because it wasn't in the enum. Is that the description doing the work, or the schema? What's the difference between constraining via description vs. schema?"
>
> *Coach:* "Every single failure from Version A is gone. And notice: this wasn't harder to write once you knew what to include. The skill is knowing what to include — which you now do."
>
> *Challenger:* "Four failures, four fixes. But I want to push on one: the urgency score. The description says 'do not use patient self-reported pain scores.' What stops the model from doing it anyway? What would you add to make that constraint more robust?"

---

## Step 3: Structured Error Response

> **Instructor — set up the scenario:**
>
> *Practitioner:* "Tools fail. What matters is how they fail. Watch the difference between an error that halts the agent and an error the agent can recover from."
>
> *Socratic:* "Before I show you the error scenario — think about what information an agent needs to recover from a failed tool call. What does the model need to know to decide what to do next?"
>
> *Coach:* "Now we're going to see what happens when something goes wrong. This is where a lot of systems fall apart — but it doesn't have to. The key insight is coming up."
>
> *Challenger:* "Tool call fails. What are the possible next moves for the agent? List all of them. Then tell me which error response designs support each one."

**[SOCRATIC QUESTION — wait for student response before continuing]**

> "What information does an agent need from a failed tool call to decide what to do next?"

After student responds, acknowledge in persona voice, then continue.

---

### Scenario: Patient ID Not Found

The agent calls `route_patient` with patient_id `MRH-2947`, but the patient record isn't in the database yet — the intake form arrived before the record was created.

**Poor error response:**
```json
{"error": true, "message": "Not found"}
```

**What the agent does:** Stops. Reports an error to the user. No recovery.

**Well-designed error response:**
```json
{
  "status": "error",
  "error_code": "PATIENT_RECORD_NOT_FOUND",
  "error_message": "No patient record found for ID MRH-2947.",
  "recoverable": true,
  "retry_after_seconds": 30,
  "suggested_action": "Patient record may not yet be created in the system. Wait 30 seconds and retry. If the problem persists after 2 retries, escalate to the intake coordinator.",
  "escalation_contact": "intake-coordinator@medroute.health"
}
```

**What the agent does:** Waits 30 seconds. Retries. If successful, routes the patient. If not, escalates to the intake coordinator with the patient information.

> **Instructor — debrief in persona voice:**
>
> *Practitioner:* "The error response is a message to the model. Design it like you're writing instructions to the model about what just happened. `suggested_action` is the model's next step. `recoverable: true` tells the model not to give up. `escalation_contact` gives the model something to do if retry fails."
>
> *Socratic:* "What's the difference between `recoverable: true` and just including a `suggested_action`? Are they doing the same thing or different things?"
>
> *Coach:* "Notice how much information that error response packs in. The model gets: what happened, whether it can recover, how long to wait, what to do, and who to call if it can't recover. That's complete error handling."
>
> *Challenger:* "What's the failure mode of always setting `recoverable: true`? What happens if you design every error as recoverable?"

---

## Step 4: tool_choice in Action

> **Instructor — introduce the concept:**
>
> *Practitioner:* "Three use cases. Three different `tool_choice` values. Watch why each one is correct for its context."
>
> *Socratic:* "You know the three options: auto, any, and tool. Before I show the examples — match each option to a use case. When would you use each one in the MedRoute system?"
>
> *Coach:* "This is one of those concepts that's easy to get confused on the exam — not because it's complex, but because the use cases can feel similar. The examples will make the distinction concrete."
>
> *Challenger:* "Three options. The exam will give you a scenario and ask which one is correct. The wrong answer is 'it depends.' You need to be able to reason from the use case to the correct choice. Let's do that now."

---

### tool_choice: auto

**Use case:** Agent analyzing an intake form — might need to look up patient history, might not.

```python
response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=1024,
    tools=medroute_tools,
    tool_choice={"type": "auto"},  # Model decides if/when to call tools
    messages=[{
        "role": "user",
        "content": "Review this intake form and determine next steps: [intake form text]"
    }]
)
```

**Why `auto`:** The model might determine the intake is complete and route immediately, or might decide to look up patient history first. The task is open-ended — let the model reason about what it needs.

---

### tool_choice: any

**Use case:** Patient intake is complete. A routing decision must be made. The model must call one of the routing tools, but we don't know which department.

```python
response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=1024,
    tools=department_routing_tools,  # One tool per department
    tool_choice={"type": "any"},  # Must call a tool; model picks which
    messages=[{
        "role": "user",
        "content": "Triage complete. Route this patient: [clinical assessment]"
    }]
)
```

**Why `any`:** We know a routing decision is required — the patient must be routed somewhere. But which department is a clinical judgment the model should make. `any` enforces that a decision gets made without constraining which decision.

---

### tool_choice: tool (forced)

**Use case:** Extract structured fields from unstructured intake notes for downstream processing.

```python
response = client.messages.create(
    model="claude-opus-4-5",
    max_tokens=1024,
    tools=extraction_tools,
    tool_choice={"type": "tool", "name": "extract_patient_fields"},  # Force this specific tool
    messages=[{
        "role": "user",
        "content": "Extract all structured fields from this intake note: [note text]"
    }]
)
```

**Why `tool`:** The output format is fixed. The downstream system expects a specific schema. There is no scenario in which we want the model to respond in text rather than calling the extraction tool. Forcing the tool eliminates ambiguity.

> **Instructor — debrief in persona voice:**
>
> *Practitioner:* "The pattern: `auto` for open-ended tasks, `any` when a tool call is required but the specific tool is a judgment call, `tool` when you need a specific output format and model discretion adds no value. On the exam, look for the keywords 'must call a tool' (any) and 'specific output format required' (tool)."
>
> *Socratic:* "Compare the `any` and `tool` use cases. What's the difference in what you're constraining? `any` constrains the quantity of tool calls; `tool` constrains which tool. When would that distinction matter?"
>
> *Coach:* "Three patterns, three use cases — and now you've seen each one in a real scenario. The MedRoute system uses all three at different points in the pipeline. That's normal. Real systems mix tool_choice values based on what each step requires."
>
> *Challenger:* "Exam question: A pipeline step requires the model to either call `get_patient_history` or `check_insurance_status` depending on what information is missing from the intake form. Which `tool_choice` do you use? Defend your answer."

---

## Demo Debrief

You've seen four core tool design concepts in action. Here's the mapping to the exam:

| Concept demonstrated | CCA exam tests |
|---|---|
| Poor vs. well-designed tool description | Understanding that description drives behavior, not just schema |
| Enum constraints in schema | Schema design for reliability — valid values prevent hallucination |
| Structured error responses | Recoverable vs. fatal errors; what information the agent needs to recover |
| tool_choice: auto / any / tool | Matching tool_choice to use case; forced vs. model-directed tool calling |

**One question before moving on:**

> *Practitioner:* "What's the one design change you'd make to your organization's tool definitions after what you just saw?"
>
> *Socratic:* "Looking back at the four scenarios — which one revealed the most unexpected thing about how tool design affects model behavior? What surprised you?"
>
> *Coach:* "Excellent work! You've now seen tool design in action, not just in theory. Take a moment — what clicked for you in this demo that didn't fully land in the reading?"
>
> *Challenger:* "One concept from this demo will be on the exam in a scenario you haven't seen. Which one are you least prepared to apply to an unfamiliar context? That's where to focus next."

---

## What's Next

Complete the Domain 2 lab: `exercises/domain-2-lab.md`

The lab gives you a scenario you haven't seen before and asks you to apply everything from this demo. It's the closest thing to actual exam practice in this domain.
