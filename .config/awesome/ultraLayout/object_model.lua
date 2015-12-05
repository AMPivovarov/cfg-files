local table = require("util.table")

local null = {}

local function extract_fields(private)
  local ret = {}
  for k, v in pairs(private or {}) do
    ret[k] = true
    if v == null then
      private[k] = nil
    end
  end
  return ret
end

local function array_to_keys(input)
  local ret = {}
  for k, v in pairs(input or {}) do
    ret[v] = true
  end
  return ret
end


local function setup_object(data, private, args)
  data.__get_map = data.__get_map or {}
  data.__set_map = data.__set_map or {}


  local private_fields = extract_fields(private)
  local autosignal_fields = array_to_keys(args.autosignal_fields)
  local mutable_fields = array_to_keys(args.mutable_fields)


  local signals = {}

  function data:add_signal(name, func)
    signals[name] = signals[name] or {}
    table.insert_unique(signals[name], func)
  end

  function data:remove_signal(name, func)
    if not signals[name] then return end
    table.remove_value(signals[name], func)
  end

  function data:emit_signal(name, ...)
    for k, v in pairs(signals[name] or {}) do
      v(data, ...)
    end
  end

  function data:add_autosignal_field(name)
    table.insert(autosignal_fields, name)
  end


  local function auto_signal(key)
    if autosignal_fields[key] then
      data:emit_signal(key .. "::changed")
    end
  end

  local function get_data(_, key)
    if data.__get_map[key] then
      return data.__get_map[key](data)
    elseif private_fields[key] then
      return private[key]
    else
      return rawget(data, key)
    end
  end

  local function set_data(_, key, value)
    if data.__set_map[key] == false then
      error("This is a read-only field: '" .. key .. "'\n" .. debug.traceback())
      return
    end

    if data.__set_map[key] then
      data.__set_map[key](value, data)
      auto_signal(key)
    elseif private_fields[key] then
      if not mutable_fields[key] then
        error("This is a read-only field: '" .. key .. "'\n" .. debug.traceback())
        return
      end
      private[key] = value
      auto_signal(key)
    else
      rawset(data, key, value)
    end
  end


  setmetatable(data, { __index = get_data, __newindex = set_data, __tostring = data.__tostring })

  if data.__init then
    data:__init()
  end

  return data
end

return setmetatable({ null = null }, { __call = function(_, ...) return setup_object(...) end })