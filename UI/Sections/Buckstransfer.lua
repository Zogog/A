--!strict
-- UI/Sections/BucksTransfer.lua
-- Builds the Bucks Transfer tab UI for ASTRAL/TBIGUI v3.

local RayfieldInit = require("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local State = require("State")
local CashRegister = require("Core/Transfer/CashRegister")
local Mannequin = require("Core/Transfer/Mannequin")
local DialogSuppressor = require("Core/Transfer/DialogSuppressor")

local BucksTransfer = {}
BucksTransfer.__index = BucksTransfer

---------------------------------------------------------------------
-- Build Bucks Transfer Tab
---------------------------------------------------------------------

function BucksTransfer.Build(Tabs, Core, UI)
    local tab = Tabs.BucksTransfer

    -----------------------------------------------------------------
    -- Cash Register Transfer
    -----------------------------------------------------------------

    tab:CreateSection("💵 Cash Register Transfer")

    tab:CreateToggle({
        Name = "Enable Cash Register Transfer",
        CurrentValue = State.Transfer.CashRegisterEnabled,
        Callback = function(val)
            State.Transfer.CashRegisterEnabled = val
        end,
    })

    tab:CreateInput({
        Name = "Amount to Transfer",
        PlaceholderText = "Example: 50",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num then
                State.Transfer.CashRegisterAmount = num
            end
        end,
    })

    tab:CreateButton({
        Name = "Start Cash Register Transfer",
        Callback = function()
            CashRegister.Start(State.Transfer.CashRegisterAmount)
        end,
    })

    tab:CreateButton({
        Name = "Stop Cash Register Transfer",
        Callback = function()
            CashRegister.Stop()
        end,
    })

    -----------------------------------------------------------------
    -- Mannequin Transfer
    -----------------------------------------------------------------

    tab:CreateSection("🧍 Mannequin Transfer")

    tab:CreateToggle({
        Name = "Enable Mannequin Transfer",
        CurrentValue = State.Transfer.MannequinEnabled,
        Callback = function(val)
            State.Transfer.MannequinEnabled = val
        end,
    })

    tab:CreateInput({
        Name = "Amount to Transfer",
        PlaceholderText = "Example: 50",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num then
                State.Transfer.MannequinAmount = num
            end
        end,
    })

    tab:CreateButton({
        Name = "Start Mannequin Transfer",
        Callback = function()
            Mannequin.Start(State.Transfer.MannequinAmount)
        end,
    })

    tab:CreateButton({
        Name = "Stop Mannequin Transfer",
        Callback = function()
            Mannequin.Stop()
        end,
    })

    -----------------------------------------------------------------
    -- Dialog Suppression
    -----------------------------------------------------------------

    tab:CreateSection("🔇 Dialog Suppression")

    tab:CreateToggle({
        Name = "Suppress 'Okay' Dialogs (Recommended)",
        CurrentValue = State.Transfer.SuppressDialogs,
        Callback = function(val)
            State.Transfer.SuppressDialogs = val

            if val then
                DialogSuppressor.Enable()
            else
                DialogSuppressor.Disable()
            end
        end,
    })

    -----------------------------------------------------------------
    -- Warnings
    -----------------------------------------------------------------

    tab:CreateSection("⚠️ Warnings")

    tab:CreateLabel("• Do NOT enable both transfer methods at the same time.")
    tab:CreateLabel("• Dialog suppression prevents popups from interrupting transfers.")
    tab:CreateLabel("• Transfers stop automatically if Adopt Me blocks the action.")
end

---------------------------------------------------------------------

return BucksTransfer
