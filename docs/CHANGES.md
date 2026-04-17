# Version 1.3.1
- Added a movable minimap icon for BLU Classic that opens the options panel, supports drag repositioning, and can be hidden or restored with slash commands.
- Added `/blu` as a BLU Classic slash-command alias while keeping saved variables isolated in `BLUClassicDB` with Classic-specific minimap keys.
- Refined the Blizzard options-category title styling by aligning the icon more cleanly, restoring the `Level-Up` hyphen, and matching the `!` color to the BLU logo letters.
- Upgraded BLU Classic nested sound dropdowns to more closely match BLU with better menu sizing, cleaner submenu labels, truncation tooltips, and variant counts.

# Version 1.3.0
- Added nested dropdown sound selection menus organized by game franchise, with variant submenus for games that have multiple sound options.
- Removed Retail WoW support entirely — BLU Classic is now Classic-only (Classic Era, BCC, Wrath, Cata, Mists). Use [BLU](https://github.com/donniedice/BLU) for Retail.
- Removed Delve Companion, Honor Ranks, Renown, and Trading Post event types and their associated code, defaults, and option groups.
- Deleted the Retail TOC file (`BLU_Classic.toc`) and removed Retail interface version detection from core.
- Ensured default WoW sounds are always restored on logout, reload, or addon disable via a standalone `PLAYER_LOGOUT` handler registered at file-load time.
