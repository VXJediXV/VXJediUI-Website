local VXJediUI = select(2, ...)

function VXJediUI:SetAyijeCDM(resolution, forceImport)
    if not Ayije_CDM_API then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("Ayije CDM is not loaded", 1.0, 0.0, 0.0)
        return
    end

    local profileStrings = VXJediUI.AyijeCDMProfileString[resolution]

    if not profileStrings then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("Ayije CDM profile strings not found for " .. resolution, 1.0, 0.0, 0.0)
        return
    end

    if forceImport then
        -- Import all 4 profiles
        local profileNames = { "VXJediUI", "VXJediUI CastEmphasize", "VXJediUI Healer", "VXJediUI Healer DualResource" }
        for _, profileName in ipairs(profileNames) do
            local profileString = profileStrings[profileName]
            if profileString and profileString ~= "ENTERSTRINGHERE" then
                Ayije_CDM_API:ImportProfile(profileString, profileName)
            end
        end

        VXJediUIDB.InstalledVersions["AyijeCDM"] = GetAddonInstalledVersion("AyijeCDM")
    end

    local charKey = UnitName("player") .. " - " .. GetRealmName()
    local className, _ = UnitClass("player")

    local specMapping = GetAyijeCDMSpecProfilesFromClass(className)

    if not Ayije_CDMDB["specProfiles"] then
        Ayije_CDMDB["specProfiles"] = {}
    end

    Ayije_CDMDB["specProfiles"][charKey] = specMapping

    -- Set the current profile to match the player's active spec
    local currentSpecIndex = GetSpecialization() or 1
    local profileForCurrentSpec = specMapping and specMapping[currentSpecIndex] or "VXJediUI"
    Ayije_CDMDB["profileKeys"][charKey] = profileForCurrentSpec

    UIErrorsFrame:SetScale(2)
    RefreshImportStatus("AyijeCDM")
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported Ayije CDM", 1.0, 1.0, 1.0)
end
