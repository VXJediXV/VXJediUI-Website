local VXJediUI = select(2, ...)

function VXJediUI:SetWarpDeplete(resolution, forceImport)
    local profileName = "VXJediUI"

    if forceImport then
        if not WarpDepleteDB then WarpDepleteDB = {} end
        if not WarpDepleteDB["profiles"] then WarpDepleteDB["profiles"] = {} end
        if not WarpDepleteDB["profileKeys"] then WarpDepleteDB["profileKeys"] = {} end

        local is1080 = (resolution == "1080p")

        WarpDepleteDB["profiles"][profileName] = {
            ["showPrideGlow"] = false,
            ["bar1Texture"] = "VXJedi",
            ["bar1TextureColor"] = "ff7d7d7d",
            ["bar1FontSize"] = is1080 and 11 or 14,
            ["bar2Texture"] = "VXJedi",
            ["bar2TextureColor"] = "ff7d7d7d",
            ["bar2FontSize"] = is1080 and 11 or 14,
            ["bar3Texture"] = "VXJedi",
            ["bar3TextureColor"] = "ff7d7d7d",
            ["bar3FontSize"] = is1080 and 11 or 14,
            ["barPadding"] = 1,
            ["barWidth"] = 260,
            ["deathsColor"] = "ffee313f",
            ["deathsFontSize"] = is1080 and 11 or 14,
            ["forcesTexture"] = "VXJedi",
            ["forcesTextureColor"] = "ffA855F7",
            ["forcesFontSize"] = is1080 and 11 or 14,
            ["forcesOverlayTexture"] = "VXJedi",
            ["forcesOverlayTextureColor"] = "ffe7e7e7",
            ["forcesGlowColor"] = "ffe7e7e7",
            ["forcesGlowFrequency"] = 0.1,
            ["forcesGlowLineCount"] = 11,
            ["frameX"] = is1080 and 16.99973297119141 or 16.99977874755859,
            ["frameY"] = is1080 and 155.9998779296875 or 253.9998474121094,
            ["keyColor"] = "ffffffff",
            ["keyFontSize"] = is1080 and 11 or 14,
            ["keyDetailsColor"] = "ffffffff",
            ["keyDetailsFontSize"] = is1080 and 11 or 14,
            ["objectivesFontSize"] = is1080 and 11 or 14,
            ["objectivesOffset"] = 1,
            ["timerFontSize"] = is1080 and 24 or 30,
            ["timerRunningColor"] = "ffffffff",
            ["timerSuccessColor"] = "ff00ff28",
            ["verticalOffset"] = 1,
            ["alignBossClear"] = "end",
        }

        VXJediUIDB.InstalledVersions["WarpDeplete"] = GetAddonInstalledVersion("WarpDeplete")
    end

    if not WarpDepleteDB["profileKeys"] then WarpDepleteDB["profileKeys"] = {} end
    WarpDepleteDB["profileKeys"][UnitName("player") .. " - " .. GetRealmName()] = profileName

    UIErrorsFrame:SetScale(2)
    RefreshImportStatus("WarpDeplete")
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported WarpDeplete", 1.0, 1.0, 1.0)
end
