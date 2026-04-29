-- VXJediEssentials FocusCastbar
-- Thin wrapper around CastbarBase. All castbar logic lives in CastbarBase.lua.
-- To modify castbar behavior, edit CastbarBase.lua — changes apply to both
-- TargetCastbar and FocusCastbar automatically.
---@class AE
local AE = select(2, ...)

local L = AE.L
if not VXJediEssentials then
    error("FocusCastbar: Addon object not initialized. Check file load order!")
    return
end

AE:CreateCastbarModule({
    moduleName   = "FocusCastbar",
    unit         = "focus",
    dbPath       = "FocusCastbar",
    frameName    = "AE_FocusCastbarFrame",
    changedEvent = "PLAYER_FOCUS_CHANGED",
    previewLabel = L["Focus Castbar"],
})
