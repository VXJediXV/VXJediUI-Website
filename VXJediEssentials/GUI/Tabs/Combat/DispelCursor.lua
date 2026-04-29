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
        return VXJediEssentials:GetModule("DispelCursor", true)
    end
    return nil
end

GUIFrame:RegisterContent("DispelCursor", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.DispelCursor
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel("Database not available")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local DC = GetModule()
    local allWidgets = {}

    local function ApplySettings()
        if DC then DC:ApplySettings() end
    end

    local function ApplyModuleState(enabled)
        if not DC then return end
        DC.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("DispelCursor")
        else
            VXJediEssentials:DisableModule("DispelCursor")
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
    local card1 = GUIFrame:CreateCard(scrollChild, L["Dispel on Cursor"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Dispel on Cursor"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyModuleState(checked)
            UpdateAllWidgetStates()
        end,
        true, "Dispel on Cursor", L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    local noteHeight = 40
    local noteRow = GUIFrame:CreateRow(card1.content, noteHeight)
    local noteText = GUIFrame:CreateText(noteRow,
        AE:ColorTextByTheme(L["Note"]),
        "Shows your dispel cooldown timer following your cursor. Auto-detects your class dispel spell.",
        noteHeight, "hide")
    noteRow:AddWidget(noteText, 1)
    card1:AddRow(noteRow, noteHeight)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings (cursor offsets)
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    local row2 = GUIFrame:CreateRow(card2.content, 40)
    local xSlider = GUIFrame:CreateSlider(row2, L["X Offset from Cursor"], -50, 50, 1, db.XOffset or 10, 60,
        function(val)
            db.XOffset = val
        end)
    row2:AddWidget(xSlider, 0.5)
    table_insert(allWidgets, xSlider)

    local ySlider = GUIFrame:CreateSlider(row2, L["Y Offset from Cursor"], -50, 50, 1, db.YOffset or 10, 60,
        function(val)
            db.YOffset = val
        end)
    row2:AddWidget(ySlider, 0.5)
    table_insert(allWidgets, ySlider)
    card2:AddRow(row2, 40)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Font Settings
    ----------------------------------------------------------------
    local card3 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card3)

    local row3 = GUIFrame:CreateRow(card3.content, 40)
    local fontSizeSlider = GUIFrame:CreateSlider(row3, L["Font Size"], 8, 36, 1, db.FontSize or 18, 60,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row3:AddWidget(fontSizeSlider, 1)
    table_insert(allWidgets, fontSizeSlider)
    card3:AddRow(row3, 40)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 4: Colors
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card4)

    local row4 = GUIFrame:CreateRow(card4.content, 40)
    local colorPicker = GUIFrame:CreateColorPicker(row4, L["Text Color"], db.TextColor or { 1, 1, 1, 1 },
        function(r, g, b, a)
            db.TextColor = { r, g, b, a }
            ApplySettings()
        end)
    row4:AddWidget(colorPicker, 1)
    table_insert(allWidgets, colorPicker)
    card4:AddRow(row4, 40)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 3)
    return yOffset
end)
