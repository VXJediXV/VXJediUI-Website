-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("Automation: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class Automation: AceModule, AceEvent-3.0, AceHook-3.0
local AUTO = VXJediEssentials:NewModule("Automation", "AceEvent-3.0", "AceHook-3.0")

------------------------------------------------------------------------
-- Upvalues
------------------------------------------------------------------------
local pcall = pcall
local select = select
local ipairs = ipairs
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_Container = C_Container
local C_Item = C_Item
local C_CVar = C_CVar
local C_GossipInfo = C_GossipInfo
local C_FriendList = C_FriendList
local C_BattleNet = C_BattleNet
local C_PetBattles = C_PetBattles
local RepairAllItems = RepairAllItems
local CanMerchantRepair = CanMerchantRepair
local GetRepairAllCost = GetRepairAllCost
local CanGuildBankRepair = CanGuildBankRepair
local IsInGuild = IsInGuild
local AcceptQuest = AcceptQuest
local CompleteQuest = CompleteQuest
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestReward = GetQuestReward
local IsQuestCompletable = IsQuestCompletable
local GetNumActiveQuests = GetNumActiveQuests
local GetActiveTitle = GetActiveTitle
local SelectActiveQuest = SelectActiveQuest
local GetNumAvailableQuests = GetNumAvailableQuests
local SelectAvailableQuest = SelectAvailableQuest
local QuestGetAutoAccept = QuestGetAutoAccept
local CloseQuest = CloseQuest
local ConfirmAcceptQuest = ConfirmAcceptQuest
local StaticPopup_Hide = StaticPopup_Hide
local StaticPopupDialogs = StaticPopupDialogs
local CancelDuel = CancelDuel
local AcceptResurrect = AcceptResurrect
local UnitAffectingCombat = UnitAffectingCombat
local InCombatLockdown = InCombatLockdown
local IsEncounterInProgress = IsEncounterInProgress
local UnitIsDead = UnitIsDead
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local CinematicFrame_CancelCinematic = CinematicFrame_CancelCinematic
local GameMovieFinished = GameMovieFinished
local _G = _G

------------------------------------------------------------------------
-- Module lifecycle
------------------------------------------------------------------------
function AUTO:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.Automation
end

function AUTO:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Friend check (don't decline duels from friends/BNet friends)
------------------------------------------------------------------------
local function IsFriend(name)
    if not name then return false end
    -- Check regular friends list
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.name == name then return true end
    end
    -- Check BNet friends
    for i = 1, BNGetNumFriends() do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.gameAccountInfo then
            local charName = accountInfo.gameAccountInfo.characterName
            if charName and charName == name then return true end
        end
    end
    return false
end

------------------------------------------------------------------------
-- Skip Cinematics
------------------------------------------------------------------------
local cinematicFrame = nil
local function SetupSkipCinematics()
    if not cinematicFrame then
        cinematicFrame = CreateFrame("Frame")
        cinematicFrame:SetScript("OnEvent", function(_, event)
            if event == "CINEMATIC_START" then
                CinematicFrame_CancelCinematic()
            elseif event == "PLAY_MOVIE" then
                pcall(GameMovieFinished)
            end
        end)
    end
    if AUTO.db.SkipCinematics then
        cinematicFrame:RegisterEvent("CINEMATIC_START")
        cinematicFrame:RegisterEvent("PLAY_MOVIE")
    else
        cinematicFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Hide Talking Head
------------------------------------------------------------------------
function AUTO:SetupTalkingHeadHider()
    if self._talkingHeadHooked then return end
    local function HideTalkingHead(frame)
        if AUTO.db and AUTO.db.HideTalkingHead and frame then
            frame:Hide()
        end
    end
    if _G.TalkingHeadFrame then
        self:SecureHook(_G.TalkingHeadFrame, "PlayCurrent", HideTalkingHead)
        self:SecureHook(_G.TalkingHeadFrame, "Reset", HideTalkingHead)
    else
        self:SecureHook("TalkingHead_LoadUI", function()
            if _G.TalkingHeadFrame then
                self:SecureHook(_G.TalkingHeadFrame, "PlayCurrent", HideTalkingHead)
                self:SecureHook(_G.TalkingHeadFrame, "Reset", HideTalkingHead)
            end
        end)
    end
    self._talkingHeadHooked = true
end

------------------------------------------------------------------------
-- Sell Junk (iterative ticker to avoid server throttling)
------------------------------------------------------------------------
local sellJunkFrame = nil
local sellJunkTicker = nil

local function StopSelling()
    if sellJunkTicker then sellJunkTicker._cancelled = true end
end

local function SellJunkIteration()
    if not MerchantFrame:IsShown() then StopSelling(); return end

    local soldCount = 0
    for bagID = 0, 5 do
        for slot = 1, C_Container.GetContainerNumSlots(bagID) do
            local itemLink = C_Container.GetContainerItemLink(bagID, slot)
            if itemLink then
                local _, _, itemQuality = C_Item.GetItemInfo(itemLink)
                local itemSellPrice = select(11, C_Item.GetItemInfo(itemLink))
                if itemQuality == 0 and itemSellPrice and itemSellPrice > 0 then
                    C_Container.UseContainerItem(bagID, slot)
                    soldCount = soldCount + 1
                end
            end
        end
    end

    if soldCount == 0 then StopSelling() end
end

local function StartSellTicker()
    StopSelling()
    local iterations = 100
    sellJunkTicker = { _cancelled = false, _remainingIterations = iterations }
    local function tick()
        if sellJunkTicker._cancelled then return end
        SellJunkIteration()
        sellJunkTicker._remainingIterations = sellJunkTicker._remainingIterations - 1
        if sellJunkTicker._remainingIterations > 0 and not sellJunkTicker._cancelled then
            C_Timer.After(0.2, tick)
        end
    end
    C_Timer.After(0.2, tick)
end

local function SetupAutoSellRepair()
    if not sellJunkFrame then
        sellJunkFrame = CreateFrame("Frame")
        sellJunkFrame:SetScript("OnEvent", function(_, event)
            if event ~= "MERCHANT_SHOW" then return end

            -- Auto sell junk
            if AUTO.db.AutoSellJunk then
                StartSellTicker()
            end

            -- Auto repair (with guild funds fallback)
            if AUTO.db.AutoRepair and CanMerchantRepair() then
                local repairCost, canRepair = GetRepairAllCost()
                if canRepair and repairCost > 0 then
                    if AUTO.db.UseGuildFunds and IsInGuild() and CanGuildBankRepair() then
                        -- Try guild funds first, then personal as fallback
                        RepairAllItems(true)
                        RepairAllItems(false)
                    else
                        RepairAllItems(false)
                    end
                end
            end
        end)
    end
    if AUTO.db.AutoSellJunk or AUTO.db.AutoRepair then
        sellJunkFrame:RegisterEvent("MERCHANT_SHOW")
    else
        sellJunkFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Auto Role Check
------------------------------------------------------------------------
local function SetupAutoRoleCheck()
    -- Auto accept LFD role check
    if LFDRoleCheckPopup and not AUTO._lfdHooked then
        AUTO._lfdHooked = true
        LFDRoleCheckPopup:HookScript("OnShow", function()
            if AUTO.db and AUTO.db.AutoRoleCheck and LFDRoleCheckPopupAcceptButton then
                LFDRoleCheckPopupAcceptButton:Click()
            end
        end)
    end

    -- Auto sign up in Group Finder application dialog
    if LFGListApplicationDialog and not AUTO._lfgAppHooked then
        AUTO._lfgAppHooked = true
        LFGListApplicationDialog:HookScript("OnShow", function()
            if not AUTO.db or not AUTO.db.AutoRoleCheck then return end
            local dialog = LFGListApplicationDialog
            if dialog.SignUpButton and dialog.SignUpButton:IsEnabled() then
                dialog.SignUpButton:Click()
            end
        end)
    end
end

------------------------------------------------------------------------
-- Auto-Fill Delete (hides editbox, enables button directly)
------------------------------------------------------------------------
local function SetupAutoFillDelete()
    if AUTO._deleteHooked then return end
    AUTO._deleteHooked = true

    local easyDelFrame = CreateFrame("Frame")
    easyDelFrame:RegisterEvent("DELETE_ITEM_CONFIRM")
    easyDelFrame:SetScript("OnEvent", function()
        if not AUTO.db or not AUTO.db.AutoFillDelete then return end
        if StaticPopup1EditBox and StaticPopup1EditBox:IsShown() then
            StaticPopup1EditBox:Hide()
            StaticPopup1Button1:Enable()
        end
    end)
end

------------------------------------------------------------------------
-- Auto Loot CVar
------------------------------------------------------------------------
local function ApplyAutoLoot()
    if AUTO.db.AutoLoot then
        C_CVar.SetCVar("autoLootDefault", "1")
    end
end

------------------------------------------------------------------------
-- Quest Automation
------------------------------------------------------------------------
local function IsQuestModifierHeld()
    local mod = AUTO.db.QuestModifier
    if not mod or mod == "" or mod == "NONE" then return false end
    if mod == "CTRL" then return IsControlKeyDown() end
    if mod == "ALT" then return IsAltKeyDown() end
    if mod == "SHIFT" then return IsShiftKeyDown() end
    return false
end

local function ShouldSkipQuestAutomation()
    if AUTO.db.QuestModifierInvert then
        return not IsQuestModifierHeld()
    else
        return IsQuestModifierHeld()
    end
end

-- Safety: don't auto-complete quests that require currency
local function QuestRequiresCurrency()
    for i = 1, 6 do
        local progItem = _G["QuestProgressItem" .. i]
        if progItem and progItem:IsShown() and progItem.type == "required" and progItem.objectType == "currency" then
            return true
        end
    end
    return false
end

-- Safety: don't auto-complete quests that require gold
local function QuestRequiresGold()
    local requiredMoney = GetQuestMoneyToGet and GetQuestMoneyToGet() or 0
    return requiredMoney > 0
end

-- Safety: don't auto-select gossip options with color codes (like "skip ahead")
local function HasColoredGossipOption()
    local gossipOptions = C_GossipInfo.GetOptions()
    for i = 1, #gossipOptions do
        local nameText = gossipOptions[i].name
        if nameText then
            local upper = strupper(nameText)
            if string.find(upper, "|C") or string.find(upper, "<") then
                if not string.find(nameText, "FF0008E8") then
                    return true
                end
            end
        end
    end
    return false
end

local questFrame = nil
local function SetupAutoQuests()
    if not questFrame then
        questFrame = CreateFrame("Frame")
        questFrame:SetScript("OnEvent", function(_, event, arg1)
            -- Clear progress items when quest interaction ends
            if event == "QUEST_FINISHED" then
                for i = 1, 6 do
                    local progItem = _G["QuestProgressItem" .. i]
                    if progItem and progItem:IsShown() then
                        progItem:Hide()
                    end
                end
                return
            end

            -- Check modifier key
            if ShouldSkipQuestAutomation() then return end

            ----------------------------------------------------------------
            -- Accept quests
            ----------------------------------------------------------------
            if event == "QUEST_DETAIL" then
                if AUTO.db.AutoAcceptQuests then
                    if QuestGetAutoAccept() then
                        CloseQuest()
                    else
                        AcceptQuest()
                    end
                end

            elseif event == "QUEST_ACCEPT_CONFIRM" then
                if AUTO.db.AutoAcceptQuests then
                    ConfirmAcceptQuest()
                    StaticPopup_Hide("QUEST_ACCEPT")
                end

            ----------------------------------------------------------------
            -- Turn in quests
            ----------------------------------------------------------------
            elseif event == "QUEST_PROGRESS" then
                if AUTO.db.AutoTurnInQuests and IsQuestCompletable() then
                    if QuestRequiresCurrency() then return end
                    if QuestRequiresGold() then return end
                    CompleteQuest()
                end

            elseif event == "QUEST_COMPLETE" then
                if AUTO.db.AutoTurnInQuests then
                    if QuestRequiresCurrency() then return end
                    if QuestRequiresGold() then return end
                    if GetNumQuestChoices() <= 1 then
                        GetQuestReward(GetNumQuestChoices())
                    end
                end

            elseif event == "QUEST_AUTOCOMPLETE" then
                if AUTO.db.AutoTurnInQuests then
                    local index = C_QuestLog.GetLogIndexForQuestID(arg1)
                    if index then
                        local info = C_QuestLog.GetInfo(index)
                        if info and info.isAutoComplete then
                            C_QuestLog.SetSelectedQuest(C_QuestLog.GetQuestIDForLogIndex(index))
                            ShowQuestComplete(C_QuestLog.GetSelectedQuest())
                        end
                    end
                end

            ----------------------------------------------------------------
            -- Select quests from NPC lists
            ----------------------------------------------------------------
            elseif event == "QUEST_GREETING" then
                if AUTO.db.AutoTurnInQuests then
                    for i = 1, GetNumActiveQuests() do
                        local title, isComplete = GetActiveTitle(i)
                        if title and isComplete then
                            return SelectActiveQuest(i)
                        end
                    end
                end
                if AUTO.db.AutoAcceptQuests then
                    for i = 1, GetNumAvailableQuests() do
                        local title = select(1, GetAvailableTitle(i))
                        if title then
                            return SelectAvailableQuest(i)
                        end
                    end
                end

            elseif event == "GOSSIP_SHOW" then
                if HasColoredGossipOption() then return end

                if AUTO.db.AutoTurnInQuests then
                    local activeQuests = C_GossipInfo.GetActiveQuests()
                    for _, quest in ipairs(activeQuests) do
                        if quest.title and quest.isComplete and quest.questID then
                            return C_GossipInfo.SelectActiveQuest(quest.questID)
                        end
                    end
                end
                if AUTO.db.AutoAcceptQuests then
                    local availableQuests = C_GossipInfo.GetAvailableQuests()
                    for _, quest in ipairs(availableQuests) do
                        if quest.questID then
                            return C_GossipInfo.SelectAvailableQuest(quest.questID)
                        end
                    end
                end
            end
        end)
    end

    -- Register/unregister events based on settings
    if AUTO.db.AutoAcceptQuests or AUTO.db.AutoTurnInQuests then
        questFrame:RegisterEvent("QUEST_DETAIL")
        questFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
        questFrame:RegisterEvent("QUEST_PROGRESS")
        questFrame:RegisterEvent("QUEST_COMPLETE")
        questFrame:RegisterEvent("QUEST_GREETING")
        questFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
        questFrame:RegisterEvent("QUEST_FINISHED")
        questFrame:RegisterEvent("GOSSIP_SHOW")
    else
        questFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Decline Duels (with friend check)
------------------------------------------------------------------------
local duelFrame = nil
local function SetupAutoDeclineDuels()
    if not duelFrame then
        duelFrame = CreateFrame("Frame")
        duelFrame:SetScript("OnEvent", function(_, _, name)
            if AUTO.db and AUTO.db.AutoDeclineDuels then
                if not IsFriend(name) then
                    CancelDuel()
                    StaticPopup_Hide("DUEL_REQUESTED")
                end
            end
        end)
    end
    if AUTO.db.AutoDeclineDuels then
        duelFrame:RegisterEvent("DUEL_REQUESTED")
    else
        duelFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Decline Pet Battle Duels (with friend check)
------------------------------------------------------------------------
local petDuelFrame = nil
local function SetupAutoDeclinePetBattles()
    if not petDuelFrame then
        petDuelFrame = CreateFrame("Frame")
        petDuelFrame:SetScript("OnEvent", function(_, _, name)
            if AUTO.db and AUTO.db.AutoDeclinePetBattles then
                if not IsFriend(name) then
                    C_PetBattles.CancelPVPDuel()
                end
            end
        end)
    end
    if AUTO.db.AutoDeclinePetBattles then
        petDuelFrame:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
    else
        petDuelFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Auto Filter AH to Current Expansion
------------------------------------------------------------------------
local ahFrame = nil
local craftingOrdersHooked = false
local function SetupAHCurrentExpansion()
    if not ahFrame then
        ahFrame = CreateFrame("Frame")
        ahFrame:SetScript("OnEvent", function(_, event)
            if not AUTO.db or not AUTO.db.AHCurrentExpansion then return end
            if event == "AUCTION_HOUSE_SHOW" then
                C_Timer.After(0, function()
                    if AuctionHouseFrame and AuctionHouseFrame.SearchBar then
                        local filterBtn = AuctionHouseFrame.SearchBar.FilterButton
                        if filterBtn and filterBtn.filters then
                            filterBtn.filters[Enum.AuctionHouseFilter.CurrentExpansionOnly] = true
                            AuctionHouseFrame.SearchBar:UpdateClearFiltersButton()
                        end
                    end
                end)
            elseif event == "CRAFTINGORDERS_SHOW_CUSTOMER" then
                if craftingOrdersHooked then return end
                local filterDropdown = ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.FilterDropdown
                local function onShow()
                    if not AUTO.db or not AUTO.db.AHCurrentExpansion then return end
                    filterDropdown.filters[Enum.AuctionHouseFilter.CurrentExpansionOnly] = true
                    filterDropdown:ValidateResetState()
                end
                filterDropdown:HookScript("OnShow", function() C_Timer.After(0, onShow) end)
                C_Timer.After(0, onShow)
                craftingOrdersHooked = true
            end
        end)
    end
    if AUTO.db.AHCurrentExpansion then
        ahFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
        ahFrame:RegisterEvent("CRAFTINGORDERS_SHOW_CUSTOMER")
    else
        ahFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Auto Accept Resurrection
--
-- Refuses to auto-accept under ANY of these conditions:
--   * Player is in combat (UnitAffectingCombat)
--   * Combat lockdown is active (InCombatLockdown)
--   * A boss encounter is in progress (IsEncounterInProgress)
--     ^ This is the critical one for Battle Rez scenarios — when you die
--       during a raid boss fight, you're not "in combat" anymore (corpses
--       aren't), but the encounter is still active. Without this check,
--       a Druid's Rebirth would silently auto-accept and pull you back
--       into the fight against your will.
--   * The sender is dead (can't trust a rez from a corpse)
------------------------------------------------------------------------
local resFrame = nil
local function SetupAutoAcceptRes()
    if not resFrame then
        resFrame = CreateFrame("Frame")
        resFrame:SetScript("OnEvent", function(_, event, sender)
            if event ~= "RESURRECT_REQUEST" then return end
            if not AUTO.db or not AUTO.db.AutoAcceptRes then return end
            -- Refuse during any form of active combat
            if UnitAffectingCombat("player") then return end
            if InCombatLockdown() then return end
            if IsEncounterInProgress() then return end
            if sender and UnitIsDead(sender) then return end
            AcceptResurrect()
            StaticPopup_Hide("RESURRECT_NO_TIMER")
        end)
    end
    if AUTO.db.AutoAcceptRes then
        resFrame:RegisterEvent("RESURRECT_REQUEST")
    else
        resFrame:UnregisterAllEvents()
    end
end

------------------------------------------------------------------------
-- Apply / Enable
------------------------------------------------------------------------
function AUTO:ApplySettings()
    if not self.db.Enabled then return end
    SetupSkipCinematics()
    self:SetupTalkingHeadHider()
    SetupAutoSellRepair()
    SetupAutoRoleCheck()
    SetupAutoFillDelete()
    ApplyAutoLoot()
    SetupAutoQuests()
    SetupAutoDeclineDuels()
    SetupAutoDeclinePetBattles()
    SetupAHCurrentExpansion()
    SetupAutoAcceptRes()
end

function AUTO:OnEnable()
    if not self.db.Enabled then return end
    C_Timer.After(1.0, function()
        AUTO:ApplySettings()
    end)
end
