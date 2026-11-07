-- BLU_Classic resolves a bare name only in its documented folders, never in other addons.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local files, probes = {}, 0
local addons = { "Blizzard_Foo", "BLU_Classic", "WeakAuras", "MyVoicePack", "SoundsOfWar", "Details" }
_G.PlaySoundFile = function(path) probes = probes + 1; if files[path:lower()] then return true, 1 end return false end
_G.StopSound = function() end
_G.C_AddOns = { GetNumAddOns = function() return #addons end, GetAddOnInfo = function(i) return addons[i] end }
_G.BLU_Classic = { Modules = {}, db = {} }
assert(loadfile("data/usersounds.lua"))()
local US = BLU_Classic.UserSounds
local function has(p) files[p:lower()] = true end

has("Interface\\AddOns\\MyVoicePack\\media\\sounds\\roar.ogg")
check(US:Resolve("roar") == nil, "a bare name is not guessed from another addon's folder")

has("Interface\\AddOns\\BLU_Classic\\user\\sounds\\boom.ogg")
check(US:Resolve("boom") == "Interface\\AddOns\\BLU_Classic\\user\\sounds\\boom.ogg", "BLU's own folders resolve a bare name")

probes = 0
local miss, err = US:Resolve("definitely-not-there")
check(miss == nil and probes > 0 and probes <= 60, "a miss only probes BLU's folders (" .. probes .. " probes)")
check(err:find("user\\sounds", 1, true) and err:lower():find("restart", 1, true), "failure explains the folder and the restart")

probes = 0
check(US:Resolve("Interface\\AddOns\\Elsewhere\\x.ogg") == "Interface\\AddOns\\Elsewhere\\x.ogg", "explicit path kept")
check(probes == 0, "no search for an explicit path")
print("user-sounds-search-test OK")
