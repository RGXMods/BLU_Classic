-- BLU Classic follows the framework's beta global theme override live: the brand cyan is the framework's main
-- colour while the override is on, and the options body is rebuilt when the theme changes.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local override, listener = false, nil
local GOLD = { 1, 0.843, 0 }
local D = {
  Unpack = function(_, role) return 0.2, 0.2, 0.2 end,
  RegisterBrand = function(_, id, own, style)
    return { id = id, style = style, OnChange = function(_, fn) listener = fn end, Build = function(_, fn) return fn() end,
      Resolve = function() if override then return { primary = GOLD, accent = GOLD }, "materialround" end return own, style end }
  end,
}
_G.RGXFramework = { GetDesign = function() return D end }
local rebuilt = 0
_G.BLU_Classic = { Modules = {}, RebuildOptionsBody = function() rebuilt = rebuilt + 1 end }
assert(loadfile("data/ui/design.lua"))("BLU_Classic")
local BLU, Design = _G.BLU_Classic, _G.BLU_Classic.Design
check(BLU.Hex() == "|cff05dffa", "override off: BLU cyan (" .. BLU.Hex() .. ")")
check(Design:GetBrand().id == "BLU_Classic" and Design:GetBrand().style == "framework", "the brand is registered in BLU's own square style")
override = true
check(BLU.Hex() == "|cffffd700", "override on: the framework's main colour")
local r = Design.Rgb("brand")
check(r == 1, "override on: brand highlights follow")
listener()
check(rebuilt == 1, "a theme change rebuilds the options body")
override = false
check(BLU.Hex() == "|cff05dffa", "override off again: BLU cyan")

-- Tabs take the framework's tab look while the override is on.
do
  local fh = assert(io.open("data/ui/tabs.lua")); local tabsSrc = fh:read("*a"); fh:close()
  check(tabsSrc:find("D:IsThemeOverride() and UIfw and UIfw.SkinTab", 1, true) and tabsSrc:find("UIfw:SkinTab(button)", 1, true), "under the override the tabs use the framework's tab skin")
  check(tabsSrc:find('UIfw:PaintTab(self, active and "active" or "idle", Primary())', 1, true), "the tab states are painted by the framework")
end
io.write("live-theme OK\n")
