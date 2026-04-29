-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials
local L = AE.L
if not VXJediEssentials then
    error("SpellAlerts: Addon object not initialized. Check file load order!")
    return
end

---@class SpellAlerts: AceModule, AceEvent-3.0
local SA = VXJediEssentials:NewModule("SpellAlerts", "AceEvent-3.0")

local _SetCVar = SetCVar or C_CVar.SetCVar
local GetSpecialization = GetSpecialization

function SA:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.SpellAlerts
end

function SA:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

function SA:ApplyForCurrentSpec()
    local specIndex = GetSpecialization()
    if not specIndex or not self.db then return end

    local shown = self.db.EnabledSpecs and self.db.EnabledSpecs[specIndex]
    _SetCVar("displaySpellActivationOverlays", shown and "1" or "0")
end

function SA:OnEnable()
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "ApplyForCurrentSpec")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplyForCurrentSpec")
    self:ApplyForCurrentSpec()
end

function SA:OnDisable()
    self:UnregisterAllEvents()
    -- Restore overlays when disabled
    _SetCVar("displaySpellActivationOverlays", "1")
end

function SA:ApplySettings()
    self:ApplyForCurrentSpec()
end
