-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Safety check
local L = AE.L
if not VXJediEssentials then
    error("CombatCross: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class CombatCross: AceModule, AceEvent-3.0
local CC = VXJediEssentials:NewModule("CombatCross", "AceEvent-3.0")

-- Localization
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local UIFrameFadeIn = UIFrameFadeIn
local UIParent = UIParent

-- Constants
local FONT_SIZE_MULTIPLIER = 2

-- Module state
CC.frame = nil
CC.text = nil
CC.previewActive = false
CC.combatActive = false

-- Update db
function CC:UpdateDB()
    self.db = AE.db.profile.CombatCross
end

-- Module init
function CC:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

-- Module OnEnable
function CC:OnEnable()
    if not self.db.Enabled then return end
    self:CreateFrame()
    self:ApplySettings()

    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnExitCombat")
end

-- Module OnDisable
function CC:OnDisable()
    self:UnregisterAllEvents()
    if self.frame then self.frame:Hide() end
end

-- Get color based on color mode
function CC:GetColor()
    local colorMode = self.db.ColorMode or "custom"
    return AE:GetAccentColor(colorMode, self.db.Color)
end

-- Create the combat cross frame
function CC:CreateFrame()
    if self.frame then return end

    self.frame = CreateFrame("Frame", "AE_CombatCrossFrame", UIParent)
    self.frame:SetSize(30, 30)
    self.frame:SetPoint("CENTER")
    self.frame:SetFrameStrata("HIGH")
    self.frame:SetFrameLevel(100)
    self.frame:Hide()

    -- Create cross text
    local fontSize = self.db.Thickness * FONT_SIZE_MULTIPLIER
    self.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.text:SetPoint("CENTER")
    self.text:SetFont(AE.FONT, fontSize, "")
    self.text:SetText("+")

    self.text:ClearAllPoints()
    self.text:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
end

-- Apply settings from profile
function CC:ApplySettings()
    if not self.frame or not self.text then return end

    -- Apply position & strata
    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)

    -- Apply font
    local fontSize = self.db.Thickness * FONT_SIZE_MULTIPLIER
    local outline = self.db.Outline and "OUTLINE" or ""
    self.text:SetFont(AE.FONT, fontSize, outline)

    -- Apply color
    local r, g, b, a = self:GetColor()
    self.text:SetTextColor(r, g, b, a)
end

-- Apply position
function CC:ApplyPosition()
    if not self.frame then return end
    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)
end

-- Show combat cross
function CC:Show(isPreview)
    if not self.frame then
        self:CreateFrame()
        self:ApplySettings()
    end
    if not self.frame then return end

    if isPreview then
        self.previewActive = true
    else
        self.combatActive = true
    end

    if self.previewActive or self.combatActive then
        if not self.frame:IsShown() then
            self.frame:Show()
            self.frame:SetAlpha(0)
            UIFrameFadeIn(self.frame, 0.3, 0, 1)
        end
    end
end

-- Hide combat cross
function CC:Hide(isPreview)
    if not self.frame then return end

    if isPreview then
        self.previewActive = false
    else
        self.combatActive = false
    end

    if not self.previewActive and not self.combatActive then
        self.frame:Hide()
    end
end

-- Preview support
function CC:ShowPreview()
    if InCombatLockdown() then return end
    self:Show(true)
end

function CC:HidePreview()
    if InCombatLockdown() then return end
    if not self.previewActive then return end
    self:Hide(true)
end

-- Combat events
function CC:OnEnterCombat()
    if not self.db.Enabled then return end
    self:Show(false)
end

function CC:OnExitCombat()
    if not self.db.Enabled then return end
    self:Hide(false)
end

-- Refresh
function CC:Refresh()
    self:ApplySettings()
end
