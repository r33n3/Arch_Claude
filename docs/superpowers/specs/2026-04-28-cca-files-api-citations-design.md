# Design — CCA Course Content Gap Fills: Files API + Citations

**Date:** 2026-04-28
**Status:** Approved
**Scope:** Two integrated additions to the CCA Foundations exam prep course

---

## Problem

The CCA Foundations course is missing two exam-relevant topics:

1. **Files API** (Domain 2) — an Anthropic API resource/tool pattern for uploading documents once and referencing by file ID across multiple calls; absent from `domain-2-tool-design.md`
2. **Citations** (Domain 4) — structured source attribution returned by Claude when analyzing documents; absent from `domain-4-prompt-engineering.md`

Additionally, `patterns/decision-frameworks.md` and `patterns/anti-patterns.md` are missing entries for both topics.

---

## Approach

**Integrated native sections** — each addition is inserted into the existing domain's concept walkthrough at the correct position, following the established course structure (4 persona variants, knowledge check, exam pattern callout). The patterns library is updated in parallel. No new files are created.

---

## Addition 1 — Domain 2: Files API

**File:** `domains/domain-2-tool-design.md`
**Position:** New section 9, inserted after existing section 8 "Security Considerations", before the Domain Checkpoint

### Content specification

**Opening narration** — 4 persona variants framing the Files API as a resource design decision: upload once, reference many times.

**Core concepts:**

**What the Files API is:** An Anthropic API feature that lets you upload a document once and reference it by `file_id` across multiple API calls. Rather than embedding the full document content in every user turn, you upload it once and pass the ID. Files persist on Anthropic's servers for up to 30 days.

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
| Cost | Pay once for upload; reference is cheaper | Pay full tokens every call |
| Latency | Lower on repeated calls (server has the file) | Same every call |
| Expiry | 30 days | N/A — not stored |

**When to use Files API:**
- Same document analyzed multiple times across different calls (analysis, extraction, summarization in sequence)
- Multi-agent workflows where several agents need the same source document
- Large documents that would otherwise add cost from repeated re-embedding

**When to use inline documents:**
- One-off single-call analysis
- Documents that change on every call
- Simplicity preferred over optimization

**Knowledge check:** You're building an agent that processes legal contracts: it runs three sequential analyses (clause extraction → risk scoring → summary generation) on the same PDF. Would you use the Files API or embed the PDF inline in each call? Why?

**Exam pattern callout:**
> The CCA exam tests Files API in tool/resource design scenarios: when is it appropriate vs. when is inline document passing correct? The pattern: same document, multiple calls → Files API. One-off analysis → inline. Questions may also ask about file lifecycle (30-day expiry, explicit deletion).

---

## Addition 2 — Domain 4: Citations

**File:** `domains/domain-4-prompt-engineering.md`
**Position:** New section 10, inserted after existing section 9 "Extended Thinking", before the Domain Checkpoint

### Content specification

**Opening narration** — 4 persona variants framing citations as a traceability mechanism: turning "Claude says X" into "Claude says X, citing paragraph 3 of document Y."

**Core concepts:**

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
- `type`: `"char_location"` (character-level) or `"page_location"` (page-level for PDFs)
- `cited_text`: the exact quote from the source document
- `document_title`: the document title you provided
- `start_char_index` / `end_char_index` (char-level) or `page` (page-level)

**When to use citations:**
- Document QA where answers must be traceable to specific source passages
- Compliance-sensitive domains (healthcare, legal, finance) requiring audit trails
- Multi-document analysis where the agent must distinguish which source supports which claim
- Any use case where "Claude found this in the document" must be verifiable

**When NOT to use citations:**
- Generative tasks (summaries, rewrites, classifications) — citations are meaningless when Claude is synthesizing rather than quoting
- Real-time or high-throughput pipelines where citation parsing adds latency with no downstream consumer
- Simple extraction tasks where the caller already has the source

**Citations vs. RAG:**
RAG retrieves relevant chunks before the call. Citations attribute within the call. They are complementary: RAG surfaces the right documents; citations verify which parts of those documents support the response.

**Knowledge check:** You're building a healthcare QA agent that answers clinician questions by reading patient notes. Compliance requires that every answer be traceable to a source passage. Should you use citations? What does the citation object give you that a plain text response doesn't?

**Exam pattern callout:**
> The CCA exam tests citations in document analysis scenarios. The key distinction: citations are for attribution and traceability — appropriate when downstream systems need to verify claims against source documents. For generative tasks (summarization, creative rewriting), citations are meaningless. Questions may also ask about the difference between citations and RAG.

---

## Patterns Library Updates

### decision-frameworks.md additions

**Domain 2 table — new row:**
| When to use Files API vs. inline document | Files API → same document, multiple API calls (upload once, reference by ID). Inline → one-off single-call analysis. Cost and latency favor Files API for repeated use; inline is simpler for single-use. |

**Domain 4 table — new row:**
| When to enable citations | Document QA, compliance-sensitive domains, multi-document analysis where claims must trace to source passages. Not for generative tasks (summaries, rewrites) — citations are meaningless when Claude is synthesizing rather than quoting. |

### anti-patterns.md additions

**AP-2.5 — Files API Misuse: Re-Uploading on Every Call**
- What it looks like: An agent that analyzes the same contract PDF in 5 sequential calls re-uploads the file as an inline document every time.
- Why it fails: Redundant token cost (paying for the full document on every call) and unnecessary latency. The Files API exists precisely for this pattern.
- What to do instead: Upload once with `client.beta.files.upload()`, store the `file_id`, and reference it across all subsequent calls. Clean up with `delete()` when done.

**AP-4.6 — Citations on Generative Tasks**
- What it looks like: A summary generation pipeline has `citations: {enabled: true}`. The developer expects citations to improve quality.
- Why it fails: Citations attribute claims to source passages. When the output is a synthesis or summary, citations either don't fire or attach meaninglessly to synthesized content.
- What to do instead: Enable citations only when the task requires traceability — answers or extractions that should point back to a specific passage. For summarization, remove citations and evaluate output quality directly.

---

## Implementation Checklist

- [ ] Add Files API section to `domains/domain-2-tool-design.md` (new section 9, before Domain Checkpoint)
- [ ] Update Domain 2 Checkpoint confidence list to include "Files API" as topic 9
- [ ] Update Domain 2 Last session note template to include Files API
- [ ] Add Citations section to `domains/domain-4-prompt-engineering.md` (new section 10, before Domain Checkpoint)
- [ ] Update Domain 4 Checkpoint confidence list to include "Citations" as topic 10
- [ ] Update Domain 4 Last session note template to include Citations
- [ ] Add Files API row to Domain 2 table in `patterns/decision-frameworks.md`
- [ ] Add Citations row to Domain 4 table in `patterns/decision-frameworks.md`
- [ ] Add AP-2.5 to Domain 2 section in `patterns/anti-patterns.md`
- [ ] Add AP-4.6 to Domain 4 section in `patterns/anti-patterns.md`

---

## Files Modified

| File | Change |
|---|---|
| `domains/domain-2-tool-design.md` | Add section 9: Files API; update Domain Checkpoint |
| `domains/domain-4-prompt-engineering.md` | Add section 10: Citations; update Domain Checkpoint |
| `patterns/decision-frameworks.md` | Add rows for Files API (Domain 2) and Citations (Domain 4) |
| `patterns/anti-patterns.md` | Add AP-2.5, AP-4.6 |

No new files created.
