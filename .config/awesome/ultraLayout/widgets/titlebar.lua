local awful = require("awful")
local beautiful = require("beautiful")
local table = require("util.table")
local checks = require("util.checks")
local wibox = require("wibox")


local function create_for_leaf(leaf, args)
  local wb = wibox({
    position = "free",
    ontop = true,
    visible = false,

    x = args.x,
    y = args.y,
    width = args.width,
    height = args.height,
  })

  local textb = wibox.widget.textbox(leaf.client.name, true)

  local l = wibox.layout.align.horizontal()
  l:set_left(textb)
  wb:set_widget(l)

  if leaf.focused then
    wb:set_bg(beautiful.bg_focused)
  else
    wb:set_bg(beautiful.bg_normal)
  end

  return wb
end


local function create__for_container(cnt, args)
end


local function create(cnt, args)
  if cnt.leaf then
    return create_for_leaf(cnt, args)
  else
    return create__for_container(cnt, args)
  end
end

return setmetatable({}, { __call = function(_, ...) return create(...) end })