# Spec Package: CCA Foundations Interactive Course
Generated: 2026-04-11
Mode: New Project
Status: Draft

---

## 1. Overview

**Problem:** Students preparing for the Claude Certified Architect (CCA) Foundations exam have no interactive, exercise-driven learning environment. Existing materials are passive reading. The certification tests whether architects can design and reason about agentic systems — skills that require doing, not just reading.

**Users:** Practitioners who already build with Claude and agentic systems. Motivated beginners who need the practitioner-level context to engage meaningfully.

**Success criteria:**
- Student completes all 5 domains and receives a readiness report
- Opening exercise runs successfully with live subagent invocation in first session
- Instructor persona visibly and meaningfully changes delivery style
- Progress tracking accurately surfaces weak areas after each domain
- Readiness report styled to learn.anthropic.com standard

**Scope boundary:** Does not include a web interface, hosted LMS, multi-student tracking, grading, or any non-Anthropic reading material. This is a Claude Code-native instructor flow only.

---

## 2. Component Manifest

### Component 1: CLAUDE.md Bootstrap Engine
- **Approach:** Static code (markdown instructions + logic branches)
- **Capability required:** routing
- **Model:** None — CLAUDE.md is read by Claude Code at session start; Claude interprets the logic
- **Model justification:** Routing and session detection is deterministic (does file exist? → branch)
- **Confidence:** ★★★★★
- **Evidence:** Noctua course uses identical pattern — validated in production student sessions
- **Input:** Session start event; `.student_cca/student.md` (if exists); `.student_cca/progress.md` (if exists)
- **Output:** Instructor persona loaded; student oriented to current position; session begun
- **Error handling:** If `.student_cca/` missing → run first-time setup flow; never fail silently
- **Governance:** No model calls at bootstrap — pure routing. No PII stored beyond local machine.
- **Test strategy:** Manual walkthrough — first-time and returning student paths
- **Estimated cost:** Zero

---

### Component 2: Day 0 Onboarding Flow
- **Approach:** LLM (Sonnet-tier) delivering structured content from `day-0-onboarding.md`
- **Capability required:** moderate_reasoning
- **Model:** claude-sonnet-4-6 (via Claude Code session)
- **Model justification:** Persona-adaptive delivery of course overview requires generation, not scripting. Sonnet handles natural instructor voice well.
- **Confidence:** ★★★★☆
- **Evidence:** Noctua onboarding pattern proven; CCA-specific content needs validation
- **Input:** Day 0 content file; student has no prior `.student_cca/` files
- **Output:** `.student_cca/student.md` created with persona choice; student confirmed ready to proceed
- **Error handling:** If student doesn't pick a persona → prompt again with simplified options; never skip persona selection
- **Governance:** Student chooses their own persona — no coercive defaults
- **Test strategy:** Run through all 4 persona selection paths; confirm student.md writes correctly
- **Estimated cost:** ~$0.01 per onboarding session

---

### Component 3: Instructor Persona Engine
- **Approach:** LLM (Sonnet-tier) with persona-scoped system context loaded from student.md
- **Capability required:** moderate_reasoning
- **Model:** claude-sonnet-4-6 (via Claude Code session)
- **Model justification:** Persona adaptation across varied content types (exercises, questions, feedback) requires generative capability. Not templatable.
- **Confidence:** ★★★★☆
- **Evidence:** Persona-switching pattern proven in Noctua; CCA-specific persona mechanics need spec-time definition
- **Input:** `.student_cca/student.md` (persona selection); domain content; student responses
- **Output:** All content delivery voiced through chosen persona
- **Error handling:** Unrecognized persona name → list valid options; don't silently default
- **Governance:** Personas are educational styles, not character roleplay — all must remain pedagogically sound
- **Test strategy:** Side-by-side session runs of same domain content under all 4 personas; verify distinct delivery
- **Estimated cost:** Included in domain session cost

---

### Component 4: Opening Agentic Exercise (Dynamically Generated)
- **Approach:** LLM (Sonnet-tier) orchestrating live subagent invocation via Task tool + narration
- **Capability required:** deep_reasoning (orchestration + real-time narration + dynamic scenario generation)
- **Model:** claude-sonnet-4-6 (via Claude Code session; spawns subagents as Tasks)
- **Model justification:** Must generate a scenario tailored to student's background, coordinate live agent execution, narrate each step in persona voice, and ask Socratic questions. Highest complexity component.
- **Confidence:** ★★★☆☆
- **Evidence:** Task tool invocation is well-documented; dynamic scenario generation + narration-while-executing pattern needs prototype validation
- **Input:** `exercises/opening-exercise.md` scaffolding; student's confirmed prereqs; student background (collected during Day 0)
- **Output:** Student has observed coordinator + 2 subagents running a scenario relevant to their background; debrief maps observed behavior to Domain 1 concepts
- **Error handling:** If Task invocation fails → instructor narrates what *would* have happened; never block course progress on tool failure
- **Governance:** Subagents are sandboxed within student's own environment; no external API calls without student's explicit prereq setup
- **Test strategy:** Full end-to-end run with all 4 personas × 3 background types (practitioner/beginner/security); verify narration quality; verify subagent invocation succeeds; test failure fallback
- **Estimated cost:** ~$0.05–0.15 per exercise run (coordinator + 2 subagents + dynamic generation)

---

### Component 5: Domain Content Scaffolding (×5)
- **Approach:** Static markdown content + LLM delivery (Sonnet-tier)
- **Capability required:** moderate_reasoning
- **Model:** claude-sonnet-4-6 (via Claude Code session)
- **Model justification:** Knowledge checks require understanding student responses and adapting; directed reading links and exercise instructions are static
- **Confidence:** ★★★★☆
- **Evidence:** Domain 1 topics well-documented in CCA study plan; exercise design for Domains 2–5 needs authoring
- **Input:** Domain markdown file; student's current persona; prior progress.md entries
- **Output:** Domain completed; checkpoint written to progress.md; weak areas flagged
- **Error handling:** If student struggles at knowledge check → instructor revisits concept before moving on; never skip a struggling student
- **Governance:** Directed reading links to Anthropic sources only — no third-party content
- **Test strategy:** Complete run of each domain under each persona; verify checkpoints write correctly; verify weak-area flagging
- **Estimated cost:** ~$0.10–0.30 per domain session

---

### Component 6: Progress Tracking & Feedback Loop
- **Approach:** Static code (markdown writes) + LLM (Sonnet-tier) for feedback synthesis
- **Capability required:** data_processing (writes) + simple_generation (feedback)
- **Model:** claude-sonnet-4-6 for feedback synthesis; no model for writes
- **Model justification:** Writing checkpoint rows to markdown is deterministic. Synthesizing "here's where you're weak" from tabular data requires light generation.
- **Confidence:** ★★★★★ (writes) / ★★★★☆ (feedback synthesis)
- **Evidence:** Noctua progress.md pattern validated; feedback synthesis is straightforward summarization
- **Input:** Domain checkpoint data (section, confidence level, notes)
- **Output:** `.student_cca/progress.md` updated; on-demand feedback available to student
- **Error handling:** If progress.md is malformed → rebuild from session context rather than fail
- **Governance:** All data is local to student's machine; no telemetry
- **Test strategy:** Verify writes after each checkpoint; verify feedback synthesis matches stored data
- **Estimated cost:** ~$0.01 per feedback synthesis call

---

### Component 7a: Progress Report Generator (on-demand)
- **Approach:** LLM (Sonnet-tier) + static template styled to learn.anthropic.com
- **Capability required:** moderate_reasoning
- **Model:** claude-sonnet-4-6
- **Model justification:** Synthesizing partial progress into a useful snapshot requires generation; template handles styling
- **Confidence:** ★★★★☆
- **Evidence:** Report content logic is straightforward summarization; learn.anthropic.com styling needs analysis
- **Input:** `.student_cca/progress.md` (partial or complete); triggered by student at any time
- **Output:** `.student_cca/progress-report-[date].md` — completed domains, per-domain confidence, weak areas
- **Error handling:** If no checkpoints exist yet → tell student to complete at least one domain section first
- **Governance:** Report is informational only — not an Anthropic official assessment
- **Test strategy:** Generate from mock data at: 1 domain complete, 3 domains complete, all complete
- **Estimated cost:** ~$0.03–0.05 per report

---

### Component 7b: Final Readiness Report Generator
- **Approach:** LLM (Sonnet-tier) + static template styled to learn.anthropic.com
- **Capability required:** moderate_reasoning
- **Model:** claude-sonnet-4-6
- **Model justification:** Full readiness narrative + recommendation requires synthesis beyond simple summarization
- **Confidence:** ★★★☆☆
- **Evidence:** learn.anthropic.com styling needs analysis before template is built; recommendation logic needs definition
- **Input:** Complete `.student_cca/progress.md` with all 5 domains; triggered by student after Domain 5
- **Output:** `.student_cca/readiness-report-final.md` — full per-domain summary + readiness recommendation (Ready / Review these areas / Needs more time)
- **Error handling:** If not all domains completed → show which domains are outstanding; still generate partial if student insists
- **Governance:** Recommendation is advisory only — not an Anthropic official certification assessment
- **Test strategy:** Generate from mock data for all 3 recommendation outcomes; verify styling matches target
- **Estimated cost:** ~$0.05–0.08 per final report

---

## 3. Agent Swarm Configuration

The opening exercise demonstrates this swarm live to the student:

```yaml
swarm:
  name: "opening-exercise-demo"
  purpose: "Live demonstration of agentic architecture for CCA Domain 1 teaching"

  orchestrator:
    name: coordinator
    capability: routing
    model_constraints:
      - "must be visible to student — runs in main Claude Code session"
    resolved_model: claude-sonnet-4-6
    role: "Receives the task, decomposes it, assigns subtasks to subagents, collects results, synthesizes output"

  agents:
    - name: research-subagent
      capability: moderate_reasoning
      model_constraints:
        - "spawned via Task tool"
        - "isolated context — no access to coordinator's full context"
      resolved_model: claude-sonnet-4-6
      resolved_justification: "Moderate reasoning task; student-visible for learning purposes"
      role: "Executes a focused research subtask assigned by coordinator"
      tools: [Read, Grep, WebFetch]
      components: [4]  # Opening Exercise

    - name: analysis-subagent
      capability: moderate_reasoning
      model_constraints:
        - "spawned via Task tool"
        - "receives structured input from coordinator, not raw task"
      resolved_model: claude-sonnet-4-6
      resolved_justification: "Parallel analysis worker; demonstrates coordinator's 4 jobs in action"
      role: "Executes a focused analysis subtask; returns structured result to coordinator"
      tools: [Read, Bash]
      components: [4]  # Opening Exercise

notes:
  - "Swarm exists to TEACH, not to be efficient — narration of each step is mandatory"
  - "Student asked Socratic questions at: task decomposition, subagent invocation, result synthesis"
  - "Instructor narrates coordinator's 4 jobs as they happen: decompose, assign, monitor, synthesize"
```

---

## 4. Data Contracts

```yaml
contracts:
  - from: CLAUDE.md Bootstrap (Component 1)
    to: Day 0 Onboarding (Component 2)
    format: file-existence check
    schema:
      student_cca_exists: boolean
      student_md_exists: boolean
      progress_md_exists: boolean

  - from: Day 0 Onboarding (Component 2)
    to: Instructor Persona Engine (Component 3)
    format: markdown
    schema:
      file: .student_cca/student.md
      fields:
        persona_name: string  # "The Practitioner" | "The Socratic" | "The Coach" | "The Challenger"
        switch_phrase: string  # "switch to [name] persona"

  - from: Domain Content Scaffolding (Component 5)
    to: Progress Tracking (Component 6)
    format: markdown append
    schema:
      file: .student_cca/progress.md
      checkpoint_row:
        domain: string       # "Domain 1"
        section: string      # "Agentic Loop"
        date: string         # ISO date
        confidence: string   # "High" | "Medium" | "Low"
        notes: string        # optional

  - from: Progress Tracking (Component 6)
    to: Readiness Report Generator (Component 7)
    format: markdown read
    schema:
      file: .student_cca/progress.md
      requires:
        all_5_domains_complete: boolean
        per_domain_confidence: array

  - from: Opening Exercise (Component 4)
    to: Domain Content Scaffolding — Domain 1 (Component 5)
    format: conversational handoff
    schema:
      debrief_complete: boolean
      concepts_introduced: [agentic_loop, coordinator_jobs, subagent_invocation, task_decomposition]
```

---

## 5. Integration Map

```
Student opens Claude Code with CCA-Foundations repo mounted
    ↓
CLAUDE.md auto-loads (Component 1)
    ↓ (first time)                    ↓ (returning)
Day 0 Onboarding                   Load persona + progress
(Component 2)                       Orient to current position
    ↓
Persona selected → student.md written
    ↓
Opening Agentic Exercise (Component 4)
    → Spawns coordinator + 2 subagents (Task tool)
    → Instructor narrates each step in persona voice
    → Debrief: maps to Domain 1 concepts
    ↓
Domain 1 → Domain 2 → Domain 3 → Domain 4 → Domain 5
(Component 5, delivered via Component 3 persona engine)
    → Each domain: exercise → directed reading → knowledge checks → checkpoint
    → Checkpoint writes to progress.md (Component 6)
    ↓
All 5 domains complete
    ↓
Readiness Report (Component 7)
    → Reads progress.md
    → Synthesizes per-domain confidence
    → Outputs recommendation + .student_cca/readiness-report.md

Reading Layer (external, not built):
    learn.anthropic.com
    docs.anthropic.com/claude-code
    docs.anthropic.com (Claude SDK)
    github.com/anthropics (public repos)
```

---

## 6. Compliance Mapping

- **AIUC-1 domains applicable:** Human oversight (student controls pacing), Transparency (persona is explicit choice), Data minimization (all data local)
- **Risk tier:** Low — educational tool, no external data transmission, local-only state
- **Governance hooks:**
  - Persona change always acknowledged explicitly — no silent switching
  - Readiness report is advisory only — explicitly not an Anthropic official assessment
  - Directed reading links to Anthropic sources only — no third-party content injection
  - Subagents run in student's own environment — no access to external systems beyond what student already has

---

## 7. Build Instructions

### Phase 1: Foundation (build first, enables all other work)
1. `CLAUDE.md` — bootstrap logic, session detection, persona load, orientation
2. `.student_cca/` template files — `student.md` and `progress.md` structures
3. `README.md` — prerequisites section
4. `.gitignore` — exclude `.student_cca/`

### Phase 2: Core Flow (sequential — each depends on Phase 1)
5. `domains/day-0-onboarding.md` — course overview, persona selection flow
6. `exercises/opening-exercise.md` — coordinator + subagents scenario with narration scaffolding
7. `domains/domain-1-agentic-architecture.md` — first domain, highest weight (27%)

### Phase 3: Remaining Domains (can build in parallel once Domain 1 is validated)
Each domain needs: content file + demo exercise + lab(s)

8. `domains/domain-2-tool-design.md` + `exercises/domain-2-demo.md` + `exercises/domain-2-lab.md`
9. `domains/domain-3-claude-code.md` + `exercises/domain-3-demo.md` + `exercises/domain-3-lab.md`
10. `domains/domain-4-prompt-engineering.md` + `exercises/domain-4-demo.md` + `exercises/domain-4-lab.md`
11. `domains/domain-5-context-reliability.md` + `exercises/domain-5-demo.md` + `exercises/domain-5-lab.md`

### Phase 4: Reference + Output (parallel with Phase 3)
12. `patterns/decision-frameworks.md`
13. `patterns/anti-patterns.md`
14. `reports/readiness-report-template.md` (styled to learn.anthropic.com — covers both progress + final report)

### Parallel opportunities
- Phases 3 and 4 can run in parallel worktrees
- Domains 2–5 can each be built simultaneously (4 agents × 3 files each)
- Report template can be built independently of domain content

---

## 8. Evaluation Criteria

- **Target metrics:**
  - Opening exercise runs without tool failure in standard Claude Code setup
  - Persona delivery is distinguishably different across all 4 types (human eval)
  - Progress.md writes correctly after every domain checkpoint
  - Readiness report matches learn.anthropic.com styling (visual review)

- **Evaluation dataset:** Manual walkthroughs — one full course run per persona type (4 total)

- **Cost target:** Under $1.00 total per student course completion

---

## 9. Validation Strategy

All labs and demos must be prototyped and validated before being authored into domain files. This includes:
- Verifying that subagent invocation patterns work as documented
- Confirming that directed reading links are accurate and current
- Testing that exercise scaffolding produces the intended student experience
- Validating each domain's key concepts against official Anthropic source material

## 10. Fictional Enterprise Lab Scenarios

Labs use fictional enterprise background data to ground concepts in real-world context. These scenarios are invented — not based on real companies. They should reflect the kinds of organizations actually deploying Claude and agentic systems at scale.

**Scenario pool (to be expanded per domain):**
- **FinClearance Corp** — financial services firm using Claude for regulatory document analysis and compliance workflows
- **MedRoute Health** — healthcare network using multi-agent systems for patient intake triage and clinical decision support routing
- **BuildOps Inc** — construction/infrastructure company using Claude Code for automated project status reporting and contractor coordination
- **SecurePath Systems** — enterprise security firm using agentic frameworks for threat detection and incident response orchestration

Each domain's lab uses one or more of these scenarios to demonstrate how the domain's concepts apply in production enterprise deployments.

## 11. Open Questions

- [ ] Component 4 confidence is ★★★☆☆ — dynamic scenario generation + narration-while-executing needs a prototype run before full domain authoring begins

## 12. Style Reference

Visual analysis of learn.anthropic.com complete. Full design system documented in:
`docs/specs/anthropic-learn-style-guide.md`

Key tokens for report authors:
- Page bg: `#faf9f5` (ivory-light)
- Section container: `#e3dacc` (oat), 12px radius, 48px padding
- Inner cards: `rgba(25,25,25,0.1)` tint, 8px radius, 24px padding
- Font: anthropicSerif (fallback: Georgia serif), weights 400–500 only
- All report templates must follow `docs/specs/anthropic-learn-style-guide.md`
