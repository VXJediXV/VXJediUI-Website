-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

-- Localization
local UnitName = UnitName
local UnitClass = UnitClass
local GetRealmName = GetRealmName
local ipairs = ipairs
local ReloadUI = ReloadUI

-- Addon info
local ADDON_VERSION = AE.Version
local ADDON_AUTHOR = AE.Author

-- Register HomePage content
local L = AE.L
GUIFrame:RegisterContent("HomePage", function(scrollChild, yOffset)
    local _, class = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }

    ----------------------------------------------------------------
    -- Card 1: Welcome Header
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Welcome to VXJediEssentials"], yOffset)

    -- Player greeting
    local playerName = UnitName("player") or "Adventurer"
    local greetingText = "Hello, |cff" ..
        string.format("%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255) ..
        playerName .. "|r!"
    local greetingLabel = card1:AddLabel(greetingText)

    card1:AddSpacing(4)

    -- Version and author info
    local infoText = "Version: |cffffffff" .. ADDON_VERSION .. "|r  -  Author: |cffffffff" .. ADDON_AUTHOR .. "|r"
    local infoLabel = card1:AddLabel(infoText)
    infoLabel:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    card1:AddSpacing(2)

    -- Credit line
    local creditLabel = card1:AddLabel(L["Based on work provided by |cffffffffNorsken|r"])
    creditLabel:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Quick Actions
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Quick Actions"], yOffset)

    local row1 = GUIFrame:CreateRow(card2.content, 38)

    -- Reload UI Button
    local reloadBtn = GUIFrame:CreateButton(row1, L["Reload UI"], {
        width = 140,
        height = 32,
        callback = function()
            ReloadUI()
        end
    })
    row1:AddWidget(reloadBtn, 0.5)

    card2:AddRow(row1, 38)

    card2:AddSpacing(4)
    local tipLabel = card2:AddLabel(
        "Use |cffffffff/aes|r to open settings, |cffffffff/rl|r to reload.")
    tipLabel:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2b: General Settings
    ----------------------------------------------------------------
    local card2b = GUIFrame:CreateCard(scrollChild, L["General Settings"], yOffset)

    local row2b1 = GUIFrame:CreateRow(card2b.content, 36)
    local minimapDb = AE.db and AE.db.profile.Minimap
    local minimapCheck = GUIFrame:CreateCheckbox(row2b1, L["Show Minimap Button"],
        minimapDb and not minimapDb.hide,
        function(checked)
            if minimapDb then
                minimapDb.hide = not checked
                local icon = LibStub and LibStub("LibDBIcon-1.0", true)
                if icon then
                    if checked then
                        icon:Show("VXJediEssentials")
                    else
                        icon:Hide("VXJediEssentials")
                    end
                end
            end
        end)
    row2b1:AddWidget(minimapCheck, 1)
    card2b:AddRow(row2b1, 36)

    local row2b2 = GUIFrame:CreateRow(card2b.content, 36)
    local chatMsgCheck = GUIFrame:CreateCheckbox(row2b2, L["Show Command in Chat on Login"],
        AE.db and AE.db.profile.ShowChatMessage == true,
        function(checked)
            if AE.db then
                AE.db.profile.ShowChatMessage = checked
            end
        end)
    row2b2:AddWidget(chatMsgCheck, 1)
    card2b:AddRow(row2b2, 36)

    yOffset = yOffset + card2b:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Current Profile
    ----------------------------------------------------------------
    local card3 = GUIFrame:CreateCard(scrollChild, L["Profile"], yOffset)

    local profileName = AE.db and AE.db:GetCurrentProfile() or "Default"
    local profileLabel = card3:AddLabel("Active Profile: |cffffffff" .. profileName .. "|r")

    card3:AddSpacing(4)

    local realmName = GetRealmName() or "Unknown"
    local charInfo = playerName .. " - " .. realmName
    local charLabel = card3:AddLabel("Character: |cffffffff" .. charInfo .. "|r")
    charLabel:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 4: Getting Started
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Getting Started"], yOffset)

    local tips = {
        "Use the sidebar to navigate between different module settings.",
        "Each module has its own position settings in its GUI tab.",
        "Most changes apply instantly without needing a reload. Modules where a reload is required will prompt you.",
    }

    for _, tip in ipairs(tips) do
        local tipLabel2 = card4:AddLabel(AE:ColorTextByTheme("\226\128\162 ") .. tip)
        tipLabel2:SetTextColor(Theme.textSecondary[1], Theme.textSecondary[2], Theme.textSecondary[3], 1)
        card4:AddSpacing(2)
    end

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Support
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Support"], yOffset)

    local supportLabel = card5:AddLabel("Found a bug or have a suggestion?")
    card5:AddSpacing(4)

    local discordLabel = card5:AddLabel("Join the Discord: |cff5865F2discord.gg/vxjedixv|r")
    discordLabel:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    yOffset = yOffset - (Theme.paddingSmall * 3)
    return yOffset
end)
