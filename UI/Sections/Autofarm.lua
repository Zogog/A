--!strict
local AdoptMeAPI = import("Core/AdoptMeAPI")
local State = import("Core/State")

local Autofarm = {}
Autofarm.__index = Autofarm

function Autofarm.Build(Tabs)
    local tab = Tabs.Autofarm
    if not tab then return end

    tab:CreateLabel("Autofarm Settings")

    tab:CreateToggle({
        Name = "Enable Autofarm",
        CurrentValue = State.Autofarm.Enabled,
        Callback = function(v)
            State.Autofarm.Enabled = v
        end
    })

    tab:CreateToggle({
        Name = "Baby Farm",
        CurrentValue = State.Autofarm.BabyFarm,
        Callback = function(v)
            State.Autofarm.BabyFarm = v
        end
    })

    tab:CreateToggle({
        Name = "Pet Farm",
        CurrentValue = State.Autofarm.PetFarm,
        Callback = function(v)
            State.Autofarm.PetFarm = v
        end
    })
end

return Autofarm
