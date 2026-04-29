local VXJediUI = select(2, ...)

function VXJediUI:SetBuffReminders(resolution, forceImport)
    if not BuffRemindersAPI then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("BuffReminders is not loaded", 1.0, 0.0, 0.0)
        return
    end

    if forceImport then
        local profileString = VXJediUI.BuffRemindersProfileString[resolution]
        if profileString and profileString ~= "ENTERSTRINGHERE" then
            BuffRemindersAPI:ImportProfile(profileString, "VXJediUI")
        end

        VXJediUIDB.InstalledVersions["BuffReminders"] = GetAddonInstalledVersion("BuffReminders")
    end

    -- Set the profile for this character (works for both import and load)
    BuffRemindersAPI:SetProfile("VXJediUI")

    UIErrorsFrame:SetScale(2)
    RefreshImportStatus("BuffReminders")
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported BuffReminders", 1.0, 1.0, 1.0)
end
