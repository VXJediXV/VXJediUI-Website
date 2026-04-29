-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("DragonRiding: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class DragonRiding: AceModule, AceEvent-3.0
local DR = VXJediEssentials:NewModule("DragonRiding", "AceEvent-3.0")

------------------------------------------------------------------------
-- Upvalues & constants
------------------------------------------------------------------------
local CreateFrame = CreateFrame
local C_Spell = C_Spell
local C_Timer = C_Timer
local C_UnitAuras = C_UnitAuras
local C_PlayerInfo = C_PlayerInfo
local GetTime = GetTime
local UIParent = UIParent
local math_min = math.min
local math_max = math.max
local math_floor = math.floor
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

local VIGOR_SPELL = 372610
local THRILL_SPELL = 377234
local SECOND_WIND_SPELL = 425782
local WHIRLING_SURGE_SPELL = 361584

local BORDER_WIDTH = 1
local DEFAULT_BAR_HEIGHT = 12
local DEFAULT_BAR_WIDTH = 252
local DEFAULT_SPACING = 1
local DEFAULT_Y_OFFSET = 220
local SPEED_UPDATE_INTERVAL = 0.05  -- 20Hz, was 50Hz
local DEFAULT_SPEED_FONT_SIZE = 14

-- Cached spell name (looked up once at first use)
local THRILL_SPELL_NAME

-- Default colors (module-level, never reallocated)
local DEFAULT_BG_COLOR              = { 0, 0, 0, 0.8 }
local DEFAULT_BORDER_COLOR          = { 0, 0, 0, 1 }
local DEFAULT_VIGOR_COLOR           = { 0.898, 0.063, 0.224, 1 }
local DEFAULT_VIGOR_THRILL_COLOR    = { 0.2, 0.8, 0.2, 1 }
local DEFAULT_SECOND_WIND_COLOR     = { 0.917, 0.168, 0.901, 1 }
local DEFAULT_SECOND_WIND_CD_COLOR  = { 0.3, 0.3, 0.3, 1 }
local DEFAULT_SURGE_COLOR           = { 0.411, 0.8, 0.941, 1 }
local DEFAULT_SURGE_CD_COLOR        = { 0.3, 0.3, 0.3, 1 }

------------------------------------------------------------------------
-- Module state
------------------------------------------------------------------------
DR.container = nil
DR.parent = nil
DR.vigorFrame = nil
DR.surgeFrame = nil
DR.secondWindFrame = nil
DR.speedText = nil
DR.isPreview = false
DR.numVigor = 0

-- Per-pill cooldown state for the unified animation OnUpdate.
-- Each entry is { pill, startTime, duration, target } so we can drive all
-- animating pills from one OnUpdate handler instead of one per pill.
DR.animatingPills = {}

-- Cached state for "show/hide on gliding" so we don't call Show/Hide every tick
DR._lastGlidingShown = nil

------------------------------------------------------------------------
-- DB
------------------------------------------------------------------------
function DR:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.DragonRiding
end

function DR:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Pill creation
------------------------------------------------------------------------
local function CreatePill(parent, height)
    local pill = CreateFrame("StatusBar", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    pill:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = BORDER_WIDTH,
        insets = { left = -1, right = -1, top = -1, bottom = -1 },
    })
    local db = DR.db
    local bgColor = (db and db.Colors and db.Colors.Background) or DEFAULT_BG_COLOR
    local borderColor = (db and db.Colors and db.Colors.Border) or DEFAULT_BORDER_COLOR
    pill:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 0.8)
    pill:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
    local texturePath = AE:GetStatusbarPath((db and db.StatusBarTexture) or "VXJediEssentials")
    pill:SetStatusBarTexture(texturePath)
    pill:SetHeight(height)
    pill:SetStatusBarColor(0.75, 0.75, 0.75)
    return pill
end

------------------------------------------------------------------------
-- Resize pills to fit container width
------------------------------------------------------------------------
local function ResizePillsToFit(container, pills, numPills, spacing)
    spacing = spacing or DEFAULT_SPACING
    local maxWidth = container:GetWidth()
    local totalSpacing = spacing * (numPills - 1)
    local availableForPills = maxWidth - totalSpacing
    local barWidth = math_floor(availableForPills / numPills)
    local leftover = math_floor(availableForPills - (barWidth * numPills))

    for index = 1, numPills do
        if pills[index] then
            if index <= leftover then
                pills[index]:SetWidth(barWidth + 1)
            else
                pills[index]:SetWidth(barWidth)
            end
        end
    end
end

------------------------------------------------------------------------
-- Unified animation system
-- One OnUpdate handler drives all animating pills, instead of N handlers.
------------------------------------------------------------------------
function DR:RegisterPillAnimation(pill, startTime, duration)
    -- Replace existing entry for this pill if any
    for i = 1, #self.animatingPills do
        if self.animatingPills[i].pill == pill then
            self.animatingPills[i].startTime = startTime
            self.animatingPills[i].duration = duration
            return
        end
    end
    self.animatingPills[#self.animatingPills + 1] = {
        pill = pill,
        startTime = startTime,
        duration = duration,
    }
end

function DR:UnregisterPillAnimation(pill)
    for i = #self.animatingPills, 1, -1 do
        if self.animatingPills[i].pill == pill then
            table.remove(self.animatingPills, i)
        end
    end
end

function DR:ClearAllAnimations()
    for i = #self.animatingPills, 1, -1 do
        self.animatingPills[i] = nil
    end
end

-- Single OnUpdate handler attached to the container — drives all pill animations
local function AnimationOnUpdate()
    local now = GetTime()
    local list = DR.animatingPills
    for i = 1, #list do
        local entry = list[i]
        local elapsed = now - entry.startTime
        if elapsed >= entry.duration then
            entry.pill:SetValue(entry.duration)
        else
            entry.pill:SetValue(elapsed)
        end
    end
end

function DR:StartAnimationOnUpdate()
    if self._animOnUpdateActive or not self.container then return end
    self.container:SetScript("OnUpdate", AnimationOnUpdate)
    self._animOnUpdateActive = true
end

function DR:StopAnimationOnUpdate()
    if not self._animOnUpdateActive or not self.container then return end
    self.container:SetScript("OnUpdate", nil)
    self._animOnUpdateActive = false
end

------------------------------------------------------------------------
-- Whirling Surge update
------------------------------------------------------------------------
local function UpdateWhirlingSurge(self)
    local pill = self.surgeFrame[1]
    if not pill then return end

    local db = self.db
    local readyColor = (db.Colors and db.Colors.WhirlingSurge) or DEFAULT_SURGE_COLOR
    local cdColor = (db.Colors and db.Colors.WhirlingSurgeCD) or DEFAULT_SURGE_CD_COLOR

    local charges = C_Spell.GetSpellCharges(WHIRLING_SURGE_SPELL)
    if charges then
        local chargeStart = charges.cooldownStartTime
        local chargeDuration = charges.cooldownDuration

        if charges.currentCharges > 0 then
            pill:SetStatusBarColor(readyColor[1], readyColor[2], readyColor[3])
            if chargeDuration > 0 then
                pill:SetMinMaxValues(0, chargeDuration)
                self:RegisterPillAnimation(pill, chargeStart, chargeDuration)
            else
                self:UnregisterPillAnimation(pill)
                pill:SetMinMaxValues(0, 1)
                pill:SetValue(1)
            end
        else
            pill:SetStatusBarColor(cdColor[1], cdColor[2], cdColor[3])
            if chargeDuration > 0 then
                pill:SetMinMaxValues(0, chargeDuration)
                self:RegisterPillAnimation(pill, chargeStart, chargeDuration)
            else
                self:UnregisterPillAnimation(pill)
                pill:SetMinMaxValues(0, 1)
                pill:SetValue(0)
            end
        end
        self:CheckAnimationOnUpdate()
        return
    end

    -- Non-charge fallback
    local cooldown = C_Spell.GetSpellCooldown(WHIRLING_SURGE_SPELL)
    if cooldown and cooldown.startTime and cooldown.duration and cooldown.duration > 1.5 then
        pill:SetStatusBarColor(cdColor[1], cdColor[2], cdColor[3])
        pill:SetMinMaxValues(0, cooldown.duration)
        self:RegisterPillAnimation(pill, cooldown.startTime, cooldown.duration)
    else
        self:UnregisterPillAnimation(pill)
        pill:SetStatusBarColor(readyColor[1], readyColor[2], readyColor[3])
        pill:SetMinMaxValues(0, 1)
        pill:SetValue(1)
    end
    self:CheckAnimationOnUpdate()
end

------------------------------------------------------------------------
-- Second Wind update
------------------------------------------------------------------------
local function UpdateSecondWind(self)
    local charges = C_Spell.GetSpellCharges(SECOND_WIND_SPELL)
    if not charges then return end

    local db = self.db
    local readyColor = (db.Colors and db.Colors.SecondWind) or DEFAULT_SECOND_WIND_COLOR
    local cdColor = (db.Colors and db.Colors.SecondWindCD) or DEFAULT_SECOND_WIND_CD_COLOR

    local chargeStart = charges.cooldownStartTime
    local chargeDuration = charges.cooldownDuration

    for index = 1, 3 do
        local pill = self.secondWindFrame[index]
        if pill then
            if charges.currentCharges >= index then
                self:UnregisterPillAnimation(pill)
                pill:SetStatusBarColor(readyColor[1], readyColor[2], readyColor[3])
                pill:SetMinMaxValues(0, 1)
                pill:SetValue(1)
            elseif charges.currentCharges + 1 == index then
                pill:SetStatusBarColor(cdColor[1], cdColor[2], cdColor[3])
                if chargeDuration > 0 then
                    pill:SetMinMaxValues(0, chargeDuration)
                    self:RegisterPillAnimation(pill, chargeStart, chargeDuration)
                else
                    self:UnregisterPillAnimation(pill)
                    pill:SetMinMaxValues(0, 1)
                    pill:SetValue(0)
                end
            else
                self:UnregisterPillAnimation(pill)
                pill:SetStatusBarColor(cdColor[1], cdColor[2], cdColor[3])
                pill:SetMinMaxValues(0, 1)
                pill:SetValue(0)
            end
        end
    end
    self:CheckAnimationOnUpdate()
end

------------------------------------------------------------------------
-- Vigor update
------------------------------------------------------------------------
local function UpdateVigor(self)
    local charges = C_Spell.GetSpellCharges(VIGOR_SPELL)
    if not charges then return end

    local spacing = self.db.Spacing or DEFAULT_SPACING
    local chargeStart = charges.cooldownStartTime
    local chargeDuration = charges.cooldownDuration

    for index = 1, charges.maxCharges do
        local pill = self.vigorFrame[index]
        if not pill then
            pill = CreatePill(self.vigorFrame, self.vigorFrame:GetHeight())
            self.vigorFrame[index] = pill

            if index == 1 then
                pill:SetPoint('LEFT')
            else
                pill:SetPoint('LEFT', self.vigorFrame[index - 1], 'RIGHT', spacing, 0)
            end
        end

        if charges.currentCharges >= index then
            self:UnregisterPillAnimation(pill)
            pill:SetMinMaxValues(0, 1)
            pill:SetValue(1)
        elseif charges.currentCharges + 1 == index then
            if chargeDuration > 0 then
                pill:SetMinMaxValues(0, chargeDuration)
                self:RegisterPillAnimation(pill, chargeStart, chargeDuration)
            else
                self:UnregisterPillAnimation(pill)
                pill:SetMinMaxValues(0, 1)
                pill:SetValue(0)
            end
        else
            self:UnregisterPillAnimation(pill)
            pill:SetMinMaxValues(0, 1)
            pill:SetValue(0)
        end
    end

    if self.numVigor ~= charges.maxCharges then
        self.numVigor = charges.maxCharges
        ResizePillsToFit(self.vigorFrame, self.vigorFrame, self.numVigor, spacing)
    end

    self:CheckAnimationOnUpdate()
end

-- Determine if the unified OnUpdate should be running
function DR:CheckAnimationOnUpdate()
    if #self.animatingPills > 0 then
        self:StartAnimationOnUpdate()
    else
        self:StopAnimationOnUpdate()
    end
end

------------------------------------------------------------------------
-- Vigor color (Thrill of the Skies buff check)
------------------------------------------------------------------------
local function UpdateVigorColor(self)
    if not THRILL_SPELL_NAME then
        THRILL_SPELL_NAME = C_Spell.GetSpellName(THRILL_SPELL)
    end

    local db = self.db
    local r, g, b
    ---@diagnostic disable-next-line
    if THRILL_SPELL_NAME and C_UnitAuras.GetAuraDataBySpellName('player', THRILL_SPELL_NAME, 'HELPFUL') then
        local color = (db.Colors and db.Colors.VigorThrill) or DEFAULT_VIGOR_THRILL_COLOR
        r, g, b = color[1], color[2], color[3]
    else
        local color = (db.Colors and db.Colors.Vigor) or DEFAULT_VIGOR_COLOR
        r, g, b = color[1], color[2], color[3]
    end

    local count = self.isPreview and 6 or self.numVigor
    for index = 1, count do
        if self.vigorFrame[index] then
            self.vigorFrame[index]:SetStatusBarColor(r, g, b)
        end
    end
end

------------------------------------------------------------------------
-- Speed text update (called by ticker at 20Hz)
------------------------------------------------------------------------
local function UpdateSpeed(self)
    local speed = self.speedText
    if not speed then return end

    -- Ensure font is set (may be nil very early after creation)
    if not speed:GetFont() then
        local font = AE.FONT or "Fonts\\FRIZQT__.TTF"
        local db = self.db
        speed:SetFont(font, (db and db.SpeedFontSize) or DEFAULT_SPEED_FONT_SIZE, 'OUTLINE')
        if not speed:GetFont() then return end
    end

    local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    if isGliding then
        if self.db.ShowSpeedText ~= false then
            speed:SetFormattedText('%d%%', forwardSpeed / BASE_MOVEMENT_SPEED * 100 + 0.5)
        else
            speed:SetText('')
        end
        -- Show container when airborne (only call Show if not already shown)
        if self.db.HideWhenGrounded and self.container and self._lastGlidingShown ~= true then
            self.container:Show()
            self._lastGlidingShown = true
        end
    else
        speed:SetText('')
        if self.db.HideWhenGrounded and self.container and self._lastGlidingShown ~= false then
            self.container:Hide()
            self._lastGlidingShown = false
        end
    end
end

------------------------------------------------------------------------
-- Frame creation
------------------------------------------------------------------------
function DR:CreateFrames()
    if self.container then return end
    local db = self.db
    local barWidth = db.Width or DEFAULT_BAR_WIDTH
    local barHeight = db.BarHeight or DEFAULT_BAR_HEIGHT
    local spacing = db.Spacing or DEFAULT_SPACING

    -- Secure parent for state driver
    self.parent = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
    self.parent:Hide()

    -- Container
    self.container = CreateFrame('Frame', 'AE_DragonRidingContainer', self.parent)
    local totalHeight = (barHeight * 3) + (spacing * 2) + 20
    self.container:SetSize(barWidth, totalHeight)
    self.container:SetPoint(
        db.Position.AnchorFrom or "CENTER",
        UIParent,
        db.Position.AnchorTo or "CENTER",
        db.Position.XOffset or 0,
        db.Position.YOffset or DEFAULT_Y_OFFSET
    )
    AE:SnapFrameToPixels(self.container)

    -- Row 3: Second Wind
    self.secondWindFrame = CreateFrame('Frame', nil, self.container)
    self.secondWindFrame:SetPoint('BOTTOMLEFT', self.container, 'BOTTOMLEFT', 0, 0)
    self.secondWindFrame:SetPoint('BOTTOMRIGHT', self.container, 'BOTTOMRIGHT', 0, 0)
    self.secondWindFrame:SetHeight(barHeight)

    local swColor = (db.Colors and db.Colors.SecondWind) or DEFAULT_SECOND_WIND_COLOR
    for i = 1, 3 do
        local pill = CreatePill(self.secondWindFrame, barHeight)
        pill:SetStatusBarColor(swColor[1], swColor[2], swColor[3])
        self.secondWindFrame[i] = pill

        if i == 1 then
            pill:SetPoint('LEFT')
        else
            pill:SetPoint('LEFT', self.secondWindFrame[i - 1], 'RIGHT', spacing, 0)
        end
    end
    ResizePillsToFit(self.secondWindFrame, self.secondWindFrame, 3, spacing)

    -- Row 2: Whirling Surge
    self.surgeFrame = CreateFrame('Frame', nil, self.container)
    self.surgeFrame:SetPoint('BOTTOMLEFT', self.secondWindFrame, 'TOPLEFT', 0, spacing)
    self.surgeFrame:SetPoint('BOTTOMRIGHT', self.secondWindFrame, 'TOPRIGHT', 0, spacing)
    self.surgeFrame:SetHeight(barHeight)

    local surgePill = CreatePill(self.surgeFrame, barHeight)
    local surgeColor = (db.Colors and db.Colors.WhirlingSurge) or DEFAULT_SURGE_COLOR
    surgePill:SetStatusBarColor(surgeColor[1], surgeColor[2], surgeColor[3])
    surgePill:SetPoint('LEFT')
    surgePill:SetPoint('RIGHT')
    self.surgeFrame[1] = surgePill

    -- Row 1: Vigor
    self.vigorFrame = CreateFrame('Frame', nil, self.container)
    self.vigorFrame:SetPoint('BOTTOMLEFT', self.surgeFrame, 'TOPLEFT', 0, spacing)
    self.vigorFrame:SetPoint('BOTTOMRIGHT', self.surgeFrame, 'TOPRIGHT', 0, spacing)
    self.vigorFrame:SetHeight(barHeight)

    -- Speed text above vigor
    self.speedText = self.vigorFrame:CreateFontString(nil, 'OVERLAY')
    local fontFile = AE:GetFontPath(self.db.FontFace) or AE.FONT or "Fonts\\FRIZQT__.TTF"
    local fontSize = self.db.SpeedFontSize or DEFAULT_SPEED_FONT_SIZE
    self.speedText:SetFont(fontFile, fontSize, "OUTLINE")
    self.speedText:SetWordWrap(false)
    self.speedText:SetPoint('BOTTOM', self.vigorFrame, 'TOP', 0, 2)
    self.speedText:SetShadowOffset(0, 0)
    self.speedText:SetText("")
end

------------------------------------------------------------------------
-- Refresh (called from Apply settings paths)
------------------------------------------------------------------------
-- Hoisted helpers for Refresh — avoid recreating closures every call
local function ApplyPillBackdrop(pill, bgColor, borderColor)
    pill:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 0.8)
    pill:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
end

local function ApplyPillTexture(pill, texturePath)
    pill:SetStatusBarTexture(texturePath)
end

function DR:Refresh()
    if not self.container then return end
    local db = self.db
    local barWidth = db.Width or DEFAULT_BAR_WIDTH
    local barHeight = db.BarHeight or DEFAULT_BAR_HEIGHT
    local spacing = db.Spacing or DEFAULT_SPACING
    local totalHeight = (barHeight * 3) + (spacing * 2) + 20

    local bgColor = (db.Colors and db.Colors.Background) or DEFAULT_BG_COLOR
    local borderColor = (db.Colors and db.Colors.Border) or DEFAULT_BORDER_COLOR
    local texturePath = AE:GetStatusbarPath(db.StatusBarTexture or "VXJediEssentials")

    self.container:SetSize(barWidth, totalHeight)
    self.secondWindFrame:SetHeight(barHeight)
    self.surgeFrame:SetHeight(barHeight)
    self.vigorFrame:SetHeight(barHeight)

    self.surgeFrame:ClearAllPoints()
    self.surgeFrame:SetPoint('BOTTOMLEFT', self.secondWindFrame, 'TOPLEFT', 0, spacing)
    self.surgeFrame:SetPoint('BOTTOMRIGHT', self.secondWindFrame, 'TOPRIGHT', 0, spacing)

    self.vigorFrame:ClearAllPoints()
    self.vigorFrame:SetPoint('BOTTOMLEFT', self.surgeFrame, 'TOPLEFT', 0, spacing)
    self.vigorFrame:SetPoint('BOTTOMRIGHT', self.surgeFrame, 'TOPRIGHT', 0, spacing)

    -- Second Wind pills
    local swColor = (db.Colors and db.Colors.SecondWind) or DEFAULT_SECOND_WIND_COLOR
    for i = 1, 3 do
        local pill = self.secondWindFrame[i]
        if pill then
            pill:SetHeight(barHeight)
            pill:SetStatusBarColor(swColor[1], swColor[2], swColor[3])
            ApplyPillBackdrop(pill, bgColor, borderColor)
            ApplyPillTexture(pill, texturePath)
            if i > 1 then
                pill:ClearAllPoints()
                pill:SetPoint('LEFT', self.secondWindFrame[i - 1], 'RIGHT', spacing, 0)
            end
        end
    end
    ResizePillsToFit(self.secondWindFrame, self.secondWindFrame, 3, spacing)

    -- Whirling Surge pill
    local surgeColor = (db.Colors and db.Colors.WhirlingSurge) or DEFAULT_SURGE_COLOR
    if self.surgeFrame[1] then
        self.surgeFrame[1]:SetHeight(barHeight)
        self.surgeFrame[1]:SetStatusBarColor(surgeColor[1], surgeColor[2], surgeColor[3])
        ApplyPillBackdrop(self.surgeFrame[1], bgColor, borderColor)
        ApplyPillTexture(self.surgeFrame[1], texturePath)
    end

    -- Vigor pills
    local vigorCount = self.isPreview and 6 or self.numVigor
    for i = 1, vigorCount do
        local pill = self.vigorFrame[i]
        if pill then
            pill:SetHeight(barHeight)
            ApplyPillBackdrop(pill, bgColor, borderColor)
            ApplyPillTexture(pill, texturePath)
            if i > 1 then
                pill:ClearAllPoints()
                pill:SetPoint('LEFT', self.vigorFrame[i - 1], 'RIGHT', spacing, 0)
            end
        end
    end
    if vigorCount > 0 then
        ResizePillsToFit(self.vigorFrame, self.vigorFrame, vigorCount, spacing)
    end
    UpdateVigorColor(self)

    -- Speed font
    local fontFile = AE:GetFontPath(self.db.FontFace) or AE.FONT or "Fonts\\FRIZQT__.TTF"
    local fontSize = self.db.SpeedFontSize or DEFAULT_SPEED_FONT_SIZE
    self.speedText:SetFont(fontFile, fontSize, "OUTLINE")
    if self.isPreview then
        self.speedText:SetText('420%')
    end
end

function DR:ApplyPosition()
    if not self.container then return end
    local db = self.db
    self.container:ClearAllPoints()
    self.container:SetPoint(
        db.Position.AnchorFrom or "CENTER",
        UIParent,
        db.Position.AnchorTo or "CENTER",
        db.Position.XOffset or 0,
        db.Position.YOffset or DEFAULT_Y_OFFSET
    )
    AE:SnapFrameToPixels(self.container)
end

function DR:ApplySettings()
    self:Refresh()
    self:ApplyPosition()

    if self.parent and self.parent:IsShown() then
        UpdateVigor(self)
        UpdateVigorColor(self)
        UpdateWhirlingSurge(self)
        UpdateSecondWind(self)
    end
end

------------------------------------------------------------------------
-- Show/hide handlers (driven by state driver)
------------------------------------------------------------------------
function DR:OnShowHandler()
    if self.isPreview then return end

    -- Ensure speed text font is set before starting ticker
    if self.speedText and not self.speedText:GetFont() then
        local font = AE:GetFontPath(self.db.FontFace) or AE.FONT or "Fonts\\FRIZQT__.TTF"
        local fontSize = self.db.SpeedFontSize or DEFAULT_SPEED_FONT_SIZE
        self.speedText:SetFont(font, fontSize, 'OUTLINE')
    end

    -- Register module-level events using AceEvent so they're cleaned up on disable
    self:RegisterEvent('SPELL_UPDATE_CHARGES', 'OnChargeUpdate')
    self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN', 'OnChargeUpdate')
    self:RegisterEvent('UNIT_AURA', 'OnUnitAura')

    self.speedTicker = C_Timer.NewTicker(SPEED_UPDATE_INTERVAL, function() UpdateSpeed(self) end)

    UpdateVigor(self)
    UpdateVigorColor(self)
    UpdateWhirlingSurge(self)
    UpdateSecondWind(self)
end

function DR:OnHideHandler()
    if self.isPreview then return end

    self:UnregisterEvent('SPELL_UPDATE_CHARGES')
    self:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
    self:UnregisterEvent('UNIT_AURA')

    if self.speedTicker then
        self.speedTicker:Cancel()
        self.speedTicker = nil
    end

    -- Critical: stop all pill animations so the unified OnUpdate stops too
    self:ClearAllAnimations()
    self:StopAnimationOnUpdate()
    self._lastGlidingShown = nil
end

------------------------------------------------------------------------
-- Event dispatch
------------------------------------------------------------------------
function DR:OnChargeUpdate()
    UpdateVigor(self)
    UpdateWhirlingSurge(self)
    UpdateSecondWind(self)
end

function DR:OnUnitAura(_, unit)
    if unit ~= "player" then return end
    UpdateVigorColor(self)
end

------------------------------------------------------------------------
-- Preview mode
------------------------------------------------------------------------
function DR:ShowPreview()
    if not self.container then
        self:CreateFrames()
    end
    self.isPreview = true

    -- Cancel real tracking for clean preview state
    if self.speedTicker then
        self.speedTicker:Cancel()
        self.speedTicker = nil
    end
    self:UnregisterEvent('SPELL_UPDATE_CHARGES')
    self:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
    self:UnregisterEvent('UNIT_AURA')
    self:ClearAllAnimations()
    self:StopAnimationOnUpdate()

    -- Disable state driver during preview so it doesn't hide the frame
    if self.parent then
        UnregisterStateDriver(self.parent, 'visibility')
        self.parent:Show()
    end

    -- Create preview vigor pills if needed
    local spacing = self.db.Spacing or DEFAULT_SPACING
    for i = 1, 6 do
        if not self.vigorFrame[i] then
            local pill = CreatePill(self.vigorFrame, self.vigorFrame:GetHeight())
            self.vigorFrame[i] = pill
            if i == 1 then
                pill:SetPoint('LEFT')
            else
                pill:SetPoint('LEFT', self.vigorFrame[i - 1], 'RIGHT', spacing, 0)
            end
        end
    end

    self:ApplySettings()

    -- Set preview values
    for i = 1, 6 do
        self.vigorFrame[i]:SetMinMaxValues(0, 1)
        if i <= 4 then
            self.vigorFrame[i]:SetValue(1)
        elseif i == 5 then
            self.vigorFrame[i]:SetValue(0.6)
        else
            self.vigorFrame[i]:SetValue(0)
        end
    end

    for i = 1, 3 do
        self.secondWindFrame[i]:SetMinMaxValues(0, 1)
        if i <= 2 then
            self.secondWindFrame[i]:SetValue(1)
        else
            self.secondWindFrame[i]:SetValue(0.3)
        end
    end

    self.surgeFrame[1]:SetMinMaxValues(0, 1)
    self.surgeFrame[1]:SetValue(1)
end

function DR:HidePreview()
    self.isPreview = false
    if self.parent then
        RegisterStateDriver(self.parent, 'visibility', '[bonusbar:5] show; hide')
        if self.parent:IsShown() then
            self:OnShowHandler()
        end
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function DR:OnEnable()
    if not self.db.Enabled then return end

    self:CreateFrames()
    self:ApplySettings()

    -- Setup show/hide handlers on the secure parent
    self.parent:HookScript('OnShow', function() self:OnShowHandler() end)
    self.parent:HookScript('OnHide', function() self:OnHideHandler() end)

    -- State driver: show only when on a skyriding mount (bonusbar 5)
    RegisterStateDriver(self.parent, 'visibility', '[bonusbar:5] show; hide')
end

function DR:OnDisable()
    self:UnregisterAllEvents()
    self:ClearAllAnimations()
    self:StopAnimationOnUpdate()

    if self.parent then
        self.parent:Hide()
        UnregisterStateDriver(self.parent, 'visibility')
    end

    if self.speedTicker then
        self.speedTicker:Cancel()
        self.speedTicker = nil
    end

    self._lastGlidingShown = nil
end
