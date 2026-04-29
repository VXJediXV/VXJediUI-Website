-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials
local L = AE.L
if not VXJediEssentials then
    error("CursorCircle: Addon object not initialized. Check file load order!")
    return
end

---@class CursorCircle: AceModule, AceEvent-3.0
local CC = VXJediEssentials:NewModule("CursorCircle", "AceEvent-3.0")

local CreateFrame = CreateFrame
local UIParent = UIParent
local GetCursorPosition = GetCursorPosition

local TEXTURE = "Interface\\AddOns\\VXJediEssentials\\Media\\CursorCircles\\Circle"
local DEFAULT_COLOR = { 1, 1, 1, 0.8 }

function CC:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.CursorCircle
end

function CC:OnInitialize()
    self:UpdateDB()
    self.cachedScale = 1
    self:SetEnabledState(false)
end

-- File-level OnUpdate handler — references DC.cachedScale and the captured frame
local function CursorFollowOnUpdate(frame)
    local x, y = GetCursorPosition()
    local scale = CC.cachedScale
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

function CC:CreateCircle()
    if self.circleFrame then return end

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetSize(80, 80)
    frame:SetPoint("CENTER")
    frame:SetMouseClickEnabled(false)

    frame.tex = frame:CreateTexture(nil, "OVERLAY")
    frame.tex:SetAllPoints()
    frame.tex:SetTexture(TEXTURE)
    frame.tex:SetVertexColor(1, 1, 1, 0.8)

    frame:SetScript("OnUpdate", CursorFollowOnUpdate)

    self.circleFrame = frame
    self.cachedScale = UIParent:GetEffectiveScale()
end

function CC:OnUIScaleChanged()
    self.cachedScale = UIParent:GetEffectiveScale()
end

function CC:ApplySettings()
    self:CreateCircle()
    local size = (self.db.Size or 40) * 2
    self.circleFrame:SetSize(size, size)

    local c = self.db.Color or DEFAULT_COLOR
    self.circleFrame.tex:SetVertexColor(c[1], c[2], c[3], c[4] or 0.8)

    if self.db.Enabled then
        self.circleFrame:Show()
    else
        self.circleFrame:Hide()
    end
end

function CC:OnEnable()
    self:ApplySettings()
    self:RegisterEvent("UI_SCALE_CHANGED", "OnUIScaleChanged")
end

function CC:OnDisable()
    self:UnregisterAllEvents()
    if self.circleFrame then
        self.circleFrame:Hide()
    end
end
