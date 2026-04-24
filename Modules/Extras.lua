--!strict
-- Modules/Extras.lua
-- Utility functions for Extras tab (movement, FPS, rendering, anti-AFK)

local Config = import("Core/Config")

local Extras = {}
Extras.__index = Extras

---------------------------------------------------------------------
-- WalkSpeed / JumpPower
---------------------------------------------------------------------

function Extras.SetWalkSpeed(value: number)
    local lp = game.Players.LocalPlayer
    if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = value
    end
end

function Extras.SetJumpPower(value: number)
    local lp = game.Players.LocalPlayer
    if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.JumpPower = value
    end
end

---------------------------------------------------------------------
-- Rendering toggle
---------------------------------------------------------------------

local Lighting = game:GetService("Lighting")

function Extras.SetRendering(enabled: boolean)
    -- White screen trick: disable 3D rendering
    if not enabled then
        sethiddenproperty(game:GetService("RunService"), "RenderStepped", function() end)
        Lighting.GlobalShadows = false
    else
        -- Restore defaults
        Lighting.GlobalShadows = true
    end
end

---------------------------------------------------------------------
-- FPS Cap
---------------------------------------------------------------------

function Extras.SetFPSCap(value: number)
    if setfpscap then
        setfpscap(value)
    end
end

---------------------------------------------------------------------
-- Tick Delay
---------------------------------------------------------------------

local tickDelay = 1.0

function Extras.SetTickDelay(value: number)
    tickDelay = value
end

function Extras.GetTickDelay(): number
    return tickDelay
end

---------------------------------------------------------------------
-- Anti-AFK
---------------------------------------------------------------------

local VirtualUser = game:GetService("VirtualUser")

function Extras.SetAntiAFK(state: boolean)
    if not state then return end

    game.Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

---------------------------------------------------------------------

return Extras
