-- VXJediEssentials Portuguese (Brazil) Locale (ptBR)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "ptBR" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "Ligado"
L["Off"] = "Desligado"
L["Enabled"] = "Ativado"
L["Disabled"] = "Desativado"
L["Enable"] = "Ativar"
L["Error"] = "Erro"
L["Note"] = "Nota"
L["Show"] = "Mostrar"
L["Required"] = "Necessário"
L["Coming Soon"] = "Em breve"
L["Database not available"] = "Banco de dados indisponível"
L["None"] = "Nenhum"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "Combate"
L["Custom Buffs"] = "Buffs personalizados"
L["Optimize"] = "Otimizar"
L["Profiles"] = "Perfis"
L["Quality of Life"] = "Qualidade de vida"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "Cronômetro de combate"
L["Combat Cross"] = "Cruz de combate"
L["Combat Texts"] = "Textos de combate"
L["Combat Res"] = "Ressurreição de combate"
L["Missing Buffs"] = "Buffs faltantes"
L["Pet Status Texts"] = "Textos de estado do pet"
L["Focus Castbar"] = "Barra de conjuração do foco"
L["Target Castbar"] = "Barra de conjuração do alvo"
L["Hunters Mark Missing"] = "Marca do caçador faltando"
L["Gateway Alert"] = "Alerta de portal"
L["Automation"] = "Automação"
L["Copy Anything"] = "Copiar tudo"
L["Cursor Circle"] = "Círculo do cursor"
L["Dragon Riding UI"] = "Interface de voo dracônico"
L["Externals & Defensives"] = "Externos e defensivos"
L["System Optimization"] = "Otimização do sistema"
L["Profile Manager"] = "Gerenciador de perfis"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "Primeiros passos"
L["Support"] = "Suporte"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "Ativar cronômetro de combate"
L["Print Combat Duration to Chat"] = "Mostrar duração do combate no chat"
L["Combat lasted "] = "O combate durou "
L["Format"] = "Formato"
L["Bracket Style"] = "Estilo de colchetes"
L["Font Size"] = "Tamanho da fonte"
L["Font"] = "Fonte"
L["Font Outline"] = "Contorno da fonte"
L["Font Shadow"] = "Sombra da fonte"
L["Font Settings"] = "Configurações de fonte"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "Ativar cruz de combate"
L["Cross Size"] = "Tamanho da cruz"
L["Size"] = "Tamanho"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "Esta é uma mira estática que não se ajusta ao movimento da câmera."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "Ativar mensagens de combate"
L["Combat Res Tracker"] = "Rastreador de ressurreição"
L["Enable Combat Res Tracker"] = "Ativar rastreador de ressurreição"
L["Enter Combat Message"] = "Mensagem de início de combate"
L["Exit Combat Message"] = "Mensagem de fim de combate"
L["Low Durability Warning"] = "Aviso de durabilidade baixa"
L["LOW DURABILITY"] = "DURABILIDADE BAIXA"
L["Message Spacing"] = "Espaçamento de mensagens"
L["Durability Threshold (%)"] = "Limite de durabilidade (%)"
L["Text"] = "Texto"
L["Text Settings"] = "Configurações de texto"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "Ativar textos de estado do pet"
L["PET DEAD"] = "PET MORTO"
L["PET MISSING"] = "PET AUSENTE"
L["PET PASSIVE"] = "PET PASSIVO"
L["Pet Dead Text"] = "Texto pet morto"
L["Pet Missing Text"] = "Texto pet ausente"
L["Pet Passive Text"] = "Texto pet passivo"
L["Dead Color"] = "Cor morto"
L["Missing Color"] = "Cor ausente"
L["Passive Color"] = "Cor passivo"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "Ativar barra de foco"
L["Enable Target Castbar"] = "Ativar barra de alvo"
L["Bar Height"] = "Altura da barra"
L["Bar Texture"] = "Textura da barra"
L["Width"] = "Largura"
L["Height"] = "Altura"
L["Target Names"] = "Nomes do alvo"
L["Casting"] = "Conjurando"
L["Channeling"] = "Canalizando"
L["Empowering"] = "Potencializando"
L["Not Interruptible"] = "Não interrompível"
L["Interrupted"] = "Interrompido"
L["Cast Success"] = "Conjuração bem-sucedida"
L["Colors"] = "Cores"
L["Color Settings"] = "Configurações de cor"
L["Hold Timer"] = "Cronômetro de espera"
L["Enable Hold Timer"] = "Ativar cronômetro de espera"
L["Hold Duration"] = "Duração de espera"
L["Kick Indicator"] = "Indicador de interrupção"
L["Enable Kick Indicator"] = "Ativar indicador de interrupção"
L["Kick Ready Tick"] = "Marca de interrupção pronta"
L["Kick Not Ready"] = "Interrupção indisponível"
L["Hide Non-Interruptible Casts"] = "Ocultar conjurações não interrompíveis"
L["Timer Text Color"] = "Cor do texto do cronômetro"
L["Enable Shadow"] = "Ativar sombra"
L["Shadow Color"] = "Cor da sombra"
L["Shadow X Offset"] = "Deslocamento X da sombra"
L["Shadow Y Offset"] = "Deslocamento Y da sombra"
L["Shadow X"] = "Sombra X"
L["Shadow Y"] = "Sombra Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "Ativar rastreamento da marca do caçador"
L["Hunters Mark Tracking"] = "Rastreamento da marca do caçador"
L["MISSING MARK"] = "MARCA FALTANDO"
L["This module only works inside raid instances and while out of combat."] = "Este módulo só funciona dentro de instâncias de raide e fora de combate."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "Ativar alerta de portal"
L["Gateway Usable Alert"] = "Alerta portal utilizável"
L["GATE USABLE"] = "PORTAL UTILIZÁVEL"
L["Alert Color"] = "Cor de alerta"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "Ativar buffs faltantes"
L["Consumable & Buff Tracking"] = "Rastreamento de consumíveis e buffs"
L["Stance & Form Tracking"] = "Rastreamento de posturas e formas"
L["Stance Text Display"] = "Exibição de texto de postura"
L["Enable Stance Text"] = "Ativar texto de postura"
L["Hide in Rested Areas"] = "Ocultar em áreas de descanso"
L["MISSING"] = "FALTANDO"
L["Balance: Require Moonkin Form"] = "Equilíbrio: Requer Forma Lunática"
L["Feral: Require Cat Form"] = "Feral: Requer Forma de Gato"
L["Guardian: Require Bear Form"] = "Guardião: Requer Forma de Urso"
L["Require Shadowform"] = "Requer Forma de Sombra"
L["Require Attunement"] = "Requer Sintonização"
L["Shadow Priest Shadowform"] = "Sacerdote Sombrio Forma de Sombra"
L["Augmentation Evoker Attunement"] = "Evocador Aumento Sintonização"
L["Druid Forms"] = "Formas de druida"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "Ativar automação"
L["Merchant Automation"] = "Automação de mercador"
L["Quest Automation"] = "Automação de missões"
L["Social"] = "Social"
L["Cinematics & Dialogs"] = "Cinemáticas e diálogos"
L["Convenience"] = "Conveniência"
L["Group Finder"] = "Localizador de grupo"
L["Auto Sell Junk (Grey Items)"] = "Vender lixo automaticamente"
L["Auto Repair Gear"] = "Reparar equipamento automaticamente"
L["Use Guild Funds for Repair"] = "Usar fundos da guilda"
L["Auto Accept Quests"] = "Aceitar missões automaticamente"
L["Auto Turn In Quests"] = "Entregar missões automaticamente"
L["Hold to Pause Auto-Quest"] = "Segurar para pausar"
L["Auto Loot"] = "Saque automático"
L["Auto Accept Role Check"] = "Aceitar verificação de papel"
L["Auto Decline Duels"] = "Recusar duelos automaticamente"
L["Auto Decline Pet Battle Duels"] = "Recusar duelos de mascote"
L["Auto-Fill DELETE Text"] = "Preencher texto DELETAR"
L["Skip Cinematics & Movies"] = "Pular cinemáticas"
L["Hide Talking Head Frame"] = "Ocultar cabeça falante"
L["Auto Filter AH to Current Expansion"] = "Filtrar leilão por expansão atual"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "Ativar Copiar tudo"
L["Keybind"] = "Tecla"
L["Keybinding"] = "Atalho de teclado"
L["Copy Keybind, Supports Single Letter Only"] = "Tecla de cópia, apenas uma letra"
L["Copy Modifier Key(s)"] = "Tecla(s) modificadora(s)"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "Configurações de estado"
L["In Combat Color"] = "Cor em combate"
L["Non Combat Color"] = "Cor fora de combate"
L["Fade Duration (seconds)"] = "Duração do fade (segundos)"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "Ativar círculo do cursor"
L["Radius"] = "Raio"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "Ativar interface de voo"
L["Skyriding UI"] = "Interface de voo dracônico"
L["Hide When Grounded"] = "Ocultar no solo"
L["Speed Font Size"] = "Tamanho da fonte de velocidade"
L["Vigor"] = "Vigor"
L["Vigor (Thrill)"] = "Vigor (Emoção)"
L["Second Wind"] = "Segundo Fôlego"
L["Second Wind (On CD)"] = "Segundo Fôlego (Em CD)"
L["Whirling Surge"] = "Onda Rodopiante"
L["Whirling Surge (On CD)"] = "Onda Rodopiante (Em CD)"
L["Countdown Size"] = "Tamanho da contagem regressiva"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "Ativar externos e defensivos"
L["General Settings"] = "Configurações gerais"
L["General Icon Settings"] = "Configurações de ícones"
L["Tracker Selection"] = "Seleção de rastreador"
L["Tracker Settings"] = "Configurações do rastreador"
L["Edit Tracker"] = "Editar rastreador"
L["Growth Direction"] = "Direção de crescimento"
L["Icon Size"] = "Tamanho do ícone"
L["Icon Spacing"] = "Espaçamento de ícones"
L["Row Spacing"] = "Espaçamento de linhas"
L["Spacing"] = "Espaçamento"
L["Show Cooldown Text"] = "Mostrar texto de recarga"
L["Duration (sec)"] = "Duração (seg)"
L["Spell"] = "Feitiço"
L["Type"] = "Tipo"
L["Reverse Icon"] = "Inverter ícone"
L["Separator"] = "Separador"
L["Separator Character"] = "Caractere separador"
L["Separator Color"] = "Cor do separador"
L["Low Duration Warning"] = "Aviso de duração baixa"
L["Warn Before Expiry"] = "Avisar antes de expirar"
L["Minutes Left"] = "Minutos restantes"
L["Charges Available"] = "Cargas disponíveis"
L["Charges Unavailable"] = "Cargas indisponíveis"
L["Charge Prefix"] = "Prefixo de carga"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "Posição"
L["Display Settings"] = "Configurações de exibição"
L["X Offset"] = "Deslocamento X"
L["Y Offset"] = "Deslocamento Y"
L["Strata"] = "Camada"
L["Anchor"] = "Âncora"
L["Anchored To"] = "Ancorado em"
L["Color"] = "Cor"
L["Color Mode"] = "Modo de cor"
L["Custom Color"] = "Cor personalizada"
L["Outline"] = "Contorno"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "Configurações de fundo"
L["Enable Backdrop"] = "Ativar fundo"
L["Backdrop Color"] = "Cor do fundo"
L["Backdrop Width"] = "Largura do fundo"
L["Backdrop Height"] = "Altura do fundo"
L["Border"] = "Borda"
L["Border Color"] = "Cor da borda"
L["Border Size"] = "Tamanho da borda"
L["Background"] = "Fundo"
L["Use Shadow"] = "Usar sombra"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "Perfil ativo"
L["Current Profile"] = "Perfil atual"
L["Global Profile"] = "Perfil global"
L["Use Global Profile"] = "Usar perfil global"
L["Profile Actions"] = "Ações do perfil"
L["Profile Name"] = "Nome do perfil"
L["Profile Name (leave empty for default)"] = "Nome do perfil (vazio para padrão)"
L["Profile"] = "Perfil"
L["New Name"] = "Novo nome"
L["Rename Profile"] = "Renomear perfil"
L["Copy From Profile"] = "Copiar de perfil"
L["Source Profile"] = "Perfil de origem"
L["Profile to Delete"] = "Perfil para excluir"
L["Profile to Rename"] = "Perfil para renomear"
L["Cannot delete the active profile"] = "Não é possível excluir o perfil ativo"
L["Quick Actions"] = "Ações rápidas"
L["Import / Export"] = "Importar / Exportar"
L["Load"] = "Carregar"
L["Presets"] = "Predefinições"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "Aplicar tudo"
L["Revert All"] = "Reverter tudo"
L["Apply"] = "Aplicar"
L["Revert"] = "Reverter"
L["Current"] = "Atual"
L["Optimal"] = "Ótimo"
L["Saved"] = "Salvo"
L["No backup"] = "Sem backup"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------
