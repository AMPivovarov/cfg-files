local function new(cnt)
  local data = {}

  function data:layout()
    return cnt.geometry
  end

  function data:repaint()
  end

  return data
end

return setmetatable({}, { __index = { new = new } })