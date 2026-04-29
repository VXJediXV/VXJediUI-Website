-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local L = AE.L
local CreateFrame = CreateFrame

-- File-local state: remembers the last-selected tab across sidebar clicks
-- within a single session. Resets to "Target" on /reload.
local activeTab = "Target"

----------------------------------------------------------------------
-- Tab button factory
--
-- Creates a themed tab button with active/inactive visual states.
-- Active state uses accent color (bgHover tint + accent border + accent
-- text); inactive state uses bgDark + muted text.
----------------------------------------------------------------------
local function CreateTabButton(parent, labelText)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetBackdrop({
        bgFile   = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })

    local text = btn:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    AE:ApplyThemeFont(text, "normal")
    text:SetText(labelText)
    btn.text = text

    function btn:SetActive(active)
        self.isActive = active
        if active then
            self:SetBackdropColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 0.25)
            self:SetBackdropBorderColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
            self.text:SetTextColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
        else
            self:SetBackdropColor(Theme.bgDark[1], Theme.bgDark[2], Theme.bgDark[3], 0.8)
            self:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)
            self.text:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 0.7)
        end
    end

    btn:SetScript("OnEnter", function(self)
        if not self.isActive then
            self:SetBackdropColor(Theme.bgHover[1], Theme.bgHover[2], Theme.bgHover[3], 0.8)
        end
    end)

    btn:SetScript("OnLeave", function(self)
        if not self.isActive then
            self:SetBackdropColor(Theme.bgDark[1], Theme.bgDark[2], Theme.bgDark[3], 0.8)
        end
    end)

    return btn
end

----------------------------------------------------------------------
-- Castbars content builder
--
-- Layout:
--   - Tab bar (2 buttons: Target / Focus) at the top
--   - Two sibling container frames below, stacked at the same position
--   - Only the active tab's container is visible
--   - scrollChild height is updated dynamically on tab switch to match
--     the active container's content height
----------------------------------------------------------------------
GUIFrame:RegisterContent("Castbars", function(scrollChild, yOffset)
    -- Guard: both castbar builders must be loaded before Castbars.lua can
    -- render. If either is missing (e.g. load order broke), show an error.
    local builders = GUIFrame.CastbarBuilders
    if not builders or not builders.Target or not builders.Focus then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel("Castbar builders not loaded")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
    end

    local startY = yOffset
    local tabBarHeight = 30

    ------------------------------------------------------------------
    -- Tab bar row (two buttons side by side)
    ------------------------------------------------------------------
    local tabBar = CreateFrame("Frame", nil, scrollChild)
    tabBar:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", Theme.paddingSmall, -(startY + Theme.paddingSmall))
    tabBar:SetPoint("RIGHT", scrollChild, "RIGHT", -Theme.paddingSmall, 0)
    tabBar:SetHeight(tabBarHeight)

    local targetBtn = CreateTabButton(tabBar, L["Target Castbar"])
    targetBtn:SetPoint("TOPLEFT", tabBar, "TOPLEFT", 0, 0)
    targetBtn:SetPoint("BOTTOMRIGHT", tabBar, "BOTTOM", -2, 0)

    local focusBtn = CreateTabButton(tabBar, L["Focus Castbar"])
    focusBtn:SetPoint("TOPLEFT", tabBar, "TOP", 2, 0)
    focusBtn:SetPoint("BOTTOMRIGHT", tabBar, "BOTTOMRIGHT", 0, 0)

    ------------------------------------------------------------------
    -- Content subcontainers (both rendered, visibility toggled by tab)
    --
    -- Each container is anchored TOPLEFT/RIGHT to scrollChild so its
    -- width tracks the scroll area. Cards rendered into it anchor to
    -- the container's left/right, so they follow width changes when
    -- the scrollbar appears/disappears.
    ------------------------------------------------------------------
    local contentStartY = startY + tabBarHeight + (Theme.paddingSmall * 2)

    local targetContainer = CreateFrame("Frame", nil, scrollChild)
    targetContainer:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -contentStartY)
    targetContainer:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)
    targetContainer:SetHeight(1)

    local focusContainer = CreateFrame("Frame", nil, scrollChild)
    focusContainer:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -contentStartY)
    focusContainer:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)
    focusContainer:SetHeight(1)

    -- Render both castbars into their respective containers starting
    -- at local yOffset = 0 (the container is the new coordinate space)
    local targetEndY = builders.Target(targetContainer, 0) or 0
    local focusEndY  = builders.Focus(focusContainer, 0) or 0

    targetContainer:SetHeight(targetEndY + Theme.paddingSmall)
    focusContainer:SetHeight(focusEndY + Theme.paddingSmall)

    ------------------------------------------------------------------
    -- Tab switching
    ------------------------------------------------------------------
    local function SwitchTab(which)
        activeTab = which
        if which == "Focus" then
            targetContainer:Hide()
            focusContainer:Show()
            targetBtn:SetActive(false)
            focusBtn:SetActive(true)
            scrollChild:SetHeight(contentStartY + focusEndY + Theme.paddingLarge)
        else
            targetContainer:Show()
            focusContainer:Hide()
            targetBtn:SetActive(true)
            focusBtn:SetActive(false)
            scrollChild:SetHeight(contentStartY + targetEndY + Theme.paddingLarge)
        end
        if GUIFrame.contentArea and GUIFrame.contentArea.UpdateScrollbar then
            GUIFrame.contentArea.UpdateScrollbar()
        end
    end

    targetBtn:SetScript("OnClick", function() SwitchTab("Target") end)
    focusBtn:SetScript("OnClick", function() SwitchTab("Focus") end)

    -- Restore last-selected tab (defaults to "Target" on first load)
    SwitchTab(activeTab)

    -- Return the yOffset for the currently-visible tab so MainFrame
    -- sets the initial scrollChild height correctly. SwitchTab already
    -- set scrollChild:SetHeight, but ShowContent will overwrite it
    -- based on our return value, so the two must agree.
    local activeEndY = (activeTab == "Focus") and focusEndY or targetEndY
    return contentStartY + activeEndY
end)
