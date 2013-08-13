DetonatedMissile = class("DetonatedMissile", Missile)
DetonatedMissile.static.speed = 700

function DetonatedMissile:initialize(x, y, angle, color)
  Missile.initialize(self, x, y, angle, color)
  self.shakeAmount = 45
  self.minShrapnel = 50 -- slightly weaker
  self.maxShrapnel = 55
  self.velx = DetonatedMissile.speed * math.cos(angle)
  self.vely = DetonatedMissile.speed * math.sin(angle)
end

function DetonatedMissile:update(dt)
  Missile.update(self, dt)
  if self.dead then return end
  if input.pressed("detonate") then self:explode() end
end
