-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local L = AE.L

local ipairs = ipairs

-- Ordered feature list for consistent display
local FEATURE_ORDER = {
    { key = "PlayerFrame", title = L["Player Frame"] },
    { key = "TargetFrame", title = L["Target Frame"] },
    { key = "PetFrame",    title = L["Pet Frame"]    },
}

GUIFrame:RegisterContent("PositionController", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous and AE.db.profile.Miscellaneous.PositionController
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel("Database not available")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    -- Cache the module reference once
    local mod = VXJediEssentials:GetModule("PositionController", true)

    local function ApplySettings()
        if mod and mod.ApplySettings then
            mod:ApplySettings()
        end
    end

    -- Track references for grey-out behavior
    local featureToggles = {}   -- feature key -> checkbox widget
    local featureCards = {}     -- feature key -> position card
    local cdmToggle, cdmCard    -- CDM racials widgets

    local function RefreshEnableStates()
        local masterOn = db.Enabled == true

        -- Unit frame anchoring widgets
        for _, f in ipairs(FEATURE_ORDER) do
            local toggle = featureToggles[f.key]
            local card   = featureCards[f.key]
            if toggle and toggle.SetEnabled then
                toggle:SetEnabled(masterOn)
            end
            if card and card.SetEnabled then
                local featureOn = masterOn and (db[f.key] and db[f.key].Enabled == true)
                card:SetEnabled(featureOn)
            end
        end

        -- CDM Racials widgets
        if cdmToggle and cdmToggle.SetEnabled then
            cdmToggle:SetEnabled(masterOn)
        end
        if cdmCard and cdmCard.SetEnabled then
            local cdmOn = masterOn and (db.CDMRacials and db.CDMRacials.Enabled == true)
            cdmCard:SetEnabled(cdmOn)
        end
    end

    ----------------------------------------------------------------
    -- Card 1: Master Enable + per-feature toggles + note
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Position Controller"], yOffset)

    -- Master enable row
    local masterRow = GUIFrame:CreateRow(card1.content, 36)
    local masterCheck = GUIFrame:CreateCheckbox(masterRow, L["Enable Position Controller"],
        db.Enabled == true,
        function(checked)
            db.Enabled = checked
            if checked then
                VXJediEssentials:EnableModule("PositionController")
            else
                VXJediEssentials:DisableModule("PositionController")
            end
            ApplySettings()
            RefreshEnableStates()
        end,
        true, L["Position Controller"], L["On"], L["Off"]
    )
    masterRow:AddWidget(masterCheck, 1)
    card1:AddRow(masterRow, 36)

    -- Per-feature enable toggles (all on one row)
    local togglesRow = GUIFrame:CreateRow(card1.content, 36)
    for _, f in ipairs(FEATURE_ORDER) do
        local subDB = db[f.key]
        local cb = GUIFrame:CreateCheckbox(togglesRow, f.title,
            subDB.Enabled == true,
            function(checked)
                subDB.Enabled = checked
                ApplySettings()
                RefreshEnableStates()
            end)
        togglesRow:AddWidget(cb, 1 / 3)
        featureToggles[f.key] = cb
    end
    card1:AddRow(togglesRow, 36)

    -- Note
    local noteHeight = 70
    local noteRow = GUIFrame:CreateRow(card1.content, noteHeight)
    local noteText = GUIFrame:CreateText(noteRow,
        AE:ColorTextByTheme(L["Note"]),
        L["Anchors ElvUI unit frames to other frames. Defaults anchor Player and Target to the Essential Cooldown Viewer, and Pet below the Player frame. Use the frame chooser on each card to pick a different anchor target. Unit frame anchoring does not apply to healer specs."],
        noteHeight, "hide")
    noteRow:AddWidget(noteText, 1)
    card1:AddRow(noteRow, noteHeight)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Cards 2-4: Position cards for each unit frame feature
    ----------------------------------------------------------------
    for _, f in ipairs(FEATURE_ORDER) do
        local card, newOffset = GUIFrame:CreatePositionCard(scrollChild, yOffset, {
            title = f.title,
            db = db[f.key],
            dbKeys = {
                anchorFrameType  = "anchorFrameType",
                anchorFrameFrame = "ParentFrame",
                selfPoint        = "AnchorFrom",
                anchorPoint      = "AnchorTo",
                xOffset          = "XOffset",
                yOffset          = "YOffset",
            },
            showAnchorFrameType = true,
            showStrata = false,
            onChangeCallback = ApplySettings,
        })
        featureCards[f.key] = card
        yOffset = newOffset
    end

    ----------------------------------------------------------------
    -- Card 5: CDM Racials Offset
    ----------------------------------------------------------------
    local cdmDB = db.CDMRacials
    local card5 = GUIFrame:CreateCard(scrollChild, L["CDM Racials Offset"], yOffset)
    cdmCard = card5

    -- Enable toggle
    local cdmRow1 = GUIFrame:CreateRow(card5.content, 36)
    cdmToggle = GUIFrame:CreateCheckbox(cdmRow1, L["Enable CDM Racials Offset"],
        cdmDB.Enabled == true,
        function(checked)
            cdmDB.Enabled = checked
            ApplySettings()
            RefreshEnableStates()
        end)
    cdmRow1:AddWidget(cdmToggle, 1)
    card5:AddRow(cdmRow1, 36)

    -- Pet class offset slider
    local cdmRow2 = GUIFrame:CreateRow(card5.content, 40)
    local petOffsetSlider = GUIFrame:CreateSlider(cdmRow2,
        L["Additional Y Offset for Pet Classes"], -100, 0, 1, cdmDB.PetClassOffset or -40, 60,
        function(val)
            cdmDB.PetClassOffset = val
            ApplySettings()
        end)
    cdmRow2:AddWidget(petOffsetSlider, 1)
    card5:AddRow(cdmRow2, 40)

    -- Note
    local cdmNoteHeight = 55
    local cdmNoteRow = GUIFrame:CreateRow(card5.content, cdmNoteHeight)
    local cdmNoteText = GUIFrame:CreateText(cdmNoteRow,
        AE:ColorTextByTheme(L["Note"]),
        L["Moves Ayije CDM's Racials bar based on whether you currently have a pet out. Requires the Ayije_CDM addon."],
        cdmNoteHeight, "hide")
    cdmNoteRow:AddWidget(cdmNoteText, 1)
    card5:AddRow(cdmNoteRow, cdmNoteHeight)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    -- Apply initial enable states
    RefreshEnableStates()

    yOffset = yOffset - (Theme.paddingSmall * 3)
    return yOffset
end)
