--!strict
-- Scheduler/AutofarmScheduler.lua
-- Central dispatcher for all autofarm engines in TBIGUI v3.

-- Use global import() defined in main.lua
local State = import("Core/State")
local TimerReader = import("Core/Autofarm/TimerReader")

local Movement = import("Core/Movement")
local Platform = import("Core/Platform")

-- Engines
local PetFarmEngine = import("Core/Autofarm/PetFarmEngine")
local BabyFarmEngine = import("Core/Autofarm/BabyFarmEngine")
local EggHatchEngine = import("Core/Autofarm/EggHatchEngine")
local AgePotionFarmEngine = import("Core/Autofarm/AgePotionFarmEngine")
local LureFarmEngine = import("Core/Autofarm/LureFarmEngine")

local CherryBlossomEngine = import("Core/Autofarm/CherryBlossomEngine")
local KaijuStompEngine = import("Core/Autofarm/KaijuStompEngine")
local ComboEventEngine = import("Core/Autofarm/ComboEventEngine")

local AutofarmScheduler = {}
AutofarmScheduler.__index = AutofarmScheduler

---------------------------------------------------------------------
-- Internal Helpers
---------------------------------------------------------------------

local function AnyEngineRunning(): boolean
    for _, data in pairs(State.FarmStates) do
        if data.Running then
            return true
        end
    end
    return false
end

local function StopAllEngines()
    for _, data in pairs(State.FarmStates) do
        if data.Stop then
            data.Stop()
        end
    end
end

local function StartEngine(engineName: string)
    local data = State.FarmStates[engineName]
    if not data then return end
    if data.Start then
        data.Start()
    end
end

---------------------------------------------------------------------
-- Priority Logic
---------------------------------------------------------------------

local function TryStartEventEngines()
    -- Combo event takes priority if enabled
    if State.FarmStates.AutofarmKaijuStompAndBlossom.State then
        StartEngine("AutofarmKaijuStompAndBlossom")
        return true
    end

    -- Cherry Blossom
    if State.FarmStates.AutofarmCherryBlossom.State then
        if TimerReader.CherryIsActive() then
            StartEngine("AutofarmCherryBlossom")
            return true
        end
    end

    -- Kaiju Stomp
    if State.FarmStates.AutofarmKaijuStomp.State then
        if TimerReader.KaijuIsActive() then
            StartEngine("AutofarmKaijuStomp")
            return true
        end
    end

    return false
end

local function TryStartPetEngines()
    if State.FarmStates.AutofarmPets.State then
        StartEngine("AutofarmPets")
        return true
    end

    if State.FarmStates.AutofarmBaby.State then
        StartEngine("AutofarmBaby")
        return true
    end

    if State.FarmStates.AutofarmEggs.State then
        StartEngine("AutofarmEggs")
        return true
    end

    if State.FarmStates.AutofarmAgePotions.State then
        StartEngine("AutofarmAgePotions")
        return true
    end

    if State.FarmStates.LureAutofarm.State then
        StartEngine("LureAutofarm")
        return true
    end

    return false
end

---------------------------------------------------------------------
-- Main Loop
---------------------------------------------------------------------

function AutofarmScheduler.Start()
    if AutofarmScheduler.Running then
        return
    end

    AutofarmScheduler.Running = true

    task.spawn(function()
        Platform.Enable()

        while AutofarmScheduler.Running do
            task.wait(0.5)

            -- If an engine is running, do nothing
            if AnyEngineRunning() then
                continue
            end

            -- Try event engines first
            if TryStartEventEngines() then
                continue
            end

            -- Try pet/baby/egg/potion/lure engines
            if TryStartPetEngines() then
                continue
            end

            -- If nothing is running, keep player at AFK platform
            Movement.KeepPlayerNearPlatform()
        end

        StopAllEngines()
        Platform.Disable()
    end)
end

function AutofarmScheduler.Stop()
    AutofarmScheduler.Running = false
    StopAllEngines()
end

return AutofarmScheduler
