-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("CombatTimer: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class CombatTimer: AceModule, AceEvent-3.0
local CT = VXJediEssentials:NewModule("CombatTimer", "AceEvent-3.0")

-- Localization
local CreateFrame = CreateFrame
local GetTime = GetTime
local math_floor, math_max, math_min = math.floor, math.max, math.min
local string_format = string.format

-- Shared backdrop table (reused, never reallocated)
local SHARED_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

-- Cached values that only change when settings change
local cachedOpenBracket = "["
local cachedCloseBracket = "]"
local cachedRefreshRate = 0.25
local cachedFormat = "MM:SS"

-- Module state
CT.frame = nil
CT.text = nil
CT.startTime = 0
CT.running = false
CT.lastDisplayedText = ""
CT.isPreview = false

-- Store last combat duration
AE.lastCombatDuration = 0

-- Update db, used for profile changes
function CT:UpdateDB()
    self.db = AE.db.profile.CombatTimer
end

-- Module init
function CT:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

-- Format time based on cached settings
local function GetBrackets(style)
    if style == "round" then return "(", ")"
    elseif style == "none" then return "", ""
    else return "[", "]" end
end

local function FormatTime(total_seconds)
    local mins = math_floor(total_seconds / 60)
    local secs = math_floor(total_seconds % 60)

    if cachedFormat == "MM:SS:MS" then
        local frac = total_seconds - math_floor(total_seconds)
        local ms = math_floor(frac * 10)
        return string_format("%s%02d:%02d:%d%s", cachedOpenBracket, mins, secs, ms, cachedCloseBracket)
    end

    return string_format("%s%02d:%02d%s", cachedOpenBracket, mins, secs, cachedCloseBracket)
end

-- Create timer frame
function CT:CreateFrame()
    if self.frame then return end

    local frame = CreateFrame("Frame", "AE_CombatTimerFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(100, 25)
    AE:ApplyFramePosition(frame, self.db.Position, self.db)
    frame:SetFrameLevel(100)
    frame:EnableMouse(false)
    frame:SetMouseClickEnabled(false)
    frame:Hide()

    -- Create font string
    local text = frame:CreateFontString("AE_CombatTimerText", "OVERLAY")
    text:SetPoint("CENTER", frame, "CENTER", 0, 0)
    text:SetFont(AE.FONT, 14, "")
    text:SetText(cachedOpenBracket .. "00:00" .. cachedCloseBracket)
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")

    self.frame = frame
    frame.text = text
    self.text = text
end

-- Update frame size based on text
function CT:UpdateFrameSize()
    if not self.frame or not self.text then return end

    local backdrop = self.db.Backdrop or {}
    local bgWidth = backdrop.bgWidth or 100
    local bgHeight = backdrop.bgHeight or 10

    local w = math_floor((self.text:GetStringWidth() or 0) + bgWidth)
    local h = math_floor((self.text:GetStringHeight() or 0) + bgHeight)

    w = math_max(w, 40)
    h = math_max(h, 20)

    self.frame:SetSize(w, h)
end

-- Update timer text display
function CT:UpdateText()
    if not self.text then return end

    local total_time
    if self.running then
        total_time = self.startTime > 0 and (GetTime() - self.startTime) or 0
    else
        total_time = AE.lastCombatDuration or 0
    end

    local status = FormatTime(total_time)
    if status ~= self.lastDisplayedText then
        local oldLen = #self.lastDisplayedText
        self.text:SetText(status)
        self.lastDisplayedText = status
        -- Only resize when string length changes (e.g., 9:59 -> 10:00)
        if #status ~= oldLen then
            self:UpdateFrameSize()
        end
    end
end

-- Lightweight: only update text color (called on combat enter/exit)
function CT:UpdateCombatColor()
    if not self.text then return end
    local textColor = self.running and self.db.ColorInCombat or self.db.ColorOutOfCombat
    if textColor then
        self.text:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1, textColor[4] or 1)
    else
        self.text:SetTextColor(1, 1, 1, 1)
    end
end

-- Apply all settings from DB
function CT:ApplySettings()
    if not self.text then return end

    -- Refresh cached values from db
    cachedFormat = self.db.Format or "MM:SS"
    cachedRefreshRate = (cachedFormat == "MM:SS:MS") and 0.1 or 0.25
    cachedOpenBracket, cachedCloseBracket = GetBrackets(self.db.BracketStyle)

    -- Apply font settings
    AE:ApplyFontToText(self.text, self.db.FontFace, self.db.FontSize, self.db.FontOutline, {})

    -- Apply text alignment based on anchor
    local justify = AE:GetTextJustifyFromAnchor(self.db.Position.AnchorFrom)
    local point = AE:GetTextPointFromAnchor(self.db.Position.AnchorFrom)
    self.text:ClearAllPoints()
    self.text:SetJustifyH(justify)

    if point == "LEFT" then
        self.text:SetPoint("LEFT", self.frame, "LEFT", 4, 0)
    elseif point == "RIGHT" then
        self.text:SetPoint("RIGHT", self.frame, "RIGHT", -4, 0)
    else
        self.text:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
    end

    -- Apply text color based on combat state
    self:UpdateCombatColor()

    -- Apply backdrop
    if self.frame then
        local backdrop = self.db.Backdrop
        if backdrop and backdrop.Enabled then
            SHARED_BACKDROP.edgeSize = backdrop.BorderSize or 1
            self.frame:SetBackdrop(SHARED_BACKDROP)

            local bgColor = backdrop.Color or { 0, 0, 0, 0.6 }
            local borderColor = backdrop.BorderColor or { 1, 1, 1, 0.8 }
            self.frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 0.6)
            self.frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 0.8)
        else
            self.frame:SetBackdrop(nil)
        end
    end

    -- Force a resize since formatting/font may have changed
    self.lastDisplayedText = ""
    self:UpdateFrameSize()
    self:UpdateText()
    self:ApplyPosition()
end

-- OnUpdate handler for timer updates (only attached when running/preview)
function CT:OnUpdate(elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < cachedRefreshRate then return end
    self.elapsed = self.elapsed - cachedRefreshRate

    self:UpdateText()
end

-- Module state initialization
CT.elapsed = 0

-- Start/stop OnUpdate script (called on combat enter/exit/preview)
local function StartOnUpdate(self)
    if not self.frame then return end
    self.elapsed = 0
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
end

local function StopOnUpdate(self)
    if not self.frame then return end
    self.frame:SetScript("OnUpdate", nil)
end

-- Combat event handlers
function CT:OnEnterCombat()
    if self.running or not self.db.Enabled then return end

    self.startTime = GetTime()
    self.running = true
    AE.lastCombatDuration = 0
    self.lastDisplayedText = ""

    if self.frame then
        self.frame:Show()
    end

    -- Lightweight color update — no need to re-apply font/backdrop/position
    self:UpdateCombatColor()
    self:UpdateText()
    StartOnUpdate(self)
end

function CT:OnExitCombat()
    if not self.running then return end

    AE.lastCombatDuration = GetTime() - self.startTime
    self.running = false
    self.startTime = 0

    -- Print duration to chat
    if self.db.ShowChatMessage ~= false then
        local duration = FormatTime(AE.lastCombatDuration)
        AE:Print(L["Combat lasted "] .. duration)
    end

    -- Lightweight color update — no need to re-apply font/backdrop/position
    self:UpdateCombatColor()
    self:UpdateText()
    -- Keep OnUpdate active only if in preview mode
    if not self.isPreview then
        StopOnUpdate(self)
    end
end

-- Preview mode
function CT:ShowPreview()
    if not self.frame then
        self:CreateFrame()
    end
    self.isPreview = true
    self.frame:Show()
    self:ApplySettings()
    StartOnUpdate(self)
end

function CT:HidePreview()
    self.isPreview = false
    if not self.running then
        StopOnUpdate(self)
    end
    if self.frame and not self.running and not self.db.Enabled then
        self.frame:Hide()
    end
end

-- Expose position update for GUI changes
function CT:ApplyPosition()
    if not self.db.Enabled then return end
    if not self.frame then return end
    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)
end

-- Module OnEnable
function CT:OnEnable()
    if not self.db.Enabled then return end

    self:CreateFrame()
    self:ApplySettings()
    C_Timer.After(0.5, function() -- Delayed positioning to make sure frames exist
        self:ApplyPosition()
    end)
    -- Register events
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnExitCombat")

    if self.db.Enabled then
        self.frame:Show()
    end
end

-- Module OnDisable
function CT:OnDisable()
    if self.frame then
        StopOnUpdate(self)
        self.frame:Hide()
    end
    self.running = false
    self.isPreview = false
    self:UnregisterAllEvents()
end
