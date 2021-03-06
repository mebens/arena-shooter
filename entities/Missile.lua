Missile = class("Missile", PhysicalEntity)
Missile.static.speed = 1200
Missile.static.width = 30
Missile.static.height = 10
Missile.static.image = makeRectImage(Missile.width, Missile.height)
Missile.static.particleImage = makeRectImage(15, 15)

function Missile:initialize(x, y, angle, color)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 4
  self.width = Missile.width
  self.height = Missile.height
  self.angle = angle
  self.shakeDistance = 450
  self.shakeAmount = 50
  self.shakeTime = 0.09
  self.minShrapnel = 50
  self.maxShrapnel = 60
  
  self.velx = Missile.speed * math.cos(angle)
  self.vely = Missile.speed * math.sin(angle)
  self.image = Missile.image
  self.dead = false
  self.color = table.copy(color)
  self.color[4] = 255
  
  -- particle system
  local r = self.color[1]
  local g = self.color[2]
  local b = self.color[3]
  local ps = love.graphics.newParticleSystem(Missile.particleImage, 100)
  
  ps:setDirection(self.angle - math.tau / 2)
  ps:setSpread(math.tau / 4)
  ps:setSizes(1, 0.6, 0.2)
  ps:setSpeed(100, 200)
  ps:setParticleLife(0.3, 0.5)
  ps:setColors(r, g, b, 255, r, g, b, 0)
  ps:setEmissionRate(100)
  ps:start()
  self.particles = ps
end

function Missile:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setMask(2)
  self.fixture:setSensor(true)
end

function Missile:update(dt)
  self.particles:setPosition(self.x, self.y)
  self.particles:update(dt)
  
  if self.dead then
    if self.particles:count() == 0 then self.world = nil end
    return
  end
  
  PhysicalEntity.update(self, dt)
end

function Missile:draw()
  love.graphics.draw(self.particles)
  if not self.dead then self:drawImage() end
end

function Missile:collided(other, fixture, otherFixture, contact)
  if self.dead then return end
  if instanceOf(ExplosionChunk, other) or instanceOf(Shrapnel, other) then return end
  self:explode()
  
  if instanceOf(Enemy, other) then
    other:die()
  elseif instanceOf(Gem, other) then
    local angle = math.angle(self.x, self.y, other.x, other.y)
    other:applyLinearImpulse(200 * math.cos(angle), 200 * math.sin(angle))
  elseif instanceOf(Missile, other) then
    other:explode()
  end
end

function Missile:explode()
  Shrapnel:explosion(self.x, self.y, math.random(self.minShrapnel, self.maxShrapnel), self.color, self.world)
  self.dead = true
  self.particles:setEmissionRate(0)
  self.fixture:setMask(1, 2)
  
  -- camera shake
  local distScale = math.min(math.abs(math.distance(self.x, self.y, self.world.player.x, self.world.player.y)) / self.shakeDistance, 1)
  self.world.camera:shake(math.scale(distScale, 0, 1, 1, 0) * self.shakeAmount, self.shakeTime)
end
