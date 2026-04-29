-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM

local table_insert = table.insert
local pairs, ipairs = pairs, ipairs

local L = AE.L
local function GetModule()
    return VXJediEssentials:GetModule("PetTexts", true)
end

GUIFrame:RegisterContent("PetTexts", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.PetTexts
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel(L["Database not available"])
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local mod = GetModule()
    local allWidgets = {}

    local function ApplySettings()
        if mod and mod.ApplySettings then
            mod:ApplySettings()
        end
    end

    local function ApplyModuleState(enabled)
        if not mod then return end
        db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("PetTexts")
        else
            VXJediEssentials:DisableModule("PetTexts")
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
    local card1 = GUIFrame:CreateCard(scrollChild, L["Pet Status Texts"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Pet Status Texts"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyModuleState(checked)
            UpdateAllWidgetStates()
        end,
        true, L["Pet Status Texts"], L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings (state text inputs)
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(allWidgets, card2)

    local row2a = GUIFrame:CreateRow(card2.content, 38)
    local petMissingInput = GUIFrame:CreateEditBox(row2a, L["Pet Missing Text"], db.PetMissing or L["PET MISSING"],
        function(val)
            db.PetMissing = val
            ApplySettings()
        end)
    row2a:AddWidget(petMissingInput, 1)
    table_insert(allWidgets, petMissingInput)
    card2:AddRow(row2a, 38)

    local row2b = GUIFrame:CreateRow(card2.content, 38)
    local petDeadInput = GUIFrame:CreateEditBox(row2b, L["Pet Dead Text"], db.PetDead or L["PET DEAD"],
        function(val)
            db.PetDead = val
            ApplySettings()
        end)
    row2b:AddWidget(petDeadInput, 1)
    table_insert(allWidgets, petDeadInput)
    card2:AddRow(row2b, 38)

    local row2c = GUIFrame:CreateRow(card2.content, 38)
    local petPassiveInput = GUIFrame:CreateEditBox(row2c, L["Pet Passive Text"], db.PetPassive or L["PET PASSIVE"],
        function(val)
            db.PetPassive = val
            ApplySettings()
        end)
    row2c:AddWidget(petPassiveInput, 1)
    table_insert(allWidgets, petPassiveInput)
    card2:AddRow(row2c, 38)

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
            yOffset = 150,
            strata = "HIGH",
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

    local fontSizeSlider = GUIFrame:CreateSlider(card4.content, L["Font Size"], 8, 72, 1, db.FontSize or 24, 60,
        function(val)
            db.FontSize = val
            ApplySettings()
        end)
    row4a:AddWidget(fontSizeSlider, 0.5)
    table_insert(allWidgets, fontSizeSlider)
    card4:AddRow(row4a, 40)

    local row4b = GUIFrame:CreateRow(card4.content, 37)
    local outlineList = {
        { key = "NONE", text = "None" },
        { key = "OUTLINE", text = "Outline" },
        { key = "THICKOUTLINE", text = "Thick" },
    }
    local outlineDropdown = GUIFrame:CreateDropdown(row4b, L["Outline"], outlineList, db.FontOutline or "OUTLINE", 45,
        function(key)
            db.FontOutline = key
            ApplySettings()
        end)
    row4b:AddWidget(outlineDropdown, 1)
    table_insert(allWidgets, outlineDropdown)
    card4:AddRow(row4b, 37)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Colors
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Colors"], yOffset)
    table_insert(allWidgets, card5)

    local row5a = GUIFrame:CreateRow(card5.content, 38)
    local missingColorPicker = GUIFrame:CreateColorPicker(row5a, L["Missing Color"],
        db.MissingColor or { 1, 0.82, 0, 1 },
        function(r, g, b, a)
            db.MissingColor = { r, g, b, a }
            ApplySettings()
        end)
    row5a:AddWidget(missingColorPicker, 1)
    table_insert(allWidgets, missingColorPicker)
    card5:AddRow(row5a, 38)

    local row5b = GUIFrame:CreateRow(card5.content, 38)
    local deadColorPicker = GUIFrame:CreateColorPicker(row5b, L["Dead Color"],
        db.DeadColor or { 1, 0.2, 0.2, 1 },
        function(r, g, b, a)
            db.DeadColor = { r, g, b, a }
            ApplySettings()
        end)
    row5b:AddWidget(deadColorPicker, 1)
    table_insert(allWidgets, deadColorPicker)
    card5:AddRow(row5b, 38)

    local row5c = GUIFrame:CreateRow(card5.content, 38)
    local passiveColorPicker = GUIFrame:CreateColorPicker(row5c, L["Passive Color"],
        db.PassiveColor or { 0.3, 0.7, 1, 1 },
        function(r, g, b, a)
            db.PassiveColor = { r, g, b, a }
            ApplySettings()
        end)
    row5c:AddWidget(passiveColorPicker, 1)
    table_insert(allWidgets, passiveColorPicker)
    card5:AddRow(row5c, 38)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 2)
    return yOffset
end)
