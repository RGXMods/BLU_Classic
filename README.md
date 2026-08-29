<div align="center">

<img src="media/BLU_Logo.png" alt="BLU Classic logo" width="144">

# <span style="color:#05dffa">B</span>etter <span style="color:#05dffa">L</span>evel-<span style="color:#05dffa">U</span>p<span style="color:#05dffa">!</span> <span style="color:#FFD700">Classic</span>

### <span style="color:#e67e23">Iconic game sounds across the Classic World of Warcraft family</span>

[![Release](https://img.shields.io/github/v/release/RGXMods/BLU_Classic?style=for-the-badge&logo=github&color=FFD700)](https://github.com/RGXMods/BLU_Classic/releases)
[![WoW Classic](https://img.shields.io/badge/WoW-Classic-05dffa?style=for-the-badge&logo=worldofwarcraft&logoColor=white)](https://worldofwarcraft.blizzard.com/)
[![License](https://img.shields.io/github/license/RGXMods/BLU_Classic?style=for-the-badge&color=2dc26b)](LICENSE)

[![CurseForge](https://img.shields.io/badge/CurseForge-Download-f16436?style=flat-square&logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/blu-classic)
[![Wago](https://img.shields.io/badge/Wago-Download-b96ad9?style=flat-square)](https://addons.wago.io/addons/blu-classic)
[![Discord](https://img.shields.io/badge/Discord-RealmGX-5865f2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/N7kdKAHVVF)

**[Features](#features) | [Installation](#installation) | [Commands](#commands) | [Compatibility](#compatibility) | [Support](#support)**

</div>

---

## <span style="color:#FFD700">What Is BLU Classic?</span>

**BLU Classic** brings memorable sounds from more than 50 games to Classic World of Warcraft. Replace repetitive cues for level-ups, quests, reputation, achievements, and battle pets while keeping each client flavor's capabilities in mind.

BLU Classic is the **Classic** edition. Retail players should install [<span style="color:#05dffa">BLU</span>](https://github.com/RGXMods/BLU).

## <span style="color:#FFD700">Features</span>

| | Feature | What it provides |
|---|---|---|
| 🎵 | **50+ game sound libraries** | Favorites from Final Fantasy, Zelda, Mario, Skyrim, Pokemon, Warcraft, and many more |
| ⭐ | **Classic event coverage** | Level-up, quest, reputation, achievement, and supported battle-pet cues |
| 🔊 | **Volume variants** | Low, Medium, and High choices for bundled sounds |
| 🔇 | **Smart sound handling** | Replaces matching WoW cues without leaving default sounds muted after shutdown |
| 🎨 | **Organized options** | Nested game menus, previews, persistent profiles, and a movable minimap button |
| 🧭 | **Multi-client package** | One unified TOC with guarded behavior for each supported client family |

## <span style="color:#FFD700">Event Coverage</span>

BLU Classic keeps its event set focused on features available across the
supported Classic family.

| Event | Availability |
|---|---|
| **Character level-up** | All supported clients |
| **Quest accepted and turned in** | All supported clients |
| **Reputation rank increase** | All supported clients |
| **Achievement earned** | Clients with the achievement system |
| **Battle-pet level-up** | Mists of Pandaria Classic |

Retail-only systems such as Delves, Honor Ranks, Renown, Housing, and the
Trading Post are intentionally not included. Install
[BLU](https://github.com/RGXMods/BLU) for Retail event coverage.

## <span style="color:#FFD700">Sound Library</span>

The bundled library contains memorable cues from more than 50 games, including
Final Fantasy, Zelda, Mario, Pokemon, Skyrim, Warcraft III, Minecraft,
Morrowind, Path of Exile, RuneScape, Sonic the Hedgehog, and The Witcher 3.
Selections are organized into nested game menus.

Bundled sounds provide Low, Medium, and High variants. Each event can be
configured independently and previewed from the options panel.

## <span style="color:#FFD700">Installation</span>

1. Install BLU Classic from [CurseForge](https://www.curseforge.com/wow/addons/blu-classic), [Wago](https://addons.wago.io/addons/blu-classic), or [GitHub Releases](https://github.com/RGXMods/BLU_Classic/releases).
2. Launch your supported Classic client.
3. Type `/blu` or `/bluc` to open options.
4. Choose and preview a sound for each available event.

Manual installs belong in the matching client folder, such as:

```text
World of Warcraft/_classic_/Interface/AddOns/BLU_Classic
World of Warcraft/_classic_era_/Interface/AddOns/BLU_Classic
World of Warcraft/_anniversary_/Interface/AddOns/BLU_Classic
```

For manual installation, extract a single folder named `BLU_Classic` into the
AddOns directory used by the client you launch. Restart WoW or run `/reload`,
then enable the addon at character select.

### Requirements

BLU Classic packages its required Ace3 components in `Libs/`; no separate
framework download is required. The TOC lists Ace3 as an optional dependency
for installations that already provide it.

## <span style="color:#FFD700">Configuration</span>

1. Open the options panel with `/blu` or `/bluc`.
2. Enable the event types you want to replace.
3. Choose a game sound and volume variant for each event.
4. Preview selections before closing the panel.
5. Use profiles when you need different settings for different characters or
   play styles.

The movable minimap button also opens options. Its position and visibility are
saved in the Classic-specific `BLUClassicDB`, separate from Retail BLU.

## <span style="color:#FFD700">Commands</span>

| Command | Description |
|---|---|
| `/blu` or `/bluc` | Open options |
| `/bluc help` | Show command help |
| `/bluc debug` | Toggle diagnostics |
| `/bluc welcome` | Toggle the welcome message |
| `/bluc icon on` | Show the minimap button |
| `/bluc icon off` | Hide the minimap button |

## <span style="color:#FFD700">Compatibility</span>

The current unified `BLU_Classic.toc` supports Classic Era, Burning Crusade
Anniversary, and Mists of Pandaria Classic. Interface values are maintained in
the TOC rather than duplicated here, keeping this page accurate as clients
update.

Hardcore and Season of Discovery use the Classic Era client family. Retail is
not supported by BLU Classic.

## <span style="color:#FFD700">Troubleshooting</span>

- Open `/bluc` and verify the event is enabled with a sound selected.
- Confirm WoW's Master volume is enabled.
- Install the addon in the folder for the client you are actually launching.
- Some audio may pause briefly the first time WoW caches it.
- If options do not open, confirm the current release is installed and run
  `/reload` before trying `/blu` again.
- Use `/bluc debug` when collecting details for a reproducible report.

## <span style="color:#FFD700">Support</span>

- [GitHub Issues](https://github.com/RGXMods/BLU_Classic/issues) for reproducible bugs
- [RealmGX Discord](https://discord.gg/N7kdKAHVVF) for help, feedback, and sound suggestions
- [Release history](docs/CHANGES.md) for detailed changes
- [GitHub Sponsors](https://github.com/sponsors/donniedice) or [Buy Me a Coffee](https://buymeacoffee.com/donniedice) to support development

## <span style="color:#FFD700">Contributing</span>

Bug reports, translations, feature ideas, and sound suggestions are welcome. Include the client flavor and reproduction steps with bug reports.

Development is maintained in the
[RGXMods GitLab repository](https://gitlab.dicematrix.cloud/rgxmods/warcraft/BLU_Classic),
the source of truth for code and CI/CD. Public packages and release notes are
published through [RGXMods GitHub Releases](https://github.com/RGXMods/BLU_Classic/releases).

The project uses one unified TOC for the active Classic families, with guarded
runtime behavior for client-specific APIs. See [release history](docs/CHANGES.md)
for compatibility and packaging changes.

## <span style="color:#FFD700">License</span>

BLU Classic is available under the [MIT License](LICENSE).

---

<div align="center">

### <span style="color:#8B1538">R</span><span style="color:#7598b6">ealm</span><span style="color:#8B1538">G</span><span style="color:#8B1538">X</span> <span style="color:#4ecdc4">Mods</span>

**Made by [DonnieDice](https://github.com/donniedice) for the [RealmGX](https://realmgx.com) community.**

[<span style="color:#05dffa">BLU Retail</span>](https://github.com/RGXMods/BLU) | [<span style="color:#58be81">Simple Quest Plates</span>](https://github.com/RGXMods/SimpleQuestPlates) | [<span style="color:#e74c3c">Remove Nameplate Debuffs</span>](https://github.com/RGXMods/RemoveNameplateDebuffs)

_<span style="color:#e67e23">Make every level count with sounds that matter.</span>_

</div>
