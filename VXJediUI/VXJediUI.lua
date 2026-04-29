local GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
local E = unpack(ElvUI); --Import: Engine
local VXJediUI = E:NewModule('VXJediUI', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local addonName, VXJediUIData = ...

local EP = LibStub("LibElvUIPlugin-1.0")

local expresswayFontLocation = "Interface\\Addons\\VXJediMedia\\Fonts\\Expressway.TTF"

InstallationSoundFile = "Interface\\AddOns\\VXJediMedia\\Sounds\\Info.ogg"

-- Stores BigWigs profile export strings for 1080p/1440p settings
-- These are the same strings you get from BigWigs > Profiles > Export
VXJediUIData.BigWigsProfileString = {}

-- Stores exported details profile string for 1080p/1440p settings
VXJediUIData.DetailsProfileString = {}

-- Stores ElvUI profile import strings for 1080/1440p
VXJediUIData.ElvUIStrings = {}

-- Stores Plater profile import strings for 1080/1440p
VXJediUIData.PlaterProfileString = {}

-- WarpDeplete uses targeted profile writes (no data file needed)

-- Stores exported data for EditMode 1080/1440p settings
VXJediUIData.EditModeString = {}

-- Stores exported data for Blizzard Cooldown Manager 1080/1440p settings
VXJediUIData.BlizzardCooldownManager = {}

-- Stores VXJediEssentials profile import strings for 1080/1440p
VXJediUIData.VXJediEssentialsProfileString = {}

-- Stores Ayije CDM profile import strings for 1080/1440p
VXJediUIData.AyijeCDMProfileString = {}

-- Stores BuffReminders profile import strings for 1080/1440p
VXJediUIData.BuffRemindersProfileString = {}

-- Returns the index into the configuration data array
-- based on the user's resolution.
function GetResolution()
  horizontal, vertical = GetPhysicalScreenSize()
  if vertical <= 1200 then
    return "1080p"
  else
    return "1440p"
  end
end

function GetNiceVersionNumber(versionNumber)
  local major, minor = string.match(tostring(versionNumber), "^(%d+)%.(%d+)$")
  if not major then return 0 end
  return tonumber(major) * 1000 + tonumber(minor)
end

-- Returns the current version of the addon
function GetAddonVersion()
  return GetAddOnMetadata("VXJediUI", "Version")
end

-- Returns the current version of the dependency addon
function GetAddonInstalledVersion(addonName)
  return GetAddOnMetadata("VXJediUI", "X-" .. addonName)
end

function GetAddonSavedVersion(addonName)
  if VXJediUIDB.InstalledVersions[addonName] == nil then
    return "not Imported"
  else
    return VXJediUIDB.InstalledVersions[addonName]
  end
end

-- Returns true if the module is installed
function IsModuleInstalled(addonName)
  -- "Extras" is a virtual page, always show it
  if addonName == "Extras" then return true end
  return VXJediUIDB.InstalledVersions[addonName] ~= nil
end

-- Returns true if the module is loaded and out of date
-- else False
function IsModuleOutOfDate(addonName)
  local addonFileName = addonName

  if addonName == "EditMode" then
    addonFileName = "Blizzard_EditMode"
  elseif addonName == "AyijeCDM" then
    addonFileName = "Ayije_CDM"
  end

  return (VXJediUIDB.InstalledVersions[addonName] == nil
        or GetNiceVersionNumber(VXJediUIDB.InstalledVersions[addonName]) < GetNiceVersionNumber(GetAddonInstalledVersion(addonName)))
      and IsAddOnLoaded(addonFileName)
end

-- Returns true if the addon version is larger than the
-- latest installed version.
function IsAddonOutOfDate(installedVersion)
  if installedVersion == nil then
    return true
  end
  return GetNiceVersionNumber(GetAddonVersion()) > GetNiceVersionNumber(installedVersion)
end

-- Function that pops up a confirmation box
local function ConfirmInstallation(text, fn, cancelFn)
  StaticPopupDialogs["ProfileOverrideConfirm"] = {
    button1 = "Apply",
    button2 = "No",
    OnAccept = fn,
    OnCancel = cancelFn,
    text = text,
    whileDead = true,
  }

  StaticPopup_Show("ProfileOverrideConfirm")
end

-- Function that pops up a confirmation box
local function ConfirmOverwriteInstall(text, fn, cancelFn)
  -- If installed, pop up a dialogue box
  if VXJediUIDB ~= nil and VXJediUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] ~= nil then
    if not _G["VXJediUIPopupFont"] then
      local f = CreateFont("VXJediUIPopupFont")
      local base = GameFontHighlight:GetFont()
      f:SetFont(base, 16, "")
    end

    StaticPopupDialogs["ProfileOverrideConfirm"] = {
      button1 = "Yes",
      button2 = "No",
      OnAccept = fn,
      OnCancel = cancelFn,
      text = text,
      whileDead = true,
      wide = true,
    }

    local dialog = StaticPopup_Show("ProfileOverrideConfirm")
    if dialog and dialog.text then
      dialog.text:SetFontObject(_G["VXJediUIPopupFont"])
    end
  else
    fn()
  end
end

-- Function that gets the class color of the current logged in user
function ClassColor(text)
  local _, englishClass, _ = UnitClass("player")
  local _, _, _, hex = GetClassColor(englishClass)
  return string.format("|cff%s%s|r", string.sub(hex, 3), text)
end

-- Change the default color of the UI elements (deep blue/purple)
function Color(text)
  return string.format("|cffA855F7%s|r", text)
end

function SetImportStatusText(addonKey)
  if not PluginInstallFrame or not PluginInstallFrame.Desc2 then return end
  local saved = VXJediUIDB.InstalledVersions[addonKey]
  local latest = GetAddonInstalledVersion(addonKey)
  if saved == nil then
    PluginInstallFrame.Desc2:SetText(Red(string.format(
      "This profile has not been imported yet. The below button will import version %s.",
      latest)))
  elseif GetNiceVersionNumber(saved) < GetNiceVersionNumber(latest) then
    PluginInstallFrame.Desc2:SetText(Red(string.format(
      "Your version is %s but the latest is %s. The below button will update and load it.\nNote: importing will overwrite your existing VXJediUI profile.",
      saved, latest)))
  else
    PluginInstallFrame.Desc2:SetText(string.format(
      "Your version is %s, which is up to date.",
      Green(saved)))
  end
end

function RefreshImportStatus(addonKey)
  SetImportStatusText(addonKey)
end

function Grey(text)
  return string.format("|cff999999%s|r", text)
end

function Green(text)
  return string.format("|cff00ff00%s|r", text)
end

-- Default RED (warning/error) color
function Red(text)
  return string.format("|cffff0000%s|r", text)
end

function VXJediUI:FinishInstallation()
  if VXJediUIData.PlaterEnabled then
    Plater.db:SetProfile("VXJediUI")
  end
  VXJediUIDB.InstalledVersion = GetAddonVersion()
  VXJediUIDB.InstalledResolution = GetResolution()
  E.global.ignoreIncompatible = false
  E.private["nameplates"]["enable"] = false
  VXJediUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] = GetAddonVersion()
  DEFAULT_CHAT_FRAME.editBox:SetText("/details show")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  DEFAULT_CHAT_FRAME.editBox:SetText("/simc minimap")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  DEFAULT_CHAT_FRAME.editBox:SetText("/plater minimap")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  DEFAULT_CHAT_FRAME.editBox:SetText("/mdt minimap")
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  ReloadUI()
end

function TextSetOrInstall(isInstall, text)
  if (isInstall) then
    return string.format("Import %s", text)
  else
    return string.format("Load %s", text)
  end
end

local function GetCDMEntriesForPlayer(resolution)
  if not VXJediUIData.GetBlizzardCooldownManagerTagsForPlayer then return {} end
  return VXJediUIData:GetBlizzardCooldownManagerTagsForPlayer(resolution) or {}
end

local function GetMissingCDMEntriesForPlayer(resolution)
  if not VXJediUIData.GetMissingBlizzardCooldownManagerTagsForPlayer then return {} end
  return VXJediUIData:GetMissingBlizzardCooldownManagerTagsForPlayer(resolution) or {}
end

local function HasMissingCDMImports(resolution)
  return #GetMissingCDMEntriesForPlayer(resolution) > 0
end

local function ShouldShowCDMPage(resolution, onlyWhenMissing)
  if #GetCDMEntriesForPlayer(resolution) == 0 then return false end
  if onlyWhenMissing then
    return HasMissingCDMImports(resolution)
  end
  return true
end

local function GetCDMButtonLabel(specInfo)
  local label = specInfo and (specInfo.name or specInfo.coloredName) or ""
  if label == "" then
    return tostring(specInfo and specInfo.tag or "Spec")
  end

  label = label:gsub("|c%x%x%x%x%x%x%x%x", "")
  label = label:gsub("|r", "")
  label = label:gsub("^VXJediUI%s*%-%s*", "")

  return label
end

local function CloseInstallerFrame()
  if PluginInstallFrame and PluginInstallFrame.Close and PluginInstallFrame.Close.Click then
    PluginInstallFrame.Close:Click()
  elseif PluginInstallFrame then
    PluginInstallFrame:Hide()
  end
end

local addOns = {
  [1] = "ElvUI",
  [2] = "Plater",
  [3] = "Details",
  [4] = "WarpDeplete",
  [5] = "EditMode",
  [6] = "Extras",
}

local updatePage = function()
  PluginInstallFrame.SubTitle:SetFormattedText(Color("Update Addons"))
  PluginInstallFrame.Desc1:SetText(
    "It looks like you have a new version of VXJediUI. This installer will update your addons which are out of date. If you do not wish to update, you can skip this.")
  PluginInstallFrame.Option1:Show()
  PluginInstallFrame.Option1:SetScript("OnClick", VXJediUI.FinishInstallation)
  PluginInstallFrame.Option1:SetText("Skip")
end

local pages = {
  ["Intro"] = function(profileLoad, resolution)
    if (profileLoad) then
      PluginInstallFrame.SubTitle:SetFormattedText(string.format("%s Profile Loader", Color(addonName)))
      PluginInstallFrame.Desc1:SetText(
        "This process will load the VXJediUI profiles you have already installed for your new character -- it will not re-install or overwrite anything.\nPlease be sure to hit Finish at the end to properly load everything.")
      PluginInstallFrame.Desc2:SetText(string.format(
        "Type %s in chat for a full list of commands.", Color("/vxjediui")))
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick", VXJediUI.FinishInstallation)
      PluginInstallFrame.Option1:SetText("Skip")
    else
      PluginInstallFrame.SubTitle:SetFormattedText(string.format("Welcome to the %s %s Installation!", Color(addonName),
        Color(resolution)))
      PluginInstallFrame.Desc1:SetText(string.format(
        "This process will import profiles for all the addons that you choose in the following steps.\nSettings will only be changed for addons you choose to import."))
      PluginInstallFrame.Desc2:SetText(string.format(
        "If you'd like to reinstall the UI at any point, please run %s\n\n%s\n\nType %s in chat for a full list of commands.",
        Color("/vxjediui install"),
        Color("Some changes may not be applied until you finish the installation process."),
        Color("/vxjediui")))
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick", VXJediUI.FinishInstallation)
      PluginInstallFrame.Option1:SetText("Skip")
    end
  end,
  ["CDMIntro"] = function(resolution)
    PluginInstallFrame.SubTitle:SetFormattedText(Color("Cooldown Manager") .. " " .. Grey("v" .. GetAddonInstalledVersion("BlizzardCooldownManager")))
    PluginInstallFrame.Desc1:SetText(
      "Use this step to import Blizzard Cooldown Manager layouts for your current class.")
    PluginInstallFrame.Desc2:SetText(
      "Blizzard only allows importing layouts for the class you are currently logged into.")
    PluginInstallFrame.Desc3:SetText(string.format(
      "If you need to import another class later, run %s on that character.", Color("/vxjediui cdm")))
  end,
  ["ElvUI"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("ElvUI Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("ElvUI")))
      PluginInstallFrame.Desc1:SetText("Select the ElvUI Class profile you'd like to use.")
      SetImportStatusText("ElvUI")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick",
        function() VXJediUIData:SetElvUI(false, resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText("Dark Theme")
      PluginInstallFrame.Option2:Show()
      PluginInstallFrame.Option2:SetScript("OnClick",
        function() VXJediUIData:SetElvUI(true, resolution, shouldImport) end)
      PluginInstallFrame.Option2:SetText("Class Color")
    end
  end,
  ["BigWigs"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("BigWigs Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("BigWigs")))
      PluginInstallFrame.Desc1:SetText("Click below to import the BigWigs profile.")
      SetImportStatusText("BigWigs")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick", function() VXJediUIData:SetBigWigs(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "BigWigs"))
    end
  end,
  ["Details"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("Details Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("Details")))
      PluginInstallFrame.Desc1:SetText("Click below to import the Details profile.")
      SetImportStatusText("Details")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick", function() VXJediUIData:SetDetails(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "Details"))
    end
  end,
  ["Plater"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("Plater Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("Plater")))
      PluginInstallFrame.Desc1:SetText("Click below to import the Plater profile.")
      SetImportStatusText("Plater")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick", function() VXJediUIData:SetPlater(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "Plater"))
    end
  end,
  ["WarpDeplete"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("WarpDeplete Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("WarpDeplete")))
      PluginInstallFrame.Desc1:SetText("Click below to import the WarpDeplete profile.")
      SetImportStatusText("WarpDeplete")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick",
        function() VXJediUIData:SetWarpDeplete(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "WarpDeplete"))
    end
  end,
  ["AyijeCDM"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("AyijeCDM Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("AyijeCDM")))
      PluginInstallFrame.Desc1:SetText("Click below to import the AyijeCDM profile.")
      SetImportStatusText("AyijeCDM")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick",
        function() VXJediUIData:SetAyijeCDM(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "AyijeCDM"))
    end
  end,
  ["BuffReminders"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("BuffReminders Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("BuffReminders")))
      PluginInstallFrame.Desc1:SetText("Click below to import the BuffReminders profile.")
      SetImportStatusText("BuffReminders")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick",
        function() VXJediUIData:SetBuffReminders(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "BuffReminders"))
    end
  end,
  ["BlizzardCooldownManager"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("Cooldown Manager") .. " " .. Grey("v" .. GetAddonInstalledVersion("BlizzardCooldownManager")))
      PluginInstallFrame.Desc1:SetText(
        "Blizzard Cooldown Manager layouts are class-specific. Import each spec for this class one at a time.")

      local tagInfo = GetCDMEntriesForPlayer(resolution)
      local optionButtons = {
        PluginInstallFrame.Option1,
        PluginInstallFrame.Option2,
        PluginInstallFrame.Option3,
        PluginInstallFrame.Option4,
      }

      local function HideAllOptions()
        for _, button in ipairs(optionButtons) do
          if button then
            button:Hide()
          end
        end
      end

      if not tagInfo or #tagInfo == 0 then
        PluginInstallFrame.Desc2:SetText(Red("No Blizzard Cooldown Manager exports were found for your current class."))
        PluginInstallFrame.Desc3:SetText("")
        HideAllOptions()
        return
      end

      SetImportStatusText("BlizzardCooldownManager")

      PluginInstallFrame.Desc3:SetText(
        "Tip: if you log onto another class later, run /vxjediui cdm to import that class' specs.")

      HideAllOptions()

      -- Create "Import All Specs" button above the spec row (once)
      if not PluginInstallFrame._auiCDMAllButton then
        local S = E:GetModule("Skins")
        local btn = CreateFrame("Button", nil, PluginInstallFrame, "UIPanelButtonTemplate")
        btn:SetSize(160, 30)
        btn:SetPoint("BOTTOM", PluginInstallFrame, "BOTTOM", 0, 80)
        S:HandleButton(btn)
        PluginInstallFrame._auiCDMAllButton = btn
      end

      local allBtn = PluginInstallFrame._auiCDMAllButton
      allBtn:SetText("Import All Specs")
      allBtn:SetScript("OnClick", function()
        for _, specInfo in ipairs(tagInfo) do
          VXJediUIData:SetBlizzardCooldownManager(resolution, specInfo.tag, true)
        end
        PlaySoundFile(InstallationSoundFile)
        UIErrorsFrame:AddMessage("Imported all Cooldown Manager layouts", 1.0, 1.0, 1.0)
      end)
      allBtn:Show()

      -- Show individual spec buttons in the normal row
      for i, specInfo in ipairs(tagInfo) do
        local button = optionButtons[i]
        if not button then break end
        local currentTag = specInfo.tag
        button:SetEnabled(true)
        button:SetText(GetCDMButtonLabel(specInfo))
        button:SetScript("OnClick", function()
          VXJediUIData:SetBlizzardCooldownManager(resolution, currentTag)
        end)
        button:Show()
      end
    end
  end,
  ["VXJediEssentials"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("VXJediEssentials Profile") .. " " .. Grey("v" .. GetAddonInstalledVersion("VXJediEssentials")))
      PluginInstallFrame.Desc1:SetText("Click below to import the VXJediEssentials profile.")
      SetImportStatusText("VXJediEssentials")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick",
        function() VXJediUIData:SetVXJediEssentials(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "Essentials"))
    end
  end,
  ["EditMode"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("Edit Mode Layout") .. " " .. Grey("v" .. GetAddonInstalledVersion("EditMode")))
      PluginInstallFrame.Desc1:SetText("Click below to import the Blizzard Edit Mode layout.")
      SetImportStatusText("EditMode")
      PluginInstallFrame.Desc3:SetText(Red(
        "After importing, you will need to set the Edit Mode profile once on your other specializations."))
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick",
        function() VXJediUIData:SetEditMode(resolution, shouldImport) end)
      PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "Edit Mode"))
    end
  end,
  ["Extras"] = function(shouldImport, forceReImport, resolution)
    return function()
      PluginInstallFrame.SubTitle:SetFormattedText(Color("Extras"))
      PluginInstallFrame.Desc1:SetText(
        "Optional cleanup and quality-of-life adjustments. None of these are required, but they help complete the look and feel of VXJediUI.")
      PluginInstallFrame.Desc2:SetText(
        "Click any button below to apply that change. You can run these as many times as you'd like.")
      PluginInstallFrame.Option1:Show()
      PluginInstallFrame.Option1:SetScript("OnClick", function()
        if VXJediUI.HideMinimapIcons then
          VXJediUI.HideMinimapIcons()
          UIErrorsFrame:SetScale(2)
          PlaySoundFile(InstallationSoundFile)
          UIErrorsFrame:AddMessage("Minimap icons hidden", 1.0, 1.0, 1.0)
        end
      end)
      PluginInstallFrame.Option1:SetText("Hide Minimap Icons")
    end
  end,
  ["Finish"] = function()
    PluginInstallFrame.SubTitle:SetFormattedText(Color("Finish"))
    PluginInstallFrame.Desc1:SetText("All done! Press Finish below to reload your UI and complete the installation.")
    PluginInstallFrame.Option1:SetScript("OnClick", VXJediUI.FinishInstallation)
    PluginInstallFrame.Option1:SetText("Finish")
    PluginInstallFrame.Option1:Show()
  end,
  ["CDMFinish"] = function()
    PluginInstallFrame.SubTitle:SetFormattedText(Color("Finish"))
    PluginInstallFrame.Desc1:SetText("CDM import step complete. You can close this installer now.")
    PluginInstallFrame.Desc2:SetText("")
    PluginInstallFrame.Desc3:SetText("")
    PluginInstallFrame.Option1:SetScript("OnClick", CloseInstallerFrame)
    PluginInstallFrame.Option1:SetText("Close")
    PluginInstallFrame.Option1:Show()
    PluginInstallFrame.Option2:Hide()
    if PluginInstallFrame.Option3 then PluginInstallFrame.Option3:Hide() end
    if PluginInstallFrame.Option4 then PluginInstallFrame.Option4:Hide() end
  end,
}

local stepTitles = {
  ["Intro"] = "Introduction",
  ["CDMIntro"] = "Introduction",
  ["ElvUI"] = "ElvUI",
  ["BigWigs"] = "BigWigs",
  ["Details"] = "Details",
  ["Plater"] = "Plater",
  ["WarpDeplete"] = "WarpDeplete",
  ["AyijeCDM"] = "AyijeCDM",
  ["BuffReminders"] = "BuffReminders",
  ["BlizzardCooldownManager"] = "Cooldown Manager",
  ["VXJediEssentials"] = "VXJediEssentials",
  ["EditMode"] = "EditMode",
  ["Extras"] = "Extras",
  ["Finish"] = "Finish",
  ["CDMFinish"] = "Finish",
}

local function SetFont()
  local libSharedMedia = LibStub("LibSharedMedia-3.0")
  libSharedMedia:Register("font", "VXJediUI Expressway", expresswayFontLocation)
  E.db["general"]["font"] = "VXJediUI Expressway"
  E:UpdateMedia()
  E:UpdateFontTemplates()
end

local function AppendBlizzardCooldownManagerPage(newPages, newStepTitles, shouldImport, forceReImport, resolution)
  if not ShouldShowCDMPage(resolution, false) then return end

  table.insert(newPages, pages["BlizzardCooldownManager"](shouldImport, forceReImport, resolution))
  table.insert(newStepTitles, stepTitles["BlizzardCooldownManager"])
end

function VXJediUI:BlizzardCooldownManagerOnly(resolution)
  local newPages = {}
  local newStepTitles = {}

  table.insert(newPages, function() pages["CDMIntro"](resolution) end)
  table.insert(newStepTitles, stepTitles["CDMIntro"])

  if ShouldShowCDMPage(resolution, false) then
    table.insert(newPages, pages["BlizzardCooldownManager"](true, false, resolution))
    table.insert(newStepTitles, stepTitles["BlizzardCooldownManager"])
  end

  table.insert(newPages, pages["CDMFinish"])
  table.insert(newStepTitles, stepTitles["CDMFinish"])

  return {
    Title = "|TInterface\\AddOns\\VXJediMedia\\StatusBars\\VXJedi.tga:16:16|t " .. Color(addonName) .. " " .. Grey("v" .. GetAddonVersion()),
    Name = string.format("%s Blizzard CDM Import", Color(addonName)),
    tutorialImage = "Interface\\AddOns\\VXJediMedia\\Media\\logo.tga",
    Pages = newPages,
    StepTitles = newStepTitles,
    StepTitlesColor = { 1, 1, 1 },
    StepTitlesColorSelected = { 168 / 255, 85 / 255, 247 / 255 },
    StepTitleWidth = 200,
    StepTitleButtonWidth = 200,
    StepTitleTextJustification = "CENTER",
  }
end

-- ForceReinstall is run when they're reimport via /vxjediui install
function VXJediUI:ForceReinstall(resolution)
  local newPages = {}
  local newStepTitles = {}

  table.insert(newPages, function() pages["Intro"](false, resolution) end)
  table.insert(newStepTitles, stepTitles["Intro"])

  for _, addonName in ipairs(addOns) do
    table.insert(newPages, pages[addonName](true, true, resolution))
    table.insert(newStepTitles, stepTitles[addonName])
    if addonName == "ElvUI" then
      AppendBlizzardCooldownManagerPage(newPages, newStepTitles, true, true, resolution)
    end
  end

  table.insert(newPages, pages["Finish"])
  table.insert(newStepTitles, stepTitles["Finish"])

  return {
    Title = "|TInterface\\AddOns\\VXJediMedia\\StatusBars\\VXJedi.tga:16:16|t " .. Color(addonName) .. " " .. Grey("v" .. GetAddonVersion()),
    Name = string.format("%s Installation", Color(addonName)),
    tutorialImage = "Interface\\AddOns\\VXJediMedia\\Media\\logo.tga",
    Pages = newPages,
    StepTitles = newStepTitles,
    StepTitlesColor = { 1, 1, 1 },
    StepTitlesColorSelected = { 168 / 255, 85 / 255, 247 / 255 },
    StepTitleWidth = 200,
    StepTitleButtonWidth = 200,
    StepTitleTextJustification = "CENTER",
  }
end

-- Sets profiles for addons they've already installed
function VXJediUI:SetProfiles()
  local newPages = {}
  local newStepTitles = {}
  local resolution = GetResolution()

  table.insert(newPages, function() pages["Intro"](true, nil) end)
  table.insert(newStepTitles, stepTitles["Intro"])

  for _, addonName in ipairs(addOns) do
    if IsModuleInstalled(addonName) then
      table.insert(newPages, pages[addonName](false, false, resolution))
      table.insert(newStepTitles, stepTitles[addonName])
    end
    if addonName == "ElvUI" then
      AppendBlizzardCooldownManagerPage(newPages, newStepTitles, HasMissingCDMImports(resolution), false, resolution)
    end
  end

  table.insert(newPages, pages["Finish"])
  table.insert(newStepTitles, stepTitles["Finish"])

  return {
    Title = "|TInterface\\AddOns\\VXJediMedia\\StatusBars\\VXJedi.tga:16:16|t " .. Color(addonName) .. " " .. Grey("v" .. GetAddonVersion()),
    Name = string.format("%s Installation", Color(addonName)),
    tutorialImage = "Interface\\AddOns\\VXJediMedia\\Media\\logo.tga",
    Pages = newPages,
    StepTitles = newStepTitles,
    StepTitlesColor = { 1, 1, 1 },
    StepTitlesColorSelected = { 168 / 255, 85 / 255, 247 / 255 },
    StepTitleWidth = 200,
    StepTitleButtonWidth = 200,
    StepTitleTextJustification = "CENTER",
  }
end

-- Install sets profiles if they're already installed, importing if they're not installed or out of date
function VXJediUI:Install(resolution)
  local newPages = {}
  local newStepTitles = {}

  table.insert(newPages, function() pages["Intro"](false, resolution) end)
  table.insert(newStepTitles, stepTitles["Intro"])

  for _, addonName in ipairs(addOns) do
    if IsModuleOutOfDate(addonName) then
      -- Force re-import if they're not installed, or out of date
      table.insert(newPages, pages[addonName](true, false, resolution))
      table.insert(newStepTitles, stepTitles[addonName])
    else
      -- Set profile if they're up to date
      table.insert(newPages, pages[addonName](false, false, resolution))
      table.insert(newStepTitles, stepTitles[addonName])
    end
    if addonName == "ElvUI" then
      AppendBlizzardCooldownManagerPage(newPages, newStepTitles,
        IsModuleOutOfDate("BlizzardCooldownManager") or HasMissingCDMImports(resolution), false, resolution)
    end
  end

  table.insert(newPages, pages["Finish"])
  table.insert(newStepTitles, stepTitles["Finish"])

  return {
    Title = "|TInterface\\AddOns\\VXJediMedia\\StatusBars\\VXJedi.tga:16:16|t " .. Color(addonName) .. " " .. Grey("v" .. GetAddonVersion()),
    Name = string.format("%s Installation", Color(addonName)),
    tutorialImage = "Interface\\AddOns\\VXJediMedia\\Media\\logo.tga",
    Pages = newPages,
    StepTitles = newStepTitles,
    StepTitlesColor = { 1, 1, 1 },
    StepTitlesColorSelected = { 168 / 255, 85 / 255, 247 / 255 },
    StepTitleWidth = 200,
    StepTitleButtonWidth = 200,
    StepTitleTextJustification = "CENTER",
  }
end

-- UpdateOutOfDateAddons is run when they update the addons, and only shows things that are out of date
function VXJediUI:UpdateOutOfDateAddons(resolution)
  local newPages = {}
  local newStepTitles = {}

  table.insert(newPages, updatePage)
  table.insert(newStepTitles, stepTitles["Intro"])

  for _, addonName in ipairs(addOns) do
    -- Only update the things that are out of date, and import them
    if IsModuleOutOfDate(addonName) then
      table.insert(newPages, pages[addonName](true, false, resolution))
      table.insert(newStepTitles, stepTitles[addonName])
    end
    if addonName == "ElvUI" then
      if VXJediUIDB.InstalledVersions["BlizzardCooldownManager"] == nil or HasMissingCDMImports(resolution) then
        AppendBlizzardCooldownManagerPage(newPages, newStepTitles, true, false, resolution)
      end
    end
  end

  table.insert(newPages, pages["Finish"])
  table.insert(newStepTitles, stepTitles["Finish"])

  return {
    Title = "|TInterface\\AddOns\\VXJediMedia\\StatusBars\\VXJedi.tga:16:16|t " .. Color(addonName) .. " " .. Grey("v" .. GetAddonVersion()),
    Name = string.format("%s Installation", Color(addonName)),
    tutorialImage = "Interface\\AddOns\\VXJediMedia\\Media\\logo.tga",
    Pages = newPages,
    StepTitles = newStepTitles,
    StepTitlesColor = { 1, 1, 1 },
    StepTitlesColorSelected = { 168 / 255, 85 / 255, 247 / 255 },
    StepTitleWidth = 200,
    StepTitleButtonWidth = 200,
    StepTitleTextJustification = "CENTER",
  }
end

function GetAyijeCDMSpecProfilesFromClass(className)
  local specOptions = {
    ["Death Knight"] = {
      "VXJediUI",              -- [1] Blood
      "VXJediUI",              -- [2] Frost
      "VXJediUI",              -- [3] Unholy
      ["enabled"] = true,
    },
    ["Demon Hunter"] = {
      "VXJediUI CastEmphasize",              -- [1] Havoc
      "VXJediUI CastEmphasize",              -- [2] Vengeance
      "VXJediUI CastEmphasize", -- [3] Devourer
      ["enabled"] = true,
    },
    ["Druid"] = {
      "VXJediUI CastEmphasize", -- [1] Balance
      "VXJediUI",              -- [2] Feral
      "VXJediUI",              -- [3] Guardian
      "VXJediUI Healer",       -- [4] Restoration
      ["enabled"] = true,
    },
    ["Evoker"] = {
      "VXJediUI CastEmphasize", -- [1] Devastation
      "VXJediUI Healer DualResource",                     -- [2] Preservation
      "VXJediUI CastEmphasize",                     -- [3] Augmentation
      ["enabled"] = true,
    },
    ["Hunter"] = {
      "VXJediUI",              -- [1] Beast Mastery
      "VXJediUI CastEmphasize",              -- [2] Marksmanship
      "VXJediUI",              -- [3] Survival
      ["enabled"] = true,
    },
    ["Mage"] = {
      "VXJediUI CastEmphasize", -- [1] Arcane
      "VXJediUI CastEmphasize", -- [2] Fire
      "VXJediUI CastEmphasize", -- [3] Frost
      ["enabled"] = true,
    },
    ["Monk"] = {
      "VXJediUI",              -- [1] Brewmaster
      "VXJediUI Healer",       -- [2] Mistweaver
      "VXJediUI",              -- [3] Windwalker
      ["enabled"] = true,
    },
    ["Paladin"] = {
      "VXJediUI Healer DualResource",       -- [1] Holy
      "VXJediUI",              -- [2] Protection
      "VXJediUI",              -- [3] Retribution
      ["enabled"] = true,
    },
    ["Priest"] = {
      "VXJediUI Healer",       -- [1] Discipline
      "VXJediUI Healer",       -- [2] Holy
      "VXJediUI CastEmphasize", -- [3] Shadow
      ["enabled"] = true,
    },
    ["Rogue"] = {
      "VXJediUI",              -- [1] Assassination
      "VXJediUI",              -- [2] Outlaw
      "VXJediUI",              -- [3] Subtlety
      ["enabled"] = true,
    },
    ["Shaman"] = {
      "VXJediUI CastEmphasize", -- [1] Elemental
      "VXJediUI",              -- [2] Enhancement
      "VXJediUI Healer",       -- [3] Restoration
      ["enabled"] = true,
    },
    ["Warlock"] = {
      "VXJediUI CastEmphasize", -- [1] Affliction
      "VXJediUI CastEmphasize", -- [2] Demonology
      "VXJediUI CastEmphasize", -- [3] Destruction
      ["enabled"] = true,
    },
    ["Warrior"] = {
      "VXJediUI",              -- [1] Arms
      "VXJediUI",              -- [2] Fury
      "VXJediUI",              -- [3] Protection
      ["enabled"] = true,
    },
  }

  return specOptions[className]
end

function GetDualSpecConfigFromClass(className, useColor)
  local classOptionsNormal = {
    ["Shaman"] = {
      "VXJediUI",        -- [1]
      "VXJediUI",        -- [2]
      "VXJediUI Healer", -- [3]
      ["enabled"] = true,
    },
    ["Paladin"] = {
      "VXJediUI Healer", -- [1]
      "VXJediUI",        -- [2]
      "VXJediUI",        -- [3]
      ["enabled"] = true,
    },
    ["Priest"] = {
      "VXJediUI Healer", -- [1]
      "VXJediUI Healer", -- [2]
      "VXJediUI",        -- [3]
      ["enabled"] = true,
    },
    ["Monk"] = {
      "VXJediUI",        -- [1]
      "VXJediUI Healer", -- [2]
      "VXJediUI",        -- [3]
      ["enabled"] = true,
    },
    ["Druid"] = {
      "VXJediUI",        -- [1]
      "VXJediUI",        -- [2]
      "VXJediUI",        -- [3]
      "VXJediUI Healer", -- [4]
      ["enabled"] = true,
    },
    ["Evoker"] = {
      "VXJediUI",        -- [1]
      "VXJediUI Healer", -- [2]
      "VXJediUI",        -- [3]
      ["enabled"] = true,
    },
  }

  local classOptionsColor = {
    ["Shaman"] = {
      "VXJediUI [C]",        -- [1]
      "VXJediUI [C]",        -- [2]
      "VXJediUI Healer [C]", -- [3]
      ["enabled"] = true,
    },
    ["Paladin"] = {
      "VXJediUI Healer [C]", -- [1]
      "VXJediUI [C]",        -- [2]
      "VXJediUI [C]",        -- [3]
      ["enabled"] = true,
    },
    ["Priest"] = {
      "VXJediUI Healer [C]", -- [1]
      "VXJediUI Healer [C]", -- [2]
      "VXJediUI [C]",        -- [3]
      ["enabled"] = true,
    },
    ["Monk"] = {
      "VXJediUI [C]",        -- [1]
      "VXJediUI Healer [C]", -- [2]
      "VXJediUI [C]",        -- [3]
      ["enabled"] = true,
    },
    ["Druid"] = {
      "VXJediUI [C]",        -- [1]
      "VXJediUI [C]",        -- [2]
      "VXJediUI [C]",        -- [3]
      "VXJediUI Healer [C]", -- [4]
      ["enabled"] = true,
    },
    ["Evoker"] = {
      "VXJediUI [C]",        -- [1]
      "VXJediUI Healer [C]", -- [2]
      "VXJediUI [C]",        -- [3]
      ["enabled"] = true,
    },
  }

  if classOptionsNormal[className] == nil then
    return {
      ["enabled"] = false,
    }
  end

  if useColor then
    return classOptionsColor[className]
  else
    return classOptionsNormal[className]
  end
end

local function MigrateLegacyCDMImportState()
  VXJediUIDB.CDMImportedTags = VXJediUIDB.CDMImportedTags or {}

  if not VXJediUIDB.CDMImported then return end

  for _, importedByTag in pairs(VXJediUIDB.CDMImported) do
    if type(importedByTag) == "table" then
      for tag, imported in pairs(importedByTag) do
        if imported then
          VXJediUIDB.CDMImportedTags[tonumber(tag) or tag] = true
        end
      end
    end
  end
end

local function ResetCDMImportsOnVersionBump()
  local cdmVersion = GetAddonInstalledVersion("BlizzardCooldownManager")
  if not cdmVersion then return end

  if VXJediUIDB.CDMImportedVersion ~= cdmVersion then
    VXJediUIDB.CDMImportedTags = {}
    VXJediUIDB.CDMImportedVersion = cdmVersion
    VXJediUIDB.InstalledVersions["BlizzardCooldownManager"] = nil
  end
end

-- This function is run when the Addon is loaded
-- We'll only want to run the installer if the person has NOT run it before
function VXJediUI:Initialize()
  Details:AddDefaultCustomDisplays()
  Details:SetTutorialCVar("STREAMER_PLUGIN_FIRSTRUN", true)
  Details.auto_open_news_window = false
  Details:SetTutorialCVar("version_announce", 1)
  Details.character_first_run = false
  Details.is_first_run = false

  -- Optional addons inserted after ElvUI (index 1) in desired order
  -- Final order: ElvUI, [CDM inserted separately], AyijeCDM, VXJediEssentials,
  --              Plater, Details, WarpDeplete, BigWigs, BuffReminders, EditMode
  local insertPos = 2  -- after ElvUI

  if IsAddOnLoaded("Ayije_CDM") then
    table.insert(addOns, insertPos, "AyijeCDM")
    insertPos = insertPos + 1
  end

  if IsAddOnLoaded("VXJediEssentials") then
    table.insert(addOns, insertPos, "VXJediEssentials")
    insertPos = insertPos + 1
  end

  -- BigWigs and BuffReminders go before EditMode (which is last in the base list)
  local editModeIdx
  for idx, name in ipairs(addOns) do
    if name == "EditMode" then editModeIdx = idx break end
  end

  if IsAddOnLoaded("BigWigs") then
    table.insert(addOns, editModeIdx, "BigWigs")
    editModeIdx = editModeIdx + 1
  end

  if IsAddOnLoaded("BuffReminders") then
    table.insert(addOns, editModeIdx, "BuffReminders")
    editModeIdx = editModeIdx + 1
  end



  local function SuppressElvAnchorChangelog()
    local frame = _G.ElvUI_Anchor_Changelog
    if not frame then return end

    frame:Hide()
    frame:SetScript("OnShow", frame.Hide)
  end

  C_Timer.After(6, SuppressElvAnchorChangelog)
  -- Force their DB to nil if the installed version isn't set
  -- This is a hack for before versioning
  if VXJediUIDB ~= nil and VXJediUIDB.InstalledVersion == nil then
    PreviouslyInstalled = true
    VXJediUIDB = nil
  end

  if VXJediUIDB == nil then
    SetFont()

    SetCVar("ScriptErrors", "0");

    VXJediUIDB = {}
    VXJediUIDB.InstalledVersion = nil
    VXJediUIDB.InstalledVersions = {}
    VXJediUIDB.InstalledChars = {}

    VXJediUIDB.AddonData = {}
    VXJediUIDB.AddonData.ElvUI = {}
    VXJediUIDB.AddonData.ElvUI.ProfileKeys = {}
    VXJediUIDB.AddonData.MRT = {}
    VXJediUIDB.AddonData.MRT.ProfileKeys = {}

    if IsAddOnLoaded("Details") then
      Details:Disable()
      Details:DisablePlugin("DETAILS_PLUGIN_STREAM_OVERLAY")
    end
  end

  VXJediUIDB.InstalledVersions = VXJediUIDB.InstalledVersions or {}
  VXJediUIDB.CDMImportedTags = VXJediUIDB.CDMImportedTags or {}

  MigrateLegacyCDMImportState()
  ResetCDMImportsOnVersionBump()

  if VXJediUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] == nil then
    SetFont()
  end

  -- Skip ElvUI installation process
  E.private.install_complete = E.version

  -- Hide minimap icons for a clean install experience
  local function HideMinimapIcons()
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if LDBIcon then
      local iconsToHide = { "MythicDungeonTools", "BigWigs", "Plater", "Details", "DetailsStreamer", "SimulationCraft", "SimC" }
      for _, iconName in ipairs(iconsToHide) do
        if LDBIcon:IsRegistered(iconName) then
          LDBIcon:Hide(iconName)
        end
      end
    end
  end
  -- Expose HideMinimapIcons globally so the Extras page can call it
  VXJediUI.HideMinimapIcons = HideMinimapIcons

  -- Suppress Baganator welcome popup, set category mode (once), and close bags
  if IsAddOnLoaded("Baganator") then
    -- Only force category view on first run for this character, then respect user choice
    VXJediUIDB.BaganatorInitialized = VXJediUIDB.BaganatorInitialized or {}
    local charKey = UnitName("player") .. " - " .. GetRealmName()

    if not VXJediUIDB.BaganatorInitialized[charKey] and BAGANATOR_CONFIG then
      BAGANATOR_CONFIG["bag_view_type"] = "category"
      if not BAGANATOR_CONFIG["Profiles"] then BAGANATOR_CONFIG["Profiles"] = {} end
      if not BAGANATOR_CONFIG["Profiles"]["DEFAULT"] then BAGANATOR_CONFIG["Profiles"]["DEFAULT"] = {} end
      BAGANATOR_CONFIG["Profiles"]["DEFAULT"]["bag_view_type"] = "category"
      BAGANATOR_CONFIG["Profiles"]["DEFAULT"]["seen_welcome"] = 1
      VXJediUIDB.BaganatorInitialized[charKey] = true
    end

    local function DismissBaganator()
      local welcomeFrame = _G["Baganator_WelcomeFrame"]
      if welcomeFrame and welcomeFrame:IsShown() then
        welcomeFrame:Hide()
      end
      for _, frameName in ipairs({
        "Baganator_SingleViewBackpackViewFrameelvui",
        "Baganator_CategoryViewBackpackViewFrameelvui",
        "Baganator_SingleViewBackpackViewFrame",
        "Baganator_CategoryViewBackpackViewFrame",
      }) do
        local frame = _G[frameName]
        if frame and frame:IsShown() then
          frame:Hide()
        end
      end
      CloseAllBags()
    end

    C_Timer.After(0.5, DismissBaganator)
    C_Timer.After(1, DismissBaganator)
    C_Timer.After(3, DismissBaganator)
  end

  -- Skin step title buttons with transparent backdrop and hover glow
  -- Also adjust font sizes and spacing on installer pages
  local PI = E:GetModule("PluginInstaller")
  if PI and PI.Queue then
    hooksecurefunc(PI, "SetupReset", function()
      -- Hide custom CDM button at the start of each page (CDM page re-shows it)
      if PluginInstallFrame and PluginInstallFrame._auiCDMAllButton then
        PluginInstallFrame._auiCDMAllButton:Hide()
      end

      -- Apply font size and spacing adjustments (once)
      if PluginInstallFrame and not PluginInstallFrame._auiStyled then
        PluginInstallFrame._auiStyled = true

        local function BumpFontSize(fontString, bump)
          if not fontString then return end
          local font, size, flags = fontString:GetFont()
          if font and size then
            fontString:SetFont(font, size + bump, flags)
          end
        end

        local fontBump = (GetResolution() == "1080p") and 0 or 1

        if PluginInstallFrame.Desc1 then BumpFontSize(PluginInstallFrame.Desc1, fontBump) end
        if PluginInstallFrame.Desc2 then BumpFontSize(PluginInstallFrame.Desc2, fontBump) end
        if PluginInstallFrame.Desc3 then BumpFontSize(PluginInstallFrame.Desc3, fontBump) end
        if PluginInstallFrame.Desc4 then BumpFontSize(PluginInstallFrame.Desc4, fontBump) end

        if PluginInstallFrame.Desc1 then
          local point, relativeTo, relativePoint, xOfs, yOfs = PluginInstallFrame.Desc1:GetPoint()
          if point then
            PluginInstallFrame.Desc1:SetPoint(point, relativeTo, relativePoint, xOfs, (yOfs or 0) - 10)
          end
        end
        if PluginInstallFrame.Desc2 then
          local point, relativeTo, relativePoint, xOfs, yOfs = PluginInstallFrame.Desc2:GetPoint()
          if point then
            PluginInstallFrame.Desc2:SetPoint(point, relativeTo, relativePoint, xOfs, (yOfs or 0) - 6)
          end
        end
      end
    end)

    hooksecurefunc(PI, "Queue", function()
      C_Timer.After(0.2, function()
        if not PluginInstallFrame then return end

        -- Adjust font sizes (+1) and spacing on the content area
        -- Font styling is now applied in SetupReset hook (no delay)

        -- Step title button hover glow
        if not PluginInstallFrame.side then return end
        local side = PluginInstallFrame.side
        if not side.Lines then return end
        for i = 1, #side.Lines do
          local btn = side.Lines[i]
          if btn and not btn._auiSkinned then
            btn._auiSkinned = true

            -- Create a subtle hover glow
            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(115/255, 129/255, 1, 0.15)
            highlight:SetBlendMode("ADD")
          end
        end
      end)
    end)
  end

  -- Ignore ElvUI warnings
  E.global.ignoreIncompatible = true

  local resolution = GetResolution()
  -- If they haven't run the installer before, or switched resolutions, do a force install
  if VXJediUIDB.InstalledVersion == nil then
    Details:ShutDownAllInstances()
    E:GetModule("PluginInstaller"):Queue(VXJediUI:Install(resolution))
  elseif VXJediUIDB.InstalledResolution ~= resolution then
    Details:ShutDownAllInstances()
    E:GetModule("PluginInstaller"):Queue(VXJediUI:ForceReinstall(resolution))
    -- Else if they log in and their addon is out of date, run the normal Installer (skips whatever is not updated)
  elseif IsAddonOutOfDate(VXJediUIDB.InstalledVersion) then
    Details:ShutDownAllInstances()
    local shouldRunInstaller = false
    for _, addon in pairs(addOns) do
      if IsModuleOutOfDate(addon) then
        shouldRunInstaller = true
        break
      end
    end

    if (shouldRunInstaller) then
      E:GetModule("PluginInstaller"):Queue(VXJediUI:UpdateOutOfDateAddons(resolution))
    else
      -- Silently update to the latest version
      VXJediUIDB.InstalledVersion = GetAddonVersion()
      VXJediUIDB.InstalledResolution = resolution
    end
    -- Else if that character has not installed the addon before, run it
  elseif VXJediUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] == nil then
    Details:ShutDownAllInstances()
    E:GetModule("PluginInstaller"):Queue(VXJediUI:SetProfiles())
  end
end

-- The command that the person runs to force the installer to run
SLASH_VXJEDIUI1 = "/vxjediui"
SLASH_VXJEDIUI2 = "/vxjediui"

-- Ran when the person types /vxjediui
function RunVXJediUI(msg, _)
  local tokens = SplitStr(msg)
  if tokens[1] == "install" then
    if (tokens[2] ~= nil and tokens[2] == "1080p") then
      ConfirmOverwriteInstall(
        "It appears you have already installed VXJediUI. This will re-install all profiles. If you are looking to load what you have already installed on your new character, please type |cffA855F7/vxjediui load|r instead.\n\nContinue with Install?",
        function() E:GetModule("PluginInstaller"):Queue(VXJediUI:ForceReinstall("1080p")) end, nil)
    elseif (tokens[2] ~= nil and tokens[2] == "1440p") then
      ConfirmOverwriteInstall(
        "It appears you have already installed VXJediUI. This will re-install all profiles. If you are looking to load what you have already installed on your new character, please type |cffA855F7/vxjediui load|r instead.\n\nContinue with Install?",
        function() E:GetModule("PluginInstaller"):Queue(VXJediUI:ForceReinstall("1440p")) end, nil)
    else
      ConfirmOverwriteInstall(
        "It appears you have already installed VXJediUI. This will re-install all profiles. If you are looking to load what you have already installed on your new character, please type |cffA855F7/vxjediui load|r instead.\n\nContinue with Install?",
        function() E:GetModule("PluginInstaller"):Queue(VXJediUI:ForceReinstall(GetResolution())) end, nil)
    end
  elseif tokens[1] == "load" then
    E:GetModule("PluginInstaller"):Queue(VXJediUI:SetProfiles())
  elseif tokens[1] == "cdm" then
    -- Clear any stale install entries so we can reopen
    local PI = E:GetModule("PluginInstaller")
    wipe(PI.Installs)
    if (tokens[2] ~= nil and tokens[2] == "1080p") then
      PI:Queue(VXJediUI:BlizzardCooldownManagerOnly("1080p"))
    elseif (tokens[2] ~= nil and tokens[2] == "1440p") then
      PI:Queue(VXJediUI:BlizzardCooldownManagerOnly("1440p"))
    else
      PI:Queue(VXJediUI:BlizzardCooldownManagerOnly(GetResolution()))
    end
  elseif (tokens[1] == "ver") or (tokens[1] == "version") or (tokens[1] == "v") then
    print(string.format("|cffffffffVXJediUI version %s", GetAddonVersion()))
  elseif tokens[1] == "debug" then
    local prefix = "|cffA855F7VXJediUI|r |cffc0c0c0debug|r"
    print(prefix .. " ----------------------------")
    print(prefix .. " Installer: " .. Color("v" .. GetAddonVersion()))
    print(prefix .. " Resolution: " .. Color(GetResolution()))
    print(prefix .. " Installed Version: " .. (VXJediUIDB.InstalledVersion or Red("not set")))
    print(prefix .. " Installed Resolution: " .. (VXJediUIDB.InstalledResolution or Red("not set")))
    print(prefix .. " Character: " .. UnitName("player") .. " - " .. GetRealmName())
    print(prefix .. " ----------------------------")
    print(prefix .. " Addon Versions (saved / current):")
    local trackedAddons = { "ElvUI", "BigWigs", "Details", "Plater", "WarpDeplete", "EditMode", "VXJediEssentials", "AyijeCDM", "BuffReminders", "BlizzardCooldownManager" }
    for _, name in ipairs(trackedAddons) do
      local saved = GetAddonSavedVersion(name)
      local addonFileName = name
      if name == "EditMode" then addonFileName = "Blizzard_EditMode"
      elseif name == "AyijeCDM" then addonFileName = "Ayije_CDM" end
      local loaded = IsAddOnLoaded(addonFileName)
      if loaded then
        local current = GetAddonInstalledVersion(name)
        local savedStr = saved ~= "0" and saved or Red("none")
        local status = ""
        if saved == "0" then
          status = " " .. Red("(not imported)")
        elseif IsModuleOutOfDate(name) then
          status = " " .. Red("(update available)")
        else
          status = " " .. Green("(up to date)")
        end
        print(prefix .. "   " .. name .. ": " .. savedStr .. " / " .. current .. status)
      else
        print(prefix .. "   " .. name .. ": " .. Grey("not loaded"))
      end
    end
    print(prefix .. " ----------------------------")
  else
    print(Color("Welcome to VXJediUI v" .. GetAddonVersion()))
    print("For first time installation, please type " .. Color("/vxjediui install") .. ".")
    print("If you'd like to force the installer to install a different resolution, please type " .. Color("/vxjediui install 1080p") .. " OR " .. Color("/vxjediui install 1440p") .. ".")
    print("If you already installed, and just want to load the profiles on your new character, please type " .. Color("/vxjediui load") .. ".")
    print("To install just the Blizzard Cooldown Manager strings, please type " .. Color("/vxjediui cdm") .. ".")
    print("For debugging support, please type " .. Color("/vxjediui debug") .. ".")
  end
end

function SplitStr(s)
  local chunks = {}
  for substring in s:gmatch("%S+") do
    table.insert(chunks, substring)
  end
  return chunks
end

SlashCmdList["VXJEDIUI"] = RunVXJediUI

E:RegisterModule(VXJediUI:GetName())
