-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local table_insert = table.insert
local table_sort = table.sort

local allWidgets = {}

local L = AE.L
local function GetBattleResDB()
    if not AE.db or not AE.db.profile then return nil end
    return AE.db.profile.BattleRes
end

local function GetCombatResModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("CombatRes", true)
    end
    return nil
end

local function ApplySettings()
    local CR = GetCombatResModule()
    if CR and CR.ApplySettings then CR:ApplySettings() end
end

local function ApplyCombatResState(enabled)
    local CR = GetCombatResModule()
    if not CR then return end
    CR.db.Enabled = enabled
    if enabled then
        VXJediEssentials:EnableModule("CombatRes")
    else
        VXJediEssentials:DisableModule("CombatRes")
    end
end

local function UpdateAllWidgetStates()
    local db = GetBattleResDB()
    if not db then return end
    local mainEnabled = db.Enabled ~= false
    for _, widget in ipairs(allWidgets) do
        if widget.SetEnabled then
            widget:SetEnabled(mainEnabled)
        end
    end
end

GUIFrame:RegisterContent("battleRes", function(scrollChild, yOffset)
    local db = GetBattleResDB()
    if not db then return yOffset end

    db.TextMode = db.TextMode or {}
    local tm = db.TextMode

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Combat Res Tracker"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 40)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Combat Res Tracker"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyCombatResState(checked)
            UpdateAllWidgetStates()
        end,
        true,
        L["Combat Res Tracker"],
        L["On"],
        L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 40)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings (separator/brackets/growth)
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    -- Separator character + charge prefix
    local row2a = GUIFrame:CreateRow(card2.content, 39)
    local sepInput = GUIFrame:CreateEditBox(row2a, L["Separator Character"], tm.Separator or "|", function(val)
        tm.Separator = val
        ApplySettings()
    end)
    row2a:AddWidget(sepInput, 0.5)
    table_insert(allWidgets, sepInput)

    local sepChargeInput = GUIFrame:CreateEditBox(row2a, L["Charge Prefix"], tm.SeparatorCharges or "CR:", function(val)
        tm.SeparatorCharges = val
        ApplySettings()
    end)
    row2a:AddWidget(sepChargeInput, 0.5)
    table_insert(allWidgets, sepChargeInput)
    card2:AddRow(row2a, 39)

    -- Bracket style + Growth direction
    local row2b = GUIFrame:CreateRow(card2.content, 36)
    local bracketList = { ["square"] = "[ ]", ["round"] = "( )", ["none"] = L["None"] }
    local bracketDropdown = GUIFrame:CreateDropdown(row2b, L["Bracket Style"], bracketList, tm.BracketStyle or "square", 50,
        function(key)
            tm.BracketStyle = key
            ApplySettings()
        end)
    row2b:AddWidget(bracketDropdown, 0.5)
    table_insert(allWidgets, bracketDropdown)

    local growthList = {
        { key = "LEFT",  text = "Left" },
        { key = "RIGHT", text = "Right" },
    }
    local growthDropdown = GUIFrame:CreateDropdown(row2b, L["Growth Direction"], growthList,
        tm.GrowthDirection or "RIGHT", 60,
        function(key)
            tm.GrowthDirection = key
            ApplySettings()
        end)
    row2b:AddWidget(growthDropdown, 0.5)
    table_insert(allWidgets, growthDropdown)
    card2:AddRow(row2b, 36)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Position
    ----------------------------------------------------------------
    local positionCard
    positionCard, yOffset = GUIFrame:CreatePositionCard(scrollChild, yOffset, {
        title = L["Position"],
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
        defaults = {
            anchorFrameType = "UIPARENT",
            selfPoint = "CENTER",
            anchorPoint = "CENTER",
            xOffset = 0,
            yOffset = -200,
            strata = "HIGH",
        },
        showAnchorFrameType = true,
        showStrata = true,
        sliderRange = { -2000, 2000 },
        onChangeCallback = ApplySettings,
    })

    if positionCard.positionWidgets then
        for _, widget in ipairs(positionCard.positionWidgets) do
            table_insert(allWidgets, widget)
        end
    end
    table_insert(allWidgets, positionCard)

    ----------------------------------------------------------------
    -- Card 4: Font Settings
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)

    local LSM = AE.LSM or LibStub("LibSharedMedia-3.0", true)
    local fontList = {}
    if LSM then
        for name in pairs(LSM:HashTable("font")) do
            table_insert(fontList, { key = name, text = name })
        end
        table_sort(fontList, function(a, b) return a.text < b.text end)
    else
        table_insert(fontList, { key = "Friz Quadrata TT", text = "Friz Quadrata TT" })
    end

    local outlineList = {
        { key = "NONE",         text = "None" },
        { key = "OUTLINE",      text = "Outline" },
        { key = "THICKOUTLINE", text = "Thick" },
    }

    local row4a = GUIFrame:CreateRow(card4.content, 40)
    local fontDropdown = GUIFrame:CreateDropdown(row4a, L["Font"], fontList, tm.FontFace or "Friz Quadrata TT", 30,
        function(key)
            tm.FontFace = key
            ApplySettings()
        end)
    row4a:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local outlineDropdown = GUIFrame:CreateDropdown(row4a, L["Outline"], outlineList, tm.FontOutline or "OUTLINE", 45,
        function(key)
            tm.FontOutline = key
            ApplySettings()
        end)
    row4a:AddWidget(outlineDropdown, 0.5)
    table_insert(allWidgets, outlineDropdown)
    card4:AddRow(row4a, 40)

    local row4b = GUIFrame:CreateRow(card4.content, 40)
    local fontSizeSlider = GUIFrame:CreateSlider(row4b, L["Font Size"], 8, 36, 1, tm.FontSize or 18, 60,
        function(val)
            tm.FontSize = val
            ApplySettings()
        end)
    row4b:AddWidget(fontSizeSlider, 0.5)
    table_insert(allWidgets, fontSizeSlider)

    local spacingSlider = GUIFrame:CreateSlider(row4b, "Text Spacing", 0, 20, 1, tm.TextSpacing or 4, 80,
        function(val)
            tm.TextSpacing = val
            ApplySettings()
        end)
    row4b:AddWidget(spacingSlider, 0.5)
    table_insert(allWidgets, spacingSlider)
    card4:AddRow(row4b, 40)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Colors
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)

    local row5a = GUIFrame:CreateRow(card5.content, 39)
    local sepColor = GUIFrame:CreateColorPicker(row5a, L["Separator Color"], tm.SeparatorColor or { 1, 1, 1, 1 },
        function(r, g, b, a)
            tm.SeparatorColor = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(sepColor, 0.5)
    table_insert(allWidgets, sepColor)

    local timerColor = GUIFrame:CreateColorPicker(row5a, L["Timer Text Color"], tm.TimerColor or { 1, 1, 1, 1 },
        function(r, g, b, a)
            tm.TimerColor = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(timerColor, 0.5)
    table_insert(allWidgets, timerColor)
    card5:AddRow(row5a, 39)

    local row5b = GUIFrame:CreateRow(card5.content, 39)
    local chargeAvailColor = GUIFrame:CreateColorPicker(row5b, L["Charges Available"],
        tm.ChargeAvailableColor or { 0.3, 1, 0.3, 1 },
        function(r, g, b, a)
            tm.ChargeAvailableColor = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(chargeAvailColor, 0.5)
    table_insert(allWidgets, chargeAvailColor)

    local chargeUnavailColor = GUIFrame:CreateColorPicker(row5b, L["Charges Unavailable"],
        tm.ChargeUnavailableColor or { 1, 0.3, 0.3, 1 },
        function(r, g, b, a)
            tm.ChargeUnavailableColor = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(chargeUnavailColor, 0.5)
    table_insert(allWidgets, chargeUnavailColor)
    card5:AddRow(row5b, 39)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 3)
    return yOffset
end)
