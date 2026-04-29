-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local L = AE.L
local function GetModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("WorldMap", true)
    end
    return nil
end

GUIFrame:RegisterContent("WorldMap", function(scrollChild, yOffset)
    -- Ensure defaults exist
    if AE.db and AE.db.profile and AE.db.profile.Miscellaneous and not AE.db.profile.Miscellaneous.WorldMap then
        AE.db.profile.Miscellaneous.WorldMap = {
            Enabled = true,
            ScaleEnabled = true,
            Scale = 1.2,
            WaypointBarEnabled = true,
        }
    end
    local db = AE.db and AE.db.profile.Miscellaneous and AE.db.profile.Miscellaneous.WorldMap
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, "Error", yOffset)
        errorCard:AddLabel("Database not available")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local WM = GetModule()

    local function ApplySettings()
        if WM then
            WM:UpdateDB()
            WM:ApplySettings()
        end
    end

    -- Card 1: Map Scale
    local card1 = GUIFrame:CreateCard(scrollChild, L["Map Scale"], yOffset)

    local row1a = GUIFrame:CreateRow(card1.content, 40)
    local scaleCheck = GUIFrame:CreateCheckbox(row1a, L["Increase World Map Scale"],
        db.ScaleEnabled == true,
        function(checked)
            db.ScaleEnabled = checked
            ApplySettings()
        end)
    row1a:AddWidget(scaleCheck, 0.5)

    local scaleSlider = GUIFrame:CreateSlider(row1a, L["Scale"], 1.0, 2.0, 0.05,
        db.Scale or 1.2, 100,
        function(val)
            db.Scale = val
            if WM then
                WM.scaleApplied = false
            end
            ApplySettings()
        end)
    row1a:AddWidget(scaleSlider, 0.5)
    card1:AddRow(row1a, 40)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    -- Card 2: Waypoint Search Bar
    local card2 = GUIFrame:CreateCard(scrollChild, L["Waypoint Search"], yOffset)

    local row2a = GUIFrame:CreateRow(card2.content, 40)
    local waypointCheck = GUIFrame:CreateCheckbox(row2a, L["Coordinate Search Bar on World Map"],
        db.WaypointBarEnabled == true,
        function(checked)
            db.WaypointBarEnabled = checked
            ApplySettings()
        end)
    row2a:AddWidget(waypointCheck, 1)
    card2:AddRow(row2a, 40)

    local row2b = GUIFrame:CreateRow(card2.content, 34)
    local descLabel = card2.content:CreateFontString(nil, "OVERLAY")
    local fontPath = AE:GetFontPath("Expressway") or "Fonts\\FRIZQT__.TTF"
    descLabel:SetFont(fontPath, 11, "")
    descLabel:SetTextColor(0.6, 0.6, 0.6, 1)
    descLabel:SetText("Type coordinates (e.g. 45.2 67.8) and press Enter to set a waypoint.")
    descLabel:SetPoint("LEFT", row2b, "LEFT", 8, 0)
    card2:AddRow(row2b, 34)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    return yOffset
end)
