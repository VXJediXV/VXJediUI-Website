-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local table_insert = table.insert
local ipairs = ipairs
local pcall = pcall
local tostring = tostring
local tonumber = tonumber
local CreateFrame = CreateFrame
local C_Timer = C_Timer

local L = AE.L
local function GetModule()
    if VXJediEssentials then
        return VXJediEssentials:GetModule("Optimize", true)
    end
    return nil
end

------------------------------------------------------------------------
-- Shared backdrop table (single allocation, reused for all buttons)
------------------------------------------------------------------------
local SHARED_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

------------------------------------------------------------------------
-- Shared hover handlers (avoid per-row closure allocation)
------------------------------------------------------------------------
local function OnButtonEnter(self)
    self:SetBackdropBorderColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
end
local function OnButtonLeave(self)
    self:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)
end

------------------------------------------------------------------------
-- Persistent dirty flag — survives content rebuilds, clears on reload prompt
------------------------------------------------------------------------
local optimizeDirty = false
local hookInstalled = false

local function InstallCloseHook()
    if hookInstalled then return end
    -- Poll for mainFrame; it may not exist yet at file load time
    C_Timer.After(0, function()
        local frame = GUIFrame.mainFrame
        if not frame then return end
        frame:HookScript("OnHide", function()
            if optimizeDirty then
                optimizeDirty = false
                StaticPopup_Show("VXJEDI_OPTIMIZE_RELOAD")
            end
        end)
        hookInstalled = true
    end)
end

------------------------------------------------------------------------
-- Content builder
------------------------------------------------------------------------
GUIFrame:RegisterContent("Optimize", function(scrollChild, yOffset)
    local OPT = GetModule()
    if not OPT then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel("Optimize module not available")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    -- Make sure the OnHide hook is wired up
    InstallCloseHook()

    local refreshCallbacks = {}

    local function RefreshAllRows()
        for _, fn in ipairs(refreshCallbacks) do
            fn()
        end
    end

    local function MarkDirty()
        optimizeDirty = true
    end

    --------------------------------------------------------------------------
    -- Card 1: Presets (Optimize All / Revert All)
    --------------------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Presets"], yOffset)

    local row1 = GUIFrame:CreateRow(card1.content, 40)

    local optimizeBtn = GUIFrame:CreateButton(row1, L["Optimize All"], {
        width = 140,
        height = 28,
        callback = function()
            OPT:OptimizeAll()
            RefreshAllRows()
            MarkDirty()
        end,
    })
    row1:AddWidget(optimizeBtn, 0.5)

    local revertBtn = GUIFrame:CreateButton(row1, L["Revert All"], {
        width = 140,
        height = 28,
        callback = function()
            OPT:RevertAll()
            RefreshAllRows()
            MarkDirty()
        end,
    })
    row1:AddWidget(revertBtn, 0.5)

    card1:AddRow(row1, 40)
    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    --------------------------------------------------------------------------
    -- Helper: add column header row to a card
    --------------------------------------------------------------------------
    local function AddColumnHeaders(card)
        local row = GUIFrame:CreateRow(card.content, 20)

        local container = CreateFrame("Frame", nil, row)
        container:SetAllPoints()

        local settingHeader = container:CreateFontString(nil, "OVERLAY")
        settingHeader:SetPoint("LEFT", container, "LEFT", 4, 0)
        settingHeader:SetWidth(150)
        settingHeader:SetJustifyH("LEFT")
        AE:ApplyThemeFont(settingHeader, "small")
        settingHeader:SetText(L["Setting"])
        settingHeader:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 0.7)

        local currentHeader = container:CreateFontString(nil, "OVERLAY")
        currentHeader:SetPoint("LEFT", settingHeader, "RIGHT", 4, 0)
        currentHeader:SetWidth(90)
        currentHeader:SetJustifyH("LEFT")
        AE:ApplyThemeFont(currentHeader, "small")
        currentHeader:SetText(L["Current"])
        currentHeader:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 0.7)

        local spacer = container:CreateFontString(nil, "OVERLAY")
        spacer:SetPoint("LEFT", currentHeader, "RIGHT", 2, 0)
        AE:ApplyThemeFont(spacer, "small")
        spacer:SetText(" ")

        local recHeader = container:CreateFontString(nil, "OVERLAY")
        recHeader:SetPoint("LEFT", spacer, "RIGHT", 2, 0)
        recHeader:SetWidth(90)
        recHeader:SetJustifyH("LEFT")
        AE:ApplyThemeFont(recHeader, "small")
        recHeader:SetText(L["Recommended"])
        recHeader:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 0.7)

        row:AddWidget(container, 1)
        card:AddRow(row, 20)
    end

    --------------------------------------------------------------------------
    -- Helper: build a single CVar status row inside a card
    --------------------------------------------------------------------------
    local function AddCVarRow(card, entry, widgets)
        local row = GUIFrame:CreateRow(card.content, 32)

        local container = CreateFrame("Frame", nil, row)
        container:SetAllPoints()

        local nameLabel = container:CreateFontString(nil, "OVERLAY")
        nameLabel:SetPoint("LEFT", container, "LEFT", 4, 0)
        nameLabel:SetWidth(150)
        nameLabel:SetJustifyH("LEFT")
        AE:ApplyThemeFont(nameLabel, "small")
        nameLabel:SetText(entry.name)
        nameLabel:SetTextColor(Theme.textPrimary[1], Theme.textPrimary[2], Theme.textPrimary[3], 1)

        local currentLabel = container:CreateFontString(nil, "OVERLAY")
        currentLabel:SetPoint("LEFT", nameLabel, "RIGHT", 4, 0)
        currentLabel:SetWidth(90)
        currentLabel:SetJustifyH("LEFT")
        AE:ApplyThemeFont(currentLabel, "small")

        local arrow = container:CreateFontString(nil, "OVERLAY")
        arrow:SetPoint("LEFT", currentLabel, "RIGHT", 2, 0)
        AE:ApplyThemeFont(arrow, "small")
        arrow:SetText(">")
        arrow:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 0.6)

        local optimalLabel = container:CreateFontString(nil, "OVERLAY")
        optimalLabel:SetPoint("LEFT", arrow, "RIGHT", 2, 0)
        optimalLabel:SetWidth(90)
        optimalLabel:SetJustifyH("LEFT")
        AE:ApplyThemeFont(optimalLabel, "small")

        -- Apply button
        local applyBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
        applyBtn:SetSize(50, 20)
        applyBtn:SetPoint("RIGHT", container, "RIGHT", -60, 0)
        applyBtn:SetBackdrop(SHARED_BACKDROP)
        applyBtn:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], 1)
        applyBtn:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)
        local applyText = applyBtn:CreateFontString(nil, "OVERLAY")
        AE:ApplyThemeFont(applyText, "small")
        applyText:SetPoint("CENTER")
        applyText:SetText(L["Apply"])
        applyText:SetTextColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)

        -- Revert button
        local revertBtnSmall = CreateFrame("Button", nil, container, "BackdropTemplate")
        revertBtnSmall:SetSize(50, 20)
        revertBtnSmall:SetPoint("RIGHT", container, "RIGHT", -4, 0)
        revertBtnSmall:SetBackdrop(SHARED_BACKDROP)
        revertBtnSmall:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], 1)
        revertBtnSmall:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)
        local revertText = revertBtnSmall:CreateFontString(nil, "OVERLAY")
        AE:ApplyThemeFont(revertText, "small")
        revertText:SetPoint("CENTER")
        revertText:SetText(L["Revert"])
        revertText:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)

        applyBtn:SetScript("OnEnter", OnButtonEnter)
        applyBtn:SetScript("OnLeave", OnButtonLeave)
        revertBtnSmall:SetScript("OnEnter", OnButtonEnter)
        revertBtnSmall:SetScript("OnLeave", OnButtonLeave)

        local function RefreshRow()
            local current = OPT:GetCurrentValue(entry.cvar) or "?"
            local isOpt = OPT:IsOptimal(entry.cvar, entry.optimal)
            local currentDisplay = OPT:GetValueLabel(entry.cvar, current)
            local optimalDisplay = OPT:GetValueLabel(entry.cvar, entry.optimal)

            if isOpt then
                currentLabel:SetTextColor(0.3, 1, 0.3, 1)
            else
                currentLabel:SetTextColor(1, 0.55, 0, 1)
            end
            currentLabel:SetText(currentDisplay)
            optimalLabel:SetText(optimalDisplay)
            optimalLabel:SetTextColor(0.3, 1, 0.3, 1)

            if OPT:HasBackup(entry.cvar) then
                revertBtnSmall:SetAlpha(1)
                revertBtnSmall:EnableMouse(true)
            else
                revertBtnSmall:SetAlpha(0.35)
                revertBtnSmall:EnableMouse(false)
            end
        end

        applyBtn:SetScript("OnClick", function()
            OPT:ApplyCVar(entry.cvar, entry.optimal)
            RefreshRow()
            MarkDirty()
        end)

        revertBtnSmall:SetScript("OnClick", function()
            OPT:RevertCVar(entry.cvar)
            RefreshRow()
            MarkDirty()
        end)

        container:EnableMouse(true)
        container:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(entry.name, 1, 0.82, 0, 1)
            GameTooltip:AddLine(" ")
            local cur = OPT:GetCurrentValue(entry.cvar) or "?"
            GameTooltip:AddLine(L["Current"] .. ": " .. OPT:GetValueLabel(entry.cvar, cur), 0.7, 0.7, 0.7)
            GameTooltip:AddLine(L["Recommended"] .. ": " .. OPT:GetValueLabel(entry.cvar, entry.optimal), 0.3, 1, 0.3)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["CVar"] .. ": " .. entry.cvar, 0.5, 0.5, 0.5)
            if entry.desc then
                GameTooltip:AddLine(entry.desc, 0.5, 0.5, 0.5)
            end
            GameTooltip:Show()
        end)
        container:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        row:AddWidget(container, 1)
        card:AddRow(row, 32)
        table_insert(widgets, row)
        table_insert(refreshCallbacks, RefreshRow)

        RefreshRow()
    end

    --------------------------------------------------------------------------
    -- Build a card per category
    --------------------------------------------------------------------------
    for _, cat in ipairs(OPT.Categories) do
        local card = GUIFrame:CreateCard(scrollChild, cat.name, yOffset)
        local widgets = {}

        AddColumnHeaders(card)

        for _, entry in ipairs(cat.cvars) do
            AddCVarRow(card, entry, widgets)
        end

        yOffset = yOffset + card:GetContentHeight() + Theme.paddingSmall
    end

    return yOffset
end)
