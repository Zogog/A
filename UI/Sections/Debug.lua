--!strict
local Debug = {}
Debug.__index = Debug

function Debug.Build(Tabs)
    local tab = Tabs.Debug
    if not tab then return end

    tab:CreateLabel("Debug Tools")

    tab:CreateButton({
        Name = "Print State",
        Callback = function()
            print("STATE DUMP:", getgenv().State)
        end
    })
end

return Debug
