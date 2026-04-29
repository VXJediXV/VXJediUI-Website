-- VXJediEssentials Missing Enchants on Character Panel
-- Shows "No Enchant" text on character panel
-- Based on BetterCharacterPanel by Jibbie
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials

local L = AE.L
if not VXJediEssentials then
    error("MissingEnchants: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class MissingEnchants: AceModule, AceEvent-3.0
local ME = VXJediEssentials:NewModule("MissingEnchants", "AceEvent-3.0")

-- Localization
local _G = _G
local pairs = pairs
local select = select
local strsplit = strsplit
local GetInventoryItemLink = GetInventoryItemLink
local GetExpansionForLevel = GetExpansionForLevel
local GetItemInfoInstant = GetItemInfoInstant
local UnitLevel = UnitLevel
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel

local INVSLOT_HEAD = INVSLOT_HEAD
local INVSLOT_SHOULDER = INVSLOT_SHOULDER
local INVSLOT_BACK = INVSLOT_BACK
local INVSLOT_CHEST = INVSLOT_CHEST
local INVSLOT_WRIST = INVSLOT_WRIST
local INVSLOT_LEGS = INVSLOT_LEGS
local INVSLOT_FEET = INVSLOT_FEET
local INVSLOT_FINGER1 = INVSLOT_FINGER1
local INVSLOT_FINGER2 = INVSLOT_FINGER2
local INVSLOT_MAINHAND = INVSLOT_MAINHAND
local INVSLOT_OFFHAND = INVSLOT_OFFHAND

-- Constants
local UPDATE_DEBOUNCE = 0.1
local NO_ENCHANT_TEXT = "|cffff0000No Enchant|r"

-- Enchantable slots per expansion
local expansionEnchantableSlots = {
    [11] = {
        [INVSLOT_MAINHAND] = true, [INVSLOT_HEAD] = true, [INVSLOT_SHOULDER] = true,
        [INVSLOT_CHEST] = true, [INVSLOT_LEGS] = true, [INVSLOT_FEET] = true,
        [INVSLOT_FINGER1] = true, [INVSLOT_FINGER2] = true,
    },
    [10] = {
        [INVSLOT_BACK] = true, [INVSLOT_CHEST] = true, [INVSLOT_WRIST] = true,
        [INVSLOT_LEGS] = true, [INVSLOT_FEET] = true, [INVSLOT_MAINHAND] = true,
        [INVSLOT_FINGER1] = true, [INVSLOT_FINGER2] = true,
    },
}

-- Slot layout side
local slotLayout = {
    [INVSLOT_HEAD] = "left", [INVSLOT_SHOULDER] = "left",
    [INVSLOT_BACK] = "left", [INVSLOT_CHEST] = "left", [INVSLOT_WRIST] = "left",
    [INVSLOT_LEGS] = "right", [INVSLOT_FEET] = "right",
    [INVSLOT_FINGER1] = "right", [INVSLOT_FINGER2] = "right",
    [INVSLOT_MAINHAND] = "center", [INVSLOT_OFFHAND] = "center",
}

-- Enchant slot buttons
local enchantSlotButtons = {
    [INVSLOT_HEAD] = "CharacterHeadSlot", [INVSLOT_SHOULDER] = "CharacterShoulderSlot",
    [INVSLOT_BACK] = "CharacterBackSlot", [INVSLOT_CHEST] = "CharacterChestSlot",
    [INVSLOT_WRIST] = "CharacterWristSlot", [INVSLOT_LEGS] = "CharacterLegsSlot",
    [INVSLOT_FEET] = "CharacterFeetSlot", [INVSLOT_FINGER1] = "CharacterFinger0Slot",
    [INVSLOT_FINGER2] = "CharacterFinger1Slot", [INVSLOT_MAINHAND] = "CharacterMainHandSlot",
    [INVSLOT_OFFHAND] = "CharacterSecondaryHandSlot",
}

-- Background texture names on CharacterModelScene
local CHARACTER_BACKGROUND_TEXTURES = {
    "BackgroundTopLeft", "BackgroundTopRight",
    "BackgroundBotLeft", "BackgroundBotRight",
    "BackgroundOverlay",
}

-- Update db, used for profile changes
function ME:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.MissingEnchants
end

-- Module init
function ME:OnInitialize()
    self:UpdateDB()
    self.enchantTexts = {}
    self.hooked = false
    self.cachedExpansion = nil
    self.cachedExpansionLevel = nil
    self._updatePending = false
    self._backgroundsHidden = false
    self._backgroundOriginalState = {}
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function HasEnchant(itemLink)
    if not itemLink then return false end
    local itemString = itemLink:match("item[%-?%d:]+")
    if not itemString then return false end
    local _, _, enchantId = strsplit(":", itemString)
    return enchantId and enchantId ~= "" and enchantId ~= "0"
end

-- Cached expansion lookup — only recomputed when level changes
function ME:GetExpansion()
    local level = UnitLevel("player")
    if self.cachedExpansionLevel ~= level then
        self.cachedExpansion = GetExpansionForLevel(level)
        self.cachedExpansionLevel = level
    end
    return self.cachedExpansion
end

function ME:CanEnchantSlot(slot)
    local expansion = self:GetExpansion()
    local slots = expansion and expansionEnchantableSlots[expansion]
    if not slots then return false end
    if slots[slot] then return true end

    if slot == INVSLOT_OFFHAND then
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local itemEquipLoc = select(4, GetItemInfoInstant(itemLink))
            return itemEquipLoc ~= "INVTYPE_HOLDABLE" and itemEquipLoc ~= "INVTYPE_SHIELD"
        end
        return false
    end
    return false
end

------------------------------------------------------------------------
-- Display
------------------------------------------------------------------------

function ME:GetFontSettings()
    local db = self.db
    local fontFace = db and db.FontFace or "Expressway"
    local fontSize = db and db.FontSize or 11
    local fontOutline = db and db.FontOutline or "OUTLINE"
    local fontPath = AE:GetFontPath(fontFace) or AE.FONT or "Fonts\\FRIZQT__.TTF"
    return fontPath, fontSize, fontOutline
end

function ME:CreateEnchantText(button, slot)
    local fontPath, fontSize, fontOutline = self:GetFontSettings()
    local text = button:CreateFontString(nil, "OVERLAY")
    text:SetFont(fontPath, fontSize, fontOutline)
    text:SetTextColor(1, 0, 0, 1)

    local side = slotLayout[slot]
    if side == "left" then
        text:SetPoint("TOPLEFT", button, "TOPRIGHT", 4, -5)
    elseif side == "right" then
        text:SetPoint("TOPRIGHT", button, "TOPLEFT", -4, -5)
    elseif side == "center" then
        if slot == INVSLOT_MAINHAND then
            text:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -4, 2)
        else
            text:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 4, 2)
        end
    end
    return text
end

function ME:ApplyFontToAll()
    local fontPath, fontSize, fontOutline = self:GetFontSettings()
    for _, text in pairs(self.enchantTexts) do
        text:SetFont(fontPath, fontSize, fontOutline)
    end
end

function ME:UpdateEnchantDisplay()
    local db = self.db
    local enchantEnabled = db and db.Enabled ~= false
    local isMaxLevel = IsLevelAtEffectiveMaxLevel(UnitLevel("player"))

    for slot, buttonName in pairs(enchantSlotButtons) do
        local button = _G[buttonName]
        if button then
            if not self.enchantTexts[slot] then
                self.enchantTexts[slot] = self:CreateEnchantText(button, slot)
            end
            local text = self.enchantTexts[slot]
            if enchantEnabled then
                local itemLink = GetInventoryItemLink("player", slot)
                if itemLink and isMaxLevel and self:CanEnchantSlot(slot) and not HasEnchant(itemLink) then
                    text:SetText(NO_ENCHANT_TEXT)
                else
                    text:SetText("")
                end
            else
                text:SetText("")
            end
        end
    end
end

-- Debounced update — collapses bursts of equipment events into one update
function ME:QueueUpdate()
    if self._updatePending then return end
    if not (CharacterFrame and CharacterFrame:IsShown()) then return end
    self._updatePending = true
    C_Timer.After(UPDATE_DEBOUNCE, function()
        self._updatePending = false
        if CharacterFrame and CharacterFrame:IsShown() then
            self:UpdateEnchantDisplay()
        end
    end)
end

------------------------------------------------------------------------
-- Character background hiding
------------------------------------------------------------------------

function ME:HideCharacterBackground()
    local scene = _G.CharacterModelScene
    if not scene then return end

    -- Save original state on first hide so we can restore later
    if not self._backgroundsHidden then
        for _, texName in pairs(CHARACTER_BACKGROUND_TEXTURES) do
            local tex = scene[texName]
            if tex then
                self._backgroundOriginalState[texName] = tex:IsShown()
            end
        end
        if scene.backdrop then
            self._backgroundOriginalState.backdrop = scene.backdrop:IsShown()
        end
        if _G.CharacterModelFrameBackgroundOverlay then
            self._backgroundOriginalState.frameOverlay = _G.CharacterModelFrameBackgroundOverlay:IsShown()
        end
    end

    for _, texName in pairs(CHARACTER_BACKGROUND_TEXTURES) do
        local tex = scene[texName]
        if tex then tex:Hide() end
    end
    if scene.backdrop then scene.backdrop:Hide() end
    if _G.CharacterModelFrameBackgroundOverlay then
        _G.CharacterModelFrameBackgroundOverlay:Hide()
    end

    self._backgroundsHidden = true
end

function ME:RestoreCharacterBackground()
    if not self._backgroundsHidden then return end
    local scene = _G.CharacterModelScene
    if not scene then return end

    for _, texName in pairs(CHARACTER_BACKGROUND_TEXTURES) do
        local tex = scene[texName]
        if tex and self._backgroundOriginalState[texName] then
            tex:Show()
        end
    end
    if scene.backdrop and self._backgroundOriginalState.backdrop then
        scene.backdrop:Show()
    end
    if _G.CharacterModelFrameBackgroundOverlay and self._backgroundOriginalState.frameOverlay then
        _G.CharacterModelFrameBackgroundOverlay:Show()
    end

    self._backgroundsHidden = false
end

------------------------------------------------------------------------
-- Hooking and events
------------------------------------------------------------------------

function ME:HookCharacterPanel()
    if self.hooked then return end
    if not PaperDollFrame then return end

    PaperDollFrame:HookScript("OnShow", function()
        ME:UpdateEnchantDisplay()
        local db = ME.db
        if db and db.HideCharacterBackground then
            ME:HideCharacterBackground()
        end
    end)

    self.hooked = true
end

-- Equipment changed handler (used for both PEC and UIC)
-- Note: only one of these is registered to avoid double-fires
function ME:OnEquipmentChanged()
    self:QueueUpdate()
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function ME:OnEnable()
    self:UpdateDB()
    self:HookCharacterPanel()

    -- Register only ONE equipment event to avoid double-firing.
    -- PLAYER_EQUIPMENT_CHANGED is the most direct signal for our use case.
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "OnEquipmentChanged")

    -- If the panel is already visible, refresh now
    if CharacterFrame and CharacterFrame:IsShown() then
        self:UpdateEnchantDisplay()
        if self.db and self.db.HideCharacterBackground then
            self:HideCharacterBackground()
        end
    end
end

function ME:OnDisable()
    self:UnregisterAllEvents()
    -- Clear all displayed text
    for _, text in pairs(self.enchantTexts) do
        text:SetText("")
    end
    -- Restore character background if we hid it
    self:RestoreCharacterBackground()
    self._updatePending = false
end

------------------------------------------------------------------------
-- Public API (preserved for GUI compatibility)
------------------------------------------------------------------------
AE.MissingEnchants = {
    Enable = function() ME:Enable() end,
    Disable = function() ME:Disable() end,
    Refresh = function()
        ME:UpdateDB()
        ME:HookCharacterPanel()
        ME:ApplyFontToAll()
        if CharacterFrame and CharacterFrame:IsShown() then
            ME:UpdateEnchantDisplay()
            if ME.db and ME.db.HideCharacterBackground then
                ME:HideCharacterBackground()
            else
                ME:RestoreCharacterBackground()
            end
        end
    end,
    ApplyFont = function() ME:ApplyFontToAll() end,
}
