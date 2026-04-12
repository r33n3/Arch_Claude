<!--
  ============================================================
  CCA FOUNDATIONS — READINESS REPORT TEMPLATE
  ============================================================
  This is a Claude-fill template. Do NOT present this file
  directly to the student. Follow the instructions in each
  comment block, fill in every {{PLACEHOLDER}}, then render
  the completed document as your response.

  DATA SOURCE: .student_cca/progress.md
  Exact field names:
    - Status       (Not started | In Progress | Complete)
    - Confidence   (High | Medium | Low | Not started | —)
    - Confusion Log
    - Last session note

  REPORT VARIANT SELECTION
  ─────────────────────────
  Determine which variant to render before filling anything:

  PROGRESS REPORT (on-demand):
    Trigger: Student says "generate my progress report" (or similar)
    Condition: One or more domains have Status ≠ Complete
    Omit: The "Readiness Recommendation" section entirely
    Save output to: .student_cca/progress-report-{{DATE}}.md

  FINAL READINESS REPORT:
    Trigger: All 5 domains have Status = Complete AND student
             confirms they want the final report
    Condition: All 5 Status fields = Complete
    Include: All sections including Readiness Recommendation
    Save output to: .student_cca/readiness-report-final.md

  If all 5 are complete but this is triggered on-demand (not at
  Domain 5 checkpoint), still render the Final Readiness Report.
  ============================================================
-->

---

<!--
  STYLE NOTES (for markdown rendering context)
  ─────────────────────────────────────────────
  Visual target: learn.anthropic.com (see docs/specs/anthropic-learn-style-guide.md)

  Color semantics to express via emoji/symbol in plain markdown:
    Confidence High     → ● (filled, positive)   — olive #788c5d in HTML
    Confidence Medium   → ◑ (half-filled)         — clay  #d97757 in HTML
    Confidence Low      → ○ (empty, concern)      — error red #bf4d43 in HTML
    Status Complete     → ✓
    Status In Progress  → ◐
    Status Not started  → —

  Section containers: use horizontal rules and blockquotes to
  approximate the oat-background card pattern from the style guide.

  Recommendation block colors (use blockquote styling):
    Ready to sit      → cactus tone — wrap in > [!NOTE] or > **READY**
    Review areas      → heather tone — wrap in > [!WARNING] or > **REVIEW**
    Needs more time   → clay accent — wrap in > [!CAUTION] or > **NOT YET**
  ============================================================
-->

---

# CCA Foundations — {{REPORT_VARIANT_TITLE}}

<!--
  FILL: {{REPORT_VARIANT_TITLE}}
    Progress Report   → "Progress Report"
    Final Report      → "Readiness Report"
-->

**Student file:** `.student_cca/progress.md`
**Report generated:** {{DATE}}
**Domains completed:** {{COMPLETED_COUNT}} of 5

<!--
  FILL:
    {{DATE}}            → today's date, format: Month DD, YYYY
    {{COMPLETED_COUNT}} → count of rows where Status = Complete
-->

---

## Your Progress

<!--
  READ .student_cca/progress.md — domain table section.
  For each of the 5 domain rows, extract: Domain number, Title,
  Exam Weight, Status, Confidence.
  Map values to symbols using this key:
    Status:
      Complete     → ✓ Complete
      In Progress  → ◐ In Progress
      Not started  → — Not started
    Confidence:
      High         → ● High
      Medium       → ◑ Medium
      Low          → ○ Low
      Not started  → — (dash)
      —            → — (dash)
  Fill the table below. Do not omit any row even if Not started.
-->

| Domain | Title | Exam Weight | Status | Confidence |
|:------:|-------|:-----------:|--------|:----------:|
| 1 | Agentic Architecture | 27% | {{D1_STATUS}} | {{D1_CONFIDENCE}} |
| 2 | Tool Design | 18% | {{D2_STATUS}} | {{D2_CONFIDENCE}} |
| 3 | Claude Code | 20% | {{D3_STATUS}} | {{D3_CONFIDENCE}} |
| 4 | Prompt Engineering | 20% | {{D4_STATUS}} | {{D4_CONFIDENCE}} |
| 5 | Context & Reliability | 15% | {{D5_STATUS}} | {{D5_CONFIDENCE}} |

<!--
  FILL all 10 cells above from the progress.md domain table.
  Use the symbol mapping defined in this block's comment.
-->

---

## Confidence Summary

<!--
  Compute from the 5 Confidence values just filled:
    HIGH_COUNT   = count of "High"
    MEDIUM_COUNT = count of "Medium"
    LOW_COUNT    = count of "Low"
    BLANK_COUNT  = count of "—" or "Not started"

  Write 1–2 plain-language sentences. Examples:
    "You have strong confidence across 4 of 5 domains, with Domain 2
     flagged for review."
    "Three domains are complete with mixed confidence — two High,
     one Low. Two domains are not yet started."
  Keep it factual; save encouragement for the Recommendation block.
-->

{{CONFIDENCE_SUMMARY}}

---

## Areas to Watch

<!--
  This section ONLY appears if at least one of these conditions is true:
    (a) Any domain has Confidence = Low
    (b) Any domain has Confidence = Medium
    (c) The Confusion Log in progress.md is non-empty

  If none of those conditions are true, replace this section with:
  > No flagged weak areas — all completed domains rated High confidence.

  OTHERWISE:
  1. List any domain with Confidence = Low first, labeled "(Low confidence — priority review)"
  2. List any domain with Confidence = Medium, labeled "(Medium confidence — worth revisiting)"
  3. Read .student_cca/progress.md → ## Confusion Log
     If there are entries, extract up to 3 most recent/prominent ones
     and list them as specific topic bullets under "Open confusions:"
     If the Confusion Log is empty or has only a heading, omit that sub-list.
-->

### Domains needing attention

{{WEAK_DOMAIN_LIST}}

<!--
  FILL: One bullet per flagged domain. Format:
    - **Domain N — [Title]** (Low confidence — priority review)
    - **Domain N — [Title]** (Medium confidence — worth revisiting)
  If no flagged domains at all, write: _None — all rated High or not yet started._
-->

### Open confusions

<!--
  CONDITIONAL: Only include this sub-section if the Confusion Log
  in progress.md has actual entries (not just the "## Confusion Log"
  header with nothing below it).
  Extract up to 3 entries. If none, omit this sub-section entirely.
-->

{{CONFUSION_LOG_ITEMS}}

---

## Recommended Next Focus

<!--
  ALWAYS include this section in both report variants.

  LOGIC — determine the student's current situation:

  CASE A: All 5 Complete
    → Skip to Readiness Recommendation (next section).
      Write here: "See readiness recommendation below."

  CASE B: 1–4 domains Complete, rest Not started or In Progress
    → Identify the next logical domain to work on.
      Priority order: In Progress first, then lowest-numbered Not started.
      List up to 3 specific, actionable next steps. Examples:
        - "Complete Domain 2 — Tool Design (18% of exam)"
        - "Review your Low-confidence notes on Domain 1 before moving on"
        - "After Domain 2, Domain 4 covers 20% — schedule it next"

  CASE C: 0 domains Complete (all Not started)
    → Recommend starting Domain 1.
      List 2 steps: open domain-1, note the 27% exam weight.

  Be specific. Name the domain, weight, and file path where relevant.
  Do not write generic study tips.
-->

{{NEXT_FOCUS_ITEMS}}

---

<!--
  ============================================================
  READINESS RECOMMENDATION
  ============================================================
  RENDER THIS SECTION ONLY for the FINAL READINESS REPORT
  (all 5 Status = Complete).

  FOR PROGRESS REPORT: Delete everything from this horizontal
  rule down to and including the closing "---" after the
  recommendation block. The document ends after "Recommended
  Next Focus."
  ============================================================
-->

## Readiness Recommendation

<!--
  APPLY the following three-tier logic to the 5 Confidence values:

  ── TIER 1: READY TO SIT ───────────────────────────────────────
  Condition: ALL of the following are true
    • No domain has Confidence = Low
    • At most 1 domain has Confidence = Medium
    • All 5 Status = Complete
  Render the READY block below.

  ── TIER 2: REVIEW THESE AREAS FIRST ──────────────────────────
  Condition: ANY of the following is true
    • Exactly 1–2 domains have Confidence = Low
    • 2–3 domains have Confidence = Medium
    (and all 5 Status = Complete, otherwise this is a Progress Report)
  Render the REVIEW block below.

  ── TIER 3: NEEDS MORE TIME ────────────────────────────────────
  Condition: ANY of the following is true
    • 3 or more domains have Confidence = Low
    • 4 or more domains have Confidence = Medium or Low combined
  Render the NEEDS MORE TIME block below.

  RENDER ONLY ONE of the three blocks. Delete the other two.
-->

<!-- ── READY TO SIT block (delete if not Tier 1) ── -->
> **READY TO SIT**
>
> You have demonstrated High or near-High confidence across all five
> domains. Your preparation covers {{EXAM_WEIGHT_READY}}% of the exam
> weight at High confidence. You are ready to schedule your exam.
>
> **Recommended action:** Review your Confusion Log one final time,
> then schedule within the next 7–14 days while the material is fresh.

<!--
  FILL {{EXAM_WEIGHT_READY}}: sum the Exam Weight percentages of all
  domains rated High (27+18+20+20+15 = 100 total). E.g. if domains
  1, 3, 4, 5 are High → 27+20+20+15 = 82%.
-->

<!-- ── REVIEW THESE AREAS FIRST block (delete if not Tier 2) ── -->
> **REVIEW THESE AREAS FIRST**
>
> You are close to exam-ready, but the following domains need
> additional review before you sit:
>
> {{REVIEW_DOMAIN_LIST}}
>
> These areas represent **{{REVIEW_WEIGHT}}%** of the exam.
> Focused review of 2–3 hours per flagged domain should be sufficient.
>
> **Recommended action:** Work through the flagged domains' exercises
> again, then reassess confidence in your progress tracker.

<!--
  FILL:
    {{REVIEW_DOMAIN_LIST}}: bullet list of Low and Medium confidence
      domains, one per line. Format:
        > - Domain N — [Title] ([Weight]%) — Confidence: [Level]
    {{REVIEW_WEIGHT}}: sum of Exam Weights for the flagged domains only
-->

<!-- ── NEEDS MORE TIME block (delete if not Tier 3) ── -->
> **NEEDS MORE TIME**
>
> Several domains are showing Low confidence, which represents
> significant exam risk. Do not sit until these are addressed:
>
> {{NEEDS_MORE_DOMAIN_LIST}}
>
> These areas represent **{{NEEDS_MORE_WEIGHT}}%** of the exam.
>
> **Recommended action:** Re-work the labs for each flagged domain
> from scratch. Use your Confusion Log as a study guide. Budget
> at least one full session per domain before re-assessing.

<!--
  FILL:
    {{NEEDS_MORE_DOMAIN_LIST}}: bullet list of all Low confidence
      domains. Format same as REVIEW_DOMAIN_LIST above.
    {{NEEDS_MORE_WEIGHT}}: sum of Exam Weights for Low confidence domains
-->

---

## What to Do Next

<!--
  ALWAYS include. Vary content by report variant and tier.

  PROGRESS REPORT — fill based on current state:
    List 3–5 numbered, concrete actions. Examples:
      1. Open `domains/domain-2-tool-design.md` — this domain is In Progress.
      2. After completing Domain 2, you will have covered 45% of exam weight.
      3. Use `switch to Challenger persona` before labs to sharpen precision.
    Reference actual file paths. Name specific domains by number and title.

  FINAL READINESS REPORT:
    Tier 1 (Ready):
      1. Read through your Confusion Log at .student_cca/progress.md.
      2. Skim exercise answer keys for any items that tripped you up.
      3. Schedule your exam. You are prepared.
    Tier 2 (Review):
      1. Re-run the lab for [lowest-weighted Low/Medium domain] first.
      2. For each flagged domain, spend 30 min on its demo narration.
      3. Re-run the Domain 5 checkpoint after review to re-score confidence.
      4. Schedule your exam once no domain is below Medium.
    Tier 3 (Needs more time):
      1. Block dedicated sessions for each Low-confidence domain.
      2. Re-do labs from Stage 1 with a different scenario to reinforce patterns.
      3. Use your Confusion Log as a flashcard list.
      4. Re-generate this report after each domain re-do to track improvement.
      5. Do not schedule until at least 4 of 5 domains reach Medium or higher.

  Be specific. Reference real domain titles, file paths, and weights.
  Do not write generic advice.
-->

{{NEXT_STEPS_LIST}}

---

<!--
  SAVE INSTRUCTION
  ─────────────────
  After filling and rendering this report, save the completed
  markdown to the appropriate file:

  Progress Report  → .student_cca/progress-report-{{DATE_FILENAME}}.md
  Final Report     → .student_cca/readiness-report-final.md

  Where {{DATE_FILENAME}} = date in YYYYMMDD format (e.g. 20260412).

  Confirm to the student: "Your report has been saved to [path]."
  Then ask: "Would you like to continue with [next domain / exam prep]?"
-->

---

*CCA Foundations — Certified Claude Associate*
*Report generated {{DATE}} · learn.anthropic.com*
