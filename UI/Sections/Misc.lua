--!strict
-- UI/Sections/Misc.lua
-- Builds the Misc tab UI for ASTRAL/TBIGUI v3.

local RayfieldInit = require("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local Movement = require("Core/Movement")
local Platform = require("Core/Platform")
local State = require("State")
local ExecutorCheck = require("Core/ExecutorCheck")
local SessionTracker = require("Stats/SessionTracker")

local MiscSection = {}
MiscSection.__index = MiscSection

---------------------------------------------------------------------
-- Build Misc Tab
---------------------------------------------------------------------

function MiscSection.Build(Tabs, Core, UI)
    local tab = Tabs.Misc

    -----------------------------------------------------------------
    -- Safe Mode & Engine Lock
    -----------------------------------------------------------------

    tab:CreateSection("Safety Controls")

    tab:CreateToggle({
        Name = "Safe Mode (Disables risky actions)",
        CurrentValue = State.Runtime.SafeMode,
        Callback = function(val)
            State.Runtime.SafeMode = val
        end,
    })

    tab:CreateToggle({
        Name = "Engine Lock (Prevents scheduler from switching engines)",
        CurrentValue = State.EngineLock,
        Callback = function(val)
            State.EngineLock = val
        end,
    })

    -----------------------------------------------------------------
    -- Platform Tools
    -----------------------------------------------------------------

    tab:CreateSection("Platform Tools")

    tab:CreateButton({
        Name = "Teleport to AFK Platform",
        Callback = function()
            Movement.TeleportToPlatform()
        end,
    })

    tab:CreateButton({
        Name = "Recreate AFK Platform",
        Callback = function()
            Platform.Disable()
            Platform.Enable()
        end,
    })

    -----------------------------------------------------------------
    -- Player Tools
    -----------------------------------------------------------------

    tab:CreateSection("Player Tools")

    tab:CreateButton({
        Name = "Reset Character",
        Callback = function()
            local lp = game.Players.LocalPlayer
            if lp.Character then
                lp.Character:BreakJoints()
            end
        end,
    })

    tab:CreateButton({
        Name = "Rejoin Server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end,
    })

    tab:CreateButton({
        Name = "Server Hop",
        Callback = function()
            local ts = game:GetService("TeleportService")
            local servers = game.HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )

            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers then
                    ts:TeleportToPlaceInstance(game.PlaceId, server.id)
                    break
                end
            end
        end,
    })

    -----------------------------------------------------------------
    -- Session Tools
    -----------------------------------------------------------------

    tab:CreateSection("Session Tools")

    tab:CreateButton({
        Name = "Reset Session Stats",
        Callback = function()
            SessionTracker.Reset()
        end,
    })

    tab:CreateButton({
        Name = "Reload UI",
        Callback = function()
            RayfieldInit.Init()
        end,
    })

    -----------------------------------------------------------------
    -- Executor Info
    -----------------------------------------------------------------

    tab:CreateSection("Executor Info")

    local caps = ExecutorCheck.GetCapabilities()

    tab:CreateLabel("Executor: " .. caps.Name)
    tab:CreateLabel("Supports Requests: " .. tostring(caps.HasRequest))
    tab:CreateLabel("Supports WebSocket: " .. tostring(caps.HasWebSocket))
    tab:CreateLabel("Supports File System: " .. tostring(caps.HasFileSystem))
    tab:CreateLabel("QueueOnTeleport: " .. tostring(caps.HasQueueOnTeleport))
end

---------------------------------------------------------------------

return MiscSection
