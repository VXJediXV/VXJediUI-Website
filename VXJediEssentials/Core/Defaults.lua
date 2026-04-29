-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)

-- Default settings table
local Defaults = {
    global = {
        UseGlobalProfile = false,  -- Switch to global profile
        GlobalProfile = "Default", -- Name of global profile to use

        -- GUI State (only frame position/size persists across logins)
        GUIState = {
            frame = {
                point = nil,         -- Anchor point
                relativePoint = nil, -- Relative anchor point
                xOffset = nil,       -- Frame X offset
                yOffset = nil,       -- Frame Y offset
                width = nil,         -- Frame width
                height = nil,        -- Frame height
            },
            selectedGroupId = nil,   -- Currently selected sidebar item
            selectedTab = nil,       -- Currently selected tab in content
            minimized = false,       -- Is frame minimized
        },
    },
    profile = {


        -- Minimap Icon Settings
        Minimap = {
            hide = true, -- Show/hide minimap icon (default hidden)
        },
        -- Startup chat message
        ShowChatMessage = false,
        -- Combat Timer Settings
        CombatCross = {
            Enabled = false,
            Strata = "HIGH",
            anchorFrameType = "UIPARENT",
            ParentFrame = "UIParent",
            Position = {
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                XOffset = 0,
                YOffset = -10,
            },
            ColorMode = "custom",
            Color = { 0, 1, 0.169, 1 },
            Thickness = 22,
            Outline = true,
        },

        CombatTimer = {
            Enabled = false,                      -- Enable/disable combat timer
            ShowChatMessage = true,              -- Print combat duration to chat
            Format = "MM:SS",                    -- Time format
            BracketStyle = "square",             -- "square" = [], "round" = (), "none" = no brackets
            FontSize = 28,                       -- Font size
            FontFace = "Expressway",             -- Font face
            FontOutline = "OUTLINE",         -- Font outline
            FontShadow = {                       -- Font shadow settings
                Enabled = false,                 -- Enable font shadow
                OffsetX = 0,                     -- X offset
                OffsetY = 0,                     -- Y offset
                Color = { 0, 0, 0, 0 },          -- Shadow color (alpha 1 when enabled)
            },
            ColorInCombat = { 1, 1, 1, 1 },      -- Color when in combat
            ColorOutOfCombat = { 1, 1, 1, 0.7 }, -- Color when out of combat
            anchorFrameType = "SELECTFRAME",     -- Anchor type: SCREEN, UIPARENT, SELECTFRAME
            ParentFrame = "UIParent",            -- Parent frame
            Strata = "HIGH",                     -- Frame strata
            Position = {                         -- Position settings
                AnchorFrom = "CENTER",           -- Anchor point from
                AnchorTo = "CENTER",             -- Anchor point to
                XOffset = 0,                     -- X offset
                YOffset = -100,                  -- Y offset
            },
            Backdrop = {                         -- Backdrop settings
                Enabled = false,                 -- Enable/disable backdrop
                Color = { 0, 0, 0, 0.6 },        -- Backdrop color
                BorderColor = { 0, 0, 0, 1 },    -- Border color
                BorderSize = 1,
                bgWidth = 5,
                bgHeight = 5,

            },
        },

        -- Combat Message Settings
        CombatMessage = {
            Enabled = false,               -- Enable/disable combat messages
            Strata = "HIGH",              -- Frame strata
            anchorFrameType = "UIPARENT", -- Anchor frame type (SCREEN, UIPARENT, SELECTFRAME)
            ParentFrame = "UIParent",     -- Parent frame name (when SELECTFRAME)
            FontFace = "Expressway",      -- Font face
            FontSize = 16,                -- Font size
            FontOutline = "OUTLINE",  -- Font outline: NONE, OUTLINE, THICKOUTLINE
            FontShadow = {                -- Font shadow settings
                Enabled = false,          -- Enable font shadow
                Color = { 0, 0, 0, 0 },   -- Shadow color
                OffsetX = 0,              -- Shadow X offset
                OffsetY = 0,              -- Shadow Y offset
            },
            Position = {                  -- Position settings
                AnchorFrom = "CENTER",    -- Anchor point from
                AnchorTo = "CENTER",      -- Anchor point to
                XOffset = 0,              -- X offset
                YOffset = 172,            -- Y offset
            },
            Duration = 2.5,               -- Message display duration
            Spacing = 4,                  -- Vertical spacing between messages
            -- Enter Combat Message
            EnterCombat = {
                Enabled = true,                 -- Enable enter combat message
                Text = "+ COMBAT +",            -- Text on entering combat
                Color = { 0.929, 0.259, 0, 1 }, -- Color on entering combat
            },
            -- Exit Combat Message
            ExitCombat = {
                Enabled = true,                 -- Enable exit combat message
                Text = "- COMBAT -",            -- Text on exiting combat
                Color = { 0.788, 1, 0.627, 1 }, -- Color on exiting combat
            },
            -- Low Durability Warning (persistent while out of combat)
            LowDurability = {
                Enabled = true,                 -- Enable low durability warning
                Text = "LOW DURABILITY",        -- Warning text
                Color = { 1, 0.3, 0.3, 1 },    -- Warning color (red)
                Threshold = 15,                 -- Percentage threshold
            },
        },


        -- Battle Res Tracker Settings
        BattleRes = {
            Enabled = false,               -- Enable/disable battle res tracker
            DisplayMode = "text",         -- "icon" or "text"
            PreviewMode = false,          -- Preview mode for testing outside M+
            Strata = "HIGH",              -- Frame strata
            anchorFrameType = "UIPARENT", -- Anchor frame type
            ParentFrame = "UIParent",     -- Parent frame name
            Position = {                  -- Position settings
                AnchorFrom = "CENTER",    -- Anchor point from
                AnchorTo = "CENTER",      -- Anchor point to
                XOffset = 0.1,            -- X offset
                YOffset = -430,           -- Y offset
            },

            -- Text Mode Settings
            TextMode = {
                -- General text settings
                BracketStyle = "square",         -- "square" = [], "round" = (), "none" = no brackets
                FontFace = "Expressway",     -- Font face
                FontSize = 18,               -- Font size
                FontOutline = "OUTLINE", -- Font outline
                TextSpacing = 4,             -- Spacing between timer and charges

                -- Separator Settings
                Separator = "|",                 -- Separator between timer and charges
                SeparatorCharges = "CR:",
                SeparatorColor = { 1, 1, 1, 1 }, -- Separator color
                SeparatorShadow = {
                    Enabled = false,             -- Enable shadow
                    Color = { 0, 0, 0, 0 },      -- Shadow color
                    OffsetX = 0,                 -- Shadow X offset (regular shadow only)
                    OffsetY = 0,                 -- Shadow Y offset (regular shadow only)
                },

                -- Cooldown Timer Settings
                TimerColor = { 1, 1, 1, 1 }, -- Timer text color
                TimerShadow = {
                    Enabled = false,         -- Enable shadow
                    Color = { 0, 0, 0, 0 },  -- Shadow color
                    OffsetX = 0,             -- Shadow X offset
                    OffsetY = 0,             -- Shadow Y offset
                },

                -- Charge Count Settings
                ChargeAvailableColor = { 0.3, 1, 0.3, 1 },   -- Charge color when 1+ available
                ChargeUnavailableColor = { 1, 0.3, 0.3, 1 }, -- Charge color when 0 available
                ChargeShadow = {
                    Enabled = false,                         -- Enable shadow
                    Color = { 0, 0, 0, 0 },                  -- Shadow color
                    OffsetX = 0,                             -- Shadow X offset (regular shadow only)
                    OffsetY = 0,                             -- Shadow Y offset (regular shadow only)
                },

                -- Backdrop Settings
                Backdrop = {                      -- Backdrop settings (text mode mainly)
                    Enabled = true,               -- Enable backdrop
                    Color = { 0, 0, 0, 0.8 },     -- Background color
                    BorderColor = { 0, 0, 0, 1 }, -- Border color
                    PaddingX = 8,                 -- Horizontal padding (visual only, not used for sizing)
                    PaddingY = 4,                 -- Vertical padding (visual only, not used for sizing)
                    FrameWidth = 112,             -- Fixed frame width
                    FrameHeight = 26,             -- Fixed frame height
                },
                GrowthDirection = "RIGHT",        -- Growth direction: "LEFT", "RIGHT", "CENTER"
            },
        },


        DispelCursor = {
            Enabled = false,
            FontSize = 18,
            TextColor = { 1, 1, 1, 1 },
            XOffset = 10,
            YOffset = 10,
        },

        RangeCheck = {
            Enabled = false,
            CombatOnly = false,
            IncludeFriendlies = false,
            HideSuffix = false,
            UseRangeColors = true,
            TextColor = { 1, 1, 1, 1 },
            FontFace = "Expressway",
            FontSize = 18,
            FontOutline = "OUTLINE",
            FontShadow = {
                Enabled = false,
                OffsetX = 0,
                OffsetY = 0,
                Color = { 0, 0, 0, 0 },
            },
            Strata = "HIGH",
            anchorFrameType = "UIPARENT",
            ParentFrame = "UIParent",
            Position = {
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                XOffset = 0,
                YOffset = -190,
            },
        },

        FasterLoot = {
            Enabled = false,
        },

        PetTexts = {
            Enabled = false, -- Master toggle
            -- State texts
            PetMissing = "PET MISSING",
            PetPassive = "PET PASSIVE",
            PetDead = "PET DEAD",
            -- State colors (RGBA)
            MissingColor = { 1, 0.82, 0, 1 },  -- Gold/yellow for missing
            PassiveColor = { 0.3, 0.7, 1, 1 }, -- Light blue for passive
            DeadColor = { 1, 0.2, 0.2, 1 },    -- Red for dead
            -- Font settings
            FontFace = "Expressway",           -- Font face
            FontSize = 25,                     -- Font size
            FontOutline = "OUTLINE",       -- Font outline (NONE, OUTLINE, THICKOUTLINE)
            -- Position settings
            Strata = "HIGH",                   -- Frame strata
            anchorFrameType = "UIPARENT",      -- Anchor frame type
            ParentFrame = "UIParent",          -- Parent frame name
            Position = {                       -- Position settings
                AnchorFrom = "CENTER",         -- Anchor point from
                AnchorTo = "CENTER",           -- Anchor point to
                XOffset = 0,                   -- X offset
                YOffset = 105,                 -- Y offset
            },
        },

        -- Optimize Settings (CVar presets)
        Optimize = {},

        -- Miscellaneous Settings
        Miscellaneous = {
            MissingEnchants = {
                Enabled = true,
                FontFace = "Expressway",
                FontSize = 11,
                FontOutline = "OUTLINE",
                HideCharacterBackground = false,
            },
            SpellAlerts = {
                Enabled = false,
                EnabledSpecs = {},
            },
            HuntersMark = {
                Enabled = false,
                Color = { 1, 0.290, 0.301, 1 },
                -- Font settings
                FontFace = "Expressway",      -- Font face
                FontSize = 22,                -- Font size
                FontOutline = "OUTLINE",  -- Font outline (NONE, OUTLINE, THICKOUTLINE)
                -- Position settings
                Strata = "HIGH",              -- Frame strata
                anchorFrameType = "UIPARENT", -- Anchor frame type
                ParentFrame = "UIParent",     -- Parent frame name
                Position = {                  -- Position settings
                    AnchorFrom = "CENTER",    -- Anchor point from
                    AnchorTo = "CENTER",      -- Anchor point to
                    XOffset = 0,              -- X offset
                    YOffset = 75,             -- Y offset
                },
            },

            Gateway = {
                Enabled = false,
                Color = { 0, 1, 0 },
                -- Font settings
                FontFace = "Expressway",      -- Font face
                FontSize = 36,                -- Font size
                FontOutline = "OUTLINE",  -- Font outline (NONE, OUTLINE, THICKOUTLINE)
                -- Position settings
                Strata = "HIGH",              -- Frame strata
                anchorFrameType = "UIPARENT", -- Anchor frame type
                ParentFrame = "UIParent",     -- Parent frame name
                Position = {                  -- Position settings
                    AnchorFrom = "CENTER",    -- Anchor point from
                    AnchorTo = "CENTER",      -- Anchor point to
                    XOffset = 0,              -- X offset
                    YOffset = -319,           -- Y offset
                },
            },

            CopyAnything = {
                Enabled = false, -- Master toggle
                key = "C",      -- Copy keybind
                mod = "ctrl",   -- ctrl, shift, alt
            },

            Automation = {
                Enabled = false,         -- Master toggle
                SkipCinematics = true,  -- Skip in-game cinematics and movies
                HideTalkingHead = true, -- Hide talking head popup frame
                AutoSellJunk = true,    -- Auto sell grey items at merchants
                AutoRepair = true,      -- Auto repair gear at merchants
                UseGuildFunds = true,   -- Use guild bank for repairs when available
                AutoRoleCheck = true,   -- Auto accept role checks and LFG signups
                AutoFillDelete = true,  -- Auto fill DELETE text when deleting items
                AutoLoot = true,        -- Enable auto loot by default
                AutoAcceptQuests = false, -- Auto accept quests from NPCs
                AutoTurnInQuests = false, -- Auto turn in completed quests
                QuestModifier = "SHIFT",  -- Hold to pause quest automation (CTRL, ALT, SHIFT, NONE)
                QuestModifierInvert = false, -- Invert modifier: hold to enable instead of pause
                AutoDeclineDuels = false, -- Auto decline duel requests
                AutoDeclinePetBattles = false, -- Auto decline pet battle requests
                AHCurrentExpansion = false, -- Auto filter AH to current expansion only
                AutoAcceptRes = false,      -- Auto accept resurrection requests out of combat
            },
            CursorCircle = {
                Enabled = false,        -- Show circle around cursor
                Size = 40,              -- Radius in pixels
                Color = { 1, 1, 1, 0.8 }, -- Circle color (RGBA)
            },
            WorldMap = {
                Enabled = true,
                ScaleEnabled = true,        -- Increase world map scale
                Scale = 1.2,                -- Scale multiplier (1.0 = default)
                WaypointBarEnabled = true,  -- Show coordinate search bar on world map
            },
            DragonRiding = {
                Enabled = false,
                Width = 252,               -- Total width of the UI
                BarHeight = 6,             -- Height of each row
                Spacing = 3,               -- Spacing between rows
                FontFace = "Expressway",
                SpeedFontSize = 14,        -- Speed text font size
                StatusBarTexture = "VXJediEssentials", -- LSM statusbar texture name
                HideWhenGrounded = false,  -- Hide UI elements when not gliding
                Position = {               -- Position settings
                    AnchorFrom = "CENTER", -- Anchor point from
                    AnchorTo = "CENTER",   -- Anchor point to
                    XOffset = 0,           -- X offset
                    YOffset = 280,         -- Y offset
                },
                Colors = {
                    Vigor = { 0.898, 0.063, 0.224, 1 },       -- Normal vigor color
                    VigorThrill = { 0, 1, 0.137, 1 },         -- Thrill of the Skies active
                    WhirlingSurge = { 0.411, 0.8, 0.941, 1 }, -- Whirling Surge
                    WhirlingSurgeCD = { 0.3, 0.3, 0.3, 1 },   -- Whirling Surge on cooldown
                    SecondWind = { 0.917, 0.168, 0.901, 1 },  -- Second Wind
                    SecondWindCD = { 0.3, 0.3, 0.3, 1 },      -- Second Wind on cooldown
                    Background = { 0, 0, 0, 0.8 },            -- Bar background color
                    Border = { 0, 0, 0, 1 },                  -- Bar border color
                },
            },

            PositionController = {
                Enabled = false,
                PlayerFrame = {
                    Enabled = true,
                    anchorFrameType = "SELECTFRAME",
                    ParentFrame = "EssentialCooldownViewer",
                    Position = {
                        AnchorFrom = "RIGHT",
                        AnchorTo = "LEFT",
                        XOffset = -20,
                        YOffset = 0,
                    },
                },
                TargetFrame = {
                    Enabled = true,
                    anchorFrameType = "SELECTFRAME",
                    ParentFrame = "EssentialCooldownViewer",
                    Position = {
                        AnchorFrom = "LEFT",
                        AnchorTo = "RIGHT",
                        XOffset = 20,
                        YOffset = 0,
                    },
                },
                PetFrame = {
                    Enabled = true,
                    anchorFrameType = "SELECTFRAME",
                    ParentFrame = "ElvUF_Player",
                    Position = {
                        AnchorFrom = "CENTER",
                        AnchorTo = "BOTTOM",
                        XOffset = 0,
                        YOffset = -10,
                    },
                },
                CDMRacials = {
                    Enabled = false,
                    PetClassOffset = -40,
                },
            },

            TargetCastbar = {
                Enabled = false,

                Width = 300,
                Height = 29,

                FontFace = "Expressway",
                FontSize = 14,
                FontOutline = "OUTLINE",

                Strata = "HIGH",
                anchorFrameType = "UIPARENT",
                ParentFrame = "UIParent",
                Position = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    XOffset = 0,
                    YOffset = 260,
                },

                -- Colors
                CastingColor = { 0.623, 0.749, 1, 1 },
                ChannelingColor = { 0.623, 0.749, 1, 1 },
                EmpoweringColor = { 0.8, 0.4, 1, 1 },
                NotInterruptibleColor = { 0.780, 0.250, 0.250, 1 },
                HideNotInterruptible = false,
                TextColor = { 1, 1, 1, 1 },

                -- Backdrop
                BackdropColor = { 0, 0, 0, 0.8 },
                BorderColor = { 0, 0, 0, 1 },

                -- Statusbar
                StatusBarTexture = "VXJedi",

                -- Hold Timer
                HoldTimer = {
                    Enabled = true,
                    Duration = 0.5,
                    InterruptedColor = { 0.1, 0.8, 0.1, 1 },
                    SuccessColor = { 0.780, 0.250, 0.250, 1 },
                },
                timeToHold = 0.5,

                -- Kick Indicator
                KickIndicator = {
                    Enabled = true,
                    NotReadyColor = { 0.5, 0.5, 0.5, 1 },
                    TickColor = { 0.1, 0.8, 0.1, 1 },
                    SecondaryReadyColor = { 0.878, 0.643, 1, 1 },
                    SecondaryTickColor = { 0.878, 0.643, 1, 1 },
                },

                -- Target Names
                TargetNames = {
                    Anchor = "RIGHT",
                    XOffset = 0,
                    YOffset = 14,
                    FontSize = 12,
                },
            },

            FocusCastbar = {
                Enabled = false,

                Width = 300,
                Height = 29,

                FontFace = "Expressway",
                FontSize = 14,
                FontOutline = "OUTLINE",

                Strata = "HIGH",
                anchorFrameType = "UIPARENT",
                ParentFrame = "UIParent",
                Position = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    XOffset = 0,
                    YOffset = 220,
                },

                -- Colors
                CastingColor = { 0.623, 0.749, 1, 1 },
                ChannelingColor = { 0.623, 0.749, 1, 1 },
                EmpoweringColor = { 0.8, 0.4, 1, 1 },
                NotInterruptibleColor = { 0.780, 0.250, 0.250, 1 },
                HideNotInterruptible = false,
                TextColor = { 1, 1, 1, 1 },

                -- Backdrop
                BackdropColor = { 0, 0, 0, 0.8 },
                BorderColor = { 0, 0, 0, 1 },

                -- Statusbar
                StatusBarTexture = "VXJedi",

                -- Hold Timer
                HoldTimer = {
                    Enabled = true,
                    Duration = 0.5,
                    InterruptedColor = { 0.1, 0.8, 0.1, 1 },
                    SuccessColor = { 0.780, 0.250, 0.250, 1 },
                },
                timeToHold = 0.5,

                -- Kick Indicator
                KickIndicator = {
                    Enabled = true,
                    NotReadyColor = { 0.5, 0.5, 0.5, 1 },
                    TickColor = { 0.1, 0.8, 0.1, 1 },
                    SecondaryReadyColor = { 0.878, 0.643, 1, 1 },
                    SecondaryTickColor = { 0.878, 0.643, 1, 1 },
                },
            },
        },

        -- Stance Text Display
        StanceText = {
            Enabled = false,

            -- Stance Text Display Settings
            StanceText = {
                Enabled = false,
                FontFace = "Expressway",
                FontSize = 14,
                FontOutline = "OUTLINE",
                Strata = "HIGH",
                anchorFrameType = "UIPARENT",
                ParentFrame = "UIParent",
                Position = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    XOffset = -250,
                    YOffset = -130,
                },

                -- Warrior Stance Texts
                WARRIOR = {
                    ["386164"] = { Enabled = true, Text = "BATTLE", Color = { 1, 0, 0, 1 } },
                    ["386196"] = { Enabled = true, Text = "BER", Color = { 1, 0, 0, 1 } },
                    ["386208"] = { Enabled = true, Text = "DEF", Color = { 0.3, 0.7, 1, 1 } },
                },

                -- Paladin Aura Texts
                PALADIN = {
                    ["465"] = { Enabled = true, Text = "DEVO", Color = { 0.3, 0.7, 1, 1 } },
                    ["317920"] = { Enabled = true, Text = "CONC", Color = { 0.9, 0.5, 1, 1 } },
                    ["32223"] = { Enabled = true, Text = "CRU", Color = { 1, 0.8, 0.3, 1 } },
                },
            },
        },
    },
}

-- Returns the Default Table.
function AE:GetDefaultDB()
    return Defaults
end

-- Position Card Template
--[[

                anchorFrameType = "UIPARENT",
                ParentFrame = "UIParent",
                Strata = "LOW",
                Position = {
                    AnchorFrom = "BOTTOMRIGHT",
                    AnchorTo = "BOTTOMRIGHT",
                    XOffset = -1,
                    YOffset = 1,
                },

]]
