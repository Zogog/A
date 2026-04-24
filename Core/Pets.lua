--!strict
-- Core/Pets.lua
-- Centralized pet logic for TBIGUI v3.
-- Handles validation, switching, kind detection, rarity, and inventory scanning.

-- Use global import() defined in main.lua
local AdoptMeAPI = import("Core/AdoptMeAPI")

local Pets = {}
Pets.__index = Pets

---------------------------------------------------------------------
-- Internal: Inventory Access
---------------------------------------------------------------------

local function GetPetInventory()
    local inv = AdoptMeAPI.GetPlayersInventory()
    return inv.pets or {}
end

local function GetPetConfig(petId: string)
    return AdoptMeAPI.GetPlayersPetConfigs(petId)
end

---------------------------------------------------------------------
-- Validation
---------------------------------------------------------------------

function Pets.IsValidPet(petId: string): boolean
    if petId == "" then return false end

    local inv = GetPetInventory()
    return inv[petId] ~= nil
end

function Pets.IsEgg(petId: string): boolean
    if not Pets.IsValidPet(petId) then return false end

    local cfg = GetPetConfig(petId)
    return cfg.isEgg == true
end

---------------------------------------------------------------------
-- Kind & Rarity
---------------------------------------------------------------------

function Pets.GetKind(petId: string): string
    if not Pets.IsValidPet(petId) then return "unknown" end
    return GetPetConfig(petId).petKind or "unknown"
end

function Pets.GetRarity(petId: string): string
    if not Pets.IsValidPet(petId) then return "common" end
    return GetPetConfig(petId).rarity or "common"
end

function Pets.GetAgeName(petId: string): string
    if not Pets.IsValidPet(petId) then return "Unknown" end
    return GetPetConfig(petId).petAgeName or "Unknown"
end

---------------------------------------------------------------------
-- Equipped Pets
---------------------------------------------------------------------

function Pets.GetEquippedPets()
    return AdoptMeAPI.GetPlayersEquippedPets()
end

function Pets.IsEquipped(petId: string): boolean
    local eq = Pets.GetEquippedPets()
    return eq.FirstPet == petId or eq.SecondPet == petId
end

---------------------------------------------------------------------
-- Switching Helpers
---------------------------------------------------------------------

-- Find another pet of the same kind (excluding the current one)
function Pets.FindSameKindPet(currentPet: string, kind: string): string?
    local inv = GetPetInventory()

    for uid, data in pairs(inv) do
        if uid ~= currentPet then
            local cfg = GetPetConfig(uid)
            if cfg.petKind == kind then
                return uid
            end
        end
    end

    return nil
end

-- Find any pet of the same type (egg vs non-egg)
function Pets.FindRandomPetOfSameType(currentPet: string): string?
    local inv = GetPetInventory()
    local isEgg = Pets.IsEgg(currentPet)

    for uid, _ in pairs(inv) do
        if uid ~= currentPet then
            if Pets.IsEgg(uid) == isEgg then
                return uid
            end
        end
    end

    return nil
end

-- Find any pet of same rarity
function Pets.FindSameRarityPet(currentPet: string): string?
    local rarity = Pets.GetRarity(currentPet)
    local inv = GetPetInventory()

    for uid, _ in pairs(inv) do
        if uid ~= currentPet then
            if Pets.GetRarity(uid) == rarity then
                return uid
            end
        end
    end

    return nil
end

---------------------------------------------------------------------
-- Random Pet Helpers
---------------------------------------------------------------------

function Pets.GetRandomPet(): string?
    local inv = GetPetInventory()
    for uid in pairs(inv) do
        return uid -- first key = random enough for Roblox inventory
    end
    return nil
end

function Pets.GetRandomEgg(): string?
    local inv = GetPetInventory()
    for uid in pairs(inv) do
        if Pets.IsEgg(uid) then
            return uid
        end
    end
    return nil
end

---------------------------------------------------------------------
-- Sorting Helpers
---------------------------------------------------------------------

function Pets.GetPetsSortedByAge()
    local inv = GetPetInventory()
    local list = {}

    for uid, _ in pairs(inv) do
        local cfg = GetPetConfig(uid)
        table.insert(list, {
            uid = uid,
            age = cfg.petAge or 0,
        })
    end

    table.sort(list, function(a, b)
        return a.age < b.age
    end)

    return list
end

function Pets.GetYoungestPet(): string?
    local sorted = Pets.GetPetsSortedByAge()
    return sorted[1] and sorted[1].uid or nil
end

---------------------------------------------------------------------
-- Egg Helpers
---------------------------------------------------------------------

function Pets.GetEggs()
    local inv = GetPetInventory()
    local eggs = {}

    for uid in pairs(inv) do
        if Pets.IsEgg(uid) then
            table.insert(eggs, uid)
        end
    end

    return eggs
end

---------------------------------------------------------------------

return Pets
