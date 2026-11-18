-- BLU Classic's sound folders: sounds\wow_default\, sounds\game\ and sounds\user\ (shipped empty for the player's
-- own files). Every built-in sound path must point at a file that exists, and a file in sounds\user\ is found by name.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function exists(p) local f = io.open(p, "rb"); if f then f:close(); return true end return false end
local function read(p) local f = assert(io.open(p, "rb")); local s = f:read("*a"); f:close(); return s end
check(exists("sounds/user/README.txt"), "sounds/user ships with its README")
local src = read("data/sounds.lua")
local n = 0
for sub, name in src:gmatch('Interface\\\\Addons\\\\BLU_Classic\\\\sounds\\\\([%w_]+)\\\\([^"\\]+)"') do
  n = n + 1
  check(sub == "wow_default" or sub == "game", name .. " is in a known folder (" .. sub .. ")")
  check((sub == "wow_default") == (name:find("_default_", 1, true) ~= nil), name .. " is in the right folder")
  check(exists("sounds/" .. sub .. "/" .. name), "sounds/" .. sub .. "/" .. name .. " exists")
end
check(n >= 180, "built-in sound paths found (" .. n .. ")")
check(not src:find('BLU_Classic\\\\sounds\\\\[%w_%-]+%.ogg'), "no built-in sound still points at the flat sounds folder")

local files = {}
_G.PlaySoundFile = function(path) if files[path:lower()] then return true, 1 end return false end
_G.StopSound = function() end
_G.BLU_Classic = { Modules = {}, db = {} }
assert(loadfile("data/usersounds.lua"))()
local US = BLU_Classic.UserSounds
local USER = "Interface\\AddOns\\BLU_Classic\\sounds\\user\\"
check(US.ADDON_USER_FOLDER == USER, "the shipped user folder is exposed")
files[(USER .. "sonar_boop_med.ogg"):lower()] = true
check(US:Resolve("sonar_boop_med") == USER .. "sonar_boop_med.ogg", "a name in sounds\\user resolves")
print("sound-layout-test OK")
