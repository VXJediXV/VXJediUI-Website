-- VXJediEssentials Faster Auto Loot
-- Instantly loots all items when loot window opens
---@class AE
local AE = select(2, ...)

if not VXJediEssentials then return end

local CreateFrame = CreateFrame
local GetNumLootItems = GetNumLootItems
local LootSlot = LootSlot
local GetCVarBool = GetCVarBool
local IsModifiedClick = IsModifiedClick
local GetCursorInfo = GetCursorInfo
local GetTime = GetTime

local lastLootTime = 0

local function ShouldAutoLoot()
    local autoLootOn = GetCVarBool("autoLootDefault")
    local modifierHeld = IsModifiedClick("AUTOLOOTTOGGLE")
    if autoLootOn then
        return not modifierHeld
    else
        return modifierHeld
    end
end

local function CollectLoot()
    local db = AE.db and AE.db.profile.FasterLoot
    if not db or not db.Enabled then return end
    if not ShouldAutoLoot() then return end

    local now = GetTime()
    if now - lastLootTime < 0.2 then return end
    lastLootTime = now

    if GetCursorInfo() then return end

    -- TSM compatibility: don't interfere with TradeSkillMaster destroy flow
    if TSMDestroyBtn and TSMDestroyBtn:IsShown() and TSMDestroyBtn:GetButtonState() == "DISABLED" then return end

    -- Iterate in reverse to avoid index shifting when slots are looted
    for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
    end
end

local lootFrame = CreateFrame("Frame", "AE_FasterLoot")
lootFrame:RegisterEvent("PLAYER_LOGIN")

lootFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        local db = AE.db and AE.db.profile.FasterLoot
        if db and db.Enabled then
            self:RegisterEvent("LOOT_READY")
        end
        self:UnregisterEvent("PLAYER_LOGIN")
        return
    end

    if event == "LOOT_READY" then
        CollectLoot()
    end
end)

-- Public API for toggling
AE.FasterLoot = {
    Enable = function()
        lootFrame:RegisterEvent("LOOT_READY")
    end,
    Disable = function()
        lootFrame:UnregisterEvent("LOOT_READY")
    end,
    Refresh = function()
        local db = AE.db and AE.db.profile.FasterLoot
        if db and db.Enabled then
            lootFrame:RegisterEvent("LOOT_READY")
        else
            lootFrame:UnregisterEvent("LOOT_READY")
        end
    end,
}
