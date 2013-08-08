EnemySpawner = class("EnemySpawner", Entity)
EnemySpawner.static.colors = {
  { 230, 230, 230 },
  { 210, 210, 210 },
  { 190, 190, 190 }
}
  
function EnemySpawner:initialize(x, y, baseRate)
  Entity.initialize(self, x, y)
  self.visible = false
  self.baseRate = baseRate or 2
  self.timer = 0
end

function EnemySpawner:update(dt)
  if self.world.over then return end
  
  if self.timer > 0 then
    self.timer = self.timer - dt
  else
    self.timer = self.timer + self.baseRate + math.random()
    self.world:add(Enemy:new(self.x, self.y, EnemySpawner.colors[math.random(1, #EnemySpawner.colors)]))
  end
end
