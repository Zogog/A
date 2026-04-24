--!strict
-- Core/Autofarm/FurnitureManager.lua
-- Centralized furniture lookup & usage for TBIGUI v3.

local AdoptMeAPI = require(script.Parent.Parent.AdoptMeAPI)
local Config = require(script.Parent.Parent.Config)

local FurnitureManager = {}
FurnitureManager.__index = FurnitureManager

---------------------------------------------------------------------
-- Internal: Furniture Cache
---------------------------------------------------------------------

-- Cache furniture folder names to avoid repeated scanning
local FurnitureCache: {[string]: string} = {}

---------------------------------------------------------------------
-- Utility: Find furniture folder in house
---------------------------------------------------------------------

local function FindFurnitureFolder(furnitureName: string): string?
    -- Cached?
    if FurnitureCache[furnitureName] then
        return FurnitureCache[furnitureName]
    end

    -- Query AdoptMeAPI
    local folder = AdoptMeAPI.GetFurniture(furnitureName)
    if folder then
        FurnitureCache[furnitureName] = folder
        return folder
    end

    return nil
end

---------------------------------------------------------------------
-- Public: Check if furniture exists
---------------------------------------------------------------------

function FurnitureManager.Exists(furnitureName: string): boolean
    return FindFurnitureFolder(furnitureName) ~= nil
end

---------------------------------------------------------------------
-- Public: Use furniture
---------------------------------------------------------------------

function FurnitureManager.Use(furnitureName: string)
    local folder = FindFurnitureFolder(furnitureName)

    if not folder then
        warn("[FurnitureManager] Furniture not found:", furnitureName)
        return false
    end

    AdoptMeAPI.RunRouterClient(false, "FurnitureAPI/UseFurniture", {
        folder,
    })

    return true
end

---------------------------------------------------------------------
-- Public: Ensure furniture exists (buy if missing)
---------------------------------------------------------------------

function FurnitureManager.Ensure(furnitureName: string)
    if FurnitureManager.Exists(furnitureName) then
        return true
    end

    -- Buy furniture
    AdoptMeAPI.BuyItem("furniture", furnitureName, 1)
    task.wait(0.5)

    -- Re-scan
    local folder = FindFurnitureFolder(furnitureName)
    if not folder then
        warn("[FurnitureManager] Failed to obtain furniture:", furnitureName)
        return false
    end

    return true
end

---------------------------------------------------------------------
-- Public: Lure Helpers
---------------------------------------------------------------------

function FurnitureManager.GetLureFolder(): string?
    return FindFurnitureFolder(Config.Furniture.LureName)
end

function FurnitureManager.LureExists(): boolean
    return FurnitureManager.Exists(Config.Furniture.LureName)
end

function FurnitureManager.PlaceLure()
    local lureName = Config.Furniture.LureName

    -- Buy if needed
    if not FurnitureManager.Exists(lureName) then
        AdoptMeAPI.BuyItem("furniture", lureName, 1)
        task.wait(0.5)
    end

    -- Place lure
    AdoptMeAPI.RunRouterClient(false, "FurnitureAPI/PlaceFurniture", {
        lureName,
        { x = 0, y = 0, z = 0 }
    })

    task.wait(1)
end

function FurnitureManager.ActivateLure(baitKind: string)
    local folder = FurnitureManager.GetLureFolder()
    if not folder then
        warn("[FurnitureManager] Cannot activate lure: not found")
        return false
    end

    AdoptMeAPI.RunRouterClient(false, "LureAPI/ActivateLure", {
        folder,
        baitKind,
    })

    return true
end

function FurnitureManager.LureIsActive(): boolean
    local folder = FurnitureManager.GetLureFolder()
    if not folder then return false end

    local model = workspace.HouseInteriors.furniture:FindFirstChild(folder)
    if not model then return false end

    return model:FindFirstChild("Active") ~= nil
end

---------------------------------------------------------------------

return FurnitureManager
