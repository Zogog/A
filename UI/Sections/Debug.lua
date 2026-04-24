--!strict
-- UI/Sections/Debug.lua
-- Builds the Debug tab UI for ASTRAL/TBIGUI v3.

-- Use global import() defined in main.lua
local RayfieldInit = import("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local InventoryDebug = import("Modules/Debug/InventoryDebug")
local State = import("Core/State")

local DebugSection = {}
DebugSection.__index = DebugSection

---------------------------------------------------------------------
-- Build Debug Tab
---------------------------------------------------------------------

function DebugSection.Build(Tabs, Core, UI)
    local tab = Tabs.Debug

    -----------------------------------------------------------------
    -- API Dump
    -----------------------------------------------------------------

    tab:CreateSection("📦 Adopt Me API Dump")

    local ApiDump = tab:CreateParagraph({
        Title = "API Data",
        Content = "Press Refresh to load.",
    })

    tab:CreateButton({
        Name = "Refresh API Dump",
        Callback = function()
            local dump = InventoryDebug.GetAPIDump()
            ApiDump:Set(dump)
        end,
    })

    -----------------------------------------------------------------
    -- Auto Refresh
    -----------------------------------------------------------------

    tab:CreateToggle({
        Name = "Auto‑Refresh API Dump",
        CurrentValue = State.Debug.AutoRefresh,
        Callback = function(val)
            State.Debug.AutoRefresh = val
        end,
    })

    -----------------------------------------------------------------
    -- Module Load Status
    -----------------------------------------------------------------

    tab:CreateSection("📁 Module Load Status")

    local ModuleStatus = tab:CreateParagraph({
        Title = "Modules",
        Content = "Press Refresh to load.",
    })

    tab:CreateButton({
        Name = "Refresh Module Status",
        Callback = function()
            local status = InventoryDebug.GetModuleStatus()
            ModuleStatus:Set(status)
        end,
    })

    -----------------------------------------------------------------
    -- Error Log
    -----------------------------------------------------------------

    tab:CreateSection("⚠️ Error Log")

    local ErrorLog = tab:CreateParagraph({
        Title = "Errors",
        Content = "No errors logged.",
    })

    tab:CreateButton({
        Name = "Refresh Error Log",
        Callback = function()
            local log = InventoryDebug.GetErrorLog()
            ErrorLog:Set(log)
        end,
    })

    tab:CreateButton({
        Name = "Clear Error Log",
        Callback = function()
            InventoryDebug.ClearErrorLog()
            ErrorLog:Set("No errors logged.")
        end,
    })

    -----------------------------------------------------------------
    -- Live Auto‑Refresh Loop
    -----------------------------------------------------------------

    task.spawn(function()
        while task.wait(1) do
            if not State.Debug.AutoRefresh then
                continue
            end

            local dump = InventoryDebug.GetAPIDump()
            ApiDump:Set(dump)

            local status = InventoryDebug.GetModuleStatus()
            ModuleStatus:Set(status)

            local log = InventoryDebug.GetErrorLog()
            ErrorLog:Set(log)
        end
    end)
end

---------------------------------------------------------------------

return DebugSection
