Barrier = class("Barrier", PhysicalEntity)

function Barrier:initialize()
  PhysicalEntity.initialize(self)
  self.layer = 1
  self.padding = 5
  self.color = { 240, 240, 240, 220 }
end

function Barrier:added()
  self:setupBody()
  self:alphaDown()

  local w = self.world.width
  local h = self.world.height
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
  love.graphics.rectangle("fill", 0, 0, self.world.width, self.padding) -- top
  love.graphics.rectangle("fill", 0, self.world.height - self.padding, self.world.width, self.padding) -- bottom
  love.graphics.rectangle("fill", 0, 0, self.padding, self.world.height) -- left
  love.graphics.rectangle("fill", self.world.width - self.padding, 0, self.padding, self.world.height) -- right
  love.graphics.popColor()
end

function Barrier:alphaDown()
  tween(self.color, 1, { [4] = 150 }, nil, self.alphaUp, self)
end

function Barrier:alphaUp()
  tween(self.color, 1, { [4] = 220 }, nil, self.alphaDown, self)
end
