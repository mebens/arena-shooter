Gem = class("Gem", PhysicalEntity)
Gem.static.size = 15

do
  local canvas = love.graphics.newCanvas(Gem.size * 2, Gem.size * 2)
  local size
  love.graphics.setCanvas(canvas)
  love.graphics.storeColor()
  
  -- glow
  for i = 0, Gem.size - 1 do
    size = Gem.size * 2 - i * 2
    love.graphics.setColor(255, 255, 255, 30 / Gem.size)
    love.graphics.rectangle("fill", i, i, size, size)
  end
  
  -- main rectangle
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", Gem.size / 2, Gem.size / 2, Gem.size, Gem.size)
  love.graphics.resetColor()
  love.graphics.setCanvas()
  Gem.static.image = love.graphics.newImage(canvas:getImageData())
end

function Gem:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "static")
  self.layer = 5
  self.width = Gem.size
  self.height = Gem.size
  self.scale = 1
  self.rotateSpeed = math.tau / 2
  self.dead = false
  self.image = Gem.image
  self.color = { 255, 230, 80 }
end

function Gem:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setSensor(true)
end

function Gem:update(dt)
  PhysicalEntity.update(self, dt)
  self.angle = (self.angle + self.rotateSpeed * dt) % math.tau
end

function Gem:draw()
  self:drawImage()
end

function Gem:die()
  if self.dead then return end
  self.dead = true
  
  self:animate(.25, { scale = 2 }, ease.quadOut, function()
    for i = 1, 6 do
      if ExplosionChunk.count < ExplosionChunk.maxCount then
        self.world:add(ExplosionChunk:new(self.x, self.y, math.random() * math.tau, self.color, 3, 5))
      else
        break
      end
    end
    
    self.world:sendMessage("gem.collected")
    self.world = nil 
  end)
end

function Gem:collided(other, fixture, otherFixture, contact)
  if instanceOf(Player, other) then self:die() end
end
