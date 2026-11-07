--=====================================================================================
-- BLU_Classic - data/usersounds.lua
-- User custom sounds: players add their own .ogg/.mp3/.wav files and pick them on the
-- event pages. Behavior mirrors BLU Forever core/sounds/usersounds.lua, kept small:
--   * entries are stored per profile in db.userCustomSounds = { {file=, name=}, ... }
--   * a custom sound is selected by the string id "custom:<normalized path>", so the
--     numeric ids of the shipped library never change
--   * a short name resolves against common AddOns folders and is verified by playing it
--=====================================================================================

local BLU = _G.BLU_Classic
local ADDON_NAME = "BLU_Classic"

local UserSounds = {}
BLU.UserSounds = UserSounds
BLU.Modules = BLU.Modules or {}
BLU.Modules["usersounds"] = UserSounds

local ID_PREFIX = "custom:"
local EXTENSIONS = {"ogg", "mp3", "wav"}
local SEARCH_PATHS = {
    "Interface\\AddOns\\%s",
    "Interface\\AddOns\\sounds\\%s",
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\%s",
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\sounds\\%s",
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\user\\%s",
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\user\\sounds\\%s",
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\media\\%s",
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\media\\sounds\\%s",
}

local function Normalize(path)
    if type(path) ~= "string" then return nil end
    local normalized = path:gsub("/", "\\"):gsub("^%s+", ""):gsub("%s+$", "")
    if normalized == "" then return nil end
    return normalized
end

local function HasSupportedExtension(path)
    local lower = (path or ""):lower()
    for _, extension in ipairs(EXTENSIONS) do
        if lower:sub(-(#extension + 1)) == "." .. extension then
            return true
        end
    end
    return false
end

local function DisplayNameFromPath(path)
    return path:match("([^\\]+)%.[^%.]+$") or path
end

-- WoW reports whether a file can be played; this briefly plays it, then stops it.
local function CanPlay(path)
    local ok, willPlay, handle = pcall(PlaySoundFile, path, "Master")
    if handle and StopSound then
        pcall(StopSound, handle)
    end
    return ok and willPlay == true
end

local function Entries(create)
    local db = BLU.db
    if not db then return nil end
    if type(db.userCustomSounds) ~= "table" then
        if not create then return {} end
        db.userCustomSounds = {}
    end
    return db.userCustomSounds
end

function UserSounds:IdForFile(file)
    return ID_PREFIX .. file
end

function UserSounds:IsCustomId(value)
    return type(value) == "string" and value:sub(1, #ID_PREFIX) == ID_PREFIX
end

function UserSounds:FileForId(value)
    if not self:IsCustomId(value) then return nil end
    return value:sub(#ID_PREFIX + 1)
end

function UserSounds:GetEntries()
    local list = {}
    for _, entry in ipairs(Entries(false) or {}) do
        if type(entry) == "table" and entry.file then
            list[#list + 1] = {
                file = entry.file,
                name = entry.name or DisplayNameFromPath(entry.file),
                id = self:IdForFile(entry.file),
                removable = true,
            }
        end
    end
    return list
end

function UserSounds:GetName(value)
    local file = self:FileForId(value)
    if not file then return nil end
    for _, entry in ipairs(self:GetEntries()) do
        if entry.file == file then return entry.name end
    end
    return DisplayNameFromPath(file) .. " (missing)"
end

-- Returns the stored custom entry for a selection id, or nil when it was removed.
function UserSounds:Find(value)
    local file = self:FileForId(value)
    if not file then return nil end
    for _, entry in ipairs(self:GetEntries()) do
        if entry.file == file then return entry end
    end
    return nil
end

--- Resolve what the player typed: a full Interface\AddOns path, a file name with an
--- extension, or a bare name (tried with .ogg/.mp3/.wav in BLU's own documented folders only).
function UserSounds:Resolve(input)
    local text = Normalize(input)
    if not text then return nil, "Enter a file name like myfile or myfile.ogg." end

    local explicitPath = text:find("\\") ~= nil
    local explicitExtension = HasSupportedExtension(text)

    if explicitPath and explicitExtension then
        return text
    end

    local names = {}
    if explicitExtension then
        names[1] = text
    else
        for _, extension in ipairs(EXTENSIONS) do
            names[#names + 1] = text .. "." .. extension
        end
    end

    local candidates = {}
    if explicitPath then
        candidates = names
    else
        for _, name in ipairs(names) do
            for _, pattern in ipairs(SEARCH_PATHS) do
                candidates[#candidates + 1] = string.format(pattern, name)
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        if CanPlay(candidate) then
            return candidate
        end
    end

    return nil, "Could not find '" .. text .. "'. Put the .ogg, .mp3 or .wav in Interface\\AddOns\\" .. ADDON_NAME .. "\\user\\sounds\\ (then fully restart the game, a /reload is not enough for new files), or give the full path starting with Interface\\AddOns\\."
end

--- Returns ok, nameOrError, resolvedPath.
function UserSounds:Add(input)
    if not BLU.db then return false, "Database not ready." end
    local path, err = self:Resolve(input)
    if not path then return false, err end

    local entries = Entries(true)
    for _, entry in ipairs(entries) do
        if entry.file == path then
            return false, "That sound is already added."
        end
    end

    local name = DisplayNameFromPath(path)
    entries[#entries + 1] = { file = path, name = name }
    return true, name, path
end

function UserSounds:Remove(file)
    local entries = Entries(false)
    if not entries then return false, "Database not ready." end
    for index, entry in ipairs(entries) do
        if entry.file == file then
            table.remove(entries, index)
            return true
        end
    end
    return false, "Sound not found."
end
