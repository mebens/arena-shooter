BombEnemy = class("BombEnemy", Enemy)
BombEnemy.static.explodeDist = 100
BombEnemy.static.minColor = 70
BombEnemy.static.maxColor = 240

function BombEnemy:initialize(x, y)
  Enemy.initialize(self, x, y, { BombEnemy.maxColor, 0, 0 })
  self.pulseDir = -1
end

function BombEnemy:update(dt)
  Enemy.update(self, dt)
  
  local player = self.world.player
  local dist = math.distance(self.x, self.y, player.x, player.y)
  self.color[1] = math.clamp(self.color[1] + 1 / dist * 100 * 2000 * self.pulseDir * dt, BombEnemy.minColor, BombEnemy.maxColor)

  if self.color[1] <= BombEnemy.minColor then
    self.pulseDir = 1
  elseif self.color[1] >= BombEnemy.maxColor then
    self.pulseDir = -1
  end
end
