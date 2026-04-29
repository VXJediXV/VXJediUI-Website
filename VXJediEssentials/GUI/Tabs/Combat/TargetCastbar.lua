-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM

local table_insert = table.insert
local ipairs = ipairs
local pairs = pairs

local L = AE.L
local function GetTargetCastbarModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("TargetCastbar", true)
    end
    return nil
end

GUIFrame.CastbarBuilders = GUIFrame.CastbarBuilders or {}
GUIFrame.CastbarBuilders.Target = function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous.TargetCastbar
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local TCB = GetTargetCastbarModule()
    local allWidgets = {}

    local function ApplySettings()
        if TCB and TCB.ApplySettings then
            TCB:ApplySettings()
        end
    end

    local function ApplyPosition()
        if TCB and TCB.ApplyPosition then
            TCB:ApplyPosition()
        end
    end

    local function ApplyTargetCastbarState(enabled)
        if not TCB then return end
        TCB.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("TargetCastbar")
        else
            VXJediEssentials:DisableModule("TargetCastbar")
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

    local fontList = {}
    if LSM then
        for name in pairs(LSM:HashTable("font")) do
            fontList[name] = name
        end
    else
        fontList["Friz Quadrata TT"] = "Friz Quadrata TT"
    end

    local statusbarList = {}
    if LSM then
        for name in pairs(LSM:HashTable("statusbar")) do
            statusbarList[name] = name
        end
    else
        statusbarList["Blizzard"] = "Blizzard"
    end

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Target Castbar"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Target Castbar"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyTargetCastbarState(checked)
            UpdateAllWidgetStates()
        end,
        true, L["Target Castbar"], L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings (size, texture, hide-non-interruptible)
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    -- Width + Height
    local row2a = GUIFrame:CreateRow(card2.content, 40)
    local widthSlider = GUIFrame:CreateSlider(row2a, L["Width"], 100, 1000, 1,
        db.Width or 200, nil,
        function(val)
            db.Width = val
            ApplySettings()
        end)
    row2a:AddWidget(widthSlider, 0.5)
    table_insert(allWidgets, widthSlider)

    local heightSlider = GUIFrame:CreateSlider(row2a, L["Height"], 5, 500, 1,
        db.Height or 20, nil,
        function(val)
            db.Height = val
            ApplySettings()
        end)
    row2a:AddWidget(heightSlider, 0.5)
    table_insert(allWidgets, heightSlider)
    card2:AddRow(row2a, 40)

    -- Bar Texture
    local row2b = GUIFrame:CreateRow(card2.content, 36)
    local statusbarDropdown = GUIFrame:CreateDropdown(row2b, L["Bar Texture"], statusbarList,
        db.StatusBarTexture or "VXJediEssentials", 70,
        function(key)
            db.StatusBarTexture = key
            ApplySettings()
        end)
    row2b:AddWidget(statusbarDropdown, 1)
    table_insert(allWidgets, statusbarDropdown)
    card2:AddRow(row2b, 36)

    -- Hide Non-Interruptible toggle
    local row2c = GUIFrame:CreateRow(card2.content, 36)
    local hideNotInterruptCheck = GUIFrame:CreateCheckbox(row2c, L["Hide Non-Interruptible Casts"],
        db.HideNotInterruptible == true,
        function(checked)
            db.HideNotInterruptible = checked
        end,
        true, "Hide", L["On"], L["Off"]
    )
    row2c:AddWidget(hideNotInterruptCheck, 1)
    table_insert(allWidgets, hideNotInterruptCheck)
    card2:AddRow(row2c, 36)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Position
    ----------------------------------------------------------------
    local card3, newYOffset = GUIFrame:CreatePositionCard(scrollChild, yOffset, {
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
    table_insert(allWidgets, card3)
    yOffset = newYOffset

    ----------------------------------------------------------------
    -- Card 4: Font Settings
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card4)

    local row4a = GUIFrame:CreateRow(card4.content, 40)
    local fontDropdown = GUIFrame:CreateDropdown(row4a, L["Font"], fontList,
        db.FontFace or "Expressway", 30,
        function(key)
            db.FontFace = key
            ApplySettings()
        end)
    row4a:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local outlineList = { ["NONE"] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = "Thick" }
    local outlineDropdown = GUIFrame:CreateDropdown(row4a, L["Outline"], outlineList,
        db.FontOutline or "OUTLINE", 45,
        function(key)
            db.FontOutline = key
            ApplySettings()
        end)
    row4a:AddWidget(outlineDropdown, 0.5)
    table_insert(allWidgets, outlineDropdown)
    card4:AddRow(row4a, 40)

    local row4b = GUIFrame:CreateRow(card4.content, 36)
    local fontSizeSlider = GUIFrame:CreateSlider(row4b, L["Font Size"], 8, 24, 1,
        db.FontSize or 12, nil,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row4b:AddWidget(fontSizeSlider, 1)
    table_insert(allWidgets, fontSizeSlider)
    card4:AddRow(row4b, 36)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Colors
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card5)

    -- Casting + Channeling
    local row5a = GUIFrame:CreateRow(card5.content, 40)
    local castingColor = db.CastingColor or { 1, 0.7, 0, 1 }
    local castingPicker = GUIFrame:CreateColorPicker(row5a, L["Casting"], castingColor,
        function(r, g, b, a)
            db.CastingColor = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(castingPicker, 0.5)
    table_insert(allWidgets, castingPicker)

    local channelingColor = db.ChannelingColor or { 0, 0.7, 1, 1 }
    local channelingPicker = GUIFrame:CreateColorPicker(row5a, L["Channeling"], channelingColor,
        function(r, g, b, a)
            db.ChannelingColor = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(channelingPicker, 0.5)
    table_insert(allWidgets, channelingPicker)
    card5:AddRow(row5a, 40)

    -- Empowering + Not Interruptible
    local row5b = GUIFrame:CreateRow(card5.content, 40)
    local empoweringColor = db.EmpoweringColor or { 0.8, 0.4, 1, 1 }
    local empoweringPicker = GUIFrame:CreateColorPicker(row5b, L["Empowering"], empoweringColor,
        function(r, g, b, a)
            db.EmpoweringColor = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(empoweringPicker, 0.5)
    table_insert(allWidgets, empoweringPicker)

    local notInterruptColor = db.NotInterruptibleColor or { 0.7, 0.7, 0.7, 1 }
    local notInterruptPicker = GUIFrame:CreateColorPicker(row5b, L["Not Interruptible"], notInterruptColor,
        function(r, g, b, a)
            db.NotInterruptibleColor = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(notInterruptPicker, 0.5)
    table_insert(allWidgets, notInterruptPicker)
    card5:AddRow(row5b, 40)

    -- Separator
    local rowSep1 = GUIFrame:CreateRow(card5.content, 8)
    local sep1 = GUIFrame:CreateSeparator(rowSep1)
    rowSep1:AddWidget(sep1, 1)
    card5:AddRow(rowSep1, 8)

    -- Text Color
    local row5c = GUIFrame:CreateRow(card5.content, 40)
    local textColor = db.TextColor or { 1, 1, 1, 1 }
    local textPicker = GUIFrame:CreateColorPicker(row5c, L["Text"], textColor,
        function(r, g, b, a)
            db.TextColor = { r, g, b, a }
            ApplySettings()
        end)
    row5c:AddWidget(textPicker, 0.5)
    table_insert(allWidgets, textPicker)
    card5:AddRow(row5c, 40)

    -- Separator
    local rowSep2 = GUIFrame:CreateRow(card5.content, 8)
    local sep2 = GUIFrame:CreateSeparator(rowSep2)
    rowSep2:AddWidget(sep2, 1)
    card5:AddRow(rowSep2, 8)

    -- Background + Border
    local row5d = GUIFrame:CreateRow(card5.content, 36)
    local bgColor = db.BackdropColor or { 0, 0, 0, 0.8 }
    local bgPicker = GUIFrame:CreateColorPicker(row5d, L["Background"], bgColor,
        function(r, g, b, a)
            db.BackdropColor = { r, g, b, a }
            ApplySettings()
        end)
    row5d:AddWidget(bgPicker, 0.5)
    table_insert(allWidgets, bgPicker)

    local borderColor = db.BorderColor or { 0, 0, 0, 1 }
    local borderPicker = GUIFrame:CreateColorPicker(row5d, L["Border"], borderColor,
        function(r, g, b, a)
            db.BorderColor = { r, g, b, a }
            ApplySettings()
        end)
    row5d:AddWidget(borderPicker, 0.5)
    table_insert(allWidgets, borderPicker)
    card5:AddRow(row5d, 36)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Sub-feature: Hold Timer After Interrupt
    ----------------------------------------------------------------
    local card6 = GUIFrame:CreateCard(scrollChild, L["Hold Timer"], yOffset)
    table_insert(allWidgets, card6)

    local holdTimerWidgets = {}
    local function UpdateHoldTimerWidgetStates()
        local holdEnabled = db.HoldTimer and db.HoldTimer.Enabled ~= false
        for _, widget in ipairs(holdTimerWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(holdEnabled)
            end
        end
    end

    if not db.HoldTimer then
        db.HoldTimer = {
            Enabled = true,
            Duration = 0.5,
            InterruptedColor = { 0.1, 0.8, 0.1, 1 },
            SuccessColor = { 0.8, 0.1, 0.1, 1 },
        }
    end

    local row6a = GUIFrame:CreateRow(card6.content, 40)
    local holdEnableCheck = GUIFrame:CreateCheckbox(row6a, L["Enable Hold Timer"], db.HoldTimer.Enabled ~= false,
        function(checked)
            db.HoldTimer.Enabled = checked
            UpdateHoldTimerWidgetStates()
        end,
        true, L["Hold Timer"], L["On"], L["Off"]
    )
    row6a:AddWidget(holdEnableCheck, 0.5)

    local holdSlider = GUIFrame:CreateSlider(row6a, L["Hold Duration"], 0, 2, 0.1,
        db.HoldTimer.Duration or 0.5, nil,
        function(val)
            db.HoldTimer.Duration = val
            db.timeToHold = val
        end)
    row6a:AddWidget(holdSlider, 0.5)
    table_insert(holdTimerWidgets, holdSlider)
    card6:AddRow(row6a, 40)

    local rowSep3 = GUIFrame:CreateRow(card6.content, 8)
    local sep3 = GUIFrame:CreateSeparator(rowSep3)
    rowSep3:AddWidget(sep3, 1)
    card6:AddRow(rowSep3, 8)

    local row6b = GUIFrame:CreateRow(card6.content, 36)
    local interruptedColor = db.HoldTimer.InterruptedColor or { 0.1, 0.8, 0.1, 1 }
    local interruptedPicker = GUIFrame:CreateColorPicker(row6b, L["Interrupted"], interruptedColor,
        function(r, g, b, a)
            db.HoldTimer.InterruptedColor = { r, g, b, a }
        end)
    row6b:AddWidget(interruptedPicker, 0.5)
    table_insert(holdTimerWidgets, interruptedPicker)

    local successColor = db.HoldTimer.SuccessColor or { 0.8, 0.1, 0.1, 1 }
    local successPicker = GUIFrame:CreateColorPicker(row6b, L["Cast Success"], successColor,
        function(r, g, b, a)
            db.HoldTimer.SuccessColor = { r, g, b, a }
        end)
    row6b:AddWidget(successPicker, 0.5)
    table_insert(holdTimerWidgets, successPicker)
    card6:AddRow(row6b, 36)

    yOffset = yOffset + card6:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Sub-feature: Kick Indicator
    ----------------------------------------------------------------
    local card7 = GUIFrame:CreateCard(scrollChild, L["Kick Indicator"], yOffset)
    table_insert(allWidgets, card7)

    local kickIndicatorWidgets = {}
    local function UpdateKickIndicatorWidgetStates()
        local kickEnabled = db.KickIndicator and db.KickIndicator.Enabled ~= false
        for _, widget in ipairs(kickIndicatorWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(kickEnabled)
            end
        end
    end

    local row7a = GUIFrame:CreateRow(card7.content, 40)
    local kickEnableCheck = GUIFrame:CreateCheckbox(row7a, L["Enable Kick Indicator"], db.KickIndicator.Enabled ~= false,
        function(checked)
            db.KickIndicator.Enabled = checked
            UpdateKickIndicatorWidgetStates()
        end,
        true, L["Kick Indicator"], L["On"], L["Off"]
    )
    row7a:AddWidget(kickEnableCheck, 1)
    card7:AddRow(row7a, 40)

    local rowSepKick = GUIFrame:CreateRow(card7.content, 8)
    local sepKick = GUIFrame:CreateSeparator(rowSepKick)
    rowSepKick:AddWidget(sepKick, 1)
    card7:AddRow(rowSepKick, 8)

    local row7b = GUIFrame:CreateRow(card7.content, 40)
    local notReadyColor = db.KickIndicator.NotReadyColor or { 0.5, 0.5, 0.5, 1 }
    local notReadyPicker = GUIFrame:CreateColorPicker(row7b, L["Kick Not Ready"], notReadyColor,
        function(r, g, b, a)
            db.KickIndicator.NotReadyColor = { r, g, b, a }
            ApplySettings()
        end)
    row7b:AddWidget(notReadyPicker, 0.5)
    table_insert(kickIndicatorWidgets, notReadyPicker)

    local tickColor = db.KickIndicator.TickColor or { 1, 1, 1, 1 }
    local tickPicker = GUIFrame:CreateColorPicker(row7b, L["Kick Ready Tick"], tickColor,
        function(r, g, b, a)
            db.KickIndicator.TickColor = { r, g, b, a }
            ApplySettings()
        end)
    row7b:AddWidget(tickPicker, 0.5)
    table_insert(kickIndicatorWidgets, tickPicker)
    card7:AddRow(row7b, 40)

    yOffset = yOffset + card7:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    UpdateHoldTimerWidgetStates()
    UpdateKickIndicatorWidgetStates()
    yOffset = yOffset - Theme.paddingSmall
    return yOffset
end
