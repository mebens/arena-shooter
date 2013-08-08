ExternalBarrier = class("ExternalBarrier", Barrier)

function ExternalBarrier:initialize(type)
  Barrier.initialize(self, type)
  self.sides = {}
end

function ExternalBarrier:added()
  Barrier.added(self)
  local w = self.world.width
  local h = self.world.height
  local p = self.padding
  
  if self.type == "rectangle" then
    self.sides[1] = self:addShape(love.physics.newEdgeShape(p, p, w - p, p))
    self.sides[2] = self:addShape(love.physics.newEdgeShape(w - p, p, w - p, h - p))
    self.sides[3] = self:addShape(love.physics.newEdgeShape(p, h - p, w - p, h - p))
    self.sides[4] = self:addShape(love.physics.newEdgeShape(p, p, p, h - p))
    
    -- old rect and shape padding code
    -- self.top = self:addShape(love.physics.newRectangleShape(w / 2, (vp - p) / 2, w + p * 2, p))
    -- self.bottom = self:addShape(love.physics.newRectangleShape(w / 2, h + (p - vp) / 2, w + p * 2, p))
    -- self.left = self:addShape(love.physics.newRectangleShape((vp - p) / 2, h / 2, p, h + p * 2))
    -- self.right = self:addShape(love.physics.newRectangleShape(w + (p - vp) / 2, h / 2, p, h + p * 2))
  elseif self.type == "pentagon" then
    
  elseif self.type == "hexagon" then
    
  end
  
  for _, v in ipairs(self.sides) do v:setCategory(16) end
end

function ExternalBarrier:draw()
  local w = self.world.width
  local h = self.world.height
  local p = self.padding
  
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", 0, 0, w, p) -- top
  love.graphics.rectangle("fill", 0, h - p, w, p) -- bottom
  love.graphics.rectangle("fill", 0, p, p, h - p * 2) -- left
  love.graphics.rectangle("fill", w - p, p, p, h - p * 2) -- right
end
