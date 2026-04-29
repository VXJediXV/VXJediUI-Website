-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM

local L = AE.L
local table_insert = table.insert
local pairs = pairs

GUIFrame:RegisterContent("MissingEnchants", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    db.MissingEnchants = db.MissingEnchants or {}
    local meDb = db.MissingEnchants

    local allWidgets = {}

    local function ApplySettings()
        if AE.MissingEnchants and AE.MissingEnchants.Refresh then
            AE.MissingEnchants.Refresh()
        end
    end

    local function UpdateAllWidgetStates()
        local mainEnabled = meDb.Enabled ~= false
        for _, widget in ipairs(allWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(mainEnabled)
            end
        end
    end

    ----------------------------------------------------------------
    -- Card 1: Enable Toggles
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Character Panel Enhancements"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Show Missing Enchants"],
        meDb.Enabled ~= false,
        function(checked)
            meDb.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
        end,
        true, "Missing Enchants", L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    local row1b = GUIFrame:CreateRow(card1.content, 36)
    local hideBGCheck = GUIFrame:CreateCheckbox(row1b, L["Hide Character Panel Background"],
        meDb.HideCharacterBackground == true,
        function(checked)
            meDb.HideCharacterBackground = checked
            ApplySettings()
        end
    )
    row1b:AddWidget(hideBGCheck, 1)
    table_insert(allWidgets, hideBGCheck)
    card1:AddRow(row1b, 36)

    -- Info text
    local noteHeight = 40
    local noteRow = GUIFrame:CreateRow(card1.content, noteHeight)
    local noteText = GUIFrame:CreateText(noteRow,
        AE:ColorTextByTheme("How it works"),
        "Displays red warnings for missing enchants next to equipment slots on your character panel. Only shows at max level.",
        noteHeight, "hide")
    noteRow:AddWidget(noteText, 1)
    card1:AddRow(noteRow, noteHeight)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Font Settings
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card2)

    -- Font Face and Size
    local row2a = GUIFrame:CreateRow(card2.content, 40)
    local fontList = {}
    if LSM then
        for name in pairs(LSM:HashTable("font")) do fontList[name] = name end
    else
        fontList["Friz Quadrata TT"] = "Friz Quadrata TT"
    end

    local fontDropdown = GUIFrame:CreateDropdown(row2a, L["Font"], fontList, meDb.FontFace or "Expressway", 30,
        function(key)
            meDb.FontFace = key
            ApplySettings()
        end)
    row2a:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local fontSizeSlider = GUIFrame:CreateSlider(card2.content, L["Font Size"], 8, 24, 1,
        meDb.FontSize or 11, 60,
        function(val)
            meDb.FontSize = val
            ApplySettings()
        end)
    row2a:AddWidget(fontSizeSlider, 0.5)
    table_insert(allWidgets, fontSizeSlider)
    card2:AddRow(row2a, 40)

    -- Font Outline
    local row2b = GUIFrame:CreateRow(card2.content, 37)
    local outlineList = {
        { key = "NONE", text = "None" },
        { key = "OUTLINE", text = "Outline" },
        { key = "THICKOUTLINE", text = "Thick" },
    }
    local outlineDropdown = GUIFrame:CreateDropdown(row2b, L["Outline"], outlineList, meDb.FontOutline or "OUTLINE", 45,
        function(key)
            meDb.FontOutline = key
            ApplySettings()
        end)
    row2b:AddWidget(outlineDropdown, 1)
    table_insert(allWidgets, outlineDropdown)
    card2:AddRow(row2b, 37)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 2)
    return yOffset
end)
