Editor = class("Editor", World)
Editor.static.commands = {}

function Editor:initialize()
  World.initialize(self)
  self.font = debug.settings.font
  self.camera = EditorCamera:new()
  self.shapes = {}
  self.spawns = {}
  self.boxWidth = Enemy.width * 2
  self.boxHeight = Enemy.height * 2
  self:resetPlayer()
  
  self.mode = ""
  self.selectedShape = 0
  self.shapeMode = 1
  self.creatingShape = false
  
  self.inputModes = {
    ["editorShapeSelect"] = "shapeSelect",
    ["editorShapeMode"] = "shapeMode",
    ["editorShapeNew"] = "shapeNew",
    ["editorSpawn"] = "spawn",
    ["editorPlayer"] = "player",
    ["editorResetMode"] = ""
  }
  
  self.shapeModes = { "rectangle", "pentagon", "hexagon" }
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
  
  -- mode inputs
  for k, v in pairs(self.inputModes) do
    if input.pressed(k) then self.mode = v end
  end
  
  if self.mode == "shapeSelect" then
    -- shape selection
    if #self.shapes > 1 then
      if mouse.pressed.wu and self.selectedShape > 1 then
        self.selectedShape = self.selectedShape - 1
      elseif mouse.pressed.wd and self.selectedShape < #self.shapes then
        self.selectedShape = self.selectedShape + 1
      end
    end
    
    -- shape deletion
    if input.pressed("editorDelete") then
      table.remove(self.shapes, self.selectedShape)
      
      if #self.shapes == 0 then
        self.selectedShape = 0
      elseif self.selectedShape == #self.shapes + 1 then
        self.selectedShape = #self.shapes
      end
    end
  elseif self.mode == "shapeMode" then
    if mouse.pressed.wu and self.shapeMode > 1 then
      self.shapeMode = self.shapeMode - 1
    elseif mouse.pressed.wd and self.shapeMode < #self.shapes then
      self.shapeMode = self.shapeMode + 1
    end
  elseif self.mode == "shapeNew" then
    if self.creatingShape then
      self:createShape()
      
      if input.pressed("editorCancel") then
        self.creatingShape = false
        self.workingShape = nil
      elseif mouse.released.l then
        self.shapes[#self.shapes + 1] = self.workingShape
        self.workingShape = nil
        self.creatingShape = false
        self.selectedShape = #self.shapes
      end
    elseif mouse.pressed.l then
      self.creatingShape = true
      self.workingShape = { x = mouse.x, y = mouse.y }
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
  -- info
  local format = "Mouse: %i, %i\nEditor Mode: %s\nShape Mode: %s"
  if self.mode == "shapeSelect" then format = format .. "\nSelected Shape: %i" end
  
  love.graphics.setFont(self.font)
  love.graphics.print((format):format(
    mouse.x,
    mouse.y,
    self.mode == "" and "none" or self.mode,
    self.shapeModes[self.shapeMode],
    self.selectedShape
  ), 5, 5)
  
  self.camera:set()
  love.graphics.storeColor()
  
  -- resolution box
  love.graphics.setLineWidth(3)
  love.graphics.setColor(200, 200, 200)
  love.graphics.rectangle("line", 0, 0, data.resolutionWidth, data.resolutionHeight)
  
  -- shapes
  love.graphics.setLineWidth(5)
  
  for i, v in ipairs(self.shapes) do
    if self.mode == "shapeSelect" and self.selectedShape == i then
      love.graphics.setColor(255, 50, 70)
    else
      love.graphics.setColor(255, 255, 255)
    end
    
    love.graphics.polygon("line", unpack(v))
  end
  
  -- spawns
  for i = 1, #self.spawns, 2 do
    love.graphics.setColor(255, 0, 0)
    self:drawBox(self.spawns[i], self.spawns[i + 1])
  end
  
  -- player
  love.graphics.setColor(0, 255, 0)
  self:drawBox(self.player.x, self.player.y)
  
  -- mode specific stuff
  if self.creatingShape then
    if #self.workingShape > 1 then
      love.graphics.setLineWidth(5)
      love.graphics.setColor(255, 255, 255, 150)
      love.graphics.polygon("line", unpack(self.workingShape))
    end
  elseif self.mode == "spawn" then
    love.graphics.setColor(255, 0, 0, 150)
    self:drawBox(mouse.x, mouse.y)
  elseif self.mode == "player" then
    love.graphics.setColor(0, 255, 0, 150)
    self:drawBox(mouse.x, mouse.y)
  end
  
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

function Editor:createShape()
  local mode = self.shapeModes[self.shapeMode]
  local shape = self.workingShape
  local ox, oy = shape.x, shape.y
  local dist = math.distance(ox, oy, mouse.x, mouse.y)
  local angle = math.angle(ox, oy, mouse.x, mouse.y)
  
  if mode == "rectangle" then
    shape[1] = ox - dist * math.cos(angle)
    shape[2] = oy - dist * math.sin(angle)
    shape[3] = ox + dist * math.cos(angle)
    shape[4] = oy - dist * math.sin(angle)
    shape[5] = ox + dist * math.cos(angle)
    shape[6] = oy + dist * math.sin(angle)
    shape[7] = ox - dist * math.cos(angle)
    shape[8] = oy + dist * math.sin(angle)
  end
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
