ChargerEnemy = class("ChargerEnemy", Enemy)

function ChargerEnemy:added()
  self:setupBody()
  self:animate(Enemy.scaleTime, { scale = 1 })
  
  local w = Enemy.width
  local h = Enemy.height
  self.fixture = self:addShape(love.physics.newPolygonShape(-w / 2, -h / 2, w / 2, -h / 2, -w / 2, h / 2))
end

function ChargerEnemy:draw()
  love.graphics.pushColor(self.color)
  love.graphics.polygon("fill", self:getWorldPoints(self.fixture:getShape():getPoints()))
  love.graphics.popColor()
end
