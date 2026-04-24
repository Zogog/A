--!strict
-- Core/ExecutorCheck.lua
-- Safe capability detection for TBIGUI v3.
-- Does NOT perform harmful checks or exploit-specific behavior.

local ExecutorCheck = {}
ExecutorCheck.__index = ExecutorCheck

---------------------------------------------------------------------
-- Internal: Safe environment probes
---------------------------------------------------------------------

local function has(funcName: string): boolean
    local ok = pcall(function()
        return getfenv()[funcName]
    end)
    return ok and getfenv()[funcName] ~= nil
end

local function hasGlobal(name: string): boolean
    local ok, value = pcall(function()
        return getfenv()[name]
    end)
    return ok and value ~= nil
end

local function safeGetVersion()
    local ok, ver = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
        if identifyexecutor then
            return identifyexecutor()
        end
        return "Unknown"
    end)
    return ok and ver or "Unknown"
end

---------------------------------------------------------------------
-- Capability Table
---------------------------------------------------------------------

function ExecutorCheck.GetCapabilities()
    return {
        Name = safeGetVersion(),

        -- HTTP / Request
        HasRequest = hasGlobal("request") or hasGlobal("http_request"),

        -- Queue on teleport
        HasQueueOnTeleport = hasGlobal("queue_on_teleport"),

        -- WebSocket support
        HasWebSocket = hasGlobal("WebSocket") or hasGlobal("websocket"),

        -- File system support
        HasFileSystem = hasGlobal("writefile") and hasGlobal("readfile"),

        -- Set identity / thread control
        HasSetIdentity = hasGlobal("setidentity") or hasGlobal("setthreadidentity"),

        -- Drawing API (used by some UI modules)
        HasDrawing = hasGlobal("Drawing"),

        -- Basic environment flags
        HasGetFEnv = hasGlobal("getfenv"),
        HasSetFEnv = hasGlobal("setfenv"),
    }
end

---------------------------------------------------------------------
-- Simple helpers
---------------------------------------------------------------------

function ExecutorCheck.GetName(): string
    return ExecutorCheck.GetCapabilities().Name
end

function ExecutorCheck.SupportsRequests(): boolean
    return ExecutorCheck.GetCapabilities().HasRequest
end

function ExecutorCheck.SupportsWebSocket(): boolean
    return ExecutorCheck.GetCapabilities().HasWebSocket
end

function ExecutorCheck.SupportsQueueOnTeleport(): boolean
    return ExecutorCheck.GetCapabilities().HasQueueOnTeleport
end

function ExecutorCheck.SupportsFileSystem(): boolean
    return ExecutorCheck.GetCapabilities().HasFileSystem
end

---------------------------------------------------------------------

return ExecutorCheck
