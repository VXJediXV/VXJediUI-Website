-- VXJediEssentials German Locale (deDE)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "deDE" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "An"
L["Off"] = "Aus"
L["Enabled"] = "Aktiviert"
L["Disabled"] = "Deaktiviert"
L["Enable"] = "Aktivieren"
L["Error"] = "Fehler"
L["Note"] = "Hinweis"
L["Show"] = "Anzeigen"
L["Required"] = "Erforderlich"
L["Coming Soon"] = "Demnächst"
L["Database not available"] = "Datenbank nicht verfügbar"
L["None"] = "Keine"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "Kampf"
L["Custom Buffs"] = "Benutzerdefinierte Buffs"
L["Optimize"] = "Optimieren"
L["Profiles"] = "Profile"
L["Quality of Life"] = "Komfort"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "Kampftimer"
L["Combat Cross"] = "Kampfkreuz"
L["Combat Texts"] = "Kampftexte"
L["Combat Res"] = "Kampfwiederbelebung"
L["Missing Buffs"] = "Fehlende Buffs"
L["Pet Status Texts"] = "Begleiter-Statustexte"
L["Focus Castbar"] = "Fokus-Zauberleiste"
L["Target Castbar"] = "Ziel-Zauberleiste"
L["Hunters Mark Missing"] = "Mal des Jägers fehlt"
L["Gateway Alert"] = "Portal-Warnung"
L["Automation"] = "Automatisierung"
L["Copy Anything"] = "Alles kopieren"
L["Cursor Circle"] = "Cursor-Kreis"
L["Dragon Riding UI"] = "Drachenreiten-UI"
L["Externals & Defensives"] = "Externe & Defensive"
L["System Optimization"] = "Systemoptimierung"
L["Profile Manager"] = "Profilverwaltung"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "Erste Schritte"
L["Support"] = "Unterstützung"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "Kampftimer aktivieren"
L["Print Combat Duration to Chat"] = "Kampfdauer im Chat ausgeben"
L["Combat lasted "] = "Kampf dauerte "
L["Format"] = "Format"
L["Bracket Style"] = "Klammerstil"
L["Font Size"] = "Schriftgröße"
L["Font"] = "Schriftart"
L["Font Outline"] = "Schriftumriss"
L["Font Shadow"] = "Schriftschatten"
L["Font Settings"] = "Schrifteinstellungen"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "Kampfkreuz aktivieren"
L["Cross Size"] = "Kreuzgröße"
L["Size"] = "Größe"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "Dies ist ein statisches Fadenkreuz und passt sich nicht an Kamerabewegungen an."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "Kampfnachrichten aktivieren"
L["Combat Res Tracker"] = "Kampfwiederbelebung-Tracker"
L["Enable Combat Res Tracker"] = "Kampfwiederbelebung-Tracker aktivieren"
L["Enter Combat Message"] = "Kampfbeginn-Nachricht"
L["Exit Combat Message"] = "Kampfende-Nachricht"
L["Low Durability Warning"] = "Warnung bei niedriger Haltbarkeit"
L["LOW DURABILITY"] = "NIEDRIGE HALTBARKEIT"
L["Message Spacing"] = "Nachrichtenabstand"
L["Durability Threshold (%)"] = "Haltbarkeitsschwelle (%)"
L["Text"] = "Text"
L["Text Settings"] = "Texteinstellungen"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "Begleiter-Statustexte aktivieren"
L["PET DEAD"] = "BEGLEITER TOT"
L["PET MISSING"] = "BEGLEITER FEHLT"
L["PET PASSIVE"] = "BEGLEITER PASSIV"
L["Pet Dead Text"] = "Begleiter-Tot-Text"
L["Pet Missing Text"] = "Begleiter-Fehlt-Text"
L["Pet Passive Text"] = "Begleiter-Passiv-Text"
L["Dead Color"] = "Tot-Farbe"
L["Missing Color"] = "Fehlt-Farbe"
L["Passive Color"] = "Passiv-Farbe"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "Fokus-Zauberleiste aktivieren"
L["Enable Target Castbar"] = "Ziel-Zauberleiste aktivieren"
L["Bar Height"] = "Balkenhöhe"
L["Bar Texture"] = "Balkentextur"
L["Width"] = "Breite"
L["Height"] = "Höhe"
L["Target Names"] = "Zielnamen"
L["Casting"] = "Zaubert"
L["Channeling"] = "Kanalisiert"
L["Empowering"] = "Aufladung"
L["Not Interruptible"] = "Nicht unterbrechbar"
L["Interrupted"] = "Unterbrochen"
L["Cast Success"] = "Zauber erfolgreich"
L["Colors"] = "Farben"
L["Color Settings"] = "Farbeinstellungen"
L["Hold Timer"] = "Haltetimer"
L["Enable Hold Timer"] = "Haltetimer aktivieren"
L["Hold Duration"] = "Haltedauer"
L["Kick Indicator"] = "Unterbrechungsanzeige"
L["Enable Kick Indicator"] = "Unterbrechungsanzeige aktivieren"
L["Kick Ready Tick"] = "Unterbrechung-Bereit-Markierung"
L["Kick Not Ready"] = "Unterbrechung nicht bereit"
L["Hide Non-Interruptible Casts"] = "Nicht unterbrechbare Zauber ausblenden"
L["Timer Text Color"] = "Timer-Textfarbe"
L["Enable Shadow"] = "Schatten aktivieren"
L["Shadow Color"] = "Schattenfarbe"
L["Shadow X Offset"] = "Schatten X-Versatz"
L["Shadow Y Offset"] = "Schatten Y-Versatz"
L["Shadow X"] = "Schatten X"
L["Shadow Y"] = "Schatten Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "Mal des Jägers Verfolgung aktivieren"
L["Hunters Mark Tracking"] = "Mal des Jägers Verfolgung"
L["MISSING MARK"] = "MAL FEHLT"
L["This module only works inside raid instances and while out of combat."] = "Dieses Modul funktioniert nur in Schlachtzugsinstanzen und außerhalb des Kampfes."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "Portal-Warnung aktivieren"
L["Gateway Usable Alert"] = "Portal benutzbar"
L["GATE USABLE"] = "PORTAL BENUTZBAR"
L["Alert Color"] = "Warnfarbe"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "Fehlende Buffs aktivieren"
L["Consumable & Buff Tracking"] = "Verbrauchsgüter- & Buff-Verfolgung"
L["Stance & Form Tracking"] = "Haltungs- & Formverfolgung"
L["Stance Text Display"] = "Haltungstext-Anzeige"
L["Enable Stance Text"] = "Haltungstext aktivieren"
L["Hide in Rested Areas"] = "In Erholungsgebieten ausblenden"
L["MISSING"] = "FEHLT"
L["Balance: Require Moonkin Form"] = "Gleichgewicht: Mondkingestalt erforderlich"
L["Feral: Require Cat Form"] = "Wild: Katzengestalt erforderlich"
L["Guardian: Require Bear Form"] = "Wächter: Bärengestalt erforderlich"
L["Require Shadowform"] = "Schattengestalt erforderlich"
L["Require Attunement"] = "Einstimmung erforderlich"
L["Shadow Priest Shadowform"] = "Schattenpriester Schattengestalt"
L["Augmentation Evoker Attunement"] = "Verstärkung Rufer Einstimmung"
L["Druid Forms"] = "Druidenformen"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "Automatisierung aktivieren"
L["Merchant Automation"] = "Händler-Automatisierung"
L["Quest Automation"] = "Quest-Automatisierung"
L["Social"] = "Soziales"
L["Cinematics & Dialogs"] = "Zwischensequenzen & Dialoge"
L["Convenience"] = "Komfort"
L["Group Finder"] = "Gruppenfinder"
L["Auto Sell Junk (Grey Items)"] = "Schrott automatisch verkaufen (Graue Gegenstände)"
L["Auto Repair Gear"] = "Ausrüstung automatisch reparieren"
L["Use Guild Funds for Repair"] = "Gildenbank für Reparaturen verwenden"
L["Auto Accept Quests"] = "Quests automatisch annehmen"
L["Auto Turn In Quests"] = "Quests automatisch abgeben"
L["Hold to Pause Auto-Quest"] = "Halten zum Pausieren der Auto-Quest"
L["Auto Loot"] = "Automatisch plündern"
L["Auto Accept Role Check"] = "Rollenprüfung automatisch bestätigen"
L["Auto Decline Duels"] = "Duelle automatisch ablehnen"
L["Auto Decline Pet Battle Duels"] = "Haustierkampf-Duelle automatisch ablehnen"
L["Auto-Fill DELETE Text"] = "LÖSCHEN-Text automatisch ausfüllen"
L["Skip Cinematics & Movies"] = "Zwischensequenzen & Filme überspringen"
L["Hide Talking Head Frame"] = "Sprechenden Kopf ausblenden"
L["Auto Filter AH to Current Expansion"] = "AH automatisch auf aktuelle Erweiterung filtern"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "Alles kopieren aktivieren"
L["Keybind"] = "Tastenbelegung"
L["Keybinding"] = "Tastenbelegung"
L["Copy Keybind, Supports Single Letter Only"] = "Kopiertaste, nur einzelne Buchstaben"
L["Copy Modifier Key(s)"] = "Kopier-Modifikatortaste(n)"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "Zustandseinstellungen"
L["In Combat Color"] = "Kampffarbe"
L["Non Combat Color"] = "Nicht-Kampffarbe"
L["Fade Duration (seconds)"] = "Ausblenddauer (Sekunden)"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "Cursor-Kreis aktivieren"
L["Radius"] = "Radius"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "Drachenreiten-UI aktivieren"
L["Skyriding UI"] = "Drachenreiten-UI"
L["Hide When Grounded"] = "Am Boden ausblenden"
L["Speed Font Size"] = "Geschwindigkeit Schriftgröße"
L["Vigor"] = "Elan"
L["Vigor (Thrill)"] = "Elan (Nervenkitzel)"
L["Second Wind"] = "Zweiter Atem"
L["Second Wind (On CD)"] = "Zweiter Atem (Abklingzeit)"
L["Whirling Surge"] = "Wirbelnder Vorstoß"
L["Whirling Surge (On CD)"] = "Wirbelnder Vorstoß (Abklingzeit)"
L["Countdown Size"] = "Countdown-Größe"

------------------------------------------------------------------------
-- Externals & Defensives
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "Externe & Defensive aktivieren"
L["General Settings"] = "Allgemeine Einstellungen"
L["General Icon Settings"] = "Allgemeine Symbol-Einstellungen"
L["Tracker Selection"] = "Tracker-Auswahl"
L["Tracker Settings"] = "Tracker-Einstellungen"
L["Edit Tracker"] = "Tracker bearbeiten"
L["Growth Direction"] = "Wachstumsrichtung"
L["Icon Size"] = "Symbolgröße"
L["Icon Spacing"] = "Symbolabstand"
L["Row Spacing"] = "Zeilenabstand"
L["Spacing"] = "Abstand"
L["Show Cooldown Text"] = "Abklingzeittext anzeigen"
L["Duration (sec)"] = "Dauer (Sek.)"
L["Spell"] = "Zauber"
L["Type"] = "Typ"
L["Reverse Icon"] = "Symbol umkehren"
L["Separator"] = "Trennzeichen"
L["Separator Character"] = "Trennzeichen"
L["Separator Color"] = "Trennzeichenfarbe"
L["Low Duration Warning"] = "Warnung bei kurzer Dauer"
L["Warn Before Expiry"] = "Vor Ablauf warnen"
L["Minutes Left"] = "Verbleibende Minuten"
L["Charges Available"] = "Aufladungen verfügbar"
L["Charges Unavailable"] = "Aufladungen nicht verfügbar"
L["Charge Prefix"] = "Aufladungspräfix"

------------------------------------------------------------------------
-- Position & Layout
------------------------------------------------------------------------
L["Position"] = "Position"
L["Display Settings"] = "Anzeigeeinstellungen"
L["X Offset"] = "X-Versatz"
L["Y Offset"] = "Y-Versatz"
L["Strata"] = "Ebene"
L["Anchor"] = "Anker"
L["Anchored To"] = "Verankert an"
L["Color"] = "Farbe"
L["Color Mode"] = "Farbmodus"
L["Custom Color"] = "Benutzerdefinierte Farbe"
L["Outline"] = "Umriss"

------------------------------------------------------------------------
-- Backdrop
------------------------------------------------------------------------
L["Backdrop Settings"] = "Hintergrundeinstellungen"
L["Enable Backdrop"] = "Hintergrund aktivieren"
L["Backdrop Color"] = "Hintergrundfarbe"
L["Backdrop Width"] = "Hintergrundbreite"
L["Backdrop Height"] = "Hintergrundhöhe"
L["Border"] = "Rand"
L["Border Color"] = "Randfarbe"
L["Border Size"] = "Randgröße"
L["Background"] = "Hintergrund"
L["Use Shadow"] = "Schatten verwenden"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "Aktives Profil"
L["Current Profile"] = "Aktuelles Profil"
L["Global Profile"] = "Globales Profil"
L["Use Global Profile"] = "Globales Profil verwenden"
L["Profile Actions"] = "Profilaktionen"
L["Profile Name"] = "Profilname"
L["Profile Name (leave empty for default)"] = "Profilname (leer lassen für Standard)"
L["Profile"] = "Profil"
L["New Name"] = "Neuer Name"
L["Rename Profile"] = "Profil umbenennen"
L["Copy From Profile"] = "Von Profil kopieren"
L["Source Profile"] = "Quellprofil"
L["Profile to Delete"] = "Zu löschendes Profil"
L["Profile to Rename"] = "Umzubenennendes Profil"
L["Cannot delete the active profile"] = "Aktives Profil kann nicht gelöscht werden"
L["Quick Actions"] = "Schnellaktionen"
L["Import / Export"] = "Import / Export"
L["Load"] = "Laden"
L["Presets"] = "Voreinstellungen"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "Alle anwenden"
L["Revert All"] = "Alle zurücksetzen"
L["Apply"] = "Anwenden"
L["Revert"] = "Zurücksetzen"
L["Current"] = "Aktuell"
L["Optimal"] = "Optimal"
L["Saved"] = "Gespeichert"
L["No backup"] = "Keine Sicherung"

------------------------------------------------------------------------
-- Notes
------------------------------------------------------------------------
L["This module tracks when a player casts a spell and monitors a set duration. If a spell is cancelled early (e.g. Dispersion), the remaining duration will not update.\nThis is a short-term solution until Blizzard expands on their built-in Defensives filter."] = "Dieses Modul verfolgt, wann ein Spieler einen Zauber wirkt, und überwacht eine festgelegte Dauer. Wird ein Zauber vorzeitig abgebrochen (z.B. Zerstreuung), wird die verbleibende Dauer nicht aktualisiert.\nDies ist eine kurzfristige Lösung, bis Blizzard den eingebauten Defensiv-Filter erweitert."

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------
