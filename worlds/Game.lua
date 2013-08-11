Game = class("Game", PhysicalWorld):include(MessageEnabled)

function Game:initialize(design, width, height)
  PhysicalWorld.initialize(self, 0, 0)
  self:setupMessages()
  love.physics.setMeter(50)
  
  self.design = design or arenas[1]
  self.width = width or self.design.width or 1680
  self.height = height or self.design.height or 1050
  self.internalBarriers = {}
  self.paused = false
  self.over = false
  self.score = 0
  self.deltaFactor = 1
  Game.static.id = self

  self.maxSlowmo = 2
  self.slowmoFactor = 0.25
  self.slowmoRecharge = 0.2
  self.slowmo = self.maxSlowmo
  self.slowmoActive = false
  self.slowmoFadeTime = 0.3
  
  self.camera = GameCamera:new()
  self.hud = HUD:new()
  self.player = Player:new(self.width / 2, self.height / 2)
  self.background = Background:new()
  
  self:setupLayers{
    postfx.include,
    [-1] = 0, -- HUD
    [0] = 1, -- in-world HUD
    postfx.exclude,
    [1] = 1, -- barrier
    [2] = 1, -- player
    [3] = 1, -- enemy
    [4] = 1, -- missile
    [5] = 1, -- gem
    [6] = 1, -- particles
    [7] = 1 -- background
  }
  
  self:add(self.hud, self.player)
  self.design.func(self, self.width, self.height)
  self:addListener("gem.collected", self.gemCollected, self)
end

function Game:start()
  fade.fadeIn()
  
  -- gotta wait for the physics shapes to set up
  delay(0, function()
    self:generateMasks()
    self:add(self.background)
    self:spawnGem()
  end)
end

function Game:update(dt)
  if key.pressed.kp0 then
    self.paused = not self.paused
  elseif input.pressed("pause") then
    self:pause()
  end
  
  if self.paused then return end
  
  if not self.over then
    if self.slowmoActive then
      self.slowmo = self.slowmo - dt
      
      if self.slowmo <= 0 or input.released("slowmo") then
        self.slowmoTween = AttrTween:new(self, self.slowmoFadeTime, { deltaFactor = 1 })
        self.slowmoTween:start()
        self.slowmoActive = false
      end
    else
      if self.slowmo < self.maxSlowmo then
        self.slowmo = math.min(self.slowmo + self.slowmoRecharge * dt, self.maxSlowmo)
      end
      
      if self.slowmo > 0 and input.pressed("slowmo") then
        self.slowmoTween = AttrTween:new(self, self.slowmoFadeTime, { deltaFactor = self.slowmoFactor })
        self.slowmoTween:start()
        self.slowmoActive = true
        self.player:showSlowmo()
      end
    end
  elseif self.canReset and input.pressed("reset") then
    fade.fadeOut(self.reset, self)
  end
  
  -- need to update slowmo tweens before the delta gets changed
  if self.slowmoTween and self.slowmoTween.active then self.slowmoTween:update(dt) end
  dt = dt * self.deltaFactor
  _G.dt = dt
  postfx.update(dt)
  PhysicalWorld.update(self, dt)
  if key.pressed.k then self.player:die() end
end

function Game:draw()
  postfx.start()
  PhysicalWorld.draw(self)
  postfx.stop()
end

function Game:gameOver()
  if self.slowmoTween then self.slowmoTween:stop() end
  self.slowmoTween = AttrTween:new(self, 0.75, { deltaFactor = 0.1 }, ease.quadOut, self.stopGameOverSlowmo, self)
  self.slowmoTween:start()
  self.over = true
  self.canReset = true
  self.hud.drawCursor = false
  --self:gameOverSlowmoStopped()
  data.score(self)
end

function Game:gemCollected()
  self.score = self.score + 1
  self:spawnGem()
end

function Game:spawnGem()
  local regen = false
  local padding = 30
  local x, y
  
  repeat
    regen = false
    x = math.random(padding, self.width - padding)
    y = math.random(padding, self.height - padding)
    if math.distance(self.player.x, self.player.y, x, y) < 200 then regen = true end
    
    if not regen then
      local r, g, b = self.gemMask:getPixel(x, y)
      if r ~= 255 or g ~= 255 or b ~= 255 then regen = true end
    end
  until not regen
  
  self:add(Gem:new(x, y))
end
      

function Game:resolutionChanged()
  self.camera:update()
  self.hud:adjustText()
end

function Game:pause()
  if not PauseMenu.id then PauseMenu:new() end
  ammo.world = PauseMenu.id
  self.paused = true
end

function Game:unpause()
  ammo.world = self
  self.paused = false
end

function Game:createExternalBarrier(numSides)
  self.barrier = ExternalBarrier:new(numSides)
  self:add(self.barrier)
end

function Game:addInternalBarrier(...)
  for _, v in pairs{...} do
    self:add(v)
    self.internalBarriers[#self.internalBarriers + 1] = v
  end
end

function Game:generateMasks()
  self.backgroundMask = love.graphics.newCanvas(self.width, self.height)
  love.graphics.setCanvas(self.backgroundMask)
  
  -- initial blank slate
  drawBlackBg()
  love.graphics.storeColor()
  love.graphics.setColor(255, 255, 255)
  
  -- external barrier
  if self.barrier.numSides == 4 then
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
  else
    love.graphics.polygon("fill", unpack(self.barrier.points))
  end
  
  -- internal barriers
  love.graphics.setColor(0, 0, 0)
  
  for _, v in pairs(self.internalBarriers) do
    love.graphics.polygon("fill", v:getWorldPoints(v.shape:getPoints()))
  end
  
  love.graphics.resetColor()
  love.graphics.setCanvas()
  self.gemMask = self.backgroundMask:getImageData()
end

function Game:reset()
  ammo.world = Game:new(self.design, self.width, self.height)
end

function Game:stopGameOverSlowmo()
  self.slowmoTween = AttrTween:new(self, "1.5:2", { deltaFactor = 1 }, ease.quadOut, self.gameOverSlowmoStopped, self)
  self.slowmoTween:start()
end

function Game:gameOverSlowmoStopped()
  self.hud:gameOver()
end
