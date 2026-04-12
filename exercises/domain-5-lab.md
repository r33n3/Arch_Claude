# Domain 5 Lab — Reliability Audit

> **Instructor note:** This is a student-driven lab. Deliver the scenario and requirements, then step back. The student works independently. Your role is to ask questions if they get stuck, not to narrate. Debrief after the student submits all four deliverables.

---

## Overview

You're going to audit a real (fictional) agentic system for reliability problems. The system has three specific problems embedded in its design. Your job is to:

1. Find all three problems and name them precisely
2. Rewrite the affected sections with working fixes
3. Document your observability and testing plan
4. Synthesize how the problems connect back across all 5 domains

**This is a capstone exercise.** It draws on everything from Domains 1–5. By the end, you should be able to trace every fix you make back to a concept you've learned in this course.

**Time estimate:** 45–60 minutes.

---

## The System: SecurePath Systems — Automated Threat Intelligence Aggregator

**SecurePath Systems** operates a threat intelligence platform for enterprise security teams. They've built a multi-agent system that aggregates threat intelligence from multiple sources, correlates it, and generates analyst briefings.

### Architecture

**Coordinator:** `ThreatCoordinator`
- Receives daily briefing requests from security analysts
- Maintains a running context of the analyst's current investigations
- Dispatches to three specialized subagents
- Synthesizes outputs into a final analyst briefing

**Subagents:**
1. **VulnFeed Agent** — pulls from public vulnerability databases (CVE feeds, NVD), returns structured JSON of new CVEs relevant to the analyst's tracked systems
2. **ThreatActor Agent** — queries an internal threat actor database, returns recent activity attributed to tracked threat actor groups
3. **IncidentCorrelator Agent** — compares incoming threat data against the analyst's open incident tickets, identifies potential connections

**Delivery:** Final briefing is emailed to the analyst and appended to a running briefing log file.

---

### Current Implementation

Here is the relevant implementation code and configuration. Read it carefully — the three reliability problems are embedded in it.

---

**`coordinator.py` (abbreviated)**

```python
class ThreatCoordinator:
    
    def __init__(self, analyst_id: str):
        self.analyst_id = analyst_id
        self.client = anthropic.Anthropic()
        self.conversation_history = []  # grows unbounded per analyst session
    
    def run_daily_briefing(self, analyst_context: dict):
        """
        Main entry point. Builds the full briefing request and dispatches subagents.
        """
        # Build context block — includes full conversation history + analyst profile
        context_block = self._build_context(analyst_context)
        
        # Dispatch all three subagents in parallel
        vuln_result = self._run_vuln_feed(context_block)
        threat_result = self._run_threat_actor(context_block)
        incident_result = self._run_incident_correlator(context_block)
        
        # Synthesize and deliver
        briefing = self._synthesize(vuln_result, threat_result, incident_result)
        self._deliver(briefing)
        return briefing
    
    def _build_context(self, analyst_context: dict) -> str:
        """
        Builds the full context block for subagents.
        Includes full conversation history, analyst profile, tracked systems, open incidents.
        """
        return f"""
        ANALYST PROFILE: {analyst_context['profile']}
        TRACKED SYSTEMS: {analyst_context['tracked_systems']}
        OPEN INCIDENTS: {analyst_context['open_incidents']}
        CONVERSATION HISTORY: {json.dumps(self.conversation_history)}
        TODAY: {datetime.now().isoformat()}
        """
    
    def _run_vuln_feed(self, context: str) -> dict:
        """Runs the VulnFeed subagent."""
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-latest",
                max_tokens=4096,
                system=VULN_FEED_SYSTEM_PROMPT,
                messages=[{"role": "user", "content": f"{context}\n\nRun vulnerability feed analysis."}]
            )
            return {"status": "success", "data": response.content[0].text}
        except Exception as e:
            return {"status": "error", "data": str(e)}
    
    def _run_threat_actor(self, context: str) -> dict:
        """Runs the ThreatActor subagent."""
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-latest",
                max_tokens=4096,
                system=THREAT_ACTOR_SYSTEM_PROMPT,
                messages=[{"role": "user", "content": f"{context}\n\nRun threat actor analysis."}]
            )
            return {"status": "success", "data": response.content[0].text}
        except Exception as e:
            return {"status": "error", "data": str(e)}
    
    def _run_incident_correlator(self, context: str) -> dict:
        """Runs the IncidentCorrelator subagent."""
        try:
            response = self.client.messages.create(
                model="claude-3-5-sonnet-latest",
                max_tokens=4096,
                system=INCIDENT_CORRELATOR_SYSTEM_PROMPT,
                messages=[{"role": "user", "content": f"{context}\n\nRun incident correlation."}]
            )
            return {"status": "success", "data": response.content[0].text}
        except Exception as e:
            return {"status": "error", "data": str(e)}
    
    def _synthesize(self, vuln: dict, threat: dict, incident: dict) -> str:
        """
        Synthesizes the three subagent results into a briefing.
        Fails silently if any subagent returned an error.
        """
        if vuln["status"] == "success":
            vuln_section = vuln["data"]
        else:
            vuln_section = "Vulnerability feed unavailable."
        
        if threat["status"] == "success":
            threat_section = threat["data"]
        else:
            threat_section = "Threat actor data unavailable."
        
        if incident["status"] == "success":
            incident_section = incident["data"]
        else:
            incident_section = "Incident correlation unavailable."
        
        return f"""
        DAILY THREAT INTELLIGENCE BRIEFING
        
        VULNERABILITIES:
        {vuln_section}
        
        THREAT ACTOR ACTIVITY:
        {threat_section}
        
        INCIDENT CORRELATIONS:
        {incident_section}
        """
    
    def _deliver(self, briefing: str):
        """Delivers briefing via email and appends to log."""
        send_email(self.analyst_id, briefing)
        with open(f"logs/briefings_{self.analyst_id}.log", "a") as f:
            f.write(briefing + "\n---\n")
```

---

**`deploy_config.py` (abbreviated)**

```python
# Deployment configuration for ThreatCoordinator

# Model configuration
MODEL = "claude-3-5-sonnet-latest"  # always latest

# Subagent configuration
SUBAGENT_TIMEOUT = None  # no timeout set
MAX_RETRIES = 0          # no retry logic

# Analyst session configuration  
MAX_CONVERSATION_HISTORY = None  # no limit on history size

# Logging configuration
LOG_LEVEL = "INFO"
LOG_SUBAGENT_INPUTS = False   # subagent inputs not logged
LOG_SUBAGENT_OUTPUTS = False  # subagent outputs not logged
LOG_CONTEXT_SIZE = False      # context token count not logged
LOG_FINAL_BRIEFING = True     # only the final briefing is logged
```

---

**Production behavior observed by the team:**

- New analysts: system works well, briefings are accurate and delivered quickly
- Analysts with 3+ months of history: system is slower, occasionally fails with no error message
- One senior analyst with 18 months of history: system fails silently about 40% of the time — briefing is delivered but some sections are blank, with no explanation
- When the SecurePath internal threat actor database goes down (happens ~2x/month): all three subagents fail, and the coordinator delivers a fully blank briefing
- After Anthropic released a new Claude version, the VulnFeed Agent's output format changed subtly — the coordinator's synthesis code broke for two weeks before anyone noticed

---

## Your Task

Work through all four deliverables below. Write your answers in this file or in a separate document — whatever works for you. The debrief at the end requires you to explain your reasoning, not just show the fix.

---

### Deliverable 1: Problem Identification

**Find all three reliability problems.** For each problem:
- Name it precisely (not just "it doesn't work" — use the correct vocabulary from Domain 5)
- Explain exactly where in the code or configuration it lives
- Describe the failure mode in production: what happens, when, and to whom
- Explain why the current behavior is wrong

**Hint:** You've seen all three problem types in this domain. One is a context management problem. One is a missing reliability pattern. One is a missing observability pattern. They're all in the code and config above.

---

### Deliverable 2: Rewrites

**Rewrite the affected sections with working fixes.** For each problem:
- Show the original code/config
- Show your fixed version
- Explain what changed and why

Requirements:
- Your context management fix must specify the strategy (truncation / summarization / selective retention) and justify the choice for this specific use case
- Your reliability fix must handle both transient and structural failures differently — show how
- Your observability fix must specify what is logged, in what format, and at which points in the execution flow

---

### Deliverable 3: Observability and Testing Plan

Write a short plan (bullet points are fine) covering:

**What you'd log:**
- List the specific events you'd instrument in this system
- For each event, specify: what data is captured, in what format, why it matters for debugging

**What you'd monitor:**
- List 3–5 production metrics you'd track for this system
- For each metric: what does it measure, what threshold triggers an alert, what does an alert indicate

**How you'd test it:**
- Describe how you'd verify the context management fix works correctly
- Describe how you'd test that the reliability fix correctly distinguishes transient vs. structural failures
- Describe how you'd catch the "model version upgrade changes output format" problem before it hits production

---

### Deliverable 4: Capstone Synthesis

This is the capstone exercise for the full course. Answer these questions as specifically as you can:

1. **Domain 1 connection:** The incident correlator subagent depends on the open incidents being passed in context. If the context management fix you implemented truncates or summarizes conversation history, what happens to open incidents that were discussed early in the conversation history? What architectural pattern from Domain 1 would solve this correctly?

2. **Domain 2 connection:** The ThreatActor Agent calls the SecurePath internal database as a tool. When the database goes down, the tool returns an error. The current code catches all exceptions the same way. How would better tool design (from Domain 2) have made this failure more diagnosable and recoverable?

3. **Domain 3 connection:** Where in a CLAUDE.md configuration would you put the reliability policies for this system — the timeout values, the retry parameters, the logging configuration? What's the advantage of putting them there vs. hardcoding them in `deploy_config.py`?

4. **Domain 4 connection:** After the model upgrade, the VulnFeed Agent's output format changed subtly. The synthesis code broke for two weeks. What prompt engineering pattern (from Domain 4) would have made the VulnFeed Agent's output format more stable across model versions? What would that prompt look like?

5. **Domain 5 synthesis:** If you had to pick one change from Deliverable 2 that would have the highest impact on this system's production reliability, which would it be and why? Make the argument in terms of: what failure mode it prevents, how frequently that failure mode occurs, and what the cost of that failure is to the analyst.

---

## Lab Debrief

After you've submitted all four deliverables, the instructor will debrief. Here's what the debrief covers:

> **Instructor — debrief in persona voice:**
>
> *Practitioner:* "Walk me through your problem identification first. Three problems — name them, one sentence each. Then we'll look at your fixes."
>
> *Socratic:* "Before I tell you whether you found the right three problems — tell me which one you're least confident about. What made it harder to identify than the others?"
>
> *Coach:* "Let's go through what you built! Start with the one you're most proud of — what fix do you think has the highest impact on this system, and why?"
>
> *Challenger:* "Your context management fix: which strategy did you choose, and why that one for this specific system? Walk me through the trade-offs you considered and why you rejected the alternatives."

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "Before I give you feedback: in your Deliverable 4 synthesis, which domain connection was hardest to make? Where do you still feel uncertain about how Domain 5 connects back to the earlier material?"

---

### Answer Key (Instructor Only)

> **Do not share this with the student until after they've submitted all four deliverables.**

**Problem 1: Context overflow risk (context management)**

Location: `_build_context()` + `MAX_CONVERSATION_HISTORY = None` in deploy_config

Failure mode: `self.conversation_history` grows unbounded. After 3+ months of daily briefings, the conversation history alone approaches and eventually exceeds context limits. Senior analyst with 18-month history is hitting context limit errors ~40% of the time — the "fails silently" behavior is the exception handler swallowing the `anthropic.APIStatusError` for context overflow.

Correct fix: Implement conversation history management. For this use case, selective retention is most appropriate (not truncation) — the open incidents from months ago are still relevant to correlation. A better approach: maintain a structured "analyst state" file with tracked systems, open incidents, and key findings — pass that as structured context rather than raw conversation history. Summarize narrative exchanges.

**Problem 2: Missing retry logic (reliability pattern)**

Location: `MAX_RETRIES = 0` and `SUBAGENT_TIMEOUT = None` in deploy_config; exception handling in `_run_*` methods catches all exceptions identically

Failure mode: When the internal ThreatActor database goes down (2x/month), the subagent returns an error. No retry means transient failures (database restart, brief network issue) always result in a blank section. No timeout means a slow database can hang the entire coordinator indefinitely. The `except Exception` block treats all errors the same — rate limits, context overflow, network errors, authentication failures.

Correct fix: Add timeout per subagent invocation (suggest: 30–60s for this use case). Add retry with exponential backoff for transient errors (HTTP 429, HTTP 503, network timeout). Do not retry structural errors (HTTP 400, HTTP 401, HTTP 413). Return PartialResult with specific failure reason rather than blank section.

**Problem 3: Missing observability (logging)**

Location: `deploy_config.py` — `LOG_SUBAGENT_INPUTS = False`, `LOG_SUBAGENT_OUTPUTS = False`, `LOG_CONTEXT_SIZE = False`. Only final briefing is logged.

Failure mode: The two-week model upgrade incident — nobody noticed the VulnFeed output format changed because the subagent output was never logged. The coordinator's synthesis code silently produced malformed briefings that looked complete but were structurally wrong. Without subagent output logs, there's no way to detect the regression or diagnose why synthesis broke.

Correct fix: Log every subagent invocation with trace ID: input tokens, output tokens, response (structured), latency, error if any. Log context size at each request. Use structured logging (JSON) for queryability. Add a structural validation step after synthesis: verify the briefing has the expected sections before delivery.

---

### Capstone Synthesis Answers (Discussion Points)

**Domain 1:** Open incidents as external memory (not conversation history) — the architectural fix is to maintain a separate `analyst_state` document tracking open incidents, decisions, and constraints. This is the selective retention pattern applied at the architecture level.

**Domain 2:** A well-designed tool would return structured error types (database_unavailable vs. record_not_found vs. auth_error) rather than raw exceptions. The coordinator can then make intelligent retry decisions based on error type rather than treating all failures as the same class.

**Domain 3:** CLAUDE.md is where you'd document the operating parameters for this system — retry policy, timeout values, context limits, logging requirements. Advantage: they're readable by the Claude agent itself, not just the Python runtime. An agent running in this context can understand and apply them. `deploy_config.py` is for the Python runtime; CLAUDE.md is for the agent.

**Domain 4:** Structured output prompt engineering — explicitly specify the JSON schema the VulnFeed Agent must return and include a few-shot example in the system prompt. This makes the output format explicit and resistant to model version changes in tone/style. The agent may still upgrade, but the output contract is specified in the prompt.

**Domain 5 synthesis:** The context overflow problem (Problem 1) has the highest long-term impact — it's deterministic, worsens over time, affects the most valuable analysts (those with the longest history), and causes silent degradation rather than clear errors. The blank briefing 40% of the time for senior analysts is more damaging than occasional ThreatActor unavailability.

---

## What's Next

You've completed the Domain 5 lab and the full CCA Foundations curriculum.

> **Instructor:** Run the Domain 5 checkpoint now (in `domains/domain-5-context-reliability.md`). Collect confidence levels, update `.student_cca/progress.md`, and check whether all 5 domains are complete.

If all 5 domains are complete:

> "You've built everything — orchestrated agentic systems, designed tools, configured Claude Code, engineered prompts, and audited for reliability. That's the full CCA Foundations curriculum. Ready to generate your readiness report? Say **'generate my readiness report'** when you are."
