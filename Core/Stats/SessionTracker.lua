--!strict
-- Stats/SessionTracker.lua
-- Centralized session statistics for TBIGUI v3.
-- All engines update this module. UI reads from it.

local SessionTracker = {}
SessionTracker.__index = SessionTracker

---------------------------------------------------------------------
-- Internal state
---------------------------------------------------------------------

local startTime = os.time()

local stats = {
    RuntimeSeconds = 0,

    BucksEarned = 0,
    PotionsFarmed = 0,
    EggsHatched = 0,
    PetsAged = 0,
    LureCatches = 0,

    BlossomRuns = 0,
    KaijuRuns = 0,
    ComboRuns = 0,
}

---------------------------------------------------------------------
-- Runtime
---------------------------------------------------------------------

function SessionTracker.UpdateRuntime()
    stats.RuntimeSeconds = os.time() - startTime
end

function SessionTracker.GetRuntime()
    return stats.RuntimeSeconds
end

---------------------------------------------------------------------
-- Currency & Items
---------------------------------------------------------------------

function SessionTracker.AddBucks(amount: number)
    stats.BucksEarned += amount
end

function SessionTracker.AddPotions(amount: number)
    stats.PotionsFarmed += amount
end

function SessionTracker.AddEggHatch()
    stats.EggsHatched += 1
end

function SessionTracker.AddPetAge()
    stats.PetsAged += 1
end

function SessionTracker.AddLureCatch()
    stats.LureCatches += 1
end

---------------------------------------------------------------------
-- Event Counters
---------------------------------------------------------------------

function SessionTracker.AddBlossomRun()
    stats.BlossomRuns += 1
end

function SessionTracker.AddKaijuRun()
    stats.KaijuRuns += 1
end

function SessionTracker.AddComboRun()
    stats.ComboRuns += 1
end

---------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------

function SessionTracker.GetStats()
    return stats
end

function SessionTracker.GetStat(key: string)
    return stats[key]
end

---------------------------------------------------------------------
-- Reset
---------------------------------------------------------------------

function SessionTracker.Reset()
    startTime = os.time()

    for k in pairs(stats) do
        stats[k] = 0
    end
end

---------------------------------------------------------------------

return SessionTracker
