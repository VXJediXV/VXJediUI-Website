-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

local CreateFrame = CreateFrame
local ipairs = ipairs

------------------------------------------------------------------------
-- Sub-tab switcher widget
--
-- A horizontal row of pill-style tab buttons. The active tab is filled
-- with the theme accent color; inactive tabs are muted. Clicking an
-- inactive tab fires the onSwitch callback which is expected to update
-- some external "active tab" state and call GUIFrame:RefreshContent()
-- to re-render the content area with the new tab's content.
--
-- Usage:
--   local _, newOffset = GUIFrame:CreateSubTabs(scrollChild, yOffset, {
--       tabs = {
--           { id = "target", label = "Target" },
--           { id = "focus",  label = "Focus"  },
--       },
--       activeId = currentTab,
--       onSwitch = function(newId)
--           currentTab = newId
--           GUIFrame:RefreshContent()
--       end,
--   })
--   yOffset = newOffset
--   -- ...render content for currentTab below...
--
-- Returns: (container frame, new yOffset after the sub-tab row)
------------------------------------------------------------------------
function GUIFrame:CreateSubTabs(parent, yOffset, config)
    config = config or {}
    local tabs = config.tabs or {}
    local activeId = config.activeId
    local onSwitch = config.onSwitch

    local rowHeight = 32
    local buttonHeight = 28
    local buttonWidth = 110
    local spacing = 4

    -- Container anchored the same way CreateCard anchors itself
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", Theme.paddingSmall, -(yOffset or 0) + Theme.paddingSmall)
    container:SetPoint("RIGHT", parent, "RIGHT", -Theme.paddingSmall, 0)
    container:SetHeight(rowHeight)

    local buttons = {}

    for i, tab in ipairs(tabs) do
        local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
        btn:SetSize(buttonWidth, buttonHeight)
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", (i - 1) * (buttonWidth + spacing), -2)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })

        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        AE:ApplyThemeFont(text, "normal")
        text:SetText(tab.label or tab.id)

        btn.tabId = tab.id
        btn.text = text

        local function UpdateVisual()
            if btn.tabId == activeId then
                -- Active: filled with accent color, accent border, accent text
                btn:SetBackdropColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 0.35)
                btn:SetBackdropBorderColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
                text:SetTextColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
            else
                -- Inactive: muted bg, dim border, secondary text
                btn:SetBackdropColor(Theme.bgMedium[1], Theme.bgMedium[2], Theme.bgMedium[3], 1)
                btn:SetBackdropBorderColor(Theme.border[1], Theme.border[2], Theme.border[3], 1)
                text:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 0.7)
            end
        end

        btn:SetScript("OnClick", function(self)
            if self.tabId ~= activeId then
                if onSwitch then onSwitch(self.tabId) end
            end
        end)

        btn:SetScript("OnEnter", function(self)
            if self.tabId ~= activeId then
                self:SetBackdropBorderColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
                self.text:SetTextColor(Theme.accent[1], Theme.accent[2], Theme.accent[3], 1)
            end
        end)

        btn:SetScript("OnLeave", function(self)
            UpdateVisual()
        end)

        UpdateVisual()
        buttons[tab.id] = btn
    end

    container.buttons = buttons

    return container, (yOffset or 0) + rowHeight + Theme.paddingSmall
end
