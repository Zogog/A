--!strict
local ExtrasModule = import("Modules/Extras")

local Extras = {}
Extras.__index = Extras

function Extras.Build(Tabs)
    local tab = Tabs.Extras
    if not tab then return end

    tab:CreateLabel("Extras")

    tab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 200},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(v)
            ExtrasModule.SetWalkSpeed(v)
        end
    })

    tab:CreateSlider({
        Name = "JumpPower",
        Range = {50, 300},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(v)
            ExtrasModule.SetJumpPower(v)
        end
    })

    tab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Callback = function(v)
            ExtrasModule.SetAntiAFK(v)
        end
    })

    tab:CreateSlider({
        Name = "FPS Cap",
        Range = {30, 240},
        Increment = 10,
        CurrentValue = 60,
        Callback = function(v)
            ExtrasModule.SetFPSCap(v)
        end
    })
end

return Extras
