local VXJediUI = select(2, ...)

function VXJediUI:SetPlater(resolution, forceImport)
    if not Plater then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("Plater is not loaded", 1.0, 0.0, 0.0)
        return
    end

    local profileName = "VXJediUI"
    local profileString = VXJediUI.PlaterProfileString[resolution]

    if not profileString or profileString == "" then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("Plater profile string not found for " .. resolution, 1.0, 0.0, 0.0)
        return
    end

    if forceImport then
        local data = Plater.DecompressData(profileString, "print")
        if data then
            PlaterDB.profiles[profileName] = data
        else
            UIErrorsFrame:SetScale(2)
            UIErrorsFrame:AddMessage("Failed to decompress Plater profile", 1.0, 0.0, 0.0)
            return
        end
        VXJediUIDB.InstalledVersions["Plater"] = GetAddonInstalledVersion("Plater")
    end

    PlaterDB["profileKeys"][UnitName("player") .. " - " .. GetRealmName()] = profileName

    VXJediUI.PlaterEnabled = true

    UIErrorsFrame:SetScale(2)
    RefreshImportStatus("Plater")
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported Plater", 1.0, 1.0, 1.0)
end
