-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM or LibStub("LibSharedMedia-3.0", true)

local table_insert = table.insert

local L = AE.L
local function GetCombatTimerModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("CombatTimer", true)
    end
    return nil
end

GUIFrame:RegisterContent("combatTimer", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.CombatTimer
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local CT = GetCombatTimerModule()

    local allWidgets = {}
    local shadowWidgets = {}
    local bgWidgets = {}

    local function ApplySettings()
        if CT then
            CT:ApplySettings()
        end
    end

    local function ApplyPosition()
        if CT then
            CT:ApplyPosition()
        end
    end

    local function ApplyCombatTimerState(enabled)
        if not CT then return end
        CT.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("CombatTimer")
        else
            VXJediEssentials:DisableModule("CombatTimer")
        end
    end

    local function UpdateAllWidgetStates()
        local mainEnabled = db.Enabled ~= false
        local shadowEnabled = db.FontShadow and db.FontShadow.Enabled == true
        local bgEnabled = db.Backdrop and db.Backdrop.Enabled == true

        for _, widget in ipairs(allWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(mainEnabled)
            end
        end

        if mainEnabled then
            for _, widget in ipairs(shadowWidgets) do
                if widget.SetEnabled then
                    widget:SetEnabled(shadowEnabled)
                end
            end
            for _, widget in ipairs(bgWidgets) do
                if widget.SetEnabled then
                    widget:SetEnabled(bgEnabled)
                end
            end
        end
    end

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Combat Timer"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Combat Timer"], db.Enabled ~= false, function(checked)
            db.Enabled = checked
            ApplyCombatTimerState(checked)
            UpdateAllWidgetStates()
        end,
        true,
        L["Combat Timer"],
        L["On"],
        L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    -- Format + Bracket Style row
    local row2a = GUIFrame:CreateRow(card2.content, 36)
    local formatList = { ["MM:SS"] = "MM:SS", ["MM:SS:MS"] = "MM:SS:MS" }
    local formatDropdown = GUIFrame:CreateDropdown(row2a, L["Format"], formatList, db.Format or "MM:SS", 50,
        function(key)
            db.Format = key
            ApplySettings()
        end)
    row2a:AddWidget(formatDropdown, 0.5)
    table_insert(allWidgets, formatDropdown)

    local bracketList = { ["square"] = "[ ]", ["round"] = "( )", ["none"] = L["None"] }
    local bracketDropdown = GUIFrame:CreateDropdown(row2a, L["Bracket Style"], bracketList, db.BracketStyle or "square", 50,
        function(key)
            db.BracketStyle = key
            ApplySettings()
        end)
    row2a:AddWidget(bracketDropdown, 0.5)
    table_insert(allWidgets, bracketDropdown)
    card2:AddRow(row2a, 36)

    -- Chat message toggle
    local row2b = GUIFrame:CreateRow(card2.content, 36)
    local chatCheck = GUIFrame:CreateCheckbox(row2b, L["Print Combat Duration to Chat"], db.ShowChatMessage ~= false,
        function(checked)
            db.ShowChatMessage = checked
        end,
        true, "Chat Message", L["On"], L["Off"]
    )
    row2b:AddWidget(chatCheck, 1)
    table_insert(allWidgets, chatCheck)
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
            strata = L["Strata"],
        },
        showAnchorFrameType = true,
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
    -- Card 4: Font Settings (with shadow folded in)
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card4)
    db.FontShadow = db.FontShadow or {}

    local fontList = {}
    if LSM then
        for name in pairs(LSM:HashTable("font")) do fontList[name] = name end
    else
        fontList["Friz Quadrata TT"] = "Friz Quadrata TT"
    end

    -- Font Face + Outline
    local row4a = GUIFrame:CreateRow(card4.content, 40)
    local fontDropdown = GUIFrame:CreateDropdown(row4a, L["Font"], fontList, db.FontFace or "Friz Quadrata TT", 30,
        function(key)
            db.FontFace = key
            ApplySettings()
        end)
    row4a:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local outlineList = {
        { key = "NONE",         text = "None" },
        { key = "OUTLINE",      text = "Outline" },
        { key = "THICKOUTLINE", text = "Thick" },
    }
    local outlineDropdown = GUIFrame:CreateDropdown(row4a, L["Outline"], outlineList, db.FontOutline or "OUTLINE", 45,
        function(key)
            db.FontOutline = key
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row4a:AddWidget(outlineDropdown, 0.5)
    table_insert(allWidgets, outlineDropdown)
    card4:AddRow(row4a, 40)

    -- Font Size
    local row4b = GUIFrame:CreateRow(card4.content, 37)
    local fontSizeSlider = GUIFrame:CreateSlider(card4.content, L["Font Size"], 8, 72, 1, db.FontSize or 18, 60,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row4b:AddWidget(fontSizeSlider, 1)
    table_insert(allWidgets, fontSizeSlider)
    card4:AddRow(row4b, 37)

    -- Shadow separator
    local row4sep = GUIFrame:CreateRow(card4.content, 8)
    local sepShadow = GUIFrame:CreateSeparator(row4sep)
    row4sep:AddWidget(sepShadow, 1)
    table_insert(allWidgets, sepShadow)
    card4:AddRow(row4sep, 8)

    -- Shadow enable + color
    local row4c = GUIFrame:CreateRow(card4.content, 40)
    local shadowEnableCheck = GUIFrame:CreateCheckbox(row4c, L["Use Shadow"], db.FontShadow.Enabled == true,
        function(checked)
            db.FontShadow.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row4c:AddWidget(shadowEnableCheck, 0.5)
    table_insert(allWidgets, shadowEnableCheck)

    local shadowColor = GUIFrame:CreateColorPicker(row4c, L["Shadow Color"], db.FontShadow.Color or { 0, 0, 0, 1 },
        function(r, g, b, a)
            db.FontShadow.Color = { r, g, b, a }
            ApplySettings()
        end)
    row4c:AddWidget(shadowColor, 0.5)
    table_insert(allWidgets, shadowColor)
    table_insert(shadowWidgets, shadowColor)
    card4:AddRow(row4c, 40)

    -- Shadow X/Y offset
    local row4d = GUIFrame:CreateRow(card4.content, 37)
    local shadowX = GUIFrame:CreateSlider(row4d, L["Shadow X Offset"], -5, 5, 1, db.FontShadow.OffsetX or 0, 15,
        function(val)
            db.FontShadow.OffsetX = val
            ApplySettings()
        end)
    row4d:AddWidget(shadowX, 0.5)
    table_insert(allWidgets, shadowX)
    table_insert(shadowWidgets, shadowX)

    local shadowY = GUIFrame:CreateSlider(row4d, L["Shadow Y Offset"], -5, 5, 1, db.FontShadow.OffsetY or 0, 15,
        function(val)
            db.FontShadow.OffsetY = val
            ApplySettings()
        end)
    row4d:AddWidget(shadowY, 0.5)
    table_insert(allWidgets, shadowY)
    table_insert(shadowWidgets, shadowY)
    card4:AddRow(row4d, 37)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Colors
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card5)

    local row5a = GUIFrame:CreateRow(card5.content, 40)
    local inCombatColor = GUIFrame:CreateColorPicker(row5a, L["In Combat Color"], db.ColorInCombat or { 1, 1, 1, 1 },
        function(r, g, b, a)
            db.ColorInCombat = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(inCombatColor, 1)
    table_insert(allWidgets, inCombatColor)
    card5:AddRow(row5a, 40)

    local row5b = GUIFrame:CreateRow(card5.content, 37)
    local outCombatColor = GUIFrame:CreateColorPicker(row5b, L["Non Combat Color"],
        db.ColorOutOfCombat or { 1, 1, 1, 0.7 },
        function(r, g, b, a)
            db.ColorOutOfCombat = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(outCombatColor, 1)
    table_insert(allWidgets, outCombatColor)
    card5:AddRow(row5b, 37)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 6: Backdrop Settings
    ----------------------------------------------------------------
    local card6 = GUIFrame:CreateCard(scrollChild, L["Backdrop Settings"], yOffset)
    table_insert(allWidgets, card6)
    db.Backdrop = db.Backdrop or {}

    local row6a = GUIFrame:CreateRow(card6.content, 39)
    local backdropCheck = GUIFrame:CreateCheckbox(row6a, L["Enable Backdrop"], db.Backdrop.Enabled ~= false,
        function(checked)
            db.Backdrop.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row6a:AddWidget(backdropCheck, 1)
    table_insert(allWidgets, backdropCheck)
    card6:AddRow(row6a, 39)

    local row6b = GUIFrame:CreateRow(card6.content, 39)
    local bgWidth = GUIFrame:CreateSlider(row6b, L["Backdrop Width"], 1, 600, 1, db.Backdrop.bgWidth or 100, 0,
        function(val)
            db.Backdrop.bgWidth = val
            ApplySettings()
        end)
    row6b:AddWidget(bgWidth, 0.4)
    table_insert(allWidgets, bgWidth)
    table_insert(bgWidgets, bgWidth)

    local bgHeight = GUIFrame:CreateSlider(row6b, L["Backdrop Height"], 1, 600, 1, db.Backdrop.bgHeight or 40, 0,
        function(val)
            db.Backdrop.bgHeight = val
            ApplySettings()
        end)
    row6b:AddWidget(bgHeight, 0.39)
    table_insert(allWidgets, bgHeight)
    table_insert(bgWidgets, bgHeight)

    local bgColor = GUIFrame:CreateColorPicker(row6b, L["Backdrop Color"], db.Backdrop.Color or { 0, 0, 0, 0.6 },
        function(r, g, b, a)
            db.Backdrop.Color = { r, g, b, a }
            ApplySettings()
        end)
    row6b:AddWidget(bgColor, 0.21)
    table_insert(allWidgets, bgColor)
    table_insert(bgWidgets, bgColor)
    card6:AddRow(row6b, 39)

    local row6sep = GUIFrame:CreateRow(card6.content, 8)
    local sepBgCard = GUIFrame:CreateSeparator(row6sep)
    row6sep:AddWidget(sepBgCard, 1)
    table_insert(allWidgets, sepBgCard)
    table_insert(bgWidgets, sepBgCard)
    card6:AddRow(row6sep, 8)

    local row6c = GUIFrame:CreateRow(card6.content, 39)
    local borderSize = GUIFrame:CreateSlider(row6c, L["Border Size"], 1, 10, 1, db.Backdrop.BorderSize or 1, 0,
        function(val)
            db.Backdrop.BorderSize = val
            ApplySettings()
        end)
    row6c:AddWidget(borderSize, 0.79)
    table_insert(allWidgets, borderSize)
    table_insert(bgWidgets, borderSize)

    local borderColor = GUIFrame:CreateColorPicker(row6c, L["Border Color"],
        db.Backdrop.BorderColor or { 0, 0, 0, 1 },
        function(r, g, b, a)
            db.Backdrop.BorderColor = { r, g, b, a }
            ApplySettings()
        end)
    row6c:AddWidget(borderColor, 0.21)
    table_insert(allWidgets, borderColor)
    table_insert(bgWidgets, borderColor)
    card6:AddRow(row6c, 39)

    yOffset = yOffset + card6:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 5)
    return yOffset
end)
