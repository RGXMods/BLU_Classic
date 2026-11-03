--=====================================================================================
-- BLU_Classic - data/ui/shim.lua
-- Small namespace layer so the options UI (ported from BLU / BLU Forever) can use
-- the same BLU.Modules / BLU:Print* conventions on the BLU_Classic addon object.
--=====================================================================================

local BLU = _G.BLU_Classic
BLU.Modules = BLU.Modules or {}

local PREFIX = "|cff05dffaBLU_Classic:|r "

function BLU:Print(message)
    print(PREFIX .. tostring(message))
end

function BLU:PrintError(message)
    print(PREFIX .. "|cffff4444" .. tostring(message) .. "|r")
end

function BLU:PrintDebug(message)
    if self.debugMode then
        print(PREFIX .. "|cff888888[ui]|r " .. tostring(message))
    end
end

-- Localized text with an English fallback for strings that have no locale key yet.
function BLU:GetText(key, fallback)
    local L = _G.BLU_L
    local value = L and L[key]
    if type(value) == "string" and value ~= "" then
        return value
    end
    return fallback or key
end

-- Delay through the framework timer; never the raw C_Timer.
function BLU:UIAfter(seconds, callback)
    local RGX = _G.RGXFramework
    if RGX and RGX.After then
        return RGX:After(seconds, callback)
    end
    callback()
end
