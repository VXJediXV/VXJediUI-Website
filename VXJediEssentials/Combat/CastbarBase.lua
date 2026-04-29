-- VXJediEssentials Castbar Base Factory
-- Provides AE:CreateCastbarModule(config) which creates a fully configured
-- castbar AceModule for a given unit (target, focus, etc.)
--
-- This is the deduplicated source of truth for both TargetCastbar and FocusCastbar.
-- Changes to castbar logic should happen here, not in the wrapper files.
---@class AE
---@diagnostic disable: undefined-field
local AE = select(2, ...)

local L = AE.L
if not VXJediEssentials then
    error("CastbarBase: Addon object not initialized. Check file load order!")
    return
end

-- Localization
local CreateFrame = CreateFrame
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local UnitCastingDuration, UnitChannelDuration = UnitCastingDuration, UnitChannelDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local select = select
local CreateColor = CreateColor
local GetTime = GetTime
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local ipairs = ipairs
local type = type

------------------------------------------------------------------------
-- Module-shared constants
------------------------------------------------------------------------
local FALLBACK_ICON = 136243
local INTERRUPTED = L["Interrupted"]
local INTERRUPTED_BY = "Interrupted by %s"
local PREVIEW_DURATION = 20
local UPDATE_THROTTLE = 0.1

-- Default color constants (module-level — never reallocated)
local DEFAULT_CASTING_COLOR     = { 1, 0.7, 0, 1 }
local DEFAULT_CHANNELING_COLOR  = { 0, 0.7, 1, 1 }
local DEFAULT_EMPOWERING_COLOR  = { 0.8, 0.4, 1, 1 }
local DEFAULT_NOTINTERRUPT_COLOR = { 0.7, 0.7, 0.7, 1 }
local DEFAULT_INTERRUPTED_COLOR = { 0.1, 0.8, 0.1, 1 }
local DEFAULT_FAILED_COLOR      = { 0.5, 0.5, 0.5, 1 }
local DEFAULT_SUCCESS_COLOR     = { 0.8, 0.1, 0.1, 1 }

-- Cast events registered in OnEnable
local CAST_EVENTS = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_EMPOWER_STOP",
    "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
}

-- Class interrupt spell IDs (primary)
local CLASS_INTERRUPTS = {
    [1] = { 6552 },                         -- Warrior
    [2] = { 96231 },                        -- Paladin
    [3] = { 147362, 187707 },               -- Hunter
    [4] = { 1766 },                         -- Rogue
    [5] = { 15487 },                        -- Priest
    [6] = { 47528 },                        -- Death Knight
    [7] = { 57994 },                        -- Shaman
    [8] = { 2139 },                         -- Mage
    [9] = { 19647, 89766 },                 -- Warlock (pet interrupts)
    [10] = { 116705 },                      -- Monk
    [11] = { 78675, 106839 },               -- Druid
    [12] = { 183752 },                      -- Demon Hunter
    [13] = { 351338 },                      -- Evoker
}

-- Secondary interrupt spell IDs
local CLASS_SECONDARY_INTERRUPTS = {
    [2] = { 31935 },                        -- Paladin (Avenger's Shield)
    [9] = { 132409, 1276467 },              -- Warlock (Spell Lock via sacrifice, Fel Ravager)
}

------------------------------------------------------------------------
-- The factory
------------------------------------------------------------------------
-- Creates and returns a fully configured castbar AceModule.
-- @param config table with the following fields:
--   moduleName   (string) - AceModule name, e.g. "TargetCastbar"
--   unit         (string) - Wow unit token, e.g. "target" or "focus"
--   dbPath       (string) - Key under AE.db.profile.Miscellaneous, e.g. "TargetCastbar"
--   frameName    (string) - Global frame name, e.g. "AE_TargetCastbarFrame"
--   changedEvent (string) - Wow event name, e.g. "PLAYER_TARGET_CHANGED"
--   previewLabel (string) - Localized label shown in preview mode
function AE:CreateCastbarModule(config)
    local moduleName   = config.moduleName
    local unit         = config.unit
    local dbPath       = config.dbPath
    local frameName    = config.frameName
    local changedEvent = config.changedEvent
    local previewLabel = config.previewLabel

    -- Create the AceModule
    local M = VXJediEssentials:NewModule(moduleName, "AceEvent-3.0")
    M._unit = unit
    M._frameName = frameName
    M._changedEvent = changedEvent
    M._previewLabel = previewLabel
    M._dbPath = dbPath

    --------------------------------------------------------------------
    -- DB / init
    --------------------------------------------------------------------
    function M:UpdateDB()
        self.db = AE.db.profile.Miscellaneous[self._dbPath]
    end

    function M:OnInitialize()
        self:UpdateDB()
        self:SetEnabledState(false)
    end

    --------------------------------------------------------------------
    -- Color setup
    --------------------------------------------------------------------
    function M:CreateColorObjects()
        local kick = self.db.KickIndicator or {}
        local notReady = kick.NotReadyColor or { 0.5, 0.5, 0.5, 1 }
        local secondaryReady = kick.SecondaryReadyColor or { 0.878, 0.643, 1, 1 }
        local uninterruptible = self.db.NotInterruptibleColor or { 0.7, 0.7, 0.7, 1 }
        self.colors = {
            NotReady = CreateColor(notReady[1], notReady[2], notReady[3]),
            SecondaryReady = CreateColor(secondaryReady[1], secondaryReady[2], secondaryReady[3]),
            Uninterruptible = CreateColor(uninterruptible[1], uninterruptible[2], uninterruptible[3]),
        }
    end

    --------------------------------------------------------------------
    -- State management
    --------------------------------------------------------------------
    function M:ResetCastState()
        self.casting, self.channeling, self.empowering = nil, nil, nil
        self.castID, self.spellID, self.spellName = nil, nil, nil
        self.notInterruptible = nil
        self.cachedDuration = nil
    end

    --------------------------------------------------------------------
    -- Frame creation
    --------------------------------------------------------------------
    function M:CreateFrame()
        if self.frame then return end
        local db = self.db
        local parent = AE:ResolveAnchorFrame(db.anchorFrameType, db.ParentFrame)
        local height = db.Height or 20

        -- Main container with backdrop
        local frame = AE:CreateStandardBackdrop(parent, self._frameName, 100,
            { 0, 0, 0, 0.8 }, { 0, 0, 0, 1 })
        frame:SetSize(db.Width or 200, height)
        frame:SetPoint(db.Position.AnchorFrom or "CENTER", parent, db.Position.AnchorTo or "CENTER",
            db.Position.XOffset or 0, db.Position.YOffset or 200)
        frame:SetFrameStrata(db.Strata or "HIGH")
        frame:EnableMouse(false)
        frame:Hide()

        -- Icon frame with backdrop
        local iconFrame = AE:CreateStandardBackdrop(frame, nil, nil, { 0, 0, 0, 0.8 }, { 0, 0, 0, 1 })
        iconFrame:SetSize(height, height)
        iconFrame:SetPoint("LEFT", frame, "LEFT", 0, 0)

        -- Icon texture with zoom
        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
        AE:ApplyZoom(icon, 0.3)

        -- Castbar
        local castBar = CreateFrame("StatusBar", nil, frame)
        castBar:SetPoint("LEFT", iconFrame, "RIGHT", 0, 0)
        castBar:SetPoint("RIGHT", frame, "RIGHT", -1, 0)
        castBar:SetPoint("TOP", frame, "TOP", 0, -1)
        castBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 1)
        castBar:SetStatusBarTexture(AE:GetStatusbarPath(db.StatusBarTexture))
        castBar:SetMinMaxValues(0, 1)
        castBar:SetValue(0)

        -- Spark overlay frame
        local sparkOverlay = CreateFrame("Frame", nil, frame)
        sparkOverlay:SetAllPoints(castBar)
        sparkOverlay:SetFrameLevel(castBar:GetFrameLevel() + 5)

        -- Spark
        local spark = sparkOverlay:CreateTexture(nil, "ARTWORK")
        spark:SetColorTexture(1, 1, 1, 0.8)
        spark:SetSize(2, height)
        spark:SetPoint("CENTER", castBar:GetStatusBarTexture(), "RIGHT", 0, 0)
        spark:Hide()

        -- Invisible positioner for tick
        local positioner = CreateFrame("StatusBar", nil, castBar)
        positioner:SetAllPoints(castBar)
        positioner:SetStatusBarTexture(AE:GetStatusbarPath(db.StatusBarTexture))
        positioner:SetStatusBarColor(0, 0, 0, 0)
        positioner:SetMinMaxValues(0, 1)
        positioner:SetValue(0)
        positioner:SetFrameLevel(castBar:GetFrameLevel() + 1)

        -- Kick cooldown bar
        local kickCooldownBar = CreateFrame("StatusBar", nil, castBar)
        kickCooldownBar:SetAllPoints(castBar)
        kickCooldownBar:SetStatusBarTexture(AE:GetStatusbarPath(db.StatusBarTexture))
        kickCooldownBar:SetStatusBarColor(0, 0, 0, 0)
        kickCooldownBar:SetClipsChildren(true)
        kickCooldownBar:SetMinMaxValues(0, 1)
        kickCooldownBar:SetValue(0)
        kickCooldownBar:SetFrameLevel(castBar:GetFrameLevel() + 4)

        -- Mask texture to clip tick at castbar bounds
        local tickMask = castBar:CreateMaskTexture()
        tickMask:SetAllPoints(castBar)
        tickMask:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

        -- Tick texture
        local kickTick = kickCooldownBar:CreateTexture(nil, "OVERLAY", nil, 7)
        kickTick:SetSize(2, height)
        kickTick:SetColorTexture(1, 1, 1, 1)
        kickTick:SetPoint("CENTER", kickCooldownBar:GetStatusBarTexture(), "RIGHT", 0, 0)
        kickTick:AddMaskTexture(tickMask)
        kickTick:SetAlpha(0)

        -- Secondary kick cooldown bar
        local secondaryKickBar = CreateFrame("StatusBar", nil, castBar)
        secondaryKickBar:SetAllPoints(castBar)
        secondaryKickBar:SetStatusBarTexture(AE:GetStatusbarPath(db.StatusBarTexture))
        secondaryKickBar:SetStatusBarColor(0, 0, 0, 0)
        secondaryKickBar:SetClipsChildren(true)
        secondaryKickBar:SetMinMaxValues(0, 1)
        secondaryKickBar:SetValue(0)
        secondaryKickBar:SetFrameLevel(castBar:GetFrameLevel() + 3)

        -- Secondary tick texture
        local secondaryKickTick = secondaryKickBar:CreateTexture(nil, "OVERLAY", nil, 7)
        secondaryKickTick:SetSize(2, height)
        secondaryKickTick:SetColorTexture(0.878, 0.643, 1, 1)
        secondaryKickTick:SetPoint("CENTER", secondaryKickBar:GetStatusBarTexture(), "RIGHT", 0, 0)
        secondaryKickTick:AddMaskTexture(tickMask)
        secondaryKickTick:SetAlpha(0)

        -- Text elements
        local text = castBar:CreateFontString(nil, "OVERLAY")
        text:SetPoint("LEFT", castBar, "LEFT", 4, 0)
        text:SetJustifyH("LEFT")
        AE:ApplyFont(text, db.FontFace, db.FontSize, db.FontOutline)

        local time = castBar:CreateFontString(nil, "OVERLAY")
        time:SetPoint("RIGHT", castBar, "RIGHT", -4, 0)
        time:SetJustifyH("RIGHT")
        AE:ApplyFont(time, db.FontFace, db.FontSize, db.FontOutline)

        -- Store references
        self.positioner = positioner
        self.frame, self.iconFrame, self.icon = frame, iconFrame, icon
        self.castBar, self.spark = castBar, spark
        self.kickCooldownBar, self.kickTick = kickCooldownBar, kickTick
        self.secondaryKickBar, self.secondaryKickTick = secondaryKickBar, secondaryKickTick
        self.text, self.time = text, time
        self.holdTimer = nil

        self:ApplySettings()
    end

    --------------------------------------------------------------------
    -- Apply visual settings
    --------------------------------------------------------------------
    function M:ApplySettings()
        if not self.frame then return end
        self:CreateColorObjects()

        local db = self.db
        local bgColor = db.BackdropColor or { 0, 0, 0, 0.8 }
        local borderColor = db.BorderColor or { 0, 0, 0, 1 }
        local textColor = db.TextColor or { 1, 1, 1, 1 }
        local kickColors = db.KickIndicator or {}

        self.frame:SetSize(db.Width or 200, db.Height)
        self.frame:SetBackgroundColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 0.8)
        self.frame:SetBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
        self.frame:SetFrameStrata(db.Strata or "HIGH")

        self.iconFrame:SetSize(db.Height, db.Height)
        self.iconFrame:SetBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)

        local texturePath = AE:GetStatusbarPath(db.StatusBarTexture)
        self.castBar:SetStatusBarTexture(texturePath)
        self.positioner:SetStatusBarTexture(texturePath)
        self.kickCooldownBar:SetStatusBarTexture(texturePath)
        self.secondaryKickBar:SetStatusBarTexture(texturePath)
        self.spark:SetSize(2, db.Height)

        -- Kick tick settings
        self.kickTick:SetSize(2, db.Height)
        local tickColor = kickColors.TickColor or { 1, 1, 1, 1 }
        self.kickTick:SetColorTexture(tickColor[1], tickColor[2], tickColor[3], tickColor[4] or 1)

        -- Secondary kick tick settings
        self.secondaryKickTick:SetSize(2, db.Height)
        local secTickColor = kickColors.SecondaryTickColor or { 0.878, 0.643, 1, 1 }
        self.secondaryKickTick:SetColorTexture(secTickColor[1], secTickColor[2], secTickColor[3], secTickColor[4] or 1)

        AE:ApplyFont(self.text, db.FontFace, db.FontSize, db.FontOutline)
        AE:ApplyFont(self.time, db.FontFace, db.FontSize, db.FontOutline)
        self.text:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
        self.time:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)

        self:ApplyPosition()
    end

    function M:ApplyPosition()
        if not self.frame then return end
        AE:ApplyFramePosition(self.frame, self.db.Position, self.db, true)
    end

    --------------------------------------------------------------------
    -- Color resolution
    --------------------------------------------------------------------
    function M:GetCurrentCastColor()
        if self.channeling then return self.db.ChannelingColor or DEFAULT_CHANNELING_COLOR end
        if self.empowering then return self.db.EmpoweringColor or DEFAULT_EMPOWERING_COLOR end
        return self.db.CastingColor or DEFAULT_CASTING_COLOR
    end

    function M:UpdateBarColor(primaryCooldown)
        if not self.castBar then return end
        local kick = self.db.KickIndicator
        local texture = self.castBar:GetStatusBarTexture()
        local hasActiveCast = self.casting or self.channeling or self.empowering
        local u = self._unit

        -- Skip kick indicator in preview mode
        if self.isPreview then
            local color = self.db.CastingColor or DEFAULT_CASTING_COLOR
            texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
            return
        end

        -- Kick indicator with interrupt spell and active cast (only on attackable units)
        if kick and kick.Enabled and self.interruptId and hasActiveCast and UnitCanAttack("player", u) then
            local cooldown = primaryCooldown or C_Spell.GetSpellCooldownDuration(self.interruptId)
            if not cooldown then return end

            -- Cache active cast color CreateColor object on transition
            local castColorTable = self:GetCurrentCastColor()
            if self._lastCastColorTable ~= castColorTable then
                self._activeCastColor = CreateColor(castColorTable[1], castColorTable[2], castColorTable[3], castColorTable[4] or 1)
                self._lastCastColorTable = castColorTable
            end

            local interruptIsReady = cooldown:IsZero()
            local secondaryInterruptIsReady = false
            if self.secondaryInterruptId then
                local secCooldown = C_Spell.GetSpellCooldownDuration(self.secondaryInterruptId)
                if secCooldown then secondaryInterruptIsReady = secCooldown:IsZero() end
            end

            local color = C_CurveUtil.EvaluateColorFromBoolean(secondaryInterruptIsReady, self.colors.SecondaryReady, self.colors.NotReady)
            color = C_CurveUtil.EvaluateColorFromBoolean(interruptIsReady, self._activeCastColor, color)

            if self.notInterruptible ~= nil then
                color = C_CurveUtil.EvaluateColorFromBoolean(self.notInterruptible, self.colors.Uninterruptible, color)
            end

            self.castBar:SetStatusBarColor(color:GetRGBA())
            return
        end

        -- Kick indicator enabled but no interrupt spell
        if kick and kick.Enabled and hasActiveCast and UnitCanAttack("player", u) then
            local color = C_CurveUtil.EvaluateColorFromBoolean(self.notInterruptible, self.colors.Uninterruptible, self.colors.NotReady)
            self.castBar:SetStatusBarColor(color:GetRGBA())
            return
        end

        -- Fallback to regular colors
        local color = self:GetCurrentCastColor()
        self.castBar:SetStatusBarColor(color[1], color[2], color[3], color[4] or 1)
    end

    --------------------------------------------------------------------
    -- Interrupt detection
    --------------------------------------------------------------------
    function M:CacheInterruptId()
        local playerClass = select(3, UnitClass("player"))

        -- Primary interrupt
        self.interruptId = nil
        local interrupts = CLASS_INTERRUPTS[playerClass]
        if interrupts then
            for i = 1, #interrupts do
                local id = interrupts[i]
                if C_SpellBook.IsSpellKnownOrInSpellBook(id)
                    or C_SpellBook.IsSpellKnownOrInSpellBook(id, Enum.SpellBookSpellBank.Pet) then
                    self.interruptId = id
                    break
                end
            end
        end

        -- Secondary interrupt
        self.secondaryInterruptId = nil
        local secondaryInterrupts = CLASS_SECONDARY_INTERRUPTS[playerClass]
        if secondaryInterrupts then
            for i = 1, #secondaryInterrupts do
                local id = secondaryInterrupts[i]
                if C_SpellBook.IsSpellKnownOrInSpellBook(id)
                    or C_SpellBook.IsSpellKnownOrInSpellBook(id, Enum.SpellBookSpellBank.Pet) then
                    self.secondaryInterruptId = id
                    break
                end
            end
        end

        -- If no primary but secondary exists, promote secondary to primary
        if not self.interruptId and self.secondaryInterruptId then
            self.interruptId = self.secondaryInterruptId
            self.secondaryInterruptId = nil
        end
    end

    --------------------------------------------------------------------
    -- Kick indicator updates
    --------------------------------------------------------------------
    function M:UpdateKickIndicator()
        local kick = self.db.KickIndicator
        local u = self._unit
        if not kick or not kick.Enabled or not self.interruptId or not UnitCanAttack("player", u) then
            self.kickTick:SetAlpha(0)
            self.secondaryKickTick:SetAlpha(0)
            return nil, nil
        end

        if self.isPreview then
            self.kickTick:SetAlpha(0)
            self.secondaryKickTick:SetAlpha(0)
            return nil, nil
        end

        local cooldown = C_Spell.GetSpellCooldownDuration(self.interruptId)
        if not cooldown then return nil, nil end

        self.kickTick:SetAlphaFromBoolean(cooldown:IsZero(), 0,
            C_CurveUtil.EvaluateColorValueFromBoolean(self.notInterruptible, 0, 1))

        local secCooldown
        if self.secondaryInterruptId then
            secCooldown = C_Spell.GetSpellCooldownDuration(self.secondaryInterruptId)
            if secCooldown then
                local secAlpha = C_CurveUtil.EvaluateColorValueFromBoolean(self.notInterruptible, 0, 1)
                secAlpha = C_CurveUtil.EvaluateColorValueFromBoolean(secCooldown:IsZero(), 0, secAlpha)
                secAlpha = C_CurveUtil.EvaluateColorValueFromBoolean(cooldown:IsZero(), 0, secAlpha)
                self.secondaryKickTick:SetAlpha(secAlpha)
            else
                self.secondaryKickTick:SetAlpha(0)
            end
        else
            self.secondaryKickTick:SetAlpha(0)
        end

        self:UpdateBarColor(cooldown)
        return cooldown, secCooldown
    end

    function M:UpdateTickPosition(duration, primaryCooldown, secondaryCooldown)
        local kick = self.db.KickIndicator
        if not kick or not kick.Enabled or not self.interruptId then return end

        self.positioner:SetValue(duration:GetElapsedDuration())

        if not primaryCooldown then return end
        self.kickCooldownBar:SetValue(primaryCooldown:GetRemainingDuration())

        if self.secondaryInterruptId and secondaryCooldown then
            self.secondaryKickBar:SetValue(secondaryCooldown:GetRemainingDuration())
        end
    end

    --------------------------------------------------------------------
    -- Misc helpers
    --------------------------------------------------------------------
    function M:GetColoredNameFromGUID(guid)
        if guid == nil then return nil end
        local _, classToken, _, _, _, name = GetPlayerInfoByGUID(guid)
        if name == nil then return nil end
        if type(classToken) ~= "string" then return name end
        local color = C_ClassColor.GetClassColor(classToken)
        if color == nil then return name end
        return color:WrapTextInColorCode(name)
    end

    function M:SetupKickCooldownBar()
        local kick = self.db.KickIndicator
        if not kick or not kick.Enabled or not self.interruptId then
            self.kickTick:SetAlpha(0)
            self.secondaryKickTick:SetAlpha(0)
            return
        end

        local duration = self.cachedDuration
        if not duration then
            self.kickTick:SetAlpha(0)
            self.secondaryKickTick:SetAlpha(0)
            return
        end

        local width, height = self.castBar:GetSize()
        local isChannel = self.channeling or false

        self.positioner:SetMinMaxValues(0, duration:GetTotalDuration())
        self.positioner:SetReverseFill(isChannel)

        self.kickCooldownBar:ClearAllPoints()
        self.kickCooldownBar:SetSize(width, height)
        self.kickCooldownBar:SetReverseFill(isChannel)
        self.kickCooldownBar:SetMinMaxValues(0, duration:GetTotalDuration())

        self.kickTick:ClearAllPoints()
        self.kickTick:SetSize(2, height)

        if isChannel then
            self.kickCooldownBar:SetPoint("RIGHT", self.positioner:GetStatusBarTexture(), "LEFT")
            self.kickTick:SetPoint("RIGHT", self.kickCooldownBar:GetStatusBarTexture(), "LEFT")
        else
            self.kickCooldownBar:SetPoint("LEFT", self.positioner:GetStatusBarTexture(), "RIGHT")
            self.kickTick:SetPoint("LEFT", self.kickCooldownBar:GetStatusBarTexture(), "RIGHT")
        end

        if self.secondaryInterruptId then
            self.secondaryKickBar:ClearAllPoints()
            self.secondaryKickBar:SetSize(width, height)
            self.secondaryKickBar:SetReverseFill(isChannel)
            self.secondaryKickBar:SetMinMaxValues(0, duration:GetTotalDuration())

            self.secondaryKickTick:ClearAllPoints()
            self.secondaryKickTick:SetSize(2, height)

            if isChannel then
                self.secondaryKickBar:SetPoint("RIGHT", self.positioner:GetStatusBarTexture(), "LEFT")
                self.secondaryKickTick:SetPoint("RIGHT", self.secondaryKickBar:GetStatusBarTexture(), "LEFT")
            else
                self.secondaryKickBar:SetPoint("LEFT", self.positioner:GetStatusBarTexture(), "RIGHT")
                self.secondaryKickTick:SetPoint("LEFT", self.secondaryKickBar:GetStatusBarTexture(), "RIGHT")
            end
        else
            self.secondaryKickTick:SetAlpha(0)
        end
    end

    --------------------------------------------------------------------
    -- Cast events
    --------------------------------------------------------------------
    function M:OnCastEvent(event, eventUnit, ...)
        if eventUnit ~= self._unit then return end
        if event:find("START") then
            self:StartCast()
        elseif event:find("STOP") then
            local interruptedBy
            if event:find("CHANNEL") then
                interruptedBy = select(3, ...)
            elseif event:find("EMPOWER") then
                interruptedBy = select(4, ...)
            end
            local wasInterrupted = interruptedBy ~= nil
            self:EndCast(wasInterrupted, wasInterrupted, interruptedBy)
        elseif event:find("INTERRUPTED") then
            local interruptedBy = select(3, ...)
            self:EndCast(true, true, interruptedBy)
        elseif event:find("FAILED") then
            self:EndCast(true, false)
        elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
            self.notInterruptible = true
            if self.db.HideNotInterruptible then
                self.frame:SetAlphaFromBoolean(true, 0, 1)
            end
            self:UpdateBarColor()
        elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
            self.notInterruptible = false
            if self.db.HideNotInterruptible then
                self.frame:SetAlphaFromBoolean(false, 0, 1)
            end
            self:UpdateBarColor()
        end
    end

    --------------------------------------------------------------------
    -- StartCast / EndCast
    --------------------------------------------------------------------
    function M:StartCast()
        local u = self._unit
        if not self.frame or not UnitExists(u) then return end
        local name, text, texture, castID, notInterruptible, spellID, isEmpowered
        local duration, direction = nil, Enum.StatusBarTimerDirection.ElapsedTime

        -- Try regular cast first
        name, text, texture, _, _, _, castID, notInterruptible, spellID = UnitCastingInfo(u)
        if name then
            self.casting, self.channeling, self.empowering = true, nil, nil
            duration = UnitCastingDuration(u)
        else
            -- Try channel
            name, text, texture, _, _, _, notInterruptible, spellID, isEmpowered, _, castID = UnitChannelInfo(u)
            if name then
                self.casting = nil
                if isEmpowered then
                    self.empowering, self.channeling = true, nil
                    duration = UnitEmpoweredChannelDuration(u)
                else
                    self.channeling, self.empowering = true, nil
                    duration = UnitChannelDuration(u)
                    direction = Enum.StatusBarTimerDirection.RemainingTime
                end
            end
        end

        if not name then
            if not self.holdTimer then
                self:ResetCastState()
                self.frame:Hide()
                self:StopOnUpdate()
            end
            return
        end

        if self.holdTimer then
            self.holdTimer:Cancel()
            self.holdTimer = nil
        end

        self.castID, self.spellID, self.spellName = castID, spellID, text or name
        self.notInterruptible = notInterruptible

        if self.db.HideNotInterruptible and not issecretvalue(notInterruptible) then
            self.frame:SetAlphaFromBoolean(notInterruptible, 0, 1)
        else
            self.frame:SetAlpha(1)
        end

        self.castBar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, direction)
        self.cachedDuration = duration

        local isChannel = self.channeling == true
        self.positioner:SetReverseFill(isChannel)

        if duration then
            self.positioner:SetMinMaxValues(0, duration:GetTotalDuration())
        end
        self.positioner:SetValue(0)

        self.icon:SetTexture(texture or FALLBACK_ICON)
        self.spark:Show()
        self.text:SetText(text or name or "")
        self.time:SetText("")

        self:UpdateBarColor()
        self:SetupKickCooldownBar()
        self:StartOnUpdate()
        self.frame:Show()
    end

    function M:EndCast(showHold, wasInterrupted, interruptedBy)
        if not self.frame or not self.frame:IsShown() then return end
        if self.holdTimer then return end

        local holdSettings = self.db.HoldTimer
        if not holdSettings or not holdSettings.Enabled then
            self.spark:Hide()
            self.kickTick:SetAlpha(0)
            self.secondaryKickTick:SetAlpha(0)
            self:ResetCastState()
            self.frame:Hide()
            self:StopOnUpdate()
            return
        end

        -- Show hold state
        self.spark:Hide()
        self.kickTick:SetAlpha(0)
        self.secondaryKickTick:SetAlpha(0)

        self.castBar:SetMinMaxValues(0, 1)
        self.castBar:SetValue(1)
        self.positioner:SetMinMaxValues(0, 1)
        self.positioner:SetValue(1)
        self.time:SetText("")

        local texture = self.castBar:GetStatusBarTexture()
        if wasInterrupted then
            local interrupterName = interruptedBy and self:GetColoredNameFromGUID(interruptedBy)
            if interrupterName then
                self.text:SetText(INTERRUPTED_BY:format(interrupterName))
            else
                self.text:SetText(INTERRUPTED)
            end
            local color = holdSettings.InterruptedColor or DEFAULT_INTERRUPTED_COLOR
            texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        elseif showHold then
            local color = holdSettings.FailedColor or DEFAULT_FAILED_COLOR
            texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        else
            local color = holdSettings.SuccessColor or DEFAULT_SUCCESS_COLOR
            texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        end

        self:ResetCastState()

        local duration = holdSettings.Duration or 0.5
        self.holdTimer = C_Timer.NewTimer(duration, function()
            self.holdTimer = nil
            if self.frame and not (self.casting or self.channeling or self.empowering) then
                self.frame:Hide()
                self:StopOnUpdate()
            end
        end)
    end

    --------------------------------------------------------------------
    -- Unit changed (target/focus changed)
    --------------------------------------------------------------------
    function M:OnUnitChanged()
        if UnitExists(self._unit) then
            self:StartCast()
        else
            self:ResetCastState()
            if self.holdTimer then
                self.holdTimer:Cancel()
                self.holdTimer = nil
            end
            if self.frame then self.frame:Hide() end
            self:StopOnUpdate()
        end
    end

    --------------------------------------------------------------------
    -- Preview timer
    --------------------------------------------------------------------
    function M:StartPreviewTimer()
        local duration = C_DurationUtil.CreateDuration()
        duration:SetTimeFromStart(GetTime(), PREVIEW_DURATION)
        self.castBar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate,
            Enum.StatusBarTimerDirection.ElapsedTime)

        self.cachedDuration = duration
        self.positioner:SetMinMaxValues(0, PREVIEW_DURATION)
        self.positioner:SetReverseFill(false)
        self.positioner:SetValue(0)
    end

    --------------------------------------------------------------------
    -- OnUpdate handler
    --------------------------------------------------------------------
    M.updateElapsed = 0

    function M:OnUpdate(elapsed)
        self.updateElapsed = self.updateElapsed + elapsed
        local hasActiveCast = self.casting or self.channeling or self.empowering

        if hasActiveCast then
            local duration = self.castBar:GetTimerDuration()
            if duration and self.cachedDuration then
                local primaryCD, secondaryCD = self:UpdateKickIndicator()
                self:UpdateTickPosition(duration, primaryCD, secondaryCD)
            end
        else
            self.kickTick:SetAlpha(0)
            self.secondaryKickTick:SetAlpha(0)
        end

        if self.updateElapsed < UPDATE_THROTTLE then return end

        if self.holdTimer then
            self.updateElapsed = 0
            return
        end

        local duration = self.castBar:GetTimerDuration()
        if not duration then
            self.updateElapsed = 0
            return
        end

        local remaining = duration:GetRemainingDuration()
        if not remaining then
            self.updateElapsed = 0
            return
        end

        local decimals = duration:EvaluateRemainingDuration(AE.curves.DurationDecimals)
        self.time:SetFormattedText('%.' .. decimals .. 'f', remaining)

        self.updateElapsed = 0
    end

    function M:StartOnUpdate()
        if not self.frame then return end
        self.updateElapsed = 0
        if not self.frame:GetScript("OnUpdate") then
            self.frame:SetScript("OnUpdate", function(_, elapsed) self:OnUpdate(elapsed) end)
        end
    end

    function M:StopOnUpdate()
        if not self.frame then return end
        self.frame:SetScript("OnUpdate", nil)
    end

    --------------------------------------------------------------------
    -- Preview
    --------------------------------------------------------------------
    function M:ShowPreview()
        if not self.frame then self:CreateFrame() end
        self.isPreview, self.casting = true, true
        self.icon:SetTexture(FALLBACK_ICON)
        self.text:SetText(self._previewLabel)
        self.spark:Show()
        self.kickTick:SetAlpha(0)
        self.secondaryKickTick:SetAlpha(0)
        self:UpdateBarColor()
        self:ApplySettings()
        self:StartPreviewTimer()
        self:StartOnUpdate()
        self.frame:Show()

        if self.previewTicker then self.previewTicker:Cancel() end
        self.previewTicker = C_Timer.NewTicker(PREVIEW_DURATION, function()
            if self.isPreview then
                self:StartPreviewTimer()
            end
        end)
    end

    function M:HidePreview()
        self.isPreview, self.casting = false, nil
        if self.previewTicker then
            self.previewTicker:Cancel()
            self.previewTicker = nil
        end
        if self.frame and not (self.casting or self.channeling or self.empowering) then
            self.frame:Hide()
            self:StopOnUpdate()
        end
    end

    --------------------------------------------------------------------
    -- Lifecycle
    --------------------------------------------------------------------
    function M:OnEnable()
        if not self.db.Enabled then return end
        self:CreateColorObjects()
        self:CreateFrame()
        C_Timer.After(0.5, function() self:ApplyPosition() end)

        for _, event in ipairs(CAST_EVENTS) do
            self:RegisterEvent(event, "OnCastEvent")
        end

        self:RegisterEvent(self._changedEvent, "OnUnitChanged")
        self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "CacheInterruptId")
        self:RegisterEvent("UNIT_PET", "OnUnitPet")
        self:RegisterEvent("SPELLS_CHANGED", "CacheInterruptId")
        self:RegisterEvent("LOADING_SCREEN_DISABLED", "CacheInterruptId")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "CacheInterruptId")
        self:CacheInterruptId()
    end

    function M:OnUnitPet(_, unit)
        if unit == "player" then
            self:CacheInterruptId()
        end
    end

    function M:OnDisable()
        if self.frame then
            self:StopOnUpdate()
            self.frame:Hide()
        end
        if self.holdTimer then
            self.holdTimer:Cancel()
            self.holdTimer = nil
        end
        self:ResetCastState()
        self.isPreview = false
        self:UnregisterAllEvents()
    end

    return M
end
