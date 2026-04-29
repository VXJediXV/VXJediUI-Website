-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- CDM Slash Commands
-- /cd always registers (toggles Blizzard Cooldown Manager settings panel)
-- /wa only registers if neither WeakAuras nor M33kAuras is loaded (avoids conflict)

local L = AE.L
local _G = _G

local function ShowCooldownViewerSettings()
    if InCombatLockdown() then return end
    local CooldownViewerSettings = _G.CooldownViewerSettings
    if not CooldownViewerSettings then return end

    if not CooldownViewerSettings:IsShown() then
        CooldownViewerSettings:Show()
    else
        CooldownViewerSettings:Hide()
    end
end

-- /cd always registers
SLASH_CDMSC1 = "/cd"
function SlashCmdList.CDMSC(msg, editbox)
    ShowCooldownViewerSettings()
end

-- /wa only registers if no aura addon is present.
-- We check via GetAddOnInfo wrapped in pcall — GetAddOnInfo throws an error
-- when the addon doesn't exist (rather than returning nil), so a missing
-- addon in the list would otherwise short-circuit the whole check.
local function IsAddOnInstalled(name)
    local ok, result = pcall(C_AddOns.GetAddOnInfo, name)
    return ok and result ~= nil
end

local function HasAuraAddon()
    return IsAddOnInstalled("WeakAuras")
        or IsAddOnInstalled("M33kAuras")
        or IsAddOnInstalled("M33kAurasOptions")
end

if not HasAuraAddon() then
    SLASH_CDMSCWA1 = "/wa"
    function SlashCmdList.CDMSCWA(msg, editbox)
        ShowCooldownViewerSettings()
    end
end

-- SetPITarget global function
-- Mouseover a friendly target and run /run SetPITarget() to update the PI macro
-- Uses character-specific macros (index MAX_ACCOUNT_MACROS+1 and above)
_G.SetPITarget = function()
    if InCombatLockdown() then return end
    local n = UnitName("mouseover") or ""

    -- Look up character-specific macro slot directly (second arg true = per-character)
    local idx = GetMacroIndexByName("PI", true)
    if not idx or idx == 0 then
        AE:Print("PI macro not found in character-specific slots")
        return
    end

    EditMacro(idx, nil, nil,
        "#showtooltip\n/cast [@mouseover,help,nodead][@" .. n .. ",exists,nodead][] Power Infusion\n/use 13\n/use Ancestral Call\n/use Vampiric Embrace\n/use item:241308\n/use item:245898\n/use item:241308\n/use Fire-Eater's Vial")
    AE:Print("PI Updated to " .. n)
end
