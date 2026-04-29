-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local table_insert = table.insert
local ipairs = ipairs
local pcall = pcall
local string_format = string.format
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetNumSpecializations = GetNumSpecializations

local L = AE.L
local function GetModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("SpellAlerts", true)
    end
    return nil
end

GUIFrame:RegisterContent("SpellAlerts", function(scrollChild, yOffset)
    local db = AE.db and AE.db.profile.Miscellaneous.SpellAlerts
    if not db then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local SA = GetModule()
    local allWidgets = {}

    local function ApplyModuleState(enabled)
        if not SA then return end
        db.Enabled = enabled
        if enabled then
            VXJediEssentials:EnableModule("SpellAlerts")
        else
            VXJediEssentials:DisableModule("SpellAlerts")
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
    -- Card 1: Enable
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Spell Alerts"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 36)
    local enableCheck = GUIFrame:CreateCheckbox(row1, L["Enable Spell Alert Switch"], db.Enabled ~= false,
        function(checked)
            db.Enabled = checked
            ApplyModuleState(checked)
            UpdateAllWidgetStates()
        end,
        true, "Spell Alert Switch", L["On"], L["Off"]
    )
    row1:AddWidget(enableCheck, 1)
    card1:AddRow(row1, 36)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Per-spec toggles
    ----------------------------------------------------------------
    local numSpecs = GetNumSpecializations()
    if numSpecs and numSpecs > 0 then
        local card2 = GUIFrame:CreateCard(scrollChild, L["Enable Alerts per Spec"], yOffset)
        table_insert(allWidgets, card2)

        if not db.EnabledSpecs then
            db.EnabledSpecs = {}
        end

        for i = 1, numSpecs do
            local _, specName, _, specIcon = GetSpecializationInfo(i)
            if specName then
                local specRow = GUIFrame:CreateRow(card2.content, 36)
                local specCheck = GUIFrame:CreateCheckbox(specRow,
                    specName,
                    db.EnabledSpecs[i] == true,
                    function(checked)
                        db.EnabledSpecs[i] = checked or nil
                        if SA then
                            SA:ApplyForCurrentSpec()
                        end
                    end,
                    true, specName, L["Enabled"], L["Disabled"]
                )
                specRow:AddWidget(specCheck, 1)
                card2:AddRow(specRow, 36)
            end
        end

        yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall
    end

    ----------------------------------------------------------------
    -- Card 3: Spell Alert Opacity
    ----------------------------------------------------------------
    local card3 = GUIFrame:CreateCard(scrollChild, L["Spell Alert Opacity"], yOffset)
    table_insert(allWidgets, card3)

    local currentOpacity = tonumber(C_CVar.GetCVar("spellActivationOverlayOpacity")) or 0.65
    local opacityRow = GUIFrame:CreateRow(card3.content, 40)
    local opacitySlider = GUIFrame:CreateSlider(opacityRow, L["Opacity"], 0, 100, 5,
        math.floor(currentOpacity * 100), nil,
        function(val)
            pcall(C_CVar.SetCVar, "spellActivationOverlayOpacity", tostring(val / 100))
        end)
    opacityRow:AddWidget(opacitySlider, 1)
    card3:AddRow(opacityRow, 40)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    UpdateAllWidgetStates()
    yOffset = yOffset - (Theme.paddingSmall * 2)
    return yOffset
end)
