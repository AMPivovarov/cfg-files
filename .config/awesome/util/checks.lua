local module = {}

module.is_nil    = function(value) return type(value) == "nil"      end
module.is_number = function(value) return type(value) == "number"   end
module.is_func   = function(value) return type(value) == "function" end
module.is_table  = function(value) return type(value) == "table"    end
module.is_string = function(value) return type(value) == "string"   end
module.is_bool   = function(value) return type(value) == "boolean"  end
module.is_int    = function(value) return value % 1 == 0 end

local report_type_error = function(value, check)
  if not check(value) then error("Wrong type given: " .. type(value)) end
end
module.assert_nil    = function(value) report_type_error(value, module.is_nil   ) end
module.assert_number = function(value) report_type_error(value, module.is_number) end
module.assert_func   = function(value) report_type_error(value, module.is_func  ) end
module.assert_table  = function(value) report_type_error(value, module.is_table ) end
module.assert_string = function(value) report_type_error(value, module.is_string) end
module.assert_bool   = function(value) report_type_error(value, module.is_bool  ) end
module.assert_int    = function(value) report_type_error(value, module.is_int   ) end

module.assert_one_of = function(value, expected)
  for k, v in pairs(expected) do
    if v == value then return end
  end

  local variants
  for k, v in pairs(expected) do
    variants = variants and variants .. ", " or ""
    variants = variants .. tostring(v)
  end
  error("Unexpected argument: " .. tostring(value) .. " passed, but one of " .. variants .. " expected")
end

return module