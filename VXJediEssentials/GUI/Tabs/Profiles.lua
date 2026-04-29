-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local GUIFrame = AE.GUIFrame
local Theme = AE.Theme

-- Localization
local pairs = pairs

-- Build profile options for dropdowns
local L = AE.L
local function BuildProfileOptions()
    local PM = AE.ProfileManager
    if not PM then return {} end

    local profiles = PM:GetProfiles()
    local options = {}
    for _, name in pairs(profiles) do
        options[name] = name
    end
    return options
end

-- Register ProfileManager content
GUIFrame:RegisterContent("ProfileManager", function(scrollChild, yOffset)
    local PM = AE.ProfileManager
    if not PM then
        local errorCard = GUIFrame:CreateCard(scrollChild, L["Error"], yOffset)
        errorCard:AddLabel("ProfileManager not initialized. Please reload UI.")
        return yOffset + errorCard:GetContentHeight() + Theme.paddingSmall
    end

    ----------------------------------------------------------------
    -- Card 1: Current Profile
    ----------------------------------------------------------------
    local card1 = GUIFrame:CreateCard(scrollChild, L["Current Profile"], yOffset)

    local useGlobal = PM:GetUseGlobalProfile()
    local currentProfile = PM:GetCurrentProfile()
    local profileOptions = BuildProfileOptions()
    local noGlobal = useGlobal == false

    local row1 = GUIFrame:CreateRow(card1.content, 40)
    local profileDropdown = GUIFrame:CreateDropdown(row1, L["Active Profile"], profileOptions, currentProfile, 100,
        function(key)
            if key == currentProfile then return end

            local success, err = PM:SetProfile(key)
            if not success then
                AE:Print("Failed to switch profile: " .. (err or "Unknown error"))
            end
        end)
    row1:AddWidget(profileDropdown, 1)
    card1:AddRow(row1, 40)

    profileDropdown:SetEnabled(noGlobal)

    local descLabel = card1:AddLabel("Select which profile to use for this character.")
    descLabel:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    yOffset = yOffset + card1:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 2: Global Profile
    ----------------------------------------------------------------
    local card2 = GUIFrame:CreateCard(scrollChild, L["Global Profile"], yOffset)

    local globalProfile = PM:GetGlobalProfile()

    -- Toggle for global mode
    local row2a = GUIFrame:CreateRow(card2.content, 36)
    local globalToggle = GUIFrame:CreateCheckbox(row2a, L["Use Global Profile"], useGlobal,
        function(newState)
            local success = PM:SetUseGlobalProfile(newState)
            if success then
                if not newState then
                    AE:Print("Global profile mode disabled")
                    C_Timer.After(0.1, function()
                        if GUIFrame.mainFrame and GUIFrame.mainFrame:IsShown() then
                            GUIFrame:RefreshContent()
                        end
                    end)
                end
            end
        end)
    row2a:AddWidget(globalToggle, 1)
    card2:AddRow(row2a, 36)

    -- Global profile selection
    local row2b = GUIFrame:CreateRow(card2.content, 40)
    local globalDropdown = GUIFrame:CreateDropdown(row2b, L["Global Profile"], profileOptions, globalProfile, 100,
        function(key)
            local success, err = PM:SetGlobalProfile(key)
            if not success then
                AE:Print("Failed to set global profile: " .. (err or "Unknown error"))
            else
                if not useGlobal then
                    AE:Print("Global profile set to: " .. key)
                end
            end
        end)
    row2b:AddWidget(globalDropdown, 1)
    card2:AddRow(row2b, 40)

    -- Enable/disable global dropdown based on toggle state
    globalDropdown:SetEnabled(useGlobal)

    card2:AddSpacing(Theme.paddingSmall)
    local globalDesc = card2:AddLabel("When enabled, all characters will use the same profile.")
    globalDesc:SetTextColor(Theme.textMuted[1], Theme.textMuted[2], Theme.textMuted[3], 1)

    yOffset = yOffset + card2:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 3: Profile Actions
    ----------------------------------------------------------------
    local card3 = GUIFrame:CreateCard(scrollChild, L["Profile Actions"], yOffset)

    -- Create New Profile
    card3:AddLabel("Create New Profile")

    local row3a = GUIFrame:CreateRow(card3.content, 40)
    local newProfileInput = GUIFrame:CreateEditBox(row3a, L["Profile Name"], "", function() end)
    row3a:AddWidget(newProfileInput, 0.65)

    local createBtn = GUIFrame:CreateButton(row3a, "Create", {
        width = 80,
        height = 24,
        callback = function()
            local name = newProfileInput:GetValue()
            if name and name ~= "" then
                local success, err = PM:CreateProfile(name)
                if success then
                    AE:Print("Created profile: " .. name)
                    newProfileInput:SetValue("")
                    C_Timer.After(0.1, function()
                        if GUIFrame.mainFrame and GUIFrame.mainFrame:IsShown() then
                            GUIFrame:RefreshContent()
                        end
                    end)
                else
                    AE:Print("Failed to create profile: " .. (err or "Unknown error"))
                end
            else
                AE:Print("Please enter a profile name")
            end
        end
    })
    row3a:AddWidget(createBtn, 0.35, nil, 0, -14)
    card3:AddRow(row3a, 40)

    -- Separator
    local row3asep = GUIFrame:CreateRow(card3.content, 8)
    local seprow5Card = GUIFrame:CreateSeparator(row3asep)
    row3asep:AddWidget(seprow5Card, 1)
    card3:AddRow(row3asep, 8)

    -- Copy Profile
    card3:AddLabel(L["Copy From Profile"])

    local row3b = GUIFrame:CreateRow(card3.content, 40)
    local copyDropdown = GUIFrame:CreateDropdown(row3b, L["Source Profile"], profileOptions, "", 100, function() end)
    row3b:AddWidget(copyDropdown, 0.65)

    local copyBtn = GUIFrame:CreateButton(row3b, "Copy", {
        width = 80,
        height = 24,
        callback = function()
            local source = copyDropdown:GetValue()
            if source and source ~= "" then
                AE:CreatePrompt({
                    title = "Copy Profile",
                    text = "Copy all settings from '" ..
                        source .. "' to current profile?\nThis will overwrite your current settings.",
                    onAccept = function()
                        local success, err = PM:CopyProfile(source)
                        if not success then
                            AE:Print("Failed to copy profile: " .. (err or "Unknown error"))
                        end
                    end,
                    acceptText = "Copy",
                    cancelText = "Cancel",
                })
            else
                AE:Print("Please select a source profile")
            end
        end
    })
    row3b:AddWidget(copyBtn, 0.35, nil, 0, -14)
    card3:AddRow(row3b, 40)

    -- Separator
    local row3bsep = GUIFrame:CreateRow(card3.content, 8)
    local seprow3bCard = GUIFrame:CreateSeparator(row3bsep)
    row3bsep:AddWidget(seprow3bCard, 1)
    card3:AddRow(row3bsep, 8)

    -- Delete Profile
    card3:AddLabel("Delete Profile")

    local row3c = GUIFrame:CreateRow(card3.content, 40)
    local deleteDropdown = GUIFrame:CreateDropdown(row3c, L["Profile to Delete"], profileOptions, "", 100, function() end)
    row3c:AddWidget(deleteDropdown, 0.65)

    local deleteBtn = GUIFrame:CreateButton(row3c, "Delete", {
        width = 80,
        height = 24,
        callback = function()
            local toDelete = deleteDropdown:GetValue()
            if toDelete and toDelete ~= "" then
                if toDelete == PM:GetCurrentProfile() then
                    AE:Print(L["Cannot delete the active profile"])
                    return
                end
                AE:CreatePrompt({
                    title = "Delete Profile",
                    text = "Are you sure you want to delete '" .. toDelete .. "'?\nThis cannot be undone.",
                    onAccept = function()
                        local success, err = PM:DeleteProfile(toDelete)
                        if success then
                            AE:Print("Deleted profile: " .. toDelete)
                            C_Timer.After(0.1, function()
                                if GUIFrame.mainFrame and GUIFrame.mainFrame:IsShown() then
                                    GUIFrame:RefreshContent()
                                end
                            end)
                        else
                            AE:Print("Failed to delete profile: " .. (err or "Unknown error"))
                        end
                    end,
                    acceptText = "Delete",
                    cancelText = "Cancel",
                })
            else
                AE:Print("Please select a profile to delete")
            end
        end
    })
    row3c:AddWidget(deleteBtn, 0.35, nil, 0, -14)
    card3:AddRow(row3c, 40)

    yOffset = yOffset + card3:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 4: Import/Export
    ----------------------------------------------------------------
    local card4 = GUIFrame:CreateCard(scrollChild, L["Import / Export"], yOffset)

    -- Export section
    card4:AddLabel("Export Current Profile")

    local row4a = GUIFrame:CreateRow(card4.content, 36)
    local exportBtn = GUIFrame:CreateButton(row4a, "Export Profile to String", {
        callback = function()
            local exportString, err = PM:ExportProfile()
            if exportString then
                AE:CreatePrompt({
                    title = "Export Profile",
                    text = exportString,
                    showEditBox = true,
                    editBoxLabel = "Copy the string above (Ctrl+C)",
                })
                AE:Print("Export Success")
            else
                AE:Print("Export failed: " .. (err or "Unknown error"))
            end
        end
    })
    row4a:AddWidget(exportBtn, 1)
    card4:AddRow(row4a, 36)

    -- Separator
    local row4asep = GUIFrame:CreateRow(card4.content, 8)
    local seprow4aCard = GUIFrame:CreateSeparator(row4asep)
    row4asep:AddWidget(seprow4aCard, 1)
    card4:AddRow(row4asep, 8)

    -- Import section
    card4:AddLabel("Import Profile")

    local row4b = GUIFrame:CreateRow(card4.content, 40)
    local importNameInput = GUIFrame:CreateEditBox(row4b, L["Profile Name (leave empty for default)"], "", function() end)
    row4b:AddWidget(importNameInput, 1)
    card4:AddRow(row4b, 40)

    local row4c = GUIFrame:CreateRow(card4.content, 36)
    local importBtn = GUIFrame:CreateButton(row4c, "Import Profile from String", {
        callback = function()
            AE:CreatePrompt({
                title = "Import Profile",
                text = "Paste import string and press Enter",
                showEditBox = true,
                editBoxLabel = "",
                onAccept = function(importString)
                    if importString and importString ~= "" then
                        local targetName = importNameInput:GetValue()
                        if targetName == "" then targetName = nil end

                        local success, nameOrErr = PM:ImportProfile(importString, targetName)
                        if success then
                            AE:Print("Imported profile: " .. nameOrErr)
                            importNameInput:SetValue("")
                            C_Timer.After(0.1, function()
                                if GUIFrame.mainFrame and GUIFrame.mainFrame:IsShown() then
                                    GUIFrame:RefreshContent()
                                end
                            end)
                        else
                            AE:Print("Import failed: " .. (nameOrErr or "Unknown error"))
                        end
                    end
                end,
                acceptText = "Import",
                cancelText = "Cancel",
            })
        end
    })
    row4c:AddWidget(importBtn, 1)
    card4:AddRow(row4c, 36)

    yOffset = yOffset + card4:GetContentHeight() + Theme.paddingSmall

    ----------------------------------------------------------------
    -- Card 5: Rename Profile
    ----------------------------------------------------------------
    local card5 = GUIFrame:CreateCard(scrollChild, L["Rename Profile"], yOffset)

    local row5a = GUIFrame:CreateRow(card5.content, 40)
    local renameDropdown = GUIFrame:CreateDropdown(row5a, L["Profile to Rename"], profileOptions, "", 100, function() end)
    row5a:AddWidget(renameDropdown, 1)
    card5:AddRow(row5a, 40)

    local row5b = GUIFrame:CreateRow(card5.content, 40)
    local newNameInput = GUIFrame:CreateEditBox(row5b, L["New Name"], "", function() end)
    row5b:AddWidget(newNameInput, 0.65)

    local renameBtn = GUIFrame:CreateButton(row5b, "Rename", {
        width = 80,
        height = 24,
        callback = function()
            local oldName = renameDropdown:GetValue()
            local newName = newNameInput:GetValue()

            if not oldName or oldName == "" then
                AE:Print("Please select a profile to rename")
                return
            end

            if not newName or newName == "" then
                AE:Print("Please enter a new name")
                return
            end

            local success, err = PM:RenameProfile(oldName, newName)
            if success then
                AE:Print("Renamed '" .. oldName .. "' to '" .. newName .. "'")
                newNameInput:SetValue("")
                C_Timer.After(0.1, function()
                    if GUIFrame.mainFrame and GUIFrame.mainFrame:IsShown() then
                        GUIFrame:RefreshContent()
                    end
                end)
            else
                AE:Print("Failed to rename: " .. (err or "Unknown error"))
            end
        end
    })
    row5b:AddWidget(renameBtn, 0.35, nil, 0, -14)
    card5:AddRow(row5b, 40)

    yOffset = yOffset + card5:GetContentHeight() + Theme.paddingSmall

    yOffset = yOffset - (Theme.paddingSmall * 2)
    return yOffset
end)
