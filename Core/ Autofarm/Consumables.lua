--!strict
-- Core/Autofarm/Consumables.lua
-- Centralized consumable lookup & usage for TBIGUI v3.
-- Handles food, drinks, potions, and tool usage for pets & babies.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)

local Consumables = {}
Consumables.__index = Consumables

---------------------------------------------------------------------
-- Internal: Cached inventory
---------------------------------------------------------------------

local function GetInventory()
    return AdoptMeAPI.GetPlayersInventory()
end

---------------------------------------------------------------------
-- Find a consumable by kind
---------------------------------------------------------------------

function Consumables.FindByKind(kind: string): string?
    local inv = GetInventory()
    local food = inv.food

    for uniqueId, item in pairs(food) do
        if item.kind == kind then
            return uniqueId
        end
    end

    return nil
end

---------------------------------------------------------------------
-- Find any food item
---------------------------------------------------------------------

function Consumables.FindAnyFood(): string?
    local inv = GetInventory()
    local food = inv.food

    for uniqueId, item in pairs(food) do
        if item.kind ~= "pet_age_potion" then
            return uniqueId
        end
    end

    return nil
end

---------------------------------------------------------------------
-- Find any drink item
---------------------------------------------------------------------

function Consumables.FindAnyDrink(): string?
    local inv = GetInventory()
    local food = inv.food

    for uniqueId, item in pairs(food) do
        if item.kind == "water" or item.kind == "tea" or item.kind == "coffee" then
            return uniqueId
        end
    end

    return nil
end

---------------------------------------------------------------------
-- Ensure consumable exists (buy if missing)
---------------------------------------------------------------------

function Consumables.Ensure(kind: string): string?
    local found = Consumables.FindByKind(kind)
    if found then
        return found
    end

    -- Buy item
    AdoptMeAPI.BuyItem("food", kind, 1)
    task.wait(0.5)

    -- Re-scan
    return Consumables.FindByKind(kind)
end

---------------------------------------------------------------------
-- Give consumable to pet
---------------------------------------------------------------------

function Consumables.GiveToPet(petId: string, uniqueId: string)
    -- Create pet object
    AdoptMeAPI.CreatePetObject(petId, uniqueId, "food")

    -- Use tool
    AdoptMeAPI.UseTool(uniqueId)
end

---------------------------------------------------------------------
-- Feed pet (auto-selects food)
---------------------------------------------------------------------

function Consumables.FeedPet(petId: string)
    local foodId = Consumables.FindAnyFood()

    if not foodId then
        -- Buy apple as fallback
        AdoptMeAPI.BuyItem("food", "apple", 1)
        task.wait(0.5)
        foodId = Consumables.FindByKind("apple")
    end

    if not foodId then
        warn("[Consumables] Failed to obtain food.")
        return false
    end

    Consumables.GiveToPet(petId, foodId)
    return true
end

---------------------------------------------------------------------
-- Give drink to pet (auto-selects drink)
---------------------------------------------------------------------

function Consumables.GiveDrinkToPet(petId: string)
    local drinkId = Consumables.FindAnyDrink()

    if not drinkId then
        -- Buy water as fallback
        AdoptMeAPI.BuyItem("food", "water", 1)
        task.wait(0.5)
        drinkId = Consumables.FindByKind("water")
    end

    if not drinkId then
        warn("[Consumables] Failed to obtain drink.")
        return false
    end

    Consumables.GiveToPet(petId, drinkId)
    return true
end

---------------------------------------------------------------------
-- Give age potion to pet
---------------------------------------------------------------------

function Consumables.GiveAgePotion(petId: string)
    local potionKind = Config.AgePotion.PotionItemId

    local potionId = Consumables.FindByKind(potionKind)
    if not potionId then
        AdoptMeAPI.BuyItem("food", potionKind, 1)
        task.wait(0.5)
        potionId = Consumables.FindByKind(potionKind)
    end

    if not potionId then
        warn("[Consumables] Failed to obtain age potion.")
        return false
    end

    Consumables.GiveToPet(petId, potionId)
    return true
end

---------------------------------------------------------------------
-- Baby feeding
---------------------------------------------------------------------

function Consumables.FeedBaby()
    local foodId = Consumables.FindAnyFood()

    if not foodId then
        AdoptMeAPI.BuyItem("food", "apple", 1)
        task.wait(0.5)
        foodId = Consumables.FindByKind("apple")
    end

    if not foodId then
        warn("[Consumables] Failed to obtain baby food.")
        return false
    end

    AdoptMeAPI.UseTool(foodId)
    return true
end

function Consumables.GiveBabyDrink()
    local drinkId = Consumables.FindAnyDrink()

    if not drinkId then
        AdoptMeAPI.BuyItem("food", "water", 1)
        task.wait(0.5)
        drinkId = Consumables.FindByKind("water")
    end

    if not drinkId then
        warn("[Consumables] Failed to obtain baby drink.")
        return false
    end

    AdoptMeAPI.UseTool(drinkId)
    return true
end

---------------------------------------------------------------------

return Consumables
