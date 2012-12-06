Enemy = class("Enemy", PhysicalEntity)
Enemy.static.width = 30
Enemy.static.height = 30
Enemy.static.moveForce = 100
Enemy.static.scaleTime = 0.3
Enemy.static.image = makeRectImage(Enemy.width, Enemy.height)

function Enemy:initialize(x, y, color)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 3
  self.width = Enemy.width
  self.height = Enemy.height
  self.speed = Enemy.moveForce
  self.image = Enemy.image
  self.color = table.copy(color)
  self.scale = 0
end

function Enemy:added()
  self:setupBody()
  self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self:animate(Enemy.scaleTime, { scale = 1 })
end

function Enemy:update(dt)
  PhysicalEntity.update(self, dt)
  self.angle = math.angle(self.x, self.y, self.world.player.x, self.world.player.y)
  
  if self.scale == 1 then
    self:applyForce(math.cos(self.angle) * self.speed, math.sin(self.angle) * self.speed)
  end
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

  --Shrapnel:explosion(self.x, self.y, math.random(20, 30), self.color, self.world)  
  self.world:sendMessage("enemy.killed")
  self.world = nil
end
