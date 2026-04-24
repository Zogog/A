--!strict
-- Core/Autofarm/BabyFarmEngine.lua
-- Baby autofarm engine for TBIGUI v3.
-- Handles baby ailments, movement, platform logic, and team switching.

-- Use global import() defined in main.lua
local AdoptMeAPI = import("Core/AdoptMeAPI")
local Config = import("Core/Config")
local State = import("Core/State")

local PetAilments = import("Core/Autofarm/PetAilments")
local PetWait = import("Core/Autofarm/PetWait")
local Platform = import("Core/Platform")
local Movement = import("Core/Movement")

local BabyFarmEngine = {}
BabyFarmEngine.__index = BabyFarmEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.BabyAutofarm.State
        and State.FarmStates.BabyAutofarm.Running
        and not State.EngineLock
end

local function LockEngine()
    State.EngineLock = true
end

local function UnlockEngine()
    State.EngineLock = false
end

local function EnsureBabyTeam()
    -- If player is not a baby, switch to baby team
    if AdoptMeAPI.GetCurrentInterior() ~= "Babies" then
        AdoptMeAPI.SetPlayerToBaby()
        task.wait(0.5)
    end
end

local function UpdateSessionStats()
    local money = AdoptMeAPI.GetPlayerMoney()
    local potions = AdoptMeAPI.GetPlayerPotionAmount()

    if money > State.Session.InitialBucks then
        State.Session.BucksEarned += (money - State.Session.InitialBucks)
    end

    if potions > State.Session.InitialPotions then
        State.Session.PotionsFarmed += (potions - State.Session.InitialPotions)
    end

    State.Session.InitialBucks = money
    State.Session.InitialPotions = potions
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function BabyFarmEngine.Start()
    if State.FarmStates.BabyAutofarm.Running then
        return
    end

    State.FarmStates.BabyAutofarm.Running = true
    LockEngine()

    task.spawn(function()
        -- Initial setup
        Platform.Enable()
        EnsureBabyTeam()

        while EngineActive() do
            task.wait(Config.BabyFarmTickDelay)

            -- Update stats
            UpdateSessionStats()

            -- Get baby ailments
            local ailments = AdoptMeAPI.GetAilments(
                nil,           -- First pet
                nil,           -- Second pet
                true,          -- Baby
                State.DisabledAilments
            )

            -- Handle baby ailments
            for ailmentKind in pairs(ailments.Baby) do
                PetAilments.HandleBabyAilment(ailmentKind)
            end

            -- Wait for animations / router cooldowns
            PetWait.WaitForPetActions()

            -- Keep player positioned correctly
            Movement.KeepPlayerNearPlatform()
        end

        -- Cleanup
        Platform.Disable()
        UnlockEngine()
        State.FarmStates.BabyAutofarm.Running = false
    end)
end

function BabyFarmEngine.Stop()
    State.FarmStates.BabyAutofarm.State = false
    State.FarmStates.BabyAutofarm.Running = false
    UnlockEngine()
    Platform.Disable()
end

return BabyFarmEngine
