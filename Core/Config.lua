--!strict
-- Core/Config.lua
-- Static configuration values for TBIGUI v3.
-- No dynamic state should be stored here.

local Config = {}

---------------------------------------------------------------------
-- General Script Settings
---------------------------------------------------------------------

Config.ScriptName = "ASTRAL"
Config.Version = "3.0.0"

-- How often the scheduler checks for active autofarms
Config.SchedulerInterval = 0.25

-- How often stats update
Config.StatsUpdateInterval = 1

---------------------------------------------------------------------
-- Movement / Platform Settings
---------------------------------------------------------------------

Config.DefaultWalkSpeed = 16
Config.DefaultJumpPower = 50

-- Platform sizes used by PetFarm / BabyFarm
Config.PlatformSize = Vector3.new(20, 1, 20)

-- How long to wait after teleporting before continuing
Config.PostTeleportDelay = 0.5

---------------------------------------------------------------------
-- Tick Delays (core autofarm timing)
---------------------------------------------------------------------

-- Delay between ailment checks
Config.AilmentTickDelay = 1.0

-- Delay between pet farm cycles
Config.PetFarmTickDelay = 2.0

-- Delay between baby farm cycles
Config.BabyFarmTickDelay = 2.0

-- Delay between egg hatch cycles
Config.EggHatchTickDelay = 2.0

-- Delay between age potion cycles
Config.AgePotionTickDelay = 2.0

---------------------------------------------------------------------
-- Ailments
---------------------------------------------------------------------

-- Default ailments to ignore
Config.DisabledAilments = {
    "sleep",
    "school",
    "pizza_party",
}

---------------------------------------------------------------------
-- Pet Settings
---------------------------------------------------------------------

Config.PetSettings = {
    AutoSwitchSameKind = true,
    AutoSwitchRandomKind = true,
    AutoSwitchSameAge = true,
}

---------------------------------------------------------------------
-- Egg Settings
---------------------------------------------------------------------

Config.EggSettings = {
    SwitchOutEggs = true,
    HatchAllEggs = false,
}

---------------------------------------------------------------------
-- Age Potion Settings
---------------------------------------------------------------------

Config.AgePotion = {
    PotionItemId = "pet_age_potion",
    MaxAge = 6,
}

---------------------------------------------------------------------
-- Furniture / Housing
---------------------------------------------------------------------

Config.Furniture = {
    LureName = "Lures2023NormalLure",
}

---------------------------------------------------------------------
-- Event Settings (Cherry Blossom / Kaiju Stomp)
---------------------------------------------------------------------

Config.Events = {
    Blossom = {
        QueuePosition = CFrame.new(74.27, 42.06, -1569.01),
        ReturnPosition = CFrame.new(111.01, 30.85, -1464.83),
        AFKPosition = CFrame.new(84.20, 35.31, -1351.55),
        RingMessageDelay = 3.2,
    },

    Kaiju = {
        QueuePosition = CFrame.new(74.27, 42.06, -1569.01),
        ReturnPosition = CFrame.new(111.01, 30.85, -1464.83),
        AFKPosition = CFrame.new(84.20, 35.31, -1351.55),
        MaxBuildingIndex = 3000,
        MessageBurstDelay = 0.1,
    },
}

---------------------------------------------------------------------
-- Webhooks
---------------------------------------------------------------------

Config.Webhook = {
    Enabled = false,
    Interval = 60, -- seconds
    URL = "",
}

---------------------------------------------------------------------
-- Debug Settings
---------------------------------------------------------------------

Config.Debug = {
    PrintRouterCalls = false,
    PrintAilments = false,
    PrintPetSwitches = false,
}

---------------------------------------------------------------------

return Config
