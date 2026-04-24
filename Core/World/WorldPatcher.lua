--!strict
-- World/WorldPatcher.lua
-- Safe world reference stabilizer for TBIGUI v3.
-- Does NOT modify the world. Only caches and validates references.

local WorldPatcher = {}
WorldPatcher.__index = WorldPatcher

---------------------------------------------------------------------
-- Internal cache
---------------------------------------------------------------------

local cache = {
    HouseInteriors = nil,
    CherryBlossomEvent = nil,
    KaijuStompEvent = nil,
    FurnitureFolder = nil,
}

---------------------------------------------------------------------
-- Utility: Safe find
---------------------------------------------------------------------

local function safeFind(parent: Instance?, name: string): Instance?
    if not parent then return nil end
    local ok, result = pcall(function()
        return parent:FindFirstChild(name)
    end)
    return ok and result or nil
end

---------------------------------------------------------------------
-- House Interiors
---------------------------------------------------------------------

function WorldPatcher.GetHouseInteriors(): Instance?
    if cache.HouseInteriors and cache.HouseInteriors.Parent then
        return cache.HouseInteriors
    end

    local folder = safeFind(workspace, "HouseInteriors")
    cache.HouseInteriors = folder
    return folder
end

function WorldPatcher.GetFurnitureFolder(): Instance?
    local interiors = WorldPatcher.GetHouseInteriors()
    if not interiors then return nil end

    if cache.FurnitureFolder and cache.FurnitureFolder.Parent then
        return cache.FurnitureFolder
    end

    local folder = safeFind(interiors, "furniture")
    cache.FurnitureFolder = folder
    return folder
end

---------------------------------------------------------------------
-- Cherry Blossom Event
---------------------------------------------------------------------

function WorldPatcher.GetCherryEvent(): Instance?
    if cache.CherryBlossomEvent and cache.CherryBlossomEvent.Parent then
        return cache.CherryBlossomEvent
    end

    local folder = safeFind(workspace, "CherryBlossomEvent")
    cache.CherryBlossomEvent = folder
    return folder
end

function WorldPatcher.GetCherryRings(): {Instance}
    local event = WorldPatcher.GetCherryEvent()
    if not event then return {} end

    local rings = safeFind(event, "Rings")
    if not rings then return {} end

    return rings:GetChildren()
end

---------------------------------------------------------------------
-- Kaiju Stomp Event
---------------------------------------------------------------------

function WorldPatcher.GetKaijuEvent(): Instance?
    if cache.KaijuStompEvent and cache.KaijuStompEvent.Parent then
        return cache.KaijuStompEvent
    end

    local folder = safeFind(workspace, "KaijuStompEvent")
    cache.KaijuStompEvent = folder
    return folder
end

function WorldPatcher.GetKaijuBuildings(): {Instance}
    local event = WorldPatcher.GetKaijuEvent()
    if not event then return {} end

    local buildings = safeFind(event, "Buildings")
    if not buildings then return {} end

    return buildings:GetChildren()
end

---------------------------------------------------------------------
-- World Validation
---------------------------------------------------------------------

function WorldPatcher.Validate()
    -- Refresh all cached references
    WorldPatcher.GetHouseInteriors()
    WorldPatcher.GetFurnitureFolder()
    WorldPatcher.GetCherryEvent()
    WorldPatcher.GetKaijuEvent()
end

---------------------------------------------------------------------

return WorldPatcher
