local table         = require("util.table")
local checks        = require("util.checks")
local object_model  = require("ultraLayout.object_model")
local layouts       = require("ultraLayout.layouts")

local null = object_model.null

local function create_container(group, parent)
  local private = {
    __classname   = "container",
    leaf          = false,

    group         = group,
    parent        = parent or null,

    x = 0, y = 0, width = 0, height = 0,
    layout        = null,

    children      = {},
    active        = null,
  }
  local cnt = {
  }

  function cnt:__init()
    cnt:set_layout(self.group.config.default_layout or layouts.h_split)
  end

  function cnt:get_leaves(to_return)
    local to_return = to_return or {}
    for k, v in pairs(self.children) do
      if v.leaf then
        table.insert(to_return, v)
      else
        v:get_leaves(to_return)
      end
    end
    return to_return
  end

  function cnt:is_empty()
    return #self.children == 0
  end

  function cnt:set_layout(layout)
    private.layout = layout.new(cnt)
  end

  function cnt:do_layout()
    self.layout:layout()

    for k, v in pairs(self.children) do
      if not v.leaf then
        v:do_layout()
      end
    end
  end

  function cnt:add_child(cnt, index)
    local index = index or self.active_index or 0
    table.insert(self.children, index + 1, cnt)
  end

  function cnt:remove_child(cnt)
    local index = self.active_index or 0
    table.remove_value(self.children, cnt)

    if cnt == self.active then
      self.active = self.children[index] or self.children[index - 1]
    end
  end

  function cnt:move_focus_side(direction)
    return self.layout:move_focus_side(direction)
  end


  cnt.__set_map = {
    geometry = function(g) cnt.x = g.x; cnt.y = g.y; cnt.width = g.width; cnt.height = g.height end,
  }

  cnt.__get_map = {
    geometry = function() return { x = cnt.x, y = cnt.y, width = cnt.width, height = cnt.height } end,
    focused  = function() return group.focus == cnt end,
    active_index = function() return table.index_of(cnt.children, cnt.active) end,
  }

  local args = {
    autosignal_fields = {},
    mutable_fields = { "x", "y", "width", "height",
                       "active", "parent" },
  }

  return object_model(cnt, private, args)
end


local function create_leaf(group, parent, client)
  local private = {
    __classname   = "container_leaf",
    leaf          = true,

    group         = group,
    parent        = parent,
    client        = client,

    x = 0, y = 0, width = 0, height = 0,
    layout        = null,
  }
  local cnt = {
  }

  function cnt:__init()
    private.layout = layouts.unit.new(cnt)
  end

  function cnt:do_layout()
    return self.layout:layout()
  end


  cnt.__set_map = {
    geometry = function(g) cnt.x = g.x; cnt.y = g.y; cnt.width = g.width; cnt.height = g.height end,
  }

  cnt.__get_map = {
    geometry = function() return { x = cnt.x, y = cnt.y, width = cnt.width, height = cnt.height } end,
    focused  = function() return group.focus == cnt end,
  }

  local args = {
    autosignal_fields = {},
    mutable_fields = { "x", "y", "width", "height",
                       "parent" },
  }

  return object_model(cnt, private, args)
end


local function create(group, parent, client)
  if client then
    return create_leaf(group, parent, client)
  else
    return create_container(group, parent)
  end
end

return setmetatable({}, { __call = function(_, ...) return create(...) end })