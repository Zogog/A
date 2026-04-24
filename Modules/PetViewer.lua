--!strict
-- Modules/PetViewer.lua
-- Central Pet Viewer logic for ASTRAL/TBIGUI v3

local AdoptMeAPI = import("Core/AdoptMeAPI")
local PetsCore = import("Core/Pets")

local PetViewer = {}
PetViewer.__index = PetViewer

---------------------------------------------------------------------
-- Internal UI references
---------------------------------------------------------------------

local UI = {
    Label = nil,
    List = nil,
    Details = nil,
}

---------------------------------------------------------------------
-- Internal state
---------------------------------------------------------------------

local CachedPets = {}
local FilteredPets = {}
local SelectedIndex = nil

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

local function BuildPetList()
    local inv = AdoptMeAPI.GetPlayersInventory()
    local pets = inv.pets or {}

    local list = {}
    for uid, data in pairs(pets) do
        table.insert(list, {
            uid = uid,
            kind = data.kind or "Unknown",
            age = data.properties and data.properties.age or 1,
        })
    end

    table.sort(list, function(a, b)
        return AdoptMeAPI.NaturalSort(a.kind, b.kind)
    end)

    CachedPets = list
    FilteredPets = list
end

local function UpdateListUI()
    if not UI.List then return end

    local content = ""
    for i, pet in ipairs(FilteredPets) do
        content ..= string.format("[%d] %s (Age %d)\n", i, pet.kind, pet.age)
    end

    if content == "" then
        content = "No pets found."
    end

    UI.List:Set({
        Title = "Your Pets",
        Content = content,
    })

    UI.Label:Set("Loaded " .. tostring(#FilteredPets) .. " pets.")
end

local function UpdateDetailsUI()
    if not UI.Details then return end
    if not SelectedIndex or not FilteredPets[SelectedIndex] then
        UI.Details:Set({
            Title = "Pet Details",
            Content = "Select a pet to view details.",
        })
        return
    end

    local pet = FilteredPets[SelectedIndex]
    local text = string.format(
        "Unique ID: %s\nKind: %s\nAge: %d",
        pet.uid,
        pet.kind,
        pet.age
    )

    UI.Details:Set({
        Title = "Pet Details",
        Content = text,
    })
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

function PetViewer.BindUI(refs)
    UI.Label = refs.Label
    UI.List = refs.List
    UI.Details = refs.Details
end

function PetViewer.Refresh()
    BuildPetList()
    UpdateListUI()
    UpdateDetailsUI()
end

function PetViewer.Search(text: string)
    if text == "" then
        FilteredPets = CachedPets
    else
        local lower = text:lower()
        FilteredPets = {}

        for _, pet in ipairs(CachedPets) do
            if pet.kind:lower():find(lower, 1, true) then
                table.insert(FilteredPets, pet)
            end
        end
    end

    SelectedIndex = nil
    UpdateListUI()
    UpdateDetailsUI()
end

function PetViewer.SelectByIndex(text: string)
    local num = tonumber(text)
    if not num then return end

    if not FilteredPets[num] then return end

    SelectedIndex = num
    UpdateDetailsUI()
end

function PetViewer.EquipSelected()
    if not SelectedIndex then return end
    local pet = FilteredPets[SelectedIndex]
    if not pet then return end

    AdoptMeAPI.EquipPet(pet.uid)
end

---------------------------------------------------------------------

return PetViewer
