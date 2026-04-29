local VXJediUI = select(2, ...)

function VXJediUI:SetBigWigs(resolution, forceImport)
    local profileString = VXJediUI.BigWigsProfileString[resolution]

    if not profileString or profileString == "" then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("BigWigs profile string not found for " .. resolution, 1.0, 0.0, 0.0)
        return
    end

    if not BigWigsAPI or not BigWigsAPI.RegisterProfile then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("BigWigs API not available", 1.0, 0.0, 0.0)
        return
    end

    local function onImportComplete()
        VXJediUIDB.InstalledVersions["BigWigs"] = GetAddonInstalledVersion("BigWigs")
        RefreshImportStatus("BigWigs")
    end

    BigWigsAPI.RegisterProfile("VXJediUI", profileString, "VXJediUI", onImportComplete)
end
