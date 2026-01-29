---
name: docs-directory
description: Create and maintain a centralized /docs directory with durable, well-structured project documentation (one concept per file, logical hierarchy, clear writing). Use when the user asks to add documentation, architecture docs, ADRs, design docs, runbooks, onboarding docs, or to organize existing docs.
---

# Centralized `/docs` Directory

## Goal

Keep long-lasting project documentation in a top-level `docs/` directory that is:

- structured (not a flat dumping ground)
- easy to navigate
- one concept per file
- elaborate yet clear and understandable

## When to use

Use this approach when adding or reorganizing durable docs:

- architecture / system design
- decisions (ADRs)
- runbooks / operations
- onboarding
- guides / how-tos
- reference material

## Default `/docs` structure

Prefer a small set of predictable top-level categories, with room to grow:

```
docs/
  README.md
  architecture/
  decisions/
  guides/
  reference/
  runbooks/
  onboarding/
```

Guidance:

- `docs/README.md` is the landing page (what’s in here + where to start).
- Keep categories meaningful; don’t add new folders unless they add clarity.
- Nest only when it helps scanning (avoid deep nesting unless the project is large).

## One concept per file

- Each doc file should answer one clear question (single topic, single purpose).
- If a doc is growing into multiple topics, split it and link between the docs.
- Avoid “everything.md” and giant, multi-purpose documents.

## Writing style

- Optimize for future readers: assume they didn’t write the code.
- Be concrete, specific, and consistent with terminology used in the codebase.
- Prefer short sections, explicit headings, and examples over long prose.
- Explain decisions and trade-offs; avoid repeating what the code already shows.

## File naming conventions

- Prefer `kebab-case.md` for filenames (predictable, readable).
- Prefer folder names that match doc intent (`guides`, `runbooks`, `reference`, etc.).

## Document templates

### Default doc template (most files)

Use this structure:

```markdown
# <Title>

## Purpose
<What this doc is for and who should read it>

## Context
<Key background and assumptions>

## Details
<The core content: steps, diagrams-in-text, examples, decisions>

## Related
- <Links to related docs/files/issues>
```

### ADR template (for `docs/decisions/`)

Use a numbered or dated naming scheme, one decision per file:

- `0001-use-terraform-for-org-management.md`
- `2026-01-29-adopt-centralized-docs-directory.md`

Template:

```markdown
# ADR: <Decision title>

## Status
Proposed | Accepted | Deprecated

## Context
<What prompted the decision>

## Decision
<What we chose>

## Consequences
<Trade-offs and follow-up work>
```

## Workflow: adding docs during a change

1. Identify what is durable knowledge vs implementation detail.
2. Put durable knowledge in `docs/` (not in code comments).
3. Choose the correct category folder.
4. Write one concept per file; split and link when needed.
5. Update `docs/README.md` if the new doc is a primary entry point.
