-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM

local table_insert = table.insert
local pairs, ipairs = pairs, ipairs

local L = AE.L
local function GetHuntersMarkModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("HuntersMark", true)
    end
    return nil
end

GUIFrame:RegisterContent("HuntersMark", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous.HuntersMark
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local HUNTMARK = GetHuntersMarkModule()
    local allWidgets = {}

    local function ApplySettings()
        if HUNTMARK then
            HUNTMARK:ApplySettings()
        end
    end

    local function ApplyModuleState(enabled)
        if not HUNTMARK then return end
        db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("HuntersMark")
        else
            VXJediEssentials:DisableModule("HuntersMark")
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
    local card1 = GUIFrame:CreateCard(scrollChild, L["Hunters Mark Tracking"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Hunters Mark Tracking"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyModuleState(checked)
            UpdateAllWidgetStates()
        end,
        true, L["Hunters Mark Tracking"], L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    local noteHeight = 40
    local noteRow = GUIFrame:CreateRow(card1.content, noteHeight)
    local noteText = GUIFrame:CreateText(noteRow,
        AE:ColorTextByTheme(L["Note"]),
        L["This module only works inside raid instances and while out of combat."],
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
        onChangeCallback = ApplySettings,
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

    local fontList = {}
    if LSM then
        for name in pairs(LSM:HashTable("font")) do fontList[name] = name end
    else
        fontList["Friz Quadrata TT"] = "Friz Quadrata TT"
    end

    local row3a = GUIFrame:CreateRow(card3.content, 40)
    local fontDropdown = GUIFrame:CreateDropdown(row3a, L["Font"], fontList, db.FontFace or "Friz Quadrata TT", 30,
        function(key)
            db.FontFace = key
            ApplySettings()
        end)
    row3a:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local fontSizeSlider = GUIFrame:CreateSlider(card3.content, L["Font Size"], 8, 72, 1, db.FontSize or 24, 60,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row3a:AddWidget(fontSizeSlider, 0.5)
    table_insert(allWidgets, fontSizeSlider)
    card3:AddRow(row3a, 40)

    local row3b = GUIFrame:CreateRow(card3.content, 37)
    local outlineList = {
        { key = "NONE", text = "None" },
        { key = "OUTLINE", text = "Outline" },
        { key = "THICKOUTLINE", text = "Thick" },
    }
    local outlineDropdown = GUIFrame:CreateDropdown(row3b, L["Outline"], outlineList, db.FontOutline or "OUTLINE", 45,
        function(key)
            db.FontOutline = key
            ApplySettings()
        end)
    row3b:AddWidget(outlineDropdown, 1)
    table_insert(allWidgets, outlineDropdown)
    card3:AddRow(row3b, 37)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 4: Colors
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card4)

    local row4 = GUIFrame:CreateRow(card4.content, 40)
    local colorPicker = GUIFrame:CreateColorPicker(row4, L["Alert Color"], db.Color or { 0, 1, 0, 1 },
        function(r, g, b, a)
            db.Color = { r, g, b, a }
            ApplySettings()
        end)
    row4:AddWidget(colorPicker, 1)
    table_insert(allWidgets, colorPicker)
    card4:AddRow(row4, 40)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 2)
    return yOffset
end)
