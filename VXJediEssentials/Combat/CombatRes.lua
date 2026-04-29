-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("CombatRes: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class CombatRes: AceModule, AceEvent-3.0
local CR = VXJediEssentials:NewModule("CombatRes", "AceEvent-3.0")

-- Localization
local CreateFrame = CreateFrame
local UIParent = UIParent
local C_Spell = C_Spell
local GetTime = GetTime
local GetInstanceInfo = GetInstanceInfo
local IsEncounterInProgress = IsEncounterInProgress
local math_floor = math.floor
local string_format = string.format
local tostring = tostring

-- Module constants
local SPELL_ID = 20484 -- Rebirth

-- Module state
CR.frame = nil
CR.isPreview = false
CR.isInBResInstance = false

-- Cached settings for performance
CR.cachedSettings = {}

-- Update db, used for profile changes
function CR:UpdateDB()
    self.db = AE.db.profile.BattleRes
end

-- Module init
function CR:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

-- Update anchors based on growth direction
function CR:UpdateAnchors()
    if not self.frame or not self.frame.content then return end

    local textMode = self.db.TextMode or {}
    local textSpacing = textMode.TextSpacing or 4
    local growthDirection = textMode.GrowthDirection or "RIGHT"
    local padding = 4

    self.frame.content:ClearAllPoints()
    self.frame.separator:ClearAllPoints()
    self.frame.charge:ClearAllPoints()
    self.frame.timerText:ClearAllPoints()
    if self.frame.CRText then
        self.frame.CRText:ClearAllPoints()
    end

    if growthDirection == "RIGHT" then
        self.frame.content:SetPoint("LEFT", self.frame, "LEFT", padding, 0)

        if self.frame.CRText then
            self.frame.CRText:SetPoint("LEFT", self.frame.content, "LEFT", 0, 0)
            self.frame.charge:SetPoint("LEFT", self.frame.CRText, "RIGHT", textSpacing, 0)
        else
            self.frame.charge:SetPoint("LEFT", self.frame.content, "LEFT", 0, 0)
        end

        self.frame.separator:SetPoint("LEFT", self.frame.charge, "RIGHT", textSpacing, 0)
        self.frame.timerText:SetPoint("LEFT", self.frame.separator, "RIGHT", textSpacing, 0)
        self.frame.timerText:SetJustifyH("LEFT")
    elseif growthDirection == "LEFT" then
        self.frame.content:SetPoint("RIGHT", self.frame, "RIGHT", -padding, 0)

        self.frame.timerText:SetPoint("RIGHT", self.frame.content, "RIGHT", 0, 0)
        self.frame.separator:SetPoint("RIGHT", self.frame.timerText, "LEFT", -textSpacing, 0)

        if self.frame.CRText then
            self.frame.charge:SetPoint("RIGHT", self.frame.separator, "LEFT", -textSpacing, 0)
            self.frame.CRText:SetPoint("RIGHT", self.frame.charge, "LEFT", -textSpacing, 0)
        else
            self.frame.charge:SetPoint("RIGHT", self.frame.separator, "LEFT", 0, 0)
        end

        self.frame.timerText:SetJustifyH("RIGHT")
    end
end

-- Create the main frame
function CR:CreateFrame()
    if self.frame then return end

    local db = self.db
    local textMode = db.TextMode or {}
    local fontPath = AE:GetFontPath(textMode.FontFace or "Friz Quadrata TT")
    local fontSize = textMode.FontSize or 18

    local frame = CreateFrame("Frame", "AE_BattleResFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(100, 26)
    frame:SetFrameStrata(db.Strata or "HIGH")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:Hide()

    -- Content container
    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetSize(1, 24)

    -- Timer text
    frame.timerText = frame.content:CreateFontString(nil, "OVERLAY")
    frame.timerText:SetFont(fontPath, fontSize, "")
    frame.timerText:SetTextColor(1, 1, 1, 1)

    -- Separator text
    frame.separator = frame.content:CreateFontString(nil, "OVERLAY")
    frame.separator:SetFont(fontPath, fontSize, "")
    frame.separator:SetText(textMode.Separator or "|")
    frame.separator:SetTextColor(1, 1, 1, 1)

    -- Charge text
    frame.charge = frame.content:CreateFontString(nil, "OVERLAY")
    frame.charge:SetFont(fontPath, fontSize, "")
    frame.charge:SetTextColor(1, 1, 1, 1)

    -- CR label text
    frame.CRText = frame.content:CreateFontString(nil, "OVERLAY")
    frame.CRText:SetFont(fontPath, fontSize, "")
    frame.CRText:SetText("CR:")
    frame.CRText:SetTextColor(1, 1, 1, 1)

    self.frame = frame
end

-- Apply text mode settings
function CR:ApplyTextModeSettings()
    if not self.frame then return end

    local db = self.db
    local textMode = db.TextMode or {}
    local fontName = textMode.FontFace or "Friz Quadrata TT"
    local fontSize = textMode.FontSize or 18
    local fontOutline = textMode.FontOutline or "OUTLINE"

    -- Cache settings
    self.cachedSettings.separator = textMode.Separator or "|"
    self.cachedSettings.separatorCharges = textMode.SeparatorCharges or "CR:"
    self.cachedSettings.availableColor = textMode.ChargeAvailableColor or { 0.3, 1, 0.3, 1 }
    self.cachedSettings.unavailableColor = textMode.ChargeUnavailableColor or { 1, 0.3, 0.3, 1 }
    self.cachedSettings.timerColor = textMode.TimerColor or { 1, 1, 1, 1 }
    self.cachedSettings.separatorColor = textMode.SeparatorColor or { 1, 1, 1, 1 }
    self.cachedSettings.growthDirection = textMode.GrowthDirection or "RIGHT"

    -- Pre-unpack colors into individual r/g/b/a fields for fast per-tick access
    local ac = self.cachedSettings.availableColor
    self.cachedSettings.availR, self.cachedSettings.availG, self.cachedSettings.availB, self.cachedSettings.availA = ac[1], ac[2], ac[3], ac[4] or 1
    local uc = self.cachedSettings.unavailableColor
    self.cachedSettings.unavR, self.cachedSettings.unavG, self.cachedSettings.unavB, self.cachedSettings.unavA = uc[1], uc[2], uc[3], uc[4] or 1

    -- Cache bracket characters
    local bracketStyle = textMode.BracketStyle or "square"
    local openChar, closeChar
    if bracketStyle == "round" then openChar, closeChar = "(", ")"
    elseif bracketStyle == "none" then openChar, closeChar = "", ""
    else openChar, closeChar = "[", "]" end
    self.cachedSettings.openBracket = openChar
    self.cachedSettings.closeBracket = closeChar

    local sepShadow = textMode.SeparatorShadow or {}
    local chargeShadow = textMode.ChargeShadow or {}
    local timerShadow = textMode.TimerShadow or {}

    -- Apply separator
    local sc = self.cachedSettings.separatorColor
    self.frame.separator:SetText(self.cachedSettings.separator)
    self.frame.separator:SetTextColor(sc[1], sc[2], sc[3], sc[4] or 1)
    AE:ApplyFontToText(self.frame.separator, fontName, fontSize, fontOutline, sepShadow)

    -- Apply charge
    AE:ApplyFontToText(self.frame.charge, fontName, fontSize, fontOutline, chargeShadow)

    -- Apply CR text (with opening bracket baked in)
    self.frame.CRText:SetText(openChar .. self.cachedSettings.separatorCharges)
    self.frame.CRText:SetTextColor(sc[1], sc[2], sc[3], sc[4] or 1)
    AE:ApplyFontToText(self.frame.CRText, fontName, fontSize, fontOutline, sepShadow)

    -- Apply timer
    local tc = self.cachedSettings.timerColor
    self.frame.timerText:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
    AE:ApplyFontToText(self.frame.timerText, fontName, fontSize, fontOutline, timerShadow)

    self:UpdateAnchors()
    self:ApplyBackdropSettings()
end

-- Apply backdrop settings
function CR:ApplyBackdropSettings()
    if not self.frame then return end

    local textMode = self.db.TextMode or {}
    local backdrop = textMode.Backdrop or {}

    -- Always use the same frame size to prevent text shifting
    self.frame:SetSize(backdrop.FrameWidth or 100, backdrop.FrameHeight or 26)

    if backdrop.Enabled then
        local bgColor = backdrop.Color or { 0, 0, 0, 0.6 }
        local borderColor = backdrop.BorderColor or { 0, 0, 0, 1 }
        self.frame:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 0.6)
        self.frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
    else
        self.frame:SetBackdropColor(0, 0, 0, 0)
        self.frame:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

-- Difficulties that have battle res charges
local DIFFICULTIES_WITH_BRES = {
    [14] = true, -- Normal Raid
    [15] = true, -- Heroic Raid
    [16] = true, -- Mythic Raid
    [17] = true, -- LFR
    [33] = true, -- Timewalking Raid
    [8]  = true, -- Mythic+ (active key)
}

-- Update display (called every 1s by animation loop)
function CR:UpdateDisplay()
    if not self.frame then return end

    local chargeTable = C_Spell.GetSpellCharges(SPELL_ID)
    local cs = self.cachedSettings
    local close = cs.closeBracket or "]"

    if not chargeTable then
        if self._lastTimerText ~= "0:00" .. close then
            self.frame.timerText:SetText("0:00" .. close)
            self._lastTimerText = "0:00" .. close
        end
        if self._lastChargeText ~= "0" then
            self.frame.charge:SetText("0")
            self._lastChargeText = "0"
        end
        if not self._isIdle then
            self._isIdle = true
            self:ApplyIdleColors()
        end
        return
    end

    local startTime = chargeTable.cooldownStartTime
    local fullDuration = chargeTable.cooldownDuration
    local curCharges = chargeTable.currentCharges
    local remainingSeconds = fullDuration - (GetTime() - startTime)

    -- Build timer text
    local minutes = math_floor(remainingSeconds / 60)
    local seconds = math_floor(remainingSeconds - (minutes * 60))
    local timerStr
    if minutes == 0 then
        timerStr = seconds .. close
    else
        timerStr = string_format("%d:%02d%s", minutes, seconds, close)
    end
    -- Only update SetText if value changed
    if self._lastTimerText ~= timerStr then
        self.frame.timerText:SetText(timerStr)
        self._lastTimerText = timerStr
    end

    -- Charge text — only update on change
    local chargeStr = tostring(curCharges)
    if self._lastChargeText ~= chargeStr then
        self.frame.charge:SetText(chargeStr)
        self._lastChargeText = chargeStr
    end

    -- If charges are 0 and no time remaining, grey out everything
    if curCharges == 0 and remainingSeconds <= 0 then
        if not self._isIdle then
            self._isIdle = true
            self:ApplyIdleColors()
        end
        return
    end

    -- Active state — restore proper colors only on transition
    if self._isIdle then
        self._isIdle = false
        self:ApplyActiveColors()
    end

    -- Charge color — only update when charge state crosses zero/non-zero boundary
    local chargeIsZero = (curCharges == 0)
    if self._lastChargeIsZero ~= chargeIsZero then
        if chargeIsZero then
            self.frame.charge:SetTextColor(cs.unavR, cs.unavG, cs.unavB, cs.unavA)
        else
            self.frame.charge:SetTextColor(cs.availR, cs.availG, cs.availB, cs.availA)
        end
        self._lastChargeIsZero = chargeIsZero
    end
end

-- Preview update (when not in instance)
function CR:UpdatePreview()
    if not self.frame then return end
    self.frame:Show()
    local close = self.cachedSettings.closeBracket or "]"
    self.frame.timerText:SetText("02:00" .. close)
    self.frame.charge:SetText("2")
    self._lastTimerText = "02:00" .. close
    self._lastChargeText = "2"
    local cs = self.cachedSettings
    self.frame.charge:SetTextColor(cs.availR or 0.3, cs.availG or 1, cs.availB or 0.3, cs.availA or 1)
    self._lastChargeIsZero = false
end

-- Start the 1-second updater (like BigWigs AnimationGroup approach)
function CR:StartUpdater()
    if not self.frame then return end
    if not self.frame.updater then
        local updater = self.frame:CreateAnimationGroup()
        updater:SetLooping("REPEAT")
        local anim = updater:CreateAnimation()
        anim:SetDuration(1)
        updater:SetScript("OnLoop", function()
            CR:UpdateDisplay()
        end)
        self.frame.updater = updater
    end
    self.frame.updater:Play()
end

function CR:StopUpdater()
    if self.frame and self.frame.updater then
        self.frame.updater:Stop()
    end
end

-- Grey color for idle state (CR: 0 | 0:00)
local IDLE_COLOR = { 0.45, 0.45, 0.45, 1 }

function CR:ApplyIdleColors()
    if not self.frame then return end
    local r, g, b, a = IDLE_COLOR[1], IDLE_COLOR[2], IDLE_COLOR[3], IDLE_COLOR[4]
    self.frame.timerText:SetTextColor(r, g, b, a)
    self.frame.charge:SetTextColor(r, g, b, a)
    self.frame.separator:SetTextColor(r, g, b, a)
    if self.frame.CRText then self.frame.CRText:SetTextColor(r, g, b, a) end
    -- Reset charge color cache so next active transition reapplies
    self._lastChargeIsZero = nil
end

function CR:ApplyActiveColors()
    if not self.frame then return end
    local sc = self.cachedSettings.separatorColor or { 1, 1, 1, 1 }
    local tc = self.cachedSettings.timerColor or { 1, 1, 1, 1 }
    self.frame.separator:SetTextColor(sc[1], sc[2], sc[3], sc[4] or 1)
    self.frame.timerText:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
    if self.frame.CRText then self.frame.CRText:SetTextColor(sc[1], sc[2], sc[3], sc[4] or 1) end
end

-- Check if we're in an instance with battle res
function CR:CheckInstance()
    if not self.db or not self.db.Enabled then return end

    local _, _, difficultyID = GetInstanceInfo()

    if difficultyID == 8 then
        -- Active M+ key: bres charges tick the entire key, not per-encounter
        self.isInBResInstance = true
        self.frame:Show()
        local close = self.cachedSettings.closeBracket or "]"
        self.frame.timerText:SetText("0:00" .. close)
        self.frame.charge:SetText("0")
        self._lastTimerText = "0:00" .. close
        self._lastChargeText = "0"
        self._isIdle = false
        self:StartUpdater()
    elseif DIFFICULTIES_WITH_BRES[difficultyID] then
        -- Raid: show idle, start updater only during encounters
        self.isInBResInstance = true
        self.frame:Show()
        local close = self.cachedSettings.closeBracket or "]"
        self.frame.timerText:SetText("0:00" .. close)
        self.frame.charge:SetText("0")
        self._lastTimerText = "0:00" .. close
        self._lastChargeText = "0"
        self._isIdle = true
        self:ApplyIdleColors()

        self:RegisterEvent("ENCOUNTER_START")
        self:RegisterEvent("ENCOUNTER_END")

        -- If we zoned in mid-encounter
        if IsEncounterInProgress() then
            self._isIdle = false
            self:StartUpdater()
        end
    elseif difficultyID == 23 then
        -- Mythic dungeon (not yet a key) — watch for key start
        self.isInBResInstance = false
        self:RegisterEvent("CHALLENGE_MODE_START")
    else
        self.isInBResInstance = false
        self.frame:Hide()
        self:StopUpdater()
        -- Unregister encounter/challenge events when leaving relevant instances
        self:UnregisterEvent("ENCOUNTER_START")
        self:UnregisterEvent("ENCOUNTER_END")
        self:UnregisterEvent("CHALLENGE_MODE_START")
    end
end

-- Apply all settings
function CR:ApplySettings()
    if not self.frame then
        self:CreateFrame()
    end

    AE:ApplyFramePosition(self.frame, self.db.Position, self.db)
    self:ApplyTextModeSettings()

    if not self.db.Enabled and not self.isPreview then
        self.frame:Hide()
        self:StopUpdater()
        return
    end

    if self.isPreview then
        self:UpdatePreview()
    elseif self._isIdle then
        self:ApplyIdleColors()
    end
end

-- Preview mode
function CR:ShowPreview()
    if not self.frame then
        self:CreateFrame()
    end
    self.isPreview = true
    self:ApplySettings()
    self:UpdatePreview()
end

function CR:HidePreview()
    self.isPreview = false
    if self.isInBResInstance then
        -- Keep showing if in valid instance
    elseif self.frame then
        self.frame:Hide()
    end
end

-- Module OnEnable
function CR:OnEnable()
    self:CreateFrame()

    -- Reset preview mode on init
    self.db.PreviewMode = false
    self.isPreview = false
    self.isInBResInstance = false

    C_Timer.After(0.5, function()
        self:ApplySettings()
    end)

    -- Check instance on zone changes
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Delay 1 frame for accurate difficulty info (BigWigs pattern)
function CR:PLAYER_ENTERING_WORLD()
    C_Timer.After(0, function()
        CR:CheckInstance()
    end)
end

-- Encounter events
function CR:ENCOUNTER_START()
    self:StartUpdater()
end

function CR:ENCOUNTER_END()
    self:StopUpdater()
    if self.frame then
        local close = self.cachedSettings.closeBracket or "]"
        self.frame.timerText:SetText("0:00" .. close)
        self.frame.charge:SetText("0")
        self._lastTimerText = "0:00" .. close
        self._lastChargeText = "0"
        self._isIdle = true
        self:ApplyIdleColors()
    end
end

function CR:CHALLENGE_MODE_START()
    self.isInBResInstance = true
    if self.frame then
        self.frame:Show()
        local close = self.cachedSettings.closeBracket or "]"
        self.frame.timerText:SetText("0:00" .. close)
        self.frame.charge:SetText("0")
        self._lastTimerText = "0:00" .. close
        self._lastChargeText = "0"
    end
    self:StartUpdater()
end

-- Module OnDisable
function CR:OnDisable()
    self:StopUpdater()
    if self.frame then
        self.frame:Hide()
    end
    self.isPreview = false
    self.isInBResInstance = false
end
