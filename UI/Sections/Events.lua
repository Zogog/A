--!strict
local State = import("Core/State")

local Events = {}
Events.__index = Events

function Events.Build(Tabs)
    local tab = Tabs.Events
    if not tab then return end

    tab:CreateLabel("Event Settings")

    tab:CreateToggle({
        Name = "Cherry Blossom Autofarm",
        CurrentValue = State.Events.Blossom,
        Callback = function(v)
            State.Events.Blossom = v
        end
    })

    tab:CreateToggle({
        Name = "Kaiju Stomp Autofarm",
        CurrentValue = State.Events.Kaiju,
        Callback = function(v)
            State.Events.Kaiju = v
        end
    })
end

return Events
