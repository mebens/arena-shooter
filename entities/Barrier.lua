Barrier = class("Barrier", PhysicalEntity)

function Barrier:initialize()
  PhysicalEntity.initialize(self)
  self.layer = 2
  self.padding = 0
  self.color = { 240, 240, 240 }
end

function Barrier:added()
  self:setupBody()

  local w = love.graphics.width
  local h = love.graphics.height
  local p = self.padding
  
  self.top = self:addShape(love.physics.newEdgeShape(p, p, w - p, p))
  self.bottom = self:addShape(love.physics.newEdgeShape(p, h - p, w - p, h - p))
  self.left = self:addShape(love.physics.newEdgeShape(p, p, p, h - p))
  self.right = self:addShape(love.physics.newEdgeShape(w - p, p, w - p, h - p))
  for _, v in pairs{"top", "bottom", "left", "right"} do self[v]:setCategory(16) end
end

function Barrier:draw()
  if self.padding < 1 then return end
  love.graphics.pushColor(self.color)
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, self.padding) -- top
  love.graphics.rectangle("fill", 0, love.graphics.height - self.padding, love.graphics.width, self.padding) -- bottom
  love.graphics.rectangle("fill", 0, 0, self.padding, love.graphics.height) -- left
  love.graphics.rectangle("fill", love.graphics.width - self.padding, 0, self.padding, love.graphics.height) -- right
  love.graphics.popColor()
end
