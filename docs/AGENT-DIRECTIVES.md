# BLU Classic Agent Directives

This document records the framework-first build discipline enforced by
`AGENTS.md` and the shared RGX-Framework CI include
(`/.gitlab/ci/addon.yml`, included from `rgxmods/warcraft/RGX-Framework`).
Follow it before writing or changing any code, UI, timer, event, aura, or
slash-command surface.

## The MCP tool loop

Before writing addon code, run the RGX-Framework MCP tools in order. Each
step has a single, ordered purpose; do not reorder or skip:

1. `rgx_get_contract` — read the current declarative contract surface
   (the live `RGXAddon(name, opts)` keys the framework ships today).
2. `rgx_generate_addon` — scaffold the addon file from the contract so
   the generated Lua matches what the framework would produce for these
   opts.
3. `rgx_validate_addon` — validate the actual opts table against the
   contract; fail on unknown, removed, or tier-4 keys.
4. `rgx_audit_lua` — audit every changed Lua file for forbidden raw-WoW
   patterns (see below) and confirm generated Lua matches integration.

Compare the generated Lua with the existing integration, then validate the
actual opts table and audit every changed Lua file. Never hand-roll what
the framework ships.

## The declarative contract

Build addon behavior from the declarative `RGXAddon(name, opts)` table
using **only** keys the framework ships today. Read
`docs/DECLARATIVE-API.md` in `rgxmods/warcraft/RGX-Framework` before
writing code.

- `name` — the addon name (matches the `## Title` TOC field).
- `opts` — the declarative options table. Only shipped keys are valid;
  tier 4 keys are future targets, not runtime features.

Use `onInit` and addon-scoped methods only where the shipped declarative
surface genuinely cannot express the behavior.

## Forbidden raw-WoW patterns

The following patterns fail `rgx_audit_lua` and must not appear in new
shipped Lua. Replace them with their framework-managed equivalents;
migrate existing compatibility paths deliberately instead of silently
breaking them.

| Forbidden pattern | Framework equivalent |
|---|---|
| raw `C_Timer` (e.g. `C_Timer.After`, `C_Timer.NewTicker`) | RGX timers / repeating schedules |
| manual event frames (`CreateFrame("Frame")`, manual `SetScript`) | `RGX:RegisterEvent` / `RGX:RegisterUnitEvent` |
| `SLASH_` globals | framework slash command registration |
| unguarded `SetAttribute` | framework UI controls / dropdowns |
| raw aura plumbing (`UnitAura`, custom aura watching) | `RGXAuras` module |
| raw hook reassignment (`hooksecurefunc`, `HookScript`) | framework lifecycle hooks |

## Dependency posture

This fork predates framework integration in its current runtime. Its
dependency posture is deliberate and must be stated accurately:

- **RGX-Framework is an optional dependency, not a hard requirement.**
  The TOC declares `## OptionalDeps: Ace3, RGX-Framework`, and all
  framework usage is guarded at runtime (`if RGX then` in
  `data/core.lua` and `data/initialization.lua`). The addon fully works
  without the framework installed; where the framework is present it
  takes over slash-command registration (`RGX:RegisterSlashCommand`).
- **Embedded Ace3 is the current runtime.** The addon packages its
  required Ace3 components in `Libs/` and builds on
  `LibStub("AceAddon-3.0")`. Ace3 stays until the Ace3-free migration
  lands elsewhere in the parent family (issues #1 and #9); adopt
  framework subsystems deliberately instead of duplicating what the
  embedded libraries already provide.
- **Saved variables are Classic-specific.** The TOC declares
  `## SavedVariables: BLUClassicDB`, separate from Retail BLU. Any
  future declarative adoption must match the declarative `dbName` to
  `BLUClassicDB` at that point.

## Supported Interface versions

One unified `BLU_Classic.toc` serves the active Classic families as a
comma-separated multi-value `## Interface:` line. Every supported value
was verified against the live wago.tools build feed on 2026-10-12
(`versions.wowtools.io` was unreachable that day, so the reachable feed
was used per the feed-reachability rule in `AGENTS.md`):

| Flavor | Client version | Derived `## Interface:` value | Live-feed source |
|---|---|---|---|
| Classic Era | 1.15.9 | `11509` | wago.tools build feed, product `wow_classic_era` (build 2026-09-29) |
| Burning Crusade Anniversary | 2.5.6 | `20506` | wago.tools build feed, product `wow_anniversary` (build 2026-09-12) |
| Mists of Pandaria Classic | 5.5.4 | `50504` | wago.tools build feed, product `wow_classic` (build 2026-10-09) |

Derive each value as `major * 10000 + minor * 100 + patch` — the formula
recorded in `AGENTS.md`. The shipped TOC line is:

```text
## Interface: 11509,20506,50504
```

Ground truth is always the game client's own `.build.info`; the live
feed is the cross-check for builds not installed locally, and a stale
`## Interface:` value is a bug: fix it in a task-branch MR with green
shared validation before any release.

## Release discipline

Release through the GitLab MR pipeline and green shared validation, then
patch-bump through the same discipline and create a protected GitLab
release tag matching the TOC version. The release flow enforced by the
shared `.gitlab/ci/addon.yml` include is:

1. Validate — `addon:validate` (README nonempty, TOC present, Lua 5.1
   `luac5.1 -p`, XML `xmllint --noout`, retired-token grep) must pass
   for every MR and default-branch diff.
2. Contract bundle — `contract:bundle` runs only where
   `tools/ci/package.json` exists; this repo has none, so the job never
   triggers here.
3. Mirror — `mirror:github` runs only on the default branch and `v*`
   tags; it publishes the identical protected GitLab tag to the
   downstream `RGXMods/BLU_Classic` GitHub mirror.

After merge to `main`, bump the patch version in `BLU_Classic.toc`
(`## Version:` line), create a protected GitLab release tag matching the
TOC version, and verify the identical tag on the `RGXMods/BLU_Classic`
mirror before reporting distribution pickup.

## Related references

- Framework canonical docs: `rgxmods/warcraft/RGX-Framework`
  `docs/DECLARATIVE-API.md` and `docs/RGX-MCP.md`
- This addon's contract surface and validation rules: `AGENTS.md`
- Release and CI configuration: `.gitlab-ci.yml`, which includes
  `rgxmods/warcraft/RGX-Framework` at `/.gitlab/ci/addon.yml`
