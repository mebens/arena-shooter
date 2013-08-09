Player = class("Player", PhysicalEntity)
Player:include(ColorRotator)
Player:include(Timers)
Player.static.maxLives = 3

function Player:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 2
  self.width = 50
  self.height = 50
  self.scale = 1
  self.moveForce = 3500
  self.reverseForce = 4500
  self:addTimer("missile", 0.5, 0 )
  
  -- live/death system
  self.lives = Player.maxLives
  self.invincible = false
  self.flashTime = 0.25
  self.flashCount = 5
  self.flashes = 0
  
  -- ui/visuals
  self.uiPos = Vector:new(x, y)
  self.uiSpeed = 25
  self.hideSlowmoTime = 1
  self.maxSlowmoTimer = self.hideSlowmoTime
  self.slowmoColor = { 255, 255, 255, 0 }
  self.image = makeRectImage(self.width, self.height)
  
  self.colors = {
    { 250, 0, 0 },
    { 250, 100, 0 },
    { 250, 0, 0 },
    { 250, 250, 0 }
  }
end

function Player:added()
  self:setupBody()
  self:setMass(10)
  self:setLinearDamping(5)
  self:advanceColor()
  self.color[4] = 255
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(2)
end

function Player:update(dt)
  PhysicalEntity.update(self, dt)
  self:updateTimers(dt)
  self.angle = math.angle(self.x, self.y, mouse.x, mouse.y)
  
  local xAxis = input.axisDown("left", "right")
  local yAxis = input.axisDown("up", "down")
  local xVel, yVel = self:getLinearVelocity()
  
  self:applyForce(
    xAxis * (math.sign(xVel) ~= xAxis and self.reverseForce or self.moveForce),
    yAxis * (math.sign(yVel) ~= yAxis and self.reverseForce or self.moveForce)
  )
  
  for i = 1, 2 do
    local axis = i == 1 and "x" or "y"
    local val = self.uiPos[axis]
    self.uiPos[axis] = val + (self[axis] - val) * self.uiSpeed * dt
  end
  
  if self.missileTimer <= 0 and input.pressed("fire") then
    self.world:add(Missile:new(self.x, self.y, self.angle, self.color))
    self:animate(0.05, { scale = 0.8 }, nil, self.animate, self, 0.3, { scale = 1 })
    self:resetTimer("missile")
  end
  
  if self.world.slowmo >= self.world.maxSlowmo then
    self.maxSlowmoTimer = self.maxSlowmoTimer + dt
  else
    self.maxSlowmoTimer = 0
  end
  
  -- work out whether the slowmo meter should be faded out
  local drawSlowmo = self.maxSlowmoTimer < self.hideSlowmoTime
  if self.drawSlowmo and not drawSlowmo then self:hideSlowmo() end
  self.drawSlowmo = drawSlowmo
end

function Player:draw()
  local missileRadius = 1.25

  if self.slowmoColor[4] > 0 then
    missileRadius = 1.05
    love.graphics.setColor(self.slowmoColor)
    love.graphics.setLineWidth(6)
    drawArc(self.uiPos.x, self.uiPos.y, self.width / 1.2, 0, math.tau * (self.world.slowmo / self.world.maxSlowmo), 30)
  end
  
  if self.missileTimer < self.missileTime then
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(3)
    drawArc(self.uiPos.x, self.uiPos.y, self.width / missileRadius, 0, math.tau * (self.missileTimer / self.missileTime), 30)
  end
  
  love.graphics.setLineWidth(1)    
  self:drawImage()
end

function Player:collided(other, fixture, otherFixture, contact)
  if not self.invincible and instanceOf(Enemy, other) then
    other:die()
    self.lives = self.lives - 1
    self.world:sendMessage("player.lifeLost")
    
    if self.lives == 0 then
      self:die()
    else
      self:flashOff()
      self.fixture:setMask(1)
    end
  end
end

function Player:die()
  Shrapnel:explosion(self.x, self.y, 100, self.color, self.world)
  self.world:gameOver()
  self.world = nil
end

function Player:flashOff()
  tween(self.color, self.flashTime, { [4] = 0 }, nil, self.flashOn, self)
end

function Player:flashOn()
  local complete = self.flashOff
  self.flashes = self.flashes + 1
  
  if self.flashes > self.flashCount then
    complete = nil
    self.flashes = 0
    self.fixture:setMask()
  end
  
  tween(self.color, self.flashTime, { [4] = 255 }, nil, complete, self)
end

function Player:showSlowmo()
  if self.slowmoTween then self.slowmoTween:stop() end
  self.slowmoTween = tween(self.slowmoColor, 0.1, { [4] = 255 })
end

function Player:hideSlowmo()
  if self.slowmoTween then self.slowmoTween:stop() end
  self.slowmoTween = tween(self.slowmoColor, 0.5, { [4] = 0 })
end
