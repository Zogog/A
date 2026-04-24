--!strict
-- Core/Autofarm/EggHatchEngine.lua
-- Automatically hatches eggs by running ailment cycles until the egg disappears.

-- Use global import() defined in main.lua
local AdoptMeAPI = import("Core/AdoptMeAPI")
local Config = import("Core/Config")
local State = import("Core/State")

local Pets = import("Core/Autofarm/Pets")
local PetAilments = import("Core/Autofarm/PetAilments")
local PetWait = import("Core/Autofarm/PetWait")
local Platform = import("Core/Platform")
local Movement = import("Core/Movement")

local EggHatchEngine = {}
EggHatchEngine.__index = EggHatchEngine

---------------------------------------------------------------------
-- Internal helpers
---------------------------------------------------------------------

local function EngineActive()
    return State.FarmStates.AutoHatchEggs.State
        and State.FarmStates.AutoHatchEggs.Running
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

local function EquipEgg()
    local egg = State.SelectedEgg

    if egg == "" then
        warn("[EggHatchEngine] No egg selected.")
        return false
    end

    AdoptMeAPI.EquipPet(egg, true)
    return true
end

local function EggHatched(eggId: string)
    return AdoptMeAPI.IsEggNotThere(eggId)
end

local function SwitchEggIfNeeded(oldEgg: string)
    if not Config.EggSettings.SwitchOutEggs then
        return oldEgg
    end

    local kind = AdoptMeAPI.GetPlayersPetConfigs(oldEgg).petKind

    -- Try same kind first
    local sameKind = Pets.FindSameKindPet(oldEgg, kind)
    if sameKind then
        print("[EggHatchEngine] Switching to same-kind egg:", sameKind)
        return sameKind
    end

    -- Try random egg of same type (egg vs non-egg)
    local randomEgg = Pets.FindRandomPetOfSameType(oldEgg)
    if randomEgg then
        print("[EggHatchEngine] Switching to random egg:", randomEgg)
        return randomEgg
    end

    print("[EggHatchEngine] No more eggs available.")
    return ""
end

---------------------------------------------------------------------
-- Main loop
---------------------------------------------------------------------

function EggHatchEngine.Start()
    if State.FarmStates.AutoHatchEggs.Running then
        return
    end

    State.FarmStates.AutoHatchEggs.Running = true
    LockEngine()

    task.spawn(function()
        Platform.Enable()

        if not EquipEgg() then
            UnlockEngine()
            State.FarmStates.AutoHatchEggs.Running = false
            return
        end

        while EngineActive() do
            task.wait(Config.EggHatchTickDelay)

            UpdateSessionStats()

            local egg = State.SelectedEgg
            if egg == "" then break end

            -- Check if egg hatched
            if EggHatched(egg) then
                print("[EggHatchEngine] Egg hatched:", egg)

                local newEgg = SwitchEggIfNeeded(egg)
                State.SelectedEgg = newEgg

                if newEgg == "" then
                    print("[EggHatchEngine] No eggs left. Stopping.")
                    State.FarmStates.AutoHatchEggs.State = false
                    break
                end

                AdoptMeAPI.EquipPet(newEgg, true)
                continue
            end

            -- Get ailments for the egg
            local ailments = AdoptMeAPI.GetAilments(
                egg,
                nil,
                false,
                State.DisabledAilments
            )

            -- Handle egg ailments
            for ailmentKind in pairs(ailments.FirstPet) do
                PetAilments.HandleAilment(egg, ailmentKind)
            end

            PetWait.WaitForPetActions()
            Movement.KeepPlayerNearPlatform()
        end

        Platform.Disable()
        UnlockEngine()
        State.FarmStates.AutoHatchEggs.Running = false
    end)
end

function EggHatchEngine.Stop()
    State.FarmStates.AutoHatchEggs.State = false
    State.FarmStates.AutoHatchEggs.Running = false
    UnlockEngine()
    Platform.Disable()
end

return EggHatchEngine
