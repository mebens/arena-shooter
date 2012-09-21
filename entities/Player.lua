Player = class("Player", PhysicalEntity):include(ColorRotator)

do
  local aimWidth = 400
  local aim = love.image.newImageData(aimWidth, 3)
  aim:mapPixel(function(x, y) return 255, 255, 255, (y == 1 and 180 or 100) * (x / aimWidth) end)
  Player.static.aimImage = love.graphics.newImage(aim)
end

function Player:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 3
  self.width = 50
  self.height = 50
  self.moveForce = 3500
  self.missileTime = 0.5
  self.missileTimer = self.missileTime
  Player.static.id = self
  
  -- live/death system
  self.lives = 3
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
  self:applyForce(input.axisDown("left", "right") * self.moveForce, input.axisDown("up", "down") * self.moveForce)
  self.angle = math.angle(self.x, self.y, mouse.x, mouse.y)
  
  for i = 1, 2 do
    local axis = i == 1 and "x" or "y"
    local val = self.uiPos[axis]
    self.uiPos[axis] = val + (self[axis] - val) * self.uiSpeed * dt
  end
  
  if self.missileTimer < self.missileTime then
    self.missileTimer = self.missileTimer + dt
  elseif input.pressed("fire") then
    self.world:add(Missile:new(self.x, self.y, self.angle, self.color))
    self.missileTimer = 0
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
  love.graphics.pushColor(self.color)
  --love.graphics.draw(Player.aimImage, self.x, self.y, self.angle - math.tau / 2, 1, 1, Player.aimImage:getWidth(), Player.aimImage:getHeight() / 2)
  love.graphics.popColor()

  if self.slowmoColor[4] > 0 then
    missileRadius = 1.05
    love.graphics.pushColor(self.slowmoColor)
    love.graphics.setLineWidth(6)
    drawArc(self.uiPos.x, self.uiPos.y, self.width / 1.2, 0, math.tau * (self.world.slowmo / self.world.maxSlowmo), 30)
    love.graphics.setLineWidth(1)
    love.graphics.popColor()
  end
  
  if self.missileTimer < self.missileTime then
    love.graphics.setLineWidth(3)
    drawArc(self.uiPos.x, self.uiPos.y, self.width / missileRadius, 0, math.tau * (self.missileTimer / self.missileTime), 30)
  end
    
  self:drawImage()
end

function Player:collided(other, fixture, otherFixture, contact)
  if other.class == Enemy then
    other:die()
    self.lives = self.lives - 1
    
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
