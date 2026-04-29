local VXJediUI = select(2, ...)

local LAYOUT_NAME = "VXJediUI"

function VXJediUI:SetEditMode(resolution, forceImport)
  if InCombatLockdown and InCombatLockdown() then return end

  local layoutsInfo = C_EditMode.GetLayouts()
  layoutsInfo.layouts = layoutsInfo.layouts or {}

  local customIndex

  if forceImport then
    local layoutString = VXJediUI.EditModeString and VXJediUI.EditModeString[resolution]
    if not layoutString then return end

    local layoutInfo = C_EditMode.ConvertStringToLayoutInfo(layoutString)
    if not layoutInfo then return end

    layoutInfo.layoutName = LAYOUT_NAME
    layoutInfo.layoutType = Enum.EditModeLayoutType.Account

    for i, layout in ipairs(layoutsInfo.layouts) do
      if layout.layoutName == LAYOUT_NAME then
        layoutsInfo.layouts[i] = layoutInfo
        customIndex = i
        break
      end
    end

    if not customIndex then
      if #layoutsInfo.layouts >= 5 then
        UIErrorsFrame:AddMessage("Edit Mode layout limit reached (5). Delete a layout and try again.", 1, 0.2, 0.2)
        return
      end
      table.insert(layoutsInfo.layouts, layoutInfo)
      customIndex = #layoutsInfo.layouts
    end

    C_EditMode.SaveLayouts(layoutsInfo)

    VXJediUIDB.InstalledVersions["EditMode"] = GetAddonInstalledVersion("EditMode")
  else
    for i, layout in ipairs(layoutsInfo.layouts) do
      if layout.layoutName == LAYOUT_NAME then
        customIndex = i
        break
      end
    end
    if not customIndex then return end
  end

  -- Activate for current spec
  local activeIndex = Enum.EditModePresetLayoutsMeta.NumValues + customIndex
  C_EditMode.SetActiveLayout(activeIndex)

  UIErrorsFrame:SetScale(2)
  RefreshImportStatus("EditMode")
  PlaySoundFile(InstallationSoundFile)
  UIErrorsFrame:AddMessage("Imported Edit Mode Layout", 1, 1, 1)
end
