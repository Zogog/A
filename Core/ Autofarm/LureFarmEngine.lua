--!strict
-- Core/Autofarm/LureFarmEngine.lua
-- Automatically places and maintains lures for the player.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)
local State = require(script.Parent.Parent.State)

local PetWait = require(script.Parent.PetWait)
local Platform = require(script.Parent.Platform)
local Movement = require(script.Parent.Movement)

local LureFarmEngine = {}
LureFarmEngine.__index = LureFarmEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.LureAutofarm.State
        and State.FarmStates.LureAutofarm.Running
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
-- Lure Helpers
---------------------------------------------------------------------

local function FindLureFurniture()
    local lureName = Config.Furniture.LureName
    return AdoptMeAPI.GetFurniture(lureName)
end

local function LureExists()
    return FindLureFurniture() ~= false
end

local function PlaceLure()
    local lureName = Config.Furniture.LureName

    -- Buy lure if needed
    AdoptMeAPI.BuyItem("furniture", lureName, 1)
    task.wait(0.5)

    -- Place lure using furniture placement API
    AdoptMeAPI.RunRouterClient(false, "FurnitureAPI/PlaceFurniture", {
        lureName,
        { x = 0, y = 0, z = 0 }
    })

    task.wait(1)
end

local function ActivateLure()
    local lureFolder = FindLureFurniture()
    if not lureFolder then return end

    local baitKind = State.SelectedBaitKind
    if baitKind == "" then
        warn("[LureFarmEngine] No bait selected.")
        return
    end

    AdoptMeAPI.RunRouterClient(false, "LureAPI/ActivateLure", {
        lureFolder,
        baitKind
    })
end

local function LureIsActive()
    local lureFolder = FindLureFurniture()
    if not lureFolder then return false end

    -- Check if lure has an active state
    local lureModel = workspace.HouseInteriors.furniture:FindFirstChild(lureFolder)
    if not lureModel then return false end

    return lureModel:FindFirstChild("Active") ~= nil
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function LureFarmEngine.Start()
    if State.FarmStates.LureAutofarm.Running then
        return
    end

    State.FarmStates.LureAutofarm.Running = true
    LockEngine()

    task.spawn(function()
        Platform.Enable()

        while EngineActive() do
            task.wait(1)

            UpdateSessionStats()

            -- Ensure lure exists
            if not LureExists() then
                print("[LureFarmEngine] Placing lure...")
                PlaceLure()
                task.wait(1)
            end

            -- Ensure lure is active
            if not LureIsActive() then
                print("[LureFarmEngine] Activating lure...")
                ActivateLure()
                task.wait(1)
            end

            -- Wait for router cooldowns
            PetWait.WaitForPetActions()

            -- Keep player positioned correctly
            Movement.KeepPlayerNearPlatform()
        end

        Platform.Disable()
        UnlockEngine()
        State.FarmStates.LureAutofarm.Running = false
    end)
end

function LureFarmEngine.Stop()
    State.FarmStates.LureAutofarm.State = false
    State.FarmStates.LureAutofarm.Running = false
    UnlockEngine()
    Platform.Disable()
end

return LureFarmEngine
