--!strict
-- UI/Sections/Extras.lua
-- Builds the Extras tab UI for ASTRAL/TBIGUI v3.

-- Use global import() defined in main.lua
local RayfieldInit = import("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local ExtrasModule = import("Modules/Extras")
local State = import("Core/State")

local ExtrasSection = {}
ExtrasSection.__index = ExtrasSection

---------------------------------------------------------------------
-- Build Extras Tab
---------------------------------------------------------------------

function ExtrasSection.Build(Tabs, Core, UI)
    local tab = Tabs.Extras

    -----------------------------------------------------------------
    -- Player Movement
    -----------------------------------------------------------------

    tab:CreateSection("Player Movement")

    tab:CreateSlider({
        Name = "WalkSpeed",
        Range = { 0, 100 },
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,
        Callback = function(value)
            ExtrasModule.SetWalkSpeed(value)
        end,
    })

    tab:CreateSlider({
        Name = "JumpPower",
        Range = { 0, 250 },
        Increment = 1,
        Suffix = "Power",
        CurrentValue = 50,
        Callback = function(value)
            ExtrasModule.SetJumpPower(value)
        end,
    })

    -----------------------------------------------------------------
    -- Performance
    -----------------------------------------------------------------

    tab:CreateSection("Performance")

    tab:CreateToggle({
        Name = "Disable Rendering (white screen, boosts FPS)",
        CurrentValue = false,
        Callback = function(state)
            ExtrasModule.SetRendering(not state)
        end,
    })

    tab:CreateSlider({
        Name = "FPS Cap",
        Range = { 5, 240 },
        Increment = 1,
        Suffix = "FPS",
        CurrentValue = 60,
        Callback = function(value)
            ExtrasModule.SetFPSCap(value)
        end,
    })

    -----------------------------------------------------------------
    -- Tick Delay
    -----------------------------------------------------------------

    tab:CreateSlider({
        Name = "Tick Delay",
        Range = { 0.1, 5 },
        Increment = 0.1,
        Suffix = "Seconds",
        CurrentValue = ExtrasModule.GetTickDelay(),
        Callback = function(value)
            ExtrasModule.SetTickDelay(value)
        end,
    })

    -----------------------------------------------------------------
    -- Quality of Life
    -----------------------------------------------------------------

    tab:CreateSection("Quality of Life")

    tab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = true,
        Callback = function(state)
            ExtrasModule.SetAntiAFK(state)
        end,
    })
end

---------------------------------------------------------------------

return ExtrasSection
