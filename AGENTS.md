# 🤖 AI Agent: Goose for BLU_Classic

## 🚀 Project: BLU_Classic | Better Level-Up! Classic (v1.2.4) 

This document is my internal configuration and knowledge base for the "BLU_Classic | Better Level-Up! Classic" project. It outlines my purpose, capabilities, and a verified map of the repository.

## 🎯 My Purpose

My primary goal is to assist with the development and maintenance of the BLU_Classic addon by analyzing code, managing files, and executing tasks according to established repository standards.

## 🛠️ My Capabilities

*   **Code Analysis:** I can analyze the codebase to understand file structure and symbol relationships.
*   **File Operations:** I can read, write, and modify files within the project.
*   **Shell Commands:** I can execute shell commands for tasks like searching, listing files, and running scripts.
*   **Project Information:** I can provide information about the project based on its files.

## 📂 Repository Structure

*   **`.github/workflows/`**: Contains GitHub Actions for automation.
    *   `release.yml`: Automates the packaging and release process when a new version tag is pushed.
    *   `copy-secrets.yml`: A manual workflow to sync secrets to the BLU_Classic repository.
*   **`data/`**: The core logic of the addon.
    *   `core.lua`: Handles the addon's main event logic.
    *   `initialization.lua`: Manages addon startup, version detection, and event registration.
    *   `localization.lua`: Contains all user-facing text and translations.
    *   `options.lua`: Defines the in-game configuration panel and its options.
    *   `sounds.lua`: Maps all sound files, including custom and default sounds.
    *   `utils.lua`: Provides helper functions for event queuing, sound playback, and slash commands.
    *   `battlepets.lua`: Contained logic for battle pet level-up sounds.
*   **`docs/`**: Project documentation.
    *   `guidelines_changelog.md`: Defines the format for changelogs.
    *   `changelog.txt`: The complete history of changes.
    *   `CHANGES.md`: A list of changes for the next upcoming release.
*   **`images/`**: Contains addon assets like icons.
*   **`Libs/`**: Contains third-party libraries, primarily the Ace3 framework.
*   **`sounds/`**: Contains all `.ogg` sound files.
*   **`.toc` Files**: (`BLU_Classic.toc`, `BLU_Classic_Vanilla.toc`, `BLU_Classic_Mists.toc`) Table of Contents files that tell WoW how to load the addon for different game versions.
*   **`README.md`**: The main project overview.

## 📝 Repository Standards

I am aware of and will adhere to the following standards:

*   **`.toc` File Path Separators:** I will use the correct path separator style for each `.toc` file (`/` for Retail/Cata, `\` for Mists, `\` for Vanilla).
*   **Changelog:** I will follow the strict format outlined in `docs/guidelines_changelog.md` when updating `CHANGES.md` and `changelog.txt`.

## 🤝 How to Interact With Me

You can direct me with natural language commands to perform the tasks outlined above.

## Repository Workflow

- The GitLab project under `rgxmods/warcraft` is authoritative. Normal work belongs on task branches and must merge through GitLab merge requests, never directly to the default branch.
- Shared CI is included from `rgxmods/warcraft/RGX-Framework` at `/.gitlab/ci/addon.yml`; validation must pass before publishing to the GitHub mirror.
- The GitHub `RGXMods` repository is downstream distribution, not development authority.
- Keep GitLab and GitHub release tags identical, and use protected GitLab release tags.
- Preserve any existing working Wago connection and ID exactly. Never create a new Wago connection without explicit user direction.
- Publishing integrations prohibited by the shared validation policy are retired and must not be restored.
- The root `README.md` must remain detailed and project-specific. Narrow distribution edits must not replace or truncate installation, features, compatibility, usage, media, or support content.
- Verify relative README assets. Do not overwrite newer compatibility facts with stale monorepo or history text.

## Building With RGX-Framework

- Contract first: build addon behavior from the declarative `RGXAddon(name, opts)` table using only keys the framework ships today. Read `docs/DECLARATIVE-API.md` in `rgxmods/warcraft/RGX-Framework` before writing code; tier 4 keys are future targets, not runtime features. Use `onInit` and addon-scoped methods only where the shipped declarative surface genuinely cannot express the behavior.
- MCP tool loop: before writing UI, timer, event, aura, or slash code, run the rgx-framework MCP tools in order: `rgx_get_contract` -> `rgx_generate_addon` -> `rgx_validate_addon` -> `rgx_audit_lua`. Compare generated Lua with existing integration, validate the actual opts table, and audit every changed Lua file. Never hand-roll what the framework ships.
- Prefer framework subsystems over raw WoW API: timers and repeating schedules, event registration, slash commands, minimap button, saved-settings database, aura watching, UI controls and dropdowns, colors, fonts, theming, tooltips, and sound. This fork predates framework integration in its current runtime; adopt framework subsystems deliberately instead of duplicating what the embedded Ace3 libraries already provide, and migrate existing compatibility paths deliberately instead of silently breaking them.
- Forbidden patterns that fail `rgx_audit_lua`: raw `C_Timer`, manual event frames, `SLASH_` globals, unguarded `SetAttribute`, raw aura plumbing, and raw hook reassignment. New code uses framework-managed equivalents.
- Validation: Lua 5.1 (`luac5.1 -p`) and XML (`xmllint`) must pass through the shared CI include before every MR, and the root README stays nonempty and substantive.
- Dependencies: keep `## RequiredDeps: RGX-Framework` and any `## X-RGX-Framework-MinVersion` accurate against the framework version line if the fork adopts the framework, and match the TOC SavedVariables name (`BLUClassicDB`) with the declarative `dbName` at that point.
- Repo facts: the current layout is a single `BLU_Classic.toc` serving Classic Era (`11509`), Burning Crusade Classic (`20506`), and Mists of Pandaria Classic (`50504`) as a comma-separated list; the multi-TOC and earlier-version references in the introduction above are historical. Commands are `/blu` or `/bluc` for options. The TOC owns the `vX.Y.Z` version and load order. Recheck facts in the TOC and README when they change.

## Keeping Interface Versions Current

- Ground truth is the game client's own `.build.info` in the WoW installation root: one pipe-delimited row per installed product; the Product column names the flavor and the Version column gives `major.minor.patch.build`. Read it immediately before changing a TOC or releasing.
- Derive `## Interface:` as `major * 10000 + minor * 100 + patch` (verified: `1.60.1` -> `16001`, `1.15.9` -> `11509`, `2.5.6` -> `20506`, `5.5.4` -> `50504`). This addon's TOC carries its three Classic flavors as a comma-separated list.
- Online cross-checks for builds not installed locally: the wago.tools build pages and versions.wowtools.io. Verify a feed is reachable at runtime before trusting it; if it is unreachable, the installed client's `.build.info` is authoritative and an uninstalled flavor's live version is never guessed.
- A stale `## Interface:` value is a bug: fix it in a task-branch MR with green shared validation before any release.
- Release through GitLab MR and green shared validation, then patch-bump through the same discipline and create a protected GitLab release tag matching the TOC version. Verify the identical tag on the downstream `RGXMods/BLU_Classic` mirror before reporting distribution pickup.
