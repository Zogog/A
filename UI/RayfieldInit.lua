--!strict
-- UI/RayfieldInit.lua
-- Initializes the Sirius Rayfield UI for ASTRAL/TBIGUI v3.

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local RayfieldInit = {}
RayfieldInit.__index = RayfieldInit

---------------------------------------------------------------------
-- Internal state
---------------------------------------------------------------------

local window = nil

---------------------------------------------------------------------
-- Create Window
---------------------------------------------------------------------

function RayfieldInit.Init()
    if window then
        return window
    end

    window = Rayfield:CreateWindow({
        Name = "ASTRAL | Universal Autofarm",
        LoadingTitle = "ASTRAL",
        LoadingSubtitle = "Initializing UI...",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "ASTRAL_CONFIGS",
            FileName = "ASTRAL_UI"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = false
        },
        KeySystem = false,
    })

    return window
end

---------------------------------------------------------------------

return RayfieldInit
