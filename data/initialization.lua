
BLU_L = BLU_L or {}
--=====================================================================================
-- BLU | Better Level-Up! - initialization.lua
--=====================================================================================

--=====================================================================================
-- Version Number
--=====================================================================================
if C_AddOns and C_AddOns.GetAddOnMetadata then
    BLU.VersionNumber = C_AddOns.GetAddOnMetadata("BLU_Classic", "Version")
else
    BLU.VersionNumber = GetAddOnMetadata("BLU_Classic", "Version")
end

--=====================================================================================
-- Variables
--=====================================================================================
BLU.functionsHalted = false
BLU.debugMode = false
BLU.showWelcomeMessage = true
BLU.sortedOptions = {}
BLU.optionsRegistered = false