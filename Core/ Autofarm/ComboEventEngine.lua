--!strict
-- Core/Autofarm/ComboEventEngine.lua
-- Runs Cherry Blossom and Kaiju Stomp events in sequence.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)
local State = require(script.Parent.Parent.State)

local PetWait = require(script.Parent.PetWait)
local Platform = require(script.Parent.Platform)
local Movement = require(script.Parent.Movement)

local ComboEventEngine = {}
ComboEventEngine.__index = ComboEventEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.AutofarmKaijuStompAndBlossom.State
        and State.FarmStates.AutofarmKaijuStompAndBlossom.Running
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
-- Cherry Blossom Helpers
---------------------------------------------------------------------

local function TeleportToBlossomQueue()
    Movement.TeleportTo(Config.Events.Blossom.QueuePosition)
end

local function TeleportToBlossomReturn()
    Movement.TeleportTo(Config.Events.Blossom.ReturnPosition)
end

local function TeleportToBlossomAFK()
    Movement.TeleportTo(Config.Events.Blossom.AFKPosition)
end

local function GetBlossomRings()
    local folder = workspace:FindFirstChild("CherryBlossomEvent")
    if not folder then return {} end

    local rings = folder:FindFirstChild("Rings")
    if not rings then return {} end

    return rings:GetChildren()
end

local function CollectBlossomRing(ringModel)
    if not ringModel then return end

    AdoptMeAPI.RunRouterClient(true, "CherryBlossomEvent/CollectRing", {
        ringModel.Name
    })
end

---------------------------------------------------------------------
-- Kaiju Stomp Helpers
---------------------------------------------------------------------

local function TeleportToKaijuQueue()
    Movement.TeleportTo(Config.Events.Kaiju.QueuePosition)
end

local function TeleportToKaijuReturn()
    Movement.TeleportTo(Config.Events.Kaiju.ReturnPosition)
end

local function TeleportToKaijuAFK()
    Movement.TeleportTo(Config.Events.Kaiju.AFKPosition)
end

local function GetKaijuBuildings()
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
-- Event Runners
---------------------------------------------------------------------

local function RunCherryBlossom()
    TeleportToBlossomQueue()
    task.wait(1)

    local rings = GetBlossomRings()
    for _, ring in ipairs(rings) do
        if not EngineActive() then break end
        CollectBlossomRing(ring)
        task.wait(Config.Events.Blossom.RingMessageDelay)
    end

    TeleportToBlossomReturn()
    task.wait(1)

    TeleportToBlossomAFK()
    task.wait(2)
end

local function RunKaijuStomp()
    TeleportToKaijuQueue()
    task.wait(1)

    local buildings = GetKaijuBuildings()
    for index, building in ipairs(buildings) do
        if not EngineActive() then break end
        if index > Config.Events.Kaiju.MaxBuildingIndex then break end

        SmashBuilding(building)
        task.wait(Config.Events.Kaiju.MessageBurstDelay)
    end

    TeleportToKaijuReturn()
    task.wait(1)

    TeleportToKaijuAFK()
    task.wait(2)
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function ComboEventEngine.Start()
    if State.FarmStates.AutofarmKaijuStompAndBlossom.Running then
        return
    end

    State.FarmStates.AutofarmKaijuStompAndBlossom.Running = true
    LockEngine()

    task.spawn(function()
        Platform.Enable()

        while EngineActive() do
            task.wait(1)

            UpdateSessionStats()

            -- Run Cherry Blossom
            if not EngineActive() then break end
            RunCherryBlossom()

            PetWait.WaitForPetActions()

            -- Run Kaiju Stomp
            if not EngineActive() then break end
            RunKaijuStomp()

            PetWait.WaitForPetActions()
        end

        Platform.Disable()
        UnlockEngine()
        State.FarmStates.AutofarmKaijuStompAndBlossom.Running = false
    end)
end

function ComboEventEngine.Stop()
    State.FarmStates.AutofarmKaijuStompAndBlossom.State = false
    State.FarmStates.AutofarmKaijuStompAndBlossom.Running = false
    UnlockEngine()
    Platform.Disable()
end

return ComboEventEngine
