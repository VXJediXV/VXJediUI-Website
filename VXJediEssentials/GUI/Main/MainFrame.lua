-- VXJediEssentials namespace
---@diagnostic disable: undefined-field
---@class AE
local AE = select(2, ...)
local L = AE.L
AE.GUIFrame = AE.GUIFrame or {}
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme
local addonVersion = AE.Version

-- GUI state
AE.GUIOpen = false

-- Localization
local pcall = pcall
local select = select
local ShowUIPanel = ShowUIPanel
local table_insert = table.insert
local IsMouseButtonDown = IsMouseButtonDown
local tostring = tostring
local CreateFrame = CreateFrame
local pairs = pairs
local ipairs = ipairs
local ReloadUI = ReloadUI
local CreateColor = CreateColor
local print = print
local InCombatLockdown = InCombatLockdown
local _G = _G
local C_AddOns = C_AddOns

-- Sidebar Configuration with collapsible sections
GUIFrame.selectedTab = "systems"
GUIFrame.selectedSidebarItem = nil
GUIFrame.sidebarExpanded = GUIFrame.sidebarExpanded or {}
GUIFrame.SidebarConfig = {
    systems = {
        {
            id = "optimize_section",
            type = "header",
            text = "• " .. L["Optimize"],
            defaultExpanded = true,
            items = {
                { id = "Optimize", text = L["System Optimization"] },
            }
        },
        {
            id = "combat_section",
            type = "header",
            text = "• " .. L["Combat"],
            defaultExpanded = true,
            items = {
                { id = "battleRes",     text = L["Battle Resurrection"] },
                { id = "combatTimer",   text = L["Combat Timer"] },
                { id = "combatMessage", text = L["Combat Texts"] },
                { id = "combatCross",   text = L["Player Crosshair"] },
                { id = "PetTexts",      text = L["Pet Statuses"] },
                { id = "Castbars",      text = L["Castbars"] },
                { id = "gateway",       text = L["Gateway Alert"] },
                { id = "RangeCheck",    text = L["Range Check"] },
                { id = "DispelCursor",  text = L["Dispel on Cursor"] },
                { id = "stanceText",    text = L["Stance Texts"] },
                { id = "HuntersMark",   text = L["Hunters Mark"] },
            }
        },
        {
            id = "ui_section",
            type = "header",
            text = "• " .. L["Interface"],
            defaultExpanded = true,
            items = {
                { id = "PositionController", text = L["Position Controller"] },
                { id = "WorldMap",         text = L["World Map"] },
                { id = "MissingEnchants",  text = L["Missing Enchants"] },
            }
        },
        {
            id = "qol_section",
            type = "header",
            text = "• " .. L["Quality of Life"],
            defaultExpanded = true,
            items = {
                { id = "Automation",       text = L["Automation"] },
                { id = "DragonRiding",     text = L["Skyriding"] },
                { id = "CopyAnything",     text = L["Copy Anything"] },
                { id = "CursorCircle",     text = L["Cursor Circle"] },
                { id = "SpellAlerts",      text = L["Spell Alerts"] },
            }
        },
        {
            id = "profiles_section",
            type = "header",
            text = "• " .. L["Profiles"],
            defaultExpanded = true,
            items = {
                { id = "ProfileManager", text = L["Profile Manager"] },
            }
        },

    },
}

-- Function to refresh fontstrings, part of pixelperf util
local function RefreshAllFontStrings(frame)
    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if text then
                region:SetText("")
                region:SetText(text)
            end
        end
    end

    -- Recursively refresh child frames
    for i = 1, frame:GetNumChildren() do
        local child = select(i, frame:GetChildren())
        if child then
            RefreshAllFontStrings(child)
        end
    end
end

-- Create Main Frame
function GUIFrame:CreateMainFrame()
    -- Return existing frame if already created
    if self.MainFrame then
        return self.MainFrame
    end

    -- Main window frame
    local frame = CreateFrame("Frame", "VXJediAurasGUIFrame", UIParent, "BackdropTemplate")
    frame:SetSize(810, 900)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(810, 550)
    frame:EnableMouse(true)

    -- Main frame backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = Theme.borderSize,
    })
    frame:SetBackdropColor(Theme.bgDark[1], Theme.bgDark[2], Theme.bgDark[3], Theme.bgDark[4])
    frame:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)

    -- Create a dummy overlay that allows for dropdown to go beyond scrollframe
    AE.GUIOverlay = CreateFrame("Frame", nil, UIParent)
    AE.GUIOverlay:SetAllPoints(UIParent)
    AE.GUIOverlay:SetFrameStrata("TOOLTIP")
    AE.GUIOverlay:SetFrameLevel(1)
    AE.GUIOverlay:EnableMouse(false)

    -- Create header and footer
    self:CreateHeader(frame)
    self:CreateFooter(frame)
    self:CreateContentArea(frame)
    self:CreateSidebar(frame)
    -- Create border frame
    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetAllPoints(frame)
    borderFrame:SetFrameStrata("TOOLTIP")
    borderFrame:SetFrameLevel(frame:GetFrameLevel() + 100)

    -- Create top borderFrame
    local borderTop = borderFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    borderTop:SetHeight(Theme.borderSize)
    borderTop:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    borderTop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    borderTop:SetColorTexture(Theme.border[1], Theme.border[2], Theme.border[3], 1)
    frame.borderTop = borderTop

    -- Create bottom borderFrame
    local borderBottom = borderFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    borderBottom:SetHeight(Theme.borderSize)
    borderBottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    borderBottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    borderBottom:SetColorTexture(Theme.border[1], Theme.border[2], Theme.border[3], 1)
    frame.borderBottom = borderBottom

    -- Create left borderFrame
    local borderLeft = borderFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    borderLeft:SetWidth(Theme.borderSize)
    borderLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    borderLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    borderLeft:SetColorTexture(Theme.border[1], Theme.border[2], Theme.border[3], 1)
    frame.borderLeft = borderLeft

    -- Create right borderFrame
    local borderRight = borderFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    borderRight:SetWidth(Theme.borderSize)
    borderRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    borderRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    borderRight:SetColorTexture(Theme.border[1], Theme.border[2], Theme.border[3], 1)
    frame.borderRight = borderRight

    -- Store border references
    frame.borderFrame = borderFrame

    -- Close on ESC key
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            GUIFrame:Hide()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    frame:EnableKeyboard(true)

    -- Ensure frame is on top when shown
    frame:SetToplevel(true)

    -- Update GUI open state on show/hide
    frame:SetScript("OnHide", function()
        if AE.GUIOpen then
            -- Save position on hide
            if GUIFrame.SaveFramePosition then
                GUIFrame:SaveFramePosition()
            end

            -- Save session state
            if GUIFrame.SaveSessionState then
                GUIFrame:SaveSessionState()
            end

            -- Fire content cleanup callbacks
            if GUIFrame.contentCleanupCallbacks then
                for _, callback in pairs(GUIFrame.contentCleanupCallbacks) do
                    pcall(callback)
                end
            end

            -- Fire on-close callbacks
            if GUIFrame.FireOnCloseCallbacks then
                GUIFrame:FireOnCloseCallbacks()
            end

            -- Run content cleanup callbacks
            if GUIFrame.contentCleanupCallbacks then
                for _, callback in pairs(GUIFrame.contentCleanupCallbacks) do
                    pcall(callback)
                end
            end

            -- Fire on-close callbacks
            if GUIFrame.FireOnCloseCallbacks then
                GUIFrame:FireOnCloseCallbacks()
            end

            -- Update open state and notify preview manager
            AE.GUIOpen = false
            if AE.PreviewManager then
                AE.PreviewManager:SetGUIOpen(false)
            end
        end
    end)
    -- Initially hidden
    frame:Hide()

    -- Store reference
    self.mainFrame = frame
    return frame
end

-- Helper to apply theme coloring to the GUIFrames
function GUIFrame:ApplyThemeColors()
    if not self.mainFrame then return end
    local frame = self.mainFrame
    local selBg = Theme.selectedBg or Theme.accent
    local selText = Theme.selectedText or Theme.accent

    -- Main frame backdrop
    frame:SetBackdropColor(Theme.bgDark[1], Theme.bgDark[2], Theme.bgDark[3], Theme.bgDark[4])
    frame:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)

    -- Header
    if frame.header then
        frame.header:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], Theme.bgMedium[4])
        -- Update title colors
        if frame.header.logoN then
            frame.header.logoN:SetTextColor(0.451, 0.506, 1, 1)
        end
        if frame.header.logoAuras then
            frame.header.logoAuras:SetTextColor(Theme.textPrimary[1], Theme.textPrimary[2], Theme.textPrimary[3], 1)
        end
    end

    -- Sidebar
    if self.sidebar then
        self.sidebar:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], Theme.bgMedium[4])
    end

    -- Update sidebar section headers
    if self.sidebarHeaderPool then
        local r, g, b = Theme.accent[1], Theme.accent[2], Theme.accent[3]
        for _, header in ipairs(self.sidebarHeaderPool) do
            if header.inUse then
                -- Update label and arrow color (respect disabled state)
                if header.disabled then
                    if header.label then
                        header.label:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3],
                            0.35)
                    end
                    if header.arrow then
                        header.arrow:SetVertexColor(Theme.textSecondary[1], Theme.textSecondary[2],
                            Theme.textSecondary[3], 0.35)
                    end
                else
                    if header.label then
                        header.label:SetTextColor(r, g, b, 1)
                    end
                    if header.arrow then
                        header.arrow:SetVertexColor(r, g, b, 1)
                    end
                end
                -- Update hover background gradient
                if header.background then
                    header.background:SetGradient("HORIZONTAL", CreateColor(0.3, 0.3, 0.3, 0.25),
                        CreateColor(0.3, 0.3, 0.3, 0))
                end
                -- Update selection colors
                if header.selectedOverlay then
                    header.selectedOverlay:SetVertexColor(selBg[1], selBg[2], selBg[3], selBg[4] or 0.25)
                end
                if header.selectedBar then
                    header.selectedBar:SetColorTexture(r, g, b, 1)
                end
            end
        end
    end

    -- Update static sidebar items
    if self.staticSidebarItemPool then
        local r, g, b = Theme.accent[1], Theme.accent[2], Theme.accent[3]
        for _, item in ipairs(self.staticSidebarItemPool) do
            -- Update selection overlay gradient
            if item.selectedOverlay then
                item.selectedOverlay:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0.25), CreateColor(r, g, b, 0))
            end
            -- Update hover background gradient
            if item.background then
                item.background:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0.25), CreateColor(r, g, b, 0))
            end
            if item.selectedBar then
                item.selectedBar:SetColorTexture(selText[1], selText[2], selText[3], selText[4] or 1)
            end
            -- Update text color based on selection (skip disabled items)
            if item.inUse then
                if item.disabled then
                    -- Preserve greyed-out appearance for disabled items
                    item.label:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 0.35)
                elseif item.id == self.selectedSidebarItem then
                    item.label:SetTextColor(selText[1], selText[2], selText[3], selText[4] or 1)
                else
                    item.label:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)
                end
            end
        end
    end

    -- Content area
    if frame.content then
        frame.content:SetBackdropColor(Theme.bgDark[1], Theme.bgDark[2], Theme.bgDark[3], Theme.bgDark[4])
    end

    -- Footer
    if frame.footer then
        frame.footer:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], Theme.bgMedium[4])
    end
end


-- Create Header
function GUIFrame:CreateHeader(parent)
    -- Header frame
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(Theme.headerHeight)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

    -- Header background
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    header:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], Theme.bgMedium[4])

    -- Bottom border
    local bottomBorder = header:CreateTexture(nil, "BORDER")
    bottomBorder:SetHeight(Theme.borderSize)
    bottomBorder:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    bottomBorder:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    bottomBorder:SetColorTexture(Theme.border[1], Theme.border[2], Theme.border[3], Theme.border[4])

    -- Logo / Title
    local logoContainer = CreateFrame("Frame", nil, header)
    logoContainer:SetSize(220, 32)
    logoContainer:SetPoint("LEFT", header, "LEFT", Theme.paddingLarge, 0)

    -- Title text
    local titleText = logoContainer:CreateFontString(nil, "OVERLAY")
    titleText:SetPoint("LEFT", logoContainer, "LEFT", 2, 0)
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    titleText:SetText("|cffA855F7VXJedi|r|cffF2F2F2Essentials|r")
    titleText:SetShadowOffset(0, 0)

    -- Header element references
    header.logoContainer = logoContainer
    header.logoN = titleText
    header.logoAuras = subtitleText
    header.currentVersionText = currentVersionText

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)

    -- Close button texture
    local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
    closeTex:SetAllPoints()
    closeTex:SetTexture("Interface\\AddOns\\VXJediEssentials\\Media\\GUITextures\\VXJediCustomCrossv3.png")
    closeTex:SetVertexColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)
    closeBtn:SetNormalTexture(closeTex)
    closeTex:SetRotation(math.rad(45))
    closeTex:SetTexelSnappingBias(0)
    closeTex:SetSnapToPixelGrid(true)

    -- Close button scripts
    closeBtn:SetScript("OnEnter", function()
        closeTex:SetVertexColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], Theme.accent[4])
    end)
    closeBtn:SetScript("OnLeave", function()
        closeTex:SetVertexColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)
    end)
    closeBtn:SetScript("OnClick", function()
        GUIFrame:Hide()
    end)
    header.closeBtn = closeBtn

    -- Home button (house icon, next to close button)
    local settingsBtn = CreateFrame("Button", nil, header)
    settingsBtn:SetSize(18, 18)
    settingsBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)

    -- Home button texture
    local settingsTex = settingsBtn:CreateTexture(nil, "ARTWORK")
    settingsTex:SetAllPoints()
    settingsTex:SetTexture("Interface\\AddOns\\VXJediEssentials\\Media\\GUITextures\\HomeButtonv2.png")
    settingsTex:SetVertexColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)
    settingsBtn:SetNormalTexture(settingsTex)
    settingsTex:SetTexelSnappingBias(0)
    settingsTex:SetSnapToPixelGrid(true)

    -- Home button scripts
    settingsBtn:SetScript("OnEnter", function()
        settingsTex:SetVertexColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], Theme.accent[4])
    end)
    settingsBtn:SetScript("OnLeave", function()
        settingsTex:SetVertexColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)
    end)
    settingsBtn:SetScript("OnClick", function()
        GUIFrame:OpenPage("HomePage")
    end)
    header.settingsBtn = settingsBtn

    -- Make header draggable for moving the frame
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        parent:StartMoving()
    end)
    header:SetScript("OnDragStop", function()
        parent:StopMovingOrSizing()
        AE:SnapFrameToPixels(parent)
        GUIFrame:SaveFramePosition()
    end)

    parent.header = header
    return header
end

-- Create Content Area
function GUIFrame:CreateContentArea(parent)
    local content = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    -- Dynamic-width content area: anchors span from just right of the
    -- sidebar to the right edge of the frame. When the frame is resized,
    -- the content area stretches while the sidebar stays at fixed width.
    content:SetPoint("TOPLEFT", parent, "TOPLEFT", Theme.sidebarWidth, -Theme.headerHeight)
    content:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, Theme.footerHeight)

    -- Content background
    content:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    content:SetBackdropColor(Theme.bgDark[1], Theme.bgDark[2], Theme.bgDark[3], Theme.bgDark[4])

    -- Scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    local scrollbarWidth = Theme.scrollbarWidth or 16
    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)

    -- Style the scrollbar thumb
    if scrollFrame.ScrollBar then
        local sb = scrollFrame.ScrollBar
        -- Position scrollbar inside the content area on the right edge
        sb:ClearAllPoints()
        sb:SetPoint("TOPRIGHT", content, "TOPRIGHT", -3, -Theme.paddingSmall - 12)
        sb:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -3, Theme.paddingSmall + 12)
        sb:SetWidth(scrollbarWidth - 4)

        -- Custom scrollbar textures
        if sb.Background then sb.Background:Hide() end
        if sb.Top then sb.Top:Hide() end
        if sb.Middle then sb.Middle:Hide() end
        if sb.Bottom then sb.Bottom:Hide() end
        if sb.trackBG then sb.trackBG:Hide() end
        if sb.ScrollUpButton then sb.ScrollUpButton:Hide() end
        if sb.ScrollDownButton then sb.ScrollDownButton:Hide() end
        -- Hide thumb when not needed
        sb:SetAlpha(0)
    end

    -- Scroll child
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Track scrollbar visibility state
    local scrollbarVisible = false

    -- Update scrollChild width based on scrollbar visibility.
    -- Reads live from the content frame so the scrollChild (and cards
    -- inside it) stretches when the parent frame is resized.
    local function UpdateScrollChildWidth()
        local baseWidth = content:GetWidth()
        if baseWidth <= 0 then return end
        if scrollbarVisible then
            scrollChild:SetWidth(baseWidth - scrollbarWidth)
        else
            scrollChild:SetWidth(baseWidth)
        end
    end

    -- Show/hide scrollbar and adjust content width based on content height
    local function UpdateScrollBarVisibility()
        if scrollFrame.ScrollBar then
            local contentHeight = scrollChild:GetHeight()
            local frameHeight = scrollFrame:GetHeight()
            local needsScrollbar = contentHeight > frameHeight

            -- Always update visibility, don't track state
            scrollbarVisible = needsScrollbar
            scrollFrame.ScrollBar:SetAlpha(needsScrollbar and 1 or 0)

            --UpdateScrollbar()
            UpdateScrollChildWidth()
        end
    end

    -- Store function for external access
    content.UpdateScrollBarVisibility = UpdateScrollBarVisibility

    -- Initial width setup
    UpdateScrollChildWidth()

    -- Hook multiple events to ensure visibility updates properly
    scrollFrame:HookScript("OnScrollRangeChanged", UpdateScrollBarVisibility)
    scrollChild:HookScript("OnSizeChanged", UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnSizeChanged", UpdateScrollBarVisibility)

    -- React to frame resize: when the parent frame's drag handle changes
    -- the content area's width, re-flow the scrollChild to match.
    content:HookScript("OnSizeChanged", UpdateScrollChildWidth)

    -- Also update on show
    scrollFrame:HookScript("OnShow", function()
        C_Timer.After(0, UpdateScrollBarVisibility)
    end)

    -- Store references
    content.scrollFrame = scrollFrame
    content.scrollChild = scrollChild

    -- Snapping scrollbar to pixel grid for sharper rendering
    if scrollFrame.ScrollBar then
        local sb = scrollFrame.ScrollBar
        local isSnapping = false
        local PIXEL_STEP = AE:PixelBestSize()
        local lastValue = 0
        sb:HookScript("OnValueChanged", function(self, value)
            if isSnapping then return end

            local scale = scrollFrame:GetEffectiveScale()
            -- Convert to screen pixels, round to nearest step, convert back
            local screenPixels = value * scale
            local snappedPixels = math.floor(screenPixels / PIXEL_STEP + 0.5) * PIXEL_STEP
            local snappedValue = snappedPixels / scale

            -- Only snap if we're not already at a step boundary
            if math.abs(value - snappedValue) > 0.001 then
                isSnapping = true
                self:SetValue(snappedValue)
                isSnapping = false
            end

            -- Only refresh if scroll actually changed significantly
            if math.abs(value - lastValue) > 0.1 then
                C_Timer.After(0, function()
                    RefreshAllFontStrings(scrollChild)
                end)
                lastValue = value
            end
        end)
    end

    -- Store reference
    parent.content = content
    self.contentArea = content
    return content
end

-- Create Footer
function GUIFrame:CreateFooter(parent)
    local footer = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    footer:SetHeight(Theme.footerHeight)
    footer:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    footer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    footer:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], Theme.bgMedium[4] or 1)
    footer:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], Theme.border[4] or 1)
    footer:SetFrameLevel(parent:GetFrameLevel() + 2)

    -- Version text in footer
    local versionText = footer:CreateFontString(nil, "OVERLAY")
    versionText:SetPoint("LEFT", footer, "LEFT", Theme.paddingMedium, 0)
    if AE.ApplyThemeFont then
        AE:ApplyThemeFont(versionText, "small")
    else
        versionText:SetFontObject("GameFontNormalSmall")
    end
    local addonVer = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("VXJediEssentials", "Version") or ""
    local footerFontPath = AE:GetFontPath("Expressway") or "Fonts\\FRIZQT__.TTF"
    versionText:SetFont(footerFontPath, 13, "")
    versionText:SetText(addonVer)
    versionText:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)
    versionText:SetShadowColor(0, 0, 0, 0)

    -- Resize handle
    local handle = CreateFrame("Button", nil, parent)
    handle:SetSize(16, 16)
    handle:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
    handle:SetFrameLevel(parent:GetFrameLevel() + 10)
    local tex = handle:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\AddOns\\VXJediEssentials\\Media\\GUITextures\\VXJediCustomResizeHandle23px.png")
    tex:SetVertexColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 0.6)
    handle:SetNormalTexture(tex)

    handle:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            parent:StartSizing("BOTTOMRIGHT")
        end
    end)
    handle:SetScript("OnMouseUp", function()
        parent:StopMovingOrSizing()
        if GUIFrame.SaveFrameState then
            GUIFrame:SaveFrameState()
        end
    end)

    parent.footer = footer
    parent.resizeHandle = handle
    self.footer = footer
    return footer
end


-- Refresh Content Area
function GUIFrame:RefreshContent()
    if not self.contentArea then return end

    -- Clean up custom panel if exists
    if self.contentArea._customPanel then
        self.contentArea._customPanel:Hide()
        self.contentArea._customPanel:SetParent(nil)
        self.contentArea._customPanel = nil
    end

    -- Check if there's a panel builder for this item
    local itemId = self.selectedSidebarItem
    if not itemId then
        itemId = "HomePage"
    end

    -- Check for panel builders
    if itemId and self.PanelBuilders and self.PanelBuilders[itemId] then
        if self.contentArea.scrollFrame then
            self.contentArea.scrollFrame:Hide()
        end

        local ok, panel = pcall(self.PanelBuilders[itemId], self.contentArea)
        if ok and panel then
            self.contentArea._customPanel = panel
        elseif not ok then
            if self.contentArea.scrollFrame then
                self.contentArea.scrollFrame:Show()
            end
            local scrollChild = self.contentArea.scrollChild
            local errorCard = self:CreateCard(scrollChild, L["Error"], Theme.paddingMedium)
            local errorMsg = errorCard:AddLabel("Panel builder failed: " .. tostring(panel))
            errorMsg:SetTextColor(Theme.error[1], Theme.error[2], Theme.error[3], 1)
            scrollChild:SetHeight(errorCard:GetContentHeight() + Theme.paddingLarge)
        end
        return
    end

    -- Show the outer scroll frame
    if self.contentArea.scrollFrame then
        self.contentArea.scrollFrame:Show()
    end

    -- Clear existing content
    local scrollChild = self.contentArea.scrollChild

    -- Clear existing content
    for _, region in ipairs({ scrollChild:GetRegions() }) do
        if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end

    -- Clear existing content
    for _, child in ipairs({ scrollChild:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Y offset for placing content
    local yOffset = Theme.paddingMedium

    -- Check if there's a registered content builder for this sidebar item
    if itemId and self.ContentBuilders[itemId] then
        local ok, result = pcall(self.ContentBuilders[itemId], scrollChild, yOffset)
        if ok then
            if result then
                yOffset = result
            end
        else
            local errorCard = self:CreateCard(scrollChild, L["Error"], yOffset)
            local errorMsg = errorCard:AddLabel("Content builder failed: " .. tostring(result))
            errorMsg:SetTextColor(Theme.error[1], Theme.error[2], Theme.error[3], 1)
            errorCard:AddSpacing(Theme.paddingSmall)
            yOffset = yOffset + errorCard:GetContentHeight() + Theme.paddingMedium
        end
    else
        -- No registered builder - show demo/placeholder content
        yOffset = self:BuildDemoContent(scrollChild, yOffset)
    end

    scrollChild:SetHeight(yOffset + Theme.paddingLarge)
    if self.contentArea.UpdateScrollbar then
        self.contentArea.UpdateScrollbar()
    end
end

-- Placeholder card
function GUIFrame:BuildDemoContent(scrollChild, yOffset)
    -- Card 1
    local card1 = GUIFrame:CreateCard(scrollChild, L["Coming Soon"], yOffset)
    card1:AddLabel("This section is under construction.")
    card1:AddSpacing(Theme.paddingSmall)
    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingMedium
    return yOffset
end

-- Show GUI Frame
function GUIFrame:Show()
    -- Check combat lockdown
    if InCombatLockdown() then
        AE:Print("Options will open after combat ends.")
        self.reopenAfterCombat = true
        return
    end

    -- Create main frame if it doesn't exist
    local isFirstCreate = not self.mainFrame
    if isFirstCreate then
        self:CreateMainFrame()
        GUIFrame:InitializeSidebarExpansion()
    end

    -- Restore position if not first create
    self:RestoreFramePosition()
    self.mainFrame:Show()
    self.mainFrame:Raise()
    AE.GUIOpen = true

    -- Notify preview manager that GUI is open
    if AE.PreviewManager then
        AE.PreviewManager:SetGUIOpen(true)
    end

    -- Initialize sidebar and content for current tab
    self:RefreshSidebar()

    -- Defer a refresh after frame layout completes to ensure correct widths
    C_Timer.After(0, function()
        if self.mainFrame and self.mainFrame:IsShown() then
            -- Force sidebar scrollChild to get correct width
            if self.sidebar then
                local sidebarWidth = self.sidebar:GetWidth()
                if sidebarWidth and sidebarWidth > 0 and self.sidebar.scrollChild then
                    local newWidth = sidebarWidth - Theme.paddingSmall * 2 - 16
                    self.sidebar.scrollChild:SetWidth(newWidth)
                end
            end
            self:RefreshSidebar()
            self:RefreshContent()
            if self.contentArea and self.contentArea.scrollChild then
                RefreshAllFontStrings(self.contentArea.scrollChild)
            end
        end
    end)
end

-- Hide GUI Frame
function GUIFrame:Hide()
    if self.mainFrame then
        self:SaveFramePosition()

        -- Save GUI state to session memory
        if self.SaveSessionState then
            self:SaveSessionState()
        end

        -- Fire on-close callbacks, for previews registered via RegisterOnCloseCallback
        if self.FireOnCloseCallbacks then
            self:FireOnCloseCallbacks()
        end

        AE.GUIOpen = false
        if AE.PreviewManager then
            AE.PreviewManager:SetGUIOpen(false)
        end
        self.mainFrame:Hide()
    else
        AE.GUIOpen = false
        if AE.PreviewManager then
            AE.PreviewManager:SetGUIOpen(false)
        end
    end
end

-- Toggle GUI Frame
function GUIFrame:Toggle()
    if self.mainFrame and self.mainFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Is GUI Frame Shown
function GUIFrame:IsShown()
    return self.mainFrame and self.mainFrame:IsShown()
end

-- Session state
GUIFrame.sessionState = GUIFrame.sessionState or {
    scrollPositions = {},
    selectedTab = "systems",
    selectedSidebarItem = nil,
}

-- Get Session State
function GUIFrame:GetSessionState()
    return self.sessionState
end

-- Save Session State
function GUIFrame:SaveSessionState()
    if not self.mainFrame then return end

    -- Save current scroll position for current tab
    if self.sidebar and self.sidebar.scrollFrame and self.selectedTab then
        local scrollValue = self.sidebar.scrollFrame:GetVerticalScroll()
        self.sessionState.scrollPositions[self.selectedTab] = scrollValue
    end

    -- Save selected tab and sidebar item
    self.sessionState.selectedTab = self.selectedTab
    self.sessionState.selectedSidebarItem = self.selectedSidebarItem
end

-- Restore Session State
function GUIFrame:RestoreSessionState()
    if not self.sessionState then return end

    -- Restore selected tab
    if self.sessionState.selectedTab then
        self.selectedTab = self.sessionState.selectedTab
    end

    -- Restore selected sidebar item
    if self.sessionState.selectedSidebarItem then
        self.selectedSidebarItem = self.sessionState.selectedSidebarItem
    end

    -- Restore scroll position
    C_Timer.After(0.01, function()
        if self.sidebar and self.sidebar.scrollFrame and self.selectedTab then
            local scrollValue = self.sessionState.scrollPositions[self.selectedTab]
            if scrollValue then
                self.sidebar.scrollFrame:SetVerticalScroll(scrollValue)
            end
        end
    end)
end

-- Save Frame Position to SavedVariables
function GUIFrame:SaveFramePosition()
    if not self.mainFrame then return end
    if not AE.db or not AE.db.global then return end

    local point, _, relPoint, x, y = self.mainFrame:GetPoint()

    -- Save to SavedVariables
    AE.db.global.GUIState = AE.db.global.GUIState or {}
    AE.db.global.GUIState.frame = {
        point = point,
        relativePoint = relPoint,
        xOffset = x,
        yOffset = y,
        width = self.mainFrame:GetWidth(),
        height = self.mainFrame:GetHeight(),
    }

    -- Also keep in memory for session
    self.savedPosition = AE.db.global.GUIState.frame

    -- Also save session state
    self:SaveSessionState()
end

-- Restore Frame Position
function GUIFrame:RestoreFramePosition()
    if not self.mainFrame then return end

    -- Try to load from SavedVariables first
    local pos = nil
    if AE.db and AE.db.global and AE.db.global.GUIState and AE.db.global.GUIState.frame then
        pos = AE.db.global.GUIState.frame
    end

    -- Fall back to in-memory position
    if not pos then
        pos = self.savedPosition
    end

    -- Apply position if we have one
    if pos then
        self.mainFrame:ClearAllPoints()
        self.mainFrame:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.xOffset or 0,
            pos.yOffset or 50)
        if pos.width and pos.height then
            self.mainFrame:SetSize(pos.width, pos.height)
        end
    end

    -- Also restore session state
    self:RestoreSessionState()
end

-- Combat handling: Close GUI on entering combat, reopen on leaving combat
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat - force close
        if GUIFrame:IsShown() then
            GUIFrame.reopenAfterCombat = true
            GUIFrame:Hide()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leaving combat - reopen if needed
        if GUIFrame.reopenAfterCombat then
            GUIFrame.reopenAfterCombat = nil
            GUIFrame:Show()
        end
    end
end)
