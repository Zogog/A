--!strict
-- UI/Components/Potions.lua
-- Reusable potion dropdown component for ASTRAL/TBIGUI v3.
-- Returns the POTION UID (string) to the callback.

-- Use global import() defined in main.lua
local Dropdowns = import("UI/Dropdowns")
local Inventory = import("Core/Inventory")

local Potions = {}
Potions.__index = Potions

---------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------

function Potions.Create(tab, labelText, callback)
    local self = setmetatable({}, Potions)

    self.Tab = tab
    self.LabelText = labelText
    self.Callback = callback

    -- Fetch potions from inventory
    self.PotionsTable = Inventory.GetPotions() or {}

    -- Build dropdown list + map
    self.List = Dropdowns.BuildPotionList(self.PotionsTable)
    self.Map = Dropdowns.BuildPotionDataMap(self.PotionsTable)

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

function Potions:OnSelect(option: string)
    if not option or option == "" then
        return
    end

    -- Extract index from "1=Age Potion -- UID123"
    local index = Dropdowns.GetIndexFromOption(option)
    if not index then
        warn("Potions: Failed to extract index from option:", option)
        return
    end

    -- Convert index → UID
    local uid = Dropdowns.GetPotionIdFromMap(self.Map, index)
    if not uid then
        warn("Potions: No UID found for index:", index)
        return
    end

    -- Fire callback with UID
    if self.Callback then
        self.Callback(uid)
    end
end

---------------------------------------------------------------------
-- Refresh dropdown when inventory changes
---------------------------------------------------------------------

function Potions:Refresh()
    self.PotionsTable = Inventory.GetPotions() or {}
    self.List = Dropdowns.BuildPotionList(self.PotionsTable)
    self.Map = Dropdowns.BuildPotionDataMap(self.PotionsTable)

    self.Dropdown:Refresh(self.List)
end

---------------------------------------------------------------------
-- Filter dropdown
---------------------------------------------------------------------

function Potions:Filter(text)
    local filtered = Dropdowns.Filter(self.List, text)
    self.Dropdown:Refresh(filtered)
end

---------------------------------------------------------------------

return Potions
