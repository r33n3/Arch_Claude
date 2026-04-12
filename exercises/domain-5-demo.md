# Domain 5 Demo — Reliability Patterns in Action

> **Instructor note:** This is a live walkthrough demo, not just a reading exercise. You will narrate each step in the student's chosen persona voice. Every narration block has 4 persona variants — deliver the one matching the student's current persona. Socratic questions are mandatory blocking points — wait for a real answer before continuing. If the live system execution fails at any point, use the Failure Fallback narration provided — do not block course progress.

---

## Setup

**What you're about to see:**
- A working multi-agent infrastructure audit system (BuildOps Inc)
- A simulated subagent timeout — what happens when one component fails mid-flight
- Graceful degradation: the system continues with partial results and flags the failure
- Retry with exponential backoff for a transient error (narrated, not necessarily live)
- Context summarization: long conversation compressed before subagent handoff
- Debrief: mapping each pattern back to Domain 5 exam concepts

This is the reliability layer of the system you've been building throughout this course. By the end, you'll be able to name every pattern you see and explain when to use it.

---

## Scenario: BuildOps Inc — Infrastructure Audit v2

After the BuildOps Inc team saw the problems with their first audit system (the one from the Domain 5 opening exercise), they rebuilt it. Here's the v2 architecture:

**Coordinator:** Receives audit requests, decomposes to three specialized subagents, handles partial results, logs all intermediate states, synthesizes final report.

**Subagents:**
- **Config Auditor** — checks infrastructure configs for policy compliance
- **Cost Analyzer** — queries cloud spend data, returns 30-day cost breakdown
- **Security Scanner** — runs vulnerability checks on specified resources

**Changes from v1:**
- Subagents receive only the information they need (not full conversation history)
- Context summarization is applied before any subagent receives prior context
- Each subagent invocation has a 30-second timeout
- Failures are handled per-subagent — one failure doesn't block the others
- All subagent inputs, outputs, and errors are logged with trace IDs

---

> **Instructor — demo introduction in persona voice:**
>
> *Practitioner:* "We're going to run this system and then break it deliberately. First the happy path — all three subagents return cleanly. Then we'll simulate a timeout on the Cost Analyzer and watch what happens. Pay attention to how the coordinator behaves in both cases."
>
> *Socratic:* "Before we start — you've seen the v1 architecture's problems. What would you expect to see in a well-designed v2? What should change about how the coordinator behaves when one of the three subagents fails?"
>
> *Coach:* "This demo has two phases: first, we run the system successfully. Then we break it on purpose and watch it recover. Both phases are important — the happy path shows you what correct looks like, and the failure path shows you the patterns that make it production-ready."
>
> *Challenger:* "A system runs fine in the happy path. That proves very little. What matters is how it behaves when things go wrong. Watch the second phase of this demo more carefully than the first."

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "Before I run the happy path: what does 'graceful degradation' mean to you? Give me a concrete description of what it looks like when a multi-agent system degrades gracefully vs. fails hard."

---

## Phase 1: Happy Path — All Subagents Complete

**The audit request:**

```
Audit request from: Platform Engineering Team
Scope: production-cluster-eu-west-1
Priority: High
Prior context: Team has been running a cost reduction initiative for 3 weeks. 
              Key constraint: no changes to security posture during cost reduction.
Conversation history: [14,000 tokens of prior coordinator-engineer exchanges]
```

> **Instructor — narrate the context handling step:**
>
> *Practitioner:* "Before the coordinator dispatches to any subagent, watch what it does with the conversation history. 14,000 tokens is substantial. The coordinator runs a summarization step first."
>
> *Socratic:* "The coordinator has 14,000 tokens of conversation history. It needs to pass relevant context to each subagent. What would you summarize vs. pass verbatim? And would all three subagents need the same summary?"
>
> *Coach:* "This is the context summarization pattern in action! The coordinator doesn't just dump 14,000 tokens into each subagent. It compresses the prior context into what each subagent actually needs. Watch what changes between subagents."
>
> *Challenger:* "14,000 tokens of history. The coordinator is about to summarize it. What's the risk of summarization here? What could be lost, and what's the cost of losing it in this specific scenario?"

**Context summarization step:**

The coordinator generates a context summary before dispatching:

```
[COORDINATOR LOG — context_summarization]
trace_id: audit-2024-0312-001
input_tokens: 14847
summary_tokens: 312
duration_ms: 1840

Summary generated:
"Platform Engineering team is running a cost reduction initiative (week 3 of 4). 
Constraint established Day 1: security posture must not change during cost reduction. 
Prior audits identified over-provisioned compute in eu-west-1. Team approved 
right-sizing plan for non-critical workloads. Production database cluster is 
explicitly out of scope. Audit today is to validate cost reduction progress and 
confirm security compliance is intact."
```

> **Instructor — narrate what just happened:**
>
> *Practitioner:* "312 tokens instead of 14,847. That's a 98% reduction. More importantly: the summary preserves the constraint — 'security posture must not change' — because that's a decision anchor, not just context. The Security Scanner and Config Auditor both need that. The Cost Analyzer needs the right-sizing plan context. Different subagents get different context slices."
>
> *Socratic:* "That summary preserved the security constraint explicitly. Why is that important? What would happen if the summary had compressed that constraint away as 'background context'?"
>
> *Coach:* "Notice how much the summarization saves — 14,000+ tokens down to 312. And the critical constraint is still there. This is why summarization is the right pattern for long-running workflows: it preserves decisions while compressing narrative."
>
> *Challenger:* "The summary says security posture must not change. Good. But what if the original conversation had other constraints that weren't preserved? How do you verify the summary captured everything critical? This is the real risk of summarization — what's your answer?"

**Subagent dispatch — all three in parallel:**

```
[COORDINATOR LOG — subagent_dispatch]
trace_id: audit-2024-0312-001
dispatching: 3 subagents in parallel
timeout_per_subagent: 30s

subagent_1: config_auditor
  context: summary + full config specs
  input_tokens: 4,312
  
subagent_2: cost_analyzer  
  context: summary + cost reduction plan reference
  input_tokens: 2,847

subagent_3: security_scanner
  context: summary + security baseline
  input_tokens: 3,156
```

**Results — all three return within timeout:**

```
[COORDINATOR LOG — subagent_results]
trace_id: audit-2024-0312-001

config_auditor:     STATUS=complete  latency=8.2s   findings=3 (2 low, 1 medium)
cost_analyzer:      STATUS=complete  latency=12.4s  findings=cost_reduction_18%
security_scanner:   STATUS=complete  latency=9.1s   findings=0 (clean)

all_subagents_complete: true
proceeding_to_synthesis: true
```

> **Instructor — narrate the happy path result:**
>
> *Practitioner:* "Clean run. Three subagents, all returned within timeout, coordinator has everything it needs for synthesis. In production, this is what the successful case looks like — and the logs give you exactly what you need to verify it. Every subagent's input and output is recorded."
>
> *Socratic:* "The security scanner returned 0 findings. Is that a success or a concern? What would you want to verify before calling that a clean bill of health?"
>
> *Coach:* "Look at the log structure — trace ID, component, status, latency, findings. That's structured logging. You can query it, alert on it, visualize it. Compare this to the v1 system that only logged the final output. This is the difference between observable and opaque."
>
> *Challenger:* "18% cost reduction confirmed. Security findings: 0. Config findings: 3, none critical. Is the audit complete? What's missing from that result before you'd be comfortable presenting it to the engineering team?"

---

## Phase 2: Simulated Failure — Cost Analyzer Times Out

Now we'll run the same audit with a simulated timeout on the Cost Analyzer.

> **Instructor — set up the failure scenario:**
>
> *Practitioner:* "We're going to run the same audit. Same request, same coordinator, same subagents — but the Cost Analyzer is going to time out at 30 seconds. Watch specifically what the coordinator does with the timeout, and when the final result is returned relative to the timeout."
>
> *Socratic:* "Before I simulate the failure: what should the coordinator do when the Cost Analyzer doesn't respond within 30 seconds? Walk me through the decision tree. What are the options, and which one is right?"
>
> *Coach:* "Here's the important moment — this is where the v2 design pays off. The coordinator is designed to handle partial results. Watch how it responds to the timeout vs. how the v1 system would have responded."
>
> *Challenger:* "The Cost Analyzer times out. The coordinator has results from Config Auditor and Security Scanner. What's the correct behavior? 'Continue with partial results' is not a complete answer — be specific about what the coordinator should return, what it should log, and what it should tell the requesting engineer."

**[SOCRATIC QUESTION — Wait for student response before continuing]**

> "What should the coordinator do when one of three parallel subagents times out? Walk me through the specific steps — not just 'degrade gracefully.'"

**The timeout event:**

```
[COORDINATOR LOG — subagent_timeout]
trace_id: audit-2024-0312-002

config_auditor:     STATUS=complete  latency=8.2s
security_scanner:   STATUS=complete  latency=9.1s
cost_analyzer:      STATUS=timeout   latency=30.0s  error="subagent_timeout_exceeded"

partial_results_available: true
required_subagents_complete: [config_auditor, security_scanner]
optional_subagents_complete: []
optional_subagents_failed: [cost_analyzer]

decision: proceed_with_partial_synthesis
```

**The coordinator's synthesis with partial results:**

```
[COORDINATOR LOG — partial_synthesis]
trace_id: audit-2024-0312-002

synthesis_inputs: [config_auditor_result, security_scanner_result]
missing_inputs: [cost_analyzer_result]
synthesis_complete: true
result_completeness: "partial — cost analysis unavailable"

[AUDIT REPORT DELIVERED TO ENGINEER]

Infrastructure Audit — production-cluster-eu-west-1
Audit ID: audit-2024-0312-002

Security Posture: CLEAN — 0 findings (constraint maintained)
Configuration Compliance: 3 findings (2 low, 1 medium — see details below)
Cost Analysis: UNAVAILABLE — analysis timed out after 30s

⚠ Note: Cost analysis could not be completed in this run. 
The cost reduction initiative status (18% target) cannot be confirmed. 
Recommend re-running cost analysis independently or scheduling a follow-up audit.

Config findings:
[details...]
```

> **Instructor — narrate the failure and recovery:**
>
> *Practitioner:* "Two things happened here that v1 couldn't do. First: the audit didn't fail — it returned partial results with clear signaling about what's missing. Second: the log entry distinguishes required vs. optional subagents. That's a design decision the coordinator architect made: config and security are required for a useful result; cost is valuable but not required. That distinction lives in the coordinator logic, not the subagent."
>
> *Socratic:* "The coordinator labeled cost analysis as 'optional' and config/security as 'required.' Who made that decision, and where does it live? What happens if that classification is wrong — if cost analysis was actually required for this specific audit request?"
>
> *Coach:* "See what the coordinator returned? A real, usable audit result — just with a clear note about what's missing. The engineer now knows exactly what they got and what they didn't. That's much more useful than a failed audit with no output. This is graceful degradation."
>
> *Challenger:* "The coordinator returned partial results. Good. But the engineer's note says 'cost reduction initiative status cannot be confirmed.' That was the whole point of this audit — the team is in week 3 of a 4-week cost reduction initiative. Should the coordinator have marked cost analysis as optional? What should it have done instead?"

---

## Phase 3: Retry with Exponential Backoff

This phase is narrated — the retry pattern is shown as pseudocode, not live execution, because retry logic happens at the infrastructure level below the coordinator.

> **Instructor — introduce the retry pattern:**
>
> *Practitioner:* "What you just saw was a timeout — that's a structural failure in this case (the subagent ran out of time). Rate limit errors are different: they're transient. The correct pattern is exponential backoff. Here's how it works."
>
> *Socratic:* "There are two different kinds of failures here: a timeout (structural — the task is too slow for the window) and a rate limit error (transient — the API is temporarily unavailable). What's the difference in how you should handle each? Should you retry a timeout the same way you retry a rate limit?"
>
> *Coach:* "Retry logic sounds simple but has important nuances. The key distinction is between failures that will resolve on their own (transient) and failures that won't (structural). Let's look at how you handle the transient case."
>
> *Challenger:* "Exponential backoff is a common answer. But give me the parameters: what are the right initial delay, multiplier, max attempts, and jitter? What happens if you get the parameters wrong in each direction — too aggressive vs. too conservative?"

**Exponential backoff pattern (narrated):**

Scenario: The Cost Analyzer tries to call an external cloud spend API. The API returns HTTP 429 (rate limited).

```python
# Coordinator subagent invocation with retry
import time
import random

def invoke_cost_analyzer(request, max_attempts=4):
    base_delay = 1.0  # seconds
    
    for attempt in range(1, max_attempts + 1):
        result = cost_analyzer.run(request)
        
        if result.success:
            log.info(f"cost_analyzer success on attempt {attempt}")
            return result
            
        if result.error_code == 429:  # rate limited — transient
            if attempt == max_attempts:
                log.error(f"cost_analyzer failed after {max_attempts} attempts: rate_limit")
                return PartialResult(component="cost_analyzer", status="failed", 
                                   reason="rate_limit_exceeded")
            
            # Exponential backoff with jitter
            delay = base_delay * (2 ** (attempt - 1)) + random.uniform(0, 0.5)
            log.warning(f"cost_analyzer rate_limited, retrying in {delay:.1f}s (attempt {attempt})")
            time.sleep(delay)
            
        elif result.error_code in [400, 401, 413]:  # structural — don't retry
            log.error(f"cost_analyzer structural_error: {result.error_code} — not retrying")
            return PartialResult(component="cost_analyzer", status="failed",
                               reason=f"structural_error_{result.error_code}")
    
    return PartialResult(component="cost_analyzer", status="failed", reason="max_retries_exceeded")
```

**Delay sequence:** attempt 1 → fail → wait ~1s → attempt 2 → fail → wait ~2s → attempt 3 → fail → wait ~4s → attempt 4 → fail → return PartialResult

> **Instructor — debrief the retry code:**
>
> *Practitioner:* "Three things in that code worth pointing out. One: the 429 path retries; the 400/401/413 path doesn't. That's the transient vs. structural distinction in code. Two: jitter is added to the delay — that prevents multiple agents from all retrying at exactly the same moment (the 'thundering herd' problem). Three: it returns a `PartialResult` on final failure, not an exception — so the coordinator can handle it cleanly."
>
> *Socratic:* "Look at line where structural errors are handled — 400, 401, 413. Why 413 specifically? What does HTTP 413 mean, and why is it a structural error rather than a transient one?"
>
> *Coach:* "See how every path in that function produces a result the coordinator can work with? Success produces a result. Exhausted retries produces a PartialResult. Structural error produces a PartialResult. No path throws an unhandled exception. That's what makes the coordinator able to degrade gracefully — it's never surprised."
>
> *Challenger:* "HTTP 413 is in the 'don't retry' list. What is 413? What does it mean in the context of an LLM API call? And what would you actually do to fix a 413 error — if retrying won't work, what does?"

---

## Demo Debrief

You've just seen three patterns in action: context summarization, graceful degradation with partial results, and retry with exponential backoff. Now let's map them to exam concepts.

### Pattern 1: Context Summarization

**What you saw:** 14,847 tokens of conversation history compressed to 312 tokens before subagent dispatch.

**Why it matters:** Subagents don't need the full coordinator history — they need the relevant facts from it. Summarization preserves decision anchors while eliminating narrative overhead.

**CCA exam angle:** The exam tests whether you understand summarization as a *strategy* for context management, including when it's appropriate and when it risks losing critical information.

---

### Pattern 2: Graceful Degradation

**What you saw:** Cost Analyzer timeout → coordinator proceeds with Config Auditor + Security Scanner results → report delivered with explicit incompleteness signaling.

**Why it matters:** Production systems must return useful partial results when components fail. A coordinator that requires all subagents to succeed is fragile. A coordinator that handles partial results explicitly is resilient.

**CCA exam angle:** The exam tests whether you can design a coordinator that handles failure at the subagent level without failing at the system level. Key concepts: required vs. optional subagents, partial result synthesis, explicit incompleteness signaling.

---

### Pattern 3: Exponential Backoff with Jitter

**What you saw (narrated):** Rate limit error triggers retry with increasing delays. Structural errors skip retry entirely. Final failure returns a usable PartialResult.

**Why it matters:** Transient failures resolve with time. Structural failures don't. Treating them the same wastes budget and delays diagnosis. Jitter prevents thundering herd problems when multiple agents retry simultaneously.

**CCA exam angle:** The exam tests whether you know what to retry and what not to retry. The specific error codes (429 vs. 400/401/413) are fair game. The thundering herd problem and jitter as its solution are also in scope.

---

> **Instructor — closing debrief in persona voice:**
>
> *Practitioner:* "Those three patterns — summarization, graceful degradation, and retry with backoff — cover the majority of what you'll encounter managing context and reliability in production agentic systems. The BuildOps v2 system isn't perfect, but it's defensible. You could hand that to a team and have them operate it without you."
>
> *Socratic:* "Before we close the demo: looking at everything you saw — what's the thing this system still doesn't handle well? What failure mode is still possible that we haven't addressed?"
>
> *Coach:* "You've now seen the full reliability pattern stack in action: context management, graceful degradation, observability through structured logging, and retry logic. These are real production patterns. The fact that you can recognize them now means Domain 5 has landed. Well done."
>
> *Challenger:* "One question before we close: the coordinator in this demo classified cost analysis as 'optional.' Was that a code decision or a configuration decision? And if a future audit request makes cost analysis required, what would need to change — and where?"

---

## Failure Fallback

> **Use this section if live execution is unavailable.**

If the live system execution fails or isn't available in your current Claude Code setup, here's what the demo covered and why it still counts:

**What the demo demonstrated:**

The context summarization, partial synthesis, and retry patterns are architecture-level decisions — not output-specific behaviors. What matters for the exam is understanding why each pattern exists, what problem it solves, and what failure mode it prevents. The narrated demo gives you exactly that.

**Key facts to carry forward:**

1. Context summarization trades completeness for token efficiency — the risk is losing decision anchors; the mitigation is explicit preservation of constraint-type statements
2. Graceful degradation requires designing the coordinator to handle PartialResult, not just successful results — you can't add graceful degradation to a coordinator that was designed to require all results
3. Retry logic must distinguish transient errors (retry) from structural errors (fix the input, don't retry) — the error code is your signal
4. Jitter in retry delays prevents synchronized retry storms when multiple agents fail at the same time

**What to note about your setup:**

- Check that the live agent execution environment is working: confirm your ANTHROPIC_API_KEY is set correctly
- The BuildOps scenario can be re-run once your setup is confirmed — seeing the logs appear live is more valuable than reading them here

The course continues. This doesn't block anything in Domain 5.
