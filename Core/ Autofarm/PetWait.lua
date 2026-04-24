--!strict
-- Core/Autofarm/PetWait.lua
-- Centralized wait logic for TBIGUI v3.
-- Ensures engines do not spam RouterClient or break animations.

local PetWait = {}
PetWait.__index = PetWait

---------------------------------------------------------------------
-- Internal timing
---------------------------------------------------------------------

-- Minimum delay between router calls
local ROUTER_COOLDOWN = 0.35

-- Minimum delay after animations
local ANIMATION_DELAY = 0.5

-- Last time a router call was made
local lastRouterTick = 0

---------------------------------------------------------------------
-- Wait for router cooldown
---------------------------------------------------------------------

function PetWait.WaitForRouter()
    local now = tick()
    local delta = now - lastRouterTick

    if delta < ROUTER_COOLDOWN then
        task.wait(ROUTER_COOLDOWN - delta)
    end

    lastRouterTick = tick()
end

---------------------------------------------------------------------
-- Wait for pet animations
---------------------------------------------------------------------

function PetWait.WaitForAnimations()
    task.wait(ANIMATION_DELAY)
end

---------------------------------------------------------------------
-- Combined wait (used by all engines)
---------------------------------------------------------------------

function PetWait.WaitForPetActions()
    PetWait.WaitForRouter()
    PetWait.WaitForAnimations()
end

---------------------------------------------------------------------

return PetWait
