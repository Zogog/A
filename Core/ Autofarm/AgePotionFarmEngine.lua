--!strict
-- Core/Autofarm/AgePotionFarmEngine.lua
-- Farms age potions by running pet ailments until max age is reached.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)
local State = require(script.Parent.Parent.State)

local Pets = require(script.Parent.Pets)
local PetAilments = require(script.Parent.PetAilments)
local PetWait = require(script.Parent.PetWait)
local Platform = require(script.Parent.Platform)
local Movement = require(script.Parent.Movement)

local AgePotionFarmEngine = {}
AgePotionFarmEngine.__index = AgePotionFarmEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.AgePotionFarm.State
        and State.FarmStates.AgePotionFarm.Running
        and not State.EngineLock
end

local function LockEngine()
    State.EngineLock = true
end

local function UnlockEngine()
    State.EngineLock = false
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

local function EquipPetForPotionFarm()
    local pet = State.SelectedPets.FirstPet

    if pet == "" then
        warn("[AgePotionFarmEngine] No pet selected for potion farm.")
        return false
    end

    AdoptMeAPI.EquipPet(pet, true)
    return true
end

local function PetReachedMaxAge(petId: string)
    local cfg = AdoptMeAPI.GetPlayersPetConfigs(petId)
    return cfg.petAge >= Config.AgePotion.MaxAge
end

local function SwitchPetIfNeeded()
    local pet = State.SelectedPets.FirstPet
    if pet == "" then return end

    if PetReachedMaxAge(pet) then
        local kind = AdoptMeAPI.GetPlayersPetConfigs(pet).petKind
        local newPet = Pets.FindSameKindPet(pet, kind)

        if newPet then
            State.SelectedPets.FirstPet = newPet
            AdoptMeAPI.EquipPet(newPet, true)
            print("[AgePotionFarmEngine] Switched to new pet:", newPet)
        else
            print("[AgePotionFarmEngine] No more pets of same kind. Stopping farm.")
            State.FarmStates.AgePotionFarm.State = false
        end
    end
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function AgePotionFarmEngine.Start()
    if State.FarmStates.AgePotionFarm.Running then
        return
    end

    State.FarmStates.AgePotionFarm.Running = true
    LockEngine()

    task.spawn(function()
        -- Initial setup
        Platform.Enable()

        if not EquipPetForPotionFarm() then
            UnlockEngine()
            State.FarmStates.AgePotionFarm.Running = false
            return
        end

        while EngineActive() do
            task.wait(Config.AgePotionTickDelay)

            -- Update stats
            UpdateSessionStats()

            local pet = State.SelectedPets.FirstPet
            if pet == "" then break end

            -- Check if pet reached max age
            SwitchPetIfNeeded()

            -- Get ailments for the pet
            local ailments = AdoptMeAPI.GetAilments(
                pet,
                nil,
                false,
                State.DisabledAilments
            )

            -- Handle ailments
            for ailmentKind in pairs(ailments.FirstPet) do
                PetAilments.HandleAilment(pet, ailmentKind)
            end

            -- Wait for animations / router cooldowns
            PetWait.WaitForPetActions()

            -- Keep player positioned correctly
            Movement.KeepPlayerNearPlatform()
        end

        -- Cleanup
        Platform.Disable()
        UnlockEngine()
        State.FarmStates.AgePotionFarm.Running = false
    end)
end

function AgePotionFarmEngine.Stop()
    State.FarmStates.AgePotionFarm.State = false
    State.FarmStates.AgePotionFarm.Running = false
    UnlockEngine()
    Platform.Disable()
end

return AgePotionFarmEngine
