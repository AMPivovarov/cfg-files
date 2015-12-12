local awful = require("awful")
local create_group = require("ultraLayout.groups")

local module = {}


local tag_groups = {}


local function get_tag(tag)
  local tag = tag
  if not tag then
    local screen = awful.screen.focused()
    tag = awful.tag.selected(screen)
  end
  return tag
end


module.init = function(tag)
  local tag = get_tag(tag)
  if not tag or tag_groups[tag] then return end

  local screen = awful.tag.getscreen(tag)
  local group = create_group(screen)
  tag_groups[tag] = group

  for k, v in pairs(tag:clients()) do
    group:handle_add_client(v)
  end

  awful.layout.set(group, tag)
end

module.move_focus_parent = function(tag)
  local tag = get_tag(tag)
  if not tag_groups[tag] then return end

  tag_groups[tag]:move_focus_parent()
end

module.move_focus_child = function(tag)
  local tag = get_tag(tag)
  if not tag_groups[tag] then return end

  tag_groups[tag]:move_focus_child()
end

module.move_focus_side = function(direction, tag)
  local tag = get_tag(tag)
  if not tag_groups[tag] then return end

  tag_groups[tag]:move_focus_side(direction)
end


client.connect_signal("tagged", function(c, tag)
  if tag_groups[tag] then
    tag_groups[tag]:handle_add_client(c)
  end
end)

client.connect_signal("untagged", function(c, tag)
  if tag_groups[tag] then
    tag_groups[tag]:handle_remove_client(c)
  end
end)

return module