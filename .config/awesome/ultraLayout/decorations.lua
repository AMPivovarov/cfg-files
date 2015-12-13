local awful         = require("awful")
local table         = require("util.table")
local checks        = require("util.checks")
local object_model  = require("ultraLayout.object_model")

local function create(group)
  local private = {
    __classname   = "decorations",

    group = group,

    decorations = {},
  }
  local data = {}


  function data:clear()
    for k, v in pairs(private.decorations) do
      v.visible = false
    end
    private.decorations = {}
  end

  function data:show()
    for k, v in pairs(private.decorations) do
      v.visible = true
    end
  end

  function data:add(widget)
    table.insert(private.decorations, widget)
  end


  data.__set_map = {
  }

  data.__get_map = {
  }

  local args = {
    autosignal_fields = {},
    mutable_fields = {},
  }

  object_model(data, private, args)

  return data
end

return setmetatable({}, { __call = function(_, ...) return create(...) end })