--=====================================================================================
-- BLU_Classic | Better Level-Up! - initialization.lua
--=====================================================================================
BLU_Classic = LibStub("AceAddon-3.0"):NewAddon("BLU_Classic", "AceEvent-3.0")

--=====================================================================================
-- Version Number (API differs between Retail and Classic)
--=====================================================================================
if C_AddOns and C_AddOns.GetAddOnMetadata then
    -- Retail 10.0+ API
    BLU_Classic.VersionNumber = C_AddOns.GetAddOnMetadata("BLU_Classic", "Version")
else
    -- Classic Era / Classic / older API
    BLU_Classic.VersionNumber = GetAddOnMetadata("BLU_Classic", "Version")
end

--=====================================================================================
-- Libraries and Variables
--=====================================================================================
BLU_Classic.functionsHalted = false
BLU_Classic.debugMode = false
BLU_Classic.showWelcomeMessage = true
BLU_Classic.optionsRegistered = false

BLU_L = BLU_L or {}
