-- BLU_Classic looks up a typed custom sound name through the framework's resolver (RGXSound:ResolveFile), with the
-- designated BLU_Sounds folder first. With the real framework file reachable (RGXFW_PATH or a sibling checkout),
-- the player's own spellings are checked end to end.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local files = {}
_G.PlaySoundFile = function(path) if files[path:lower()] then return true, 1 end return false end
_G.StopSound = function() end
_G.BLU_Classic = { Modules = {}, db = {} }
assert(loadfile("data/usersounds.lua"))()
local US = BLU_Classic.UserSounds
local FOLDER = "Interface\\AddOns\\BLU_Sounds\\"

local seen
_G.RGXSound = { ResolveFile = function(_, input, opts) seen = { input = input, folders = opts and opts.folders }; return FOLDER .. "x.ogg" end }
check(US:Resolve("sonar boop med") == FOLDER .. "x.ogg", "the framework's answer is used")
check(seen.input == "sonar boop med" and seen.folders[1] == FOLDER, "typed text and BLU_Sounds first are passed")

_G.RGXSound = { ResolveFile = function() return nil, {} end }
local miss, err = US:Resolve("nope")
check(miss == nil and err:find("BLU_Sounds", 1, true) and err:lower():find("restart", 1, true), "a miss explains the folder and the restart")
check(US:Resolve("Interface\\AddOns\\Elsewhere\\x.ogg") == "Interface\\AddOns\\Elsewhere\\x.ogg", "an explicit path is still kept")

local fw = os.getenv("RGXFW_PATH")
local chunk
for _, p in ipairs({ fw and (fw .. "/libraries/sound/sound.lua"), "../fw/libraries/sound/sound.lua", "../RGX-Framework/libraries/sound/sound.lua" }) do
  if p then chunk = loadfile(p); if chunk then break end end
end
if chunk then
  _G.RGXFramework = { RegisterModule = function() end }
  chunk("RGX-Framework", {})
  files[(FOLDER .. "sonar_boop_med.ogg"):lower()] = true
  for _, typed in ipairs({ "sonar_boop_med", "sonar_boop_med.ogg", "sonar boop med" }) do
    local got = US:Resolve(typed)
    check(got and got:lower() == (FOLDER .. "sonar_boop_med.ogg"):lower(), "'" .. typed .. "' finds the file (got " .. tostring(got) .. ")")
  end
  -- The smart lookup end to end: where players really put files and how they really type names.
  local cases = {
    { "Interface\\AddOns\\BLU_Sounds\\BLU_Sounds\\unzipped.ogg", "unzipped" },
    { "Interface\\AddOns\\BLU_Sounds\\sounds\\nested.ogg", "nested.ogg" },
    { "Interface\\AddOns\\BLU_Sounds\\hidden.ogg.ogg", "hidden.ogg" },
    { "Interface\\AddOns\\BLU_Sounds\\real-dash.mp3", "real dash.ogg" },
    { "Interface\\AddOns\\BLU_Sounds\\pack\\inpack.ogg", "BLU_Sounds/pack/inpack" },
    { "Interface\\AddOns\\BLU_Sounds\\pasted.ogg", "C:\\Program Files (x86)\\World of Warcraft\\_forever_\\Interface\\AddOns\\BLU_Sounds\\pasted.ogg" },
  }
  for _, c in ipairs(cases) do
    files[c[1]:lower()] = true
    local t = c[2]
    local got = US:Resolve(t)
    check(got and got:lower() == c[1]:lower(), "'" .. t .. "' finds " .. c[1] .. " (got " .. tostring(got) .. ")")
  end
  print("user-sounds-framework-test OK (real framework resolver)")
else
  print("user-sounds-framework-test OK (framework source not reachable; real resolver not exercised)")
end
