-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local L = AE.L
local function GetModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("CursorCircle", true)
    end
    return nil
end

GUIFrame:RegisterContent("CursorCircle", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous.CursorCircle
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local CC = GetModule()

    local function ApplySettings()
        if CC then
            CC:UpdateDB()
            CC:ApplySettings()
        end
    end

    -- Card 1: Cursor Circle
    local card1 = GUIFrame:CreateCard(scrollChild, L["Cursor Circle"], yOffset)

    -- Enable toggle
    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Cursor Circle"], db.Enabled == true,
        function(checked)
            db.Enabled = checked
            ApplySettings()
        end,
        true, L["Cursor Circle"], L["On"], L["Off"])
    row1:AddWidget(enableCheck, 0.5)
    card1:AddRow(row1, 36)

    -- Size slider: CreateSlider(parent, label, min, max, step, value, labelWidth, callback)
    local row2 = GUIFrame:CreateRow(card1.content, 36)
    local sizeSlider = GUIFrame:CreateSlider(row2, L["Radius"], 10, 100, 1, db.Size or 40, 55,
        function(val)
            db.Size = val
            ApplySettings()
        end)
    row2:AddWidget(sizeSlider, 1)
    card1:AddRow(row2, 36)

    -- Color picker
    local row3 = GUIFrame:CreateRow(card1.content, 40)
    local colorPicker = GUIFrame:CreateColorPicker(row3, "Circle Color", db.Color or { 1, 1, 1, 0.8 },
        function(r, g, b, a)
            db.Color = { r, g, b, a }
            ApplySettings()
        end)
    row3:AddWidget(colorPicker, 1)
    card1:AddRow(row3, 40)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    return yOffset
end)
