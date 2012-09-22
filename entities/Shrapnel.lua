Shrapnel = class("Shrapnel", PhysicalEntity)
Shrapnel.static.width = 7
Shrapnel.static.height = 7
Shrapnel.static.minForce = 40
Shrapnel.static.maxForce = 50
Shrapnel.static.image = makeRectImage(Shrapnel.width, Shrapnel.height)

function Shrapnel.static:explosion(x, y, amount, color, world)
  for i = 1, amount do
    (world or ammo.world):add(Shrapnel:new(x, y, math.tau * math.random(), color))
  end
end

function Shrapnel:initialize(x, y, angle, color)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 5
  self.width = Shrapnel.width
  self.height = Shrapnel.height
  self.angle = angle
  self.color = table.copy(color)
  self.color[4] = 230
  self.image = Shrapnel.image
end

function Shrapnel:added()
  self:setupBody()
  self:setLinearDamping(2.5)
  self.tween = tween(self.color, "0.4:0.6", { [4] = 0 }, nil, self.die, self)
  
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setGroupIndex(-2)
  self.fixture:setRestitution(0.9)
  
  local force = math.random(Shrapnel.minForce, Shrapnel.maxForce)
  self:applyLinearImpulse(math.cos(self.angle) * force, math.sin(self.angle) * force)
end

function Shrapnel:draw()
  self:drawImage()
end

function Shrapnel:collided(other, fixture, otherFixture, contact)
  if other.class == Enemy and math.distance(0, 0, self.velx, self.vely) > 1200 then
    other:die()
    self:die()
    self.tween:stop()
  end
end

function Shrapnel:die()
  self.world = nil
end
