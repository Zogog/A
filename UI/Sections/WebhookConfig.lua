--!strict
local State = import("Core/State")

local WebhookConfig = {}
WebhookConfig.__index = WebhookConfig

function WebhookConfig.Build(Tabs)
    local tab = Tabs.Webhooks
    if not tab then return end

    tab:CreateLabel("Webhook Settings")

    tab:CreateInput({
        Name = "Webhook URL",
        PlaceholderText = "Enter URL",
        RemoveTextAfterFocusLost = false,
        Callback = function(v)
            State.Webhook.URL = v
        end
    })

    tab:CreateToggle({
        Name = "Enable Webhook",
        CurrentValue = State.Webhook.Enabled,
        Callback = function(v)
            State.Webhook.Enabled = v
        end
    })
end

return WebhookConfig
