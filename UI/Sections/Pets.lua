--!strict
-- UI/Sections/Pets.lua
-- Builds the Pets tab UI for ASTRAL/TBIGUI v3.

local RayfieldInit = require("UI/RayfieldInit")
local Window = RayfieldInit.Init()

local PetViewer = require("Modules/PetViewer")
local PetsCore = require("Core/Pets")

local PetsSection = {}
PetsSection.__index = PetsSection

---------------------------------------------------------------------
-- Build Pets Tab
---------------------------------------------------------------------

function PetsSection.Build(Tabs, Core, UI)
    local tab = Tabs.Pets

    tab:CreateSection("Pet Viewer")

    -----------------------------------------------------------------
    -- Pet List
    -----------------------------------------------------------------

    local PetListLabel = tab:CreateLabel("Loading pets...", "paw-print")

    local PetList = tab:CreateParagraph({
        Title = "Your Pets",
        Content = "Loading...",
    })

    local Details = tab:CreateParagraph({
        Title = "Pet Details",
        Content = "Select a pet to view details.",
    })

    -----------------------------------------------------------------
    -- Refresh Button
    -----------------------------------------------------------------

    tab:CreateButton({
        Name = "Refresh Pet List",
        Callback = function()
            PetViewer.Refresh()
        end,
    })

    -----------------------------------------------------------------
    -- Search Input
    -----------------------------------------------------------------

    tab:CreateInput({
        Name = "Search Pets",
        PlaceholderText = "Type a pet name...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            PetViewer.Search(text)
        end,
    })

    -----------------------------------------------------------------
    -- Select Pet by Index
    -----------------------------------------------------------------

    tab:CreateInput({
        Name = "Select Pet (Enter Index)",
        PlaceholderText = "Example: 1",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            PetViewer.SelectByIndex(text)
        end,
    })

    -----------------------------------------------------------------
    -- Equip Button
    -----------------------------------------------------------------

    tab:CreateButton({
        Name = "Equip Selected Pet",
        Callback = function()
            PetViewer.EquipSelected()
        end,
    })

    -----------------------------------------------------------------
    -- Wire UI elements to PetViewer
    -----------------------------------------------------------------

    PetViewer.BindUI({
        Label = PetListLabel,
        List = PetList,
        Details = Details,
    })

    -- Initial load
    PetViewer.Refresh()
end

---------------------------------------------------------------------

return PetsSection
