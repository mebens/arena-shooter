MessageEnabled = {}

function MessageEnabled:setupMessages()
  self._listeners = {}
end

function MessageEnabled:addListener(name, callback, ...)
  if type(name) == "table" then
    for i, v in ipairs(name) do self:addListener(name) end
  else
    if not self._listeners[name] then self._listeners[name] = {} end
    self._listeners[name][callback] = { ... }
  end
end

function MessageEnabled:removeListener(name, callback)
  if self._listeners[name] then self._listeners[name][callback] = nil end
end

function MessageEnabled:sendMessage(name)
  if not self._listeners[name] then error("No listeners for message '" .. name .. "'") end
  for func, args in pairs(self._listeners[name]) do func(unpack(args)) end
end
