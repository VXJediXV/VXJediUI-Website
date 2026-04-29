-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials
local L = AE.L
if not VXJediEssentials then
    error("Optimize: Addon object not initialized. Check file load order!")
    return
end

---@class Optimize: AceModule, AceEvent-3.0
local OPT = VXJediEssentials:NewModule("Optimize", "AceEvent-3.0")

local _SetCVar = SetCVar or C_CVar.SetCVar
local _GetCVar = GetCVar or C_CVar.GetCVar
local pcall = pcall
local tostring = tostring
local tonumber = tonumber
local string_format = string.format
local math_abs = math.abs
local ipairs = ipairs
local pairs = pairs
local next = next

------------------------------------------------------------------------
-- Separate SavedVariables for optimization backups
-- This persists in VXJediEssentialsOptimizeDB so installer won't overwrite it
------------------------------------------------------------------------
local backupCache = nil
local function GetBackupDB()
    if backupCache then return backupCache end
    if not VXJediEssentialsOptimizeDB then
        VXJediEssentialsOptimizeDB = {}
    end
    if not VXJediEssentialsOptimizeDB.SavedSettings then
        VXJediEssentialsOptimizeDB.SavedSettings = {}
    end
    backupCache = VXJediEssentialsOptimizeDB
    return backupCache
end

------------------------------------------------------------------------
-- CVar Definitions grouped by category
------------------------------------------------------------------------
OPT.Categories = {
    {
        id = "render",
        name = "Render & Display",
        cvars = {
            { cvar = "renderScale",         optimal = "1",    name = "Render Scale",       desc = "100%% native resolution" },
            { cvar = "VSync",               optimal = "0",    name = "VSync",              desc = L["Disabled"] },
            { cvar = "MSAAQuality",          optimal = "0",    name = "Multisampling",      desc = L["None"] },
            { cvar = "LowLatencyMode",       optimal = "3",    name = "Low Latency Mode",   desc = "Reflex + Boost" },
            { cvar = "ffxAntiAliasingMode",  optimal = "4",    name = "Anti-Aliasing",      desc = "CMAA2" },
        },
    },
    {
        id = "graphics",
        name = "Graphics Quality",
        cvars = {
            { cvar = "graphicsShadowQuality",      optimal = "0", name = "Shadow Quality",      desc = "Low" },
            { cvar = "graphicsLiquidDetail",        optimal = "1", name = "Liquid Detail",        desc = "Fair" },
            { cvar = "graphicsParticleDensity",     optimal = "3", name = "Particle Density",     desc = "Good" },
            { cvar = "graphicsSSAO",                optimal = "0", name = "SSAO",                 desc = L["Disabled"] },
            { cvar = "graphicsDepthEffects",        optimal = "0", name = "Depth Effects",        desc = L["Disabled"] },
            { cvar = "graphicsComputeEffects",      optimal = "0", name = "Compute Effects",      desc = L["Disabled"] },
            { cvar = "graphicsOutlineMode",         optimal = "2", name = "Outline Mode",         desc = "High" },
            { cvar = "graphicsTextureResolution",   optimal = "2", name = "Texture Resolution",   desc = "High" },
            { cvar = "graphicsSpellDensity",        optimal = "0", name = "Spell Density",        desc = "Essential" },
            { cvar = "graphicsProjectedTextures",   optimal = "1", name = "Projected Textures",   desc = L["Enabled"] },
        },
    },
    {
        id = "detail",
        name = "View Distance & Detail",
        cvars = {
            { cvar = "graphicsViewDistance",        optimal = "3", name = "View Distance",        desc = "Level 4" },
            { cvar = "graphicsEnvironmentDetail",   optimal = "3", name = "Environment Detail",   desc = "Level 4" },
            { cvar = "graphicsGroundClutter",       optimal = "0", name = "Ground Clutter",       desc = "Level 1" },
        },
    },
    {
        id = "advanced",
        name = "Advanced",
        cvars = {
            { cvar = "GxMaxFrameLatency",    optimal = "2",      name = "Triple Buffering",    desc = L["Disabled"] },
            { cvar = "TextureFilteringMode",  optimal = "5",      name = "Texture Filtering",   desc = "16x Anisotropic" },
            { cvar = "shadowRt",             optimal = "0",      name = "Ray Traced Shadows",  desc = L["Disabled"] },
            { cvar = "ResampleQuality",       optimal = "3",      name = "Resample Quality",    desc = "FidelityFX SR 1.0" },
            { cvar = "GxApi",                optimal = "D3D12",  name = "Graphics API",        desc = "DirectX 12" },
            { cvar = "physicsLevel",          optimal = "1",      name = "Physics Integration", desc = "Player Only" },
        },
    },
    {
        id = "fps",
        name = "FPS Limits",
        cvars = {
            { cvar = "useTargetFPS",  optimal = "0",  name = "Target FPS",           desc = L["Disabled"] },
            { cvar = "useMaxFPSBk",   optimal = "1",  name = "Background FPS Toggle", desc = L["Enabled"] },
            { cvar = "maxFPSBk",      optimal = "60", name = "Background FPS",        desc = "60 FPS" },
        },
    },
    {
        id = "post",
        name = "Post Processing",
        cvars = {
            { cvar = "ResampleSharpness", optimal = "0.2", name = "Resample Sharpness", desc = "Slight sharpening" },
            { cvar = "ResampleAlwaysSharpen", optimal = "1", name = "Always Sharpen", desc = L["Enabled"] },
        },
    },
    {
        id = "network",
        name = "Network & Logging",
        cvars = {
            { cvar = "advancedCombatLogging", optimal = "1", name = "Advanced Combat Logging", desc = "Required for Warcraft Logs" },
            { cvar = "disableServerNagle", optimal = "1", name = "Disable Server Nagle", desc = "Reduces network latency" },
        },
    },
    {
        id = "cvar",
        name = "CVars",
        cvars = {
            { cvar = "AutoPushSpellToActionBar", optimal = "0", name = "Auto Push Spells to Action Bar", desc = L["Disabled"] },
            { cvar = "nameplateShowFriendlyClassColor", optimal = "1", name = "Class Color Names", desc = L["Enabled"] },
            { cvar = "UnitNameFriendlyPlayerName", optimal = "1", name = "Friendly Player Names", desc = "Show only player names" },
            { cvar = "SpellQueueWindow", optimal = "200", name = "Spell Queue Window", desc = "200ms" },
            { cvar = "nameplateStackingTypes", optimal = "AA", name = "Stacking Nameplates", desc = "Enemy Units" },
        },
    },
    {
        id = "cosmetic",
        name = "Cosmetic Effects",
        cvars = {
            { cvar = "ffxDeath", optimal = "0", name = "Death Effect", desc = L["Disabled"] },
            { cvar = "ffxGlow", optimal = "0", name = "Glow Effect", desc = L["Disabled"] },
            { cvar = "ffxNether", optimal = "0", name = "Nether Effect", desc = L["Disabled"] },
            { cvar = "ffxVenari", optimal = "0", name = "Venari Effect", desc = L["Disabled"] },
            { cvar = "ffxLingeringVenari", optimal = "0", name = "Lingering Venari Effect", desc = L["Disabled"] },
        },
    },
}

------------------------------------------------------------------------
-- Friendly display labels for CVar values
------------------------------------------------------------------------
local VALUE_LABELS = {
    renderScale = function(v)
        return string_format("%d%%", (tonumber(v) or 1) * 100)
    end,
    VSync = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    MSAAQuality = function(v)
        local t = { [0] = L["None"], [1] = "2x", [2] = "4x", [3] = "8x" }
        return t[tonumber(v)] or v
    end,
    LowLatencyMode = function(v)
        local t = { [0] = L["None"], [1] = "Built-In", [2] = "Reflex", [3] = "Reflex+Boost", [4] = "XeLL" }
        return t[tonumber(v)] or v
    end,
    ffxAntiAliasingMode = function(v)
        local t = { [0] = L["None"], [1] = "Image-Based", [2] = "Multisample", [4] = "CMAA2" }
        return t[tonumber(v)] or v
    end,
    graphicsShadowQuality = function(v)
        local t = { [0] = "Low", [1] = "Fair", [2] = "Good", [3] = "High", [4] = "Ultra" }
        return t[tonumber(v)] or v
    end,
    graphicsLiquidDetail = function(v)
        local t = { [0] = "Low", [1] = "Fair", [2] = "Good", [3] = "High" }
        return t[tonumber(v)] or v
    end,
    graphicsParticleDensity = function(v)
        local t = { [0] = L["Disabled"], [1] = "Low", [2] = "Fair", [3] = "Good", [4] = "High", [5] = "Ultra" }
        return t[tonumber(v)] or v
    end,
    graphicsSSAO = function(v)
        local t = { [0] = L["Disabled"], [1] = "Low", [2] = "Good", [3] = "High", [4] = "Ultra" }
        return t[tonumber(v)] or v
    end,
    graphicsDepthEffects = function(v)
        local t = { [0] = L["Disabled"], [1] = "Low", [2] = "Good", [3] = "High" }
        return t[tonumber(v)] or v
    end,
    graphicsComputeEffects = function(v)
        local t = { [0] = L["Disabled"], [1] = "Low", [2] = "Good", [3] = "High" }
        return t[tonumber(v)] or v
    end,
    graphicsOutlineMode = function(v)
        local t = { [1] = "Low", [2] = "High", [3] = "Ultra High" }
        return t[tonumber(v)] or v
    end,
    graphicsTextureResolution = function(v)
        local t = { [1] = "Low", [2] = "High", [3] = "Ultra" }
        return t[tonumber(v)] or v
    end,
    graphicsSpellDensity = function(v)
        local t = { [0] = "Essential", [1] = "Low", [2] = "Fair", [3] = "Good", [4] = "High", [5] = "Ultra" }
        return t[tonumber(v)] or v
    end,
    graphicsProjectedTextures = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    graphicsViewDistance = function(v) return "Level " .. ((tonumber(v) or 0) + 1) end,
    graphicsEnvironmentDetail = function(v) return "Level " .. ((tonumber(v) or 0) + 1) end,
    graphicsGroundClutter = function(v) return "Level " .. ((tonumber(v) or 0) + 1) end,
    GxMaxFrameLatency = function(v) return tonumber(v) == 3 and L["Enabled"] or L["Disabled"] end,
    TextureFilteringMode = function(v)
        local t = { [0] = "Bilinear", [1] = "Trilinear", [2] = "2x Aniso", [3] = "4x Aniso", [4] = "8x Aniso", [5] = "16x Aniso" }
        return t[tonumber(v)] or v
    end,
    shadowRt = function(v)
        local t = { [0] = L["Disabled"], [1] = "Low", [2] = "Good", [3] = "High", [4] = "Ultra" }
        return t[tonumber(v)] or v
    end,
    ResampleQuality = function(v)
        local t = { [0] = "Point", [1] = "Bilinear", [2] = "Bicubic", [3] = "FidelityFX SR 1.0" }
        return t[tonumber(v)] or v
    end,
    GxApi = function(v)
        local u = (v or ""):upper()
        if u == "D3D12" then return "DX12"
        elseif u == "D3D11" then return "DX11"
        elseif u == "OPENGL" then return "OpenGL"
        else return v end
    end,
    physicsLevel = function(v)
        local t = { [0] = L["None"], [1] = "Player Only", [2] = "Full" }
        return t[tonumber(v)] or v
    end,
    useTargetFPS = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    useMaxFPSBk = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    maxFPSBk = function(v) return v .. " FPS" end,
    ResampleSharpness = function(v) return tostring(v) end,
    SpellQueueWindow = function(v) return v .. "ms" end,
    UnitNameFriendlyPlayerName = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    nameplateShowFriendlyClassColor = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    nameplateStackingTypes = function(v)
        local t = { [""] = L["None"], ["AA"] = "Enemy Units", ["BB"] = "Friendly Units", ["CC"] = "Both" }
        return t[v] or v
    end,
    ResampleAlwaysSharpen = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    advancedCombatLogging = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    disableServerNagle = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    ffxDeath = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    ffxGlow = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    ffxNether = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    ffxVenari = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
    ffxLingeringVenari = function(v) return v == "1" and L["Enabled"] or L["Disabled"] end,
}

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------

--- Get the friendly label for a cvar value
function OPT:GetValueLabel(cvar, value)
    local fn = VALUE_LABELS[cvar]
    if fn then return fn(value) end
    return tostring(value)
end

--- Read current value of a cvar (safe)
function OPT:GetCurrentValue(cvar)
    local ok, val = pcall(_GetCVar, cvar)
    if ok and val and val ~= "" then return val end
    return nil
end

--- Check whether a cvar already matches its optimal value
function OPT:IsOptimal(cvar, optimal)
    local current = self:GetCurrentValue(cvar)
    if not current then return false end
    -- Case-insensitive comparison for string cvars like GxApi (d3d12 vs D3D12)
    local cn, on = tonumber(current), tonumber(optimal)
    if cn and on then
        -- Use tolerance for floating point cvars like ResampleSharpness
        return math_abs(cn - on) < 0.001
    end
    return tostring(current):upper() == tostring(optimal):upper()
end

--- Apply a single cvar. Saves previous value into separate SavedVariables for revert.
function OPT:ApplyCVar(cvar, value)
    -- Backup first
    local backup = GetBackupDB()
    if not backup.SavedSettings[cvar] then
        local current = self:GetCurrentValue(cvar)
        if current then
            backup.SavedSettings[cvar] = current
        end
    end
    local ok = pcall(_SetCVar, cvar, tostring(value))
    return ok
end

--- Revert a single cvar to its backed-up value
function OPT:RevertCVar(cvar)
    local backup = GetBackupDB()
    local saved = backup.SavedSettings[cvar]
    if not saved then return false end
    local ok = pcall(_SetCVar, cvar, tostring(saved))
    if ok then
        backup.SavedSettings[cvar] = nil
    end
    return ok
end

function OPT:HasBackup(cvar)
    local backup = GetBackupDB()
    return backup.SavedSettings[cvar] ~= nil
end

--- Apply every optimal cvar across all categories.
--- Preserves window mode so applying never changes fullscreen/windowed.
function OPT:OptimizeAll()
    -- Preserve display mode
    local displayBackup = {}
    for _, cv in ipairs({ "gxWindow", "gxMaximize" }) do
        local ok, val = pcall(_GetCVar, cv)
        if ok and val then displayBackup[cv] = val end
    end

    local applied, failed = 0, 0
    for _, cat in ipairs(self.Categories) do
        for _, entry in ipairs(cat.cvars) do
            if self:ApplyCVar(entry.cvar, entry.optimal) then
                applied = applied + 1
            else
                failed = failed + 1
            end
        end
    end

    -- Restore display mode
    for cv, val in pairs(displayBackup) do
        pcall(_SetCVar, cv, val)
    end

    local AE_ORANGE = "|cffff8800"
    local AE_GREEN  = "|cff00ff00"
    local AE_RESET  = "|r"
    print(AE_ORANGE .. "VXJediEssentials:|r " .. AE_GREEN .. applied .. " settings optimized." .. AE_RESET)
    if failed > 0 then
        print(AE_ORANGE .. "Warning:|r " .. failed .. " settings could not be applied.")
    end
end

--- Revert all backed-up cvars
function OPT:RevertAll()
    local backup = GetBackupDB()
    if not backup.SavedSettings or not next(backup.SavedSettings) then
        print("|cffff8800VXJediEssentials:|r No saved settings to revert.")
        return
    end

    local count, failed = 0, 0
    for cvar, val in pairs(backup.SavedSettings) do
        local ok = pcall(_SetCVar, cvar, tostring(val))
        if ok then
            backup.SavedSettings[cvar] = nil
            count = count + 1
        else
            failed = failed + 1
        end
    end

    print("|cffff8800VXJediEssentials:|r |cff00ff00" .. count .. " settings reverted.|r")
    if failed > 0 then
        print("|cffff8800Warning:|r " .. failed .. " settings could not be reverted.")
    end
end

function OPT:HasAnySavedSettings()
    local backup = GetBackupDB()
    return backup.SavedSettings and next(backup.SavedSettings) ~= nil
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function OPT:OnInitialize()
    -- Module does not need enable/disable cycling; it acts on demand
end


------------------------------------------------------------------------
-- Static popup
------------------------------------------------------------------------
StaticPopupDialogs["VXJEDI_OPTIMIZE_RELOAD"] = {
    text = "Settings applied. Some changes require a reload to take effect.\n\nReload now?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function() ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
