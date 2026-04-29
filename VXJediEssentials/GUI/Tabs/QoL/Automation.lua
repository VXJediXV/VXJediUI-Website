-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local table_insert = table.insert
local ipairs = ipairs

local L = AE.L
local function GetAutomationModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("Automation", true)
    end
    return nil
end

GUIFrame:RegisterContent("Automation", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous.Automation
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local AUTO = GetAutomationModule()
    local function ApplySettings()
        if AUTO then AUTO:ApplySettings() end
    end
    local allWidgets = {}
    local function ApplyAutomationState(enabled)
        if not AUTO then return end
        AUTO.db.Enabled = enabled
        if enabled then VXJediEssentials:EnableModule("Automation")
        else VXJediEssentials:DisableModule("Automation") end
    end
    local function UpdateAllWidgetStates()
        local mainEnabled = db.Enabled ~= false
        for _, widget in ipairs(allWidgets) do
            if widget.SetEnabled then widget:SetEnabled(mainEnabled) end
        end
    end

    -- Card 1: Enable
    local card1 = GUIFrame:CreateCard(scrollChild, L["Automation"], yOffset)
    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Automation"], db.Enabled ~= false,
        function(checked) db.Enabled = checked; ApplyAutomationState(checked); UpdateAllWidgetStates() end,
        true, L["Automation"], L["On"], L["Off"])
    row1:AddWidget(enableCheck, 0.5)
    card1:AddRow(row1, 36)
    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    -- Card 2: Cinematics and Dialogs
    local card2 = GUIFrame:CreateCard(scrollChild, L["Cinematics & Dialogs"], yOffset)
    table_insert(allWidgets, card2)
    local row2a = GUIFrame:CreateRow(card2.content, 40)
    local skipCinematicsCheck = GUIFrame:CreateCheckbox(row2a, L["Skip Cinematics & Movies"], db.SkipCinematics ~= false,
        function(checked) db.SkipCinematics = checked; ApplySettings() end)
    row2a:AddWidget(skipCinematicsCheck, 1)
    table_insert(allWidgets, skipCinematicsCheck)
    card2:AddRow(row2a, 40)
    local row2b = GUIFrame:CreateRow(card2.content, 34)
    local hideTalkingHeadCheck = GUIFrame:CreateCheckbox(row2b, L["Hide Talking Head Frame"], db.HideTalkingHead ~= false,
        function(checked) db.HideTalkingHead = checked; ApplySettings() end)
    row2b:AddWidget(hideTalkingHeadCheck, 1)
    table_insert(allWidgets, hideTalkingHeadCheck)
    card2:AddRow(row2b, 34)
    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    -- Card 3: Merchant Automation
    local card3 = GUIFrame:CreateCard(scrollChild, L["Merchant Automation"], yOffset)
    table_insert(allWidgets, card3)
    local row3a = GUIFrame:CreateRow(card3.content, 40)
    local autoSellCheck = GUIFrame:CreateCheckbox(row3a, L["Auto Sell Junk (Grey Items)"], db.AutoSellJunk ~= false,
        function(checked) db.AutoSellJunk = checked; ApplySettings() end)
    row3a:AddWidget(autoSellCheck, 1)
    table_insert(allWidgets, autoSellCheck)
    card3:AddRow(row3a, 40)
    local row3b = GUIFrame:CreateRow(card3.content, 40)
    local autoRepairCheck = GUIFrame:CreateCheckbox(row3b, L["Auto Repair Gear"], db.AutoRepair ~= false,
        function(checked) db.AutoRepair = checked; ApplySettings() end)
    row3b:AddWidget(autoRepairCheck, 1)
    table_insert(allWidgets, autoRepairCheck)
    card3:AddRow(row3b, 40)
    local row3c = GUIFrame:CreateRow(card3.content, 34)
    local useGuildCheck = GUIFrame:CreateCheckbox(row3c, L["Use Guild Funds for Repair"], db.UseGuildFunds ~= false,
        function(checked) db.UseGuildFunds = checked; ApplySettings() end)
    row3c:AddWidget(useGuildCheck, 1)
    table_insert(allWidgets, useGuildCheck)
    card3:AddRow(row3c, 34)
    local row3d = GUIFrame:CreateRow(card3.content, 34)
    local ahExpansionCheck = GUIFrame:CreateCheckbox(row3d, L["Auto Filter AH to Current Expansion"], db.AHCurrentExpansion == true,
        function(checked) db.AHCurrentExpansion = checked; ApplySettings() end)
    row3d:AddWidget(ahExpansionCheck, 1)
    table_insert(allWidgets, ahExpansionCheck)
    card3:AddRow(row3d, 34)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    -- Card 4: Group Finder
    local card4 = GUIFrame:CreateCard(scrollChild, L["Group Finder"], yOffset)
    table_insert(allWidgets, card4)
    local row4 = GUIFrame:CreateRow(card4.content, 34)
    local autoRoleCheck = GUIFrame:CreateCheckbox(row4, L["Auto Accept Role Check"], db.AutoRoleCheck ~= false,
        function(checked) db.AutoRoleCheck = checked; ApplySettings() end)
    row4:AddWidget(autoRoleCheck, 1)
    table_insert(allWidgets, autoRoleCheck)
    card4:AddRow(row4, 34)

    card4:AddLabel("|cff888888" .. L["TIP_AutoRoleCheck"] .. "|r")

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    -- Card 5: Quest Automation
    local card5 = GUIFrame:CreateCard(scrollChild, L["Quest Automation"], yOffset)
    table_insert(allWidgets, card5)
    local row5a = GUIFrame:CreateRow(card5.content, 40)
    local autoAcceptCheck = GUIFrame:CreateCheckbox(row5a, L["Auto Accept Quests"], db.AutoAcceptQuests == true,
        function(checked) db.AutoAcceptQuests = checked; ApplySettings() end)
    row5a:AddWidget(autoAcceptCheck, 1)
    table_insert(allWidgets, autoAcceptCheck)
    card5:AddRow(row5a, 40)
    local row5b = GUIFrame:CreateRow(card5.content, 34)
    local autoTurnInCheck = GUIFrame:CreateCheckbox(row5b, L["Auto Turn In Quests"], db.AutoTurnInQuests == true,
        function(checked) db.AutoTurnInQuests = checked; ApplySettings() end)
    row5b:AddWidget(autoTurnInCheck, 1)
    table_insert(allWidgets, autoTurnInCheck)
    card5:AddRow(row5b, 34)
    local row5c = GUIFrame:CreateRow(card5.content, 36)
    local modifierOptions = {
        { value = "SHIFT", text = "Shift" },
        { value = "CTRL", text = "Ctrl" },
        { value = "ALT", text = "Alt" },
        { value = "NONE", text = L["None"] },
    }
    local currentMod = db.QuestModifier or "SHIFT"
    local modDropdown = GUIFrame:CreateDropdown(row5c, L["Hold to Pause Auto-Quest"], modifierOptions,
        currentMod, nil, function(val) db.QuestModifier = val end)
    row5c:AddWidget(modDropdown, 1)
    table_insert(allWidgets, modDropdown)
    card5:AddRow(row5c, 36)
    local row5d = GUIFrame:CreateRow(card5.content, 34)
    local invertCheck = GUIFrame:CreateCheckbox(row5d, L["Invert Modifier"], db.QuestModifierInvert == true,
        function(checked) db.QuestModifierInvert = checked; ApplySettings() end)
    row5d:AddWidget(invertCheck, 1)
    table_insert(allWidgets, invertCheck)
    card5:AddRow(row5d, 34)
    card5:AddLabel("|cff888888" .. L["TIP_QuestModifier"] .. "|r")
    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    -- Card 6: Social
    local card6 = GUIFrame:CreateCard(scrollChild, L["Social"], yOffset)
    table_insert(allWidgets, card6)
    local row6a = GUIFrame:CreateRow(card6.content, 40)
    local autoDeclineDuelsCheck = GUIFrame:CreateCheckbox(row6a, L["Auto Decline Duels"], db.AutoDeclineDuels == true,
        function(checked) db.AutoDeclineDuels = checked; ApplySettings() end)
    row6a:AddWidget(autoDeclineDuelsCheck, 1)
    table_insert(allWidgets, autoDeclineDuelsCheck)
    card6:AddRow(row6a, 40)
    local row6b = GUIFrame:CreateRow(card6.content, 34)
    local autoDeclinePetCheck = GUIFrame:CreateCheckbox(row6b, L["Auto Decline Pet Battle Duels"], db.AutoDeclinePetBattles == true,
        function(checked) db.AutoDeclinePetBattles = checked; ApplySettings() end)
    row6b:AddWidget(autoDeclinePetCheck, 1)
    table_insert(allWidgets, autoDeclinePetCheck)
    card6:AddRow(row6b, 34)
    local row6c = GUIFrame:CreateRow(card6.content, 34)
    local autoResCheck = GUIFrame:CreateCheckbox(row6c, L["Auto Accept Resurrection"], db.AutoAcceptRes == true,
        function(checked) db.AutoAcceptRes = checked; ApplySettings() end)
    row6c:AddWidget(autoResCheck, 1)
    table_insert(allWidgets, autoResCheck)
    card6:AddRow(row6c, 34)
    yOffset = yOffset + card6:GetContentHeight() + Theme.paddingSmall

    -- Card 7: Convenience
    local card7 = GUIFrame:CreateCard(scrollChild, L["Convenience"], yOffset)
    table_insert(allWidgets, card7)
    local row7a = GUIFrame:CreateRow(card7.content, 40)
    local autoFillDeleteCheck = GUIFrame:CreateCheckbox(row7a, L["Auto-Fill DELETE Text"], db.AutoFillDelete ~= false,
        function(checked) db.AutoFillDelete = checked; ApplySettings() end)
    row7a:AddWidget(autoFillDeleteCheck, 1)
    table_insert(allWidgets, autoFillDeleteCheck)
    card7:AddRow(row7a, 40)
    local row7b = GUIFrame:CreateRow(card7.content, 34)
    local autoLootCheck = GUIFrame:CreateCheckbox(row7b, L["Auto Loot"], db.AutoLoot ~= false,
        function(checked) db.AutoLoot = checked; ApplySettings() end)
    row7b:AddWidget(autoLootCheck, 1)
    table_insert(allWidgets, autoLootCheck)
    card7:AddRow(row7b, 34)
    local fasterLootDb = AE.db and AE.db.profile.FasterLoot
    if fasterLootDb then
        local row7c = GUIFrame:CreateRow(card7.content, 34)
        local fasterLootCheck = GUIFrame:CreateCheckbox(row7c, L["Faster Auto Loot"],
            fasterLootDb.Enabled == true,
            function(checked)
                fasterLootDb.Enabled = checked
                if AE.FasterLoot then AE.FasterLoot.Refresh() end
            end)
        row7c:AddWidget(fasterLootCheck, 1)
        table_insert(allWidgets, fasterLootCheck)
        card7:AddRow(row7c, 34)
    end
    yOffset = yOffset + card7:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 2)
    return yOffset
end)
