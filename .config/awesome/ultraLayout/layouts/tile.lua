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

  return data
end

return setmetatable({}, { __index = { new = new } })