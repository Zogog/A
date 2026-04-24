--!strict
-- UI/Sections/Autofarm.lua
-- Builds the Autofarm tab UI for ASTRAL/TBIGUI v3.

-- Use global import() defined in main.lua
local RayfieldInit = import("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local State = import("Core/State")
local Scheduler = import("Core/Scheduler/AutofarmScheduler")

local AutofarmSection = {}
AutofarmSection.__index = AutofarmSection

---------------------------------------------------------------------
-- Build Autofarm Tab
---------------------------------------------------------------------

function AutofarmSection.Build(Tabs, Core, UI)
    local tab = Tabs.Autofarm

    tab:CreateSection("Pet Autofarm")

    -----------------------------------------------------------------
    -- Pet Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Pet Autofarm",
        CurrentValue = State.FarmStates.PetAutofarm.State,
        Callback = function(val)
            State.FarmStates.PetAutofarm.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Baby Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Baby Autofarm",
        CurrentValue = State.FarmStates.BabyAutofarm.State,
        Callback = function(val)
            State.FarmStates.BabyAutofarm.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Egg Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Egg Autofarm",
        CurrentValue = State.FarmStates.AutoHatchEggs.State,
        Callback = function(val)
            State.FarmStates.AutoHatchEggs.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Age Potion Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Age Potion Autofarm",
        CurrentValue = State.FarmStates.AgePotionFarm.State,
        Callback = function(val)
            State.FarmStates.AgePotionFarm.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Lure Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Lure Autofarm",
        CurrentValue = State.FarmStates.LureAutofarm.State,
        Callback = function(val)
            State.FarmStates.LureAutofarm.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Event Autofarms
    -----------------------------------------------------------------

    tab:CreateSection("Event Autofarms")

    tab:CreateToggle({
        Name = "Cherry Blossom Autofarm",
        CurrentValue = State.FarmStates.AutofarmCherryBlossom.State,
        Callback = function(val)
            State.FarmStates.AutofarmCherryBlossom.State = val
        end,
    })

    tab:CreateToggle({
        Name = "Kaiju Stomp Autofarm",
        CurrentValue = State.FarmStates.AutofarmKaijuStomp.State,
        Callback = function(val)
            State.FarmStates.AutofarmKaijuStomp.State = val
        end,
    })

    tab:CreateToggle({
        Name = "Combo Event Autofarm (Blossom + Kaiju)",
        CurrentValue = State.FarmStates.AutofarmKaijuStompAndBlossom.State,
        Callback = function(val)
            State.FarmStates.AutofarmKaijuStompAndBlossom.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Scheduler Controls
    -----------------------------------------------------------------

    tab:CreateSection("Scheduler")

    tab:CreateButton({
        Name = "Start Scheduler",
        Callback = function()
            Scheduler.Start()
        end,
    })

    tab:CreateButton({
        Name = "Stop Scheduler",
        Callback = function()
            Scheduler.Stop()
        end,
    })
end

---------------------------------------------------------------------

return AutofarmSection
