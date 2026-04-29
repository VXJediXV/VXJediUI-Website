-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Safety check
local L = AE.L
if not VXJediEssentials then
    error("HuntersMark: Addon object not initialized. Check file load order!")
    return
end

-- Only load for Hunters — skip entire module for other classes
local _, playerClass = UnitClass("player")
if playerClass ~= "HUNTER" then return end

-- Create module
---@class HuntersMark: AceModule, AceEvent-3.0
local HUNTMARK = VXJediEssentials:NewModule("HuntersMark", "AceEvent-3.0")

-- Localization
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitIsBossMob = UnitIsBossMob
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local C_NamePlate = C_NamePlate
local AuraUtil = AuraUtil
local issecretvalue = issecretvalue
local next = next
local wipe = wipe
local type = type

-- Constants
local SPELL_ID = 257284 -- Hunter's Mark
local NAMEPLATE_UNITS = {
    "nameplate1", "nameplate2", "nameplate3", "nameplate4", "nameplate5",
    "nameplate6", "nameplate7", "nameplate8", "nameplate9", "nameplate10",
    "target",
}

------------------------------------------------------------------------
-- Aura scanning (zero closure allocation per scan)
------------------------------------------------------------------------
local _hm_hasMarkNow = false
local function _HunterMarkAuraCallback(auraInfo)
    if not auraInfo or not auraInfo.spellId then return false end
    if issecretvalue(auraInfo.spellId) then return false end
    if auraInfo.spellId == SPELL_ID and auraInfo.sourceUnit == "player" then
        _hm_hasMarkNow = true
        return true
    end
end

------------------------------------------------------------------------
-- DB / Init
------------------------------------------------------------------------
function HUNTMARK:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.HuntersMark
end

function HUNTMARK:OnInitialize()
    self:UpdateDB()
    self.markedUnits = {}
    self.scanningActive = false
    self.isPreview = false
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function IsInRaidInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "raid"
end

------------------------------------------------------------------------
-- Frame creation
------------------------------------------------------------------------
function HUNTMARK:CreateWarningFrame()
    if self.frame then return end

    local frame = CreateFrame("Frame", "AE_HuntersMarkWarning", UIParent)
    frame:SetSize(200, 40)

    -- Center text
    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont(AE.FONT, self.db.FontSize or 22, "")
    text:SetPoint("CENTER")
    text:SetText(L["MISSING MARK"])
    frame.text = text

    -- Left/right icons
    local iconSize = self.db.FontSize or 22
    local leftIcon = AE:CreateIconFrame(frame, iconSize, { zoom = 0.3 })
    leftIcon:SetPoint("RIGHT", text, "LEFT", -4, 0)
    frame.leftIcon = leftIcon

    local rightIcon = AE:CreateIconFrame(frame, iconSize, { zoom = 0.3 })
    rightIcon:SetPoint("LEFT", text, "RIGHT", 4, 0)
    frame.rightIcon = rightIcon

    frame:Hide()
    self.frame = frame
    self:ApplySettings()
end

------------------------------------------------------------------------
-- Display update
------------------------------------------------------------------------
function HUNTMARK:UpdateWarningDisplay()
    if self.isPreview then return end
    if not self.frame then return end

    if not next(self.markedUnits) then
        self.frame:Hide()
        return
    end

    -- If any tracked unit has the mark, hide the warning
    for _, hasAura in next, self.markedUnits do
        if hasAura then
            self.frame:Hide()
            return
        end
    end

    -- Boss visible but missing mark
    self.frame:Show()
end

function HUNTMARK:CheckUnitForMark(unit)
    if InCombatLockdown() then return end
    if not unit or not UnitExists(unit) or not UnitIsBossMob(unit) then return end

    _hm_hasMarkNow = false
    AuraUtil.ForEachAura(unit, "HARMFUL", nil, _HunterMarkAuraCallback, true)

    self.markedUnits[unit] = _hm_hasMarkNow
    self:UpdateWarningDisplay()
end

function HUNTMARK:RescanAllNameplates()
    wipe(self.markedUnits)
    for _, namePlate in next, C_NamePlate.GetNamePlates() do
        if namePlate.unitToken then
            self:CheckUnitForMark(namePlate.unitToken)
        end
    end
    self:UpdateWarningDisplay()
end

------------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------------
function HUNTMARK:OnNamePlateAdded(_, unit)
    if not IsInRaidInstance() then return end
    if InCombatLockdown() then return end
    if type(unit) ~= "string" then return end
    self:CheckUnitForMark(unit)
end

function HUNTMARK:OnNamePlateRemoved(_, unit)
    if not IsInRaidInstance() then return end
    if type(unit) ~= "string" then return end
    self.markedUnits[unit] = nil
    self:UpdateWarningDisplay()
end

function HUNTMARK:OnUnitAura(_, unit)
    if not IsInRaidInstance() then return end
    if InCombatLockdown() then return end
    if type(unit) ~= "string" then return end
    self:CheckUnitForMark(unit)
end

function HUNTMARK:OnEnterCombat()
    if not IsInRaidInstance() then return end
    if self.frame then self.frame:Hide() end
end

function HUNTMARK:OnLeaveCombat()
    if not IsInRaidInstance() then return end
    self:RescanAllNameplates()
end

function HUNTMARK:OnPlayerEnteringWorld()
    -- Re-evaluate whether we should be scanning based on the new instance type
    self:SetScanningActive(IsInRaidInstance())
end

------------------------------------------------------------------------
-- Scanning lifecycle
------------------------------------------------------------------------
function HUNTMARK:CreateAuraFrame()
    if self.auraFrame then return end
    -- Dedicated frame for UNIT_AURA with engine-level unit filtering.
    -- AceEvent doesn't expose RegisterUnitEvent, and filtering at the engine
    -- level is much cheaper than receiving every UNIT_AURA fire and filtering
    -- in Lua.
    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, _, unit)
        HUNTMARK:OnUnitAura(nil, unit)
    end)
    self.auraFrame = frame
end

function HUNTMARK:SetScanningActive(active)
    if active == self.scanningActive then return end

    if active then
        self:CreateAuraFrame()
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "OnNamePlateAdded")
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "OnNamePlateRemoved")
        self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
        self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeaveCombat")
        -- Engine-level unit filtering — only fires for the listed units
        self.auraFrame:RegisterUnitEvent("UNIT_AURA", unpack(NAMEPLATE_UNITS))
    else
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:UnregisterEvent("PLAYER_REGEN_DISABLED")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if self.auraFrame then
            self.auraFrame:UnregisterEvent("UNIT_AURA")
        end
        wipe(self.markedUnits)
        if self.frame then self.frame:Hide() end
    end

    self.scanningActive = active
end

------------------------------------------------------------------------
-- Settings / lifecycle
------------------------------------------------------------------------
function HUNTMARK:ApplySettings()
    if not self.db or not self.frame then return end

    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)

    local text = self.frame.text
    if text then
        local color = self.db.Color or { 1, 0, 0, 1 }
        AE:ApplyFontToText(text, self.db.FontFace, self.db.FontSize or 22, self.db.FontOutline, {})
        text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
    end

    local texture = C_Spell.GetSpellTexture(SPELL_ID)
    if self.frame.leftIcon then
        self.frame.leftIcon:SetIconSize(self.db.FontSize or 22)
        self.frame.leftIcon.icon:SetTexture(texture)
    end
    if self.frame.rightIcon then
        self.frame.rightIcon:SetIconSize(self.db.FontSize or 22)
        self.frame.rightIcon.icon:SetTexture(texture)
    end
end

function HUNTMARK:OnEnable()
    if not self.db.Enabled then return end

    self:CreateWarningFrame()

    -- Always listen for PEW so we can react to instance changes
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

    -- If already in a raid, start scanning immediately
    if IsInRaidInstance() then
        self:SetScanningActive(true)
    end
end

function HUNTMARK:OnDisable()
    self:UnregisterAllEvents()
    if self.auraFrame then
        self.auraFrame:UnregisterEvent("UNIT_AURA")
    end
    self.scanningActive = false
    if self.frame then
        self.frame:Hide()
    end
    wipe(self.markedUnits)
    self.isPreview = false
end

------------------------------------------------------------------------
-- Preview
------------------------------------------------------------------------
function HUNTMARK:ShowPreview()
    if not self.frame then self:CreateWarningFrame() end
    self.isPreview = true
    self.frame:SetAlpha(1)
    self.frame:Show()
    self:ApplySettings()
end

function HUNTMARK:HidePreview()
    self.isPreview = false
    if not self.frame then return end
    self.frame:Hide()

    if not self.db.Enabled then return end

    if IsInRaidInstance() and not self.scanningActive then
        self:SetScanningActive(true)
    end
    if self.scanningActive then
        self:RescanAllNameplates()
    end
end
