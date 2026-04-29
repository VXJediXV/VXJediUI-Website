-- VXJediEssentials — Custom ElvUI Tags
-- Registers custom tags with ElvUI if present.
---@class AE
local AE = select(2, ...)

-- Only load if ElvUI is present
if not ElvUI then return end

local E = unpack(ElvUI)
local ElvUF = _G.ElvUF

-- Locals
local UnitName = UnitName
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitInPartyIsAI = UnitInPartyIsAI
local format = string.format

local ElvUF_colors_class = ElvUF.colors.class
local ElvUF_colors_reaction = ElvUF.colors.reaction

local function Hex(r, g, b)
    return format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
end

local function GetUnitColor(unit)
    if UnitIsPlayer(unit) or (UnitInPartyIsAI and UnitInPartyIsAI(unit)) then
        local _, unitClass = UnitClass(unit)
        if unitClass then
            local cs = ElvUF_colors_class[unitClass]
            if cs then
                return Hex(cs.r, cs.g, cs.b)
            end
        end
    else
        local reaction = UnitReaction(unit, 'player')
        if reaction then
            local cr = ElvUF_colors_reaction[reaction]
            if cr then
                return Hex(cr.r, cr.g, cr.b)
            end
        end
    end
    return '|cFFcccccc'
end

-- [aes:target:name-classcolor]
-- Displays the unit's target name colored by class (players) or reaction (NPCs)
E:AddTag('aes:target:name-classcolor', 'UNIT_TARGET UNIT_FACTION', function(unit)
    local targetUnit = unit .. 'target'
    local name = UnitName(targetUnit)
    if not name then return end

    return GetUnitColor(targetUnit) .. name
end)
E:AddTagInfo('aes:target:name-classcolor', 'VXJediEssentials', "Displays the unit's target name with class/reaction color")
