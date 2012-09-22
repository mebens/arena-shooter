EnemyChunk = class("EnemyChunk", PhysicalEntity)
EnemyChunk.static.width = 7
EnemyChunk.static.height = 7
EnemyChunk.static.minForce = 6
EnemyChunk.static.maxForce = 10
EnemyChunk.static.count = 0
EnemyChunk.static.maxCount = 75
EnemyChunk.static.image = makeRectImage(EnemyChunk.width, EnemyChunk.height)

function EnemyChunk:initialize(x, y, angle, color)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 5
  self.width = EnemyChunk.width
  self.height = EnemyChunk.height
  self.angle = angle
  self.color = color
  self.color[4] = 255
  self.image = EnemyChunk.image
  EnemyChunk.count = EnemyChunk.count + 1
end

function EnemyChunk:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setRestitution(0.75)
  tween(self.color, "0.5:1", { [4] = 0 }, nil, self.die, self)
  
  local force = math.random(EnemyChunk.minForce, EnemyChunk.maxForce)
  self:applyLinearImpulse(math.cos(self.angle) * force, math.sin(self.angle) * force)
end

function EnemyChunk:draw()
  self:drawImage()
end

function EnemyChunk:die()
  self.world = nil
  EnemyChunk.count = EnemyChunk.count - 1
end
