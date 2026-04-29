-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

-- Localization Setup
local table_insert = table.insert
local ipairs = ipairs
local pairs = pairs
local LSM = AE.LSM

-- Reload UI popup for disabling Skyriding HUD
local L = AE.L
StaticPopupDialogs["VXJEDI_DRAGONRIDING_RELOAD"] = {
    text = "Skyriding UI changes require a reload to take effect. Reload now?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function() ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function GetDragonRidingModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("DragonRiding", true)
    end
    return nil
end

GUIFrame:RegisterContent("DragonRiding", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous.DragonRiding
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local DR = GetDragonRidingModule()
    local allWidgets = {}

    local function ApplySettings()
        if DR and DR.ApplySettings then
            DR:ApplySettings()
        end
    end

    local function ApplyDragonRidingState(enabled)
        if not DR then return end
        DR.db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("DragonRiding")
        else
            VXJediEssentials:DisableModule("DragonRiding")
            StaticPopup_Show("VXJEDI_DRAGONRIDING_RELOAD")
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
    local card1 = GUIFrame:CreateCard(scrollChild, L["Skyriding UI"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Skyriding UI"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyDragonRidingState(checked)
            UpdateAllWidgetStates()
        end,
        true,
        L["Skyriding UI"],
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

    -- Behavior toggles
    local row2a = GUIFrame:CreateRow(card2.content, 36)
    local groundedCheck = GUIFrame:CreateCheckbox(row2a, L["Hide When Grounded"], db.HideWhenGrounded == true,
        function(checked)
            db.HideWhenGrounded = checked
            StaticPopup_Show("VXJEDI_DRAGONRIDING_RELOAD")
        end,
        true, "Hide Grounded", L["On"], L["Off"]
    )
    row2a:AddWidget(groundedCheck, 0.5)
    table_insert(allWidgets, groundedCheck)

    local speedTextCheck = GUIFrame:CreateCheckbox(row2a, "Show Speed Text", db.ShowSpeedText ~= false,
        function(checked)
            db.ShowSpeedText = checked
            StaticPopup_Show("VXJEDI_DRAGONRIDING_RELOAD")
        end,
        true, "Speed Text", L["On"], L["Off"]
    )
    row2a:AddWidget(speedTextCheck, 0.5)
    table_insert(allWidgets, speedTextCheck)
    card2:AddRow(row2a, 36)

    -- Width
    local row2b = GUIFrame:CreateRow(card2.content, 40)
    local widthSlider = GUIFrame:CreateSlider(row2b, L["Width"], 100, 500, 1,
        db.Width or 252, nil,
        function(val)
            db.Width = val
            ApplySettings()
        end)
    row2b:AddWidget(widthSlider, 1)
    table_insert(allWidgets, widthSlider)
    card2:AddRow(row2b, 40)

    -- Bar Height
    local row2c = GUIFrame:CreateRow(card2.content, 40)
    local heightSlider = GUIFrame:CreateSlider(row2c, L["Bar Height"], 1, 24, 1,
        db.BarHeight or 12, nil,
        function(val)
            db.BarHeight = val
            ApplySettings()
        end)
    row2c:AddWidget(heightSlider, 1)
    table_insert(allWidgets, heightSlider)
    card2:AddRow(row2c, 40)

    -- Row Spacing
    local row2d = GUIFrame:CreateRow(card2.content, 40)
    local spacingSlider = GUIFrame:CreateSlider(row2d, L["Row Spacing"], 0, 10, 1,
        db.Spacing or 1, nil,
        function(val)
            db.Spacing = val
            ApplySettings()
        end)
    row2d:AddWidget(spacingSlider, 1)
    table_insert(allWidgets, spacingSlider)
    card2:AddRow(row2d, 40)

    -- Bar Texture
    local row2e = GUIFrame:CreateRow(card2.content, 40)
    local barList = {}
    if LSM then
        for name in pairs(LSM:HashTable("statusbar")) do barList[name] = name end
    else
        barList["VXJediEssentials"] = "VXJediEssentials"
    end
    local barDropdown = GUIFrame:CreateDropdown(row2e, "Bar Texture", barList,
        db.StatusBarTexture or "VXJediEssentials", 30,
        function(key)
            db.StatusBarTexture = key
            ApplySettings()
        end)
    row2e:AddWidget(barDropdown, 1)
    table_insert(allWidgets, barDropdown)
    card2:AddRow(row2e, 40)

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
        showAnchorFrameType = false,
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
    -- Card 4: Font Settings
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(allWidgets, card4)

    local row4 = GUIFrame:CreateRow(card4.content, 40)
    local speedFontSlider = GUIFrame:CreateSlider(row4, L["Speed Font Size"], 8, 24, 1,
        db.SpeedFontSize or 14, nil,
        function(val)
            db.SpeedFontSize = val
            ApplySettings()
        end)
    row4:AddWidget(speedFontSlider, 1)
    table_insert(allWidgets, speedFontSlider)
    card4:AddRow(row4, 40)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Colors
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card5)

    db.Colors = db.Colors or {}

    -- Vigor
    local row5a = GUIFrame:CreateRow(card5.content, 36)
    local vigorColor = db.Colors.Vigor or { 0.898, 0.063, 0.224, 1 }
    local vigorPicker = GUIFrame:CreateColorPicker(row5a, L["Vigor"], vigorColor,
        function(r, g, b, a)
            db.Colors.Vigor = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(vigorPicker, 0.5)
    table_insert(allWidgets, vigorPicker)
    card5:AddRow(row5a, 36)

    -- Vigor Thrill
    local row5b = GUIFrame:CreateRow(card5.content, 36)
    local thrillColor = db.Colors.VigorThrill or { 0.2, 0.8, 0.2, 1 }
    local thrillPicker = GUIFrame:CreateColorPicker(row5b, L["Vigor (Thrill)"], thrillColor,
        function(r, g, b, a)
            db.Colors.VigorThrill = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(thrillPicker, 0.5)
    table_insert(allWidgets, thrillPicker)
    card5:AddRow(row5b, 36)

    -- Whirling Surge / On CD
    local row5c = GUIFrame:CreateRow(card5.content, 36)
    local surgeColor = db.Colors.WhirlingSurge or { 0.411, 0.8, 0.941, 1 }
    local surgePicker = GUIFrame:CreateColorPicker(row5c, L["Whirling Surge"], surgeColor,
        function(r, g, b, a)
            db.Colors.WhirlingSurge = { r, g, b, a }
            ApplySettings()
        end)
    row5c:AddWidget(surgePicker, 0.5)
    table_insert(allWidgets, surgePicker)

    local surgeCDColor = db.Colors.WhirlingSurgeCD or { 0.3, 0.3, 0.3, 1 }
    local surgeCDPicker = GUIFrame:CreateColorPicker(row5c, L["Whirling Surge (On CD)"], surgeCDColor,
        function(r, g, b, a)
            db.Colors.WhirlingSurgeCD = { r, g, b, a }
            ApplySettings()
        end)
    row5c:AddWidget(surgeCDPicker, 0.5)
    table_insert(allWidgets, surgeCDPicker)
    card5:AddRow(row5c, 36)

    -- Second Wind / On CD
    local row5d = GUIFrame:CreateRow(card5.content, 36)
    local swColor = db.Colors.SecondWind or { 0.3, 0.7, 1, 1 }
    local swPicker = GUIFrame:CreateColorPicker(row5d, L["Second Wind"], swColor,
        function(r, g, b, a)
            db.Colors.SecondWind = { r, g, b, a }
            ApplySettings()
        end)
    row5d:AddWidget(swPicker, 0.5)
    table_insert(allWidgets, swPicker)

    local swCDColor = db.Colors.SecondWindCD or { 0.3, 0.3, 0.3, 1 }
    local swCDPicker = GUIFrame:CreateColorPicker(row5d, L["Second Wind (On CD)"], swCDColor,
        function(r, g, b, a)
            db.Colors.SecondWindCD = { r, g, b, a }
            ApplySettings()
        end)
    row5d:AddWidget(swCDPicker, 0.5)
    table_insert(allWidgets, swCDPicker)
    card5:AddRow(row5d, 36)

    -- Background / Border
    local row5e = GUIFrame:CreateRow(card5.content, 36)
    local bgColor = db.Colors.Background or { 0, 0, 0, 0.8 }
    local bgPicker = GUIFrame:CreateColorPicker(row5e, "Bar Background", bgColor,
        function(r, g, b, a)
            db.Colors.Background = { r, g, b, a }
            ApplySettings()
        end)
    row5e:AddWidget(bgPicker, 0.5)
    table_insert(allWidgets, bgPicker)

    local borderColor = db.Colors.Border or { 0, 0, 0, 1 }
    local borderPicker = GUIFrame:CreateColorPicker(row5e, "Bar Border", borderColor,
        function(r, g, b, a)
            db.Colors.Border = { r, g, b, a }
            ApplySettings()
        end)
    row5e:AddWidget(borderPicker, 0.5)
    table_insert(allWidgets, borderPicker)
    card5:AddRow(row5e, 36)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - Theme.paddingSmall
    return yOffset
end)
