--!strict
-- UI/Tabs.lua
-- Creates all Rayfield tabs for ASTRAL/TBIGUI v3.

local Tabs = {}
Tabs.__index = Tabs

function Tabs.Build(Window)
    local t = {}

    t.Autofarm      = Window:CreateTab("Autofarm", 4483362458)
    t.Pets          = Window:CreateTab("Pets", 4483362458)
    t.Events        = Window:CreateTab("Events", 4483362458)
    t.Extras        = Window:CreateTab("Extras", 4483362458)
    t.Misc          = Window:CreateTab("Misc", 4483362458)
    t.BucksTransfer = Window:CreateTab("Bucks Transfer", 4483362458)
    t.Webhooks      = Window:CreateTab("Webhooks", 4483362458)
    t.Stats         = Window:CreateTab("Stats", 4483362458)
    t.Debug         = Window:CreateTab("Debug", 4483362458)

    return t
end

return Tabs
