--=====================================================================================
-- BLU_Classic - data/ui/design.lua
-- Design system (colors, backdrops, styled controls). Mirrors BLU / BLU Forever
-- core/interface/design.lua so all three builds share one look.
--=====================================================================================

local BLU = _G.BLU_Classic

-- Create design module
local Design = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["design"] = Design

BLU.Design = Design

-- Colour adapter. Every colour in BLU Classic's options UI comes from the RGX-Framework
-- theme: Design.Rgb(role) / Design.Rgba(role, alpha) read the framework's token for a
-- role when a panel is built. Values are never cached at load (the framework restores its
-- saved style after this file loads), and nothing here changes the framework's style or
-- theme. FALLBACK holds BLU's original palette and is used only when the framework is not
-- loaded.
local FALLBACK = {
    primary = {0.02, 0.87, 0.98}, surface = {0.08, 0.11, 0.15}, background = {0.05, 0.05, 0.05},
    border = {0.14, 0.20, 0.28}, hover = {0.11, 0.18, 0.24}, track = {0.30, 0.30, 0.30},
    text = {0.80, 0.80, 0.80}, subtext = {0.60, 0.66, 0.72},
    success = {0.36, 0.88, 0.52}, error = {1.00, 0.35, 0.35}, warning = {1.00, 0.82, 0.18},
    label = {0.36, 0.36, 0.40},
}

-- Old palette names, kept so existing call sites (Design.Colors.Primary) keep working.
-- Secondary is the gold used for tooltip hints. The framework "warning" token is amber in every style.
-- Highlights (active tabs, switch on-state, accents) use BLU's brand cyan, not the framework
-- theme colour. Surfaces, borders and text still follow the framework.
local BRAND = {0.02, 0.87, 0.98}  -- #05DFFA
local ROLE_BY_KEY = { Primary = "brand", Accent = "border", Secondary = "warning" }

local function FrameworkDesign()
    local RGX = _G.RGXFramework
    local D = RGX and RGX.GetDesign and RGX:GetDesign()
    if D and type(D.Unpack) == "function" then
        return D
    end
    return nil
end

function Design.Rgb(role)
    if role == "brand" then
        return BRAND[1], BRAND[2], BRAND[3]
    end
    local D = FrameworkDesign()
    if D then
        local r, g, b = D:Unpack(role)
        if type(r) == "number" then
            return r, g, b
        end
    end
    local fallback = FALLBACK[role] or FALLBACK.text
    return fallback[1], fallback[2], fallback[3]
end

function Design.Rgba(role, alpha)
    local r, g, b = Design.Rgb(role)
    return r, g, b, alpha
end

-- Read on each access, so a panel built after a theme change picks up the new colour.
Design.Colors = setmetatable({}, {
    __index = function(_, key)
        local role = ROLE_BY_KEY[key]
        if not role then
            return nil
        end
        local r, g, b = Design.Rgb(role)
        return { r, g, b }
    end,
})

-- Backdrop templates
Design.Backdrops = {
    Dark = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    },
    
    Light = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    },
    
    Button = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    },
    
    Solid = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    },

    Panel = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    }
}

-- Layout constants
Design.Layout = {
    Spacing = 10,
    Padding = 15,
}

-- Font objects
Design.Fonts = {
    Title = "GameFontNormalLarge",
    Normal = "GameFontNormal",
    Small = "GameFontNormalSmall",
    Highlight = "GameFontHighlight",
}

-- Convert RGB (0-1) to Hex string

function Design:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end



-- Helper function to create styled buttons
function Design:CreateStyledButton(parent, text, width, height)
    return self:CreateActionButton(parent, text, width, height)
end

-- Action button — matches tab button visual system (bg texture + border frame + text)
-- Optional tooltip: pass tooltipTitle and tooltipBody on the returned button, or call

function Design:CreateActionButton(parent, text, width, height, tooltipTitle, tooltipBody)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 120, height or 22)

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(Design.Rgba("surface", 0.90))
    button.bg = bg

    local border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    border:SetBackdropBorderColor(Design.Rgba("border", 1))
    button.border = border

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text or "Button")
    label:SetTextColor(Design.Rgba("text", 1))
    button.label = label

    function button:SetText(value)
        if self.label then
            self.label:SetText(value or "")
        end
    end

    function button:GetText()
        if self.label and self.label.GetText then
            return self.label:GetText()
        end
        return nil
    end

    local function applyHover(self)
        self.bg:SetColorTexture(Design.Rgba("hover", 1))
        self.border:SetBackdropBorderColor(unpack(Design.Colors.Primary))
        self.label:SetTextColor(unpack(Design.Colors.Primary))
    end
    local function applyIdle(self)
        self.bg:SetColorTexture(Design.Rgba("surface", 0.90))
        self.border:SetBackdropBorderColor(Design.Rgba("border", 1))
        self.label:SetTextColor(Design.Rgba("text", 1))
    end

    button:SetScript("OnEnter", function(self)
        applyHover(self)
        if self._ttTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self._ttTitle, unpack(Design.Colors.Primary))
            if self._ttBody then
                GameTooltip:AddLine(" ")
                for line in tostring(self._ttBody):gmatch("[^\n]+") do
                    local color = {0.88, 0.88, 0.88}
                    local lower = string.lower(line)

                    if string.find(lower, "type ", 1, true) or string.find(lower, "enter ", 1, true) then
                        color = Design.Colors.Secondary
                    elseif string.find(lower, "full interface", 1, true) or string.find(lower, "full path", 1, true) then
                        color = {0.72, 0.84, 1.0}
                    elseif string.find(lower, "automatically", 1, true) or string.find(lower, "search", 1, true) then
                        color = {0.60, 0.88, 0.70}
                    end

                    GameTooltip:AddLine(line, color[1], color[2], color[3], true)
                end
            end
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function(self)
        applyIdle(self)
        GameTooltip:Hide()
    end)

    function button:SetTooltip(title, body)
        self._ttTitle = title
        self._ttBody = body
    end

    if tooltipTitle then
        button:SetTooltip(tooltipTitle, tooltipBody)
    end

    return button
end


-- Helper function to create section headers
function Design:CreateSectionHeader(parent, text, icon)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(32)
    header:SetBackdrop(Design.Backdrops.Solid)
    header:SetBackdropColor(Design.Rgba("surface", 0.95))
    header:SetBackdropBorderColor(unpack(Design.Colors.Accent))

    local leftInset = 10
    if icon then
        local iconTexture = header:CreateTexture(nil, "ARTWORK")
        iconTexture:SetSize(16, 16)
        iconTexture:SetPoint("LEFT", 8, 0)
        iconTexture:SetTexture(icon)
        leftInset = 30
    end
    
    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", leftInset, 0)
    label:SetText(text)
    label:SetTextColor(unpack(Design.Colors.Primary))
    header.label = label
    
    return header
end

-- Helper function to create dividers
function Design:CreateDivider(parent)
    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetColorTexture(Design.Rgba("track", 0.8))
    return divider
end

function Design:ApplyBackdrop(frame, template, bgColor, borderColor)
    template = template or "Dark"
    local backdrop = self.Backdrops[template] or self.Backdrops.Dark
    frame:SetBackdrop(backdrop)
    if bgColor then
        frame:SetBackdropColor(unpack(bgColor))
    end
    if borderColor then
        frame:SetBackdropBorderColor(unpack(borderColor))
    end
end

function Design:CreateSection(parent, title, icon)
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    self:ApplyBackdrop(section, "Panel", {0.03, 0.03, 0.03, 0.6}, {0.14, 0.20, 0.28, 1})
    
    if title then
        local header = self:CreateHeader(section, title, icon)
        header:SetPoint("TOPLEFT", 10, -8)
        header:SetPoint("TOPRIGHT", -10, -8)
        section.header = header
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 16, -42)
        section.content:SetPoint("BOTTOMRIGHT", -16, 12)
    else
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT", 16, -10)
        section.content:SetPoint("BOTTOMRIGHT", -16, 10)
    end
    
    return section
end

function Design:CreateCheckbox(parent, label, tooltip)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(24)
    
    local check = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint("LEFT", 0, 0)
    
    local text = frame:CreateFontString(nil, "OVERLAY", Design.Fonts.Normal)
    text:SetPoint("LEFT", check, "RIGHT", 5, 0)
    text:SetText(label)
    
    frame.check = check
    frame.text = text
    
    if tooltip then
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
    end
    
    -- Auto-size frame
    frame:SetWidth(check:GetWidth() + 5 + text:GetStringWidth())
    
    return frame
end

-- Aliases (same names BLU / BLU Forever use)
Design.CreateButton = Design.CreateStyledButton
Design.CreateHeader = Design.CreateSectionHeader
