Timers = {}

function Timers:addTimer(name, limit, starting)
  if not self.timers then self.timers = {} end
  
  local limitName = name .. "Time"
  local timeName = name .. "Timer"
  
  self[limitName] = limit
  self[timeName] = starting or limit
  self.timers[name] = { time = timeName, limit = limitName }
end

function Timers:resetTimer(name)
  local timer = self.timers[name]
  self[timer.time] = self[timer.time] + self[timer.limit]
end

function Timers:removeTimer(name)
  if not self.timers then return end
  self.timers[name] = nil
end

function Timers:updateTimers(dt)
  if not self.timers then return end
  
  for k, v in pairs(self.timers) do
    local time = self[v.time]
    if time > 0 then self[v.time] = time - dt end
  end
end
