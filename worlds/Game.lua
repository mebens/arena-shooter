Game = class("Game", PhysicalWorld):include(MessageEnabled)

function Game:initialize(width, height)
  PhysicalWorld.initialize(self, 0, 0)
  self:setupMessages()
  love.physics.setMeter(50)
  
  self.width = width or 1440
  self.height = height or 900
  self.paused = false
  self.over = false
  self.deltaFactor = 1
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
  local padding = 40
  
  self:setupLayers{
    [-2] = { 0, post = blur.include }, -- fade
    [-1] = 0, -- HUD
    [0] = 1, -- in-world HUD
    [1] = { 1, pre = blur.exclude }, -- barrier
    [2] = 1, -- player
    [3] = 1, -- enemy
    [4] = 1, -- missile
    [5] = 1 -- particles
  }
  
  self:add(
    self.score,
    self.fade,
    self.hud,
    Barrier:new(),
    self.player,
    EnemySpawner:new(padding, padding),
    EnemySpawner:new(self.width - padding, padding),
    EnemySpawner:new(padding, self.height - padding),
    EnemySpawner:new(self.width - padding, self.height - padding)
  )
end

function Game:start()
  self.fade:fadeIn()
end

function Game:update(dt)
  if input.pressed("pause") then self:pause() end
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
  PhysicalWorld.update(self, dt)
  if key.pressed.k then self.player:die() end
end

function Game:draw()
  if not self.paused or not blur.active then
    blur.start()
    PhysicalWorld.draw(self)
  end
  
  blur.stop()
end

function Game:gameOver()
  if self.slowmoTween then self.slowmoTween:stop() end
  self.slowmoTween = tween(self, 0.25, { deltaFactor = 0.1 }, nil, self.stopGameOverSlowmo, self)
  self.over = true
  self.hud.drawCursor = false
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

function Game:reset()
  ammo.world = Game:new() -- quick, temporary way of doing it
end

function Game:stopGameOverSlowmo()
  self.slowmoTween = tween(self, "0.2:0.3", { deltaFactor = 1 }, nil, self.gameOverSlowmoStopped, self)
end

function Game:gameOverSlowmoStopped()
  self.canReset = true
  data.score(self.score.score)
  self.hud:gameOver()
end
