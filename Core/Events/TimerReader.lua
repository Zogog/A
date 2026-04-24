--!strict
-- Core/Autofarm/TimerReader.lua
-- Reads event timers for Cherry Blossom, Kaiju Stomp, and future events.

local TimerReader = {}
TimerReader.__index = TimerReader

---------------------------------------------------------------------
-- Internal: Safe number parser
---------------------------------------------------------------------

local function ParseNumber(str: string?): number
    if not str then return 0 end
    local n = tonumber(str)
    return n or 0
end

---------------------------------------------------------------------
-- Cherry Blossom Timer
---------------------------------------------------------------------

local function GetCherryFolder()
    return workspace:FindFirstChild("CherryBlossomEvent")
end

function TimerReader.GetCherryTimeRemaining(): number
    local folder = GetCherryFolder()
    if not folder then return 0 end

    local timer = folder:FindFirstChild("Timer")
    if not timer then return 0 end

    return ParseNumber(timer.Value)
end

function TimerReader.CherryIsActive(): boolean
    local folder = GetCherryFolder()
    if not folder then return false end

    local active = folder:FindFirstChild("Active")
    return active ~= nil
end

---------------------------------------------------------------------
-- Kaiju Stomp Timer
---------------------------------------------------------------------

local function GetKaijuFolder()
    return workspace:FindFirstChild("KaijuStompEvent")
end

function TimerReader.GetKaijuTimeRemaining(): number
    local folder = GetKaijuFolder()
    if not folder then return 0 end

    local timer = folder:FindFirstChild("Timer")
    if not timer then return 0 end

    return ParseNumber(timer.Value)
end

function TimerReader.KaijuIsActive(): boolean
    local folder = GetKaijuFolder()
    if not folder then return false end

    local active = folder:FindFirstChild("Active")
    return active ~= nil
end

---------------------------------------------------------------------
-- Combined Event Logic
---------------------------------------------------------------------

function TimerReader.AnyEventActive(): boolean
    return TimerReader.CherryIsActive()
        or TimerReader.KaijuIsActive()
end

function TimerReader.GetNextEventTime(): number
    local cherry = TimerReader.GetCherryTimeRemaining()
    local kaiju = TimerReader.GetKaijuTimeRemaining()

    if cherry == 0 and kaiju == 0 then
        return 0
    end

    if cherry == 0 then return kaiju end
    if kaiju == 0 then return cherry end

    return math.min(cherry, kaiju)
end

---------------------------------------------------------------------

return TimerReader
