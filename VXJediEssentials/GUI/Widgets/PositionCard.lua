-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

-- Localization Setup
local table_insert = table.insert
local CreateFrame = CreateFrame
local ipairs = ipairs
local pairs = pairs

-- Anchor point options for the source/target dropdowns. Ordered
-- alphabetically to match the in-game dropdown convention.
local ANCHOR_POINT_OPTIONS = {
    { key = "BOTTOM",      text = "Bottom" },
    { key = "BOTTOMLEFT",  text = "Bottom Left" },
    { key = "BOTTOMRIGHT", text = "Bottom Right" },
    { key = "CENTER",      text = "Center" },
    { key = "LEFT",        text = "Left" },
    { key = "RIGHT",       text = "Right" },
    { key = "TOP",         text = "Top" },
    { key = "TOPLEFT",     text = "Top Left" },
    { key = "TOPRIGHT",    text = "Top Right" },
}

-- Anchor frame type options
local ANCHOR_FRAME_TYPES = {
    { key = "SCREEN",      text = "Screen Center" },
    { key = "UIPARENT",    text = "Screen (UIParent)" },
    { key = "SELECTFRAME", text = "Select Frame" },
}

----------------------------------------------------------------
-- Create Position Settings Card
----------------------------------------------------------------
function GUIFrame:CreatePositionCard(scrollChild, yOffset, config)
    config = config or {}
    local title = config.title or "Position Settings"
    local db = config.db
    local dbKeys = config.dbKeys or {}
    local defaults = config.defaults or {}
    local onChange = config.onChangeCallback
    local showAnchorFrameType = config.showAnchorFrameType ~= false
    local showStrata = config.showStrata == true
    local sliderRange = config.sliderRange or { -1000, 1000 }

    -- Map field names to actual db keys
    local keys = {
        anchorFrameType = dbKeys.anchorFrameType or "anchorFrameType",
        anchorFrameFrame = dbKeys.anchorFrameFrame or "anchorFrameFrame",
        selfPoint = dbKeys.selfPoint or "AnchorFrom",
        anchorPoint = dbKeys.anchorPoint or "AnchorTo",
        xOffset = dbKeys.xOffset or "XOffset",
        yOffset = dbKeys.yOffset or "YOffset",
        strata = dbKeys.strata or "Strata",
    }

    -- Keys that are stored at root level (not in Position table)
    local rootKeys = {
        [keys.anchorFrameType] = true,
        [keys.anchorFrameFrame] = true,
        [keys.strata] = true,
    }

    -- Helper to get value from db (handles nested Position table or flat)
    local function getValue(key, default)
        -- Root-level keys are always at db root
        if rootKeys[key] then
            if db[key] ~= nil then
                return db[key]
            end
            return default
        end
        -- Position-related keys check Position table first, then root
        if db.Position and db.Position[key] ~= nil then
            return db.Position[key]
        elseif db[key] ~= nil then
            return db[key]
        end
        return default
    end

    -- Helper to set value in db
    local function setValue(key, val)
        -- Root-level keys are always saved at db root
        if rootKeys[key] then
            db[key] = val
        elseif db.Position then
            -- Position-related keys go in Position table if it exists
            db.Position[key] = val
        else
            db[key] = val
        end
        if onChange then onChange() end
    end

    -- Track widgets for enable/disable
    local widgets = {}

    local card = GUIFrame:CreateCard(scrollChild, title, yOffset)

    -- Get current anchor type for conditional UI
    local currentType = getValue(keys.anchorFrameType, defaults.anchorFrameType or "SCREEN")

    -- Row 1: Anchored To dropdown
    if showAnchorFrameType then
        local row1 = GUIFrame:CreateRow(card.content, 40)

        local anchorTypeList = {}
        for _, opt in ipairs(ANCHOR_FRAME_TYPES) do
            anchorTypeList[opt.key] = opt.text
        end

        local anchorTypeDropdown = GUIFrame:CreateDropdown(row1, "Anchored To", anchorTypeList, currentType, 70,
            function(key)
                setValue(keys.anchorFrameType, key)
                -- Refresh to show/hide frame input
                C_Timer.After(0.25, function()
                    GUIFrame:RefreshContent()
                end)
            end)
        row1:AddWidget(anchorTypeDropdown, 1)
        table_insert(widgets, anchorTypeDropdown)
        card:AddRow(row1, 40)

        -- Row 2: Frame input + Select Frame button (only if SELECTFRAME)
        if currentType == "SELECTFRAME" then
            local row2 = GUIFrame:CreateRow(card.content, 40)

            local frameInput = GUIFrame:CreateEditBox(row2, "Frame", getValue(keys.anchorFrameFrame, ""), function(val)
                setValue(keys.anchorFrameFrame, val ~= "" and val or nil)
            end)
            row2:AddWidget(frameInput, 0.5)
            table_insert(widgets, frameInput)

            local selectFrameBtn = GUIFrame:CreateButton(row2, "Select Frame", {
                width = 110,
                height = 24,
                callback = function()
                    if AE.FrameChooser then
                        AE.FrameChooser:Start(function(frameName, isPreview)
                            if frameName then
                                frameInput:SetValue(frameName)
                                if not isPreview then
                                    setValue(keys.anchorFrameFrame, frameName)
                                end
                            end
                        end, getValue(keys.anchorFrameFrame, ""))
                    end
                end,
            })
            row2:AddWidget(selectFrameBtn, 0.5, nil, 0, -14)
            table_insert(widgets, selectFrameBtn)
            card:AddRow(row2, 40)
        end
    end

    -- Row 3: Anchor point dropdowns
    local row3 = GUIFrame:CreateRow(card.content, 40)

    local selfPointValue = getValue(keys.selfPoint, defaults.selfPoint or "CENTER")
    local selfPointDropdown = GUIFrame:CreateDropdown(row3, "Anchor From", ANCHOR_POINT_OPTIONS, selfPointValue, 70,
        function(key)
            setValue(keys.selfPoint, key)
        end)
    row3:AddWidget(selfPointDropdown, 0.5)
    table_insert(widgets, selfPointDropdown)

    local anchorPointLabel = showAnchorFrameType and
        (currentType == "SELECTFRAME" and "To Frame's" or "To Screen's") or
        "To Frame's"
    local anchorPointValue = getValue(keys.anchorPoint, defaults.anchorPoint or "CENTER")
    local anchorPointDropdown = GUIFrame:CreateDropdown(row3, anchorPointLabel, ANCHOR_POINT_OPTIONS, anchorPointValue, 70,
        function(key)
            setValue(keys.anchorPoint, key)
        end)
    row3:AddWidget(anchorPointDropdown, 0.5)
    table_insert(widgets, anchorPointDropdown)
    card:AddRow(row3, 40)

    -- Row 4: X and Y offset sliders
    local row4 = GUIFrame:CreateRow(card.content, 40)

    local xSlider = GUIFrame:CreateSlider(row4, "X Offset", sliderRange[1], sliderRange[2], 0.01,
        getValue(keys.xOffset, defaults.xOffset or 0), 55,
        function(val)
            setValue(keys.xOffset, val)
        end)
    row4:AddWidget(xSlider, 0.5)
    table_insert(widgets, xSlider)

    local ySlider = GUIFrame:CreateSlider(row4, "Y Offset", sliderRange[1], sliderRange[2], 0.01,
        getValue(keys.yOffset, defaults.yOffset or 0), 55,
        function(val)
            setValue(keys.yOffset, val)
        end)
    row4:AddWidget(ySlider, 0.5)
    table_insert(widgets, ySlider)
    card:AddRow(row4, 40)

    -- Row 5: Strata dropdown (optional, below offsets)
    if showStrata then
        local row5 = GUIFrame:CreateRow(card.content, 37)
        -- Ordered from highest to lowest strata
        local strataList = {
            { key = "TOOLTIP",           text = "Tooltip" },
            { key = "FULLSCREEN_DIALOG", text = "Fullscreen Dialog" },
            { key = "FULLSCREEN",        text = "Fullscreen" },
            { key = "DIALOG",            text = "Dialog" },
            { key = "HIGH",              text = "High" },
            { key = "MEDIUM",            text = "Medium" },
            { key = "LOW",               text = "Low" },
            { key = "BACKGROUND",        text = "Background" },
        }
        local currentStrata = getValue(keys.strata, defaults.strata or "HIGH")
        local strataDropdown = GUIFrame:CreateDropdown(row5, "Strata", strataList, currentStrata, 39,
            function(key)
                setValue(keys.strata, key)
            end)
        row5:AddWidget(strataDropdown, 1)
        table_insert(widgets, strataDropdown)
        card:AddRow(row5, 37)
    end

    -- Store widgets for external enable/disable
    card.positionWidgets = widgets

    -- SetEnabled method for the card
    function card:SetEnabled(enabled)
        -- Apply visual disabled state to the card itself
        if enabled then
            self:SetAlpha(1)
            if self.header then self.header:SetAlpha(1) end
            if self.titleText then self.titleText:SetAlpha(1) end
        else
            self:SetAlpha(0.5)
            if self.header then self.header:SetAlpha(0.5) end
            if self.titleText then self.titleText:SetAlpha(0.5) end
        end

        -- Disable all internal widgets
        for _, widget in ipairs(self.positionWidgets) do
            if widget.SetEnabled then
                widget:SetEnabled(enabled)
            elseif widget.SetDisabled then
                widget:SetDisabled(not enabled)
            end
        end
    end
    function card:SetPositionWidgetsEnabled(enabled)
        self:SetEnabled(enabled)
    end

    return card, yOffset + card:GetContentHeight() + Theme.paddingSmall
end
