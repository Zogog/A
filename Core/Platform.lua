--!strict
-- Core/Platform.lua
-- Creates and manages the AFK platform used by all engines.

local Config = require("Config") -- GitHub-safe import

local Platform = {}
Platform.__index = Platform

---------------------------------------------------------------------
-- Internal state
---------------------------------------------------------------------

local platformPart: Part? = nil
local platformName = "ASTRAL_AFK_PLATFORM"

---------------------------------------------------------------------
-- Utility: Create platform part
---------------------------------------------------------------------

local function CreatePlatform(): Part
    local part = Instance.new("Part")
    part.Name = platformName
    part.Size = Config.Platform.Size
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = Config.Platform.Transparency
    part.Color = Config.Platform.Color
    part.Material = Enum.Material.SmoothPlastic
    part.Position = Config.Platform.Position
    part.Parent = workspace

    return part
end

---------------------------------------------------------------------
-- Public: Enable platform
---------------------------------------------------------------------

function Platform.Enable()
    -- Already exists?
    local existing = workspace:FindFirstChild(platformName)
    if existing and existing:IsA("Part") then
        platformPart = existing
        return
    end

    -- Create new platform
    platformPart = CreatePlatform()
end

---------------------------------------------------------------------
-- Public: Disable platform
---------------------------------------------------------------------

function Platform.Disable()
    if platformPart and platformPart.Parent then
        platformPart:Destroy()
    end

    platformPart = nil
end

---------------------------------------------------------------------
-- Public: Get platform position
---------------------------------------------------------------------

function Platform.GetPosition(): Vector3
    if platformPart then
        return platformPart.Position
    end

    return Config.Platform.Position
end

---------------------------------------------------------------------
-- Public: Ensure platform exists
---------------------------------------------------------------------

function Platform.Ensure()
    if not platformPart or not platformPart.Parent then
        Platform.Enable()
    end
end

---------------------------------------------------------------------

return Platform
