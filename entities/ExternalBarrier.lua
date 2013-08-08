ExternalBarrier = class("ExternalBarrier", Barrier)

function ExternalBarrier:initialize(type)
  Barrier.initialize(self, type)
  self.sides = {}
  self.shapePadding = 50
end

function ExternalBarrier:added()
  Barrier.added(self)
  local w = self.world.width
  local h = self.world.height
  local sp = self.shapePadding
  local vp = self.padding
  
  if self.type == "rectangle" then
    self.sides[1] = self:addShape(love.physics.newRectangleShape(w / 2, (vp - sp) / 2, w + sp * 2, sp))
    self.sides[2] = self:addShape(love.physics.newRectangleShape(w / 2, h + (sp - vp) / 2, w + sp * 2, sp))
    self.sides[3] = self:addShape(love.physics.newRectangleShape((vp - sp) / 2, h / 2, sp, h + sp * 2))
    self.sides[4] = self:addShape(love.physics.newRectangleShape(w + (sp - vp) / 2, h / 2, sp, h + sp * 2))
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
