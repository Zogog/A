--!strict
local SessionTracker = import("Core/Stats/SessionTracker")

local Stats = {}
Stats.__index = Stats

function Stats.Build(Tabs)
    local tab = Tabs.Stats
    if not tab then return end

    tab:CreateLabel("Session Stats")

    local StatsBox = tab:CreateParagraph({
        Title = "Stats",
        Content = "Loading..."
    })

    task.spawn(function()
        while task.wait(1) do
            StatsBox:Set({
                Title = "Stats",
                Content = SessionTracker.GetStatsText()
            })
        end
    end)
end

return Stats
