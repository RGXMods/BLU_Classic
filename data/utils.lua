BLU_L = BLU_L or {}
--=====================================================================================
-- BLU_Classic | Better Level-Up! - utils.lua
--=====================================================================================

-- Global table to hold the event queue
BLU_Classic_EventQueue = {}

--=====================================================================================
-- Database Get/Set Functions
--=====================================================================================
function BLU_Classic:GetValue(info)
    return self.db.profile[info[#info]]
end

function BLU_Classic:SetValue(info, value)
    self.db.profile[info[#info]] = value
end

--=====================================================================================
-- Event Handling
--=====================================================================================
function BLU_Classic:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound, debugMessage)
    if self.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end

    -- Mute default sounds for this event
    local version = self:GetGameVersion()
    local soundIDs = muteSoundIDs and muteSoundIDs[version]
    if soundIDs then
        for _, soundID in ipairs(soundIDs) do
            MuteSoundFile(soundID)
        end
    end
    
    -- Queue the event
    table.insert(BLU_Classic_EventQueue, {
        eventName = eventName,
        soundSelectKey = soundSelectKey,
        volumeKey = volumeKey,
        defaultSound = defaultSound,
        debugMessage = debugMessage
    })

    if not self.isProcessingQueue then
        self.isProcessingQueue = true
        self:ProcessEventQueue()
    end
end

--=====================================================================================
-- Process Event Queue
--=====================================================================================
function BLU_Classic:ProcessEventQueue()
    if #BLU_Classic_EventQueue == 0 then
        self.isProcessingQueue = false
        return
    end

    local event = table.remove(BLU_Classic_EventQueue, 1)

    if event.debugMessage then
        self:PrintDebugMessage(event.debugMessage)
    end

    local sound = self:SelectSound(self.db.profile[event.soundSelectKey])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(event.soundSelectKey))
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end

    local volumeLevel = self.db.profile[event.volumeKey]
    if not volumeLevel or volumeLevel < 0 or volumeLevel > 3 then
        volumeLevel = 2 -- Default to medium
    end

    self:PlaySelectedSound(sound, volumeLevel, event.defaultSound)
    C_Timer.After(1, function() self:ProcessEventQueue() end)
end

--=====================================================================================
-- Player Entering World Handler
--=====================================================================================
function BLU_Classic:HandlePlayerEnteringWorld()
    self:HaltOperations()
end

--=====================================================================================
-- Halt Operations
--=====================================================================================
function BLU_Classic:HaltOperations()

    -- Ensure functions are halted
    if not self.functionsHalted then
        self.functionsHalted = true
    end

    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end

    local countdownTime = 5
    self.haltTimer = C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        if countdownTime <= 0 then
            self:ResumeOperations()
        end
    end, countdownTime)
end

--=====================================================================================
-- Resume Operations
--=====================================================================================
function BLU_Classic:ResumeOperations()

    -- Lift the function halt
    if self.functionsHalted then
        self.functionsHalted = false
    end

    self.countdownRunning = false

    if self.haltTimer then
        self.haltTimer:Cancel()
        self.haltTimer = nil
    end
end

--=====================================================================================
-- Slash Command Handler
--=====================================================================================
function BLU_Classic:HandleSlashCommands(input)
    input = input:trim():lower()

    if input == "" then
        self:OpenOptionsPanel()
    elseif input == "icon" then
        self:DisplayBLUHelp()
    elseif input == "icon on" then
        self:ToggleMinimapIcon(true)
    elseif input == "icon off" then
        self:ToggleMinimapIcon(false)
    elseif input == "debug" then
        self:ToggleDebugMode()
    elseif input == "welcome" then
        self:ToggleWelcomeMessage()
    elseif input == "help" then
        self:DisplayBLUHelp() -- Use DisplayBLUHelp from be75efd
    else
        print(BLU_Classic_PREFIX .. BLU_L["UNKNOWN_SLASH_COMMAND"])
    end
end

--=====================================================================================
-- Open Options Panel (with Classic Era compatibility)
--=====================================================================================
function BLU_Classic:OpenOptionsPanel()
    -- Make sure options are initialized first
    if not self.optionsFrame then
        self:InitializeOptions()
    end
    
    if not self.optionsFrame then
        print(BLU_Classic_PREFIX .. "Options not initialized. Please reload UI.")
        return
    end
    
    local opened = false
    
    -- Try modern API first (Retail 10.0+)
    if Settings and Settings.OpenToCategory then
        -- In Retail, optionsFrame.name contains the category name
        local categoryName = self.optionsFrame.name or BLU_L["OPTIONS_PANEL_TITLE"]
        Settings.OpenToCategory(categoryName)
        opened = true
    end
    
    -- Try legacy API (Classic Era, Classic, older Retail)
    if not opened and InterfaceOptionsFrame_OpenToCategory then
        -- Classic needs the frame itself, not just the name
        -- Call twice to ensure it opens to the correct category (known Blizzard bug)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        opened = true
    end
    
    -- Fallback: Try to show the Interface Options frame directly
    if not opened then
        if InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            opened = true
        elseif SettingsPanel then
            SettingsPanel:Show()
            opened = true
        end
    end
    
    if opened then
        if self.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    else
        print(BLU_Classic_PREFIX .. "Unable to open options panel. Try /interface instead.")
    end
end

--=====================================================================================
-- Display BLU Help
--=====================================================================================
function BLU_Classic:DisplayBLUHelp()
    local helpCommand = BLU_L["HELP_COMMAND"] or "/bluc help - Displays help information."
    local helpDebug = BLU_L["HELP_DEBUG"] or "/blu debug or /bluc debug - Toggles debug mode."
    local helpWelcome = BLU_L["HELP_WELCOME"] or "/blu welcome - Toggles welcome messages."
    local helpIcon = BLU_L["HELP_ICON"] or "/blu icon on|off - Show or hide minimap icon."
    local helpPanel = BLU_L["HELP_PANEL"] or "/blu or /bluc - Opens the options panel."

    print(BLU_Classic_PREFIX .. helpCommand)
    print(BLU_Classic_PREFIX .. helpDebug)
    print(BLU_Classic_PREFIX .. helpWelcome)
    print(BLU_Classic_PREFIX .. helpIcon)
    print(BLU_Classic_PREFIX .. helpPanel)
end

--=====================================================================================
-- Toggle Functions
--=====================================================================================
function BLU_Classic:ToggleDebugMode()
    self.debugMode = not self.debugMode
    self.db.profile.debugMode = self.debugMode

    -- Use the localized strings directly, assuming they are defined
    local statusMessage = self.debugMode and BLU_L["DEBUG_MODE_ENABLED"] or BLU_L["DEBUG_MODE_DISABLED"]

    print(BLU_Classic_PREFIX .. statusMessage)

    -- Only print the debug message if debug mode is enabled
    if self.debugMode then
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.debugMode))
    end
end

function BLU_Classic:ToggleWelcomeMessage()
    self.showWelcomeMessage = not self.showWelcomeMessage
    self.db.profile.showWelcomeMessage = self.showWelcomeMessage

    local status = self.showWelcomeMessage and BLU_Classic_PREFIX .. BLU_L["WELCOME_MSG_ENABLED"] or BLU_Classic_PREFIX .. BLU_L["WELCOME_MSG_DISABLED"]
    print(status)
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(self.showWelcomeMessage))
    self:PrintDebugMessage("CURRENT_DB_SETTING", tostring(self.db.profile.showWelcomeMessage))
end

function BLU_Classic:CreateMinimapButton()
    if self.minimapButton or not Minimap then
        return
    end

    local button = CreateFrame("Button", "BLU_Classic_MinimapButton", Minimap)
    self.minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local backdrop = button:CreateTexture(nil, "BACKGROUND")
    backdrop:SetSize(24, 24)
    backdrop:SetPoint("CENTER", button, "CENTER", 1, 0)
    backdrop:SetTexture("Interface\\Buttons\\WHITE8X8")
    if backdrop.SetMask then
        backdrop:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall")
    end
    backdrop:SetVertexColor(0.03, 0.03, 0.03, 0.98)
    button.backdrop = backdrop

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(19, 19)
    icon:SetPoint("CENTER", button, "CENTER", 0, -1)
    icon:SetTexture("Interface\\AddOns\\BLU_Classic\\media\\icon")
    icon:SetTexCoord(0.02, 0.98, 0.02, 0.98)
    button.icon = icon

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(54, 54)
    overlay:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.overlay = overlay

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" and not self.isDragging then
            BLU_Classic:OpenOptionsPanel()
        end
    end)

    button:SetScript("OnDragStart", function(self)
        self.isDragging = true
        if GameTooltip then
            GameTooltip:Hide()
        end
        self:SetScript("OnUpdate", function()
            BLU_Classic:UpdateMinimapPositionFromCursor()
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:SetScript("OnUpdate", nil)
        BLU_Classic:UpdateMinimapButtonPosition()
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(BLU_L["MINIMAP_TOOLTIP_TITLE"] or "BLU Classic")
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffd9c6ffKeep your BLU Classic settings one click away.|r", 1, 1, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("|cff05dffaLeft-Click|r", "|cffffffffOpen options|r", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("|cff4ecdc4Left-Drag|r", "|cffffffffMove around minimap|r", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("|cffe74c3cCtrl+Right-Click|r", "|cffffffffHide minimap icon|r", 1, 1, 1, 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "RightButton" and IsControlKeyDown() then
            self.isCtrlRightClick = true
        end
    end)

    button:SetScript("OnMouseUp", function(self, mouseButton)
        if mouseButton == "RightButton" and self.isCtrlRightClick and IsControlKeyDown() then
            self.isCtrlRightClick = false
            GameTooltip:Hide()
            BLU_Classic:ToggleMinimapIcon(false)
        end
    end)
end

function BLU_Classic:UpdateMinimapButtonPosition()
    if not self.minimapButton or not Minimap or not self.db or not self.db.profile then
        return
    end

    local angle = math.rad(self.db.profile.classicMinimapAngle or 220)
    local minimapRadius = math.max(Minimap:GetWidth() or 140, Minimap:GetHeight() or 140) / 2 + 10
    local x = math.cos(angle) * minimapRadius
    local y = math.sin(angle) * minimapRadius
    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function BLU_Classic:UpdateMinimapPositionFromCursor()
    if not self.minimapButton or not Minimap or not self.db or not self.db.profile then
        return
    end

    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx = cx / scale
    cy = cy / scale

    if not mx or not my then
        return
    end

    local dy = cy - my
    local dx = cx - mx
    local angle = math.deg((math.atan2 and math.atan2(dy, dx)) or math.atan(dy, dx))
    if angle < 0 then
        angle = angle + 360
    end

    self.db.profile.classicMinimapAngle = angle
    self:UpdateMinimapButtonPosition()
end

function BLU_Classic:ToggleMinimapIcon(show)
    if not self.db or not self.db.profile then
        return
    end

    self.db.profile.classicMinimapIconEnabled = show and true or false

    if show then
        if not self.minimapButton then
            self:CreateMinimapButton()
        end
        if self.minimapButton then
            self.minimapButton:Show()
            self:UpdateMinimapButtonPosition()
        end
        print(BLU_Classic_PREFIX .. (BLU_L["MINIMAP_ICON_SHOWN"] or "Minimap icon shown.|r"))
    else
        if self.minimapButton then
            self.minimapButton:Hide()
        end
        print(BLU_Classic_PREFIX .. (BLU_L["MINIMAP_ICON_HIDDEN"] or "Minimap icon hidden.|r"))
    end
end

--=====================================================================================
-- Debug Messaging
--=====================================================================================

function BLU_Classic:DebugMessage(message)
    if self.debugMode then
        print(BLU_Classic_PREFIX .. DEBUG_PREFIX .. message)
    end
end

function BLU_Classic:PrintDebugMessage(key, ...)
    if self.debugMode and BLU_L[key] then -- Changed BLU_Classic_L to BLU_L for consistency
        self:DebugMessage(BLU_L[key]:format(...))
    end
end

--=====================================================================================
-- Sound Selection
--=====================================================================================

function BLU_Classic:RandomSoundID()
    self:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

    local validSoundIDs = {}

    if sounds then
        for soundID, _ in pairs(sounds) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end

    if defaultSounds then
        for soundID, _ in pairs(defaultSounds) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end

    if #validSoundIDs == 0 then
        self:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    local randomIndex = math.random(1, #validSoundIDs)
    local selected = validSoundIDs[randomIndex]

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", "|cff8080ff" .. selected.id .. "|r")
    return selected
end
--=====================================================================================
-- Select Sound
--=====================================================================================
function BLU_Classic:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", "|cff8080ff" .. tostring(soundID) .. "|r")

    -- Random sound (value 2)
    if not soundID or soundID == 2 then
        local randomSound = self:RandomSoundID()
        if randomSound then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", "|cff8080ff" .. randomSound.id .. "|r")
            return randomSound
        end
    end

    self:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", "|cff8080ff" .. soundID .. "|r")
    return {table = sounds, id = soundID}
end

--=====================================================================================
-- Test Sound Function
--=====================================================================================

function BLU_Classic:TestSound(soundID, volumeKey, defaultSound, debugMessage)
    self:PrintDebugMessage(debugMessage)

    local sound = self:SelectSound(self.db.profile[soundID])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(soundID))
        return
    end
    
    local volumeLevel = self.db.profile[volumeKey]
    if not volumeLevel or volumeLevel < 0 or volumeLevel > 3 then
        volumeLevel = 2
    end
    
    self:PlaySelectedSound(sound, volumeLevel, defaultSound)
end

--=====================================================================================
-- Sound Playback
--=====================================================================================
function BLU_Classic:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    local soundFile
    
    -- Default sound (value 1)
    if sound.id == 1 then
        soundFile = defaultTable and defaultTable[volumeLevel]
    else
        -- Custom sound
        soundFile = sound.table and sound.table[sound.id] and sound.table[sound.id][volumeLevel]
    end

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", "|cffce9178" .. tostring(soundFile) .. "|r")

    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", "|cff8080ff" .. tostring(sound.id) .. "|r")
    end
end
