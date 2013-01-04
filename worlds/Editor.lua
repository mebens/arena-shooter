Editor = class("Editor", World)
Editor.static.commands = {}

function Editor:initialize()
  World.initialize(self)
  self.font = debug.settings.font
  self.camera = EditorCamera:new()
  self.points = {}
  self.spawns = {}
  self.boxWidth = 40
  self.boxHeight = 40
  self:resetPlayer()
end

function Editor:start()
  love.mouse.setVisible(true)
  debug.include(Editor.commands)
end

function Editor:stop()
  love.mouse.setVisible(false)
  debug.exclude(Editor.commands)
end

function Editor:update(dt)
  World.update(self, dt)
  
  if input.pressed("editorWalls") then
    self.mode = self.mode ~= "walls" and "walls" or nil
  elseif input.pressed("editorSpawn") then
    self.mode = self.mode ~= "spawn" and "spawn" or nil
  elseif input.pressed("editorPlayer") then
    self.mode = self.mode ~= "player" and "player" or nil
  end
  
  if self.mode == "walls" then
    if mouse.pressed.l then
      local px, py = mouse.x, mouse.y
      
      if #self.points >= 2 and input.down("editorLock") then
        px, py = self:getLockedPoint(px, py)
      end
      
      self.points[#self.points + 1] = px
      self.points[#self.points + 1] = py
    elseif input.pressed("editorDelete") then
      self.points[#self.points] = nil
      self.points[#self.points] = nil
    elseif input.pressed("editorReset") then
      self.points = {}
    end
  elseif self.mode == "spawn" then
    if mouse.pressed.l then
      self.spawns[#self.spawns + 1] = mouse.x
      self.spawns[#self.spawns + 1] = mouse.y
    elseif input.pressed("editorDelete") then
      self.spawns[#self.spawns] = nil
      self.spawns[#self.spawns] = nil
    elseif input.pressed("editorReset") then
      self.spawns = {}
    end
  elseif self.mode == "player" then
    if mouse.pressed.l then
      self.player.x = mouse.x
      self.player.y = mouse.y
    elseif input.pressed("editorReset") then
      self:resetPlayer()
    end
  end
end

function Editor:draw()
  love.graphics.setFont(self.font)
  love.graphics.print(("Mode: %s\nMouse: %i, %i"):format(self.mode or "none", mouse.x, mouse.y), 5, 5)
  self.camera:set()
  
  local p = self.points
  love.graphics.setLineWidth(5)
  love.graphics.storeColor()
  
  if self.mode == "walls" then
    if #p >= 2 then
      for i = 1, #p - 2, 2 do
        love.graphics.line(p[i], p[i + 1], p[i + 2], p[i + 3])
      end
      
      local mx, my = love.mouse.getWorldPosition()
      if input.down("editorLock") then mx, my = self:getLockedPoint(mx, my) end
      love.graphics.line(p[#p - 1], p[#p], mx, my)
    end
  else
    if #p == 4 then
      love.graphics.line(unpack(p))
    elseif #p >= 6 then
      love.graphics.polygon("line", p)
    end
    
    if self.mode then
      if self.mode == "spawn" then
        love.graphics.setColor(255, 0, 0, 150)
      else
        love.graphics.setColor(0, 255, 0, 150)
      end
      
      self:drawBox(mouse.x, mouse.y)
    end
  end
  
  for i = 1, #self.spawns, 2 do
    love.graphics.setColor(255, 0, 0)
    self:drawBox(self.spawns[i], self.spawns[i + 1])
  end
  
  love.graphics.setColor(0, 255, 0)
  self:drawBox(self.player.x, self.player.y)
  
  love.graphics.resetColor()
  love.graphics.setLineWidth(1)
  self.camera:unset()
end

function Editor:getLockedPoint(x, y)
  local ox, oy = self.points[#self.points - 1], self.points[#self.points]
  local angle = math.rad(math.round(math.deg(math.angle(ox, oy, x, y)) / 45) * 45)
  local dist = math.distance(ox, oy, x, y)
  return ox + dist * math.cos(angle), oy + dist * math.sin(angle)
end

function Editor:drawBox(x, y)
  love.graphics.rectangle("fill", x - self.boxWidth / 2, y - self.boxHeight / 2, self.boxWidth, self.boxHeight)
end

function Editor:resetPlayer()
  self.player = { x = love.graphics.width / 2, y = love.graphics.height / 2 }
end

function Editor:load(name)
  local path = "arenas/" .. name .. ".lua"
  
  if not love.filesystem.exists(path) then
    path = "assets/" .. path
    assert(love.filesystem.exists(path), "An arena with the name '" .. name .. "' doesn't exist.")
  end
  
  local data = loadstring(love.filesystem.read(path))()
  self.name = data.name
  self.points = data.points
  self.spawns = data.spawns
  self.player = data.player
end

function Editor:save(name)
  if not self.name then self.name = name end
  local str = "return {"
  
  for _, v in pairs{"points", "spawns"} do
    local t = self[v]
    str = str .. '["' .. v .. '"]={'
    
    for i = 1, #t do
      str = str .. t[i]
      if i < #t then str = str .. "," end
    end
    
    str = str .. "},"
  end
  
  str = str .. '["player"]={["x"]=' .. self.player.x .. ',["y"]=' .. self.player.y .. '}}'
  
  if not love.filesystem.exists("arenas") then love.filesystem.mkdir("arenas") end
  love.filesystem.write("arenas/" .. (name or self.name) .. ".lua", str)
end

function Editor.commands:new(name)
  assert(instanceOf(Editor, ammo.world), "ammo.world is not an Editor")
  ammo.world.points = {}
  ammo.world.spawns = {}
  ammo.world:resetPlayer()
  if name then ammo.world.name = name end
end

function Editor.commands:save(name)
  assert(instanceOf(Editor, ammo.world), "ammo.world is not an Editor")
  ammo.world:save(name)
  return "Arena saved as'" .. (name or ammo.world.name) .. "'"
end

function Editor.commands:load(name)
  assert(instanceOf(Editor, ammo.world), "ammo.world is not an Editor")
  ammo.world:load(name)
end

function Editor.commands:name(name)
  assert(instanceOf(Editor, ammo.world), "ammo.world is not an Editor")
  ammo.world.name = name
  return "Arena named '" .. name .. "'"
end

function Editor.commands:delete(name)
  assert(instanceOf(Editor, ammo.world), "ammo.world is not an Editor")
  name = name or ammo.world.name
  assert(love.filesystem.exists("arenas/" .. name .. ".lua"), "An arena with the name '" .. name .. "' doesn't exist.")
  love.filesystem.remove("arenas/" .. name .. ".lua")
  return "Arena named '" .. name .. "' has been removed."
end
