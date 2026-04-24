--!strict
-- Main.lua (entry point for ASTRAL/TBIGUI v3)

---------------------------------------------------------------------
-- Global GitHub loader
---------------------------------------------------------------------

local BASE = "https://raw.githubusercontent.com/Zogog/A/main/"

getgenv().import = function(path: string)
    local url = BASE .. path .. ".lua"
    local src = game:HttpGet(url)
    return loadstring(src)()
end

---------------------------------------------------------------------
-- UI Init
---------------------------------------------------------------------

local RayfieldInit = import("UI/RayfieldInit")
local Window = RayfieldInit.Init()

---------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------

local Tabs = import("UI/Tabs").Build(Window)

---------------------------------------------------------------------
-- Core
---------------------------------------------------------------------

local State = import("Core/State")
local Scheduler = import("Core/Scheduler/AutofarmScheduler")

---------------------------------------------------------------------
-- Sections
---------------------------------------------------------------------

import("UI/Sections/Autofarm").Build(Tabs)
import("UI/Sections/Pets").Build(Tabs)
import("UI/Sections/Events").Build(Tabs)
import("UI/Sections/Extras").Build(Tabs)
import("UI/Sections/Misc").Build(Tabs)
import("UI/Sections/BucksTransfer").Build(Tabs)
import("UI/Sections/WebhookConfig").Build(Tabs)
import("UI/Sections/Stats").Build(Tabs)
import("UI/Sections/Debug").Build(Tabs)

---------------------------------------------------------------------
-- Webhook Scheduler
---------------------------------------------------------------------

if State.Webhooks and State.Webhooks.Enabled then
    import("Core/Webhooks/WebhookScheduler").Start()
end

print("ASTRAL/TBIGUI v3 loaded successfully.")
