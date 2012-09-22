Enemy = class("Enemy", PhysicalEntity)
Enemy.static.width = 30
Enemy.static.height = 30
Enemy.static.moveForce = 100
Enemy.static.image = makeRectImage(Enemy.width, Enemy.height)

function Enemy:initialize(x, y, color)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 3
  self.width = Enemy.width
  self.height = Enemy.height
  self.image = Enemy.image
  self.color = table.copy(color)
end

function Enemy:added()
  self:setupBody()
  self:addShape(love.physics.newRectangleShape(self.width, self.height))
end

function Enemy:update(dt)
  PhysicalEntity.update(self, dt)
  self.angle = math.angle(self.x, self.y, self.world.player.x, self.world.player.y)
  self:applyForce(math.cos(self.angle) * Enemy.moveForce, math.sin(self.angle) * Enemy.moveForce)
end

function Enemy:draw()
  self:drawImage()
end

function Enemy:die()
  if self.dead then return end
  self.dead = true
  
  for i = 1, 10 do
    if EnemyChunk.count < EnemyChunk.maxCount then
      self.world:add(EnemyChunk:new(self.x, self.y, math.random() * math.tau, self.color))
    else
      break
    end
  end
  
  self.world:enemyKilled(self)
  self.world = nil
end
