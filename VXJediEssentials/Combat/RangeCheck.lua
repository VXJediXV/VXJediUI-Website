-- VXJediEssentials Range Check Display
---@class AE
local AE = select(2, ...)

if not VXJediEssentials then return end

---@class RangeCheck: AceModule, AceEvent-3.0
local RC = VXJediEssentials:NewModule("RangeCheck", "AceEvent-3.0")

local CreateFrame = CreateFrame
local UIParent = UIParent
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitCanAssist = UnitCanAssist
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitAffectingCombat = UnitAffectingCombat
local math_min = math.min

local RangeLib

-- Constants
local TICK_RATE = 0.1
local MAX_RANGE_FOR_COLOR = 40

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function HasAttackableTarget()
    if not UnitExists("target") then return false end
    if not UnitCanAttack("player", "target") then return false end
    if UnitIsDeadOrGhost("target") then return false end
    return true
end

local function HasValidTarget()
    if not UnitExists("target") then return false end
    if UnitIsDeadOrGhost("target") then return false end
    if not UnitCanAttack("player", "target") and not UnitCanAssist("player", "target") then return false end
    return true
end

local function GetRangeColor(minRange, db)
    if not db.UseRangeColors or not minRange then
        local c = db.TextColor or { 1, 1, 1, 1 }
        return c[1], c[2], c[3]
    end
    local pct = math_min(minRange / MAX_RANGE_FOR_COLOR, 1)
    if pct < 0.5 then
        return pct * 2, 1, 0
    else
        return 1, 1 - (pct - 0.5) * 2, 0
    end
end

------------------------------------------------------------------------
-- Frame creation
------------------------------------------------------------------------
function RC:CreateFrame()
    if self.frame then return end

    local frame = CreateFrame("Frame", "AE_RangeCheckFrame", UIParent)
    frame:SetSize(100, 30)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame:Hide()

    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(AE.FONT or STANDARD_TEXT_FONT, 18, "OUTLINE")
    label:SetPoint("CENTER")

    self.frame = frame
    self.label = label
end

------------------------------------------------------------------------
-- Tick logic (the actual range check)
------------------------------------------------------------------------
function RC:Tick()
    local db = self.db
    if not db or not db.Enabled then
        self.frame:Hide()
        return
    end

    if not RangeLib then
        RangeLib = LibStub("LibRangeCheck-3.0", true)
        if not RangeLib then
            self.frame:Hide()
            return
        end
    end

    local hasTarget = db.IncludeFriendlies and HasValidTarget() or HasAttackableTarget()
    if not hasTarget then
        self.frame:Hide()
        return
    end

    if db.CombatOnly and not self.inCombat then
        self.frame:Hide()
        return
    end

    local minRange, maxRange = RangeLib:GetRange("target")
    local suffix = db.HideSuffix and "" or " yd"
    if minRange and maxRange then
        self.label:SetText(minRange .. "-" .. maxRange .. suffix)
    elseif maxRange then
        self.label:SetText("0-" .. maxRange .. suffix)
    elseif minRange then
        self.label:SetText(minRange .. "+" .. suffix)
    else
        self.label:SetText("--" .. suffix)
    end
    self.label:SetTextColor(GetRangeColor(minRange, db))
    self.frame:Show()
end

------------------------------------------------------------------------
-- Ticker lifecycle
------------------------------------------------------------------------
function RC:StartTicker()
    if not self.frame then return end
    self.tickAcc = 0
    if not self.frame:GetScript("OnUpdate") then
        self.frame:SetScript("OnUpdate", function(_, elapsed)
            self.tickAcc = self.tickAcc + elapsed
            if self.tickAcc < TICK_RATE then return end
            self.tickAcc = 0
            self:Tick()
        end)
    end
end

function RC:StopTicker()
    if not self.frame then return end
    self.frame:SetScript("OnUpdate", nil)
    self.frame:Hide()
end

-- Force the next tick to fire immediately
function RC:ForceTick()
    self.tickAcc = TICK_RATE
end

------------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------------
function RC:OnEnterCombat()
    self.inCombat = true
    self:ForceTick()
end

function RC:OnExitCombat()
    self.inCombat = false
    self:ForceTick()
end

function RC:OnTargetChanged()
    self:ForceTick()
end

------------------------------------------------------------------------
-- Module lifecycle
------------------------------------------------------------------------
function RC:UpdateDB()
    self.db = AE.db.profile.RangeCheck
end

function RC:OnInitialize()
    self:UpdateDB()
    self.tickAcc = 0
    self.inCombat = false
    self:SetEnabledState(false)
end

function RC:OnEnable()
    if not self.db.Enabled then return end
    self:CreateFrame()
    self:ApplySettings()

    self.inCombat = UnitAffectingCombat("player")
    if not RangeLib then
        RangeLib = LibStub("LibRangeCheck-3.0", true)
    end

    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnExitCombat")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnTargetChanged")

    self:StartTicker()
end

function RC:OnDisable()
    self:UnregisterAllEvents()
    self:StopTicker()
end

------------------------------------------------------------------------
-- Settings / Preview
------------------------------------------------------------------------
function RC:ApplySettings()
    local db = self.db
    if not db or not self.frame then return end
    AE:ApplyFontToText(self.label, db.FontFace, db.FontSize, db.FontOutline, db.FontShadow)
    AE:ApplyFramePosition(self.frame, db.Position, db)
end

function RC:ApplyPosition()
    if not self.frame then return end
    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)
end

function RC:ShowPreview()
    if not self.frame then self:CreateFrame() end
    self:ApplySettings()
    self:StopTicker()
    self.label:SetText("10-15 yd")
    self.label:SetTextColor(0.5, 1, 0, 1)
    self.frame:Show()
end

function RC:HidePreview()
    if self.db and self.db.Enabled then
        self:StartTicker()
    else
        self:StopTicker()
    end
end

function RC:Refresh()
    self:ApplySettings()
end
