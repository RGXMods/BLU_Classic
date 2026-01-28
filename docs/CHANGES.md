## v1.2.6
- Fix: Resolved SavedVariables conflict between BLU and BLU_Classic addons (BCC, Wrath, Cata TOCs were using `BLUDB` instead of `BLUClassicDB`)
- Fix: Corrected Lua syntax error in battlepets.lua (`}` instead of `end`) causing errors on MoP Classic
- Fix: Version string in options panel no longer shows stale hardcoded "v1.2.2" fallback
- Fix: Removed hardcoded version suffix from TOC title strings (now displayed dynamically)
- Fix: Removed branch triggers from CI/CD workflow to prevent duplicate Discord notifications
- Update: Main TOC interface version updated to 120000 (Midnight pre-patch)

## v1.2.5
- Fix: Registered /blu slash command to open options panel
- Chore: Updated TOC interface versions for all Classic clients
