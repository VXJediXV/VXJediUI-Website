-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Safety check
local L = AE.L
if not VXJediEssentials then
    error("PetTexts: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class PetTexts: AceModule, AceEvent-3.0
local PET = VXJediEssentials:NewModule("PetTexts", "AceEvent-3.0")

-- Localization
local UnitClass = UnitClass
local IsMounted = IsMounted
local UnitOnTaxi = UnitOnTaxi
local UnitInVehicle = UnitInVehicle
local UnitHasVehicleUI = UnitHasVehicleUI
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local UnitExists = UnitExists
local CreateFrame = CreateFrame
local GetPetActionInfo = GetPetActionInfo
local PetHasActionBar = PetHasActionBar
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local IsPlayerSpell = IsPlayerSpell
local C_Timer = C_Timer
local C_SpellBook = C_SpellBook
local C_UnitAuras = C_UnitAuras
local math_max = math.max

-- Tracked pet classes
local PET_CLASSES = {
    ["HUNTER"] = { summonSpellId = 883, reviveSpellId = 982, specId = nil },
    ["WARLOCK"] = { summonSpellId = 688, reviveSpellId = nil, specId = nil },
    ["DEATHKNIGHT"] = { summonSpellId = 46584, reviveSpellId = nil, specId = 252 },
    ["MAGE"] = { summonSpellId = 31687, reviveSpellId = nil, specId = 64 },
}

-- Constants
local UPDATE_DEBOUNCE = 0.15
local GRIMOIRE_OF_SACRIFICE = 196099
local SPECID_MM_HUNTER = 254
local TALENT_UNBREAKABLE_BOND = 466867
local TALENT_SPOTTERS_MARK = 466872

-- Pet status enum for internal tracking
local PET_STATUS = {
    NONE = 0,
    MISSING = 1,
    DEAD = 2,
    PASSIVE = 3,
}

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function IsPlayerMounted()
    return IsMounted() or UnitOnTaxi("player") or UnitInVehicle("player") or UnitHasVehicleUI("player")
end

local function IsPetOnPassive()
    if not UnitExists("pet") or not PetHasActionBar() then return false end
    for slot = 1, 10 do
        local name, _, isToken, isActive = GetPetActionInfo(slot)
        if isToken and name == "PET_MODE_PASSIVE" and isActive then return true end
    end
    return false
end

------------------------------------------------------------------------
-- Death tracking
------------------------------------------------------------------------
function PET:CheckAndUpdatePetDeathState()
    if UnitExists("pet") and not UnitIsDeadOrGhost("pet") then
        self.petDeathTracked = false
        return false
    end
    if UnitExists("pet") and UnitIsDeadOrGhost("pet") then
        self.petDeathTracked = true
        return true
    end
    if self.petDeathTracked then return true end
    return false
end

function PET:ResetPetDeathTracking()
    self.petDeathTracked = false
end

------------------------------------------------------------------------
-- Status check
------------------------------------------------------------------------
function PET:CheckPetStatus()
    local petInfo = self.petInfo
    if not petInfo then return PET_STATUS.NONE, nil, nil end
    if IsPlayerMounted() then return PET_STATUS.NONE, nil, nil end

    local specIndex = GetSpecialization()
    local specID = GetSpecializationInfo(specIndex)

    -- MM Hunter with Unbreakable Bond / Spotter's Mark replaces the pet
    if specID == SPECID_MM_HUNTER
        and (IsPlayerSpell(TALENT_UNBREAKABLE_BOND) or IsPlayerSpell(TALENT_SPOTTERS_MARK)) then
        return PET_STATUS.NONE, nil, nil
    end

    -- Spec restriction (DK Unholy, Mage Frost)
    if petInfo.specId and specIndex and specID ~= petInfo.specId then
        return PET_STATUS.NONE, nil, nil
    end

    if not C_SpellBook.IsSpellKnown(petInfo.summonSpellId) then
        return PET_STATUS.NONE, nil, nil
    end

    -- Priority: Dead > Passive > Missing
    if self:CheckAndUpdatePetDeathState() then
        return PET_STATUS.DEAD, self.db.PetDead, self.db.DeadColor
    end

    if UnitExists("pet") then
        if IsPetOnPassive() then
            return PET_STATUS.PASSIVE, self.db.PetPassive, self.db.PassiveColor
        end
        return PET_STATUS.NONE, nil, nil
    end

    -- Pet missing — check Grimoire of Sacrifice (Warlock)
    local sacrificeAura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID(GRIMOIRE_OF_SACRIFICE)
    if sacrificeAura then return PET_STATUS.NONE, nil, nil end

    return PET_STATUS.MISSING, self.db.PetMissing, self.db.MissingColor
end

------------------------------------------------------------------------
-- Display creation & update
------------------------------------------------------------------------
function PET:CreatePetTexts()
    if self.frame then return end
    local frame = CreateFrame("Frame", "AE_PetTextsFrame", UIParent)
    frame:SetSize(200, 50)

    local text = frame:CreateFontString(nil, "OVERLAY")
    local fontPath = AE:GetFontPath(self.db.FontFace)
    text:SetFont(fontPath, self.db.FontSize, "")
    text:SetTextColor(1, 0.82, 0, 1)
    text:ClearAllPoints()
    text:SetPoint("CENTER", frame, "CENTER", 0, 0)

    self.frame = frame
    self.frame.text = text
    self.text = text

    local width, height = math_max(text:GetWidth(), 170), math_max(text:GetHeight(), 18)
    frame:SetSize(width + 5, height + 5)

    self.frame:Hide()
end

function PET:UpdatePetText()
    if not self.frame then return end
    local _, message, color = self:CheckPetStatus()

    if message and color then
        self.text:SetText(message)
        self.text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

-- Debounced update — burst-tolerant
function PET:QueueUpdate()
    if self._updatePending then return end
    self._updatePending = true
    C_Timer.After(UPDATE_DEBOUNCE, function()
        self._updatePending = false
        self:UpdatePetText()
    end)
end

------------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------------
function PET:OnUnitPet(_, unit)
    if unit ~= "player" then return end
    -- Check immediately whether the pet is now alive
    if UnitExists("pet") and not UnitIsDeadOrGhost("pet") then
        self:ResetPetDeathTracking()
    end
    self:QueueUpdate()
end

function PET:OnPlayerEnteringWorld()
    self:QueueUpdate()
end

function PET:OnPetBarUpdate()
    self:QueueUpdate()
end

------------------------------------------------------------------------
-- DB / Init
------------------------------------------------------------------------
function PET:UpdateDB()
    self.db = AE.db.profile.PetTexts
end

function PET:OnInitialize()
    self:UpdateDB()
    local _, class = UnitClass("player")
    self.petInfo = PET_CLASSES[class]
    self.petDeathTracked = false
    self._updatePending = false
    self.isPreview = false
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function PET:OnEnable()
    if not self.db.Enabled then return end
    if not self.petInfo then return end

    self:CreatePetTexts()
    self:ApplySettings()

    self:RegisterEvent("UNIT_PET", "OnUnitPet")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "QueueUpdate")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("SPELLS_CHANGED", "QueueUpdate")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "QueueUpdate")
    self:RegisterEvent("UNIT_DIED", "QueueUpdate")
    self:RegisterEvent("PET_BAR_UPDATE", "OnPetBarUpdate")

    -- Initial check
    self:UpdatePetText()
end

function PET:OnDisable()
    self:UnregisterAllEvents()
    if self.frame then self.frame:Hide() end
    self._updatePending = false
end

------------------------------------------------------------------------
-- Preview / Settings
------------------------------------------------------------------------
function PET:ShowPreview(state)
    if not self.frame then self:CreatePetTexts() end

    self.isPreview = true
    self.previewState = state or "missing"

    local previewText, previewColor
    if self.previewState == "dead" then
        previewText = self.db.PetDead or L["PET DEAD"]
        previewColor = self.db.DeadColor or { 1, 0.2, 0.2, 1 }
    elseif self.previewState == "passive" then
        previewText = self.db.PetPassive or L["PET PASSIVE"]
        previewColor = self.db.PassiveColor or { 0.3, 0.7, 1, 1 }
    else
        previewText = self.db.PetMissing or L["PET MISSING"]
        previewColor = self.db.MissingColor or { 1, 0.82, 0, 1 }
    end

    self.text:SetText(previewText)
    self.text:SetTextColor(previewColor[1], previewColor[2], previewColor[3], previewColor[4] or 1)
    self.frame:Show()
end

function PET:HidePreview()
    self.isPreview = false
    if self.db.Enabled then
        self:UpdatePetText()
    else
        if self.frame then self.frame:Hide() end
    end
end

function PET:ApplySettings()
    if not self.frame then return end
    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)
    AE:ApplyFontToText(self.text, self.db.FontFace, self.db.FontSize, self.db.FontOutline, {})

    if self.isPreview then
        self:ShowPreview(self.previewState)
    end
end
