Barrier = class("Barrier", PhysicalEntity)

function Barrier:initialize()
  PhysicalEntity.initialize(self)
  self.layer = 1
  self.visualPadding = 5
  self.shapePadding = 50
  self.color = { 240, 240, 240, 240 }
end

function Barrier:added()
  self:setupBody()
  self:alphaDown()

  local w = self.world.width
  local h = self.world.height
  local p = self.shapePadding
  local vp = self.visualPadding
  
  self.top = self:addShape(love.physics.newRectangleShape(w / 2, (vp - p) / 2, w + p * 2, p))
  self.bottom = self:addShape(love.physics.newRectangleShape(w / 2, h + (p - vp) / 2, w + p * 2, p))
  self.left = self:addShape(love.physics.newRectangleShape((vp - p) / 2, h / 2, p, h + p * 2))
  self.right = self:addShape(love.physics.newRectangleShape(w + (p - vp) / 2, h / 2, p, h + p * 2))
  for _, v in pairs{"top", "bottom", "left", "right"} do self[v]:setCategory(16) end
end

function Barrier:draw()
  if self.visualPadding < 1 then return end
  local w = self.world.width
  local h = self.world.height
  local p = self.visualPadding
  
  love.graphics.setColor(self.color)
  love.graphics.rectangle("fill", 0, 0, w, p) -- top
  love.graphics.rectangle("fill", 0, h - p, w, p) -- bottom
  love.graphics.rectangle("fill", 0, p, p, h - p * 2) -- left
  love.graphics.rectangle("fill", w - p, p, p, h - p * 2) -- right
end

function Barrier:alphaDown()
  tween(self.color, 1, { [4] = 180 }, nil, self.alphaUp, self)
end

function Barrier:alphaUp()
  tween(self.color, 1, { [4] = 240 }, nil, self.alphaDown, self)
end
