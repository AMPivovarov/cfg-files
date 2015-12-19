local awful         = require("awful")
local table         = require("util.table")
local checks        = require("util.checks")
local object_model  = require("ultraLayout.object_model")
local create_container   = require("ultraLayout.containers")
local create_decorations = require("ultraLayout.decorations")

local null = object_model.null

local function create_group(screen, config)
  local private = {
    __classname   = "group",

    name          = "ultra",
    screen        = screen,
    config        = config or {},

    client_to_cnt = {},
    root          = null,

    focus         = null,
    decorations   = null,
  }
  local group = {
  }

  function group:__init()
    private.root  = create_container(group)
    private.focus = self.root
    private.decorations = create_decorations(group)
  end


  function group.arrange(p)
    group.root.geometry = p.workarea
    group.root:do_layout()
    group.decorations:clear()

    local clients = {}
    for k, v in pairs(group.root:get_leaves()) do
      clients[v.client] = v:do_layout()
    end

    for k, c in pairs(p.clients) do
      if clients[c] then
        p.geometries[c] = clients[c]
      end
    end

    group.decorations:show()
  end


  function group:handle_add_client(client)
    local parent = self.focus_cnt

    local cnt = create_container(self, parent, client)
    parent:add_child(cnt)
    self.client_to_cnt[client] = cnt

    self:mark_dirty()
  end

  function group:handle_remove_client(client)
    local cnt = self.client_to_cnt[client]
    local parent = cnt.parent
    local was_focused = cnt.focused

    parent:remove_child(cnt)
    self.client_to_cnt[client] = nil

    while (parent ~= self.root and parent:is_empty()) do
      was_focused = was_focused or parent.focused
      parent.parent:remove_child(parent)
      parent = parent.parent
    end

    if was_focused then
      local current = parent
      while current.active do
        current = current.active
      end
      self.focus = current
    end

    self:mark_dirty()
  end

  function group:move_focus_parent()
    if self.focus ~= self.root then
      self.focus = self.focus.parent
    end
  end

  function group:move_focus_child()
    if self.focus.active ~= nil then
      self.focus = self.focus.active
    end
  end

  function group:move_focus_side(direction)
    checks.assert_one_of(direction, { "left", "right", "up", "down" })

    local current = self.focus_cnt
    local target
    while current and target == nil do
      target = current:move_focus_side(direction)
      current = current.parent
    end

    if target then
      while not target.leaf and target.active do
        target = target.active
      end
      self.focus = target
    end
  end


  function group:move_container_parent()
    local current = self.focus
    local parent = current.parent
    if current == self.root or parent == self.root then return end
    local target = parent.parent

    parent:remove_child(current)
    target:add_child(current)
    current.parent = target

    if parent:is_empty() then
      target:remove_child(parent)
    end

    self:update_active_by_focus()
    self:mark_dirty()
  end

  function group:move_container_side(direction)
    checks.assert_one_of(direction, { "left", "right", "up", "down" })
    local current = self.focus
    local parent = current.parent
    if current == self.root then return end

    local cnt = current.leaf and current.parent or current
    local target
    while cnt and target == nil do
      target = cnt:move_focus_side(direction)
      cnt = cnt.parent
    end

    if not target then return end
    if target.leaf then
      local target_leaf = target
      local target = target.parent

      if target ~= parent then
        local index = table.index_of(target.children, target_leaf)
        target:add_child(current, index)
        parent:remove_child(current)
        current.parent = target
      else
        parent:remove_child(current)
        local index = table.index_of(target.children, target_leaf)
        target:add_child(current, index)
      end
    else
      parent:remove_child(current)
      target:add_child(current)
      current.parent = target
    end

    self:update_active_by_focus()
    self:mark_dirty()
  end


  function group:set_layout(layout)
    local current = self.focus

    if current.leaf then
      local parent = current.parent
      local index = table.index_of(parent.children, current)

      local new_cnt = create_container(group, parent)
      new_cnt:set_layout(layout)
      new_cnt:add_child(current)
      current.parent = new_cnt

      parent.children[index] = new_cnt
      if parent.active == current then
        parent.active = new_cnt
      end
    else
      current:set_layout(layout)
    end

    self:mark_dirty()
  end

  function group:mark_dirty()
    awful.layout.arrange(self.screen)
  end

  function group:refresh_focus()
    local new_focus = group.client_to_cnt[client.focus]
    if new_focus then
      group.focus = new_focus
    end
  end

  function group:update_active_by_focus()
    local focus = self.focus
    local current = focus
    while current ~= group.root do
      current.parent.active = current
      current = current.parent
    end
  end

  local function set_focus(to_focus)
    if private.focus == to_focus then return end
    private.focus = to_focus

    group:update_active_by_focus()

    if to_focus.leaf then
      client.focus = to_focus.client
      to_focus.client:raise()
    else
      client.focus = nil
    end

    group:mark_dirty()
  end


  group.__set_map = {
    focus = set_focus
  }

  group.__get_map = {
    focus_cnt = function() return group.focus.leaf and group.focus.parent or group.focus end,
  }

  local args = {
    autosignal_fields = { "focus" },
    mutable_fields = { "focus" },
  }

  object_model(group, private, args)


  client.connect_signal("focus", function(client)
    group:refresh_focus()
  end)

  return group
end

return setmetatable({}, { __call = function(_, ...) return create_group(...) end })