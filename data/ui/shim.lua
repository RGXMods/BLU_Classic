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

-- Debug scopes (same set and matching rules as BLU Forever, limited to what
-- BLU Classic emits). Scope filtering applies only while debug mode is on.
function BLU:NormalizeDebugScope(scope)
    if type(scope) ~= "string" or scope == "" then
        return "core"
    end
    local normalized = scope:lower():gsub("^%s+", ""):gsub("%s+$", "")

    if normalized:find("^tabs") then return "tabs" end
    if normalized:find("^options") then return "options" end
    if normalized:find("^registry") then return "registry" end
    if normalized:find("^sounds") or normalized:find("^usersounds") then return "sounds" end
    if normalized:find("^loader") or normalized:find("^init") then return "loader" end
    if normalized:find("^database") or normalized:find("^config") then return "database" end
    if normalized:find("^profiles") then return "profiles" end
    if normalized:find("^events") or normalized:find("^timer") or normalized:find("^slash")
        or normalized:find("^welcome") or normalized:find("^state") then return "events" end
    if normalized:find("^levelup") or normalized:find("^quest") or normalized:find("^reputation")
        or normalized:find("^achievement") or normalized:find("^battlepet") then return "features" end
    return normalized == "core" and "core" or normalized
end

function BLU:IsDebugScopeEnabled(scope)
    local profile = self.db
    local scopes = profile and profile.debugScopes
    if type(scopes) ~= "table" then
        return true
    end
    local normalized = self:NormalizeDebugScope(scope)
    if scopes[normalized] == nil then
        return true
    end
    return scopes[normalized] ~= false
end

function BLU:PrintDebug(message)
    if not self.debugMode then
        return
    end
    message = tostring(message)
    local rawScope = message:match("^%[([^%]]+)%]")
    if not self:IsDebugScopeEnabled(rawScope or "core") then
        return
    end
    print(PREFIX .. "|cff888888[debug]|r " .. message)
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
