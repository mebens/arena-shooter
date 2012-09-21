EnemySpawner = class("EnemySpawner", Entity)
EnemySpawner.static.colors = {
  { 240, 240, 240 },
  { 220, 220, 220 },
  { 200, 200, 200 },
  { 180, 180, 180 },
  { 160, 160, 160 },
  { 140, 140, 140 }
}
  
function EnemySpawner:initialize(x, y)
  Entity.initialize(self, x, y)
  self.visible = false
  self.rate = math.random(2.5, 3)
  self.timer = self.rate
end

function EnemySpawner:update(dt)
  if self.world.over then return end
  
  if self.timer > 0 then
    self.timer = self.timer - dt
  else
    self.timer = self.timer + self.rate
    self.world:add(Enemy:new(self.x, self.y, EnemySpawner.colors[math.random(1, #EnemySpawner.colors)]))
  end
end
