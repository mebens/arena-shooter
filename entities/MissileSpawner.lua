MissileSpawner = class("MissileSpawner", Entity):include(ColorRotator)

function MissileSpawner:initialize(x, y, angle)
  Entity.initialize(self, x, y)
  self.angle = angle
  self.baseRate = 4
  self.timer = self.baseRate + math.random() * 4
  
  self.colors = {
    { 250, 0, 0 },
    { 250, 100, 0 },
    { 250, 0, 0 },
    { 250, 250, 0 }
  }
  
  self:advanceColor()
end

function MissileSpawner:update(dt)
  if self.timer > 0 then
    self.timer = self.timer - dt
  else
    self.timer = self.timer + self.baseRate + math.random() * 4
    self.world:add(Missile:new(self.x, self.y, self.angle, self.color))
  end
end
