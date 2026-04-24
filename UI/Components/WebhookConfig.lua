--!strict
-- UI/Sections/WebhookConfig.lua
-- Builds the Webhook Config tab UI for ASTRAL/TBIGUI v3.

-- Use global import() defined in main.lua
local RayfieldInit = import("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local State = import("Core/State")
local Webhooks = import("Webhooks/Webhooks")
local Scheduler = import("Webhooks/WebhookScheduler")

local WebhookConfig = {}
WebhookConfig.__index = WebhookConfig

---------------------------------------------------------------------
-- Build Webhook Config Tab
---------------------------------------------------------------------

function WebhookConfig.Build(Tabs, Core, UI)
    local tab = Tabs.Webhooks

    -----------------------------------------------------------------
    -- Webhook Settings
    -----------------------------------------------------------------

    tab:CreateSection("🔗 Webhook Settings")

    tab:CreateInput({
        Name = "Webhook URL",
        PlaceholderText = "https://discord.com/api/webhooks/...",
        RemoveTextAfterFocusLost = false,
        CurrentValue = State.Webhooks.URL,
        Callback = function(text)
            State.Webhooks.URL = text
        end,
    })

    tab:CreateInput({
        Name = "Webhook Username",
        PlaceholderText = "ASTRAL Bot",
        RemoveTextAfterFocusLost = false,
        CurrentValue = State.Webhooks.Username,
        Callback = function(text)
            State.Webhooks.Username = text
        end,
    })

    tab:CreateInput({
        Name = "Webhook Avatar URL",
        PlaceholderText = "https://example.com/avatar.png",
        RemoveTextAfterFocusLost = false,
        CurrentValue = State.Webhooks.Avatar,
        Callback = function(text)
            State.Webhooks.Avatar = text
        end,
    })

    -----------------------------------------------------------------
    -- Test Webhook
    -----------------------------------------------------------------

    tab:CreateSection("🧪 Test Webhook")

    tab:CreateButton({
        Name = "Send Test Webhook",
        Callback = function()
            Webhooks.SendRaw("ASTRAL Webhook Test Successful!")
        end,
    })

    -----------------------------------------------------------------
    -- Scheduler Controls
    -----------------------------------------------------------------

    tab:CreateSection("📨 Webhook Scheduler")

    tab:CreateToggle({
        Name = "Enable Webhook Scheduler",
        CurrentValue = State.Webhooks.Enabled,
        Callback = function(val)
            State.Webhooks.Enabled = val
            if val then
                Scheduler.Start()
            else
                Scheduler.Stop()
            end
        end,
    })

    tab:CreateSlider({
        Name = "Dispatch Delay",
        Range = { 0.25, 5 },
        Increment = 0.25,
        Suffix = "Seconds",
        CurrentValue = State.Webhooks.DispatchDelay,
        Callback = function(value)
            State.Webhooks.DispatchDelay = value
        end,
    })

    tab:CreateButton({
        Name = "Clear Webhook Queue",
        Callback = function()
            Scheduler.Clear()
        end,
    })

    -----------------------------------------------------------------
    -- Info
    -----------------------------------------------------------------

    tab:CreateSection("ℹ️ Info")

    tab:CreateLabel("• Scheduler sends one message at a time to avoid rate limits.")
    tab:CreateLabel("• Test webhook uses raw text only.")
    tab:CreateLabel("• Engines enqueue messages; scheduler dispatches them.")
end

---------------------------------------------------------------------

return WebhookConfig
