local wibox      = require("wibox")
local beautiful  = require("beautiful")
local awful      = require("awful")
local naughty    = require("naughty")

local module = {}
module.items = {}

function module.show_history(num)
    for i = math.max(1, #module.items - num), #module.items do
        naughty.notify(module.items[i])
    end
end

function module.clear_history(num)
	module.items = {}
end

local function update_notifications(data)
    -- Do not process same message twice
    if data.notification_history_ignore then return end
    data.notification_history_ignore = true
    table.insert(module.items, data)
end

-- Callback used to modify notifications
naughty.config.notify_callback = function(data)
    update_notifications(data)
    return data
end

return module