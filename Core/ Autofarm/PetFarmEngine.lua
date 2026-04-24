--!strict
-- Core/Autofarm/PetFarmEngine.lua
-- Main pet autofarm engine for TBIGUI v3.
-- Handles pet ailments, switching, movement, and platform logic.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)
local State = require(script.Parent.Parent.State)

local Pets = require(script.Parent.Pets)
local PetAilments = require(script.Parent.PetAilments)
local PetWait = require(script.Parent.PetWait)
local Platform = require(script.Parent.Platform)
local Movement = require(script.Parent.Movement)

local PetFarmEngine = {}
PetFarmEngine.__index = PetFarmEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.PetAutofarm.State
        and State.FarmStates.PetAutofarm.Running
        and not State.EngineLock
end

local function LockEngine()
    State.EngineLock = true
end

local function UnlockEngine()
    State.EngineLock = false
end

local function EquipPets()
    local first = State.SelectedPets.FirstPet
    local second = State.SelectedPets.SecondPet

    if first ~= "" then
        AdoptMeAPI.EquipPet(first, true)
    end

    if second ~= "" then
        AdoptMeAPI.EquipPet(second, false)
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

function PetFarmEngine.Start()
    if State.FarmStates.PetAutofarm.Running then
        return
    end

    State.FarmStates.PetAutofarm.Running = true
    LockEngine()

    task.spawn(function()
        -- Initial setup
        Platform.Enable()
        EquipPets()

        while EngineActive() do
            task.wait(Config.PetFarmTickDelay)

            -- Update stats
            UpdateSessionStats()

            -- Validate pets
            local firstPet = State.SelectedPets.FirstPet
            local secondPet = State.SelectedPets.SecondPet

            if firstPet == "" and secondPet == "" then
                warn("[PetFarmEngine] No pets selected.")
                break
            end

            -- Handle ailments
            local ailments = AdoptMeAPI.GetAilments(
                firstPet,
                secondPet,
                false,
                State.DisabledAilments
            )

            -- First pet ailments
            for ailmentKind in pairs(ailments.FirstPet) do
                PetAilments.HandleAilment(firstPet, ailmentKind)
            end

            -- Second pet ailments
            for ailmentKind in pairs(ailments.SecondPet) do
                PetAilments.HandleAilment(secondPet, ailmentKind)
            end

            -- Wait for animations / router cooldowns
            PetWait.WaitForPetActions()

            -- Movement logic (optional)
            Movement.KeepPlayerNearPlatform()
        end

        -- Cleanup
        Platform.Disable()
        UnlockEngine()
        State.FarmStates.PetAutofarm.Running = false
    end)
end

function PetFarmEngine.Stop()
    State.FarmStates.PetAutofarm.State = false
    State.FarmStates.PetAutofarm.Running = false
    UnlockEngine()
    Platform.Disable()
end

return PetFarmEngine
