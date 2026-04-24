--!strict
-- Core/Autofarm/AgePotionGiver.lua
-- Automatically gives age potions to the selected pet.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)
local State = require(script.Parent.Parent.State)

local Pets = require(script.Parent.Pets)
local PetWait = require(script.Parent.PetWait)
local Movement = require(script.Parent.Movement)
local Platform = require(script.Parent.Platform)

local AgePotionGiver = {}
AgePotionGiver.__index = AgePotionGiver

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.AutoGiveAgePotions.State
        and State.FarmStates.AutoGiveAgePotions.Running
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

local function EnsurePotionAvailable()
    local count = AdoptMeAPI.GetPlayerPotionAmount()

    if count > 0 then
        return true
    end

    -- Buy potion
    AdoptMeAPI.BuyItem("food", Config.AgePotion.PotionItemId, 1)
    task.wait(0.5)

    return AdoptMeAPI.GetPlayerPotionAmount() > 0
end

local function EquipPet()
    local pet = State.SelectedPets.FirstPet

    if pet == "" then
        warn("[AgePotionGiver] No pet selected.")
        return false
    end

    AdoptMeAPI.EquipPet(pet, true)
    return true
end

local function GivePotionToPet(petId: string)
    local potionId = Config.AgePotion.PotionItemId

    -- Find potion in inventory
    local inv = AdoptMeAPI.GetPlayersInventory()
    local food = inv.food

    local potionUnique = nil
    for uid, item in pairs(food) do
        if item.kind == potionId then
            potionUnique = uid
            break
        end
    end

    if not potionUnique then
        warn("[AgePotionGiver] No potion found after purchase.")
        return false
    end

    -- Create pet object (potion)
    AdoptMeAPI.CreatePetObject(petId, potionUnique, "food")

    -- Use potion
    AdoptMeAPI.UseTool(potionUnique)

    return true
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function AgePotionGiver.Start()
    if State.FarmStates.AutoGiveAgePotions.Running then
        return
    end

    State.FarmStates.AutoGiveAgePotions.Running = true
    LockEngine()

    task.spawn(function()
        Platform.Enable()

        if not EquipPet() then
            UnlockEngine()
            State.FarmStates.AutoGiveAgePotions.Running = false
            return
        end

        while EngineActive() do
            task.wait(1)

            UpdateSessionStats()

            local pet = State.SelectedPets.FirstPet
            if pet == "" then break end

            -- Ensure potion exists
            if not EnsurePotionAvailable() then
                warn("[AgePotionGiver] Could not obtain potion.")
                break
            end

            -- Give potion
            if GivePotionToPet(pet) then
                print("[AgePotionGiver] Gave potion to:", pet)
            end

            -- Wait for animations / router cooldowns
            PetWait.WaitForPetActions()

            -- Keep player positioned correctly
            Movement.KeepPlayerNearPlatform()
        end

        Platform.Disable()
        UnlockEngine()
        State.FarmStates.AutoGiveAgePotions.Running = false
    end)
end

function AgePotionGiver.Stop()
    State.FarmStates.AutoGiveAgePotions.State = false
    State.FarmStates.AutoGiveAgePotions.Running = false
    UnlockEngine()
    Platform.Disable()
end

return AgePotionGiver
