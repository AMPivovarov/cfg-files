local checks = require("util.checks")

local table = table
local module = setmetatable({}, { __index = table })

module.index_of = function(t, value)
  checks.assert_table(t)
  for i = 1, #t do
    if value == t[i] then return i end
  end
  return nil
end

module.insert_unique = function(t, value)
  checks.assert_table(t)
  local index = module.index_of(t, value)
  if not index then
    table.insert(t, value)
    return true
  end
  return false
end

module.remove_value = function(t, value)
  checks.assert_table(t)
  local index = module.index_of(t, value)
  if index then
    table.remove(t, index)
    return true
  end
  return false
end

return module