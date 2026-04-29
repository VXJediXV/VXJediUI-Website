-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

local L = AE.L
function AE.GUIFrame:CreateSpacer(parent, height)
    height = height or 16
    local spacer = CreateFrame("Frame", nil, parent)
    spacer:SetHeight(height)
    return spacer
end


