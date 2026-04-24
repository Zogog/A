--!strict
-- UI/Components/PetDropdown.lua
-- Reusable pet dropdown component for ASTRAL/TBIGUI v3.
-- Returns the PET UID (string) to the callback.

local Dropdowns = require("UI/Dropdowns") -- your string list builder
local PetsCore = require("Core/Pets")

local PetDropdown = {}
PetDropdown.__index = PetDropdown

---------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------

function PetDropdown.Create(tab, labelText, petsTable, callback)
    local self = setmetatable({}, PetDropdown)

    self.Tab = tab
    self.LabelText = labelText
    self.PetsTable = petsTable
    self.Callback = callback

    -- Build initial list
    self.List = Dropdowns.BuildPetList(self.PetsTable)
    self.Map = Dropdowns.BuildPetDataMap(self.PetsTable)

    -- Create UI dropdown
    self.Dropdown = tab:CreateDropdown({
        Name = labelText,
        Options = self.List,
        CurrentOption = "",
        MultipleOptions = false,
        Callback = function(option)
            self:OnSelect(option)
        end,
    })

    return self
end

---------------------------------------------------------------------
-- Handle selection
---------------------------------------------------------------------

function PetDropdown:OnSelect(option: string)
    if not option or option == "" then
        return
    end

    -- Extract index from "1=Dog: 12 -- ABC123"
    local index = Dropdowns.GetIndexFromOption(option)
    if not index then
        warn("PetDropdown: Failed to extract index from option:", option)
        return
    end

    -- Convert index → UID
    local uid = Dropdowns.GetPetIdFromMap(self.Map, index)
    if not uid then
        warn("PetDropdown: No UID found for index:", index)
        return
    end

    -- Fire callback with UID
    if self.Callback then
        self.Callback(uid)
    end
end

---------------------------------------------------------------------
-- Refresh dropdown when pets change
---------------------------------------------------------------------

function PetDropdown:Refresh(newPetsTable)
    self.PetsTable = newPetsTable
    self.List = Dropdowns.BuildPetList(self.PetsTable)
    self.Map = Dropdowns.BuildPetDataMap(self.PetsTable)

    self.Dropdown:Refresh(self.List)
end

---------------------------------------------------------------------
-- Filter dropdown
---------------------------------------------------------------------

function PetDropdown:Filter(text)
    local filtered = Dropdowns.Filter(self.List, text)
    self.Dropdown:Refresh(filtered)
end

---------------------------------------------------------------------

return PetDropdown
