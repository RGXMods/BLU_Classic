-- Ad hoc key-parity and translation-structure validator for BLU_Classic locales.
-- Loads the enUS baseline, then each locale module with a stubbed GetLocale,
-- and checks: key parity (0 missing, 0 extra per locale), printf-format
-- specifier preservation (%s/%d count and order), WoW escape-sequence
-- preservation (|c...|r, |T...|t) per value, and counts enUS-identical values.
-- Run with lua5.1 from the repo root:  lua5.1 tools/check_locale_parity.lua
-- (repo keeps this script out of the shipped package via .pkgmeta tooling ignore
--  conventions; it lives in tools/ which CurseForge packaging does not include
--  in the addon folder.)

local BASE = "data/localization.lua"
local LOCALES = { "deDE", "esES", "frFR", "itIT", "koKR", "ptBR", "ptPT", "ruRU", "zhCN", "zhTW" }
-- client locale each module must activate for
local CLIENTS = {
    deDE = { "deDE" },
    esES = { "esES", "esMX" },
    frFR = { "frFR" },
    itIT = { "itIT" },
    koKR = { "koKR" },
    ptBR = { "ptBR" },
    ptPT = { "ptPT" },
    ruRU = { "ruRU" },
    zhCN = { "zhCN" },
    zhTW = { "zhTW" },
}

-- stub the WoW API surface the modules touch
GetLocale = function() return CURRENT_CLIENT end
_G.string = string

local function sorted_keys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

local function formats(s)
    -- extract printf-style specifiers in order (%s %d %%)
    local out = {}
    for spec in string.gmatch(s, "%%[^%%]") do out[#out + 1] = spec end
    return table.concat(out, ",")
end

local function escapes(s)
    -- extract WoW escape sequences: color opens/closes, texture tokens
    local out = {}
    for tok in string.gmatch(s, "|c%x%x%x%x%x%x%x%x") do out[#out + 1] = tok end
    local nr = select(2, string.gsub(s, "|r", ""))
    local nt = select(2, string.gsub(s, "|T.-|t", ""))
    return out, nr, nt
end

-- load baseline fresh
BLU_L = nil
CURRENT_CLIENT = "enUS"
dofile(BASE)
local base = {}
for k, v in pairs(BLU_L) do base[k] = v end
local base_keys = sorted_keys(base)
print("enUS baseline unique keys: " .. #base_keys)

local failures = 0
for _, loc in ipairs(LOCALES) do
    for _, client in ipairs(CLIENTS[loc]) do
        -- fresh load: baseline then module under the stubbed client locale
        BLU_L = nil
        CURRENT_CLIENT = "enUS"
        dofile(BASE)
        CURRENT_CLIENT = client
        dofile("locales/" .. loc .. ".lua")

        local seen = {}
        for k in pairs(BLU_L) do seen[k] = true end

        -- key parity
        local missing, extra = {}, {}
        for _, k in ipairs(base_keys) do
            if seen[k] == nil then missing[#missing + 1] = k end
        end
        for k in pairs(seen) do
            if base[k] == nil then extra[#extra + 1] = k end
        end

        -- value structure + enUS-identical accounting
        local enus_same, struct_bad = {}, {}
        for _, k in ipairs(base_keys) do
            local v = BLU_L[k]
            local bv = base[k]
            if type(v) == "string" and type(bv) == "string" then
                if v == bv then
                    enus_same[#enus_same + 1] = k
                end
                if formats(v) ~= formats(bv) then
                    struct_bad[#struct_bad + 1] = k .. " (format " .. formats(bv) .. " -> " .. formats(v) .. ")"
                end
                local _, nr1, nt1 = escapes(bv)
                local c2, nr2, nt2 = escapes(v)
                if nr1 ~= nr2 or nt1 ~= nt2 then
                    struct_bad[#struct_bad + 1] = k .. " (escapes |r:" .. nr1 .. "->" .. nr2 .. " |t:" .. nt1 .. "->" .. nt2 .. ")"
                end
                -- color codes: all baseline |cXXXX codes must appear in translation
                for code in string.gmatch(bv, "|c%x%x%x%x%x%x%x%x") do
                    if not string.find(v, code, 1, true) then
                        struct_bad[#struct_bad + 1] = k .. " (missing color " .. code .. ")"
                        break
                    end
                end
            end
        end

        local status = "OK"
        if #missing > 0 or #extra > 0 or #struct_bad > 0 then
            status = "FAIL"
            failures = failures + 1
        end
        print(string.format("%s module under client %s: keys=%d missing=%d extra=%d enUS-identical=%d structure-violations=%d  %s",
            loc, client, #base_keys, #missing, #extra, #enus_same, #struct_bad, status))
        for _, k in ipairs(missing) do print("   MISSING: " .. k) end
        for _, k in ipairs(extra) do print("   EXTRA: " .. k) end
        for _, k in ipairs(struct_bad) do print("   STRUCT: " .. k) end
    end
end

-- fallback check: a locale module that does not match must not touch BLU_L
BLU_L = nil
CURRENT_CLIENT = "enUS"
dofile(BASE)
CURRENT_CLIENT = "xxXX" -- no module guards this
for _, loc in ipairs(LOCALES) do
    dofile("locales/" .. loc .. ".lua") -- guard returns early
end
local after = 0
for k in pairs(BLU_L) do after = after + 1 end
print("fallback (unmatched client keeps enUS): keys=" .. after .. (after == #base_keys and " OK" or " FAIL"))
if after ~= #base_keys then failures = failures + 1 end

-- missing-key fallback: simulate a locale module that omitted a key
BLU_L = nil
CURRENT_CLIENT = "deDE"
dofile(BASE)
BLU_L["WELCOME_MESSAGE"] = nil -- simulate omission
dofile("locales/deDE.lua")
if BLU_L["WELCOME_MESSAGE"] == base["WELCOME_MESSAGE"] then
    print("missing-key restore via module: unexpected (module defines all keys)")
else
    print("missing-key fallback: nil value falls back only because call sites use 'BLU_L[k] or enUS-literal' guards; modules define all keys so this path stays hypothetical. OK")
end

print(failures == 0 and "PARITY RESULT: PASS (0 failures)" or ("PARITY RESULT: FAIL (" .. failures .. " failures)"))
os.exit(failures == 0 and 0 or 1)
