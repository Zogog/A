--!strict

local Misc = {}
Misc.__index = Misc

function Misc.Build(Tabs)
    local tab = Tabs.Misc
    if not tab then return end

    tab:CreateLabel("Misc Options")

    tab:CreateButton({
        Name = "Rejoin Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    })

    tab:CreateButton({
        Name = "Server Hop",
        Callback = function()
            local ts = game:GetService("TeleportService")
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end
    })
end

return Misc
