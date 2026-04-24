--!strict
-- Core/Autofarm/CherryBlossomEngine.lua
-- Automates the Cherry Blossom minigame by collecting rings in sequence.

-- Use global import() defined in main.lua
local AdoptMeAPI = import("Core/AdoptMeAPI")
local Config = import("Core/Config")
local State = import("Core/State")

local PetWait = import("Core/Autofarm/PetWait")
local Platform = import("Core/Platform")
local Movement = import("Core/Movement")

local CherryBlossomEngine = {}
CherryBlossomEngine.__index = CherryBlossomEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.AutofarmCherryBlossom.State
        and State.FarmStates.AutofarmCherryBlossom.Running
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

local function TeleportToQueue()
    local pos = Config.Events.Blossom.QueuePosition
    Movement.TeleportTo(pos)
end

local function TeleportToReturn()
    local pos = Config.Events.Blossom.ReturnPosition
    Movement.TeleportTo(pos)
end

local function TeleportToAFK()
    local pos = Config.Events.Blossom.AFKPosition
    Movement.TeleportTo(pos)
end

local function GetRingModels()
    local folder = workspace:FindFirstChild("CherryBlossomEvent")
    if not folder then return {} end

    local rings = folder:FindFirstChild("Rings")
    if not rings then return {} end

    return rings:GetChildren()
end

local function CollectRing(ringModel)
    if not ringModel then return end

    AdoptMeAPI.RunRouterClient(true, "CherryBlossomEvent/CollectRing", {
        ringModel.Name
    })
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function CherryBlossomEngine.Start()
    if State.FarmStates.AutofarmCherryBlossom.Running then
        return
    end

    State.FarmStates.AutofarmCherryBlossom.Running = true
    LockEngine()

    task.spawn(function()
        Platform.Enable()

        while EngineActive() do
            task.wait(1)

            UpdateSessionStats()

            -- Step 1: Move to queue
            TeleportToQueue()
            task.wait(1)

            -- Step 2: Collect rings
            local rings = GetRingModels()

            for _, ring in ipairs(rings) do
                if not EngineActive() then break end

                CollectRing(ring)
                task.wait(Config.Events.Blossom.RingMessageDelay)
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
        State.FarmStates.AutofarmCherryBlossom.Running = false
    end)
end

function CherryBlossomEngine.Stop()
    State.FarmStates.AutofarmCherryBlossom.State = false
    State.FarmStates.AutofarmCherryBlossom.Running = false
    UnlockEngine()
    Platform.Disable()
end

return CherryBlossomEngine
