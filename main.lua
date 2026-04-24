--!strict
-- Main.lua (entry point for ASTRAL/TBIGUI v3)

-- Load UI
local RayfieldInit = require("UI/RayfieldInit")
local Window = RayfieldInit.Init()

-- Load Tabs
local Tabs = require("UI/Tabs").Build(Window)

-- Load Core
local State = require("State")
local Scheduler = require("Scheduler/AutofarmScheduler")

-- Load Sections
require("UI/Sections/Autofarm").Build(Tabs)
require("UI/Sections/Pets").Build(Tabs)
require("UI/Sections/Events").Build(Tabs)
require("UI/Sections/Extras").Build(Tabs)
require("UI/Sections/Misc").Build(Tabs)
require("UI/Sections/BucksTransfer").Build(Tabs)
require("UI/Sections/WebhookConfig").Build(Tabs)
require("UI/Sections/Stats").Build(Tabs)
require("UI/Sections/Debug").Build(Tabs)

-- Start scheduler if enabled
if State.Webhooks.Enabled then
    require("Webhooks/WebhookScheduler").Start()
end

print("ASTRAL/TBIGUI v3 loaded successfully.")
