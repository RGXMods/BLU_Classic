# Version 1.3.0
- Added nested dropdown sound selection menus organized by game franchise, with variant submenus for games that have multiple sound options.
- Removed Retail WoW support entirely — BLU Classic is now Classic-only (Classic Era, BCC, Wrath, Cata, Mists). Use [BLU](https://github.com/donniedice/BLU) for Retail.
- Removed Delve Companion, Honor Ranks, Renown, and Trading Post event types and their associated code, defaults, and option groups.
- Deleted the Retail TOC file (`BLU_Classic.toc`) and removed Retail interface version detection from core.
- Ensured default WoW sounds are always restored on logout, reload, or addon disable via a standalone `PLAYER_LOGOUT` handler registered at file-load time.
