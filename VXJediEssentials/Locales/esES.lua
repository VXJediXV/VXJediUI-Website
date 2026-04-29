-- VXJediEssentials Spanish (Spain) Locale (esES)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "esES" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "Activado"
L["Off"] = "Desactivado"
L["Enabled"] = "Activado"
L["Disabled"] = "Desactivado"
L["Enable"] = "Activar"
L["Error"] = "Error"
L["Note"] = "Nota"
L["Show"] = "Mostrar"
L["Required"] = "Requerido"
L["Coming Soon"] = "Próximamente"
L["Database not available"] = "Base de datos no disponible"
L["None"] = "Ninguno"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "Combate"
L["Custom Buffs"] = "Mejoras personalizadas"
L["Optimize"] = "Optimizar"
L["Profiles"] = "Perfiles"
L["Quality of Life"] = "Calidad de vida"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "Temporizador de combate"
L["Combat Cross"] = "Cruz de combate"
L["Combat Texts"] = "Textos de combate"
L["Combat Res"] = "Resurrección de combate"
L["Missing Buffs"] = "Mejoras faltantes"
L["Pet Status Texts"] = "Textos de estado de mascota"
L["Focus Castbar"] = "Barra de lanzamiento de foco"
L["Target Castbar"] = "Barra de lanzamiento de objetivo"
L["Hunters Mark Missing"] = "Marca del cazador faltante"
L["Gateway Alert"] = "Alerta de portal"
L["Automation"] = "Automatización"
L["Copy Anything"] = "Copiar todo"
L["Cursor Circle"] = "Círculo del cursor"
L["Dragon Riding UI"] = "Interfaz de vuelo de dragón"
L["Externals & Defensives"] = "Externos y defensivos"
L["System Optimization"] = "Optimización del sistema"
L["Profile Manager"] = "Gestor de perfiles"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "Primeros pasos"
L["Support"] = "Soporte"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "Activar temporizador de combate"
L["Print Combat Duration to Chat"] = "Mostrar duración del combate en el chat"
L["Combat lasted "] = "El combate duró "
L["Format"] = "Formato"
L["Bracket Style"] = "Estilo de corchetes"
L["Font Size"] = "Tamaño de fuente"
L["Font"] = "Fuente"
L["Font Outline"] = "Contorno de fuente"
L["Font Shadow"] = "Sombra de fuente"
L["Font Settings"] = "Ajustes de fuente"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "Activar cruz de combate"
L["Cross Size"] = "Tamaño de la cruz"
L["Size"] = "Tamaño"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "Esta es una retícula estática que no se ajusta con el movimiento de cámara."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "Activar mensajes de combate"
L["Combat Res Tracker"] = "Rastreador de resurrección"
L["Enable Combat Res Tracker"] = "Activar rastreador de resurrección"
L["Enter Combat Message"] = "Mensaje de inicio de combate"
L["Exit Combat Message"] = "Mensaje de fin de combate"
L["Low Durability Warning"] = "Aviso de durabilidad baja"
L["LOW DURABILITY"] = "DURABILIDAD BAJA"
L["Message Spacing"] = "Espaciado de mensajes"
L["Durability Threshold (%)"] = "Umbral de durabilidad (%)"
L["Text"] = "Texto"
L["Text Settings"] = "Ajustes de texto"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "Activar textos de mascota"
L["PET DEAD"] = "MASCOTA MUERTA"
L["PET MISSING"] = "MASCOTA AUSENTE"
L["PET PASSIVE"] = "MASCOTA PASIVA"
L["Pet Dead Text"] = "Texto mascota muerta"
L["Pet Missing Text"] = "Texto mascota ausente"
L["Pet Passive Text"] = "Texto mascota pasiva"
L["Dead Color"] = "Color muerto"
L["Missing Color"] = "Color ausente"
L["Passive Color"] = "Color pasivo"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "Activar barra de foco"
L["Enable Target Castbar"] = "Activar barra de objetivo"
L["Bar Height"] = "Altura de barra"
L["Bar Texture"] = "Textura de barra"
L["Width"] = "Ancho"
L["Height"] = "Alto"
L["Target Names"] = "Nombres de objetivo"
L["Casting"] = "Lanzando"
L["Channeling"] = "Canalizando"
L["Empowering"] = "Potenciando"
L["Not Interruptible"] = "No interrumpible"
L["Interrupted"] = "Interrumpido"
L["Cast Success"] = "Lanzamiento exitoso"
L["Colors"] = "Colores"
L["Color Settings"] = "Ajustes de color"
L["Hold Timer"] = "Temporizador de espera"
L["Enable Hold Timer"] = "Activar temporizador de espera"
L["Hold Duration"] = "Duración de espera"
L["Kick Indicator"] = "Indicador de interrupción"
L["Enable Kick Indicator"] = "Activar indicador de interrupción"
L["Kick Ready Tick"] = "Marca de interrupción lista"
L["Kick Not Ready"] = "Interrupción no lista"
L["Hide Non-Interruptible Casts"] = "Ocultar lanzamientos no interrumpibles"
L["Timer Text Color"] = "Color del temporizador"
L["Enable Shadow"] = "Activar sombra"
L["Shadow Color"] = "Color de sombra"
L["Shadow X Offset"] = "Desplazamiento X de sombra"
L["Shadow Y Offset"] = "Desplazamiento Y de sombra"
L["Shadow X"] = "Sombra X"
L["Shadow Y"] = "Sombra Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "Activar rastreo de marca del cazador"
L["Hunters Mark Tracking"] = "Rastreo de marca del cazador"
L["MISSING MARK"] = "MARCA FALTANTE"
L["This module only works inside raid instances and while out of combat."] = "Este módulo solo funciona en instancias de banda y fuera de combate."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "Activar alerta de portal"
L["Gateway Usable Alert"] = "Alerta de portal utilizable"
L["GATE USABLE"] = "PORTAL UTILIZABLE"
L["Alert Color"] = "Color de alerta"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "Activar mejoras faltantes"
L["Consumable & Buff Tracking"] = "Rastreo de consumibles y mejoras"
L["Stance & Form Tracking"] = "Rastreo de posturas y formas"
L["Stance Text Display"] = "Mostrar texto de postura"
L["Enable Stance Text"] = "Activar texto de postura"
L["Hide in Rested Areas"] = "Ocultar en zonas de descanso"
L["MISSING"] = "FALTANTE"
L["Balance: Require Moonkin Form"] = "Equilibrio: Requiere forma de lechúcico"
L["Feral: Require Cat Form"] = "Feral: Requiere forma de felino"
L["Guardian: Require Bear Form"] = "Guardián: Requiere forma de oso"
L["Require Shadowform"] = "Requiere forma de las sombras"
L["Require Attunement"] = "Requiere sintonización"
L["Shadow Priest Shadowform"] = "Sacerdote Sombra Forma de las sombras"
L["Augmentation Evoker Attunement"] = "Evocador Aumento Sintonización"
L["Druid Forms"] = "Formas de druida"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "Activar automatización"
L["Merchant Automation"] = "Automatización de mercader"
L["Quest Automation"] = "Automatización de misiones"
L["Social"] = "Social"
L["Cinematics & Dialogs"] = "Cinemáticas y diálogos"
L["Convenience"] = "Conveniencia"
L["Group Finder"] = "Buscador de grupo"
L["Auto Sell Junk (Grey Items)"] = "Vender basura automáticamente"
L["Auto Repair Gear"] = "Reparar equipo automáticamente"
L["Use Guild Funds for Repair"] = "Usar fondos de hermandad"
L["Auto Accept Quests"] = "Aceptar misiones automáticamente"
L["Auto Turn In Quests"] = "Entregar misiones automáticamente"
L["Hold to Pause Auto-Quest"] = "Mantener para pausar"
L["Auto Loot"] = "Botín automático"
L["Auto Accept Role Check"] = "Aceptar verificación de rol"
L["Auto Decline Duels"] = "Rechazar duelos automáticamente"
L["Auto Decline Pet Battle Duels"] = "Rechazar duelos de mascotas"
L["Auto-Fill DELETE Text"] = "Rellenar texto ELIMINAR"
L["Skip Cinematics & Movies"] = "Saltar cinemáticas"
L["Hide Talking Head Frame"] = "Ocultar cabeza parlante"
L["Auto Filter AH to Current Expansion"] = "Filtrar subasta por expansión actual"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "Activar Copiar todo"
L["Keybind"] = "Tecla"
L["Keybinding"] = "Atajo de teclado"
L["Copy Keybind, Supports Single Letter Only"] = "Tecla de copia, solo una letra"
L["Copy Modifier Key(s)"] = "Tecla(s) modificadora(s)"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "Ajustes de estado"
L["In Combat Color"] = "Color en combate"
L["Non Combat Color"] = "Color fuera de combate"
L["Fade Duration (seconds)"] = "Duración del desvanecimiento (segundos)"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "Activar círculo del cursor"
L["Radius"] = "Radio"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "Activar interfaz de vuelo"
L["Skyriding UI"] = "Interfaz de vuelo draconique"
L["Hide When Grounded"] = "Ocultar en tierra"
L["Speed Font Size"] = "Tamaño de fuente de velocidad"
L["Vigor"] = "Vigor"
L["Vigor (Thrill)"] = "Vigor (Emoción)"
L["Second Wind"] = "Segundo aliento"
L["Second Wind (On CD)"] = "Segundo aliento (En CD)"
L["Whirling Surge"] = "Oleada giratoria"
L["Whirling Surge (On CD)"] = "Oleada giratoria (En CD)"
L["Countdown Size"] = "Tamaño de cuenta regresiva"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "Activar externos y defensivos"
L["General Settings"] = "Ajustes generales"
L["General Icon Settings"] = "Ajustes de iconos"
L["Tracker Selection"] = "Selección de rastreador"
L["Tracker Settings"] = "Ajustes de rastreador"
L["Edit Tracker"] = "Editar rastreador"
L["Growth Direction"] = "Dirección de crecimiento"
L["Icon Size"] = "Tamaño de icono"
L["Icon Spacing"] = "Espaciado de iconos"
L["Row Spacing"] = "Espaciado de filas"
L["Spacing"] = "Espaciado"
L["Show Cooldown Text"] = "Mostrar texto de recarga"
L["Duration (sec)"] = "Duración (seg)"
L["Spell"] = "Hechizo"
L["Type"] = "Tipo"
L["Reverse Icon"] = "Invertir icono"
L["Separator"] = "Separador"
L["Separator Character"] = "Carácter separador"
L["Separator Color"] = "Color del separador"
L["Low Duration Warning"] = "Aviso de duración baja"
L["Warn Before Expiry"] = "Avisar antes de expirar"
L["Minutes Left"] = "Minutos restantes"
L["Charges Available"] = "Cargas disponibles"
L["Charges Unavailable"] = "Cargas no disponibles"
L["Charge Prefix"] = "Prefijo de carga"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "Posición"
L["Display Settings"] = "Ajustes de pantalla"
L["X Offset"] = "Desplazamiento X"
L["Y Offset"] = "Desplazamiento Y"
L["Strata"] = "Estrato"
L["Anchor"] = "Ancla"
L["Anchored To"] = "Anclado a"
L["Color"] = "Color"
L["Color Mode"] = "Modo de color"
L["Custom Color"] = "Color personalizado"
L["Outline"] = "Contorno"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "Ajustes de fondo"
L["Enable Backdrop"] = "Activar fondo"
L["Backdrop Color"] = "Color de fondo"
L["Backdrop Width"] = "Ancho del fondo"
L["Backdrop Height"] = "Alto del fondo"
L["Border"] = "Borde"
L["Border Color"] = "Color del borde"
L["Border Size"] = "Tamaño del borde"
L["Background"] = "Fondo"
L["Use Shadow"] = "Usar sombra"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "Perfil activo"
L["Current Profile"] = "Perfil actual"
L["Global Profile"] = "Perfil global"
L["Use Global Profile"] = "Usar perfil global"
L["Profile Actions"] = "Acciones de perfil"
L["Profile Name"] = "Nombre de perfil"
L["Profile Name (leave empty for default)"] = "Nombre de perfil (vacío para predeterminado)"
L["Profile"] = "Perfil"
L["New Name"] = "Nuevo nombre"
L["Rename Profile"] = "Renombrar perfil"
L["Copy From Profile"] = "Copiar de perfil"
L["Source Profile"] = "Perfil fuente"
L["Profile to Delete"] = "Perfil a eliminar"
L["Profile to Rename"] = "Perfil a renombrar"
L["Cannot delete the active profile"] = "No se puede eliminar el perfil activo"
L["Quick Actions"] = "Acciones rápidas"
L["Import / Export"] = "Importar / Exportar"
L["Load"] = "Cargar"
L["Presets"] = "Preajustes"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "Aplicar todo"
L["Revert All"] = "Revertir todo"
L["Apply"] = "Aplicar"
L["Revert"] = "Revertir"
L["Current"] = "Actual"
L["Optimal"] = "Óptimo"
L["Saved"] = "Guardado"
L["No backup"] = "Sin respaldo"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------
