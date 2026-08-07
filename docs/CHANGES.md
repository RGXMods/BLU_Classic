## v1.3.2 - 2026-08-07
- Created main `BLU_Classic.toc` with unified interface versions: 11509 (Classic Era), 20506 (TBC Anniversary), 50504 (MoP Classic).
- Updated variant TOCs to current active versions.
- Added `data\battlepets.lua` to main TOC load order.

## v1.3.1
- Added a movable minimap icon for BLU Classic that opens the options panel, supports drag repositioning, and can be hidden or restored with slash commands.
- Added `/blu` as a BLU Classic slash-command alias while keeping saved variables isolated in `BLUClassicDB` with Classic-specific minimap keys.
- Refined the Blizzard options-category title styling by aligning the icon more cleanly, restoring the `Level-Up` hyphen, and matching the `!` color to the BLU logo letters.
- Upgraded BLU Classic nested sound dropdowns to more closely match BLU with better menu sizing, cleaner submenu labels, truncation tooltips, and variant counts.