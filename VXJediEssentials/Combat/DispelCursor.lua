-- VXJediEssentials Dispel on Cursor
-- Shows dispel cooldown timer that follows your cursor
---@class AE
local AE = select(2, ...)

if not VXJediEssentials then return end

---@class DispelCursor: AceModule, AceEvent-3.0
local DC = VXJediEssentials:NewModule("DispelCursor", "AceEvent-3.0")

-- Localization
local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local C_Spell = C_Spell
local C_SpellBook = C_SpellBook
local UIParent = UIParent
local ipairs = ipairs

-- Dispel spell IDs per class (player spellbook)
local DISPEL_SPELL_IDS = {
    -- Healer dispels
    115450, -- Detox (Monk - MW)
    4987,   -- Cleanse (Paladin - Holy)
    527,    -- Purify (Priest - Holy/Disc)
    360823, -- Naturalize (Evoker - Preservation)
    88423,  -- Nature's Cure (Druid - Restoration)
    77130,  -- Purify Spirit (Shaman - Restoration)
    -- DPS/Tank dispels
    213634, -- Purify Disease (Priest - Shadow)
    218164, -- Detox (Monk - WW/BM)
    213644, -- Cleanse Toxins (Paladin - Ret/Prot)
    2782,   -- Remove Corruption (Druid - Balance/Feral)
    475,    -- Remove Curse (Mage)
    365585, -- Expunge (Evoker - Devastation/Augmentation)
    51886,  -- Cleanse Spirit (Shaman - Elemental/Enhancement)
}

-- Pet dispel spell IDs (Warlock imp/familiar)
local PET_DISPEL_SPELL_IDS = {
    89808, -- Singe Magic (Imp / Fel Imp)
}

DC.frame = nil
DC.trackedSpellId = nil
DC.cachedScale = 1
DC.onUpdateActive = false

function DC:UpdateDB()
    self.db = AE.db.profile.DispelCursor
end

function DC:OnInitialize()
    self:UpdateDB()
    self:SetEnabledState(false)
end

------------------------------------------------------------------------
-- Spell detection
------------------------------------------------------------------------
function DC:FindDispelSpell()
    self.trackedSpellId = nil

    -- Check player spellbook
    for _, spellID in ipairs(DISPEL_SPELL_IDS) do
        if C_SpellBook.IsSpellInSpellBook(spellID) then
            self.trackedSpellId = spellID
            return
        end
    end

    -- Check pet spellbook (e.g. Singe Magic on Warlock imp)
    for _, spellID in ipairs(PET_DISPEL_SPELL_IDS) do
        if C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Pet) then
            self.trackedSpellId = spellID
            return
        end
    end
end

------------------------------------------------------------------------
-- OnUpdate (cursor following) — only attached when actually needed
------------------------------------------------------------------------
local function CursorFollowOnUpdate(frame)
    local sdb = DC.db
    local x, y = GetCursorPosition()
    local scale = DC.cachedScale
    local cooldownText = frame.cooldownText
    cooldownText:ClearAllPoints()
    cooldownText:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
        (x / scale) + (sdb.XOffset or 10),
        (y / scale) + (sdb.YOffset or 10))
end

function DC:StartCursorFollow()
    if self.onUpdateActive or not self.frame then return end
    self.frame:SetScript("OnUpdate", CursorFollowOnUpdate)
    self.onUpdateActive = true
end

function DC:StopCursorFollow()
    if not self.onUpdateActive or not self.frame then return end
    self.frame:SetScript("OnUpdate", nil)
    self.onUpdateActive = false
end

------------------------------------------------------------------------
-- Cooldown update — also manages OnUpdate lifecycle
--
-- Taint note: we intentionally avoid testing `duration:IsZero()` in a
-- raw if/not. In Midnight, duration objects from C_Spell.GetSpellCooldownDuration
-- return tainted booleans from IsZero(), and testing them directly throws
-- "attempt to perform boolean test on a secret boolean value". Instead we:
--   1. Always call SetCooldownFromDurationObject (taint-safe, handles
--      zero durations by rendering nothing)
--   2. Keep the cursor follow OnUpdate attached while we have a tracked
--      spell. The OnUpdate is cheap (one SetPoint per frame), and when
--      the dispel is ready the Blizzard Cooldown frame template hides
--      its own countdown text automatically — so the cursor follow just
--      tracks an invisible FontString, which is harmless.
------------------------------------------------------------------------
function DC:UpdateCooldown()
    if not self.frame then return end
    local cooldownFrame = self.frame.cooldownFrame

    if not self.trackedSpellId then
        cooldownFrame:Clear()
        self:StopCursorFollow()
        return
    end

    local duration = C_Spell.GetSpellCooldownDuration(self.trackedSpellId)
    if not duration then
        cooldownFrame:Clear()
        self:StopCursorFollow()
        return
    end

    cooldownFrame:SetCooldownFromDurationObject(duration, false)
    self:StartCursorFollow()
end

------------------------------------------------------------------------
-- Frame creation
------------------------------------------------------------------------
function DC:CreateFrame()
    if self.frame then return end

    local frame = CreateFrame("Frame", "AE_DispelCursorFrame", UIParent)
    frame:SetFrameStrata("TOOLTIP")

    local cooldownFrame = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    cooldownFrame:SetSize(1, 1)
    cooldownFrame:SetDrawSwipe(false)
    cooldownFrame:SetDrawEdge(false)
    cooldownFrame:SetDrawBling(false)
    cooldownFrame:SetHideCountdownNumbers(false)

    local cooldownText
    for _, region in ipairs({ cooldownFrame:GetRegions() }) do
        if region:GetObjectType() == "FontString" then
            cooldownText = region
            break
        end
    end

    if not cooldownText then
        cooldownText = cooldownFrame:CreateFontString(nil, "OVERLAY")
    end

    frame.cooldownFrame = cooldownFrame
    frame.cooldownText = cooldownText

    self.frame = frame

    -- Cache the UI scale and listen for changes
    self.cachedScale = UIParent:GetEffectiveScale()

    -- Apply font/color settings now that the frame exists
    self:ApplySettings()

    frame:Show()
end

------------------------------------------------------------------------
-- Settings
------------------------------------------------------------------------
function DC:ApplySettings()
    if not self.frame or not self.frame.cooldownText then return end
    local db = self.db
    self.frame.cooldownText:SetFont(AE.FONT, db.FontSize or 18, "OUTLINE")
    local c = db.TextColor or { 1, 1, 1, 1 }
    self.frame.cooldownText:SetTextColor(c[1], c[2], c[3], c[4] or 1)
end

------------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------------
function DC:OnSpellbookChanged()
    self:FindDispelSpell()
    self:UpdateCooldown()
end

function DC:OnUnitPet(_, unit)
    if unit ~= "player" then return end
    self:FindDispelSpell()
    self:UpdateCooldown()
end

function DC:OnSpellCooldown()
    self:UpdateCooldown()
end

function DC:OnUIScaleChanged()
    self.cachedScale = UIParent:GetEffectiveScale()
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function DC:OnEnable()
    if not self.db.Enabled then return end
    self:CreateFrame()
    self:FindDispelSpell()
    self:UpdateCooldown()

    -- Module-level events (AceEvent dispatch)
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnSpellCooldown")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnSpellbookChanged")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnSpellbookChanged")
    self:RegisterEvent("SPELLS_CHANGED", "OnSpellbookChanged")
    self:RegisterEvent("UNIT_PET", "OnUnitPet")
    self:RegisterEvent("UI_SCALE_CHANGED", "OnUIScaleChanged")
end

function DC:OnDisable()
    self:UnregisterAllEvents()
    self:StopCursorFollow()
    if self.frame then
        self.frame.cooldownFrame:Clear()
        self.frame:Hide()
    end
end

------------------------------------------------------------------------
-- Preview / public refresh
------------------------------------------------------------------------
function DC:ShowPreview()
    if not self.frame then
        self:CreateFrame()
    end
    self:ApplySettings()
    self.frame:Show()
    self:StartCursorFollow()
end

function DC:HidePreview()
    if not self.frame then return end
    if not self.db or not self.db.Enabled then
        self:StopCursorFollow()
        self.frame:Hide()
    else
        -- If module is enabled, return to normal cooldown-driven behavior
        self:UpdateCooldown()
    end
end

function DC:Refresh()
    self:UpdateDB()
    self:ApplySettings()
end
