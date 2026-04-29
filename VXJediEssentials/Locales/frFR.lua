-- VXJediEssentials French Locale (frFR)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "frFR" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "Activé"
L["Off"] = "Désactivé"
L["Enabled"] = "Activé"
L["Disabled"] = "Désactivé"
L["Enable"] = "Activer"
L["Error"] = "Erreur"
L["Note"] = "Note"
L["Show"] = "Afficher"
L["Required"] = "Requis"
L["Coming Soon"] = "Bientôt disponible"
L["Database not available"] = "Base de données indisponible"
L["None"] = "Aucun"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "Combat"
L["Custom Buffs"] = "Buffs personnalisés"
L["Optimize"] = "Optimiser"
L["Profiles"] = "Profils"
L["Quality of Life"] = "Qualité de vie"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "Chronomètre de combat"
L["Combat Cross"] = "Croix de combat"
L["Combat Texts"] = "Textes de combat"
L["Combat Res"] = "Résurrection en combat"
L["Missing Buffs"] = "Buffs manquants"
L["Pet Status Texts"] = "Textes d'état du familier"
L["Focus Castbar"] = "Barre d'incantation du focus"
L["Target Castbar"] = "Barre d'incantation de la cible"
L["Hunters Mark Missing"] = "Marque du chasseur manquante"
L["Gateway Alert"] = "Alerte de portail"
L["Automation"] = "Automatisation"
L["Copy Anything"] = "Tout copier"
L["Cursor Circle"] = "Cercle du curseur"
L["Dragon Riding UI"] = "IU de Vol draconique"
L["Externals & Defensives"] = "Externes et défensifs"
L["System Optimization"] = "Optimisation du système"
L["Profile Manager"] = "Gestionnaire de profils"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "Premiers pas"
L["Support"] = "Support"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "Activer le chronomètre de combat"
L["Print Combat Duration to Chat"] = "Afficher la durée du combat dans le chat"
L["Combat lasted "] = "Le combat a duré "
L["Bracket Style"] = "Style de crochets"
L["Font Size"] = "Taille de police"
L["Font"] = "Police"
L["Font Outline"] = "Contour de police"
L["Font Shadow"] = "Ombre de police"
L["Font Settings"] = "Paramètres de police"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "Activer la croix de combat"
L["Cross Size"] = "Taille de la croix"
L["Size"] = "Taille"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "C'est un réticule statique qui ne s'ajuste pas avec le mouvement de la caméra."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "Activer les messages de combat"
L["Enter Combat Message"] = "Message d'entrée en combat"
L["Exit Combat Message"] = "Message de sortie de combat"
L["Low Durability Warning"] = "Avertissement de durabilité faible"
L["LOW DURABILITY"] = "DURABILITÉ FAIBLE"
L["Message Spacing"] = "Espacement des messages"
L["Durability Threshold (%)"] = "Seuil de durabilité (%)"
L["Text"] = "Texte"
L["Text Settings"] = "Paramètres de texte"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "Activer les textes d'état du familier"
L["PET DEAD"] = "FAMILIER MORT"
L["PET MISSING"] = "FAMILIER ABSENT"
L["PET PASSIVE"] = "FAMILIER PASSIF"
L["Pet Dead Text"] = "Texte familier mort"
L["Pet Missing Text"] = "Texte familier absent"
L["Pet Passive Text"] = "Texte familier passif"
L["Dead Color"] = "Couleur mort"
L["Missing Color"] = "Couleur absent"
L["Passive Color"] = "Couleur passif"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "Activer la barre focus"
L["Enable Target Castbar"] = "Activer la barre cible"
L["Bar Height"] = "Hauteur de la barre"
L["Bar Texture"] = "Texture de la barre"
L["Width"] = "Largeur"
L["Height"] = "Hauteur"
L["Target Names"] = "Noms des cibles"
L["Casting"] = "Incantation"
L["Channeling"] = "Canalisation"
L["Empowering"] = "Renforcement"
L["Not Interruptible"] = "Non interruptible"
L["Interrupted"] = "Interrompu"
L["Cast Success"] = "Incantation réussie"
L["Colors"] = "Couleurs"
L["Color Settings"] = "Paramètres de couleur"
L["Hold Timer"] = "Chrono de maintien"
L["Enable Hold Timer"] = "Activer le chrono de maintien"
L["Hold Duration"] = "Durée de maintien"
L["Kick Indicator"] = "Indicateur d'interruption"
L["Enable Kick Indicator"] = "Activer l'indicateur d'interruption"
L["Kick Ready Tick"] = "Marque interruption prête"
L["Kick Not Ready"] = "Interruption indisponible"
L["Hide Non-Interruptible Casts"] = "Masquer les sorts non interruptibles"
L["Timer Text Color"] = "Couleur du chrono"
L["Enable Shadow"] = "Activer l'ombre"
L["Shadow Color"] = "Couleur de l'ombre"
L["Shadow X Offset"] = "Décalage X de l'ombre"
L["Shadow Y Offset"] = "Décalage Y de l'ombre"
L["Shadow X"] = "Ombre X"
L["Shadow Y"] = "Ombre Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "Activer le suivi de la marque du chasseur"
L["Hunters Mark Tracking"] = "Suivi de la marque du chasseur"
L["MISSING MARK"] = "MARQUE MANQUANTE"
L["This module only works inside raid instances and while out of combat."] = "Ce module ne fonctionne qu'en instance de raid et hors combat."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "Activer l'alerte de portail"
L["Gateway Usable Alert"] = "Alerte portail utilisable"
L["GATE USABLE"] = "PORTAIL UTILISABLE"
L["Alert Color"] = "Couleur d'alerte"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "Activer les buffs manquants"
L["Consumable & Buff Tracking"] = "Suivi des consommables et buffs"
L["Stance & Form Tracking"] = "Suivi des postures et formes"
L["Stance Text Display"] = "Affichage du texte de posture"
L["Enable Stance Text"] = "Activer le texte de posture"
L["Hide in Rested Areas"] = "Masquer dans les zones de repos"
L["MISSING"] = "MANQUANT"
L["Balance: Require Moonkin Form"] = "Équilibre : Forme de sélénien requise"
L["Feral: Require Cat Form"] = "Féral : Forme de félin requise"
L["Guardian: Require Bear Form"] = "Gardien : Forme d'ours requise"
L["Require Shadowform"] = "Forme d'ombre requise"
L["Require Attunement"] = "Harmonisation requise"
L["Shadow Priest Shadowform"] = "Prêtre Ombre Forme d'ombre"
L["Augmentation Evoker Attunement"] = "Évocateur Augmentation Harmonisation"
L["Druid Forms"] = "Formes de druide"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "Activer l'automatisation"
L["Merchant Automation"] = "Automatisation marchands"
L["Quest Automation"] = "Automatisation des quêtes"
L["Social"] = "Social"
L["Cinematics & Dialogs"] = "Cinématiques et dialogues"
L["Convenience"] = "Confort"
L["Group Finder"] = "Recherche de groupe"
L["Auto Sell Junk (Grey Items)"] = "Vendre auto. les objets gris"
L["Auto Repair Gear"] = "Réparation automatique"
L["Use Guild Funds for Repair"] = "Utiliser les fonds de guilde"
L["Auto Accept Quests"] = "Accepter auto. les quêtes"
L["Auto Turn In Quests"] = "Rendre auto. les quêtes"
L["Hold to Pause Auto-Quest"] = "Maintenir pour suspendre"
L["Auto Loot"] = "Butin automatique"
L["Auto Accept Role Check"] = "Accepter auto. la vérification de rôle"
L["Auto Decline Duels"] = "Refuser auto. les duels"
L["Auto Decline Pet Battle Duels"] = "Refuser auto. les duels de mascottes"
L["Auto-Fill DELETE Text"] = "Remplir auto. le texte SUPPRIMER"
L["Skip Cinematics & Movies"] = "Passer les cinématiques"
L["Hide Talking Head Frame"] = "Masquer la tête parlante"
L["Auto Filter AH to Current Expansion"] = "Filtrer auto. l'HV sur l'extension actuelle"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "Activer Tout copier"
L["Keybind"] = "Raccourci"
L["Keybinding"] = "Raccourci clavier"
L["Copy Keybind, Supports Single Letter Only"] = "Touche de copie, une seule lettre"
L["Copy Modifier Key(s)"] = "Touche(s) modificatrice(s)"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "Paramètres d'état"
L["In Combat Color"] = "Couleur en combat"
L["Non Combat Color"] = "Couleur hors combat"
L["Fade Duration (seconds)"] = "Durée du fondu (secondes)"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "Activer le cercle du curseur"
L["Radius"] = "Rayon"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "Activer l'interface de vol"
L["Skyriding UI"] = "Interface de vol draconique"
L["Hide When Grounded"] = "Masquer au sol"
L["Speed Font Size"] = "Taille police vitesse"
L["Vigor"] = "Vigueur"
L["Vigor (Thrill)"] = "Vigueur (Frisson)"
L["Second Wind"] = "Deuxième souffle"
L["Second Wind (On CD)"] = "Deuxième souffle (Recharge)"
L["Whirling Surge"] = "Déferlante tourbillonnante"
L["Whirling Surge (On CD)"] = "Déferlante tourbillonnante (Recharge)"
L["Countdown Size"] = "Taille du décompte"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "Activer externes et défensifs"
L["General Settings"] = "Paramètres généraux"
L["General Icon Settings"] = "Paramètres d'icônes"
L["Tracker Selection"] = "Sélection du traqueur"
L["Tracker Settings"] = "Paramètres du traqueur"
L["Edit Tracker"] = "Modifier le traqueur"
L["Growth Direction"] = "Direction de croissance"
L["Icon Size"] = "Taille d'icône"
L["Icon Spacing"] = "Espacement d'icônes"
L["Row Spacing"] = "Espacement des lignes"
L["Spacing"] = "Espacement"
L["Show Cooldown Text"] = "Afficher le texte de recharge"
L["Duration (sec)"] = "Durée (sec)"
L["Spell"] = "Sort"
L["Type"] = "Type"
L["Reverse Icon"] = "Inverser l'icône"
L["Separator"] = "Séparateur"
L["Separator Character"] = "Caractère séparateur"
L["Separator Color"] = "Couleur du séparateur"
L["Low Duration Warning"] = "Alerte durée faible"
L["Warn Before Expiry"] = "Avertir avant expiration"
L["Minutes Left"] = "Minutes restantes"
L["Charges Available"] = "Charges disponibles"
L["Charges Unavailable"] = "Charges indisponibles"
L["Charge Prefix"] = "Préfixe de charge"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "Position"
L["Display Settings"] = "Paramètres d'affichage"
L["X Offset"] = "Décalage X"
L["Y Offset"] = "Décalage Y"
L["Strata"] = "Strate"
L["Anchor"] = "Ancre"
L["Anchored To"] = "Ancré à"
L["Color"] = "Couleur"
L["Color Mode"] = "Mode de couleur"
L["Custom Color"] = "Couleur personnalisée"
L["Outline"] = "Contour"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "Paramètres de fond"
L["Enable Backdrop"] = "Activer le fond"
L["Backdrop Color"] = "Couleur de fond"
L["Backdrop Width"] = "Largeur du fond"
L["Backdrop Height"] = "Hauteur du fond"
L["Border"] = "Bordure"
L["Border Color"] = "Couleur de bordure"
L["Border Size"] = "Taille de bordure"
L["Background"] = "Arrière-plan"
L["Use Shadow"] = "Utiliser l'ombre"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "Profil actif"
L["Current Profile"] = "Profil actuel"
L["Global Profile"] = "Profil global"
L["Use Global Profile"] = "Utiliser le profil global"
L["Profile Actions"] = "Actions du profil"
L["Profile Name"] = "Nom du profil"
L["Profile Name (leave empty for default)"] = "Nom du profil (vide pour défaut)"
L["Profile"] = "Profil"
L["New Name"] = "Nouveau nom"
L["Rename Profile"] = "Renommer le profil"
L["Copy From Profile"] = "Copier depuis un profil"
L["Source Profile"] = "Profil source"
L["Profile to Delete"] = "Profil à supprimer"
L["Profile to Rename"] = "Profil à renommer"
L["Cannot delete the active profile"] = "Impossible de supprimer le profil actif"
L["Quick Actions"] = "Actions rapides"
L["Import / Export"] = "Import / Export"
L["Load"] = "Charger"
L["Presets"] = "Préréglages"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "Tout appliquer"
L["Revert All"] = "Tout annuler"
L["Apply"] = "Appliquer"
L["Revert"] = "Annuler"
L["Current"] = "Actuel"
L["Optimal"] = "Optimal"
L["Saved"] = "Sauvegardé"
L["No backup"] = "Aucune sauvegarde"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------
