# Anthropic Academy — Visual Style Guide
Source: https://www.anthropic.com/learn (analyzed 2026-04-11)
Use for: CCA Foundations progress reports and readiness report styling

---

## Color Palette

### Backgrounds
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Ivory Light | `#faf9f5` | rgb(250, 249, 245) | Page background |
| Ivory Medium | `#f0eee6` | rgb(240, 238, 230) | Newsletter/callout boxes |
| Oat | `#e3dacc` | rgb(227, 218, 204) | Featured section containers |
| Ivory Dark | `#e8e6dc` | rgb(232, 230, 220) | Subtle divider backgrounds |
| Card Tint | `rgba(25,25,25,0.1)` | — | Inner cards on oat background |

### Section Accent Colors
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Cactus | `#bcd1ca` | rgb(188, 209, 202) | Section background variant (green-teal) |
| Heather | `#cbcadb` | rgb(203, 202, 219) | Section background variant (lavender) |
| Sky | `#6a9bcc` | rgb(106, 155, 204) | Section background variant (blue) |
| Clay | `#d97757` | — | Accent / highlight color |

### Text & Interactive
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| Dark (primary) | `#141413` | rgb(20, 20, 19) | All body text, headings, borders |
| Slate Medium | `#3d3d3a` | — | Secondary text |
| Slate Light | `#5e5d59` | — | Muted text |
| Cloud Light | `#d1cfc5` | — | Dividers |
| Focus Blue | `#2c84db` | — | Focus rings |
| Error Red | `#bf4d43` | — | Error states |

---

## Typography

**Font stack:** `anthropicSerif, "anthropicSerif Fallback", serif`  
(Fallback for reports: `Georgia, "Times New Roman", serif`)

| Element | Size | Weight | Line Height | Notes |
|---------|------|--------|-------------|-------|
| H1 | 36px | 500 | 36px | Page title |
| H2 | 23px | 500 | 27.6px | Section headings |
| Body paragraph | 20px | 400 | 31px | Main content |
| Card title | 22px | 400 | — | Course card heading |
| Card label | 17px | 400 | — | "Featured Course" eyebrow |
| Small / nav | 15px | 400 | — | Utility text |
| Card link text | 16px | 400 | 20px | Letter-spacing: -0.16px |

---

## Spacing Tokens

```
4px   8px   12px   16px   24px   32px   40px   48px   64px   80px   96px   128px
```

Page gutter: **32px**  
Section padding: **48px**  
Card inner padding: **24px**

---

## Border Radius

| Token | Value | Use |
|-------|-------|-----|
| br-4 | 4px | Buttons (dark CTA) |
| br-8 | 8px | Inner cards, outlined buttons |
| br-12 | 12px | Section containers |
| br-16 | 16px | Larger containers |

---

## Component Patterns

### Section Container
```
background: #e3dacc (oat)
border-radius: 12px
padding: 48px
```

### Inner Card (on oat section)
```
background: rgba(25, 25, 25, 0.1)  ← 10% black tint on oat = ~rgb(204,196,184)
border-radius: 8px
padding: 24px
```

### Outlined Button ("See all courses")
```
border: 1px solid #141413
border-radius: 8px
padding: 8px 16px
background: transparent
font-size: 15px
color: #141413
```

### Dark CTA Button
```
background: #141413
border-radius: 4px
color: #ffffff
padding: 8px 16px
```

### Callout / Newsletter Box
```
background: #f0eee6 (ivory-medium)
border-radius: 12px
padding: 24px
```

### Course Card (full clickable)
```
border: 1px solid #141413
border-radius: 8px
padding: 8px 16px
background: transparent
```
Card eyebrow label: 17px, weight 400  
Card title: 22px, weight 400  
Arrow icon: → right-aligned

---

## Report Template Guidance

Apply these patterns to CCA progress and readiness reports:

### Page Layout
- Background: `#faf9f5` (ivory-light)
- Content max-width: ~900px, centered
- Side padding: 32px

### Report Header
- H1 style: 36px serif, weight 500
- Subtitle: 20px, weight 400, line-height 31px
- Background: transparent (body bg shows through)

### Domain Summary Section
Use oat section container pattern:
- Container: `#e3dacc`, 12px radius, 48px padding
- Per-domain row: tint-10 inner card, 8px radius, 24px padding
- Confidence label: small text (15px), color coded:
  - High: olive `#788c5d`
  - Medium: clay `#d97757`  
  - Low: error red `#bf4d43`

### Readiness Recommendation Block
Use heather (`#cbcadb`) or cactus (`#bcd1ca`) section depending on outcome:
- Ready to sit → cactus (green-teal, positive)
- Review areas → heather (neutral lavender)
- Needs more time → ivory-medium with clay accent

### Weak Areas / Focus List
- Callout box: ivory-medium `#f0eee6`, 12px radius, 24px padding
- List items: 20px body text
- Headers: H2 style (23px, weight 500)

---

## What NOT to Do
- No bright whites (#fff) as section backgrounds — always use ivory-light or warmer tones
- No blue as a primary color — sky is accent only
- No bold (700+) weight — Anthropic uses 400–500 throughout
- No tight line heights — body text needs breathing room (31px for 20px text = 1.55)
- No hard-edged containers — always use border-radius tokens (minimum br-8)
- No generic sans-serif — use serif stack always; fallback to Georgia not Arial/Helvetica
