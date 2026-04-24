--!strict
-- Core/Autofarm/PetAilments.lua
-- Centralized ailment handling for pets and babies in TBIGUI v3.

-- Use global import() defined in main.lua
local AdoptMeAPI = import("Core/AdoptMeAPI")
local Config = import("Core/Config")
local State = import("Core/State")

local PetWait = import("Core/Autofarm/PetWait")
local Movement = import("Core/Movement")

local PetAilments = {}
PetAilments.__index = PetAilments

---------------------------------------------------------------------
-- Ailment Routing Table
---------------------------------------------------------------------

-- Each ailment maps to a handler function
local AilmentHandlers = {}

-- Baby-specific handlers
local BabyAilmentHandlers = {}

---------------------------------------------------------------------
-- Utility: Teleport to correct location
---------------------------------------------------------------------

local function GoToLocation(location: string)
    if location == "home" then
        AdoptMeAPI.GoToHome()
    elseif location == "school" then
        AdoptMeAPI.GoToStore("School")
    elseif location == "hospital" then
        AdoptMeAPI.GoToStore("Hospital")
    elseif location == "salon" then
        AdoptMeAPI.GoToStore("Salon")
    elseif location == "pizza" then
        AdoptMeAPI.GoToStore("PizzaShop")
    elseif location == "camp" then
        AdoptMeAPI.GoToStore("CampingShop")
    elseif location == "playground" then
        AdoptMeAPI.GoToStore("Playground")
    elseif location == "mainmap" then
        AdoptMeAPI.GoToMainMap()
    end

    task.wait(Config.PostTeleportDelay)
end

---------------------------------------------------------------------
-- Utility: Use furniture in home
---------------------------------------------------------------------

local function UseFurniture(furnitureName: string)
    local furnitureFolder = AdoptMeAPI.GetFurniture(furnitureName)
    if not furnitureFolder then
        warn("[PetAilments] Furniture not found:", furnitureName)
        return
    end

    AdoptMeAPI.RunRouterClient(false, "FurnitureAPI/UseFurniture", {
        furnitureFolder,
    })
end

---------------------------------------------------------------------
-- Ailment Handlers (Pets)
---------------------------------------------------------------------

AilmentHandlers["sleep"] = function(petId)
    GoToLocation("home")
    UseFurniture("Crib")
end

AilmentHandlers["clean"] = function(petId)
    GoToLocation("home")
    UseFurniture("Shower")
end

AilmentHandlers["hungry"] = function(petId)
    GoToLocation("home")
    UseFurniture("FoodBowl")
end

AilmentHandlers["thirsty"] = function(petId)
    GoToLocation("home")
    UseFurniture("WaterBowl")
end

AilmentHandlers["school"] = function(petId)
    GoToLocation("school")
end

AilmentHandlers["pizza_party"] = function(petId)
    GoToLocation("pizza")
end

AilmentHandlers["playground"] = function(petId)
    GoToLocation("playground")
end

AilmentHandlers["camping"] = function(petId)
    GoToLocation("camp")
end

AilmentHandlers["sick"] = function(petId)
    GoToLocation("hospital")
end

AilmentHandlers["salon"] = function(petId)
    GoToLocation("salon")
end

AilmentHandlers["perform"] = function(petId)
    AdoptMeAPI.RunRouterClient(true, "PetAPI/Perform", { petId })
end

AilmentHandlers["pet_me"] = function(petId)
    AdoptMeAPI.RunRouterClient(true, "PetAPI/PetPet", { petId })
end

---------------------------------------------------------------------
-- Baby Ailment Handlers
---------------------------------------------------------------------

BabyAilmentHandlers["sleep"] = function()
    GoToLocation("home")
    UseFurniture("Crib")
end

BabyAilmentHandlers["clean"] = function()
    GoToLocation("home")
    UseFurniture("Shower")
end

BabyAilmentHandlers["hungry"] = function()
    GoToLocation("home")
    UseFurniture("HighChair")
end

BabyAilmentHandlers["thirsty"] = function()
    GoToLocation("home")
    UseFurniture("HighChair")
end

BabyAilmentHandlers["school"] = function()
    GoToLocation("school")
end

BabyAilmentHandlers["pizza_party"] = function()
    GoToLocation("pizza")
end

BabyAilmentHandlers["playground"] = function()
    GoToLocation("playground")
end

BabyAilmentHandlers["camping"] = function()
    GoToLocation("camp")
end

BabyAilmentHandlers["sick"] = function()
    GoToLocation("hospital")
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

function PetAilments.HandleAilment(petId: string, ailmentKind: string)
    local handler = AilmentHandlers[ailmentKind]

    if not handler then
        warn("[PetAilments] No handler for ailment:", ailmentKind)
        return
    end

    handler(petId)

    -- Wait for animations / router cooldowns
    PetWait.WaitForPetActions()
end

function PetAilments.HandleBabyAilment(ailmentKind: string)
    local handler = BabyAilmentHandlers[ailmentKind]

    if not handler then
        warn("[PetAilments] No baby handler for ailment:", ailmentKind)
        return
    end

    handler()

    -- Wait for animations / router cooldowns
    PetWait.WaitForPetActions()
end

return PetAilments
