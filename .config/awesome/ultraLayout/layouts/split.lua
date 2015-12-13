local table = require("util.table")

local function new(cnt, horizontal)
  local data = {}

  local c = assert(cnt.children)

  function data:layout()
    local area = cnt.geometry
    local count = #c

    if horizontal then
      local step = area.width / count
      local x = area.x
      for k, v in pairs(c) do
        v.x = x
        v.y = area.y
        v.width = step
        v.height = area.height

        x = x + step
      end
    else
      local step = area.height / count
      local y = area.y
      for k, v in pairs(c) do
        v.x = area.x
        v.y = y
        v.width = area.width
        v.height = step

        y = y + step
      end
    end
  end

  function data:move_focus_side(direction)
    local index = cnt.active_index
    if not index then return nil end

    if horizontal then
      if direction == "left" then
        return c[index - 1]
      elseif direction == "right" then
        return c[index + 1]
      end
    else
      if direction == "up" then
        return c[index - 1]
      elseif direction == "down" then
        return c[index + 1]
      end
    end

    return nil
  end

  return data
end


return {
  h_split = setmetatable({}, { __index = { new = function(cnt) return new(cnt, true)  end } }),
  v_split = setmetatable({}, { __index = { new = function(cnt) return new(cnt, false) end } })
}