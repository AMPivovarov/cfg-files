local titlebar = require("ultraLayout.widgets.titlebar")

local function new(cnt)
  local data = {}

  function data:layout()
    local height = 16
    local g = cnt.geometry

    local args = {
      x = g.x,
      y = g.y,
      width = g.width,
      height = height
    }

    g.y = g.y + height
    g.height = g.height - height

    
    local bar = titlebar(cnt, args)
    cnt.group.decorations:add(bar)

    return g
  end

  return data
end

return setmetatable({}, { __index = { new = new } })