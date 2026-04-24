--!strict
-- UI/Sections/Autofarm.lua
-- Builds the Autofarm tab UI for ASTRAL/TBIGUI v3.

local RayfieldInit = require("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local State = require("State")
local Scheduler = require("Scheduler/AutofarmScheduler")

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
        CurrentValue = State.FarmStates.AutofarmPets.State,
        Callback = function(val)
            State.FarmStates.AutofarmPets.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Baby Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Baby Autofarm",
        CurrentValue = State.FarmStates.AutofarmBaby.State,
        Callback = function(val)
            State.FarmStates.AutofarmBaby.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Egg Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Egg Autofarm",
        CurrentValue = State.FarmStates.AutofarmEggs.State,
        Callback = function(val)
            State.FarmStates.AutofarmEggs.State = val
        end,
    })

    -----------------------------------------------------------------
    -- Age Potion Autofarm Toggle
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Age Potion Autofarm",
        CurrentValue = State.FarmStates.AutofarmAgePotions.State,
        Callback = function(val)
            State.FarmStates.AutofarmAgePotions.State = val
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
