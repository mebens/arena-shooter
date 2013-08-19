Bullet = class("Bullet", PhysicalEntity)
Bullet.static.speed = 2000
Bullet.static.width = 12
Bullet.static.height = 4
Bullet.static.image = makeRectImage(Bullet.width, Bullet.height)

function Bullet:initialize(x, y, angle, color)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 4
  self.width = Bullet.width
  self.height = Bullet.height
  self.angle = angle
  self.damage = 4
  self.velx = Bullet.speed * math.cos(angle)
  self.vely = Bullet.speed * math.sin(angle)
  self.image = Bullet.image
  self.color = table.copy(color)
  self.color[4] = 255
end

function Bullet:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(2)
  self.fixture:setMask(2)
  self.fixture:setSensor(true)
end

function Bullet:draw()
  self:drawImage()
end

function Bullet:die()
  self.world = nil
end

function Bullet:collided(other, fixtue, otherFixture, contact)
  if instanceOf(ExplosionChunk, other) or instanceOf(Shrapnel, other) then return end
  self:die()
  
  if instanceOf(Enemy, other) then
    other:damage(self.damage)
  elseif instanceOf(Gem, other) then
    other:applyLinearImpulse(20 * math.cos(self.angle), 20 * math.sin(self.angle))
  end
end
