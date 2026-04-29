-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM

local table_insert = table.insert
local pairs, ipairs = pairs, ipairs

local L = AE.L
local function GetCombatMessageModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("CombatMessage", true)
    end
    return nil
end

GUIFrame:RegisterContent("combatMessage", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.CombatMessage
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    db.EnterCombat = db.EnterCombat or
        { Enabled = true, Text = db.EnterText or L["+ COMBAT +"], Color = db.EnterColor or { 0.929, 0.259, 0, 1 } }
    db.ExitCombat = db.ExitCombat or
        { Enabled = true, Text = db.ExitText or L["- COMBAT -"], Color = db.ExitColor or { 0.788, 1, 0.627, 1 } }
    db.FontShadow = db.FontShadow or {}

    local CM = GetCombatMessageModule()

    local allWidgets = {}
    local shadowWidgets = {}
    local enterWidgets = {}
    local exitWidgets = {}
    local durabilityWidgets = {}

    local function ApplySettings()
        if CM then
            CM:ApplySettings()
        end
    end

    local function ApplyCombatMessageState(enabled)
        if not CM then return end
        CM.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("CombatMessage")
        else
            VXJediEssentials:DisableModule("CombatMessage")
        end
    end

    local function UpdateAllWidgetStates()
        local mainEnabled = db.Enabled ~= false
        local shadowEnabled = db.FontShadow and db.FontShadow.Enabled == true
        local enterEnabled = db.EnterCombat and db.EnterCombat.Enabled ~= false
        local exitEnabled = db.ExitCombat and db.ExitCombat.Enabled ~= false
        local durabilityEnabled = db.LowDurability and db.LowDurability.Enabled ~= false

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
            for _, widget in ipairs(enterWidgets) do
                if widget.SetEnabled then
                    widget:SetEnabled(enterEnabled)
                end
            end
            for _, widget in ipairs(exitWidgets) do
                if widget.SetEnabled then
                    widget:SetEnabled(exitEnabled)
                end
            end
            for _, widget in ipairs(durabilityWidgets) do
                if widget.SetEnabled then
                    widget:SetEnabled(durabilityEnabled)
                end
            end
        end
    end

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Combat Texts"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Combat Messages"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyCombatMessageState(checked)
            UpdateAllWidgetStates()
        end,
        true,
        "Combat Messages",
        L["On"],
        L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings (animation/spacing)
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    local row2 = GUIFrame:CreateRow(card2.content, 37)
    local durationSlider = GUIFrame:CreateSlider(row2, L["Fade Duration (seconds)"], 0.5, 5.0, 0.1, db.Duration or 2.5, 140,
        function(val)
            db.Duration = val
            ApplySettings()
        end)
    row2:AddWidget(durationSlider, 0.6)
    table_insert(allWidgets, durationSlider)

    local spacingSlider = GUIFrame:CreateSlider(row2, L["Message Spacing"], 0, 20, 1, db.Spacing or 4, 100,
        function(val)
            db.Spacing = val
            ApplySettings()
        end)
    row2:AddWidget(spacingSlider, 0.4)
    table_insert(allWidgets, spacingSlider)
    card2:AddRow(row2, 37)

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
        defaults = {
            anchorFrameType = "UIPARENT",
            anchorFrameFrame = "UIParent",
            selfPoint = "CENTER",
            anchorPoint = "CENTER",
            xOffset = 0,
            yOffset = 180,
            strata = "HIGH",
        },
        showAnchorFrameType = true,
        showStrata = true,
        onChangeCallback = ApplySettings,
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

    local fontList = {}
    if LSM then
        for name in pairs(LSM:HashTable("font")) do fontList[name] = name end
    else
        fontList["Friz Quadrata TT"] = "Friz Quadrata TT"
    end

    local row4a = GUIFrame:CreateRow(card4.content, 40)
    local fontDropdown = GUIFrame:CreateDropdown(row4a, L["Font"], fontList, db.FontFace or "Friz Quadrata TT", 30,
        function(key)
            db.FontFace = key
            ApplySettings()
        end)
    row4a:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local outlineList = {
        { key = "NONE", text = "None" },
        { key = "OUTLINE", text = "Outline" },
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
    local fontSizeSlider = GUIFrame:CreateSlider(card4.content, L["Font Size"], 8, 72, 1, db.FontSize or 15, 60,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row4b:AddWidget(fontSizeSlider, 1)
    table_insert(allWidgets, fontSizeSlider)
    card4:AddRow(row4b, 37)

    -- Shadow separator
    local row4sep = GUIFrame:CreateRow(card4.content, 8)
    local shadowSep = GUIFrame:CreateSeparator(row4sep)
    row4sep:AddWidget(shadowSep, 1)
    table_insert(allWidgets, shadowSep)
    card4:AddRow(row4sep, 8)

    -- Shadow enable + color
    local row4c = GUIFrame:CreateRow(card4.content, 40)
    local shadowEnableCheck = GUIFrame:CreateCheckbox(row4c, L["Enable Shadow"], db.FontShadow.Enabled == true,
        function(checked)
            db.FontShadow.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row4c:AddWidget(shadowEnableCheck, 0.5)
    table_insert(allWidgets, shadowEnableCheck)
    table_insert(shadowWidgets, shadowEnableCheck)

    local shadowColor = GUIFrame:CreateColorPicker(row4c, L["Shadow Color"], db.FontShadow.Color or { 0, 0, 0, 1 },
        function(r, g, b, a)
            db.FontShadow.Color = { r, g, b, a }
            ApplySettings()
        end)
    row4c:AddWidget(shadowColor, 0.5)
    table_insert(allWidgets, shadowColor)
    table_insert(shadowWidgets, shadowColor)
    card4:AddRow(row4c, 40)

    -- Shadow X/Y
    local row4d = GUIFrame:CreateRow(card4.content, 37)
    local shadowX = GUIFrame:CreateSlider(row4d, L["Shadow X"], -5, 5, 1, db.FontShadow.OffsetX or 0, 15,
        function(val)
            db.FontShadow.OffsetX = val
            ApplySettings()
        end)
    row4d:AddWidget(shadowX, 0.5)
    table_insert(allWidgets, shadowX)
    table_insert(shadowWidgets, shadowX)

    local shadowY = GUIFrame:CreateSlider(row4d, L["Shadow Y"], -5, 5, 1, db.FontShadow.OffsetY or 0, 15,
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
    -- Sub-feature: Enter Combat Message
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Enter Combat Message"], yOffset)
    table_insert(allWidgets, card5)

    local row5a = GUIFrame:CreateRow(card5.content, 38)
    local enterEnableCheck = GUIFrame:CreateCheckbox(row5a, L["Enabled"], db.EnterCombat.Enabled ~= false,
        function(checked)
            db.EnterCombat.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row5a:AddWidget(enterEnableCheck, 0.2)
    table_insert(allWidgets, enterEnableCheck)

    local enterColorPicker = GUIFrame:CreateColorPicker(row5a, L["Color"],
        db.EnterCombat.Color or { 0.929, 0.259, 0, 1 },
        function(r, g, b, a)
            db.EnterCombat.Color = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(enterColorPicker, 0.3)
    table_insert(allWidgets, enterColorPicker)
    table_insert(enterWidgets, enterColorPicker)

    local enterTextInput = GUIFrame:CreateEditBox(row5a, L["Text"], db.EnterCombat.Text or L["+ COMBAT +"], function(val)
        db.EnterCombat.Text = val
        ApplySettings()
    end)
    row5a:AddWidget(enterTextInput, 0.5)
    table_insert(allWidgets, enterTextInput)
    table_insert(enterWidgets, enterTextInput)
    card5:AddRow(row5a, 38)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Sub-feature: Exit Combat Message
    ----------------------------------------------------------------
    local card6 = GUIFrame:CreateCard(scrollChild, L["Exit Combat Message"], yOffset)
    table_insert(allWidgets, card6)

    local row6a = GUIFrame:CreateRow(card6.content, 38)
    local exitEnableCheck = GUIFrame:CreateCheckbox(row6a, L["Enabled"], db.ExitCombat.Enabled ~= false,
        function(checked)
            db.ExitCombat.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
        end)
    row6a:AddWidget(exitEnableCheck, 0.2)
    table_insert(allWidgets, exitEnableCheck)

    local exitColorPicker = GUIFrame:CreateColorPicker(row6a, L["Color"],
        db.ExitCombat.Color or { 0.788, 1, 0.627, 1 },
        function(r, g, b, a)
            db.ExitCombat.Color = { r, g, b, a }
            ApplySettings()
        end)
    row6a:AddWidget(exitColorPicker, 0.3)
    table_insert(allWidgets, exitColorPicker)
    table_insert(exitWidgets, exitColorPicker)

    local exitTextInput = GUIFrame:CreateEditBox(row6a, L["Text"], db.ExitCombat.Text or L["- COMBAT -"], function(val)
        db.ExitCombat.Text = val
        ApplySettings()
    end)
    row6a:AddWidget(exitTextInput, 0.5)
    table_insert(allWidgets, exitTextInput)
    table_insert(exitWidgets, exitTextInput)
    card6:AddRow(row6a, 38)

    yOffset = yOffset + card6:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Sub-feature: Low Durability Warning
    ----------------------------------------------------------------
    db.LowDurability = db.LowDurability or { Enabled = true, Text = "LOW DURABILITY", Color = { 1, 0.3, 0.3, 1 }, Threshold = 15 }
    local card7 = GUIFrame:CreateCard(scrollChild, L["Low Durability Warning"], yOffset)
    table_insert(allWidgets, card7)

    local row7a = GUIFrame:CreateRow(card7.content, 38)
    local durabilityEnableCheck = GUIFrame:CreateCheckbox(row7a, L["Enabled"], db.LowDurability.Enabled ~= false,
        function(checked)
            db.LowDurability.Enabled = checked
            ApplySettings()
            UpdateAllWidgetStates()
            if CM then CM:CheckDurability() end
        end)
    row7a:AddWidget(durabilityEnableCheck, 0.2)
    table_insert(allWidgets, durabilityEnableCheck)

    local durabilityColorPicker = GUIFrame:CreateColorPicker(row7a, L["Color"],
        db.LowDurability.Color or { 1, 0.3, 0.3, 1 },
        function(r, g, b, a)
            db.LowDurability.Color = { r, g, b, a }
            ApplySettings()
        end)
    row7a:AddWidget(durabilityColorPicker, 0.3)
    table_insert(allWidgets, durabilityColorPicker)
    table_insert(durabilityWidgets, durabilityColorPicker)

    local durabilityTextInput = GUIFrame:CreateEditBox(row7a, L["Text"], db.LowDurability.Text or L["LOW DURABILITY"], function(val)
        db.LowDurability.Text = val
        ApplySettings()
    end)
    row7a:AddWidget(durabilityTextInput, 0.5)
    table_insert(allWidgets, durabilityTextInput)
    table_insert(durabilityWidgets, durabilityTextInput)
    card7:AddRow(row7a, 38)

    local row7sep = GUIFrame:CreateRow(card7.content, 8)
    local sep7 = GUIFrame:CreateSeparator(row7sep)
    row7sep:AddWidget(sep7, 1)
    table_insert(allWidgets, sep7)
    card7:AddRow(row7sep, 8)

    local row7b = GUIFrame:CreateRow(card7.content, 40)
    local thresholdSlider = GUIFrame:CreateSlider(row7b, L["Durability Threshold (%)"], 5, 50, 1,
        db.LowDurability.Threshold or 15, nil,
        function(val)
            db.LowDurability.Threshold = val
            if CM then CM:CheckDurability() end
        end)
    row7b:AddWidget(thresholdSlider, 1)
    table_insert(allWidgets, thresholdSlider)
    table_insert(durabilityWidgets, thresholdSlider)
    card7:AddRow(row7b, 40)

    yOffset = yOffset + card7:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 5)
    return yOffset
end)
