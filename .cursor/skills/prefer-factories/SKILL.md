---
name: prefer-factories
description: Prefer factory functions/modules over ad-hoc or “loose” classes by centralizing construction, wiring, defaults, and dependency injection. Use when adding new services/clients/managers, refactoring class-heavy code, or when the user mentions factories, instantiation, dependency injection, or widespread `new` usage.
---

# Prefer Factories

## Goal

Favor **factory functions (or factory modules)** that build and return a well-defined interface over scattered construction logic and ad-hoc classes.

## Use this skill when

- You are introducing a new “service/client/manager/handler” object
- You see repeated `new X(...)` patterns or duplicated wiring/defaults
- You need environment-specific variants (prod/test) behind a stable interface
- Dependencies/configuration are spreading across call sites

## Default approach (factory-first)

1. Search the repo for existing factory patterns and reuse/extend them before creating anything new.
2. Define the **public interface/shape** first (methods + returned type), then implement behind it.
3. Create a single `createX(...)` factory that owns:
   - defaults
   - validation
   - dependency wiring (dependency injection)
   - lifecycle setup/teardown hooks (if needed)
4. Keep the “product” implementation simple:
   - avoid side effects at import/module-load time
   - avoid hidden globals; pass dependencies explicitly
5. If existing code is close but not reusable as-is, **refactor/generalize** it so it supports both current and new use cases instead of duplicating it.

## Decision guide: factory + object vs class

- Prefer **factory returning an object** (closures/private state) when:
  - you don’t need inheritance
  - you want a small surface area and easy testing via injected deps
- Keep a **class behind a factory** when:
  - you benefit from clear instance lifecycle/state encapsulation
  - you need a stable type with well-understood identity/behavior

Even when a class is used, construction should flow through the factory (not direct `new` from many call sites).

## Refactor workflow: “loose class” → factory-owned construction

- Identify call sites doing `new X(...)`.
- Extract constructor inputs into explicit `deps` (services) and `opts` (configuration).
- Add `createX(deps, opts)` that:
  - applies defaults
  - validates inputs
  - constructs the class (or object) and returns the public interface
- Update call sites to use the factory.
- If multiple variants exist, keep variant selection inside the factory (or a thin wrapper), not spread across call sites.

## Quick examples (language-agnostic)

- `createGitHubClient({ token, baseUrl, logger }) -> GitHubClient`
- `createRepoManager({ githubClient, config, logger }) -> RepoManager`
- `createRenderer({ fs, templatesDir }) -> Renderer`

## Acceptance checklist

- [ ] A factory exists for any new “service/client/manager/handler”
- [ ] Construction/wiring/defaults are centralized in one place
- [ ] Call sites do not duplicate `new`-style wiring logic
- [ ] Dependencies are injected explicitly (easy to swap for tests)
