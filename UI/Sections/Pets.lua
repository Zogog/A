--!strict
local PetViewer = import("Modules/PetViewer")

local Pets = {}
Pets.__index = Pets

function Pets.Build(Tabs)
    local tab = Tabs.Pets
    if not tab then return end

    tab:CreateLabel("Pet Viewer")

    local PetList = tab:CreateParagraph({
        Title = "Your Pets",
        Content = "Loading..."
    })

    local PetDetails = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet."
    })

    local SearchBox = tab:CreateInput({
        Name = "Search",
        PlaceholderText = "Type to filter pets...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            PetViewer.Search(text)
        end
    })

    local SelectBox = tab:CreateInput({
        Name = "Select Pet #",
        PlaceholderText = "Enter index",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            PetViewer.SelectByIndex(text)
        end
    })

    tab:CreateButton({
        Name = "Equip Selected",
        Callback = function()
            PetViewer.EquipSelected()
        end
    })

    PetViewer.BindUI({
        Label = { Set = function() end }, -- optional
        List = PetList,
        Details = PetDetails
    })

    PetViewer.Refresh()
end

return Pets
