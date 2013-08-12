InternalBarrier = class("InternalBarrier", Barrier)

function InternalBarrier:initialize(numSides, x, y, width, height)
  Barrier.initialize(self, numSides)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

function InternalBarrier:added()
  Barrier.added(self)
  
  if self.numSides == 4 then
    self.shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
  else
    self.shape = love.physics.newPolygonShape(unpack(getRegularPolygon(self.numSides, self.width / 2)))
  end
  
  self.fixture = self:addShape(self.shape)
  self.fixture:setCategory(16)
end

function InternalBarrier:draw()
  love.graphics.setColor(self.color)
  love.graphics.setLineWidth(self.padding)
  love.graphics.polygon("line", self:getWorldPoints(self.shape:getPoints()))
  love.graphics.setLineWidth(1)
end
