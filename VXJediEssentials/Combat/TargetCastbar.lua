-- VXJediEssentials TargetCastbar
-- Thin wrapper around CastbarBase. All castbar logic lives in CastbarBase.lua.
-- To modify castbar behavior, edit CastbarBase.lua — changes apply to both
-- TargetCastbar and FocusCastbar automatically.
---@class AE
local AE = select(2, ...)

local L = AE.L
if not VXJediEssentials then
    error("TargetCastbar: Addon object not initialized. Check file load order!")
    return
end

AE:CreateCastbarModule({
    moduleName   = "TargetCastbar",
    unit         = "target",
    dbPath       = "TargetCastbar",
    frameName    = "AE_TargetCastbarFrame",
    changedEvent = "PLAYER_TARGET_CHANGED",
    previewLabel = L["Target Castbar"],
})
