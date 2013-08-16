Player = class("Player", PhysicalEntity)
Player:include(ColorRotator)
Player.static.size = 70
Player.static.maxLives = 3
Player.static.weapons = {}
Player.weapons.index = {}

local function missileFunc(self)
  self.world:add(Missile:new(self.x, self.y, self.angle, self.color))
  self:animate(0.05, { scale = 0.8 }, nil, self.animate, self, 0.3, { scale = 1 })
end

Player.weapons[#Player.weapons + 1] = {
  name = "laser",
  sides = 3,
  sustained = true,
  time = 0.6,
  disableTime = 1,
  rechargeRate = 0.5,
  
  fire = function(self)
    self.laserBeamLength = math.distance(0, 0, self.world.width, self.world.height) * 2
    
    self.world:rayCast(
      self.x,
      self.y,
      self.x + self.laserBeamLength * math.cos(self.angle),
      self.y + self.laserBeamLength * math.sin(self.angle),
      
      function(fixture, x, y, xn, yn, fraction)
        local e = fixture:getUserData()
        
        if instanceOf(Enemy, e) then
          delay(0, function() e:die() end) -- for some reason a delay is necessary for the enemies to be removed properly
        elseif instanceOf(Barrier, e) then
          self.laserBeamLength = math.distance(self.x, self.y, x, y)
          return 0
        end
        
        return 1
      end
    )
  end,
  
  draw = function(self)
    if self.firing then
      love.graphics.setColor(self.color)
      love.graphics.setLineWidth(3)
      
      love.graphics.line(
        self.x,
        self.y,
        self.x + self.laserBeamLength * math.cos(self.angle),
        self.y + self.laserBeamLength * math.sin(self.angle)
      )
      
      love.graphics.setLineWidth(1)
    end
  end
}

Player.weapons[#Player.weapons + 1] = {
  name = "missile",
  sides = 4,
  sustained = false,
  time = 0.3,
  fire = missileFunc
}

Player.weapons[#Player.weapons + 1] = {
  name = "minigun",
  sides = 5,
  sustained = false,
  time = 0.6,
  fire = missileFunc
}

Player.weapons[#Player.weapons + 1] = {
  name = "detonated",
  sides = 6,
  sustained = false,
  time = 1,
  fire = function(self)
    self.world:add(DetonatedMissile:new(self.x, self.y, self.angle, self.color))
    self:animate(0.05, { scale = 0.8 }, nil, self.animate, self, 0.3, { scale = 1 })
  end
}

for i, v in ipairs(Player.weapons) do
  Player.weapons.index[v.name] = i
  v.points = getRegularPolygon(v.sides, Player.size / 2)
  
  -- generate image
  local canvas = love.graphics.newCanvas(Player.size, Player.size)
  love.graphics.setCanvas(canvas)
  love.graphics.setColor(255, 255, 255)
  love.graphics.push()
  love.graphics.translate(Player.size / 2, Player.size / 2) -- the polygon coordinates are centre-based
  love.graphics.polygon("fill", unpack(v.points))
  love.graphics.pop()
  love.graphics.setCanvas()
  v.image = love.graphics.newImage(canvas:getImageData())
end

local function getMidpoint(p1, points)
  local p2 = (p1 + 1) % #points + 1 -- second index
  local x1, y1 = points[p1], points[p1 + 1]
  local x2, y2 = points[p2], points[p2 + 1]
  local angle = math.angle(x1, y1, x2, y2)
  local dist = math.distance(x1, y1, x2, y2) / 2
  return x1 + dist * math.cos(angle), y1 + dist * math.sin(angle)
end

function Player:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 2
  self.width = Player.size
  self.height = Player.size
  self.scale = 1
  self.moveForce = 3500
  self.reverseForce = 4500
  
  -- weapons/shapes
  self.morphTime = 0.25
  self.morphing = false
  self.weaponTimer = 0
  
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
  self:advanceColor()
  self.color[4] = 255
  self:changeWeapon()
  self.world:addListener("gem.collected", self.changeWeapon, self)
end

function Player:update(dt)
  PhysicalEntity.update(self, dt)
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
  
  if self.weapon.sustained then
    -- sustained fire, heat based
    
    if self.weaponDisableTimer > 0 then
      self.weaponDisableTimer = self.weaponDisableTimer - dt
    elseif input.down("fire") then
      self.weaponTimer = self.weaponTimer + dt
      
      if self.weaponTimer > self.weapon.time then
        self.weaponDisableTimer = self.weapon.disableTime
        self.firing = false
      else
        self.firing = true
        self.weapon.fire(self)
      end
    elseif self.weaponTimer > 0 then
      self.firing = false
      self.weaponTimer = self.weaponTimer - dt * self.weapon.rechargeRate
    end
  else
    -- single shot
    if self.weaponTimer > 0 then
      self.weaponTimer = self.weaponTimer - dt
    elseif input.pressed("fire") then
      self.weaponTimer = self.weaponTimer + self.weapon.time
      self.weapon.fire(self)
    end
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
  
  -- temporary weapon switching
  if key.pressed["1"] then
    self:changeWeapon(1)
  elseif key.pressed["2"] then
    self:changeWeapon(2)
  elseif key.pressed["3"] then
    self:changeWeapon(3)
  elseif key.pressed["4"] then
    self:changeWeapon(4)
  end
end

function Player:draw()
  if self.weapon.draw then self.weapon.draw(self) end
  
  local weaponRadius = 1.25
  local uiWidth = self.width * .75
  
  if self.slowmoColor[4] > 0 then
    weaponRadius = 1.05
    love.graphics.setColor(self.slowmoColor)
    love.graphics.setLineWidth(6)
    drawArc(self.uiPos.x, self.uiPos.y, uiWidth / 1.2, 0, math.tau * (self.world.slowmo / self.world.maxSlowmo), 30)
  end
  
  love.graphics.setLineWidth(3)
  
  if self.weapon.sustained and self.weaponTimer > 0 then
    local ratio = math.min(self.weaponTimer / self.weapon.time, 1) -- make sure it's capped at 1
    
    if ratio > 0.75 then
      local gb = math.scale(ratio, 0.75, 1, 255, 0)
      love.graphics.setColor(255, gb, gb)
    else
      love.graphics.setColor(255, 255, 255)
    end
    
    drawArc(self.uiPos.x, self.uiPos.y, uiWidth / weaponRadius, 0, math.tau * ratio, 30)
  elseif self.weaponTimer < self.weapon.time then
    love.graphics.setColor(255, 255, 255)
    drawArc(self.uiPos.x, self.uiPos.y, uiWidth / weaponRadius, 0, math.tau * (self.weaponTimer / self.weapon.time), 30)
  end
  
  love.graphics.setLineWidth(1)    
  love.graphics.setColor(self.color)
  
  if self.morphing then
    local points = {}
    
    -- translate and rotate the local shape points
    for i = 1, #self.points, 2 do
      local x, y = self.points[i], self.points[i + 1]
      local dist = math.distance(0, 0, x, y)
      local angle = math.angle(0, 0, x, y) + self.angle
      points[i] = self.x + dist * math.cos(angle)
      points[i + 1] = self.y + dist * math.sin(angle)
    end
    
    love.graphics.polygon("fill", unpack(points))
  else
    self:drawImage()
  end
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

function Player:changeWeapon(weapon)
  if type(weapon) == "string" then
    weapon = Player.weapons[Player.weapons.index[weapon]]
  elseif weapon then
    weapon = Player.weapons[weapon]
  elseif self.weapon then
    -- make sure we don't pick the current weapon
    local weapons = {}
    
    for k, v in pairs(Player.weapons.index) do
      if k ~= self.weapon.name then weapons[#weapons + 1] = v end
    end
    
    weapon = Player.weapons[weapons[math.random(1, #weapons)]]
  else
    weapon = Player.weapons[math.random(1, #Player.weapons)]
  end
  
  if self.points then
    self.points = table.copy(self.weapon.points) -- make sure the points are what they should be
    local diff = weapon.sides - self.weapon.sides
    local points = self.points
    
    -- this can't go further than the halving/doubling of points
    if diff < 0 then
      local tweenTo = table.copy(weapon.points)
      local indicies = {}
      
      for i = 0, math.min(math.abs(diff), self.weapon.sides / 2) - 1 do
        local index = i * 2 + 1
        local insert = index + i * 2 -- to compensate for the added points
        local x, y = getMidpoint(index, weapon.points)
        table.insert(tweenTo, insert + 2, x)
        table.insert(tweenTo, insert + 3, y)
        table.insert(indicies, insert)
      end
      
      tween(points, self.morphTime, tweenTo, nil, self.morphComplete, self)
    else
      for i = 0, math.min(diff, self.weapon.sides) - 1 do
        local index = i * 4 + 1 
        local x, y = getMidpoint(index, points)
        table.insert(points, index + 2, x)
        table.insert(points, index + 3, y)
      end
      
      tween(points, self.morphTime, weapon.points, nil, self.morphComplete, self)
    end
    
    self.morphing = true
  else
    self.points = table.copy(weapon.points)
  end
  
  self.image = weapon.image
  self.weapon = weapon
  self.weaponTimer = 0
  self.weaponDisableTimer = 0
  self:constructShape(weapon.points)
end

function Player:constructShape(points)
  if self.fixture then
    self.fixture:destroy()
    self.fixture = nil
  end
  
  delay(0, function()
    self.fixture = self:addShape(love.physics.newPolygonShape(unpack(points)))
    self.fixture:setCategory(2)
    self:setMass(1)
    self:setLinearDamping(5)
  end)
end

function Player:morphComplete()
  self.morphing = false
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
    
    -- player might be morphing shape (which means the fixture might not be there)
    if self.fixture then self.fixture:setMask() end
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
