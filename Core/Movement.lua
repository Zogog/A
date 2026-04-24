--!strict
-- Core/Movement.lua
-- Safe teleporting + platform-relative positioning for TBIGUI v3.
-- Does NOT override WalkSpeed, JumpPower, or Humanoid physics.

local Config = require("Config") -- GitHub-safe import
local Platform = require("Platform")

local Movement = {}
Movement.__index = Movement

---------------------------------------------------------------------
-- Utility: Get HumanoidRootPart
---------------------------------------------------------------------

local function GetRoot(): BasePart?
    local player = game.Players.LocalPlayer
    if not player then return nil end

    local char = player.Character
    if not char then return nil end

    return char:FindFirstChild("HumanoidRootPart") :: BasePart?
end

---------------------------------------------------------------------
-- Public: Teleport to a Vector3
---------------------------------------------------------------------

function Movement.TeleportTo(pos: Vector3)
    local root = GetRoot()
    if not root then return end

    root.CFrame = CFrame.new(pos)
end

---------------------------------------------------------------------
-- Public: Teleport above platform
---------------------------------------------------------------------

function Movement.TeleportToPlatform(offsetY: number?)
    offsetY = offsetY or 3

    Platform.Ensure()
    local basePos = Platform.GetPosition()

    Movement.TeleportTo(basePos + Vector3.new(0, offsetY, 0))
end

---------------------------------------------------------------------
-- Public: Keep player near platform
-- Used by all engines to maintain a stable AFK position.
---------------------------------------------------------------------

function Movement.KeepPlayerNearPlatform(maxDistance: number?)
    maxDistance = maxDistance or Config.Platform.MaxDistance

    local root = GetRoot()
    if not root then return end

    Platform.Ensure()
    local platformPos = Platform.GetPosition()

    local dist = (root.Position - platformPos).Magnitude
    if dist > maxDistance then
        Movement.TeleportToPlatform()
    end
end

---------------------------------------------------------------------
-- Public: Nudge player slightly (anti-idle drift)
---------------------------------------------------------------------

function Movement.Nudge()
    local root = GetRoot()
    if not root then return end

    local pos = root.Position
    root.CFrame = CFrame.new(pos + Vector3.new(0, 0.1, 0))
end

---------------------------------------------------------------------

return Movement
