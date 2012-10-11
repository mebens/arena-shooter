Missile = class("Missile", PhysicalEntity)
Missile.static.speed = 1200
Missile.static.shakeDistance = 450
Missile.static.shakeAmount = 50
Missile.static.shakeTime = 0.09
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
  self.velx = Missile.speed * math.cos(angle)
  self.vely = Missile.speed * math.sin(angle)
  self.image = Missile.image
  self.color = table.copy(color)
  
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
  self.fixture = self:addShape(love.physics.newRectangleShape(Missile.width, Missile.height))
  self.fixture:setMask(2)
  self.fixture:setSensor(true)
end

function Missile:update(dt)
  PhysicalEntity.update(self, dt)
  self.particles:setPosition(self.x, self.y)
  self.particles:update(dt)
end

function Missile:draw()
  love.graphics.draw(self.particles)
  self:drawImage()
end

function Missile:collided(other, fixture, otherFixture, contact)
  if instanceOf(EnemyChunk, other) then return end
  if not instanceOf(Shrapnel, other) or other:checkVelocity() then self:explode() end -- only explode for shrapnel if it has fatal velocity
  
  if instanceOf(Enemy, other) then
    other:die()
  elseif instanceOf(Missile, other) then
    other:explode()
  end
end

function Missile:explode()
  Shrapnel:explosion(self.x, self.y, math.random(40, 50), self.color, self.world)
  local distScale = math.min(math.abs(math.distance(self.x, self.y, self.world.player.x, self.world.player.y)) / Missile.shakeDistance, 1)
  self.world.camera:shake(math.scale(distScale, 0, 1, 1, 0) * Missile.shakeAmount, Missile.shakeTime)
  self.world = nil
end
