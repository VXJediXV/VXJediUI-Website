-- VXJediEssentials — Stance Texts GUI Tab
---@class AE
local AE = select(2, ...)

local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local LSM = AE.LSM

local table_insert = table.insert
local table_sort = table.sort
local wipe = wipe
local CreateFrame = CreateFrame
local ipairs, pairs = ipairs, pairs
local type = type

local allWidgets = {}
local L = AE.L

-- Get module reference
local function GetModule()
    return VXJediEssentials:GetModule("StanceText", true)
end

-- Load database settings
local function GetStanceTextDB()
    if not AE.db or not AE.db.profile then return nil end
    return AE.db.profile.StanceText
end

-- Helper to apply settings
local function ApplySettings()
    local mod = GetModule()
    if mod and mod.ApplySettings then
        mod:ApplySettings()
    end
end

-- Helper to refresh module
local function Refresh()
    local mod = GetModule()
    if mod and mod.Refresh then
        mod:Refresh()
    end
end

-- Widget state update
local function UpdateAllWidgetStates()
    local db = GetStanceTextDB()
    if not db then return end
    local mainEnabled = db.Enabled ~= false

    for _, widget in ipairs(allWidgets) do
        if widget.SetEnabled then
            widget:SetEnabled(mainEnabled)
        end
    end
end

-- Helper to apply new state
local function ApplyState(enabled)
    local MBUFFS = GetModule()
    if not MBUFFS then return end
    MBUFFS.db.Enabled = enabled
    if enabled then
        VXJediEssentials:EnableModule("StanceText")
    else
        VXJediEssentials:DisableModule("StanceText")
    end
end

-- Register cleanup callback once
if not GUIFrame._stanceTextCleanupRegistered then
    GUIFrame._stanceTextCleanupRegistered = true
    GUIFrame:RegisterOnCloseCallback("stanceText", function()
        Refresh()
    end)
end

----------------------------------------------------------------
-- Stance Text Data
----------------------------------------------------------------
local STANCE_TEXT_DATA = {
    WARRIOR = {
        { key = "386164", text = "Battle Stance",    textureId = 132349 },
        { key = "386196", text = "Berserker Stance", textureId = 132275 },
        { key = "386208", text = "Defensive Stance", textureId = 132341 },
    },
    PALADIN = {
        { key = "465",    text = "Devotion Aura",      textureId = 135893 },
        { key = "317920", text = "Concentration Aura", textureId = 135933 },
        { key = "32223",  text = "Crusader Aura",      textureId = 135890 },
    },
}

----------------------------------------------------------------
-- Icon widget helper
----------------------------------------------------------------
local function CreateIconWidget(parent, iconData, size)
    size = size or 40
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(size + 8, size)
    container.fixedWidth = size + 8

    local iconFrame = CreateFrame("Frame", nil, container)
    iconFrame:SetSize(size, size)
    iconFrame:SetPoint("LEFT", container, "LEFT", 4, 0)

    iconFrame.texture = iconFrame:CreateTexture(nil, "ARTWORK")
    iconFrame.texture:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 1, -1)
    iconFrame.texture:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -1, 1)

    if type(iconData) == "table" then
        if iconData.textureId then
            AE:ApplyZoom(iconFrame.texture, 0.3)
            iconFrame.texture:SetTexture(iconData.textureId)
        end
    elseif type(iconData) == "number" then
        AE:ApplyZoom(iconFrame.texture, 0.3)
        iconFrame.texture:SetTexture(iconData)
    end

    -- Border
    local border = iconFrame:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetColorTexture(0, 0, 0, 1)
    border:SetDrawLayer("OVERLAY", -1)
    local inner = iconFrame:CreateTexture(nil, "OVERLAY")
    inner:SetPoint("TOPLEFT", 1, -1)
    inner:SetPoint("BOTTOMRIGHT", -1, 1)
    inner:SetColorTexture(0, 0, 0, 0)

    container.SetEnabled = function(self, enabled)
        local alpha = enabled and 1 or 0.4
        iconFrame.texture:SetAlpha(alpha)
    end

    return container
end

----------------------------------------------------------------
-- Stance text card builder
----------------------------------------------------------------
local function CreateStanceTextCard(scrollChild, yOffset, classKey, title, db, activeCards)
    db[classKey] = db[classKey] or {}

    local card = GUIFrame:CreateCard(scrollChild, title, yOffset)
    table_insert(activeCards, card)
    table_insert(allWidgets, card)

    local stances = STANCE_TEXT_DATA[classKey]
    if not stances then
        return yOffset + card:GetContentHeight() + Theme.paddingSmall
    end

    local isFirst = true
    for _, stance in ipairs(stances) do
        if not isFirst then
            local sepRow = GUIFrame:CreateRow(card.content, 8)
            local sep = GUIFrame:CreateSeparator(sepRow)
            sepRow:AddWidget(sep, 1)
            table_insert(allWidgets, sep)
            card:AddRow(sepRow, 8)
        end
        isFirst = false

        db[classKey][stance.key] = db[classKey][stance.key] or {}
        if not db[classKey][stance.key].Text then
            db[classKey][stance.key].Text = stance.text
        end

        local row = GUIFrame:CreateRow(card.content, 40)

        -- Stance icon
        local iconWidget = CreateIconWidget(row, { textureId = stance.textureId }, 36)
        row:AddWidget(iconWidget, 0.1)

        -- Enable toggle
        local enableToggle = GUIFrame:CreateCheckbox(row, L["Show"],
            db[classKey][stance.key].Enabled == true,
            function(checked)
                db[classKey][stance.key].Enabled = checked
                Refresh()
            end)
        row:AddWidget(enableToggle, 0.15)
        table_insert(allWidgets, enableToggle)

        -- Color picker
        local colorPicker = GUIFrame:CreateColorPicker(row, L["Color"],
            db[classKey][stance.key].Color or { 1, 1, 1, 1 },
            function(r, g, b, a)
                db[classKey][stance.key].Color = { r, g, b, a }
                ApplySettings()
            end)
        row:AddWidget(colorPicker, 0.25)
        table_insert(allWidgets, colorPicker)

        -- Text input
        local textInput = GUIFrame:CreateEditBox(row, L["Text"],
            db[classKey][stance.key].Text or stance.text,
            function(text)
                db[classKey][stance.key].Text = text
                ApplySettings()
            end)
        row:AddWidget(textInput, 0.5)
        table_insert(allWidgets, textInput)

        card:AddRow(row, 40)
    end

    return yOffset + card:GetContentHeight() + Theme.paddingSmall
end

----------------------------------------------------------------
-- Main panel
----------------------------------------------------------------
local function CreateStanceTextsPanel(container)
    local panel = CreateFrame("Frame", nil, container)
    panel:SetAllPoints()

    -- Scroll frame
    local scrollbarWidth = Theme.scrollbarWidth or 16
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)

    -- Style scrollbar
    if scrollFrame.ScrollBar then
        local sb = scrollFrame.ScrollBar
        sb:ClearAllPoints()
        sb:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -(Theme.paddingSmall + 13))
        sb:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -3, Theme.paddingSmall + 13)
        sb:SetWidth(scrollbarWidth - 4)

        if sb.Background then sb.Background:Hide() end
        if sb.Top then sb.Top:Hide() end
        if sb.Middle then sb.Middle:Hide() end
        if sb.Bottom then sb.Bottom:Hide() end
        if sb.trackBG then sb.trackBG:Hide() end
        if sb.ScrollUpButton then sb.ScrollUpButton:Hide() end
        if sb.ScrollDownButton then sb.ScrollDownButton:Hide() end
        sb:SetAlpha(0)

        local isSnapping = false
        local PIXEL_STEP = 8 / 15
        sb:HookScript("OnValueChanged", function(self, value)
            if isSnapping then return end
            local scale = scrollFrame:GetEffectiveScale()
            local screenPixels = value * scale
            local snappedPixels = math.floor(screenPixels / PIXEL_STEP + 0.5) * PIXEL_STEP
            local snappedValue = snappedPixels / scale
            if math.abs(value - snappedValue) > 0.001 then
                isSnapping = true
                self:SetValue(snappedValue)
                isSnapping = false
            end
        end)
    end

    -- Scroll child
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    local scrollbarVisible = false

    local function UpdateScrollChildWidth()
        local baseWidth = scrollFrame:GetWidth()
        if baseWidth <= 0 then return end
        if scrollbarVisible then
            scrollChild:SetWidth(baseWidth - scrollbarWidth)
        else
            scrollChild:SetWidth(baseWidth)
        end
    end

    local function UpdateScrollBarVisibility()
        if scrollFrame.ScrollBar then
            local contentHeight = scrollChild:GetHeight()
            local frameHeight = scrollFrame:GetHeight()
            local needsScrollbar = contentHeight > frameHeight
            scrollbarVisible = needsScrollbar
            scrollFrame.ScrollBar:SetAlpha(needsScrollbar and 1 or 0)
            UpdateScrollChildWidth()
        end
    end

    UpdateScrollChildWidth()
    scrollFrame:HookScript("OnScrollRangeChanged", UpdateScrollBarVisibility)
    scrollChild:HookScript("OnSizeChanged", UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnSizeChanged", UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnShow", function()
        C_Timer.After(0, UpdateScrollBarVisibility)
    end)

    local activeCards = {}

    local function UpdateCardWidths()
        local newWidth = scrollChild:GetWidth()
        for _, card in ipairs(activeCards) do
            if card and card.SetWidth then
                card:SetWidth(newWidth)
            end
        end
    end

    scrollChild:HookScript("OnSizeChanged", function(self, width, height)
        UpdateCardWidths()
    end)

    -- Render content
    wipe(allWidgets)
    wipe(activeCards)

    local db = GetStanceTextDB()
    if not db then return panel end
    db.StanceText = db.StanceText or {}

    local yOffset = Theme.paddingMedium

    -- Build font list
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

    ----------------------------------------------------------------
    -- Card 1: Master enable
    ----------------------------------------------------------------
    local enableCard = GUIFrame:CreateCard(scrollChild, L["Stance Text Display"], yOffset)
    table_insert(activeCards, enableCard)
    table_insert(allWidgets, enableCard)

    local enableRow = GUIFrame:CreateRow(enableCard.content, 36)
    local moduleToggle = GUIFrame:CreateCheckbox(enableRow, L["Enable Module"], db.Enabled == true,
        function(checked)
            ApplyState(checked)
            UpdateAllWidgetStates()
        end)
    enableRow:AddWidget(moduleToggle, 1)
    enableCard:AddRow(enableRow, 36)

    yOffset = yOffset + enableCard:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Display Settings
    ----------------------------------------------------------------
    local displayCard = GUIFrame:CreateCard(scrollChild, L["Display Settings"], yOffset)
    table_insert(activeCards, displayCard)
    table_insert(allWidgets, displayCard)

    local stanceEnableRow = GUIFrame:CreateRow(displayCard.content, 36)
    local stanceToggle = GUIFrame:CreateCheckbox(stanceEnableRow, L["Enable Stance Text"],
        db.StanceText.Enabled == true,
        function(checked)
            db.StanceText.Enabled = checked
            Refresh()
            UpdateAllWidgetStates()
        end)
    stanceEnableRow:AddWidget(stanceToggle, 1)
    table_insert(allWidgets, stanceToggle)
    displayCard:AddRow(stanceEnableRow, 36)

    yOffset = yOffset + displayCard:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Position
    ----------------------------------------------------------------
    db.StanceText.Position = db.StanceText.Position or {}
    local positionCard
    positionCard, yOffset = GUIFrame:CreatePositionCard(scrollChild, yOffset, {
        title = "Position Settings",
        db = db.StanceText,
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
            yOffset = 100,
            strata = "HIGH",
        },
        showAnchorFrameType = true,
        showStrata = true,
        onChangeCallback = ApplySettings,
    })
    table_insert(activeCards, positionCard)

    if positionCard.positionWidgets then
        for _, widget in ipairs(positionCard.positionWidgets) do
            table_insert(allWidgets, widget)
        end
    end
    table_insert(allWidgets, positionCard)

    ----------------------------------------------------------------
    -- Card 4: Font Settings
    ----------------------------------------------------------------
    local fontCard = GUIFrame:CreateCard(scrollChild, L["Font Settings"], yOffset)
    table_insert(activeCards, fontCard)
    table_insert(allWidgets, fontCard)

    local fontRow = GUIFrame:CreateRow(fontCard.content, 36)
    local fontDropdown = GUIFrame:CreateDropdown(fontRow, L["Font"], fontList,
        db.StanceText.FontFace or "Friz Quadrata TT", 120,
        function(key)
            db.StanceText.FontFace = key
            ApplySettings()
        end)
    fontRow:AddWidget(fontDropdown, 0.5)
    table_insert(allWidgets, fontDropdown)

    local outlineDropdown = GUIFrame:CreateDropdown(fontRow, L["Outline"], outlineList,
        db.StanceText.FontOutline or "OUTLINE", 80,
        function(key)
            db.StanceText.FontOutline = key
            ApplySettings()
        end)
    fontRow:AddWidget(outlineDropdown, 0.5)
    table_insert(allWidgets, outlineDropdown)
    fontCard:AddRow(fontRow, 36)

    local sizeRow = GUIFrame:CreateRow(fontCard.content, 36)
    local fontSizeSlider = GUIFrame:CreateSlider(sizeRow, L["Font Size"], 8, 32, 1,
        db.StanceText.FontSize or 14, 60,
        function(val)
            db.StanceText.FontSize = val
            ApplySettings()
        end)
    sizeRow:AddWidget(fontSizeSlider, 1)
    table_insert(allWidgets, fontSizeSlider)
    fontCard:AddRow(sizeRow, 36)

    yOffset = yOffset + fontCard:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Sub-feature cards: Warrior / Paladin stance texts
    ----------------------------------------------------------------
    yOffset = CreateStanceTextCard(scrollChild, yOffset, "WARRIOR", "Warrior Stance Texts",
        db.StanceText, activeCards)

    yOffset = CreateStanceTextCard(scrollChild, yOffset, "PALADIN", "Paladin Aura Texts",
        db.StanceText, activeCards)

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 4)

    scrollChild:SetHeight(yOffset + Theme.paddingLarge)

    return panel
end

GUIFrame:RegisterPanel("stanceText", CreateStanceTextsPanel)
