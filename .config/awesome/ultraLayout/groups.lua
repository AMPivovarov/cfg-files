local awful         = require("awful")
local table         = require("util.table")
local checks        = require("util.checks")
local object_model  = require("ultraLayout.object_model")
local create_container = require("ultraLayout.containers")

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
  }
  local group = {
  }

  function group:__init()
    private.root  = create_container(group)
    private.focus = self.root
  end


  function group.arrange(p)
    group.root.geometry = p.workarea
    group.root:do_layout()

    local clients = {}
    for k, v in pairs(group.root:get_leaves()) do
      clients[v.client] = v:do_layout()
    end

    for k, c in pairs(p.clients) do
      if clients[c] then
        p.geometries[c] = clients[c]
      end
    end
  end


  function group:handle_add_client(client)
    local parent = self.focus.leaf and self.focus.parent or self.focus

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
      self.focus = parent
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

    local current = self.focus.leaf and self.focus.parent or self.focus
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


  function group:set_layout(layout)
    self.focus:set_layout(layout)
    self:mark_dirty()
  end

  function group:mark_dirty()
    awful.layout.arrange(self.screen)
  end


  local function set_focus(to_focus)
    if private.focus == to_focus then return end
    private.focus = to_focus

    local current = to_focus
    while current ~= group.root do
      current.parent.active = current
      current = current.parent
    end

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
  }

  local args = {
    autosignal_fields = { "focus" },
    mutable_fields = { "focus" },
  }

  object_model(group, private, args)


  client.connect_signal("focus", function(client)
    local new_focus = group.client_to_cnt[client]
    if new_focus then
      group.focus = new_focus
    end
  end)

  return group
end

return setmetatable({}, { __call = function(_, ...) return create_group(...) end })