--!strict
-- Core/Autofarm/AFKManager.lua
-- Keeps the player at the AFK platform when no engines are running.

-- Use global import() defined in main.lua
local State = import("Core/State")
local Config = import("Core/Config")

local Movement = import("Core/Movement")
local Platform = import("Core/Platform")

local AFKManager = {}
AFKManager.__index = AFKManager

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function AnyEngineRunning(): boolean
    for _, data in pairs(State.FarmStates) do
        if data.Running then
            return true
        end
    end
    return false
end

local function ShouldAFK(): boolean
    return State.Runtime.AFKPlaceEnabled
        and not AnyEngineRunning()
        and not State.EngineLock
end

local function GetAFKPosition()
    return Config.AFK.Position
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function AFKManager.Start()
    if AFKManager.Running then
        return
    end

    AFKManager.Running = true

    task.spawn(function()
        Platform.Enable()

        while AFKManager.Running do
            task.wait(1)

            if ShouldAFK() then
                -- Keep player at AFK position
                local pos = GetAFKPosition()
                Movement.TeleportTo(pos)
            end
        end

        Platform.Disable()
    end)
end

function AFKManager.Stop()
    AFKManager.Running = false
end

return AFKManager
