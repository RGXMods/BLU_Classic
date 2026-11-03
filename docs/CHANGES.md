## v1.4.0-beta.12 - 2026-11-03
- The four settings tabs (General, Profiles, Debug, Sounds) sit in a bordered box that lines up with the tab buttons, with an even margin around them.
- Highlights (the active tab, a switch that is on, and the current sound name) use BLU's brand cyan instead of the RGX-Framework theme colour. Surfaces, borders, and text still follow the framework.
- Each event page (Level Up, Quest, Reputation, Combat, Loot, Hardcore, Honor, Collectibles) has an ON/OFF switch in its header. Turning a page off stops BLU from playing its sounds and keeps your sound choices. Level Up, Quest, and Reputation then fall back to the game's own sounds.
- The Level Up and Collectibles tabs use icons that Classic's own UI loads: XP for Level Up and a mount for Collectibles. The old icons did not show in game.
- Requires RGX-Framework 2.11.0 or newer.
- Known gap: these events are not yet confirmed to fire on every Classic client.
- Known gap: the Loot tab icon is still being investigated.
- Known gap: new options labels, including the ON and OFF switch text, are English only until the locale files are updated.

## v1.4.0-beta.11 - 2026-11-03
- Mists of Pandaria Classic is no longer supported. BLU Classic targets Classic Era (11509) and Burning Crusade Classic (20506).
- The Achievement and Battle Pet tabs were Mists-only, so they are gone. The Pet Collected battle-pet trigger goes with them.
- Honor and Collectibles fill column 6 on both supported clients. The strip stays two rows, with 12 tabs.
- The CurseForge and README descriptions name only the supported clients.
- Requires RGX-Framework 2.11.0 or newer.
- Known gap: these events are not yet confirmed to fire on every Classic client.
- Known gap: the Loot tab icon is still being investigated.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.10 - 2026-11-03
- Chat messages now say BLU instead of BLU_Classic. The internal BLU_Classic names are unchanged.
- The Honor and Collectibles tabs moved from a third row to column 6, one in each of the two rows. Era and TBC Anniversary now show 12 tabs in the two-row strip.
- On Mists of Pandaria Classic, Achievement and Battle Pet already use column 6, so Honor and Collectibles are not shown there in this build. A layout decision is pending.
- Known gap: these events are not yet confirmed to fire on every Classic client.
- Known gap: the Loot tab icon is still being investigated.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.9 - 2026-11-03
- New Honor tab with PvP Rank Up. This is Classic's counterpart to Retail's honor-level trigger. It fires only for your own rank going up, not for other units or rank drops, when the client reports your rank.
- New Collectibles tab with Mount Learned, Pet Collected (Mists of Pandaria Classic only, because it is a battle-pet event), and Toy Learned. Each trigger appears only if your game client knows its event.
- Tabs and rows are hidden when the client does not know their events. A page with nothing usable says so.
- Honor and Collectibles use icons that Classic Era's own UI files reference.
- The tab strip has a third row for Honor and Collectibles. The settings box stays around the four settings tabs.
- Requires RGX-Framework 2.11.0 or newer.
- Known gap: these events are not yet confirmed to fire on every Classic client. Please report which ones play.
- Known gap: the Loot tab icon is still being investigated.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.8 - 2026-11-03
- Profiles page now uses RGX-Framework's shared profile editor: the framework header, active-profile box, profile dropdown, and Create / Rename / Copy / Delete dialogs are themed by the framework.
- Presets are on that page again, as a framework Presets card with donniedice's Preset and five reserved slots.
- Reset asks for confirmation first, and applying a preset asks for confirmation first. Both explain what they change.
- Add Custom Sound is a framework-styled dialog instead of a Blizzard popup. Enter adds the sound and Escape closes it.
- Options colours now come from the RGX-Framework theme. BLU's own palette is used only when the framework is not loaded.
- The four settings tabs (General, Profiles, Debug, Sounds) sit inside a bordered settings box, as on BLU Retail.
- The slash command is /blu only. /bluc is no longer registered; the internal BLUClassic names are unchanged.
- README and CurseForge description: BLU Classic requires RGX-Framework 2.11.0 or newer, and the command list uses /blu.
- Requires RGX-Framework 2.11.0 or newer.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.7 - 2026-11-03
- Combat tab is now a paged, two-column page using the RGX-Framework pager: all 11 triggers are kept, 6 per page, with Prev and Next buttons at the top right. Each trigger is a compact card with the sound dropdown, Test button, and a volume track.
- The Loot tab uses the same two-column layout.
- Requires RGX-Framework 2.11.0 or newer (the pager and column helpers).
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.6 - 2026-11-03
- Fixed the volume track not showing the saved level: it is now redrawn from the saved value whenever a page is shown or resized, so Off, Low, Medium, and High stay where you set them after switching tabs or reloading.
- Fixed the BLU icon in the AddOns options list sitting above the title text. The icon now scales to the list font.
- The Presets card on the Profiles tab now keeps its own height, so it can no longer collapse when the options window is short.
- Check the version number in the options window header (top right) to confirm you are on this build.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.5 - 2026-11-02
- New Combat tab with 11 triggers: Combat Start, Combat End, Low Health, Execute Window, Critical Hit, Critical Heal, Resource Capped, Resource Low, Target Lost, Encounter End, and Encounter Victory. Encounter triggers fire only on clients that report boss encounters.
- New Loot tab with 5 triggers: Uncommon, Rare, Epic, and Legendary item looted, and Coin looted. Item quality is read from the item link color, so it works in every language.
- New Hardcore tab with 4 death triggers: your death, party member death, raid member death, and other player death.
- Every new trigger starts set to [None], so nothing changes until you pick a sound. Triggers use your own sounds too, including User Custom Sounds. Hover a row for what fires it. Long trigger pages scroll with the mouse wheel.
- Profiles tab now has the Presets section from BLU Forever with donniedice's Preset and five reserved slots. Applying a preset resets the active profile to defaults and then sets the preset sounds; your custom sounds and minimap position are kept.
- Honor and Collectibles are not included: both depend on Retail-only game systems.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.3 - 2026-11-02
- Debug tab rebuilt to match BLU Forever: Debug Mode switch in the title bar and a Debug Scopes card with a checkbox per scope (Core, Options, Tabs, Registry, Loader / Init, Database / Config, Profiles, Events / Combat, Sounds / Media, Feature Modules). Scopes now filter which debug messages print.
- Sounds tab rebuilt to match BLU Forever: Installed Sound Packs list on the left and a User Custom Sounds manager on the right.
- New user custom sounds (issue #12): Add Custom Sound takes a file name like myfile or myfile.ogg, or a full Interface/AddOns path, and searches common AddOns sound folders. Custom sounds are stored per profile, appear under User Custom Sounds in every event dropdown, and can be removed from the Sounds tab. Existing saved sounds are unchanged.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.2 - 2026-11-02
- Beta: options tabs now match BLU Forever's layout: General and Profiles on row 1, Debug and Sounds on row 2, then the divider and the event tabs.
- New Debug tab with the debug switch and client details (addon, client, RGX-Framework, profile, and options page errors). The debug option moved here from General.
- New Sounds tab: scrolling list of the bundled sounds with a Play button for each.
- The number of tabs now follows the client: Achievement appears only where the client has achievements and Battle Pet only on Mists of Pandaria Classic, instead of showing greyed-out tabs.
- Known gap: new options labels are English only until the locale files are updated.

## v1.4.0-beta.1 - 2026-11-02
- Beta: new options panel that matches BLU and BLU Forever (header, tab strip, General, Profiles, Level Up, Quest, Reputation, Achievement, and Battle Pet pages). Achievement and Battle Pet tabs show greyed out on clients that lack them.
- Sound rows now use the BLU layout: sound dropdown with grouped variants, a four-step volume track (Off, Low, Medium, High), and a Test button. Saved sounds and volumes carry over unchanged.
- Profiles tab: create, rename, reset, copy, switch, and delete profiles, backed by the RGX-Framework database.
- Removed the AceConfig, AceConfigDialog, AceGUI, and AceDBOptions libraries from the TOC load order and deleted the AceGUI sound-select widget (issue #7, part of the Ace3 removal in #1). Other Ace libraries still load until #9.
- Known gap: new options labels are English only until the locale files are updated.
- Testing build: please report any panel layout problems, missing tabs, or Lua errors on Classic Era, TBC Anniversary, and Mists of Pandaria Classic.

## v1.3.8 - 2026-10-23
- Fixed CurseForge and Wago publishing: the release publisher now sends the upload `metadata` as a plain form value instead of a Blob file part, which CurseForge rejected with `1001 Missing field 'metadata'` and Wago with `422 The metadata must be a string`. Synced the publisher with the framework's corrected release tooling.

## v1.3.6 - 2026-10-16
- Added `docs/AGENT-DIRECTIVES.md`: framework-first addon development and TOC version policy documentation (issue #4).

## v1.3.5 - 2026-09-29
- Added the `AGENTS.md` framework-build and interface-versioning directives; TOC metadata cleaned to the sanctioned author field.

## v1.3.4 - 2026-08-22
- Fixed Classic Era `/blu` options failing to open: Settings clients (incl. Era 1.15.x) require a numeric category ID, but the vendored AceConfigDialog returned the category name string. Updated AceConfigDialog-3.0 to upstream minor 92 (Ace3 issue #694 fix: name->ID override only applies on pre-Settings clients) and now capture the returned category IDs for the main and Profiles registrations.

## v1.3.3 - 2026-08-07
- Add Category/Group RGX for addon menu section.

## v1.3.2 - 2026-08-07
- Created main `BLU_Classic.toc` with unified interface versions: 11509 (Classic Era), 20506 (TBC Anniversary), 50504 (MoP Classic).
- Updated variant TOCs to current active versions.
- Added `data\battlepets.lua` to main TOC load order.

## v1.3.1
- Added a movable minimap icon for BLU Classic that opens the options panel, supports drag repositioning, and can be hidden or restored with slash commands.
- Added `/blu` as a BLU Classic slash-command alias while keeping saved variables isolated in `BLUClassicDB` with Classic-specific minimap keys.
- Refined the Blizzard options-category title styling by aligning the icon more cleanly, restoring the `Level-Up` hyphen, and matching the `!` color to the BLU logo letters.
- Upgraded BLU Classic nested sound dropdowns to more closely match BLU with better menu sizing, cleaner submenu labels, truncation tooltips, and variant counts.