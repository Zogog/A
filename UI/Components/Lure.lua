--!strict
-- UI/Components/Lure.lua
-- Reusable lure farming UI component for ASTRAL/TBIGUI v3.

local Dropdowns = require("UI/Dropdowns")
local FurnitureManager = require("Core/FurnitureManager")
local LureFarmEngine = require("Autofarm/LureFarmEngine")

local LureComponent = {}
LureComponent.__index = LureComponent

---------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------

function LureComponent.Create(tab)
    local self = setmetatable({}, LureComponent)

    self.Tab = tab

    -----------------------------------------------------------------
    -- Status Label
    -----------------------------------------------------------------

    self.StatusLabel = tab:CreateLabel("Lure Status: Idle")

    -----------------------------------------------------------------
    -- Lure Furniture Dropdown
    -----------------------------------------------------------------

    self.FurnitureList = FurnitureManager.GetLureFurniture()
    self.FurnitureOptions = Dropdowns.BuildFurnitureList(self.FurnitureList)
    self.FurnitureMap = Dropdowns.BuildFurnitureMap(self.FurnitureList)

    self.FurnitureDropdown = tab:CreateDropdown({
        Name = "Select Lure Furniture",
        Options = self.FurnitureOptions,
        CurrentOption = "",
        MultipleOptions = false,
        Callback = function(option)
            self:OnFurnitureSelect(option)
        end,
    })

    -----------------------------------------------------------------
    -- Bait Dropdown
    -----------------------------------------------------------------

    self.BaitList = LureFarmEngine.GetAvailableBait()
    self.BaitOptions = Dropdowns.BuildBaitList(self.BaitList)
    self.BaitMap = Dropdowns.BuildBaitMap(self.BaitList)

    self.BaitDropdown = tab:CreateDropdown({
        Name = "Select Bait",
        Options = self.BaitOptions,
        CurrentOption = "",
        MultipleOptions = false,
        Callback = function(option)
            self:OnBaitSelect(option)
        end,
    })

    -----------------------------------------------------------------
    -- Start / Stop Buttons
    -----------------------------------------------------------------

    tab:CreateButton({
        Name = "Start Lure Autofarm",
        Callback = function()
            self:Start()
        end,
    })

    tab:CreateButton({
        Name = "Stop Lure Autofarm",
        Callback = function()
            self:Stop()
        end,
    })

    return self
end

---------------------------------------------------------------------
-- Furniture Selection
---------------------------------------------------------------------

function LureComponent:OnFurnitureSelect(option: string)
    local index = Dropdowns.GetIndexFromOption(option)
    if not index then return end

    local furnitureId = Dropdowns.GetFurnitureIdFromMap(self.FurnitureMap, index)
    if not furnitureId then return end

    self.SelectedFurniture = furnitureId
end

---------------------------------------------------------------------
-- Bait Selection
---------------------------------------------------------------------

function LureComponent:OnBaitSelect(option: string)
    local index = Dropdowns.GetIndexFromOption(option)
    if not index then return end

    local baitId = Dropdowns.GetBaitIdFromMap(self.BaitMap, index)
    if not baitId then return end

    self.SelectedBait = baitId
end

---------------------------------------------------------------------
-- Start / Stop
---------------------------------------------------------------------

function LureComponent:Start()
    if not self.SelectedFurniture then
        self.StatusLabel:Set("Lure Status: Select furniture first")
        return
    end

    if not self.SelectedBait then
        self.StatusLabel:Set("Lure Status: Select bait first")
        return
    end

    LureFarmEngine.Start(self.SelectedFurniture, self.SelectedBait)
    self.StatusLabel:Set("Lure Status: Running")
end

function LureComponent:Stop()
    LureFarmEngine.Stop()
    self.StatusLabel:Set("Lure Status: Stopped")
end

---------------------------------------------------------------------
-- Refresh (when inventory or furniture changes)
---------------------------------------------------------------------

function LureComponent:Refresh()
    -- Furniture
    self.FurnitureList = FurnitureManager.GetLureFurniture()
    self.FurnitureOptions = Dropdowns.BuildFurnitureList(self.FurnitureList)
    self.FurnitureMap = Dropdowns.BuildFurnitureMap(self.FurnitureList)
    self.FurnitureDropdown:Refresh(self.FurnitureOptions)

    -- Bait
    self.BaitList = LureFarmEngine.GetAvailableBait()
    self.BaitOptions = Dropdowns.BuildBaitList(self.BaitList)
    self.BaitMap = Dropdowns.BuildBaitMap(self.BaitList)
    self.BaitDropdown:Refresh(self.BaitOptions)
end

---------------------------------------------------------------------

return LureComponent
