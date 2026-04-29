-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
local Theme = AE.Theme

-- Custom dialog system: themed prompts and floating message popups.
--
-- Two public APIs:
--   AE:CreateMessagePopup(timer, text, fontSize, parent?, x?, y?)
--     Floating fade-in/fade-out toast. Used for "Copied!" style notifications.
--
--   AE:CreatePrompt(opts)
--     Themed dialog with header, message body, optional editbox, and accept/
--     cancel buttons. opts is a table with the following fields:
--
--       title         (string)   Header text. Default: "Confirm"
--       text          (string)   Message body, OR initial editbox text if
--                                showEditBox is true.
--       showEditBox   (boolean)  If true, displays an editbox containing
--                                opts.text instead of a static label.
--       editBoxLabel  (string)   Label shown below the editbox (only used
--                                when showEditBox is true).
--       onAccept      (function) Called when accept button or enter is pressed.
--                                Receives the editbox text as its arg if
--                                showEditBox is true.
--       onCancel      (function) Called when cancel button or escape is pressed.
--       acceptText    (string)   Accept button label. Default: "Accept"
--       cancelText    (string)   Cancel button label. Default: "Cancel"
--
--     If onAccept is omitted AND showEditBox is true, the dialog enters
--     "display only" mode (no buttons) — useful for showing a copyable
--     export string. Pressing Ctrl+C copies to clipboard and closes the dialog.

-- Localization
local CreateFrame = CreateFrame
local IsControlKeyDown = IsControlKeyDown
local IsMetaKeyDown = IsMetaKeyDown
local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut
local type = type
local UIParent = UIParent
local C_Timer = C_Timer

-- UI Constants
local POPUP_WIDTH = 360
local POPUP_HEIGHT = 120
local BUTTON_WIDTH = 100
local BUTTON_HEIGHT = 26
local MESSAGE_POPUP_SIZE = 64

-- Default theme color fallbacks (used if Theme isn't loaded yet)
local DEFAULT_BG_LIGHT      = { 0.15, 0.15, 0.15, 1 }
local DEFAULT_BG_MEDIUM     = { 0.10, 0.10, 0.10, 1 }
local DEFAULT_BORDER        = { 0.30, 0.30, 0.30, 1 }
local DEFAULT_ACCENT        = { 1.00, 0.82, 0.00, 1 }
local DEFAULT_TEXT_PRIMARY  = { 1.00, 1.00, 1.00, 1 }
local DEFAULT_TEXT_SECONDARY = { 0.70, 0.70, 0.70, 1 }

local function GetThemeColor(color, default)
    if not color or type(color) ~= "table" then return default end
    return color
end

------------------------------------------------------------------------
-- Floating message popup
------------------------------------------------------------------------
function AE:CreateMessagePopup(timer, text, fontSize, parentFrame, xOffset, yOffset)
    if AE.msgContainer then
        AE.msgContainer:Hide()
    end

    local parent = parentFrame or UIParent
    local x = xOffset or 0
    local y = yOffset or 250

    if not Theme then return end

    local msgContainer = CreateFrame("Frame", nil, parent)
    msgContainer:SetToplevel(true)
    msgContainer:SetFrameStrata("TOOLTIP")
    msgContainer:SetFrameLevel(150)
    msgContainer:SetSize(MESSAGE_POPUP_SIZE, MESSAGE_POPUP_SIZE)
    msgContainer:SetPoint("CENTER", parent, "CENTER", x, y)

    local msgText = msgContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    msgText:SetPoint("CENTER")
    msgText:SetText(text)
    msgText:SetFont(AE.FONT, fontSize, "")

    AE:ApplyFontToText(msgText, "Expressway", fontSize, "OUTLINE", {})

    local accent = GetThemeColor(Theme.accent, DEFAULT_ACCENT)
    msgText:SetTextColor(accent[1], accent[2], accent[3], 1)
    msgText:SetShadowColor(0, 0, 0, 0)

    UIFrameFadeIn(msgText, 0.2, 0, 1)
    msgContainer:Show()

    C_Timer.After(timer, function()
        UIFrameFadeOut(msgText, 1.5, 1, 0)
        C_Timer.After(1.6, function()
            msgContainer:Hide()
        end)
    end)

    AE.msgContainer = msgContainer
    return msgContainer
end

------------------------------------------------------------------------
-- Themed dialog prompt
------------------------------------------------------------------------

-- Create a themed button used by the prompt's accept/cancel actions
local function CreateThemedButton(parent, labelText, isPrimary)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    local bgMedium = GetThemeColor(Theme.bgMedium, DEFAULT_BG_MEDIUM)
    local bgLight  = GetThemeColor(Theme.bgLight, DEFAULT_BG_LIGHT)
    local border   = GetThemeColor(Theme.border, DEFAULT_BORDER)
    local accent   = GetThemeColor(Theme.accent, DEFAULT_ACCENT)
    local textPrimary = GetThemeColor(Theme.textPrimary, DEFAULT_TEXT_PRIMARY)
    local textColor = isPrimary and accent or textPrimary

    btn:SetBackdropColor(bgMedium[1], bgMedium[2], bgMedium[3], 1)
    btn:SetBackdropBorderColor(border[1], border[2], border[3], 1)

    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER")
    if AE.ApplyThemeFont then
        AE:ApplyThemeFont(label, "normal")
    else
        label:SetFontObject("GameFontNormal")
    end
    label:SetText(labelText)
    label:SetTextColor(textColor[1], textColor[2], textColor[3], 1)
    label:SetShadowColor(0, 0, 0, 0)
    btn.label = label

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(bgLight[1], bgLight[2], bgLight[3], 1)
        self:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
    end)

    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(bgMedium[1], bgMedium[2], bgMedium[3], 1)
        self:SetBackdropBorderColor(border[1], border[2], border[3], 1)
    end)

    return btn
end

function AE:CreatePrompt(opts)
    opts = opts or {}
    local title         = opts.title or "Confirm"
    local text          = opts.text or ""
    local showEditBox   = opts.showEditBox == true
    local editBoxLabel  = opts.editBoxLabel
    local onAccept      = opts.onAccept
    local onCancel      = opts.onCancel
    local acceptText    = opts.acceptText or "Accept"
    local cancelText    = opts.cancelText or "Cancel"

    -- Display-only mode: editbox shown but no accept callback (used for
    -- copyable export strings). Distinguished from a normal prompt by the
    -- absence of buttons.
    local displayOnly = showEditBox and not onAccept

    -- Close any previously open prompt
    if AE.activePrompt then
        AE.activePrompt:Hide()
        AE.activePrompt = nil
    end

    -- Resolve theme colors once
    local bgLight       = GetThemeColor(Theme.bgLight, DEFAULT_BG_LIGHT)
    local bgMedium      = GetThemeColor(Theme.bgMedium, DEFAULT_BG_MEDIUM)
    local border        = GetThemeColor(Theme.border, DEFAULT_BORDER)
    local accent        = GetThemeColor(Theme.accent, DEFAULT_ACCENT)
    local textPrimary   = GetThemeColor(Theme.textPrimary, DEFAULT_TEXT_PRIMARY)
    local textSecondary = GetThemeColor(Theme.textSecondary, DEFAULT_TEXT_SECONDARY)

    --------------------------------------------------------------------
    -- Outer dialog frame
    --------------------------------------------------------------------
    local dialog = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    dialog:SetSize(POPUP_WIDTH, POPUP_HEIGHT)
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    dialog:SetFrameStrata("TOOLTIP")
    dialog:SetFrameLevel(100)
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)

    dialog:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    dialog:SetBackdropColor(bgLight[1], bgLight[2], bgLight[3], bgLight[4] or 1)
    dialog:SetBackdropBorderColor(border[1], border[2], border[3], 1)

    --------------------------------------------------------------------
    -- Header (title + close button)
    --------------------------------------------------------------------
    local header = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    header:SetHeight(28)
    header:SetPoint("TOPLEFT", dialog, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -1, -1)
    header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    header:SetBackdropColor(bgMedium[1], bgMedium[2], bgMedium[3], 1)

    local headerBottomBorder = header:CreateTexture(nil, "BORDER")
    headerBottomBorder:SetHeight(Theme.borderSize or 1)
    headerBottomBorder:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    headerBottomBorder:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    headerBottomBorder:SetColorTexture(border[1], border[2], border[3], border[4] or 1)

    local titleLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleLabel:SetPoint("CENTER", header, "CENTER", 0, 0)
    titleLabel:SetText(title)
    titleLabel:SetTextColor(accent[1], accent[2], accent[3], accent[4] or 1)
    titleLabel:SetShadowColor(0, 0, 0, 0)

    -- Close button (top-right X)
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(17, 17)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)

    local closeTex = closeBtn:CreateTexture(nil, "ARTWORK")
    closeTex:SetAllPoints()
    closeTex:SetTexture("Interface\\AddOns\\VXJediEssentials\\Media\\GUITextures\\VXJediCustomCross.png")
    closeTex:SetVertexColor(textSecondary[1], textSecondary[2], textSecondary[3], 1)
    closeBtn:SetNormalTexture(closeTex)
    closeTex:SetTexelSnappingBias(0)
    closeTex:SetSnapToPixelGrid(false)

    closeBtn:SetScript("OnEnter", function()
        closeTex:SetVertexColor(accent[1], accent[2], accent[3], accent[4] or 1)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeTex:SetVertexColor(textSecondary[1], textSecondary[2], textSecondary[3], 1)
    end)
    closeBtn:SetScript("OnClick", function()
        if onCancel then onCancel() end
        dialog:Hide()
        AE.activePrompt = nil
    end)

    --------------------------------------------------------------------
    -- Body: either a static message label or an editbox
    --------------------------------------------------------------------
    if not showEditBox then
        local messageLabel = dialog:CreateFontString(nil, "OVERLAY")
        messageLabel:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 12, -12)
        messageLabel:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -12, -12)
        messageLabel:SetJustifyH("CENTER")
        messageLabel:SetJustifyV("TOP")
        if AE.ApplyThemeFont then
            AE:ApplyThemeFont(messageLabel, "normal")
        else
            messageLabel:SetFontObject("GameFontNormal")
        end
        messageLabel:SetText(text)
        messageLabel:SetTextColor(textPrimary[1], textPrimary[2], textPrimary[3], 1)
        messageLabel:SetShadowColor(0, 0, 0, 0)
    else
        local editBox = CreateFrame("EditBox", nil, dialog, "BackdropTemplate")
        editBox:SetSize(dialog:GetWidth() - 24, 24)
        editBox:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 12, -12)
        editBox:SetAutoFocus(true)
        editBox:SetText(text)
        editBox:SetJustifyH("CENTER")

        editBox:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        editBox:SetBackdropColor(bgMedium[1], bgMedium[2], bgMedium[3], 1)
        editBox:SetBackdropBorderColor(border[1], border[2], border[3], 1)
        if AE.ApplyThemeFont then
            AE:ApplyThemeFont(editBox, "normal")
        else
            editBox:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        end
        editBox:SetTextColor(textPrimary[1], textPrimary[2], textPrimary[3], 1)
        editBox:SetShadowColor(0, 0, 0, 0)

        editBox:HighlightText()

        if displayOnly then
            -- Display only: Ctrl+C copies and closes
            editBox:SetScript("OnKeyDown", function(self, key)
                if key == "C" and (IsControlKeyDown() or IsMetaKeyDown()) then
                    AE:CreateMessagePopup(2, "Copied to clipboard", 18, UIParent, 0, 350)
                    if onCancel then onCancel() end
                    dialog:Hide()
                    AE.activePrompt = nil
                end
            end)
        else
            -- Editable: Enter submits with the current text
            editBox:SetScript("OnEnterPressed", function(self)
                onAccept(self:GetText())
                dialog:Hide()
                AE.activePrompt = nil
            end)
        end

        editBox:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
        end)
        editBox:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(border[1], border[2], border[3], 1)
        end)

        if editBoxLabel then
            local labelFontString = dialog:CreateFontString(nil, "OVERLAY")
            labelFontString:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 12, -12)
            labelFontString:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT", -12, -12)
            labelFontString:SetJustifyH("CENTER")
            labelFontString:SetJustifyV("TOP")
            if AE.ApplyThemeFont then
                AE:ApplyThemeFont(labelFontString, "normal")
            else
                labelFontString:SetFontObject("GameFontNormal")
            end
            labelFontString:SetText(editBoxLabel)
            labelFontString:SetTextColor(textSecondary[1], textSecondary[2], textSecondary[3], 1)
            labelFontString:SetShadowColor(0, 0, 0, 0)
        end

        dialog.editBox = editBox
    end

    --------------------------------------------------------------------
    -- Accept / Cancel buttons (omitted in displayOnly mode)
    --------------------------------------------------------------------
    if not displayOnly then
        local buttonContainer = CreateFrame("Frame", nil, dialog)
        buttonContainer:SetHeight(30)
        buttonContainer:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 12, 12)
        buttonContainer:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -12, 12)

        local acceptBtn = CreateThemedButton(buttonContainer, acceptText, true)
        acceptBtn:SetPoint("RIGHT", buttonContainer, "CENTER", -4, 0)
        acceptBtn:SetScript("OnClick", function()
            if onAccept then
                if showEditBox and dialog.editBox then
                    onAccept(dialog.editBox:GetText())
                else
                    onAccept()
                end
            end
            dialog:Hide()
            AE.activePrompt = nil
        end)

        local cancelBtn = CreateThemedButton(buttonContainer, cancelText, false)
        cancelBtn:SetPoint("LEFT", buttonContainer, "CENTER", 4, 0)
        cancelBtn:SetScript("OnClick", function()
            if onCancel then onCancel() end
            dialog:Hide()
            AE.activePrompt = nil
        end)
    end

    --------------------------------------------------------------------
    -- Escape key handling
    --------------------------------------------------------------------
    dialog:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:SetPropagateKeyboardInput(false)
            if onCancel then onCancel() end
            self:Hide()
            AE.activePrompt = nil
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    dialog:EnableKeyboard(true)

    dialog:Show()
    AE.activePrompt = dialog

    return dialog
end
