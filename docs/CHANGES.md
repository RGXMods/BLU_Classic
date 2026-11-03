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