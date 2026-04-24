--!strict
-- UI/Sections/Stats.lua
-- Builds the Stats tab UI for ASTRAL/TBIGUI v3.

-- Use global import() defined in main.lua
local RayfieldInit = import("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local SessionTracker = import("Stats/SessionTracker")

local StatsSection = {}
StatsSection.__index = StatsSection

---------------------------------------------------------------------
-- Build Stats Tab
---------------------------------------------------------------------

function StatsSection.Build(Tabs, Core, UI)
    local tab = Tabs.Stats

    tab:CreateSection("📊 Session Statistics")

    -----------------------------------------------------------------
    -- Labels
    -----------------------------------------------------------------

    local RuntimeLabel       = tab:CreateLabel("Runtime: Loading...")
    local BucksLabel         = tab:CreateLabel("Bucks Earned: Loading...")
    local PotionsLabel       = tab:CreateLabel("Potions Farmed: Loading...")
    local EggsLabel          = tab:CreateLabel("Eggs Hatched: Loading...")
    local PetsAgedLabel      = tab:CreateLabel("Pets Aged: Loading...")
    local LureLabel          = tab:CreateLabel("Lure Catches: Loading...")

    tab:CreateSection("⚡ Event Stats")

    local BlossomLabel       = tab:CreateLabel("Blossom Runs: Loading...")
    local KaijuLabel         = tab:CreateLabel("Kaiju Runs: Loading...")
    local ComboLabel         = tab:CreateLabel("Combo Runs: Loading...")

    -----------------------------------------------------------------
    -- Reset Button
    -----------------------------------------------------------------

    tab:CreateButton({
        Name = "Reset Session Stats",
        Callback = function()
            SessionTracker.Reset()
        end,
    })

    -----------------------------------------------------------------
    -- Auto‑update loop
    -----------------------------------------------------------------

    task.spawn(function()
        while task.wait(1) do
            SessionTracker.UpdateRuntime()
            local stats = SessionTracker.GetStats()

            RuntimeLabel:Set("Runtime: " .. stats.RuntimeSeconds .. "s")
            BucksLabel:Set("Bucks Earned: " .. stats.BucksEarned)
            PotionsLabel:Set("Potions Farmed: " .. stats.PotionsFarmed)
            EggsLabel:Set("Eggs Hatched: " .. stats.EggsHatched)
            PetsAgedLabel:Set("Pets Aged: " .. stats.PetsAged)
            LureLabel:Set("Lure Catches: " .. stats.LureCatches)

            BlossomLabel:Set("Blossom Runs: " .. stats.BlossomRuns)
            KaijuLabel:Set("Kaiju Runs: " .. stats.KaijuRuns)
            ComboLabel:Set("Combo Runs: " .. stats.ComboRuns)
        end
    end)
end

---------------------------------------------------------------------

return StatsSection
