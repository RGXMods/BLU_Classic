-- BLU_Classic must find a named sound in other addons' sound folders, with BLU's own folders first.
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
check(US:Resolve("roar") == "Interface\\AddOns\\MyVoicePack\\media\\sounds\\roar.ogg", "finds a name inside another addon's media\\sounds")

has("Interface\\AddOns\\BLU_Classic\\user\\sounds\\boom.ogg")
has("Interface\\AddOns\\MyVoicePack\\sounds\\boom.ogg")
check(US:Resolve("boom") == "Interface\\AddOns\\BLU_Classic\\user\\sounds\\boom.ogg", "BLU's own folders win")

has("Interface\\AddOns\\Details\\media\\ding.ogg")
has("Interface\\AddOns\\SoundsOfWar\\media\\ding.ogg")
check(US:Resolve("ding"):find("SoundsOfWar", 1, true), "sound-pack-looking folders are searched first")

probes = 0
local miss = US:Resolve("definitely-not-there")
check(miss == nil and probes > 0 and probes <= 6200, "a miss stays bounded (" .. probes .. " probes)")

probes = 0
check(US:Resolve("Interface\\AddOns\\Elsewhere\\x.ogg") == "Interface\\AddOns\\Elsewhere\\x.ogg", "explicit path kept")
check(probes == 0, "no search for an explicit path")

_G.C_AddOns = nil
check(US:Resolve("roar") == nil, "without the add-on listing API other addons are not searched")
print("user-sounds-search-test OK")
