-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local ipairs = ipairs
local table_insert = table.insert

local L = AE.L
local function GetCombatCrossModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("CombatCross", true)
    end
    return nil
end

GUIFrame:RegisterContent("combatCross", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.CombatCross
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local CC = GetCombatCrossModule()

    local allWidgets = {}
    local colorModeWidgets = {}

    local function ApplySettings()
        if CC then
            CC:ApplySettings()
        end
    end

    local function ApplyPosition()
        if CC then
            CC:ApplyPosition()
        end
    end

    local function ApplyCombatCrossState(enabled)
        if not CC then return end
        CC.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("CombatCross")
        else
            VXJediEssentials:DisableModule("CombatCross")
        end
    end

    local function UpdateAllWidgetStates()
        local mainEnabled = db.Enabled ~= false
        local isCustomColor = (db.ColorMode or "custom") == "custom"

        for _, widget in ipairs(allWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(mainEnabled)
            end
        end

        if mainEnabled then
            for _, widget in ipairs(colorModeWidgets) do
                if widget.SetEnabled then
                    widget:SetEnabled(isCustomColor)
                end
            end
        end
    end

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Combat Cross"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Combat Cross"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyCombatCrossState(checked)
            UpdateAllWidgetStates()
        end,
        true, L["Combat Cross"], L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    local noteHeight = 40
    local noteRow = GUIFrame:CreateRow(card1.content, noteHeight)
    local noteText = GUIFrame:CreateText(noteRow,
        AE:ColorTextByTheme(L["Note"]),
        L["This is a static crosshair overlay and will not adjust with camera panning."],
        noteHeight, "hide")
    noteRow:AddWidget(noteText, 1)
    card1:AddRow(noteRow, noteHeight)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Position
    ----------------------------------------------------------------
    local card2, newOffset = GUIFrame:CreatePositionCard(scrollChild, yOffset, {
        db = db,
        dbKeys = {
            anchorFrameType = "anchorFrameType",
            anchorFrameFrame = "ParentFrame",
            selfPoint = "AnchorFrom",
            anchorPoint = "AnchorTo",
            xOffset = "XOffset",
            yOffset = "YOffset",
            strata = L["Strata"],
        },
        showAnchorFrameType = false,
        showStrata = true,
        onChangeCallback = ApplyPosition,
    })

    if card2.positionWidgets then
        for _, widget in ipairs(card2.positionWidgets) do
            table_insert(allWidgets, widget)
        end
    end
    table_insert(allWidgets, card2)
    yOffset = newOffset

    ----------------------------------------------------------------
    -- Card 3: Font Settings
    ----------------------------------------------------------------
    local card3 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card3)

    local row3 = GUIFrame:CreateRow(card3.content, 36)
    local outlineCheck = GUIFrame:CreateCheckbox(row3, L["Font Outline"], db.Outline ~= false,
        function(checked)
            db.Outline = checked
            ApplySettings()
        end)
    row3:AddWidget(outlineCheck, 0.5)
    table_insert(allWidgets, outlineCheck)

    local sizeSlider = GUIFrame:CreateSlider(row3, L["Size"], 8, 72, 1, db.Thickness or 22, 60,
        function(val)
            db.Thickness = val
            ApplySettings()
        end)
    row3:AddWidget(sizeSlider, 0.5)
    table_insert(allWidgets, sizeSlider)
    card3:AddRow(row3, 36)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 4: Colors
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card4)

    local currentColorMode = db.ColorMode or "custom"

    local row4 = GUIFrame:CreateRow(card4.content, 36)
    local colorModeDropdown = GUIFrame:CreateDropdown(row4, L["Color Mode"], AE.ColorModeOptions, currentColorMode, 70,
        function(key)
            db.ColorMode = key
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row4:AddWidget(colorModeDropdown, 0.5)
    table_insert(allWidgets, colorModeDropdown)

    local colorPicker = GUIFrame:CreateColorPicker(row4, L["Custom Color"], db.Color or { 0, 1, 0.169, 1 },
        function(r, g, b, a)
            db.Color = { r, g, b, a }
            ApplySettings()
        end)
    row4:AddWidget(colorPicker, 0.5)
    table_insert(allWidgets, colorPicker)
    table_insert(colorModeWidgets, colorPicker)
    card4:AddRow(row4, 36)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 3)
    return yOffset
end)
