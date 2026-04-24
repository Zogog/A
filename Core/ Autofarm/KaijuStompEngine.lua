--!strict
-- Core/Autofarm/KaijuStompEngine.lua
-- Automates the Kaiju Stomp minigame by smashing buildings in sequence.

-- Use global import() defined in main.lua
local AdoptMeAPI = import("Core/AdoptMeAPI")
local Config = import("Core/Config")
local State = import("Core/State")

local PetWait = import("Core/Autofarm/PetWait")
local Platform = import("Core/Platform")
local Movement = import("Core/Movement")

local KaijuStompEngine = {}
KaijuStompEngine.__index = KaijuStompEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.AutofarmKaijuStomp.State
        and State.FarmStates.AutofarmKaijuStomp.Running
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

---------------------------------------------------------------------
-- Kaiju Helpers
---------------------------------------------------------------------

local function TeleportToQueue()
    Movement.TeleportTo(Config.Events.Kaiju.QueuePosition)
end

local function TeleportToReturn()
    Movement.TeleportTo(Config.Events.Kaiju.ReturnPosition)
end

local function TeleportToAFK()
    Movement.TeleportTo(Config.Events.Kaiju.AFKPosition)
end

local function GetBuildings()
    local folder = workspace:FindFirstChild("KaijuStompEvent")
    if not folder then return {} end

    local buildings = folder:FindFirstChild("Buildings")
    if not buildings then return {} end

    return buildings:GetChildren()
end

local function SmashBuilding(buildingModel)
    if not buildingModel then return end

    AdoptMeAPI.RunRouterClient(true, "KaijuStompEvent/SmashBuilding", {
        buildingModel.Name
    })
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function KaijuStompEngine.Start()
    if State.FarmStates.AutofarmKaijuStomp.Running then
        return
    end

    State.FarmStates.AutofarmKaijuStomp.Running = true
    LockEngine()

    task.spawn(function()
        Platform.Enable()

        while EngineActive() do
            task.wait(1)

            UpdateSessionStats()

            -- Step 1: Move to queue
            TeleportToQueue()
            task.wait(1)

            -- Step 2: Smash buildings
            local buildings = GetBuildings()

            for index, building in ipairs(buildings) do
                if not EngineActive() then break end
                if index > Config.Events.Kaiju.MaxBuildingIndex then break end

                SmashBuilding(building)
                task.wait(Config.Events.Kaiju.MessageBurstDelay)
            end

            -- Step 3: Return to safe spot
            TeleportToReturn()
            task.wait(1)

            -- Step 4: Move to AFK position
            TeleportToAFK()
            task.wait(2)

            -- Wait for cooldown
            PetWait.WaitForPetActions()
        end

        Platform.Disable()
        UnlockEngine()
        State.FarmStates.AutofarmKaijuStomp.Running = false
    end)
end

function KaijuStompEngine.Stop()
    State.FarmStates.AutofarmKaijuStomp.State = false
    State.FarmStates.AutofarmKaijuStomp.Running = false
    UnlockEngine()
    Platform.Disable()
end

return KaijuStompEngine
