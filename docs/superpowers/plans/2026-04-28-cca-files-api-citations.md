# CCA Files API + Citations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Files API (Domain 2, section 9) and Citations (Domain 4, section 10) as native course sections, including patterns library updates and checkpoint updates.

**Architecture:** Each addition is inserted into the existing domain markdown file at the correct position (before the Domain Checkpoint), following the established pattern: 4 persona variants → core concepts → knowledge check → exam pattern callout. Domain Checkpoints are updated to include the new topic numbers. Patterns library receives one new decision-framework row and one new anti-pattern per addition.

**Tech Stack:** Markdown file edits only. No code, no build system. Verification via grep and read.

---

## File Map

| File | Change |
|---|---|
| `domains/domain-2-tool-design.md` | Insert section 9 (Files API) before `## Domain Checkpoint` (~line 338); update Checkpoint topic list and Last session note template |
| `domains/domain-4-prompt-engineering.md` | Insert section 10 (Citations) before `## Domain Checkpoint` (~line 545); update Checkpoint topic list and Last session note template |
| `patterns/decision-frameworks.md` | Add Files API row to Domain 2 table; add Citations row to Domain 4 table |
| `patterns/anti-patterns.md` | Add AP-2.5 after AP-2.4 section; add AP-4.6 after AP-4.5 section |

---

### Task 1: Add Files API section to domain-2-tool-design.md

**Files:**
- Modify: `domains/domain-2-tool-design.md` (insert before `## Domain Checkpoint`)

- [ ] **Step 1: Locate the insertion point**

Run:
```bash
grep -n "^## Domain Checkpoint" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-2-tool-design.md
```
Expected: one line showing the line number of `## Domain Checkpoint` (should be around 338).

- [ ] **Step 2: Insert the Files API section**

Insert the following block immediately before the `---` + `## Domain Checkpoint` line (the `---` separator that precedes it). Use the Edit tool with `old_string` = the separator + checkpoint header:

```
old_string:
---

## Domain Checkpoint

**Instructions for Claude (instructor role):**

new_string: (the Files API section + the separator + checkpoint header)
```

The exact content to insert (replace `old_string` with `new_string` as shown):

**old_string:**
```
---

## Domain Checkpoint

**Instructions for Claude (instructor role):**
```

**new_string:**
```
---

### 9. Files API

> **Instructor — opening narration in persona voice:**
>
> *Practitioner:* "The Files API is a resource design decision: upload a document once, reference it by ID across multiple calls. If you're running the same contract through three sequential analyses, you're not re-embedding the full PDF three times — you upload once, store the file_id, and pass that ID. It's the difference between a library that photocopies books for every patron vs. one that has a shared copy on the shelf."
>
> *Socratic:* "Before I explain the Files API — what do you think happens to your token cost and latency if you embed a 50-page PDF in every message for a 5-step analysis pipeline? Now what changes if the document is stored server-side and you pass only a reference?"
>
> *Coach:* "The Files API sounds technical but the concept is simple: upload once, reuse many times. It's the same principle as storing a file on a server vs. emailing it as an attachment every time. The API makes this explicit with a file_id you store and reference."
>
> *Challenger:* "Files API or inline document — which do you use, and when? Don't give me the general principle. Give me the decision rule with the specific conditions that flip your choice."

---

**What the Files API is:** An Anthropic API feature that lets you upload a document once and reference it by `file_id` across multiple API calls. Files persist on Anthropic's servers for up to 30 days.

**How it works:**

```python
import anthropic

client = anthropic.Anthropic()

# Upload once
with open("patient_record.pdf", "rb") as f:
    file_response = client.beta.files.upload(
        file=("patient_record.pdf", f, "application/pdf")
    )

file_id = file_response.id  # store and reuse

# Reference in multiple calls
response = client.beta.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {
                    "type": "file",
                    "file_id": file_id
                }
            },
            {"type": "text", "text": "Summarize the key diagnoses."}
        ]
    }],
    betas=["files-api-2025-04-14"]
)
```

**Supported file types:** PDF, plain text, images (for vision tasks)

**File lifecycle:** Files persist for up to 30 days. Use `client.beta.files.delete(file_id)` to remove earlier. List uploaded files with `client.beta.files.list()`.

**Files API vs. inline documents:**

| | Files API | Inline document |
|---|---|---|
| When to use | Same doc, multiple calls | One-off analysis |
| Cost | Pay once for upload; reference is cheaper on repeated calls | Pay full tokens every call |
| Latency | Lower on repeated calls | Same every call |
| Expiry | 30 days | N/A — not stored |

**When to use Files API:**
- Same document analyzed multiple times across sequential calls (e.g., extract → score → summarize pipeline)
- Multi-agent workflows where several agents need the same source document
- Large documents where repeated inline embedding adds significant cost

**When to use inline documents:**
- One-off single-call analysis
- Documents that change on every call
- Simplicity preferred over optimization

> **Knowledge Check 9:** You're building an agent that processes legal contracts — it runs three sequential analyses (clause extraction → risk scoring → summary generation) on the same PDF. Would you use the Files API or embed the PDF inline in each call? Why?
>
> *(Take a moment before scrolling)*
>
> **Exam-aligned answer:** Files API. The same document is used across three sequential calls — uploading inline three times pays full PDF token cost three times. Upload once with `client.beta.files.upload()`, store the `file_id`, reference it in all three calls. Use `client.beta.files.delete(file_id)` when done if you don't want the file persisting for 30 days.

> **Exam pattern:** The CCA exam tests Files API in tool/resource design scenarios. The pattern: same document, multiple calls → Files API. One-off analysis → inline. Questions may also ask about file lifecycle (30-day expiry, explicit deletion with `delete()`).

---

## Domain Checkpoint

**Instructions for Claude (instructor role):**
```

- [ ] **Step 3: Verify the insertion**

Run:
```bash
grep -n "### 9. Files API\|## Domain Checkpoint" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-2-tool-design.md
```
Expected: two lines — `### 9. Files API` appearing before `## Domain Checkpoint`.

- [ ] **Step 4: Update the Checkpoint topic list**

Find the confidence check list in the Domain Checkpoint (currently topics 1–8). Update it to add topic 9:

**old_string:**
```
1. Tool interface design (name, description, input schema)
2. Structured error responses
3. tool_choice options (auto / any / tool)
4. Built-in tools (computer use, web search, code execution)
5. Tool distribution (direct API vs. MCP vs. Claude Code built-ins)
6. MCP configuration
7. Tool result handling
8. Security considerations (injection, least privilege, audit logging)
```

**new_string:**
```
1. Tool interface design (name, description, input schema)
2. Structured error responses
3. tool_choice options (auto / any / tool)
4. Built-in tools (computer use, web search, code execution)
5. Tool distribution (direct API vs. MCP vs. Claude Code built-ins)
6. MCP configuration
7. Tool result handling
8. Security considerations (injection, least privilege, audit logging)
9. Files API — when to use vs. inline documents, file lifecycle
```

- [ ] **Step 5: Update the Last session note template**

Find the Last session note template in the Domain Checkpoint. Update it:

**old_string:**
```
Completed Domain 2 (Tool Design & MCP). Topics covered: tool interface design, structured errors, tool_choice, built-in tools, tool distribution, MCP configuration, tool result handling, security. Confidence ratings: [list each topic and rating]. Weak areas flagged: [list Low-confidence topics or "none"].
```

**new_string:**
```
Completed Domain 2 (Tool Design & MCP). Topics covered: tool interface design, structured errors, tool_choice, built-in tools, tool distribution, MCP configuration, tool result handling, security, Files API. Confidence ratings: [list each topic and rating]. Weak areas flagged: [list Low-confidence topics or "none"].
```

- [ ] **Step 6: Verify the checkpoint updates**

Run:
```bash
grep -n "Files API" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-2-tool-design.md
```
Expected: at least 3 lines — in the section heading, the checkpoint topic list, and the Last session note template.

- [ ] **Step 7: Commit**

```bash
cd /mnt/c/Users/bradj/Development/Arch_Claude && git add domains/domain-2-tool-design.md && git commit -m "feat: add Files API section to Domain 2 (section 9)"
```

---

### Task 2: Add Citations section to domain-4-prompt-engineering.md

**Files:**
- Modify: `domains/domain-4-prompt-engineering.md` (insert before `## Domain Checkpoint`)

- [ ] **Step 1: Locate the insertion point**

Run:
```bash
grep -n "^## Domain Checkpoint" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-4-prompt-engineering.md
```
Expected: one line showing the line number of `## Domain Checkpoint` (should be around 545).

- [ ] **Step 2: Insert the Citations section**

**old_string:**
```
---

## Domain Checkpoint

When the student reaches this section, Claude should run the following sequence:
```

**new_string:**
```
---

### 10. Citations

> **Instructor — opening narration in persona voice:**
>
> *Practitioner:* "Citations turn 'Claude says X' into 'Claude says X, citing paragraph 3 of document Y.' In compliance-sensitive domains — healthcare, legal, finance — that distinction is the difference between a usable answer and an unauditable one. Citations give you a structured pointer from each claim back to the exact source passage."
>
> *Socratic:* "Imagine you built a document QA system and a clinician asks 'what diagnoses are listed in this record?' Claude answers correctly — but how does the clinician know which part of the record to trust? What would you need to add to make the answer auditable rather than just accurate?"
>
> *Coach:* "Citations are one of those features that sounds advanced but is one parameter away: add `citations: {enabled: True}` to your document input and Claude returns structured source attributions alongside its response. The skill is knowing when traceability matters and when it doesn't."
>
> *Challenger:* "Citations vs. RAG — two different tools. Don't confuse them. Explain what each one does, what problem it solves, and give me a scenario where you'd use both together."

---

**What citations are:** When you pass a document to Claude and ask it to analyze, extract, or answer questions from it, Claude can return structured source attributions — exact quotes from the source document linked to the claims in the response.

**How to enable:**

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {"type": "text", "media_type": "text/plain", "data": document_text},
                "title": "Patient Record MRH-2947",
                "citations": {"enabled": True}
            },
            {"type": "text", "text": "What diagnoses are listed?"}
        ]
    }]
)
```

**What citation objects contain:**

| Field | Description |
|---|---|
| `type` | `"char_location"` (character-level) or `"page_location"` (page-level for PDFs) |
| `cited_text` | Exact quote from the source document |
| `document_title` | The title you provided on the document input |
| `start_char_index` / `end_char_index` | Character range (char_location type) |
| `page` | Page number (page_location type) |

**When to use citations:**
- Document QA where answers must be traceable to specific source passages
- Compliance-sensitive domains (healthcare, legal, finance) requiring audit trails
- Multi-document analysis where the agent must distinguish which source supports which claim
- Any use case where "Claude found this in the document" must be verifiable by a downstream system or human reviewer

**When NOT to use citations:**
- Generative tasks (summaries, rewrites, creative output) — citations are meaningless when Claude is synthesizing rather than quoting
- High-throughput pipelines where citation parsing adds latency with no downstream consumer
- Simple extraction tasks where the caller already has the source and doesn't need pointers back to it

**Citations vs. RAG:**

RAG retrieves relevant chunks *before* the call. Citations attribute *within* the call. They are complementary: RAG surfaces the right documents; citations verify which parts of those documents support the response. In a production document QA system, you might use RAG to narrow from 1,000 documents to 5, then citations to attribute which passages from those 5 support each answer.

> **Knowledge Check 10:** You're building a healthcare QA agent that answers clinician questions by reading patient notes. Compliance requires that every answer be traceable to a specific source passage. Should you use citations? What does the citation object give you that a plain text response doesn't?
>
> *(Take a moment before scrolling)*
>
> **Exam-aligned answer:** Yes — use citations. A plain text response tells the clinician what Claude found; the citation object tells them *where* — the exact passage (`cited_text`), its position in the document (`start_char_index`/`end_char_index` or `page`), and which document it came from (`document_title`). That's the audit trail compliance requires. Enable with `citations: {"enabled": True}` on the document input.

> **Exam pattern:** The CCA exam tests citations in document analysis scenarios. The key distinction: citations are for attribution and traceability — appropriate when downstream systems or users need to verify claims against source documents. For generative tasks (summaries, rewrites), citations are meaningless. Questions may also ask about the difference between citations and RAG: RAG = retrieval before the call; citations = attribution within the call. They are complementary, not alternatives.

---

## Domain Checkpoint

When the student reaches this section, Claude should run the following sequence:
```

- [ ] **Step 3: Verify the insertion**

Run:
```bash
grep -n "### 10. Citations\|## Domain Checkpoint" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-4-prompt-engineering.md
```
Expected: `### 10. Citations` appearing before `## Domain Checkpoint`.

- [ ] **Step 4: Update the Checkpoint topic list**

**old_string:**
```
> 1. Explicit criteria — specifying success conditions precisely
> 2. Few-shot prompting — when and how to use examples
> 3. Structured output — JSON/XML schema design for reliability
> 4. Validation loops — multi-pass output checking
> 5. Batch API — when to use vs. real-time API
> 6. Multi-instance review — calibrating confidence across calls
> 7. Prompt injection — attack patterns and defenses
> 8. System prompt design — what belongs in system vs. user turn
> 9. Extended thinking — when to use it, budget_tokens as a ceiling, exam trap with few-shot"
```

**new_string:**
```
> 1. Explicit criteria — specifying success conditions precisely
> 2. Few-shot prompting — when and how to use examples
> 3. Structured output — JSON/XML schema design for reliability
> 4. Validation loops — multi-pass output checking
> 5. Batch API — when to use vs. real-time API
> 6. Multi-instance review — calibrating confidence across calls
> 7. Prompt injection — attack patterns and defenses
> 8. System prompt design — what belongs in system vs. user turn
> 9. Extended thinking — when to use it, budget_tokens as a ceiling, exam trap with few-shot
> 10. Citations — when to enable, what citation objects contain, citations vs. RAG"
```

- [ ] **Step 5: Update the Last session note template**

**old_string:**
```
Completed Domain 4 (Prompt Engineering, 20%). [Confidence summary sentence. Flag any Low areas.]
```

**new_string:**
```
Completed Domain 4 (Prompt Engineering, 20%). Topics: explicit criteria, few-shot, structured output, validation loops, Batch API, multi-instance review, prompt injection, system prompt design, extended thinking, citations. [Confidence summary sentence. Flag any Low areas.]
```

- [ ] **Step 6: Verify the checkpoint updates**

Run:
```bash
grep -n "Citations\|citations" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-4-prompt-engineering.md | head -10
```
Expected: lines in the section heading, the checkpoint topic list, and the Last session note template.

- [ ] **Step 7: Commit**

```bash
cd /mnt/c/Users/bradj/Development/Arch_Claude && git add domains/domain-4-prompt-engineering.md && git commit -m "feat: add Citations section to Domain 4 (section 10)"
```

---

### Task 3: Update patterns/decision-frameworks.md

**Files:**
- Modify: `patterns/decision-frameworks.md`

- [ ] **Step 1: Add Files API row to Domain 2 table**

The Domain 2 table currently ends with the `| What makes a tool description reliable |` row. Insert the new row after it:

**old_string:**
```
| What makes a tool description reliable | Explicit: what the tool does, when to call it, what values are valid for each parameter (enums, ranges, formats), constraints on when NOT to call it, expected output format. See Domain 2 Version A vs. Version B exercise. |

---

## Domain 3 — Claude Code
```

**new_string:**
```
| What makes a tool description reliable | Explicit: what the tool does, when to call it, what values are valid for each parameter (enums, ranges, formats), constraints on when NOT to call it, expected output format. See Domain 2 Version A vs. Version B exercise. |
| When to use Files API vs. inline document | **Files API** → same document, multiple API calls (upload once, reference by `file_id`). **Inline** → one-off single-call analysis. Cost and latency favor Files API for repeated use. Files expire in 30 days; use `client.beta.files.delete(file_id)` to remove earlier. |

---

## Domain 3 — Claude Code
```

- [ ] **Step 2: Verify the Domain 2 Files API row**

Run:
```bash
grep -n "Files API" /mnt/c/Users/bradj/Development/Arch_Claude/patterns/decision-frameworks.md
```
Expected: one line in the Domain 2 table section.

- [ ] **Step 3: Add Citations row to Domain 4 table**

The Domain 4 table currently ends with the `| How to set budget_tokens |` row. Insert the new row after it:

**old_string:**
```
| How to set budget_tokens for extended thinking | Start at 5,000–10,000 for moderate complexity. Increase to 10,000–32,000 for multi-hop reasoning chains. `budget_tokens` is a ceiling — model uses what the task requires. Too low on a hard task → shallow reasoning. Too high on a simple task → wasted cost, identical output. Minimum is 1,024. |

---

## Domain 5 — Context & Reliability
```

**new_string:**
```
| How to set budget_tokens for extended thinking | Start at 5,000–10,000 for moderate complexity. Increase to 10,000–32,000 for multi-hop reasoning chains. `budget_tokens` is a ceiling — model uses what the task requires. Too low on a hard task → shallow reasoning. Too high on a simple task → wasted cost, identical output. Minimum is 1,024. |
| When to enable citations | **Use:** document QA, compliance-sensitive domains (healthcare, legal, finance), multi-document analysis where claims must trace to source passages. **Do not use:** generative tasks (summaries, rewrites, classifications) — citations are meaningless when Claude is synthesizing rather than quoting. Citations and RAG are complementary: RAG retrieves before the call; citations attribute within it. |

---

## Domain 5 — Context & Reliability
```

- [ ] **Step 4: Verify the Domain 4 Citations row**

Run:
```bash
grep -n "citations\|Citations" /mnt/c/Users/bradj/Development/Arch_Claude/patterns/decision-frameworks.md
```
Expected: one line in the Domain 4 table section.

- [ ] **Step 5: Commit**

```bash
cd /mnt/c/Users/bradj/Development/Arch_Claude && git add patterns/decision-frameworks.md && git commit -m "feat: add Files API and Citations rows to decision-frameworks"
```

---

### Task 4: Update patterns/anti-patterns.md

**Files:**
- Modify: `patterns/anti-patterns.md`

- [ ] **Step 1: Add AP-2.5 after AP-2.4**

The AP-2.4 section ends with the `---` separator before `## Domain 3`. Insert AP-2.5 between AP-2.4's closing `---` and the Domain 3 header:

**old_string:**
```
**What to do instead:** One tool, one action. `get_patient_data`, `route_patient`, `send_notification`, `log_routing_decision` — separate tools. The model composes them; the tools remain atomic and auditable.

---

## Domain 3 — Claude Code
```

**new_string:**
```
**What to do instead:** One tool, one action. `get_patient_data`, `route_patient`, `send_notification`, `log_routing_decision` — separate tools. The model composes them; the tools remain atomic and auditable.

---

### AP-2.5 — Files API Misuse: Re-Uploading on Every Call

**What it looks like:** An agent that analyzes the same contract PDF in 5 sequential calls re-uploads the file as an inline document on every call. The developer copied the "pass a document" pattern from the quickstart and never reconsidered it.

**Why it fails:** Inline document embedding pays the full PDF token cost on every call. A 50-page PDF embedded 5 times costs 5x what it should. The Files API exists precisely for this pattern: upload once, reference by `file_id` on subsequent calls. Cost and latency both suffer unnecessarily.

**What to do instead:** Upload once with `client.beta.files.upload()`, store the returned `file_id`, and pass `{"type": "file", "file_id": file_id}` in the document source for all subsequent calls. Use `client.beta.files.delete(file_id)` to remove the file when processing is complete rather than letting it persist for 30 days.

---

## Domain 3 — Claude Code
```

- [ ] **Step 2: Verify AP-2.5 insertion**

Run:
```bash
grep -n "### AP-2\." /mnt/c/Users/bradj/Development/Arch_Claude/patterns/anti-patterns.md
```
Expected: AP-2.1, AP-2.2, AP-2.3, AP-2.4, AP-2.5 all present.

- [ ] **Step 3: Add AP-4.6 after AP-4.5**

The AP-4.5 section ends with the `---` separator before `## Domain 5`. Insert AP-4.6 between AP-4.5's closing `---` and the Domain 5 header:

**old_string:**
```
**What to do instead:** Benchmark with and without extended thinking. For classification and extraction tasks, 3–5 few-shot examples outperform extended thinking at a fraction of the cost and latency. Enable extended thinking only when the task genuinely requires multi-step reasoning — novel problems, multi-hop analysis, complex synthesis. When in doubt: try few-shot first.

---

## Domain 5 — Context & Reliability
```

**new_string:**
```
**What to do instead:** Benchmark with and without extended thinking. For classification and extraction tasks, 3–5 few-shot examples outperform extended thinking at a fraction of the cost and latency. Enable extended thinking only when the task genuinely requires multi-step reasoning — novel problems, multi-hop analysis, complex synthesis. When in doubt: try few-shot first.

---

### AP-4.6 — Citations on Generative Tasks

**What it looks like:** A summary generation pipeline adds `"citations": {"enabled": True}` to all document inputs. The developer expects citations to improve output quality or add credibility to summaries.

**Why it fails:** Citations attribute claims to source passages. Summaries are synthesis — Claude is not quoting from the document, it is paraphrasing and condensing it. Citations either don't fire at all, or they attach to synthesized content in ways that are meaningless to downstream consumers. The feature adds no quality benefit and adds response parsing complexity.

**What to do instead:** Enable citations only when the task requires traceability — document QA answers, specific extractions, or claims that should point to a passage a human or system needs to verify. For summarization, rewriting, or classification tasks, remove the `citations` parameter entirely and evaluate output quality on its own merits.

---

## Domain 5 — Context & Reliability
```

- [ ] **Step 4: Verify AP-4.6 insertion**

Run:
```bash
grep -n "### AP-4\." /mnt/c/Users/bradj/Development/Arch_Claude/patterns/anti-patterns.md
```
Expected: AP-4.1, AP-4.2, AP-4.3, AP-4.4, AP-4.5, AP-4.6 all present.

- [ ] **Step 5: Commit**

```bash
cd /mnt/c/Users/bradj/Development/Arch_Claude && git add patterns/anti-patterns.md && git commit -m "feat: add AP-2.5 and AP-4.6 to anti-patterns"
```

---

## Final Verification

After all four tasks complete, run:

```bash
grep -n "### 9. Files API" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-2-tool-design.md
grep -n "### 10. Citations" /mnt/c/Users/bradj/Development/Arch_Claude/domains/domain-4-prompt-engineering.md
grep -c "Files API\|Citations" /mnt/c/Users/bradj/Development/Arch_Claude/patterns/decision-frameworks.md
grep -n "AP-2.5\|AP-4.6" /mnt/c/Users/bradj/Development/Arch_Claude/patterns/anti-patterns.md
```

Expected:
- Line number returned for Files API section heading
- Line number returned for Citations section heading
- Count ≥ 2 (one row per addition)
- Lines for both AP-2.5 and AP-4.6
