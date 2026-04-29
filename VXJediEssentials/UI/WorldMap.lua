-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("WorldMap: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class WorldMap: AceModule, AceEvent-3.0
local WM = VXJediEssentials:NewModule("WorldMap", "AceEvent-3.0")

-- Locals
local CreateFrame = CreateFrame
local tonumber = tonumber
local format = string.format
local gsub = string.gsub

local C_Map = C_Map
local C_SuperTrack = C_SuperTrack
local UiMapPoint = UiMapPoint
local EventRegistry = EventRegistry

-- Constants
local DEFAULT_SCALE = 1.2

-- Module state
WM.scaleApplied = false
WM.searchBar = nil
WM._minimizedCallback = nil
WM._maximizedCallback = nil

-- Update db
function WM:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.WorldMap
end

-- Module init
function WM:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

-- ================================================================
-- SCALE
-- ================================================================

function WM:ApplyScale()
    if not self.db or not self.db.ScaleEnabled then return end
    if not WorldMapFrame then return end

    local size = self.db.Scale or DEFAULT_SCALE

    WorldMapFrame:SetClampedToScreen(true)
    WorldMapFrame:SetScale(size)

    -- Register minimize/maximize callbacks once. We store closures so we can
    -- unregister them on disable, and so they always read the current scale value.
    if not self.scaleApplied then
        self._minimizedCallback = function()
            if self.db and self.db.ScaleEnabled then
                WorldMapFrame:SetScale(self.db.Scale or DEFAULT_SCALE)
            end
        end
        self._maximizedCallback = function()
            WorldMapFrame:SetScale(1)
        end
        EventRegistry:RegisterCallback("WorldMapMinimized", self._minimizedCallback, self)
        EventRegistry:RegisterCallback("WorldMapMaximized", self._maximizedCallback, self)
        self.scaleApplied = true
    end
end

function WM:RevertScale()
    if not WorldMapFrame then return end
    WorldMapFrame:SetScale(1)
    if self.scaleApplied then
        if self._minimizedCallback then
            EventRegistry:UnregisterCallback("WorldMapMinimized", self)
        end
        if self._maximizedCallback then
            EventRegistry:UnregisterCallback("WorldMapMaximized", self)
        end
        self.scaleApplied = false
    end
end

-- ================================================================
-- WAYPOINT SEARCH BAR
-- ================================================================

-- Parse coordinate text into x, y values
-- Accepts formats like: 45 67, 45.2 67.8, 45, 67, /way 45 67
local function ParseCoordinates(text)
    if not text or text == "" then return nil, nil end

    -- Strip common prefixes
    text = gsub(text, "^%s*/way%s*", "")
    text = gsub(text, "^%s*way%s*", "")

    -- Normalize separators
    text = gsub(text, "[,/|\"'%[%]%(%)]+", " ")
    text = gsub(text, "%s+", " ")
    text = gsub(text, "^%s+", "")
    text = gsub(text, "%s+$", "")

    -- Extract numbers
    local numbers = {}
    for num in text:gmatch("([%d%.]+)") do
        local n = tonumber(num)
        if n then
            numbers[#numbers + 1] = n
        end
    end

    if #numbers < 2 then return nil, nil end

    local x, y = numbers[1], numbers[2]
    if x > 100 or y > 100 then return nil, nil end

    return x, y
end

-- Get the active map ID (world map if shown, otherwise player's current map)
local function GetActiveMapID()
    if WorldMapFrame and WorldMapFrame:IsShown() then
        local id = WorldMapFrame:GetMapID()
        if id and id > 0 then return id end
    end
    return C_Map.GetBestMapForUnit("player")
end

-- Set a waypoint on the current map
local function SetWaypoint(x, y)
    local mapID = GetActiveMapID()
    if not mapID then return false, L["No map found"] end

    -- Scale to 0-1 range if needed
    if x > 1 then x = x / 100 end
    if y > 1 then y = y / 100 end

    if not C_Map.CanSetUserWaypointOnMap(mapID) then
        return false, L["Can't set waypoint here"]
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)

    local mapInfo = C_Map.GetMapInfo(mapID)
    local mapName = mapInfo and mapInfo.name or L["Unknown"]
    return true, format("%s (%.1f, %.1f)", mapName, x * 100, y * 100)
end

function WM:CreateSearchBar()
    if self.searchBar then return end
    if not WorldMapFrame then return end
    if not self.db or not self.db.WaypointBarEnabled then return end

    local fontSize = 12

    -- EditBox
    local editBox = CreateFrame("EditBox", "AE_WorldMapSearchBar", WorldMapFrame)
    editBox:SetSize(140, 20)
    editBox:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 3, -5)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(50)
    editBox:SetFrameStrata("DIALOG")

    -- Backdrop
    local bg = CreateFrame("Frame", nil, editBox, BackdropTemplateMixin and "BackdropTemplate")
    bg:SetAllPoints(editBox)
    bg:SetFrameLevel(editBox:GetFrameLevel() - 1)
    bg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    bg:SetBackdropColor(0, 0, 0, 0.7)
    bg:SetBackdropBorderColor(0, 0, 0, 1)

    -- Font
    local fontPath = AE:GetFontPath("Expressway") or "Fonts\\FRIZQT__.TTF"
    editBox:SetFont(fontPath, fontSize, "")
    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetTextInsets(4, 4, 0, 0)

    -- Placeholder text
    local placeholder = editBox:CreateFontString(nil, "ARTWORK")
    placeholder:SetFont(fontPath, fontSize, "")
    placeholder:SetTextColor(0.5, 0.5, 0.5, 0.8)
    placeholder:SetText("/way x y")
    placeholder:SetPoint("LEFT", editBox, "LEFT", 4, 0)
    editBox.placeholder = placeholder

    -- Status text (shows result after pressing enter)
    local statusText = editBox:CreateFontString(nil, "ARTWORK")
    statusText:SetFont(fontPath, fontSize - 1, "OUTLINE")
    statusText:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
    editBox.statusText = statusText

    -- Focus handlers
    editBox:SetScript("OnEditFocusGained", function()
        placeholder:Hide()
    end)

    editBox:SetScript("OnEditFocusLost", function(eb)
        local text = eb:GetText()
        if not text or text:gsub(" ", "") == "" then
            placeholder:Show()
        end
    end)

    -- Live preview while typing
    editBox:SetScript("OnTextChanged", function(eb, userInput)
        if not userInput then return end
        local text = eb:GetText()
        if not text or text:gsub(" ", "") == "" then
            statusText:SetText("")
            return
        end

        local x, y = ParseCoordinates(text)
        if x and y then
            local mapID = GetActiveMapID()
            local mapInfo = mapID and C_Map.GetMapInfo(mapID)
            local name = mapInfo and mapInfo.name or ""
            statusText:SetTextColor(0.3, 1, 0.3, 1)
            statusText:SetText(format("%s (%.1f, %.1f)", name, x, y))
        else
            statusText:SetTextColor(1, 0.3, 0.3, 1)
            statusText:SetText(L["Invalid"])
        end
    end)

    -- Enter to set waypoint
    editBox:SetScript("OnEnterPressed", function(eb)
        local text = eb:GetText()
        local x, y = ParseCoordinates(text)
        if x and y then
            local success, msg = SetWaypoint(x, y)
            if success then
                statusText:SetTextColor(0.3, 1, 0.3, 1)
                statusText:SetText(msg)
                AE:Print(L["Waypoint set"] .. ": " .. msg)
                eb:SetText("")
            else
                statusText:SetTextColor(1, 0.3, 0.3, 1)
                statusText:SetText(msg)
            end
        else
            statusText:SetTextColor(1, 0.3, 0.3, 1)
            statusText:SetText(L["Invalid coordinates"])
        end
        eb:ClearFocus()
    end)

    -- Escape to cancel
    editBox:SetScript("OnEscapePressed", function(eb)
        eb:SetText("")
        statusText:SetText("")
        eb:ClearFocus()
    end)

    self.searchBar = editBox
end

-- ================================================================
-- APPLY / ENABLE
-- ================================================================

function WM:ApplySettings()
    self:UpdateDB()
    if not self.db then return end

    -- Scale
    if self.db.ScaleEnabled then
        self:ApplyScale()
    else
        self:RevertScale()
    end

    -- Waypoint search bar
    if self.db.WaypointBarEnabled then
        if WorldMapFrame then
            self:CreateSearchBar()
            if self.searchBar then
                self.searchBar:Show()
            end
        end
    else
        if self.searchBar then
            self.searchBar:Hide()
        end
    end
end

function WM:OnEnable()
    -- Apply now if WorldMapFrame already exists, otherwise wait for the addon
    if WorldMapFrame then
        self:ApplySettings()
    else
        self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
    end
end

function WM:OnAddonLoaded(_, addonName)
    if addonName == "Blizzard_WorldMap" then
        self:UnregisterEvent("ADDON_LOADED")
        self:ApplySettings()
    end
end

function WM:OnDisable()
    self:RevertScale()
    if self.searchBar then
        self.searchBar:Hide()
    end
end
