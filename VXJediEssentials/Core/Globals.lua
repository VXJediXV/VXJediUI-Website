-- VXJediEssentials namespace
---@class AE
---@diagnostic disable: undefined-field
local AE = select(2, ...)
local addonName = select(1, ...)

-- Localization
local ipairs = ipairs
local print = print
local string_gsub = string.gsub
local ReloadUI = ReloadUI
local C_AddOns = C_AddOns
local _G = _G

-- Libraries
AE.LSM = LibStub("LibSharedMedia-3.0")
AE.LDS = LibStub("LibDualSpec-1.0")

-- Standard addon font and statusbar
AE.PATH = ([[Interface\AddOns\%s\Media\]]):format(addonName)
AE.FONT = AE.PATH .. [[Fonts\]] .. 'Expressway.TTF'
AE.SB = AE.PATH .. [[Statusbars\]] .. 'VXJediEssentials'

-- Register LSM media
if AE.LSM then
    AE.LSM:Register('font', 'Expressway', AE.FONT)
    AE.LSM:Register('statusbar', 'VXJediEssentials', AE.SB)
    AE.LSM:Register('border', 'WHITE8X8', [[Interface\Buttons\WHITE8X8]])
end

-- Helper to get Font Path from Name
function AE:GetFontPath(fontName)
    if AE.LSM and fontName then
        local path = AE.LSM:Fetch("font", fontName)
        if path then return path end
    end
    return "Fonts\\FRIZQT__.TTF"
end

-- Helper to get statusbar Path from Name
function AE:GetStatusbarPath(barName)
    if AE.LSM and barName then
        local path = AE.LSM:Fetch("statusbar", barName)
        if path then return path end
    end
    return "Interface\\TargetingFrame\\UI-StatusBar"
end

-- Addon information (cached metadata calls)
local function GetAddonMetadata()
    if not C_AddOns then return end
    local name = "VXJediEssentials"
    AE.AddOnName = C_AddOns.GetAddOnMetadata(name, "Title")
    AE.Version = C_AddOns.GetAddOnMetadata(name, "Version")
    AE.Author = C_AddOns.GetAddOnMetadata(name, "Author")
end
GetAddonMetadata()

-- Stub for GUI sidebar compatibility
function AE:ShouldNotLoadModule() return false end

-- Print: Print message to chat with addon prefix
function AE:Print(msg)
    print(self:ColorTextByTheme("VXJedi") .. "Essentials:|r " .. msg)
end

-- Setup slash commands (registered at file load time for reliability)
SLASH_VXJEDIESSENTIALS1 = "/aes"
SLASH_VXJEDIESSENTIALS2 = "/vxjediessentials"
SlashCmdList["VXJEDIESSENTIALS"] = function(msg)
    msg = (msg or ""):lower()
    msg = string_gsub(msg, "^%s+", "")
    msg = string_gsub(msg, "%s+$", "")
    if msg == "" or msg == "gui" then
        if AE.GUIFrame then
            AE.GUIFrame:Toggle()
        end
    end
end

SLASH_VXJEDI_RL1 = "/rl"
SlashCmdList["VXJEDI_RL"] = function() ReloadUI() end

SLASH_VXJEDI_FS1 = "/fs"
SlashCmdList["VXJEDI_FS"] = function()
    UIParentLoadAddOn("Blizzard_DebugTools")
    FrameStackTooltip_Toggle()
end

-- Initialization
function AE:Init()
    if AE.db and AE.db.profile.ShowChatMessage == true then
        AE:Print(AE:ColorTextByTheme("/aes") .. " to open the configuration window.")
    end
end

-- Resolve anchor frame from db settings (SCREEN, UIPARENT, SELECTFRAME)
function AE:ResolveAnchorFrame(anchorFrameType, parentFrameName)
    if anchorFrameType == "SCREEN" or anchorFrameType == "UIPARENT" then
        return UIParent
    elseif anchorFrameType == "SELECTFRAME" and parentFrameName then
        local frame = _G[parentFrameName]
        return frame or UIParent
    end
    return UIParent
end

-- Convert font outline value for SetFont API (NONE -> "")
function AE:GetFontOutline(outline)
    if not outline or outline == "NONE" or outline == "" then
        return ""
    end
    return outline
end

-- Safely apply font settings to a FontString with fallback
function AE:ApplyFont(fontString, fontName, fontSize, fontOutline)
    if not fontString then return false end

    local fontPath = self:GetFontPath(fontName)
    if not fontPath or fontPath == "" then
        fontPath = "Fonts\\FRIZQT__.TTF"
    end

    local outline = self:GetFontOutline(fontOutline)
    local size = fontSize
    if not size or size <= 0 then
        size = 12
    end

    local success = fontString:SetFont(fontPath, size, outline)
    if not success then
        success = fontString:SetFont("Fonts\\FRIZQT__.TTF", size, outline)
    end
    return success
end

-- Apply font settings to a frame's .text FontString from a settings table
-- Example: AE:ApplyFontSettings(self.frame, self.db, true)
function AE:ApplyFontSettings(frame, settings, color)
    if not frame or not frame.text or not settings then return false end
    local text = frame.text

    local fontName = settings.FontFace or "Friz Quadrata TT"
    local fontSize = settings.FontSize
    if not fontSize or fontSize <= 0 then fontSize = 14 end
    local fontOutline = settings.FontOutline or "OUTLINE"

    if color then
        text:SetTextColor(unpack(settings.Color or { 1, 1, 1, 1 }))
    end

    local success = self:ApplyFont(text, fontName, fontSize, fontOutline)

    local shadow = settings.FontShadow or {}
    if shadow.Enabled then
        local shadowColor = shadow.Color or { 0, 0, 0, 1 }
        local shadowAlpha = (shadowColor[4] and shadowColor[4] > 0) and shadowColor[4] or 0.9
        text:SetShadowColor(shadowColor[1], shadowColor[2], shadowColor[3], shadowAlpha)
        text:SetShadowOffset(shadow.OffsetX or 1, shadow.OffsetY or -1)
    else
        text:SetShadowOffset(0, 0)
        text:SetShadowColor(0, 0, 0, 0)
    end

    return success
end

-- Apply font settings directly to a FontString (no frame wrapper needed)
-- Example: AE:ApplyFontToText(self.frame.timerText, "Expressway", 18, "OUTLINE", shadowSettings)
function AE:ApplyFontToText(fontString, fontName, fontSize, fontOutline, shadowSettings)
    if not fontString then return false end

    fontName = fontName or "Friz Quadrata TT"
    fontSize = (fontSize and fontSize > 0) and fontSize or 14
    fontOutline = fontOutline or "OUTLINE"
    shadowSettings = shadowSettings or {}

    local success = self:ApplyFont(fontString, fontName, fontSize, fontOutline)

    if shadowSettings.Enabled then
        local shadowColor = shadowSettings.Color or { 0, 0, 0, 1 }
        local shadowAlpha = (shadowColor[4] and shadowColor[4] > 0) and shadowColor[4] or 0.9
        fontString:SetShadowColor(shadowColor[1], shadowColor[2], shadowColor[3], shadowAlpha)
        fontString:SetShadowOffset(shadowSettings.OffsetX or 1, shadowSettings.OffsetY or -1)
    else
        fontString:SetShadowOffset(0, 0)
        fontString:SetShadowColor(0, 0, 0, 0)
    end

    return success
end

-- Get text justification based on anchor point
function AE:GetTextJustifyFromAnchor(anchorPoint)
    if not anchorPoint then return "CENTER" end
    if anchorPoint == "RIGHT" or anchorPoint == "TOPRIGHT" or anchorPoint == "BOTTOMRIGHT" then
        return "RIGHT"
    elseif anchorPoint == "LEFT" or anchorPoint == "TOPLEFT" or anchorPoint == "BOTTOMLEFT" then
        return "LEFT"
    end
    return "CENTER"
end

-- Get text point based on anchor
function AE:GetTextPointFromAnchor(anchorPoint)
    local justify = self:GetTextJustifyFromAnchor(anchorPoint)
    if justify == "RIGHT" then
        return "RIGHT"
    elseif justify == "LEFT" then
        return "LEFT"
    end
    return "CENTER"
end

-- Preview Manager
local PreviewManager = {}
AE.PreviewManager = PreviewManager

-- Modules that support preview (have ShowPreview/HidePreview functions)
-- Audit: any module that defines :ShowPreview should be listed here so the
-- GUI's preview manager can drive its preview state.
local PREVIEW_MODULES = {
    "CombatCross", "CombatMessage", "CombatRes", "CombatTimer",
    "DispelCursor", "DragonRiding", "FocusCastbar", "Gateway",
    "HuntersMark", "StanceText", "PetTexts", "RangeCheck",
    "TargetCastbar",
}

-- State tracking
PreviewManager.guiOpen = false
PreviewManager.previewsActive = false

-- Update preview state based on GUI
function PreviewManager:UpdatePreviewState()
    local shouldShowPreviews = self.guiOpen

    if shouldShowPreviews and not self.previewsActive then
        self:StartAllPreviews()
        self.previewsActive = true
    elseif not shouldShowPreviews and self.previewsActive then
        self:StopAllPreviews()
        self.previewsActive = false
    end
end

-- Called when GUI opens/closes
function PreviewManager:SetGUIOpen(open)
    self.guiOpen = open
    self:UpdatePreviewState()
end

-- Start all module previews
function PreviewManager:StartAllPreviews()
    local Addon = VXJediEssentials
    if not Addon then return end

    for _, moduleName in ipairs(PREVIEW_MODULES) do
        local module = Addon:GetModule(moduleName, true)
        if module and module.ShowPreview and module.db.Enabled then
            module:ShowPreview()
        end
    end

end

-- Stop all module previews
function PreviewManager:StopAllPreviews()
    local Addon = VXJediEssentials
    if not Addon then return end

    for _, moduleName in ipairs(PREVIEW_MODULES) do
        local module = Addon:GetModule(moduleName, true)
        if module and module.HidePreview then
            module:HidePreview()
        end
    end
end

-- Check if previews are currently active
function PreviewManager:IsPreviewActive()
    return self.previewsActive
end

-- Global apply position settings func
-- Example usage:
-- AE:ApplyFramePosition(self.frame, self.db.Position, self.db, extra: true or empty)
function AE:ApplyFramePosition(frame, posConfig, Config, SetParent)
    if not frame or not posConfig then return end

    -- Resolve parent
    local parent = self:ResolveAnchorFrame(Config.anchorFrameType, Config.ParentFrame)
    if SetParent then
        frame:SetParent(parent)
    end
    -- Clear previous anchors and set new point
    frame:ClearAllPoints()
    frame:SetPoint(
        posConfig.AnchorFrom or "CENTER",
        parent,
        posConfig.AnchorTo or "CENTER",
        posConfig.XOffset or 0,
        posConfig.YOffset or 0
    )
    frame:SetFrameStrata(Config.Strata or "MEDIUM")

    -- Skip pixel snapping when anchored to an ElvUI frame (ElvUI handles its own snapping)
    local parentName = parent and parent.GetName and parent:GetName()
    if not parentName or not parentName:find("^ElvUF_") then
        self:SnapFrameToPixels(frame)
    end
end
