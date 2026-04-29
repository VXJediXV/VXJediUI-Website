-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

---@type VXJediEssentials
local VXJediEssentials = _G.VXJediEssentials

-- Check for addon object
local L = AE.L
if not VXJediEssentials then
    error("PositionController: Addon object not initialized. Check file load order!")
    return
end

-- Create module
---@class PositionController: AceModule, AceEvent-3.0
local PC = VXJediEssentials:NewModule("PositionController", "AceEvent-3.0")

-- Localization
local _G = _G
local InCombatLockdown = InCombatLockdown
local C_Timer = C_Timer
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local wipe = wipe

-- Constants
local DEFAULT_CDM_PET_OFFSET = -40

------------------------------------------------------------------------
-- Healer spec detection
--
-- This module is a no-op on healer specs. The user configures static
-- positions for their healer frames via ElvUI profiles, and we stay out
-- of the way. GetSpecializationRole is future-proof: any new healer spec
-- Blizzard adds will be handled automatically without code changes.
------------------------------------------------------------------------
local function IsHealerSpec()
    local specIndex = GetSpecialization()
    if not specIndex then return false end
    return GetSpecializationRole(specIndex) == "HEALER"
end

------------------------------------------------------------------------
-- Frame reference cache (Unit Frame Anchoring)
--
-- Sub-tables are pre-initialized at file load so CacheFrames never has
-- to create them. ApplyLayout reads directly from cache.frames.<Feature>
-- with zero _G lookups in the hot path.
------------------------------------------------------------------------
local cache = {
    essential = nil,
    utility   = nil,
    frames = {
        PlayerFrame = { uf = nil, mover = nil },
        TargetFrame = { uf = nil, mover = nil },
        PetFrame    = { uf = nil, mover = nil },
    },
}

local function CacheFrames()
    cache.essential = _G.EssentialCooldownViewer
    cache.utility   = _G.UtilityCooldownViewer

    local frames = cache.frames
    local f

    f = frames.PlayerFrame
    f.uf    = _G.ElvUF_Player
    f.mover = _G.ElvUF_PlayerMover

    f = frames.TargetFrame
    f.uf    = _G.ElvUF_Target
    f.mover = _G.ElvUF_TargetMover

    f = frames.PetFrame
    f.uf    = _G.ElvUF_Pet
    f.mover = _G.ElvUF_PetMover
end

------------------------------------------------------------------------
-- Collision offset (Unit Frame Anchoring)
--
-- When the user anchors a unit frame to the Essential cooldown row and
-- the Utility cooldown row below it is wider, nudge the unit frame
-- further out so it doesn't overlap the wider utility row. Player frame
-- nudges left, target frame nudges right.
--
-- Accepts either Blizzard's raw EssentialCooldownViewer or Ayije's CDM
-- wrapper (EssentialCooldownViewer_CDM_Container). The CDM container
-- mirrors the viewer's width, so either name is a valid collision trigger.
------------------------------------------------------------------------
local ESSENTIAL_PARENTS = {
    ["EssentialCooldownViewer"]              = true,
    ["EssentialCooldownViewer_CDM_Container"] = true,
}

local function GetCollisionXOffset(featureKey, baseX, parentName)
    if not ESSENTIAL_PARENTS[parentName] then return baseX end
    local essential = cache.essential
    local utility   = cache.utility
    if not (essential and utility) then return baseX end

    local eWidth = essential:GetWidth()
    local uWidth = utility:GetWidth()
    if uWidth <= eWidth then return baseX end

    local extra = (uWidth - eWidth) / 2
    if featureKey == "PlayerFrame" then
        return baseX - extra
    elseif featureKey == "TargetFrame" then
        return baseX + extra
    end
    return baseX
end

------------------------------------------------------------------------
-- Missing-parent warning cache
--
-- When a SELECTFRAME-type feature can't resolve its parent, we print a
-- one-shot warning keyed by (featureKey, parentName) so the user knows
-- why a frame isn't moving. The cache prevents spamming the chat on
-- every ApplyLayout call. Cleared on ApplySettings so that fixing the
-- parent in the GUI can re-surface a warning if the new value is also
-- missing.
------------------------------------------------------------------------
local warnedMissingParent = {}

local function WarnMissingParent(featureKey, parentName)
    local key = featureKey .. "\0" .. parentName
    if warnedMissingParent[key] then return end
    warnedMissingParent[key] = true
    AE:Print("Position Controller: parent frame '" .. parentName ..
             "' not found, " .. featureKey .. " anchor skipped")
end

------------------------------------------------------------------------
-- Restore a feature's frame and mover to the position ElvUI's current
-- profile says it should be at, by calling E:SetMoverPoints(name, parent).
--
-- This is ElvUI's canonical "apply this mover's saved position" function.
-- Tracing through ElvUI's Movers.lua:
--   1. Reads E.db.movers[name] (whatever profile is currently active)
--   2. Falls back to E:GetMoverLayout(name) if the user has never moved it
--   3. Sets the mover's anchor to that position
--   4. Re-anchors the unit frame to its mover via parent:SetPoint(...)
--      using the original ElvUI frame-to-mover anchor convention
--
-- Why this beats a snapshot/restore approach:
--   * Profile-aware: per-spec ElvUI profiles, manual profile switches,
--     /reload, character swaps — all handled by ElvUI's own state. We
--     never have to track "what was the original position".
--   * Multi-anchor safe: ElvUI manages whatever anchor convention it
--     uses internally, including anything multi-point.
--   * Correct on healer switch even if our DPS profile and healer
--     profile have completely different mover positions saved.
--
-- Programmatic SetPoint calls don't trigger ElvUI's SaveMoverPosition
-- (only drag-end and the config UI do), so E.db.movers always holds
-- the user's intended position regardless of what we've overridden.
------------------------------------------------------------------------
local function RestoreOriginalAnchor(featureKey)
    local refs = cache.frames[featureKey]
    if not refs or not refs.uf or not refs.mover then return end

    local elvui = _G.ElvUI
    if not elvui then return end
    local E = elvui[1]
    if not E or not E.SetMoverPoints then return end

    local moverName = refs.mover:GetName()
    if not moverName then return end

    E:SetMoverPoints(moverName, refs.uf)
end

local function RestoreAllAnchors()
    RestoreOriginalAnchor("PlayerFrame")
    RestoreOriginalAnchor("TargetFrame")
    RestoreOriginalAnchor("PetFrame")
end

------------------------------------------------------------------------
-- Apply a single feature's position to its unit frame + mover
--
-- When anchorFrameType is SELECTFRAME and the named parent frame does
-- not exist in _G (e.g. the user anchored to a frame created by another
-- addon that isn't currently installed or loaded), we skip this feature
-- entirely. The unit frame stays wherever ElvUI last placed it. We do
-- NOT fall back to UIParent because that silently dumps the frame in
-- an unexpected spot — the offsets the user configured are meaningful
-- only relative to the target frame they chose.
--
-- If the feature is toggled off, we ask ElvUI to re-apply its saved
-- profile position for this mover, so the frame returns to where the
-- user wants it instead of being stuck in our override spot.
------------------------------------------------------------------------
local function ApplyFeature(featureKey, subDB)
    local refs = cache.frames[featureKey]
    if not refs or not refs.uf then return end

    -- Feature is off — let ElvUI restore the user's profile position
    if not subDB or not subDB.Enabled then
        RestoreOriginalAnchor(featureKey)
        return
    end

    -- Resolve parent. SELECTFRAME does a direct lookup and bails on miss;
    -- SCREEN/UIPARENT use UIParent as the intended target.
    local parent
    if subDB.anchorFrameType == "SELECTFRAME" then
        local parentName = subDB.ParentFrame
        parent = parentName and _G[parentName]
        if not parent then
            if parentName then
                WarnMissingParent(featureKey, parentName)
            end
            return
        end
    else
        parent = _G.UIParent
    end

    local pos = subDB.Position
    if not pos then return end

    local fromPoint = pos.AnchorFrom or "CENTER"
    local toPoint   = pos.AnchorTo   or "CENTER"
    local x         = pos.XOffset    or 0
    local y         = pos.YOffset    or 0

    -- Apply collision offset when anchored to EssentialCooldownViewer
    x = GetCollisionXOffset(featureKey, x, subDB.ParentFrame)

    refs.uf:ClearAllPoints()
    refs.uf:SetPoint(fromPoint, parent, toPoint, x, y)

    local mover = refs.mover
    if mover then
        mover:ClearAllPoints()
        mover:SetPoint(fromPoint, parent, toPoint, x, y)
    end
end

------------------------------------------------------------------------
-- Main layout application (Unit Frame Anchoring)
------------------------------------------------------------------------
function PC:ApplyLayout()
    if InCombatLockdown() then return end
    if IsHealerSpec() then return end
    local db = self.db
    if not db.Enabled then return end
    if not _G.ElvUI then return end

    ApplyFeature("PlayerFrame", db.PlayerFrame)
    ApplyFeature("TargetFrame", db.TargetFrame)
    ApplyFeature("PetFrame",    db.PetFrame)
end

------------------------------------------------------------------------
-- Debounced apply: coalesce multiple events in the same frame
------------------------------------------------------------------------
local pending = false

function PC:QueueApply()
    if pending then return end
    pending = true
    C_Timer.After(0, function()
        pending = false
        PC:ApplyLayout()
    end)
end

------------------------------------------------------------------------
-- Hook cooldown viewer size changes
--
-- The OnSizeChanged script fires only when the frame actually resizes —
-- this is the authoritative signal that triggers layout updates without
-- any polling. Hooks persist for the session; on module disable, the
-- callback goes through QueueApply → ApplyLayout, which early-returns.
------------------------------------------------------------------------
local function OnViewerResized()
    PC:QueueApply()
end

function PC:HookViewerSizes()
    local essential = cache.essential
    local utility   = cache.utility

    if essential and not essential._aePositionHooked then
        essential:HookScript("OnSizeChanged", OnViewerResized)
        essential._aePositionHooked = true
    end

    if utility and not utility._aePositionHooked then
        utility:HookScript("OnSizeChanged", OnViewerResized)
        utility._aePositionHooked = true
    end
end

------------------------------------------------------------------------
-- CDM Racials hook
--
-- Hooks Ayije's Cooldown Manager to nudge the Racials container up when
-- a pet bar is showing, so it doesn't collide with pet actions. Only
-- affects the CDM_RacialsContainer — all other CDM anchoring is passed
-- through unchanged.
--
-- The hook is installed once per session (hooks can't be un-installed)
-- and gates its behavior on: master Enabled, feature Enabled, non-healer
-- spec, and pet frame visible. Any one of those being false makes the
-- hook a pass-through.
------------------------------------------------------------------------
local cdmHooked = false

function PC:TryInstallCDMHook()
    if cdmHooked then return true end

    local CDM = _G.Ayije_CDM
    if not CDM or not CDM.AnchorToPlayerFrame then return false end

    local originalAnchor = CDM.AnchorToPlayerFrame

    CDM.AnchorToPlayerFrame = function(container, anchorPoint, offsetX, offsetY, moduleName, forceRefresh, containerAnchor)
        if container and container:GetName() == "CDM_RacialsContainer" then
            local db = PC.db
            if db and db.Enabled and not IsHealerSpec()
                and db.CDMRacials and db.CDMRacials.Enabled then
                local petFrame = _G.ElvUF_Pet
                if petFrame and petFrame:IsShown() then
                    offsetY = (offsetY or 0) + (db.CDMRacials.PetClassOffset or DEFAULT_CDM_PET_OFFSET)
                end
            end
        end
        return originalAnchor(container, anchorPoint, offsetX, offsetY, moduleName, forceRefresh, containerAnchor)
    end

    cdmHooked = true
    return true
end

-- Force CDM to re-anchor the racials container (used when pet shows/hides)
local function ForceRacialsReanchor()
    local CDM = _G.Ayije_CDM
    if not CDM or not CDM.InvalidateTrackerAnchorCache or not CDM.ScheduleTrackerPositionRefresh then return end
    local container = _G.CDM_RacialsContainer
    if not container then return end
    CDM.InvalidateTrackerAnchorCache(container)
    CDM.ScheduleTrackerPositionRefresh()
end

-- Attach hooks to ElvUI's pet frame so we react to show/hide
local petWatcherAttached = false

function PC:AttachPetWatcher()
    if petWatcherAttached then return end
    local petFrame = _G.ElvUF_Pet
    if not petFrame then return end

    petFrame:HookScript("OnShow", ForceRacialsReanchor)
    petFrame:HookScript("OnHide", ForceRacialsReanchor)
    petWatcherAttached = true
end

------------------------------------------------------------------------
-- Module lifecycle
------------------------------------------------------------------------
function PC:UpdateDB()
    self.db = AE.db.profile.Miscellaneous.PositionController
end

function PC:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

function PC:OnPlayerEnteringWorld()
    CacheFrames()
    self:HookViewerSizes()
    -- Also retry CDM hook install and pet watcher in case they weren't
    -- available at OnEnable time (CDM or ElvUI loaded later than us).
    self:TryInstallCDMHook()
    self:AttachPetWatcher()
    self:QueueApply()
end

-- Register the "normal operation" events and do initial setup.
-- Called on module enable and when switching to a non-healer spec.
function PC:ActivateForSpec()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("TRAIT_CONFIG_UPDATED", "QueueApply")
    self:RegisterEvent("SPELLS_CHANGED", "QueueApply")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "QueueApply")

    self:OnPlayerEnteringWorld()
end

-- Unregister the unit-frame-anchoring events and restore the original
-- frame positions so ElvUI's profile positions come back through. The
-- CDM Racials feature's events (PLAYER_SPECIALIZATION_CHANGED,
-- ADDON_LOADED, UNIT_PET) stay registered so the CDM hook retry + pet
-- watcher logic continues on all specs.
function PC:DeactivateForHealerSpec()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("TRAIT_CONFIG_UPDATED")
    self:UnregisterEvent("SPELLS_CHANGED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")

    RestoreAllAnchors()
end

function PC:OnSpecChanged()
    if IsHealerSpec() then
        self:DeactivateForHealerSpec()
    else
        self:ActivateForSpec()
    end
end

-- ADDON_LOADED handler: retry CDM hook install when Ayije_CDM loads
function PC:OnAddonLoaded(_, addonName)
    if addonName ~= "Ayije_CDM" then return end
    if self:TryInstallCDMHook() then
        self:UnregisterEvent("ADDON_LOADED")
    end
end

-- UNIT_PET handler: re-attempt pet watcher attach if the pet frame was
-- created after our initial attach attempt
function PC:OnUnitPet(_, unit)
    if unit ~= "player" then return end
    self:AttachPetWatcher()
end

function PC:OnEnable()
    if not _G.ElvUI then
        AE:Print(L["Position Controller requires ElvUI to be enabled."])
        return
    end

    -- Spec change listener is always active so we can toggle in and out
    -- of healer specs dynamically.
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnSpecChanged")

    -- CDM Racials feature events (always registered; the hook checks
    -- db.CDMRacials.Enabled internally)
    self:RegisterEvent("UNIT_PET", "OnUnitPet")
    if not self:TryInstallCDMHook() then
        self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
    end
    self:AttachPetWatcher()

    -- Unit frame anchoring: only activate on non-healer specs
    if not IsHealerSpec() then
        self:ActivateForSpec()
    end
end

function PC:OnDisable()
    self:UnregisterAllEvents()
    RestoreAllAnchors()
    -- Note: we cannot un-hook OnSizeChanged, the CDM hook, or the pet
    -- watcher. All of those check self.db.Enabled internally (or go
    -- through QueueApply → ApplyLayout which checks it), so disabling
    -- the module makes every persistent hook a no-op.
end

-- Public hook for GUI to re-apply after settings change
function PC:ApplySettings()
    -- Clear the missing-parent warning cache so that if the user fixes a
    -- parent in the GUI and the new value is also missing, we re-warn.
    wipe(warnedMissingParent)
    self:UpdateDB()
    self:QueueApply()
    -- The CDM hook reads self.db on each call, so settings changes for
    -- the CDM racials feature take effect on the next CDM re-anchor.
    -- Force one now so GUI slider changes feel immediate.
    ForceRacialsReanchor()
end
