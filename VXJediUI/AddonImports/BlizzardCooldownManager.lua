local VXJediUIData = select(2, ...)

local function GetLayoutManager()
  if not CooldownViewerSettings or not CooldownViewerSettings.GetLayoutManager then return nil end
  return CooldownViewerSettings:GetLayoutManager()
end

local function GetDataProvider()
  if not CooldownViewerSettings or not CooldownViewerSettings.GetDataProvider then return nil end
  return CooldownViewerSettings:GetDataProvider()
end

local function GetLayoutIDByName(layoutName)
  local lm = GetLayoutManager()
  if not lm then return nil end
  local _, layouts = lm:EnumerateLayouts()
  for layoutID, layout in pairs(layouts) do
    if layout and layout.layoutName == layoutName then
      return layoutID
    end
  end
end

local function RemoveLayoutByName(layoutName)
  local lm = GetLayoutManager()
  if not lm then return end
  local id = GetLayoutIDByName(layoutName)
  if id then
    lm:RemoveLayout(id)
  end
end

local function ImportLayoutString(profileString, profileKeyToReplace)
  if not profileString or profileString == "" then return nil end

  local lm = GetLayoutManager()
  if not lm then return nil end

  if profileKeyToReplace then
    RemoveLayoutByName(profileKeyToReplace)
  end

  if lm.AreLayoutsFullyMaxed and lm:AreLayoutsFullyMaxed() then
    local activeID = lm:GetActiveLayoutID()
    if activeID then lm:RemoveLayout(activeID) end
  end

  local layoutIDs = lm:CreateLayoutsFromSerializedData(profileString)
  if layoutIDs and layoutIDs[1] then
    local importedLayoutID = layoutIDs[1]
    lm:SaveLayouts()
    return importedLayoutID
  end
end

local function GetCurrentSpecTag()
  if not CooldownViewerUtil or not CooldownViewerUtil.GetCurrentClassAndSpecTag then return nil end
  return tonumber(CooldownViewerUtil.GetCurrentClassAndSpecTag())
end

local function ActivateLayout(layoutID)
  local lm = GetLayoutManager()
  if not lm or not layoutID then return false end

  local dataProvider = GetDataProvider()
  if dataProvider and dataProvider.CheckBuildDisplayData then
    pcall(function() dataProvider:CheckBuildDisplayData() end)
  end

  if dataProvider and dataProvider.MarkDirty then
    dataProvider:MarkDirty()
  end

  local didActivate = false
  if dataProvider and dataProvider.SetActiveLayoutByID and dataProvider.GetDisplayData and dataProvider:GetDisplayData() then
    dataProvider:SetActiveLayoutByID(layoutID)
    didActivate = true
  else
    didActivate = lm:SetActiveLayoutByID(layoutID)
  end

  if CooldownViewerSettings and CooldownViewerSettings.RefreshLayout then
    pcall(function() CooldownViewerSettings:RefreshLayout() end)
  end

  if lm.NotifyListeners then
    lm:NotifyListeners()
  end

  if CooldownViewerSettings and CooldownViewerSettings.SaveCurrentLayout then
    pcall(function() CooldownViewerSettings:SaveCurrentLayout() end)
  else
    lm:SaveLayouts()
  end

  return didActivate
end

local function GetClassTagsForPlayer(dataForRes)
  if not CooldownViewerUtil or not CooldownViewerUtil.GetCurrentClassAndSpecTag then return {} end
  local currentTag = tonumber(CooldownViewerUtil.GetCurrentClassAndSpecTag())
  if not currentTag then return {} end

  local tags = {}
  local profileKeys = dataForRes.cdmData and dataForRes.cdmData.profileKeys
  if not profileKeys then return {} end

  for tag, _ in pairs(profileKeys) do
    tag = tonumber(tag)
    if tag and math.abs(tag - currentTag) <= 5 then
      table.insert(tags, tag)
    end
  end

  table.sort(tags)
  return tags
end

local function EnsureCDMImportState()
  if not VXJediUIDB then return nil end
  VXJediUIDB.CDMImportedTags = VXJediUIDB.CDMImportedTags or {}
  return VXJediUIDB.CDMImportedTags
end

function VXJediUIData:SetBlizzardCooldownManager(resolution, tag, silent)
  local resData = self.BlizzardCooldownManager
  if not resData or not resData.cdmData then return end

  local tagProfiles = resData.cdmData.profiles and resData.cdmData.profiles[tag]
  if not tagProfiles then
    UIErrorsFrame:AddMessage("No exported CDM layout for this spec.", 1.0, 0.2, 0.2)
    return
  end

  local profileKey, profileString
  for k, v in pairs(tagProfiles) do
    profileKey, profileString = k, v
    break
  end
  if not profileKey or not profileString then return end

  local layoutID = ImportLayoutString(profileString, profileKey)
  if not layoutID then
    UIErrorsFrame:AddMessage("Failed to import CDM layout.", 1.0, 0.2, 0.2)
    return
  end

  local importTag = tonumber(tag)
  local currentTag = GetCurrentSpecTag()

  if importTag and currentTag and importTag == currentTag then
    ActivateLayout(layoutID)
    if C_Timer and C_Timer.After then
      C_Timer.After(0, function()
        if not (InCombatLockdown and InCombatLockdown()) then
          ActivateLayout(layoutID)
        end
      end)
    end
  end

  local importedTags = EnsureCDMImportState()
  if importedTags then
    importedTags[tag] = true
  end

  if VXJediUIDB then
    VXJediUIDB.InstalledVersions = VXJediUIDB.InstalledVersions or {}
    VXJediUIDB.InstalledVersions["BlizzardCooldownManager"] = GetAddonInstalledVersion("BlizzardCooldownManager")
    VXJediUIDB.CDMImportedVersion = GetAddonInstalledVersion("BlizzardCooldownManager")
  end

  RefreshImportStatus("BlizzardCooldownManager")
  if not silent then
    PlaySoundFile(InstallationSoundFile)
    if importTag and currentTag and importTag == currentTag then
      UIErrorsFrame:AddMessage("Imported and applied Cooldown Manager layout: " .. profileKey, 1.0, 1.0, 1.0)
    else
      UIErrorsFrame:AddMessage("Imported Cooldown Manager layout: " .. profileKey .. " (applies when you switch to that spec)", 1.0,
        1.0, 1.0)
    end
  end
end

function VXJediUIData:GetBlizzardCooldownManagerTagsForPlayer(resolution)
  local resData = self.BlizzardCooldownManager
  if not resData then return {} end

  local tags = GetClassTagsForPlayer(resData)
  local result = {}

  local profileKeys = resData.cdmData and resData.cdmData.profileKeys
  if not profileKeys then return {} end

  for _, tag in ipairs(tags) do
    local tagData = profileKeys[tag]
    if tagData then
      for profileKey, data in pairs(tagData) do
        table.insert(result, {
          tag = tag,
          name = data.profileKey or profileKey,
          coloredName = data.coloredName or profileKey,
          icon = data.icon,
        })
        break
      end
    end
  end

  table.sort(result, function(a, b)
    return a.tag < b.tag
  end)

  return result
end

function VXJediUIData:GetMissingBlizzardCooldownManagerTagsForPlayer(resolution)
  local tags = self:GetBlizzardCooldownManagerTagsForPlayer(resolution)
  if not tags or #tags == 0 then return {} end

  local importedTags = (VXJediUIDB and VXJediUIDB.CDMImportedTags) or {}
  local missing = {}

  for _, tagInfo in ipairs(tags) do
    if not importedTags[tagInfo.tag] then
      table.insert(missing, tagInfo)
    end
  end

  return missing
end
