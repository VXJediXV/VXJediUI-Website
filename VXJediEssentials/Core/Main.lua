-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Localization Setup
local IsInInstance = IsInInstance
local LibStub = LibStub
local Theme = AE.Theme

local aceAddon = LibStub("AceAddon-3.0")

-- Constants
local DEFAULT_PROFILE = "Default"

-- Create the main addon object
---@class VXJediEssentials : AceAddon-3.0, AceEvent-3.0, AceHook-3.0
local VXJediEssentials = aceAddon:NewAddon("VXJediEssentials", "AceEvent-3.0", "AceHook-3.0")
_G.VXJediEssentials = VXJediEssentials

-- Encounter state
AE.encounterActive = false

-- OnInitialize: Called when the addon is initialized
function VXJediEssentials:OnInitialize()
    local defaults = AE:GetDefaultDB()
    if not defaults then
        defaults = { profile = {} }
    end
    AE.db = LibStub("AceDB-3.0"):New("VXJediEssentialsDB", defaults, true)
    if AE.LDS then
        AE.LDS:EnhanceDatabase(AE.db, "VXJediEssentials")
    end

    if AE.db.global and AE.db.global.UseGlobalProfile then
        local profileName = AE.db.global.GlobalProfile or DEFAULT_PROFILE
        AE.db:SetProfile(profileName)
    end

    -- Profile change callbacks
    AE.db.RegisterCallback(AE, "OnProfileChanged", function()
        if AE.ProfileManager then
            AE.ProfileManager:RefreshAllModules()
        end
    end)
    AE.db.RegisterCallback(AE, "OnProfileCopied", function()
        if AE.ProfileManager then
            AE.ProfileManager:RefreshAllModules()
        end
    end)
    AE.db.RegisterCallback(AE, "OnProfileReset", function()
        if AE.ProfileManager then
            AE.ProfileManager:RefreshAllModules()
        end
    end)

end
local function OnEncounterEnd()
    local _, instanceType = IsInInstance()
    if instanceType == "raid" and AE.encounterActive then
        AE.encounterActive = false
    end
end

local function OnEncounterStart()
    local _, instanceType = IsInInstance()
    if instanceType == "raid" then
        AE.encounterActive = true
    end
end

local function OnPlayerEnteringWorld()
    -- Automatically refresh all AceAddon modules
    for name, module in VXJediEssentials:IterateModules() do
        if module:IsEnabled() and module.ApplySettings then
            module:ApplySettings()
        end
    end
    -- Delayed re-anchor to catch ElvUI frames that haven't settled yet
    C_Timer.After(0.3, function()
        for name, module in VXJediEssentials:IterateModules() do
            if module:IsEnabled() and module.ApplyPosition then
                module:ApplyPosition()
            end
        end
    end)
end

-- OnEnable: Called when the addon is enabled
function VXJediEssentials:OnEnable()
    if AE.RefreshTheme then AE:RefreshTheme() end
    if AE.Init then AE:Init() end

    -- Automatically enable modules based on their saved settings
    for name, module in self:IterateModules() do
        if module.db and module.db.Enabled then
            self:EnableModule(name)
        end
    end

    -- Event Registration
    self:RegisterEvent("ENCOUNTER_END", OnEncounterEnd)
    self:RegisterEvent("ENCOUNTER_START", OnEncounterStart)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
end
