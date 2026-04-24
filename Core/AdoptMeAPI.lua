-- Core/AdoptMeAPI.lua
-- Internal Adopt Me client API wrapper for TBIGUI v3
-- Uses the same internal calls as the original script, but organized and lightly cleaned.

local AdoptMeAPI = {}
AdoptMeAPI.__index = AdoptMeAPI

---------------------------------------------------------------------
-- Services & Locals
---------------------------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local getiden = getthreadidentity or getidentity
local setiden = setthreadidentity or setidentity

local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
local RouterClient = require(ReplicatedStorage.ClientModules.Core.RouterClient.RouterClient)
local InteriorsM = require(ReplicatedStorage.ClientModules.Core.InteriorsM.InteriorsM)

---------------------------------------------------------------------
-- Utility helpers
---------------------------------------------------------------------

function AdoptMeAPI.getLastSegment(path: string)
    return string.match(path, ".*/(.*)")
end

function AdoptMeAPI.isOnlyLetters(text: string)
    return text:match("^[A-Za-z]+$") ~= nil
end

function AdoptMeAPI.GetNumberBeforeEqual(text: string)
    return string.match(text, "^(%d+)")
end

function AdoptMeAPI.GetIdInBracket(id: string)
    return string.match(id, "%((.-)%)")
end

function AdoptMeAPI.isTableEmpty(t: table)
    return next(t) == nil
end

function AdoptMeAPI.GetFirstSixLetters(text: string)
    return string.sub(text, 1, 6)
end

function AdoptMeAPI.extractName(name: string)
    local exclamationIndex = string.find(name, "!")
    local doubleColonIndex = string.find(name, "::")

    if exclamationIndex then
        return string.sub(name, 1, exclamationIndex - 1)
    elseif doubleColonIndex then
        return string.sub(name, 1, doubleColonIndex - 1)
    else
        return name
    end
end

function AdoptMeAPI.NaturalSort(str1: string, str2: string)
    local function padNum(num)
        return ("%09d"):format(tonumber(num) or 0)
    end

    str1 = str1:gsub("(%d+)", padNum)
    str2 = str2:gsub("(%d+)", padNum)

    return str1 < str2
end

---------------------------------------------------------------------
-- Interior / location helpers
---------------------------------------------------------------------

function AdoptMeAPI.GetPlayerInterior()
    if workspace:FindFirstChild("HouseInteriors").furniture:FindFirstChildWhichIsA("Folder") then
        if string.find(workspace:FindFirstChild("HouseInteriors").furniture:FindFirstChildWhichIsA("Folder").Name, LocalPlayer.Name)
            or string.find(workspace:FindFirstChild("HouseInteriors").blueprint:FindFirstChildWhichIsA("Model").Name, LocalPlayer.Name) then
            return "House"
        else
            if workspace.Interiors:FindFirstChildWhichIsA("Model") then
                return AdoptMeAPI.extractName(workspace.Interiors:FindFirstChildWhichIsA("Model").Name)
            else
                return nil
            end
        end
    else
        if workspace.Interiors:FindFirstChildWhichIsA("Model") then
            return AdoptMeAPI.extractName(workspace.Interiors:FindFirstChildWhichIsA("Model").Name)
        else
            return nil
        end
    end
end

function AdoptMeAPI.GetCurrentInterior()
    return InteriorsM.get_current_location().destination_id
end

---------------------------------------------------------------------
-- ClientData / inventory helpers
---------------------------------------------------------------------

function AdoptMeAPI.GetPlayersInventory()
    return ClientData.get_data()[LocalPlayer.Name].inventory
end

function AdoptMeAPI.GetPlayerMoney()
    return ClientData.get_data()[LocalPlayer.Name].money
end

function AdoptMeAPI.GetHouseInterior()
    return ClientData.get_server(LocalPlayer, "house_interior").player
end

function AdoptMeAPI.GetAilmentsManager()
    return ClientData.get_server(LocalPlayer, "ailments_manager")
end

function AdoptMeAPI.GetPetPetEntityManager()
    return require(ReplicatedStorage.ClientModules.Game.PetEntities.PetEntityManager)
end

function AdoptMeAPI.InventoryDB()
    return require(ReplicatedStorage.ClientDB.Inventory.InventoryDB)
end

function AdoptMeAPI.GetCertificate()
    return ClientData.get("subscription_manager").equip_2x_pets.active
end

---------------------------------------------------------------------
-- Internal: LocationAPI / SetLocation
---------------------------------------------------------------------

local Location
for _, v in next, getgc() do
    if type(v) == "function" and islclosure(v) and table.find(getconstants(v), "LocationAPI/SetLocation") then
        Location = v
        break
    end
end

local function SetLocation(A, B, C)
    local old = getiden()
    setiden(2)
    Location(A, B, C)
    setiden(old)
end

local function GetInteriorModel()
    return workspace.Interiors:FindFirstChildWhichIsA("Model")
end

local function Store()
    local storeModel = GetInteriorModel()
    return (storeModel and not storeModel.Name:find("MainMap") and not storeModel.Name:find("Neighborhood")) and storeModel.Name or false
end

local function GetHomeModel()
    return workspace.HouseInteriors.blueprint:FindFirstChildWhichIsA("Model")
end

local function Home()
    local homeModel = GetHomeModel()
    return homeModel and homeModel.Name or false
end

local function MainMap()
    local mapModel = GetInteriorModel()
    return (mapModel and mapModel.Name:find("MainMap")) and mapModel.Name or false
end

local function Neighborhood()
    local neighborhoodModel = GetInteriorModel()
    return (neighborhoodModel and neighborhoodModel.Name:find("Neighborhood")) and neighborhoodModel.Name or false
end

local function TeleportAndWait(LocationName, Door, Params, Condition)
    SetLocation(LocationName, Door, Params)
    return true
end

---------------------------------------------------------------------
-- Teleport API
---------------------------------------------------------------------

function AdoptMeAPI.GoToStore(Name: string)
    if Store() == Name then
        return true
    end

    return TeleportAndWait(Name, "MainDoor", {}, function()
        return Store() == Name
    end)
end

function AdoptMeAPI.GoToMainMap()
    return TeleportAndWait("MainMap", "Neighborhood/MainDoor", {}, MainMap)
end

function AdoptMeAPI.GoToHome()
    return TeleportAndWait("housing", "MainDoor", { house_owner = LocalPlayer }, Home)
end

function AdoptMeAPI.GoToNeighborhood()
    return TeleportAndWait("Neighborhood", "MainDoor", {}, Neighborhood)
end

---------------------------------------------------------------------
-- Router wrapper
---------------------------------------------------------------------

function AdoptMeAPI.RunRouterClient(IsFire: boolean, RouterName: string, args: table?)
    local old = getiden()
    setiden(2)

    if IsFire then
        if args then
            RouterClient.get(RouterName):FireServer(unpack(args))
        else
            RouterClient.get(RouterName):FireServer()
        end
    else
        if args then
            RouterClient.get(RouterName):InvokeServer(unpack(args))
        else
            RouterClient.get(RouterName):InvokeServer()
        end
    end

    setiden(old)
end

---------------------------------------------------------------------
-- Money / potions
---------------------------------------------------------------------

function AdoptMeAPI.GetPlayerPotionAmount()
    local PlayerInv = AdoptMeAPI.GetPlayersInventory()
    local PlayerInventoryFood = PlayerInv.food
    local NewPlayerAgePotion = 0

    for _, v in pairs(PlayerInventoryFood) do
        if v.kind == "pet_age_potion" then
            NewPlayerAgePotion = NewPlayerAgePotion + 1
        end
    end

    return NewPlayerAgePotion or 0
end

---------------------------------------------------------------------
-- Team API
---------------------------------------------------------------------

function AdoptMeAPI.SetPlayerToParent()
    local args = {
        [1] = "Parents",
        [2] = {
            dont_respawn = true,
            source_for_logging = "avatar_editor",
        },
    }

    AdoptMeAPI.RunRouterClient(false, "TeamAPI/ChooseTeam", args)
end

function AdoptMeAPI.SetPlayerToBaby()
    local args = {
        [1] = "Babies",
        [2] = {
            dont_respawn = true,
            source_for_logging = "avatar_editor",
        },
    }

    AdoptMeAPI.RunRouterClient(false, "TeamAPI/ChooseTeam", args)
end

---------------------------------------------------------------------
-- Inventory helpers (food, pets, configs)
---------------------------------------------------------------------

function AdoptMeAPI.GetFoodToGive(foodidGave: string)
    local Inventory = AdoptMeAPI.GetPlayersInventory()
    local food = Inventory.food

    local foodid = ""

    for id, foodItem in pairs(food) do
        if foodItem.id == foodidGave then
            foodid = id
            break
        end
    end

    return foodid
end

function AdoptMeAPI.GetPlayersPetConfigs(PetUnique: string)
    local PetConfigs = {
        petKind = "",
        petAge = 1,
    }

    for i, v in pairs(AdoptMeAPI.GetPlayersInventory().pets) do
        if i == PetUnique then
            PetConfigs.petKind = v.kind or ""
            PetConfigs.petAge = v.properties.age or 1
            break
        end
    end

    return PetConfigs
end

function AdoptMeAPI.GetPetConfigs(PetKind: string)
    local PetConfigs = {
        isEgg = false,
    }

    for i, v in pairs(AdoptMeAPI.InventoryDB().pets) do
        if i == PetKind then
            PetConfigs.isEgg = v.is_egg or false
            break
        end
    end

    return PetConfigs
end

function AdoptMeAPI.GetPlayersEquippedPets()
    return ClientData.get_data()[LocalPlayer.Name].equip_manager.pets
end

function AdoptMeAPI.GetCurrentPet(PetUnique: string)
    local CurrentPet = {}

    for _, v in next, AdoptMeAPI.GetPetPetEntityManager().get_local_owned_pet_entities() do
        if string.find(v.unique_id, PetUnique, 1, true) then
            CurrentPet = v
            break
        end
    end

    return CurrentPet
end

---------------------------------------------------------------------
-- Ailments
---------------------------------------------------------------------

function AdoptMeAPI.GetAilments(PetUnique1: string?, PetUnique2: string?, BabyUnique: boolean?, DisabledAilments: table?)
    local Ailments = {
        FirstPet = {},
        SecondPet = {},
        Baby = {},
    }

    local AilmentsManager = AdoptMeAPI.GetAilmentsManager()
    local PetAilments = AilmentsManager.ailments
    local BabyAilments = AilmentsManager.baby_ailments

    if BabyUnique then
        for _, v in pairs(BabyAilments) do
            if DisabledAilments and not table.find(DisabledAilments, v.kind) then
                Ailments.Baby[v.kind] = {}
            end
        end
    end

    for i, v in pairs(PetAilments) do
        if not PetUnique1 and not PetUnique2 then
            break
        end

        if i == PetUnique1 then
            for _, v2 in pairs(v) do
                if DisabledAilments and not table.find(DisabledAilments, v2.kind) then
                    Ailments.FirstPet[v2.kind] = {}
                end
            end
        elseif i == PetUnique2 then
            for _, v2 in pairs(v) do
                if DisabledAilments and not table.find(DisabledAilments, v2.kind) then
                    Ailments.SecondPet[v2.kind] = {}
                end
            end
        end
    end

    return Ailments
end

---------------------------------------------------------------------
-- Equip / unequip pets
---------------------------------------------------------------------

function AdoptMeAPI.EquipPet(PetUnique: string, AsLast: boolean?)
    local args = {
        [1] = PetUnique,
        [2] = {
            equip_as_last = AsLast or false,
            use_sound_delay = false,
        },
    }

    AdoptMeAPI.RunRouterClient(false, "ToolAPI/Equip", args)
    print(PetUnique .. " Equipped")
end

function AdoptMeAPI.UnequipPet(PetUnique: string, AsLast: boolean?)
    local args = {
        [1] = PetUnique,
        [2] = {
            equip_as_last = AsLast or false,
            use_sound_delay = false,
        },
    }

    AdoptMeAPI.RunRouterClient(false, "ToolAPI/Unequip", args)
end

function AdoptMeAPI.UnequipAllPets()
    for _, v in pairs(AdoptMeAPI.GetPlayersEquippedPets()) do
        if v.unique then
            print(v.unique .. " unequipped")
            AdoptMeAPI.UnequipPet(v.unique)
        end
    end
end

---------------------------------------------------------------------
-- Furniture
---------------------------------------------------------------------

function AdoptMeAPI.GetFurniture(Furniture: string)
    local HouseInteriorsNew = workspace:WaitForChild("HouseInteriors")

    for _, v in pairs(HouseInteriorsNew:WaitForChild("furniture"):GetChildren()) do
        task.wait()

        for _, v2 in pairs(v:GetChildren()) do
            task.wait()

            if v2.Name == Furniture then
                return AdoptMeAPI.getLastSegment(v.Name)
            end
        end
    end

    return false
end

---------------------------------------------------------------------
-- Egg helpers
---------------------------------------------------------------------

function AdoptMeAPI.IsEggNotThere(EggUnique: string)
    local IsEggThere = false

    local Success, Err = pcall(function()
        for i, _ in pairs(AdoptMeAPI.GetPlayersInventory().pets) do
            task.wait()

            if i == EggUnique then
                IsEggThere = true
                break
            else
                IsEggThere = false
            end
        end
    end)

    if not Success then
        warn("Something went wrong while checking if egg is still there: " .. Err)
        return false
    else
        if IsEggThere then
            return false
        else
            return true
        end
    end
end

function AdoptMeAPI.GetSameKind(PetUnique1: string, PetUnique2: string, PetKind: string)
    for i, v in pairs(AdoptMeAPI.GetPlayersInventory().pets) do
        if i == PetUnique1 or i == PetUnique2 then
            continue
        end

        if v.kind == PetKind then
            return i
        end
    end
end

function AdoptMeAPI.GetRandomKind(PetUniqueToSearch: string, PetUniqueToSkip: string)
    for i, v in pairs(AdoptMeAPI.GetPlayersInventory().pets) do
        if i == PetUniqueToSearch or i == PetUniqueToSkip then
            continue
        end

        local PetConfigs = AdoptMeAPI.GetPetConfigs(AdoptMeAPI.GetPlayersPetConfigs(PetUniqueToSearch).petKind)
        local PetToSearch = AdoptMeAPI.GetPetConfigs(v.kind)

        if PetConfigs.isEgg and PetToSearch.isEgg then
            return i
        elseif not PetConfigs.isEgg and not PetToSearch.isEgg then
            return i
        end
    end
end

---------------------------------------------------------------------
-- Return
---------------------------------------------------------------------

return AdoptMeAPI
