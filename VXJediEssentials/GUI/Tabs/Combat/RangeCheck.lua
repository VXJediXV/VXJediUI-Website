-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local L = AE.L

local ipairs = ipairs
local table_insert = table.insert

local function GetModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("RangeCheck", true)
    end
    return nil
end

GUIFrame:RegisterContent("RangeCheck", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.RangeCheck
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel("Database not available")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local RC = GetModule()
    local allWidgets = {}

    local function ApplySettings()
        if RC then RC:ApplySettings() end
    end

    local function ApplyPosition()
        if RC then RC:ApplyPosition() end
    end

    local function ApplyModuleState(enabled)
        if not RC then return end
        RC.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("RangeCheck")
        else
            VXJediEssentials:DisableModule("RangeCheck")
        end
    end

    local function UpdateAllWidgetStates()
        local mainEnabled = db.Enabled ~= false
        for _, widget in ipairs(allWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(mainEnabled)
            end
        end
    end

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Range Check"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Range Check"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyModuleState(checked)
            UpdateAllWidgetStates()
        end,
        true, "Range Check", L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    local row2a = GUIFrame:CreateRow(card2.content, 36)
    local combatOnlyCheck = GUIFrame:CreateCheckbox(row2a, L["Only Show in Combat"], db.CombatOnly == true,
        function(checked)
            db.CombatOnly = checked
        end)
    row2a:AddWidget(combatOnlyCheck, 0.5)
    table_insert(allWidgets, combatOnlyCheck)

    local friendlyCheck = GUIFrame:CreateCheckbox(row2a, L["Include Friendly Targets"], db.IncludeFriendlies == true,
        function(checked)
            db.IncludeFriendlies = checked
        end)
    row2a:AddWidget(friendlyCheck, 0.5)
    table_insert(allWidgets, friendlyCheck)
    card2:AddRow(row2a, 36)

    local row2b = GUIFrame:CreateRow(card2.content, 36)
    local hideSuffixCheck = GUIFrame:CreateCheckbox(row2b, L["Hide 'yd' Suffix"], db.HideSuffix == true,
        function(checked)
            db.HideSuffix = checked
        end)
    row2b:AddWidget(hideSuffixCheck, 0.5)
    table_insert(allWidgets, hideSuffixCheck)

    local rangeColorCheck = GUIFrame:CreateCheckbox(row2b, L["Color by Range"], db.UseRangeColors ~= false,
        function(checked)
            db.UseRangeColors = checked
        end)
    row2b:AddWidget(rangeColorCheck, 0.5)
    table_insert(allWidgets, rangeColorCheck)
    card2:AddRow(row2b, 36)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Position
    ----------------------------------------------------------------
    local card3, newOffset = GUIFrame:CreatePositionCard(scrollChild, yOffset, {
        db = db,
        dbKeys = {
            anchorFrameType = "anchorFrameType",
            anchorFrameFrame = "ParentFrame",
            selfPoint = "AnchorFrom",
            anchorPoint = "AnchorTo",
            xOffset = "XOffset",
            yOffset = "YOffset",
            strata = "Strata",
        },
        showAnchorFrameType = false,
        showStrata = true,
        onChangeCallback = ApplyPosition,
    })

    if card3.positionWidgets then
        for _, widget in ipairs(card3.positionWidgets) do
            table_insert(allWidgets, widget)
        end
    end
    table_insert(allWidgets, card3)
    yOffset = newOffset

    ----------------------------------------------------------------
    -- Card 4: Font Settings
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card4)

    local row4 = GUIFrame:CreateRow(card4.content, 40)
    local fontSizeSlider = GUIFrame:CreateSlider(row4, L["Font Size"], 8, 48, 1, db.FontSize or 18, 60,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row4:AddWidget(fontSizeSlider, 1)
    table_insert(allWidgets, fontSizeSlider)
    card4:AddRow(row4, 40)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Colors
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card5)

    local row5 = GUIFrame:CreateRow(card5.content, 40)
    local colorPicker = GUIFrame:CreateColorPicker(row5, L["Text Color"], db.TextColor or { 1, 1, 1, 1 },
        function(r, g, b, a)
            db.TextColor = { r, g, b, a }
        end)
    row5:AddWidget(colorPicker, 1)
    table_insert(allWidgets, colorPicker)
    card5:AddRow(row5, 40)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 3)
    return yOffset
end)
