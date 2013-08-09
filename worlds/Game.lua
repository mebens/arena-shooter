Game = class("Game", PhysicalWorld):include(MessageEnabled)

function Game:initialize(design, width, height)
  PhysicalWorld.initialize(self, 0, 0)
  self:setupMessages()
  love.physics.setMeter(50)
  
  self.design = design or arenas[1]
  self.width = width or self.design.width or 1680
  self.height = height or self.design.height or 1050
  self.paused = false
  self.over = false
  self.deltaFactor = 1
  self.internalBarriers = {}
  Game.static.id = self

  self.maxSlowmo = 2
  self.slowmoFactor = 0.25
  self.slowmoRecharge = 0.2
  self.slowmo = self.maxSlowmo
  self.slowmoActive = false
  
  self.camera = GameCamera:new()
  self.score = ScoreTracker:new()
  self.fade = Fade:new(0.5, true)
  self.hud = HUD:new()
  self.player = Player:new(self.width / 2, self.height / 2)
  self.background = Background:new()
  
  self:setupLayers{
    postfx.include,
    [-2] = 0, -- fade
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
  
  self:add(self.score, self.fade, self.hud, self.player)
  self.design.func(self, self.width, self.height)
  self:add(self.background)
  self:addListener("gem.collected", self.spawnGem, self)
end

function Game:start()
  self.fade:fadeIn()
  self:spawnGem()
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
        if self.slowmoTween then self.slowmoTween:stop() end
        self.slowmoTween = tween(self, 0.15, { deltaFactor = 1 })
        self.slowmoActive = false
      end
    else
      if self.slowmo < self.maxSlowmo then
        self.slowmo = math.min(self.slowmo + self.slowmoRecharge * dt, self.maxSlowmo)
      end
      
      if self.slowmo > 0 and input.pressed("slowmo") then
        if self.slowmoTween then self.slowmoTween:stop() end
        self.slowmoTween = tween(self, 0.15, { deltaFactor = self.slowmoFactor })
        self.slowmoActive = true
        self.player:showSlowmo()
      end
    end
  elseif self.canReset and input.pressed("reset") then
    self.fade:fadeOut(self.reset, self)
  end
  
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
  self.slowmoTween = tween(self, 0.25, { deltaFactor = 0.1 }, nil, self.stopGameOverSlowmo, self)
  self.over = true
  self.hud.drawCursor = false
end

function Game:spawnGem()
  local colliding = false
  local padding = 30
  local x, y
  
  repeat
    x = math.random(padding, self.width)
    y = math.random(padding, self.height)
    
    -- check that the angles to each point sum up to around math.tau (meaning it's inside the regular polygon)
    if self.barrier.numSides ~= 4 then
      local sumAngle = 0
      local roundedTau = math.round(math.tau * 100) / 100 -- two points of precision
      
      for i = 1, #self.barrier.points, 2 do
        sumAngle = sumAngle + math.angle(x, y, self.barrier.points[i], self.barrier.points[i + 1])
      end
      
      sumAngle = math.round(sumAngle * 100) / 100
      if sumAngle ~= roundedTau then colliding = true end
    end
    
    -- check against the internal barriers
    if not colliding and #self.internalBarriers > 0 then
      local cos1 = (padding / 2) * math.cos(math.tau / 8) -- 45 degrees
      local sin1 = (padding / 2) * math.sin(math.tau / 8)
      local cos2 = (padding / 2) * math.cos(math.tau * .375) -- 135 degrees
      local sin2 = (padding / 2) * math.sin(math.tau * .375)
      
      -- check raycast with two diagonal lines around the point, the size of padding
      for _, v in pairs(self.internalBarriers) do
        local ray1 = v.fixture:rayCast(x - cos1, y - sin1, x + cos1, y + sin1, 1)
        local ray2 = v.fixture:rayCast(x - cos2, y - sin2, x + cos2, y + sin2, 1)
        print(x, y, ray1, ray2)
        if ray1 or ray2 then
          colliding = true
          break
        end
      end
    end
  until not colliding
    
  self:add(Gem:new(x, y))
end
      

function Game:resolutionChanged()
  self.camera:update()
  self.hud:adjustText()
  self.background:resize()
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

function Game:reset()
  ammo.world = Game:new(self.design, self.width, self.height)
end

function Game:stopGameOverSlowmo()
  self.slowmoTween = tween(self, "0.2:0.3", { deltaFactor = 1 }, nil, self.gameOverSlowmoStopped, self)
end

function Game:gameOverSlowmoStopped()
  self.canReset = true
  data.score(self.score.score)
  self.hud:gameOver()
end
