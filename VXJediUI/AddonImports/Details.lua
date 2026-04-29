local VXJediUI = select(2, ...)

function VXJediUI:SetDetails(resolution, forceImport)
    if (forceImport) then
        _detalhes:EraseProfile("VXJediUI")
        _detalhes:ImportProfile(VXJediUI.DetailsProfileString[resolution], "VXJediUI", true, true)

        VXJediUIDB.InstalledVersions["Details"] = GetAddonInstalledVersion("Details")
    end
    
    _detalhes:ApplyProfile("VXJediUI", false, false)

    DEFAULT_CHAT_FRAME.editBox:SetText("/details show") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    
    UIErrorsFrame:SetScale(2);
    RefreshImportStatus("Details")
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported Details", 1.0, 1.0, 1.0);
end
