## v1.2.3
- Resolved merge conflicts in data/core.lua and docs/CHANGES.md.
- Reviewed and confirmed "unmute on unload" functionality.

## v1.2.2
- Updated workflow release.yml file
- Fix release.yml was missing "(Classic)" from Discord message title 

## fix: resolve critical addon errors and add missing functions
- Add PrintDebugMessage() function for safe debug logging
- Add GetGameVersion() to detect game version (retail/classic)
- Add HaltOperations() and ResumeOperations() for sound spam prevention
- Fix PET_BATTLE_LEVEL_CHANGED handler - properly retrieve speciesID
- Fix inconsistent pet tracking - use speciesID for previousPetLevels
- Add nil checks for optional HandleEvent and defaultSounds functions
- Add UNIT_SPELLCAST_SUCCEEDED event for pet training item detection
- Consolidate initialization and improve code organization
- Add comprehensive comments and improve error handling

Fixes all errors from debug output and improves overall stability.
