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
  local w = self.width
  local h = self.height
  
  if self.numSides == 4 then
    self.shape = love.physics.newRectangleShape(0, 0, w, h)
  else
    local points = {}
    local n = self.numSides
    
    for i = 0, n - 1 do
      points[#points + 1] = w * math.cos(math.tau * (i / n))
      points[#points + 1] = w * math.sin(math.tau * (i / n))
    end
    
    self.shape = love.physics.newPolygonShape(unpack(points))
  end
  
  local fixture = self:addShape(self.shape)
  fixture:setCategory(16)
end

function InternalBarrier:draw()
  love.graphics.setColor(self.color)
  love.graphics.setLineWidth(self.padding)
  love.graphics.polygon("line", self:getWorldPoints(self.shape:getPoints()))
  love.graphics.setLineWidth(1)
end
