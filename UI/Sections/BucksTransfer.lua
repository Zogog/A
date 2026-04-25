--!strict

local BucksTransfer = {}
BucksTransfer.__index = BucksTransfer

function BucksTransfer.Build(Tabs)
    local tab = Tabs.BucksTransfer
    if not tab then return end

    tab:CreateLabel("Bucks Transfer")

    tab:CreateInput({
        Name = "Amount",
        PlaceholderText = "Enter amount",
        RemoveTextAfterFocusLost = false,
        Callback = function(v)
            -- store in state if needed
        end
    })

    tab:CreateButton({
        Name = "Send Bucks",
        Callback = function()
            print("Sending bucks...")
        end
    })
end

return BucksTransfer
