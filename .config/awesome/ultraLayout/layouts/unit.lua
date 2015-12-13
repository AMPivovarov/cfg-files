local function new(cnt)
  local data = {}

  function data:layout()
    return cnt.geometry
  end

  return data
end

return setmetatable({}, { __index = { new = new } })