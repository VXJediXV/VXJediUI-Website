-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local type = type
local pairs = pairs

-- Single theme: dark translucent panels, blue accent
local ThemeDefaults = {
    bgDark         = { 0.0627, 0.0627, 0.0627, 0.60 },
    bgMedium       = { 0.0902, 0.0902, 0.0902, 0.60 },
    bgLight        = { 0.0314, 0.0314, 0.0314, 0.60 },
    bgHover        = { 0.1804, 0.1804, 0.1804, 0.60 },
    border         = { 0, 0, 0, 1 },
    accent         = { 0.451, 0.506, 1.0, 1 },
    accentHover    = { 0.451, 0.506, 1.0, 0.25 },
    accentDim      = { 0.361, 0.405, 0.80, 1 },
    textPrimary    = { 1, 1, 1, 1 },
    textSecondary  = { 1, 1, 1, 1 },
    textMuted      = { 1, 1, 1, 1 },
    selectedBg     = { 0.451, 0.506, 1.0, 0.20 },
    selectedText   = { 0.902, 0.902, 0.902, 1 },
    error          = { 0.90, 0.30, 0.30, 1 },
    success        = { 0.30, 0.80, 0.40, 1 },
    warning        = { 0.90, 0.75, 0.30, 1 },

    -- Dimensions
    headerHeight   = 32,
    footerHeight   = 24,
    sidebarWidth   = 180,
    borderSize     = 1,

    -- Spacing
    paddingSmall   = 4,
    paddingMedium  = 8,
    paddingLarge   = 12,
    scrollbarWidth = 14,

    -- Font settings
    fontFace       = "Fonts\\FRIZQT__.TTF",
    fontSizeSmall  = 11,
    fontSizeNormal = 12,
    fontSizeLarge  = 14,
    fontOutline    = "OUTLINE",
    fontShadow     = false,
}
AE.ThemeDefaults = ThemeDefaults

local function CopyColor(color)
    if type(color) ~= "table" then return { 1, 1, 1, 1 } end
    return { color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 1 }
end

-- Live theme table
AE.Theme = {}
for k, v in pairs(ThemeDefaults) do
    if type(v) == "table" then AE.Theme[k] = CopyColor(v) else AE.Theme[k] = v end
end

function AE:RefreshTheme()
    local T = self.Theme
    for k, v in pairs(ThemeDefaults) do
        if type(v) == "table" then T[k] = CopyColor(v) else T[k] = v end
    end
    if self.GUIFrame and self.GUIFrame.mainFrame and self.GUIFrame.mainFrame:IsShown() then
        self.GUIFrame:ApplyThemeColors()
    end
end

function AE:ApplyThemeFont(fontString, size)
    if not fontString or not fontString.SetFont then return end
    local T = self.Theme
    local fs
    if type(size) == "number" then
        fs = size
    elseif size == "small" then
        fs = T.fontSizeSmall or 11
    elseif size == "large" then
        fs = T.fontSizeLarge or 14
    else
        fs = T.fontSizeNormal or 12
    end
    local ff = T.fontFace or "Fonts\\FRIZQT__.TTF"
    local fo = T.fontOutline or "OUTLINE"
    if fo == "NONE" then fo = "" end
    fontString:SetFont(ff, fs, fo)
    if T.fontShadow then
        fontString:SetShadowOffset(1, -1)
        fontString:SetShadowColor(0, 0, 0, 0.8)
    else
        fontString:SetShadowOffset(0, 0)
        fontString:SetShadowColor(0, 0, 0, 0)
    end
end
