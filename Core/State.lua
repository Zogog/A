--!strict
-- Core/State.lua
-- Dynamic runtime state for TBIGUI v3.
-- Engines read/write these values. Config.lua holds static constants.

local State = {}

---------------------------------------------------------------------
-- Autofarm State Flags
---------------------------------------------------------------------

-- Every autofarm engine has:
--   State   = user toggle (true/false)
--   Running = engine currently active (true/false)

State.FarmStates = {
    PetAutofarm = {
        State = false,
        Running = false,
    },

    BabyAutofarm = {
        State = false,
        Running = false,
    },

    AgePotionFarm = {
        State = false,
        Running = false,
    },

    AutoHatchEggs = {
        State = false,
        Running = false,
    },

    AutoGiveAgePotions = {
        State = false,
        Running = false,
    },

    AutofarmCherryBlossom = {
        State = false,
        Running = false,
    },

    AutofarmKaijuStomp = {
        State = false,
        Running = false,
    },

    AutofarmKaijuStompAndBlossom = {
        State = false,
        Running = false,
    },

    LureAutofarm = {
        State = false,
        Running = false,
    },
}

---------------------------------------------------------------------
-- Selected Pets / Eggs / Items
---------------------------------------------------------------------

State.SelectedPets = {
    FirstPet = "",
    SecondPet = "",
}

State.SelectedEgg = ""

State.SelectedBaitKind = "" -- used by LureFarmEngine

---------------------------------------------------------------------
-- Disabled Ailments (runtime)
---------------------------------------------------------------------

-- This is user‑controlled and overrides Config.DisabledAilments
State.DisabledAilments = {}

---------------------------------------------------------------------
-- Session Tracking
---------------------------------------------------------------------

State.Session = {
    BucksEarned = 0,
    PotionsFarmed = 0,

    InitialBucks = 0,
    InitialPotions = 0,

    StartTime = tick(),
}

---------------------------------------------------------------------
-- Runtime Toggles
---------------------------------------------------------------------

State.Runtime = {
    AFKPlaceEnabled = false,
    DebugEnabled = false,
}

---------------------------------------------------------------------
-- Config Index (for multi‑config support)
---------------------------------------------------------------------

State.ConfigIndex = 1
State.ConfigIndex2 = nil -- used by webhook logic in older TBIGUI

---------------------------------------------------------------------
-- Webhook Runtime State
---------------------------------------------------------------------

State.Webhook = {
    LastTick = 0,
    Enabled = false,
    URL = "",
}

---------------------------------------------------------------------
-- Internal Engine State
---------------------------------------------------------------------

-- Used by scheduler to prevent multiple engines from running at once
State.EngineLock = false

-- Used by PetFarmEngine / BabyFarmEngine
State.LastAilmentTick = 0

-- Used by EggHatchEngine
State.LastEggTick = 0

-- Used by AgePotionFarmEngine
State.LastPotionTick = 0

-- Used by event engines
State.LastEventTick = 0

---------------------------------------------------------------------

return State
