local table = require("util.table")

local function new(cnt)
  local data = {}

  local c = assert(cnt.children)

  function data:layout()
    local area = cnt.geometry
    local count = #c
    local step = area.width / count

    local x = 0
    for k, v in pairs(c) do
      v.x = x
      v.y = area.y
      v.width = step
      v.height = area.height

      x = x + step
    end
  end

  function data:repaint()
  end

  function data:move_focus_side(direction)
    local index = cnt.active_index
    if not index then return nil end

    if direction == "left" then
      return c[index - 1]
    elseif direction == "right" then
      return c[index + 1]
    end

    return nil
  end

  return data
end

return setmetatable({}, { __index = { new = new } })