--!strict
-- Webhooks/WebhookScheduler.lua
-- Centralized queue + rate-limited webhook dispatcher for TBIGUI v3.

-- Use global import() defined in main.lua
local Config = import("Core/Config")
local Webhooks = import("Webhooks/Webhooks")

local WebhookScheduler = {}
WebhookScheduler.__index = WebhookScheduler

---------------------------------------------------------------------
-- Internal queue
---------------------------------------------------------------------

local queue = {} :: { {type: string, payload: any} }
local running = false

---------------------------------------------------------------------
-- Queue Helpers
---------------------------------------------------------------------

local function enqueue(entry)
    table.insert(queue, entry)
end

local function dequeue()
    if #queue == 0 then return nil end
    return table.remove(queue, 1)
end

---------------------------------------------------------------------
-- Public API: Queue webhook messages
---------------------------------------------------------------------

function WebhookScheduler.QueueRaw(content: string)
    enqueue({
        type = "raw",
        payload = content,
    })
end

function WebhookScheduler.QueueEmbed(embedData: table)
    enqueue({
        type = "embed",
        payload = embedData,
    })
end

function WebhookScheduler.QueueEvent(eventName: string, data: table)
    enqueue({
        type = "event",
        payload = {
            event = eventName,
            data = data,
        }
    })
end

---------------------------------------------------------------------
-- Dispatcher
---------------------------------------------------------------------

local function dispatch(entry)
    if not entry then return end

    if entry.type == "raw" then
        Webhooks.SendRaw(entry.payload)
        return
    end

    if entry.type == "embed" then
        Webhooks.SendEmbed(entry.payload)
        return
    end

    if entry.type == "event" then
        Webhooks.SendEvent(entry.payload.event, entry.payload.data)
        return
    end
end

---------------------------------------------------------------------
-- Main Loop
---------------------------------------------------------------------

local function runScheduler()
    if running then return end
    running = true

    task.spawn(function()
        while running do
            local nextEntry = dequeue()

            if nextEntry then
                dispatch(nextEntry)
                task.wait(Config.Webhooks.DispatchDelay)
            else
                task.wait(0.25)
            end
        end
    end)
end

---------------------------------------------------------------------
-- Public Controls
---------------------------------------------------------------------

function WebhookScheduler.Start()
    runScheduler()
end

function WebhookScheduler.Stop()
    running = false
end

function WebhookScheduler.Clear()
    table.clear(queue)
end

---------------------------------------------------------------------

return WebhookScheduler
