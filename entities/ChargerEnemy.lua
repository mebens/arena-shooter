ChargerEnemy = class("ChargerEnemy", Enemy)
ChargerEnemy.static.length = 35

do
  local length = ChargerEnemy.length
  local angle = math.tau / 6 -- 180 deg / 3
  local height = math.round(math.sin(angle) * length)
  local canvas = love.graphics.newCanvas(length, height)
  ChargerEnemy.static.points = { length, 0, 0, 0, math.cos(angle) * length, height }
  love.graphics.setCanvas(canvas)
  love.graphics.triangle("fill", unpack(ChargerEnemy.points))
  love.graphics.setCanvas()
  ChargerEnemy.static.image = love.graphics.newImage(canvas:getImageData())
end

function ChargerEnemy:initialize(x, y, color)
  Enemy.initialize(self, x, y, color)
  self.image = ChargerEnemy.image
end

function ChargerEnemy:added()
  self:setupBody()
  self:animate(Enemy.scaleTime, { scale = 1 })
  
  local w = Enemy.width
  local h = Enemy.height
  self.fixture = self:addShape(love.physics.newPolygonShape(unpack(ChargerEnemy.points)))
end

function ChargerEnemy:update(dt)
  if math.distance(self.x, self.y, self.world.player.x, self.world.player.y) < 200 then
    self.speed = Enemy.moveForce * 2
  else
    self.speed = Enemy.moveForce
  end
  
  Enemy.update(self, dt)
end
