-- VXJediEssentials English Locale (Default)
-- This file defines ALL locale keys. Other locales only override what they translate.
---@class AE
local AE = select(2, ...)

-- Initialize locale table (English is always the base)
AE.L = {}
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "On"
L["Off"] = "Off"
L["Enabled"] = "Enabled"
L["Disabled"] = "Disabled"
L["Enable Module"] = "Enable Module"
L["Error"] = "Error"
L["Note"] = "Note"
L["Show"] = "Show"
L["Coming Soon"] = "Coming Soon"
L["Database not available"] = "Database not available"
L["None"] = "None"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "Combat"
L["Interface"] = "Interface"
L["Optimize"] = "Optimize"
L["Profiles"] = "Profiles"
L["Quality of Life"] = "Quality of Life"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "Combat Timer"
L["Combat Cross"] = "Combat Cross"
L["Combat Texts"] = "Combat Texts"
L["Pet Status Texts"] = "Pet Status Texts"
L["Focus Castbar"] = "Focus Castbar"
L["Target Castbar"] = "Target Castbar"
L["Castbars"] = "Castbars"
L["Gateway Alert"] = "Gateway Alert"
L["Automation"] = "Automation"
L["Copy Anything"] = "Copy Anything"
L["Cursor Circle"] = "Cursor Circle"
L["System Optimization"] = "System Optimization"
L["Profile Manager"] = "Profile Manager"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Welcome to VXJediEssentials"] = "Welcome to VXJediEssentials"
L["Getting Started"] = "Getting Started"
L["Support"] = "Support"
L["Based on work provided by |cffffffffNorsken|r"] = "Based on work provided by |cffffffffNorsken|r"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "Enable Combat Timer"
L["Print Combat Duration to Chat"] = "Print Combat Duration to Chat"
L["Combat lasted "] = "Combat lasted "
L["Format"] = "Format"
L["Bracket Style"] = "Bracket Style"
L["Font Size"] = "Font Size"
L["Font"] = "Font"
L["Font Outline"] = "Font Outline"
L["Font Settings"] = "Font Settings"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "Enable Combat Cross"
L["Size"] = "Size"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "This is a static crosshair overlay and will not adjust with camera panning."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "Enable Combat Messages"
L["Combat Res Tracker"] = "Combat Res Tracker"
L["Enable Combat Res Tracker"] = "Enable Combat Res Tracker"
L["Enter Combat Message"] = "Enter Combat Message"
L["Exit Combat Message"] = "Exit Combat Message"
L["Low Durability Warning"] = "Low Durability Warning"
L["- COMBAT -"] = "- COMBAT -"
L["LOW DURABILITY"] = "LOW DURABILITY"
L["Message Spacing"] = "Message Spacing"
L["Text"] = "Text"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "Enable Pet Status Texts"
L["PET DEAD"] = "PET DEAD"
L["PET MISSING"] = "PET MISSING"
L["PET PASSIVE"] = "PET PASSIVE"
L["Pet Dead Text"] = "Pet Dead Text"
L["Pet Missing Text"] = "Pet Missing Text"
L["Pet Passive Text"] = "Pet Passive Text"
L["Dead Color"] = "Dead Color"
L["Missing Color"] = "Missing Color"
L["Passive Color"] = "Passive Color"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "Enable Focus Castbar"
L["Enable Target Castbar"] = "Enable Target Castbar"
L["Bar Height"] = "Bar Height"
L["Bar Texture"] = "Bar Texture"
L["Width"] = "Width"
L["Height"] = "Height"
L["Casting"] = "Casting"
L["Channeling"] = "Channeling"
L["Empowering"] = "Empowering"
L["Not Interruptible"] = "Not Interruptible"
L["Interrupted"] = "Interrupted"
L["Cast Success"] = "Cast Success"
L["Colors"] = "Colors"
L["Hold Timer"] = "Hold Timer"
L["Enable Hold Timer"] = "Enable Hold Timer"
L["Hold Duration"] = "Hold Duration"
L["Kick Indicator"] = "Kick Indicator"
L["Enable Kick Indicator"] = "Enable Kick Indicator"
L["Kick Ready Tick"] = "Kick Ready Tick"
L["Kick Not Ready"] = "Kick Not Ready"
L["Hide Non-Interruptible Casts"] = "Hide Non-Interruptible Casts"
L["Timer Text Color"] = "Timer Text Color"
L["Enable Shadow"] = "Enable Shadow"
L["Shadow Color"] = "Shadow Color"
L["Shadow X Offset"] = "Shadow X Offset"
L["Shadow Y Offset"] = "Shadow Y Offset"
L["Shadow X"] = "Shadow X"
L["Shadow Y"] = "Shadow Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "Enable Hunters Mark Tracking"
L["Hunters Mark Tracking"] = "Hunters Mark Tracking"
L["MISSING MARK"] = "MISSING MARK"
L["This module only works inside raid instances and while out of combat."] = "This module only works inside raid instances and while out of combat."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "Enable Gateway Alert"
L["Gateway Usable Alert"] = "Gateway Usable Alert"
L["GATE USABLE"] = "GATE USABLE"
L["Alert Color"] = "Alert Color"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Stance Text Display"] = "Stance Text Display"
L["Enable Stance Text"] = "Enable Stance Text"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "Enable Automation"
L["Merchant Automation"] = "Merchant Automation"
L["Quest Automation"] = "Quest Automation"
L["Social"] = "Social"
L["Cinematics & Dialogs"] = "Cinematics & Dialogs"
L["Convenience"] = "Convenience"
L["Group Finder"] = "Group Finder"
L["Auto Repair Gear"] = "Auto Repair Gear"
L["Use Guild Funds for Repair"] = "Use Guild Funds for Repair"
L["Auto Accept Quests"] = "Auto Accept Quests"
L["Auto Turn In Quests"] = "Auto Turn In Quests"
L["Hold to Pause Auto-Quest"] = "Hold to Pause Auto-Quest"
L["Invert Modifier"] = "Invert Modifier"
L["TIP_QuestModifier"] = "When inverted, quest automation only runs while holding the modifier key. Multiple rewards will always prompt."
L["Auto Loot"] = "Auto Loot"
L["Auto Accept Role Check"] = "Auto Accept Role Check"
L["TIP_AutoRoleCheck"] = "Automatically queues you using the role selected in the Dungeons & Raids window. With this enabled, you cannot add a note to your Group Finder application."
L["Auto Decline Duels"] = "Auto Decline Duels"
L["Auto Decline Pet Battle Duels"] = "Auto Decline Pet Battle Duels"
L["Auto-Fill DELETE Text"] = "Auto-Fill DELETE Text"
L["Skip Cinematics & Movies"] = "Skip Cinematics & Movies"
L["Hide Talking Head Frame"] = "Hide Talking Head Frame"
L["Auto Filter AH to Current Expansion"] = "Auto Filter AH to Current Expansion"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "Enable Copy Anything"
L["Keybind"] = "Keybind"
L["Keybinding"] = "Keybinding"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["In Combat Color"] = "In Combat Color"
L["Non Combat Color"] = "Non Combat Color"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "Enable Cursor Circle"
L["Radius"] = "Radius"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "Enable Skyriding UI"
L["Skyriding UI"] = "Skyriding UI"
L["Hide When Grounded"] = "Hide When Grounded"
L["Speed Font Size"] = "Speed Font Size"
L["Vigor"] = "Vigor"
L["Second Wind"] = "Second Wind"
L["Whirling Surge"] = "Whirling Surge"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["General Settings"] = "General Settings"
L["Growth Direction"] = "Growth Direction"
L["Row Spacing"] = "Row Spacing"
L["Separator Character"] = "Separator Character"
L["Separator Color"] = "Separator Color"
L["Charges Available"] = "Charges Available"
L["Charges Unavailable"] = "Charges Unavailable"
L["Charge Prefix"] = "Charge Prefix"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "Position"
L["Display Settings"] = "Display Settings"
L["Strata"] = "Strata"
L["Color"] = "Color"
L["Color Mode"] = "Color Mode"
L["Custom Color"] = "Custom Color"
L["Outline"] = "Outline"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "Backdrop Settings"
L["Enable Backdrop"] = "Enable Backdrop"
L["Backdrop Color"] = "Backdrop Color"
L["Backdrop Width"] = "Backdrop Width"
L["Backdrop Height"] = "Backdrop Height"
L["Border"] = "Border"
L["Border Color"] = "Border Color"
L["Border Size"] = "Border Size"
L["Background"] = "Background"
L["Use Shadow"] = "Use Shadow"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "Active Profile"
L["Current Profile"] = "Current Profile"
L["Global Profile"] = "Global Profile"
L["Use Global Profile"] = "Use Global Profile"
L["Profile Actions"] = "Profile Actions"
L["Profile Name"] = "Profile Name"
L["Profile"] = "Profile"
L["New Name"] = "New Name"
L["Rename Profile"] = "Rename Profile"
L["Copy From Profile"] = "Copy From Profile"
L["Source Profile"] = "Source Profile"
L["Profile to Delete"] = "Profile to Delete"
L["Profile to Rename"] = "Profile to Rename"
L["Cannot delete the active profile"] = "Cannot delete the active profile"
L["Quick Actions"] = "Quick Actions"
L["Import / Export"] = "Import / Export"
L["Presets"] = "Presets"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Revert All"] = "Revert All"
L["Apply"] = "Apply"
L["Revert"] = "Revert"
L["Current"] = "Current"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------
L["This module tracks when a player casts a spell and monitors a set duration. If a spell is cancelled early (e.g. Dispersion), the remaining duration will not update.\nThis is a short-term solution until Blizzard expands on their built-in Defensives filter."] = "This module tracks when a player casts a spell and monitors a set duration. If a spell is cancelled early (e.g. Dispersion), the remaining duration will not update.\nThis is a short-term solution until Blizzard expands on their built-in Defensives filter."

------------------------------------------------------------------------
-- Home Page (additional)
------------------------------------------------------------------------
L["Reload UI"] = "Reload UI"
L["Show Minimap Button"] = "Show Minimap Button"
L["Show Command in Chat on Login"] = "Show Command in Chat on Login"

------------------------------------------------------------------------
-- Range Check
------------------------------------------------------------------------
L["Range Check"] = "Range Check"
L["Enable Range Check"] = "Enable Range Check"
L["Only Show in Combat"] = "Only Show in Combat"
L["Include Friendly Targets"] = "Include Friendly Targets"
L["Hide 'yd' Suffix"] = "Hide 'yd' Suffix"
L["Color by Range"] = "Color by Range"
L["Text Color"] = "Text Color"

------------------------------------------------------------------------
-- Dispel on Cursor
------------------------------------------------------------------------
L["Dispel on Cursor"] = "Dispel on Cursor"
L["Enable Dispel on Cursor"] = "Enable Dispel on Cursor"
L["X Offset from Cursor"] = "X Offset from Cursor"
L["Y Offset from Cursor"] = "Y Offset from Cursor"

------------------------------------------------------------------------
-- Spell Alerts
------------------------------------------------------------------------
L["Spell Alerts"] = "Spell Alerts"
L["Enable Spell Alert Switch"] = "Enable Spell Alert Switch"
L["Enable Alerts per Spec"] = "Enable Alerts per Spec"
L["Spell Alert Opacity"] = "Spell Alert Opacity"
L["Opacity"] = "Opacity"

------------------------------------------------------------------------
-- Missing Enchants
------------------------------------------------------------------------
L["Character Panel Enhancements"] = "Character Panel Enhancements"
L["Show Missing Enchants"] = "Show Missing Enchants"
L["Hide Character Panel Background"] = "Hide Character Panel Background"

------------------------------------------------------------------------
-- World Map
------------------------------------------------------------------------
L["Map Scale"] = "Map Scale"
L["Increase World Map Scale"] = "Increase World Map Scale"
L["Scale"] = "Scale"
L["Waypoint Search"] = "Waypoint Search"
L["Coordinate Search Bar on World Map"] = "Coordinate Search Bar on World Map"
L["Invalid"] = "Invalid"
L["Invalid coordinates"] = "Invalid coordinates"
L["No map found"] = "No map found"
L["Can't set waypoint here"] = "Can't set waypoint here"
L["Unknown"] = "Unknown"
L["Waypoint set"] = "Waypoint set"

------------------------------------------------------------------------
-- Position Controller
------------------------------------------------------------------------
L["Position Controller"] = "Position Controller"
L["Enable Position Controller"] = "Enable Position Controller"
L["Position Controller requires ElvUI to be enabled."] = "Position Controller requires ElvUI to be enabled."
L["Player Frame"] = "Player Frame"
L["Target Frame"] = "Target Frame"
L["Pet Frame"] = "Pet Frame"
L["Anchors ElvUI unit frames to other frames. Defaults anchor Player and Target to the Essential Cooldown Viewer, and Pet below the Player frame. Use the frame chooser on each card to pick a different anchor target. Unit frame anchoring does not apply to healer specs."] = "Anchors ElvUI unit frames to other frames. Defaults anchor Player and Target to the Essential Cooldown Viewer, and Pet below the Player frame. Use the frame chooser on each card to pick a different anchor target. Unit frame anchoring does not apply to healer specs."
L["CDM Racials Offset"] = "CDM Racials Offset"
L["Enable CDM Racials Offset"] = "Enable CDM Racials Offset"
L["Additional Y Offset for Pet Classes"] = "Additional Y Offset for Pet Classes"
L["Moves Ayije CDM's Racials bar based on whether you currently have a pet out. Requires the Ayije_CDM addon."] = "Moves Ayije CDM's Racials bar based on whether you currently have a pet out. Requires the Ayije_CDM addon."

------------------------------------------------------------------------
-- Sidebar (additional)
------------------------------------------------------------------------
L["Battle Resurrection"] = "Battle Resurrection"
L["Player Crosshair"] = "Player Crosshair"
L["Pet Statuses"] = "Pet Statuses"
L["Stance Texts"] = "Stance Texts"
L["Hunters Mark"] = "Hunters Mark"
L["World Map"] = "World Map"
L["Skyriding"] = "Skyriding"
L["Missing Enchants"] = "Missing Enchants"

------------------------------------------------------------------------
-- Optimize (additional)
------------------------------------------------------------------------
L["Setting"] = "Setting"
L["Recommended"] = "Recommended"
L["Optimize All"] = "Optimize All"
L["CVar"] = "CVar"

------------------------------------------------------------------------
-- Shared (additional)
------------------------------------------------------------------------
L["Auto Accept Resurrection"] = "Auto Accept Resurrection"
L["Faster Auto Loot"] = "Faster Auto Loot"
