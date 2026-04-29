-- VXJediEssentials Italian Locale (itIT)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "itIT" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "Attivo"
L["Off"] = "Disattivo"
L["Enabled"] = "Attivato"
L["Disabled"] = "Disattivato"
L["Enable"] = "Attiva"
L["Error"] = "Errore"
L["Note"] = "Nota"
L["Show"] = "Mostra"
L["Required"] = "Richiesto"
L["Coming Soon"] = "In arrivo"
L["Database not available"] = "Database non disponibile"
L["None"] = "Nessuno"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "Combattimento"
L["Custom Buffs"] = "Benefici personalizzati"
L["Optimize"] = "Ottimizza"
L["Profiles"] = "Profili"
L["Quality of Life"] = "Qualità della vita"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "Timer di combattimento"
L["Combat Cross"] = "Croce di combattimento"
L["Combat Texts"] = "Testi di combattimento"
L["Combat Res"] = "Resurrezione in combattimento"
L["Missing Buffs"] = "Benefici mancanti"
L["Pet Status Texts"] = "Testi stato del famiglio"
L["Focus Castbar"] = "Barra di lancio focus"
L["Target Castbar"] = "Barra di lancio bersaglio"
L["Hunters Mark Missing"] = "Marchio del cacciatore mancante"
L["Gateway Alert"] = "Avviso portale"
L["Automation"] = "Automazione"
L["Copy Anything"] = "Copia tutto"
L["Cursor Circle"] = "Cerchio del cursore"
L["Dragon Riding UI"] = "Interfaccia volo draconico"
L["Externals & Defensives"] = "Esterni e difensivi"
L["System Optimization"] = "Ottimizzazione sistema"
L["Profile Manager"] = "Gestore profili"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "Per iniziare"
L["Support"] = "Supporto"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "Attiva timer di combattimento"
L["Print Combat Duration to Chat"] = "Mostra durata combattimento in chat"
L["Combat lasted "] = "Il combattimento è durato "
L["Format"] = "Formato"
L["Bracket Style"] = "Stile parentesi"
L["Font Size"] = "Dimensione carattere"
L["Font"] = "Carattere"
L["Font Outline"] = "Contorno carattere"
L["Font Shadow"] = "Ombra carattere"
L["Font Settings"] = "Impostazioni carattere"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "Attiva croce di combattimento"
L["Cross Size"] = "Dimensione croce"
L["Size"] = "Dimensione"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "Questo è un mirino statico che non si adatta ai movimenti della telecamera."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "Attiva messaggi di combattimento"
L["Combat Res Tracker"] = "Tracciamento resurrezione"
L["Enable Combat Res Tracker"] = "Attiva tracciamento resurrezione"
L["Enter Combat Message"] = "Messaggio inizio combattimento"
L["Exit Combat Message"] = "Messaggio fine combattimento"
L["Low Durability Warning"] = "Avviso durabilità bassa"
L["LOW DURABILITY"] = "DURABILITÀ BASSA"
L["Message Spacing"] = "Spaziatura messaggi"
L["Durability Threshold (%)"] = "Soglia durabilità (%)"
L["Text"] = "Testo"
L["Text Settings"] = "Impostazioni testo"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "Attiva testi stato famiglio"
L["PET DEAD"] = "FAMIGLIO MORTO"
L["PET MISSING"] = "FAMIGLIO ASSENTE"
L["PET PASSIVE"] = "FAMIGLIO PASSIVO"
L["Pet Dead Text"] = "Testo famiglio morto"
L["Pet Missing Text"] = "Testo famiglio assente"
L["Pet Passive Text"] = "Testo famiglio passivo"
L["Dead Color"] = "Colore morto"
L["Missing Color"] = "Colore assente"
L["Passive Color"] = "Colore passivo"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "Attiva barra focus"
L["Enable Target Castbar"] = "Attiva barra bersaglio"
L["Bar Height"] = "Altezza barra"
L["Bar Texture"] = "Trama barra"
L["Width"] = "Larghezza"
L["Height"] = "Altezza"
L["Target Names"] = "Nomi bersaglio"
L["Casting"] = "Lancio"
L["Channeling"] = "Canalizzazione"
L["Empowering"] = "Potenziamento"
L["Not Interruptible"] = "Non interrompibile"
L["Interrupted"] = "Interrotto"
L["Cast Success"] = "Lancio riuscito"
L["Colors"] = "Colori"
L["Color Settings"] = "Impostazioni colore"
L["Hold Timer"] = "Timer di attesa"
L["Enable Hold Timer"] = "Attiva timer di attesa"
L["Hold Duration"] = "Durata attesa"
L["Kick Indicator"] = "Indicatore interruzione"
L["Enable Kick Indicator"] = "Attiva indicatore interruzione"
L["Kick Ready Tick"] = "Segno interruzione pronta"
L["Kick Not Ready"] = "Interruzione non pronta"
L["Hide Non-Interruptible Casts"] = "Nascondi lanci non interrompibili"
L["Timer Text Color"] = "Colore testo timer"
L["Enable Shadow"] = "Attiva ombra"
L["Shadow Color"] = "Colore ombra"
L["Shadow X Offset"] = "Offset X ombra"
L["Shadow Y Offset"] = "Offset Y ombra"
L["Shadow X"] = "Ombra X"
L["Shadow Y"] = "Ombra Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "Attiva tracciamento marchio del cacciatore"
L["Hunters Mark Tracking"] = "Tracciamento marchio del cacciatore"
L["MISSING MARK"] = "MARCHIO MANCANTE"
L["This module only works inside raid instances and while out of combat."] = "Questo modulo funziona solo nelle istanze raid e fuori combattimento."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "Attiva avviso portale"
L["Gateway Usable Alert"] = "Avviso portale utilizzabile"
L["GATE USABLE"] = "PORTALE UTILIZZABILE"
L["Alert Color"] = "Colore avviso"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "Attiva benefici mancanti"
L["Consumable & Buff Tracking"] = "Tracciamento consumabili e benefici"
L["Stance & Form Tracking"] = "Tracciamento posizioni e forme"
L["Stance Text Display"] = "Visualizzazione testo posizione"
L["Enable Stance Text"] = "Attiva testo posizione"
L["Hide in Rested Areas"] = "Nascondi nelle aree di riposo"
L["MISSING"] = "MANCANTE"
L["Balance: Require Moonkin Form"] = "Equilibrio: Richiede Forma Lunare"
L["Feral: Require Cat Form"] = "Feral: Richiede Forma Felina"
L["Guardian: Require Bear Form"] = "Guardiano: Richiede Forma d'Orso"
L["Require Shadowform"] = "Richiede Forma d'Ombra"
L["Require Attunement"] = "Richiede Sintonizzazione"
L["Shadow Priest Shadowform"] = "Sacerdote Ombra Forma d'Ombra"
L["Augmentation Evoker Attunement"] = "Evocatore Potenziamento Sintonizzazione"
L["Druid Forms"] = "Forme druido"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "Attiva automazione"
L["Merchant Automation"] = "Automazione mercante"
L["Quest Automation"] = "Automazione missioni"
L["Social"] = "Sociale"
L["Cinematics & Dialogs"] = "Filmati e dialoghi"
L["Convenience"] = "Comodità"
L["Group Finder"] = "Cerca gruppo"
L["Auto Sell Junk (Grey Items)"] = "Vendi auto. oggetti grigi"
L["Auto Repair Gear"] = "Ripara auto. equipaggiamento"
L["Use Guild Funds for Repair"] = "Usa fondi gilda per riparazioni"
L["Auto Accept Quests"] = "Accetta auto. missioni"
L["Auto Turn In Quests"] = "Consegna auto. missioni"
L["Hold to Pause Auto-Quest"] = "Tieni premuto per sospendere"
L["Auto Loot"] = "Bottino automatico"
L["Auto Accept Role Check"] = "Accetta auto. verifica ruolo"
L["Auto Decline Duels"] = "Rifiuta auto. duelli"
L["Auto Decline Pet Battle Duels"] = "Rifiuta auto. duelli mascotte"
L["Auto-Fill DELETE Text"] = "Compila auto. testo ELIMINA"
L["Skip Cinematics & Movies"] = "Salta filmati"
L["Hide Talking Head Frame"] = "Nascondi testa parlante"
L["Auto Filter AH to Current Expansion"] = "Filtra auto. casa d'aste per espansione"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "Attiva Copia tutto"
L["Keybind"] = "Tasto"
L["Keybinding"] = "Scorciatoia"
L["Copy Keybind, Supports Single Letter Only"] = "Tasto copia, solo una lettera"
L["Copy Modifier Key(s)"] = "Tasto/i modificatore/i"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "Impostazioni stato"
L["In Combat Color"] = "Colore in combattimento"
L["Non Combat Color"] = "Colore fuori combattimento"
L["Fade Duration (seconds)"] = "Durata dissolvenza (secondi)"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "Attiva cerchio cursore"
L["Radius"] = "Raggio"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "Attiva interfaccia volo"
L["Skyriding UI"] = "Interfaccia volo draconico"
L["Hide When Grounded"] = "Nascondi a terra"
L["Speed Font Size"] = "Dim. carattere velocità"
L["Vigor"] = "Vigore"
L["Vigor (Thrill)"] = "Vigore (Brivido)"
L["Second Wind"] = "Secondo Respiro"
L["Second Wind (On CD)"] = "Secondo Respiro (In CD)"
L["Whirling Surge"] = "Ondata Vorticosa"
L["Whirling Surge (On CD)"] = "Ondata Vorticosa (In CD)"
L["Countdown Size"] = "Dimensione conto alla rovescia"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "Attiva esterni e difensivi"
L["General Settings"] = "Impostazioni generali"
L["General Icon Settings"] = "Impostazioni icone"
L["Tracker Selection"] = "Selezione tracker"
L["Tracker Settings"] = "Impostazioni tracker"
L["Edit Tracker"] = "Modifica tracker"
L["Growth Direction"] = "Direzione crescita"
L["Icon Size"] = "Dimensione icona"
L["Icon Spacing"] = "Spaziatura icone"
L["Row Spacing"] = "Spaziatura righe"
L["Spacing"] = "Spaziatura"
L["Show Cooldown Text"] = "Mostra testo recupero"
L["Duration (sec)"] = "Durata (sec)"
L["Spell"] = "Incantesimo"
L["Type"] = "Tipo"
L["Reverse Icon"] = "Inverti icona"
L["Separator"] = "Separatore"
L["Separator Character"] = "Carattere separatore"
L["Separator Color"] = "Colore separatore"
L["Low Duration Warning"] = "Avviso durata bassa"
L["Warn Before Expiry"] = "Avvisa prima della scadenza"
L["Minutes Left"] = "Minuti rimanenti"
L["Charges Available"] = "Cariche disponibili"
L["Charges Unavailable"] = "Cariche non disponibili"
L["Charge Prefix"] = "Prefisso carica"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "Posizione"
L["Display Settings"] = "Impostazioni schermo"
L["X Offset"] = "Offset X"
L["Y Offset"] = "Offset Y"
L["Strata"] = "Strato"
L["Anchor"] = "Ancora"
L["Anchored To"] = "Ancorato a"
L["Color"] = "Colore"
L["Color Mode"] = "Modalità colore"
L["Custom Color"] = "Colore personalizzato"
L["Outline"] = "Contorno"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "Impostazioni sfondo"
L["Enable Backdrop"] = "Attiva sfondo"
L["Backdrop Color"] = "Colore sfondo"
L["Backdrop Width"] = "Larghezza sfondo"
L["Backdrop Height"] = "Altezza sfondo"
L["Border"] = "Bordo"
L["Border Color"] = "Colore bordo"
L["Border Size"] = "Dimensione bordo"
L["Background"] = "Sfondo"
L["Use Shadow"] = "Usa ombra"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "Profilo attivo"
L["Current Profile"] = "Profilo corrente"
L["Global Profile"] = "Profilo globale"
L["Use Global Profile"] = "Usa profilo globale"
L["Profile Actions"] = "Azioni profilo"
L["Profile Name"] = "Nome profilo"
L["Profile Name (leave empty for default)"] = "Nome profilo (vuoto per predefinito)"
L["Profile"] = "Profilo"
L["New Name"] = "Nuovo nome"
L["Rename Profile"] = "Rinomina profilo"
L["Copy From Profile"] = "Copia da profilo"
L["Source Profile"] = "Profilo sorgente"
L["Profile to Delete"] = "Profilo da eliminare"
L["Profile to Rename"] = "Profilo da rinominare"
L["Cannot delete the active profile"] = "Impossibile eliminare il profilo attivo"
L["Quick Actions"] = "Azioni rapide"
L["Import / Export"] = "Importa / Esporta"
L["Load"] = "Carica"
L["Presets"] = "Preset"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "Applica tutto"
L["Revert All"] = "Ripristina tutto"
L["Apply"] = "Applica"
L["Revert"] = "Ripristina"
L["Current"] = "Corrente"
L["Optimal"] = "Ottimale"
L["Saved"] = "Salvato"
L["No backup"] = "Nessun backup"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------
