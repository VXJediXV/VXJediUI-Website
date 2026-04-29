-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("Gateway: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class Gateway: AceModule, AceEvent-3.0
local GATE = VXJediEssentials:NewModule("Gateway", "AceEvent-3.0")

-- Localization Setup
local C_Item = C_Item
local C_Timer = C_Timer
local IsUsableItem = C_Item.IsUsableItem
local GetItemCount = C_Item.GetItemCount

-- Constants
local GATEWAY_ITEM_ID = 188152
local UPDATE_DEBOUNCE = 0.5

-- Module state
GATE.isPreview = false

-- Update db, used for profile changes
function GATE:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.Gateway
end

-- Module init
function GATE:OnInitialize()
    self:UpdateDB()
    self.wasUsable = false
    self.hasItem = false
    self._updatePending = false
    self:SetEnabledState(false)
end

-- Module OnEnable
function GATE:OnEnable()
    if not self.db.Enabled then return end
    self:CreateAlertFrame()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "FullUpdate")
    self:RegisterEvent("BAG_UPDATE", "FullUpdate")
    self:RegisterEvent("SPELL_UPDATE_USABLE", "CheckUsable")
    self:FullUpdate()
end

-- Module OnDisable
function GATE:OnDisable()
    self:UnregisterAllEvents()
    self:HideAlert()
    self.wasUsable = false
    self.hasItem = false
    self.isPreview = false
    self._updatePending = false
end

-- Full update (debounced to handle BAG_UPDATE bursts)
function GATE:FullUpdate()
    if self._updatePending then return end
    self._updatePending = true
    C_Timer.After(UPDATE_DEBOUNCE, function()
        self._updatePending = false
        local count = GetItemCount(GATEWAY_ITEM_ID)
        self.hasItem = count and count > 0
        if self.hasItem then
            self:CheckUsable()
        else
            self:UpdateState(false)
        end
    end)
end

-- Only check usability
function GATE:CheckUsable()
    if not self.hasItem then
        self:UpdateState(false)
        return
    end
    self:UpdateState(IsUsableItem(GATEWAY_ITEM_ID) and true or false)
end

-- Handle state changes
function GATE:UpdateState(isUsable)
    if self.isPreview then return end
    if isUsable == self.wasUsable then return end
    self.wasUsable = isUsable

    if isUsable then
        self.alertFrame.text:SetText(L["GATE USABLE"])
        self.alertFrame:SetAlpha(1)
        self.alertFrame:Show()
    else
        if self.alertFrame then
            self.alertFrame:Hide()
        end
    end
    self:SendMessage("AE_GATEWAY_STATE_CHANGED", isUsable)
end

-- Create alert frame
function GATE:CreateAlertFrame()
    if self.alertFrame then return end

    local frame = AE:CreateTextFrame(UIParent, 300, 40, { name = "AE_GatewayAlert", })
    frame:Hide()

    self.alertFrame = frame
    self:ApplySettings()
    return frame
end

-- Update function for the GUI
function GATE:ApplySettings()
    if not self.alertFrame then return end
    AE:ApplyFramePosition(self.alertFrame, self.db.Position, self.db)
    AE:ApplyFontSettings(self.alertFrame, self.db, true)

    -- Update frame strata
    if self.db.Strata then
        self.alertFrame:SetFrameStrata(self.db.Strata)
    end
end

-- Preview mode support for GUI
function GATE:ShowPreview()
    if not self.alertFrame then
        self:CreateAlertFrame()
    end
    self.isPreview = true
    self.alertFrame.text:SetText(L["GATE USABLE"])
    self.alertFrame:SetAlpha(1)
    self.alertFrame:Show()
    self:ApplySettings()
end

function GATE:HidePreview()
    self.isPreview = false
    -- If module is enabled, check real state; otherwise hide
    if self.db.Enabled then
        self.wasUsable = nil -- Force state update
        self:CheckUsable()
    else
        if self.alertFrame then
            self.alertFrame:Hide()
        end
    end
end

-- Hide alert
function GATE:HideAlert()
    if self.alertFrame then
        self.alertFrame:Hide()
    end
end
