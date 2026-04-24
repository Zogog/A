--!strict
-- UI/Sections/Events.lua
-- Builds the Events tab UI for ASTRAL/TBIGUI v3.

local RayfieldInit = require("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local State = require("State")
local TimerReader = require("TimerReader")

local EventsSection = {}
EventsSection.__index = EventsSection

---------------------------------------------------------------------
-- Build Events Tab
---------------------------------------------------------------------

function EventsSection.Build(Tabs, Core, UI)
    local tab = Tabs.Events

    -----------------------------------------------------------------
    -- Cherry Blossom
    -----------------------------------------------------------------

    tab:CreateSection("🌸 Cherry Blossom Event")

    tab:CreateToggle({
        Name = "Cherry Blossom Autofarm",
        CurrentValue = State.FarmStates.AutofarmCherryBlossom.State,
        Callback = function(val)
            State.FarmStates.AutofarmCherryBlossom.State = val
        end,
    })

    local BlossomTimer = tab:CreateLabel("Cherry Blossom Timer: Loading...")

    -----------------------------------------------------------------
    -- Kaiju Stomp
    -----------------------------------------------------------------

    tab:CreateSection("🦖 Kaiju Stomp Event")

    tab:CreateToggle({
        Name = "Kaiju Stomp Autofarm",
        CurrentValue = State.FarmStates.AutofarmKaijuStomp.State,
        Callback = function(val)
            State.FarmStates.AutofarmKaijuStomp.State = val
        end,
    })

    local KaijuTimer = tab:CreateLabel("Kaiju Stomp Timer: Loading...")

    -----------------------------------------------------------------
    -- Combo Event
    -----------------------------------------------------------------

    tab:CreateSection("⚡ Combo Event (Blossom + Kaiju)")

    tab:CreateToggle({
        Name = "Combo Event Autofarm",
        CurrentValue = State.FarmStates.AutofarmKaijuStompAndBlossom.State,
        Callback = function(val)
            State.FarmStates.AutofarmKaijuStompAndBlossom.State = val
        end,
    })

    local ComboTimer = tab:CreateLabel("Next Event: Loading...")

    -----------------------------------------------------------------
    -- Timer Updater Loop
    -----------------------------------------------------------------

    task.spawn(function()
        while task.wait(1) do
            -- Cherry Blossom
            local blossomActive = TimerReader.CherryIsActive()
            local blossomTime = TimerReader.GetCherryTimeRemaining()

            if blossomActive then
                BlossomTimer:Set("Cherry Blossom Timer: ACTIVE (" .. blossomTime .. "s)")
            else
                BlossomTimer:Set("Cherry Blossom Timer: " .. blossomTime .. "s")
            end

            -- Kaiju Stomp
            local kaijuActive = TimerReader.KaijuIsActive()
            local kaijuTime = TimerReader.GetKaijuTimeRemaining()

            if kaijuActive then
                KaijuTimer:Set("Kaiju Stomp Timer: ACTIVE (" .. kaijuTime .. "s)")
            else
                KaijuTimer:Set("Kaiju Stomp Timer: " .. kaijuTime .. "s")
            end

            -- Combo Event
            local nextEvent = TimerReader.GetNextEventTime()
            ComboTimer:Set("Next Event In: " .. nextEvent .. "s")
        end
    end)
end

---------------------------------------------------------------------

return EventsSection
