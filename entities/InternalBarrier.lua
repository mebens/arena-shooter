InternalBarrier = class("InternalBarrier", Barrier)
InternalBarrier.all = {}

function InternalBarrier:initialize(type, x, y, width, height)
  Barrier.initialize(self, type)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

function InternalBarrier:added()
  Barrier.added(self)
  InternalBarrier.all[#InternalBarrier.all + 1] = self
  self.classIndex = #InternalBarrier.all
  
  local w = self.width
  local h = self.height
  
  if self.type == "rectangle" then
    self.shape = love.physics.newRectangleShape(0, 0, w, h)
  elseif self.type == "pentagon" then
    
  elseif self.type == "hexagon" then
    
  end
  
  local fixture = self:addShape(self.shape)
  fixture:setCategory(16)
end

function InternalBarrier:removed()
  table.remove(InternalBarrier.all, self.classIndex)
end

function InternalBarrier:draw()
  love.graphics.setColor(self.color)
  love.graphics.setLineWidth(self.padding)
  love.graphics.polygon("line", self:getWorldPoints(self.shape:getPoints()))
  love.graphics.setLineWidth(1)
end
