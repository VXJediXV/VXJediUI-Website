-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("CombatMessage: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class CombatMessage: AceModule, AceEvent-3.0
local CM = VXJediEssentials:NewModule("CombatMessage", "AceEvent-3.0")

-- Localization
local CreateFrame = CreateFrame
local UIFrameFadeRemoveFrame = UIFrameFadeRemoveFrame
local UIFrameFadeOut = UIFrameFadeOut
local UnitExists, UnitIsDeadOrGhost = UnitExists, UnitIsDeadOrGhost
local InCombatLockdown = InCombatLockdown
local ipairs, pairs = ipairs, pairs
local UIParent = UIParent
local C_Timer = C_Timer
local GetInventoryItemDurability = GetInventoryItemDurability
local math_max = math.max

-- Default colors (module-level constants — never reallocated)
local DEFAULT_ENTER_COLOR    = { 0.929, 0.259, 0, 1 }
local DEFAULT_EXIT_COLOR     = { 0.788, 1, 0.627, 1 }
local DEFAULT_LOWDURA_COLOR  = { 1, 0.3, 0.3, 1 }
local DEFAULT_FALLBACK_COLOR = { 1, 1, 1, 1 }

-- Equipment slots to check for durability
local EQUIP_SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }

-- Module state
CM.container = nil
CM.messageFrames = {}
CM.activeMessages = {}
CM.messageGeneration = 0
CM.isPreview = false
CM.inCombat = false

-- Update db, used for profile changes
function CM:UpdateDB()
    self.db = AE.db.profile.CombatMessage
end

-- Module init bruv
function CM:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

-- Message types
local MESSAGE_TYPES = {
    "enterCombat",
    "exitCombat",
    "lowDurability",
}

-- Get message config
local function GetMessageConfig(db, msgType)
    if msgType == "enterCombat" then
        local cfg = db.EnterCombat or {}
        return cfg.Enabled ~= false,
            cfg.Text or L["+ COMBAT +"],
            cfg.Color or DEFAULT_ENTER_COLOR
    elseif msgType == "exitCombat" then
        local cfg = db.ExitCombat or {}
        return cfg.Enabled ~= false,
            cfg.Text or L["- COMBAT -"],
            cfg.Color or DEFAULT_EXIT_COLOR
    elseif msgType == "lowDurability" then
        local cfg = db.LowDurability or {}
        return cfg.Enabled ~= false,
            cfg.Text or L["LOW DURABILITY"],
            cfg.Color or DEFAULT_LOWDURA_COLOR
    end
    return false, "", DEFAULT_FALLBACK_COLOR
end

-- Create container frame
function CM:CreateContainer()
    if self.container then return end

    local container = CreateFrame("Frame", "AE_CombatMessageContainer", UIParent)
    container:SetSize(200, 100)
    AE:ApplyFramePosition(container, self.db.Position, self.db)
    container:SetFrameLevel(100)

    self.container = container
end

-- Create or get a message frame
function CM:GetMessageFrame(msgType)
    if self.messageFrames[msgType] then
        return self.messageFrames[msgType]
    end
    local frame = CreateFrame("Frame", nil, self.container)
    frame:SetSize(200, 30)
    frame:Hide()

    local text = frame:CreateFontString(nil, "OVERLAY")
    local fontPath = AE:GetFontPath(self.db.FontFace)
    text:SetAllPoints(frame)
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetFont(fontPath, self.db.FontSize, "")

    -- Setting some min sizes
    local width, height = math_max(text:GetWidth(), 150), math_max(text:GetHeight(), 14)
    frame:SetSize(width + 5, height)

    frame.text = text
    frame.msgType = msgType
    frame.generation = 0

    self.messageFrames[msgType] = frame
    AE:ApplyFontSettings(frame, self.db, nil)

    return frame
end

-- Arrange visible messages vertically
function CM:ArrangeMessages()
    local spacing = self.db.Spacing or 4
    local yOffset = 0

    for _, msgType in ipairs(MESSAGE_TYPES) do
        local frame = self.messageFrames[msgType]
        if frame and frame:IsShown() then
            -- Only re-anchor if offset changed
            if frame._lastYOffset ~= yOffset then
                frame:ClearAllPoints()
                frame:SetPoint("TOP", self.container, "TOP", 0, -yOffset)
                frame._lastYOffset = yOffset
            end
            yOffset = yOffset + frame:GetHeight() + spacing
        end
    end

    -- Update container height
    if self.container then
        local newHeight = math_max(30, yOffset - spacing)
        if self.container._lastHeight ~= newHeight then
            self.container:SetHeight(newHeight)
            self.container._lastHeight = newHeight
        end
    end
end

-- Shared setup for both flash and persistent messages
-- Returns the prepared frame, or nil if message can't be shown
function CM:PrepareMessage(msgType)
    if not self.db or self.db.Enabled == false then return nil end
    if self.isPreview then return nil end

    local enabled, msgText, color = GetMessageConfig(self.db, msgType)
    if not enabled then return nil end

    local frame = self:GetMessageFrame(msgType)
    if not frame then return nil end

    -- Stop any existing fade
    UIFrameFadeRemoveFrame(frame)
    frame:SetScript("OnUpdate", nil)

    -- Set text and color
    frame.text:SetText(msgText)
    frame.text:SetTextColor(color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1)

    -- Show and arrange
    frame:SetAlpha(1)
    frame:Show()
    self.activeMessages[msgType] = true
    self:ArrangeMessages()

    return frame
end

-- Show a flash message
function CM:ShowFlashMessage(msgType)
    local frame = self:PrepareMessage(msgType)
    if not frame then return end

    local duration = self.db.Duration or 2.5
    frame.generation = frame.generation + 1
    local myGeneration = frame.generation

    UIFrameFadeOut(frame, duration, 1, 0)

    C_Timer.After(duration, function()
        if frame.generation == myGeneration and not self.isPreview then
            frame:Hide()
            frame._lastYOffset = nil
            self.activeMessages[msgType] = nil
            self:ArrangeMessages()
        end
    end)
end

-- Show a persistent message
function CM:ShowPersistentMessage(msgType)
    self:PrepareMessage(msgType)
end

-- Hide a persistent message
function CM:HidePersistentMessage(msgType)
    local frame = self.messageFrames[msgType]
    if frame then
        frame:Hide()
        frame._lastYOffset = nil
        self.activeMessages[msgType] = nil
        self:ArrangeMessages()
    end
end

-- Event Handlers
function CM:OnEnterCombat()
    self.inCombat = true
    self:HidePersistentMessage("lowDurability")
    self:ShowFlashMessage("enterCombat")
end

function CM:OnExitCombat()
    self.inCombat = false
    self:ShowFlashMessage("exitCombat")
    self:CheckDurability()
end

-- Check equipped gear durability (debounced to handle UPDATE_INVENTORY_DURABILITY bursts)
function CM:CheckDurability()
    if not self.db or self.db.Enabled == false then return end
    if self.isPreview then return end

    -- Debounce: schedule one check per ~0.5s window, ignoring burst events
    if self._durabilityPending then return end
    self._durabilityPending = true
    C_Timer.After(0.5, function()
        self._durabilityPending = false
        self:DoCheckDurability()
    end)
end

-- Actual durability check (called by debounced wrapper)
function CM:DoCheckDurability()
    if not self.db or self.db.Enabled == false then return end
    if self.isPreview then return end

    local cfg = self.db.LowDurability or {}
    if cfg.Enabled == false then
        self:HidePersistentMessage("lowDurability")
        return
    end

    local threshold = (cfg.Threshold or 15) / 100

    -- Don't show while in combat
    if self.inCombat then
        self:HidePersistentMessage("lowDurability")
        return
    end

    local hasLow = false
    for _, slot in ipairs(EQUIP_SLOTS) do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and maximum > 0 then
            if (current / maximum) < threshold then
                hasLow = true
                break
            end
        end
    end

    if hasLow then
        self:ShowPersistentMessage("lowDurability")
    else
        self:HidePersistentMessage("lowDurability")
    end
end


-- Settings Application
function CM:ApplySettings()
    if not self.container then return end
    AE:ApplyFramePosition(self.container, self.db.Position, self.db)

    -- Update font settings for all message frames
    for _, frame in pairs(self.messageFrames) do
        AE:ApplyFontSettings(frame, self.db, nil)
    end

    -- Update preview content if in preview mode
    if self.isPreview then
        for _, msgType in ipairs(MESSAGE_TYPES) do
            local frame = self.messageFrames[msgType]
            if frame then
                local _, msgText, msgColor = GetMessageConfig(self.db, msgType)
                frame.text:SetText(msgText)
                frame.text:SetTextColor(msgColor[1] or 1, msgColor[2] or 1, msgColor[3] or 1, msgColor[4] or 1)
            end
        end
        self:ArrangeMessages()
    end
end

-- Preview Mode
function CM:ShowPreview()
    if not self.container then
        self:CreateContainer()
    end

    self.isPreview = true

    -- Show all message types for preview to demonstrate vertical grouping
    for _, msgType in ipairs(MESSAGE_TYPES) do
        local frame = self:GetMessageFrame(msgType)
        if frame then
            local _, msgText, msgColor = GetMessageConfig(self.db, msgType)
            frame.text:SetText(msgText)
            frame.text:SetTextColor(msgColor[1] or 1, msgColor[2] or 1, msgColor[3] or 1, msgColor[4] or 1)
            frame:SetAlpha(1)
            frame:Show()
            self.activeMessages[msgType] = true
        end
    end

    self:ArrangeMessages()
end

function CM:HidePreview()
    if not self.isPreview then return end

    self.isPreview = false

    -- Hide all message frames
    for msgType, frame in pairs(self.messageFrames) do
        frame:Hide()
        self.activeMessages[msgType] = nil
    end
end

-- Module OnEnable
function CM:OnEnable()
    if not self.db.Enabled then return end

    -- Create container
    self:CreateContainer()

    -- Pre-create message frames
    for _, msgType in ipairs(MESSAGE_TYPES) do
        self:GetMessageFrame(msgType)
    end

    -- Register events
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnExitCombat")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "CheckDurability")

    -- Check initial combat state
    self.inCombat = InCombatLockdown()

    -- Single delayed init: apply settings + initial durability check
    C_Timer.After(0.5, function()
        self:ApplySettings()
        if not self.inCombat then
            self:DoCheckDurability()
        end
    end)
end

-- Module OnDisable
function CM:OnDisable()
    -- Hide all frames
    for _, frame in pairs(self.messageFrames) do
        frame:Hide()
    end
    self.activeMessages = {}
    self.isPreview = false
    self.inCombat = false

    -- Unregister events
    self:UnregisterAllEvents()
end
