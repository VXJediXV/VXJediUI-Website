local VXJediUI = select(2, ...)

local AE_EXPORT_PREFIX = "!AE1!"

function VXJediUI:SetVXJediEssentials(resolution, forceImport)
    if not VXJediEssentialsDB then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("VXJediEssentials is not loaded", 1.0, 0.0, 0.0)
        return
    end

    local profileString = VXJediUI.VXJediEssentialsProfileString[resolution]

    if not profileString or profileString == "" or profileString == "ENTERSTRINGHERE" then
        UIErrorsFrame:SetScale(2)
        UIErrorsFrame:AddMessage("VXJediEssentials profile string not found for " .. resolution, 1.0, 0.0, 0.0)
        return
    end

    if forceImport then
        -- Strip prefix
        local encoded = profileString
        if encoded:sub(1, #AE_EXPORT_PREFIX) == AE_EXPORT_PREFIX then
            encoded = encoded:sub(#AE_EXPORT_PREFIX + 1)
        end

        -- Decode using LibDeflate + AceSerializer
        local LibDeflate = LibStub("LibDeflate")
        local AceSerializer = LibStub("AceSerializer-3.0")

        local profileData
        local compressed = LibDeflate:DecodeForPrint(encoded)
        if compressed then
            local serialized = LibDeflate:DecompressDeflate(compressed)
            if serialized then
                local success, exportData = AceSerializer:Deserialize(serialized)
                if success and type(exportData) == "table" and exportData.d then
                    profileData = exportData.d
                end
            end
        end

        if not profileData then
            UIErrorsFrame:SetScale(2)
            UIErrorsFrame:AddMessage("Failed to decode VXJediEssentials profile", 1.0, 0.0, 0.0)
            return
        end

        -- Write directly to the SavedVariable
        local profileKey = "VXJediUI"
        VXJediEssentialsDB.profiles = VXJediEssentialsDB.profiles or {}
        VXJediEssentialsDB.profiles[profileKey] = profileData

        VXJediUIDB.InstalledVersions["VXJediEssentials"] = GetAddonInstalledVersion("VXJediEssentials")
    end

    -- Set profile key for this character
    local charKey = UnitName("player") .. " - " .. GetRealmName()
    VXJediEssentialsDB.profileKeys = VXJediEssentialsDB.profileKeys or {}
    VXJediEssentialsDB.profileKeys[charKey] = "VXJediUI"

    -- If the AceDB object exists, switch profile live
    if _G.VXJediEssentials and _G.VXJediEssentials.db then
        _G.VXJediEssentials.db:SetProfile("VXJediUI")
    end

    UIErrorsFrame:SetScale(2)
    RefreshImportStatus("VXJediEssentials")
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported VXJediEssentials", 1.0, 1.0, 1.0)
end
