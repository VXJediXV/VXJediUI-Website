-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- For easy debuging, prints are added for all "failed" attempts, prob unnecessary amount but w/e
-- Module fully documented with annotations for luals checks
-- First iteration and first time i deal with profiles so prob not a perfect module

-- Profile Manager Module
local ProfileManager = {}
AE.ProfileManager = ProfileManager

-- Libraries
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

-- Constants
local EXPORT_PREFIX = "!AE1!"
local DEFAULT_PROFILE = "Default"

-- Localization
local pairs = pairs
local type = type
local time = time
local wipe = wipe
local tostring = tostring
local next = next

--- Get list of all available profiles
---@return table List of profile names
function ProfileManager:GetProfiles()
    local profiles = {}
    if AE.db then AE.db:GetProfiles(profiles) end
    return profiles
end

--- Get the current active profile name
---@return string Current profile name
function ProfileManager:GetCurrentProfile()
    if AE.db then return AE.db:GetCurrentProfile() end
    return DEFAULT_PROFILE
end

--- Switch to a different profile
---@param profileName string The profile name to switch to
---@return boolean success, string|nil error
function ProfileManager:SetProfile(profileName)
    if not profileName or profileName == "" then return false, "Invalid profile name" end
    if not AE.db then return false, "Database not initialized" end

    -- SetProfile handles creation if profile doesn't exist
    AE.db:SetProfile(profileName)
    self:RefreshAllModules()

    -- Refresh GUI content so dropdowns/widgets reflect new profile state
    C_Timer.After(0.1, function()
        if AE.GUIFrame and AE.GUIFrame.mainFrame and AE.GUIFrame.mainFrame:IsShown() then
            AE.GUIFrame:RefreshContent()
        end
    end)

    return true
end

--- Create a new profile with default values
---@param profileName string The name for the new profile
---@return boolean success, string|nil error
function ProfileManager:CreateProfile(profileName)
    if not profileName or profileName == "" then return false, "Profile name cannot be empty" end
    if not AE.db then return false, "Database not initialized" end

    -- Check if profile with the same name already exists
    local profiles = self:GetProfiles()
    for _, name in pairs(profiles) do
        if name == profileName then
            return false, "Profile '" .. profileName .. "' already exists"
        end
    end

    -- Create by setting to it
    local currentProfile = self:GetCurrentProfile()
    AE.db:SetProfile(profileName)

    -- Reset to defaults
    AE.db:ResetProfile()

    -- Switch back to original profile
    AE.db:SetProfile(currentProfile)

    return true
end

--- Copy settings from one profile to another
---@param sourceProfile string Source profile name
---@param targetProfile string|nil Target profile name (current if nil)
---@return boolean success, string|nil error
function ProfileManager:CopyProfile(sourceProfile, targetProfile)
    if not sourceProfile or sourceProfile == "" then return false, "Source profile name cannot be empty" end
    if not AE.db then return false, "Database not initialized" end

    targetProfile = targetProfile or self:GetCurrentProfile()

    -- Check if source profile exists
    local profiles = self:GetProfiles()
    local sourceExists = false
    for _, name in pairs(profiles) do
        if name == sourceProfile then
            sourceExists = true
            break
        end
    end

    if not sourceExists then return false, "Source profile '" .. sourceProfile .. "' does not exist" end

    -- AceDB's CopyProfile copies TO the current profile FROM the source
    local currentProfile = self:GetCurrentProfile()

    -- If target is not current, switch to target first
    if targetProfile ~= currentProfile then AE.db:SetProfile(targetProfile) end

    AE.db:CopyProfile(sourceProfile)

    -- Switch back if needed
    if targetProfile ~= currentProfile then AE.db:SetProfile(currentProfile) end

    self:RefreshAllModules()
    return true
end

--- Delete a profile
---@param profileName string The profile name to delete
---@return boolean success, string|nil error
function ProfileManager:DeleteProfile(profileName)
    if not profileName or profileName == "" then return false, "Profile name cannot be empty" end
    if not AE.db then return false, "Database not initialized" end
    -- Cannot delete active profile
    if profileName == self:GetCurrentProfile() then return false, "Cannot delete the active profile" end

    -- Check if profile exists
    local profiles = self:GetProfiles()
    local exists = false
    for _, name in pairs(profiles) do
        if name == profileName then
            exists = true
            break
        end
    end

    -- Check if profile we wnant to delete even exists
    if not exists then return false, "Profile '" .. profileName .. "' does not exist" end

    -- Check if this is the global profile
    if AE.db.global and AE.db.global.UseGlobalProfile then
        if AE.db.global.GlobalProfile == profileName then
            -- Reset global profile to Default
            AE.db.global.GlobalProfile = DEFAULT_PROFILE
        end
    end

    AE.db:DeleteProfile(profileName)
    return true
end

--- Rename a profile
---@param oldName string Current profile name
---@param newName string New profile name
---@return boolean success, string|nil error
function ProfileManager:RenameProfile(oldName, newName)
    if not oldName or oldName == "" then return false, "Current name cannot be empty" end
    if not newName or newName == "" then return false, "New name cannot be empty" end
    if oldName == newName then return false, "Names are identical" end
    if not AE.db then return false, "Database not initialized" end

    -- Check if old profile exists
    local profiles = self:GetProfiles()
    local oldExists = false
    for _, name in pairs(profiles) do
        if name == oldName then
            oldExists = true
        end
        if name == newName then
            return false, "Profile '" .. newName .. "' already exists"
        end
    end

    if not oldExists then return false, "Profile '" .. oldName .. "' does not exist" end

    local isCurrentProfile = (oldName == self:GetCurrentProfile())
    local isGlobalProfile = AE.db.global and AE.db.global.GlobalProfile == oldName

    -- Create new profile with old profile's data
    AE.db:SetProfile(newName)

    -- Copy from old profile
    AE.db:CopyProfile(oldName)

    -- If old was current, stay on new; otherwise switch back
    if not isCurrentProfile then AE.db:SetProfile(self:GetCurrentProfile()) end

    -- Delete old profile
    AE.db:DeleteProfile(oldName)

    -- Update global profile reference if needed
    if isGlobalProfile then AE.db.global.GlobalProfile = newName end

    self:RefreshAllModules()
    return true
end

--- Enable or disable global profile mode
---@param enabled boolean Whether to use global profile
---@return boolean success
function ProfileManager:SetUseGlobalProfile(enabled)
    if not AE.db or not AE.db.global then return false end
    AE.db.global.UseGlobalProfile = enabled

    -- Switch to global profile
    if enabled then
        local globalProfile = AE.db.global.GlobalProfile or DEFAULT_PROFILE
        AE.db:SetProfile(globalProfile)
    end

    self:RefreshAllModules()
    return true
end

--- Get whether global profile mode is enabled
---@return boolean
function ProfileManager:GetUseGlobalProfile()
    if AE.db and AE.db.global then return AE.db.global.UseGlobalProfile or false end
    return false
end

--- Set which profile to use as global
---@param profileName string The profile name to use globally
---@return boolean success, string|nil error
function ProfileManager:SetGlobalProfile(profileName)
    if not profileName or profileName == "" then return false, "Profile name cannot be empty" end
    if not AE.db or not AE.db.global then return false, "Database not initialized" end

    AE.db.global.GlobalProfile = profileName

    -- If global mode is active, switch to this profile
    if AE.db.global.UseGlobalProfile then
        AE.db:SetProfile(profileName)
        self:RefreshAllModules()
    end

    return true
end

--- Get the name of the global profile
---@return string
function ProfileManager:GetGlobalProfile()
    if AE.db and AE.db.global then return AE.db.global.GlobalProfile or DEFAULT_PROFILE end
    return DEFAULT_PROFILE
end

--- Export a profile to a string
---@param profileName string|nil Profile to export (current if nil)
---@return string|nil exportString, string|nil error
function ProfileManager:ExportProfile(profileName)
    profileName = profileName or self:GetCurrentProfile()

    if not AE.db then return nil, "Database not initialized" end

    local profileData = AE.db.profiles[profileName]
    if not profileData then return nil, "Profile '" .. profileName .. "' not found" end

    -- Create export package with metadata
    local exportData = {
        _v = 1,           -- Version
        _n = profileName, -- Original profile name
        _t = time(),      -- Timestamp
        d = profileData   -- Profile data
    }

    -- Serialize
    local serialized = AceSerializer:Serialize(exportData)
    if not serialized then return nil, "Serialization failed" end

    -- Compress
    local compressed = LibDeflate:CompressDeflate(serialized, { level = 9 })
    if not compressed then return nil, "Compression failed" end

    -- Encode for copy
    local encoded = LibDeflate:EncodeForPrint(compressed)
    if not encoded then return nil, "Encoding failed" end

    return EXPORT_PREFIX .. encoded
end

--- Import a profile from a string
---@param importString string The export string
---@param targetName string|nil Name for the imported profile (uses embedded name if nil)
---@return boolean success, string|nil nameOrError
function ProfileManager:ImportProfile(importString, targetName)
    if not importString or importString == "" then return false, "Import string is empty" end
    -- Validate prefix
    if importString:sub(1, #EXPORT_PREFIX) ~= EXPORT_PREFIX then return false, "Invalid format (missing or wrong prefix)" end
    if not AE.db then return false, "Database not initialized" end

    -- Remove prefix
    local encoded = importString:sub(#EXPORT_PREFIX + 1)

    local profileData, embeddedName

    -- Try internal format first (LibDeflate + AceSerializer)
    local compressed = LibDeflate:DecodeForPrint(encoded)
    if compressed then
        local serialized = LibDeflate:DecompressDeflate(compressed)
        if serialized then
            local success, exportData = AceSerializer:Deserialize(serialized)
            if success and type(exportData) == "table" and exportData.d then
                profileData = exportData.d
                embeddedName = exportData._n
            end
        end
    end

    -- Fallback: try Wago API format (C_EncodingUtil: Base64 + Deflate + CBOR)
    if not profileData and C_EncodingUtil then
        local decoded = C_EncodingUtil.DecodeBase64(encoded)
        if decoded then
            local decompressed = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate)
            if decompressed then
                local data = C_EncodingUtil.DeserializeCBOR(decompressed)
                if data and type(data) == "table" then
                    -- Check if it's an envelope with {d = ..., _n = ...}
                    if data.d and type(data.d) == "table" then
                        profileData = data.d
                        embeddedName = data._n
                    else
                        -- Raw profile data (legacy or third-party export)
                        profileData = data
                    end
                end
            end
        end
    end

    if not profileData then return false, "Decoding failed" end

    -- Determine target profile name
    local finalName = targetName or embeddedName or "Imported"

    -- Check if profile exists and generate unique name if needed
    local profiles = self:GetProfiles()
    local baseName = finalName
    local counter = 1
    local nameExists = true

    while nameExists do
        nameExists = false
        for _, name in pairs(profiles) do
            if name == finalName then
                nameExists = true
                counter = counter + 1
                finalName = baseName .. " (" .. counter .. ")"
                break
            end
        end
    end

    -- Create the profile
    local currentProfile = self:GetCurrentProfile()

    -- Switch to new profile (creates it)
    AE.db:SetProfile(finalName)

    -- Copy imported data to profile
    local profileRef = AE.db.profile
    if profileRef then
        wipe(profileRef)
        for k, v in pairs(profileData) do
            profileRef[k] = v
        end
    end

    -- Switch back to original profile
    AE.db:SetProfile(currentProfile)

    return true, finalName
end

--- Refresh all enabled modules to apply new settings
function ProfileManager:RefreshAllModules()
    local VXJediEssentials = _G.VXJediEssentials
    if not VXJediEssentials then return end

    -- Stop previews before refreshing anything
    if AE.PreviewManager then AE.PreviewManager:StopAllPreviews() end

    -- Refresh module DB's, toggle enable/disable based on new profile, apply settings
    for name, module in VXJediEssentials:IterateModules() do
        if module.UpdateDB then module:UpdateDB() end

        -- Enable or disable modules based on new profile settings
        local shouldBeEnabled = module.db and module.db.Enabled
        local isEnabled = module:IsEnabled()

        if shouldBeEnabled and not isEnabled then
            VXJediEssentials:EnableModule(name)
        elseif not shouldBeEnabled and isEnabled then
            VXJediEssentials:DisableModule(name)
        elseif isEnabled and module.ApplySettings then
            module:ApplySettings()
        end
    end

    -- Refresh theme
    if AE.RefreshTheme then AE:RefreshTheme() end

    -- Refresh GUI frame if open
    if AE.GUIFrame and AE.GUIFrame.ApplyThemeColors then AE.GUIFrame:ApplyThemeColors() end

    -- Start previews again
    if AE.PreviewManager then AE.PreviewManager:StartAllPreviews() end
end

-- WagoUI Integration API --

-- Global API table for WagoUI Packs compatibility
-- Uses C_EncodingUtil as per official Wago implementation guide, if i did somethings wrong, contact me :)
-- https://github.com/methodgg/Wago-Creator-UI/blob/main/WagoUI_Libraries/LibAddonProfiles/ImplementationGuide.lua
VXJediEssentialsAPI = VXJediEssentialsAPI or {}

-- Wago Creator metadata
VXJediEssentialsAPI.slash = "/aes"
VXJediEssentialsAPI.needReloadOnImport = true
VXJediEssentialsAPI.needProfileKey = true

--- Export a profile by key
---@param profileKey string The profile name to export
---@return string The encoded profile string
function VXJediEssentialsAPI:ExportProfile(profileKey)
    if not AE.db then return "" end

    local profileData = AE.db.profiles[profileKey]
    if not profileData then return "" end

    -- Wago expects raw profile data, no envelope wrapper
    local serialized = C_EncodingUtil.SerializeCBOR(profileData)
    local compressed = C_EncodingUtil.CompressString(serialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    local encoded = C_EncodingUtil.EncodeBase64(compressed)
    return encoded and (EXPORT_PREFIX .. encoded) or ""
end

--- Import a profile from string
---@param profileString string The encoded profile string
---@param profileKey string The name for the imported profile
function VXJediEssentialsAPI:ImportProfile(profileString, profileKey)
    if not profileString or profileString == "" then return end
    if not AE.db then return end

    -- Strip prefix if present
    if profileString:sub(1, #EXPORT_PREFIX) == EXPORT_PREFIX then
        profileString = profileString:sub(#EXPORT_PREFIX + 1)
    end

    local decoded = C_EncodingUtil.DecodeBase64(profileString)
    if not decoded then return end

    local decompressed = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate)
    if not decompressed then return end

    local profileData = C_EncodingUtil.DeserializeCBOR(decompressed)
    if not profileData or type(profileData) ~= "table" then return end

    -- Handle envelope format if present (from internal export)
    if profileData.d and type(profileData.d) == "table" then
        profileData = profileData.d
    end

    -- Store profile — Wago handles SetProfile itself, but we do it here
    -- for standalone API usage
    AE.db.profiles[profileKey] = profileData
    AE.db:SetProfile(profileKey)

    -- Refresh without ReloadUI
    ProfileManager:RefreshAllModules()
end

--- Decode a profile string without importing
---@param profileString string The profile string to decode
---@return table The decoded profile data
function VXJediEssentialsAPI:DecodeProfileString(profileString)
    if not profileString or profileString == "" then return {} end

    -- Strip prefix if present
    if profileString:sub(1, #EXPORT_PREFIX) == EXPORT_PREFIX then
        profileString = profileString:sub(#EXPORT_PREFIX + 1)
    end

    local decoded = C_EncodingUtil.DecodeBase64(profileString)
    if not decoded then return {} end

    local decompressed = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate)
    if not decompressed then return {} end

    local profileData = C_EncodingUtil.DeserializeCBOR(decompressed)
    if profileData and type(profileData) == "table" then
        -- Handle envelope format {d = ..., _n = ...}
        if profileData.d and type(profileData.d) == "table" then
            return profileData.d
        end
        return profileData
    end

    return {}
end

--- Set the active profile
---@param profileKey string The profile to activate
function VXJediEssentialsAPI:SetProfile(profileKey)
    if not profileKey or profileKey == "" then return end
    if not AE.db then return end

    AE.db:SetProfile(profileKey)
    ProfileManager:RefreshAllModules()
end

--- Get all profile keys
---@return table<string, boolean> Profile keys in format [key] = true
function VXJediEssentialsAPI:GetProfileKeys()
    local keys = {}
    if AE.db and AE.db.profiles then
        for key in pairs(AE.db.profiles) do
            keys[key] = true
        end
    end
    if not next(keys) then
        keys["Default"] = true
    end
    return keys
end

--- Get current profile key
---@return string The current profile name
function VXJediEssentialsAPI:GetCurrentProfileKey()
    if AE.db then
        return AE.db:GetCurrentProfile() or "Default"
    end
    return "Default"
end

--- Open config panel
function VXJediEssentialsAPI:OpenConfig()
    if AE.GUIFrame and AE.GUIFrame.Show then
        AE.GUIFrame:Show()
    end
end

--- Close config panel
function VXJediEssentialsAPI:CloseConfig()
    if AE.GUIFrame and AE.GUIFrame.Hide then
        AE.GUIFrame:Hide()
    end
end
