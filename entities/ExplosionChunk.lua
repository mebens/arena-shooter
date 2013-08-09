ExplosionChunk = class("ExplosionChunk", PhysicalEntity)
ExplosionChunk.static.width = 7
ExplosionChunk.static.height = 7
ExplosionChunk.static.count = 0
ExplosionChunk.static.maxCount = 100
ExplosionChunk.static.image = makeRectImage(ExplosionChunk.width, ExplosionChunk.height)

function ExplosionChunk:initialize(x, y, angle, color, minForce, maxForce)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 6
  self.width = ExplosionChunk.width
  self.height = ExplosionChunk.height
  self.angle = angle
  self.color = color
  self.color[4] = 230
  self.minForce = minForce or 6
  self.maxForce = maxForce or 10
  self.image = ExplosionChunk.image
  ExplosionChunk.count = ExplosionChunk.count + 1
end

function ExplosionChunk:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setRestitution(0.75)
  tween(self.color, "0.5:1", { [4] = 0 }, nil, self.die, self)
  
  local force = math.random(self.minForce, self.maxForce)
  self:applyLinearImpulse(math.cos(self.angle) * force, math.sin(self.angle) * force)
end

function ExplosionChunk:draw()
  self:drawImage()
end

function ExplosionChunk:die()
  self.world = nil
  ExplosionChunk.count = ExplosionChunk.count - 1
end
