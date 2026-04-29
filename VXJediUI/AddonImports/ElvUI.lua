local VXJediUI = select(2, ...)
local E, L, V, P, G = unpack(ElvUI)

function VXJediUI:SetElvUI(useColor, resolution, forceImport)
    if (forceImport) then
        local D = E:GetModule("Distributor")
        local strings = VXJediUI.ElvUIStrings[resolution]

        if not strings then
            print("|cffff0000VXJediUI:|r No ElvUI strings found for resolution: " .. tostring(resolution))
            return
        end

        -- Import only the 2 profiles matching the selected theme
        local profileNames
        if useColor then
            profileNames = { "VXJediUI [C]", "VXJediUI Healer [C]" }
        else
            profileNames = { "VXJediUI", "VXJediUI Healer" }
        end

        for _, profileName in ipairs(profileNames) do
            local profileString = strings[profileName]
            if profileString and profileString ~= "ENTERSTRINGHERE" then
                local profileType, profileKey, profileData = D:Decode(profileString)
                if profileData then
                    ElvDB["profiles"] = ElvDB["profiles"] or {}
                    ElvDB["profiles"][profileKey] = profileData
                end
            end
        end

        -- Import global settings
        if strings["global"] and strings["global"] ~= "ENTERSTRINGHERE" then
            local profileType, profileKey, profileData = D:Decode(strings["global"])
            if profileData then
                if not ElvDB.global then ElvDB.global = {} end
                E:CopyTable(ElvDB.global, profileData)
            end
        end

        -- Import private settings
        if strings["private"] and strings["private"] ~= "ENTERSTRINGHERE" then
            local profileType, profileKey, profileData = D:Decode(strings["private"])
            if profileData then
                ElvPrivateDB["profiles"] = ElvPrivateDB["profiles"] or {}
                ElvPrivateDB["profiles"]["VXJediUI"] = profileData
            end
        end

        -- Import aura filters
        if strings["filters"] and strings["filters"] ~= "ENTERSTRINGHERE" then
            local profileType, profileKey, profileData = D:Decode(strings["filters"])
            if profileData and type(profileData) == "table" then
                if not ElvDB.global then ElvDB.global = {} end
                if not ElvDB.global.unitframe then ElvDB.global.unitframe = {} end
                -- Filter exports contain a .unitframe wrapper with aurafilters inside
                if profileData.unitframe then
                    E:CopyTable(ElvDB.global.unitframe, profileData.unitframe)
                else
                    -- Fallback: treat as direct aurafilters table
                    if not ElvDB.global.unitframe.aurafilters then ElvDB.global.unitframe.aurafilters = {} end
                    for filterName, filterData in pairs(profileData) do
                        ElvDB.global.unitframe.aurafilters[filterName] = filterData
                    end
                end
            end
        end

        -- Set UIScale per resolution (global import blacklists UIScale)
        if not ElvDB.global.general then ElvDB.global.general = {} end
        if resolution == "1080p" then
            ElvDB.global.general.UIScale = 0.7111111111111111
        else
            ElvDB.global.general.UIScale = 0.5333333
        end

        -- Private profile: only "VXJediUI" exists, all variants share it
        -- No need to copy to healer/color variants

        VXJediUIDB.InstalledVersions["ElvUI"] = GetAddonInstalledVersion("ElvUI")
    end

    -- Set profile keys in SavedVariables (applied on reload)
    local charKey = UnitName("player") .. " - " .. GetRealmName()

    ElvPrivateDB["profileKeys"] = ElvPrivateDB["profileKeys"] or {}
    VXJediUIDB.AddonData.ElvUI.ProfileKeys = VXJediUIDB.AddonData.ElvUI.ProfileKeys or {}
    ElvDB["profileKeys"] = ElvDB["profileKeys"] or {}

    -- Determine the correct profile for the current spec (matches LibDualSpec config)
    -- so ElvUI loads the right profile on reload without a mid-init switch
    local className = UnitClass("player")
    local dualSpecConfig = GetDualSpecConfigFromClass(className, useColor)
    local currentSpecIndex = GetSpecialization() or 1
    local profileForCurrentSpec

    if dualSpecConfig and dualSpecConfig[currentSpecIndex] then
        profileForCurrentSpec = dualSpecConfig[currentSpecIndex]
    elseif useColor then
        profileForCurrentSpec = "VXJediUI [C]"
    else
        profileForCurrentSpec = "VXJediUI"
    end

    VXJediUIDB.AddonData.ElvUI.ProfileKeys[charKey] = profileForCurrentSpec
    ElvDB["profileKeys"][charKey] = profileForCurrentSpec
    ElvPrivateDB["profileKeys"][charKey] = "VXJediUI"

    E.private["nameplates"] = E.private["nameplates"] or {}
    E.private["nameplates"]["enable"] = false

    -- Force blacklisted settings that don't save to profiles
    -- Write directly to all profile tables so it persists through reload
    local profileNames = { "VXJediUI", "VXJediUI Healer", "VXJediUI [C]", "VXJediUI Healer [C]" }
    for _, pName in ipairs(profileNames) do
        if ElvDB["profiles"] and ElvDB["profiles"][pName] then
            ElvDB["profiles"][pName]["chat"] = ElvDB["profiles"][pName]["chat"] or {}
            ElvDB["profiles"][pName]["chat"]["hideVoiceButtons"] = true
        end
    end

    -- Set dual spec profiles
    local className, _ = UnitClass("player");
    ElvDB["namespaces"] = ElvDB["namespaces"] or {}
    ElvDB["namespaces"]["LibDualSpec-1.0"] = ElvDB["namespaces"]["LibDualSpec-1.0"] or {}
    ElvDB["namespaces"]["LibDualSpec-1.0"]["char"] = ElvDB["namespaces"]["LibDualSpec-1.0"]["char"] or {}
    ElvDB["namespaces"]["LibDualSpec-1.0"]["char"][charKey] = GetDualSpecConfigFromClass(className, useColor)

    RefreshImportStatus("ElvUI")
    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported ElvUI", 1.0, 1.0, 1.0);
end
