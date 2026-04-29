-- VXJediEssentials — Stance Text Display
-- Displays configurable text labels for Warrior stances and Paladin auras.
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials
local L = AE.L
if not VXJediEssentials then return end

---@class StanceText: AceModule, AceEvent-3.0
local ST = VXJediEssentials:NewModule("StanceText", "AceEvent-3.0")

-- Localization
local GetShapeshiftForm = GetShapeshiftForm
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local UnitClass = UnitClass
local AuraUtil = AuraUtil
local issecretvalue = issecretvalue
local tostring = tostring
local ipairs = ipairs

-- Paladin aura spell IDs (constant)
local PALADIN_AURAS = { 465, 317920, 32223 }

------------------------------------------------------------------------
-- Aura scanning (upvalue-based, zero closures)
------------------------------------------------------------------------
local _scan_hasBuff = false
local _scan_targetSpellId = nil

local function _PlayerHasBuffCallback(auraInfo)
    if not auraInfo or not auraInfo.spellId then return false end
    if issecretvalue(auraInfo.spellId) then return false end
    if auraInfo.spellId == _scan_targetSpellId then
        _scan_hasBuff = true
        return true
    end
    return false
end

local function PlayerHasBuff(spellId)
    if not spellId then return false end
    _scan_hasBuff = false
    _scan_targetSpellId = spellId
    AuraUtil.ForEachAura("player", "HELPFUL", nil, _PlayerHasBuffCallback, true)
    return _scan_hasBuff
end

------------------------------------------------------------------------
-- DB / Init
------------------------------------------------------------------------
function ST:UpdateDB()
    self.db = AE.db.profile.StanceText
end

function ST:OnInitialize()
    self:UpdateDB()
    local _, class = UnitClass("player")
    self.playerClass = class
    self.isPreview = false
    self.stanceTextFrame = nil
    self._lastStanceKey = nil
    self._lastText = nil
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Stance Text Frame
------------------------------------------------------------------------
function ST:CreateStanceTextFrame()
    if self.stanceTextFrame then return end
    local textDb = self.db.StanceText

    local frame = AE:CreateTextFrame(UIParent, 200, 30, {
        name = "AE_StanceTextDisplay",
    })
    AE:ApplyFramePosition(frame, textDb.Position, textDb)
    AE:ApplyFontSettings(frame, textDb, nil)

    local textPoint = AE:GetTextPointFromAnchor(textDb.Position.AnchorFrom)
    local textJustify = AE:GetTextJustifyFromAnchor(textDb.Position.AnchorFrom)
    frame.text:ClearAllPoints()
    frame.text:SetPoint(textPoint, frame, textPoint, 0, 0)
    frame.text:SetJustifyH(textJustify)
    frame.text:SetTextColor(1, 1, 1, 1)

    frame:Hide()
    self.stanceTextFrame = frame
end

------------------------------------------------------------------------
-- Update display
------------------------------------------------------------------------
function ST:UpdateStanceTextDisplay()
    if not self.db then return end
    local textDb = self.db.StanceText

    if not textDb.Enabled then
        if self.stanceTextFrame then self.stanceTextFrame:Hide() end
        return
    end

    -- Only show for warrior/paladin
    local playerClass = self.playerClass
    if playerClass ~= "WARRIOR" and playerClass ~= "PALADIN" then
        if self.stanceTextFrame then self.stanceTextFrame:Hide() end
        return
    end

    if not self.stanceTextFrame then self:CreateStanceTextFrame() end

    -- Determine current stance/aura
    local currentSpellId
    local currentForm = GetShapeshiftForm()
    if currentForm > 0 then
        local _, _, _, formSpellId = GetShapeshiftFormInfo(currentForm)
        currentSpellId = formSpellId
    end

    if playerClass == "PALADIN" then
        for _, auraId in ipairs(PALADIN_AURAS) do
            if PlayerHasBuff(auraId) then
                currentSpellId = auraId
                break
            end
        end
    end

    if not currentSpellId then
        self.stanceTextFrame:Hide()
        self._lastStanceKey = nil
        return
    end

    local classData = textDb[playerClass]
    if not classData then
        self.stanceTextFrame:Hide()
        self._lastStanceKey = nil
        return
    end

    local stanceKey = tostring(currentSpellId)
    local stanceSettings = classData[stanceKey]
    if not stanceSettings or not stanceSettings.Enabled then
        self.stanceTextFrame:Hide()
        self._lastStanceKey = nil
        return
    end

    -- Only update text/color if stance actually changed (avoid redundant SetText/SetTextColor)
    if self._lastStanceKey ~= stanceKey then
        local text = stanceSettings.Text or "Stance"
        local color = stanceSettings.Color or { 1, 1, 1, 1 }
        self.stanceTextFrame.text:SetText(text)
        self.stanceTextFrame.text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
        self._lastStanceKey = stanceKey
    end

    self.stanceTextFrame:Show()
end

------------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------------
function ST:OnShapeshift()
    self:UpdateStanceTextDisplay()
end

function ST:OnUnitAura(_, unit)
    if unit == "player" then
        self:UpdateStanceTextDisplay()
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function ST:OnEnable()
    if not self.db then return end

    self:CreateStanceTextFrame()

    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "OnShapeshift")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", "OnShapeshift")

    -- Paladin aura detection via UNIT_AURA
    if self.playerClass == "PALADIN" then
        self:RegisterEvent("UNIT_AURA", "OnUnitAura")
    end

    -- Initial display update
    self:UpdateStanceTextDisplay()
end

function ST:OnDisable()
    self:UnregisterAllEvents()
    if self.stanceTextFrame then self.stanceTextFrame:Hide() end
    self._lastStanceKey = nil
end

------------------------------------------------------------------------
-- Settings / Preview / Refresh
------------------------------------------------------------------------
function ST:ApplySettings()
    if not self.db then return end
    if not self.stanceTextFrame then self:CreateStanceTextFrame() end

    local textDb = self.db.StanceText
    if not textDb then return end

    AE:ApplyFontSettings(self.stanceTextFrame, textDb, nil)
    AE:ApplyFramePosition(self.stanceTextFrame, textDb.Position, textDb)

    local textPoint = AE:GetTextPointFromAnchor(textDb.Position.AnchorFrom)
    local textJustify = AE:GetTextJustifyFromAnchor(textDb.Position.AnchorFrom)
    self.stanceTextFrame.text:ClearAllPoints()
    self.stanceTextFrame.text:SetPoint(textPoint, self.stanceTextFrame, textPoint, 0, 0)
    self.stanceTextFrame.text:SetJustifyH(textJustify)

    -- Force re-evaluation since settings may have changed
    self._lastStanceKey = nil
    self:UpdateStanceTextDisplay()
end

function ST:ShowPreview()
    self.isPreview = true
    if not self.stanceTextFrame then self:CreateStanceTextFrame() end
    if not self.db then return end

    local textDb = self.db.StanceText
    if textDb and textDb.Enabled then
        AE:ApplyFontSettings(self.stanceTextFrame, textDb, nil)
        AE:ApplyFramePosition(self.stanceTextFrame, textDb.Position, textDb)
        self.stanceTextFrame.text:SetText("STANCE")
        self.stanceTextFrame.text:SetTextColor(1, 1, 1, 1)
        self.stanceTextFrame:Show()
    end
end

function ST:HidePreview()
    self.isPreview = false
    self._lastStanceKey = nil
    if self.db and self.db.StanceText and self.db.StanceText.Enabled then
        self:UpdateStanceTextDisplay()
    else
        if self.stanceTextFrame then self.stanceTextFrame:Hide() end
    end
end

function ST:Refresh()
    self:ApplySettings()
end
