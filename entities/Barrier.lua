Barrier = class("Barrier", PhysicalEntity)

function Barrier:initialize(type)
  PhysicalEntity.initialize(self)
  self.layer = 1
  self.padding = 5
  self.type = type or "rectangle"
  self.color = { 240, 240, 240, 240 }
end

function Barrier:added()
  self:setupBody()
  self:alphaDown()
end

function Barrier:alphaDown()
  tween(self.color, 1, { [4] = 180 }, nil, self.alphaUp, self)
end

function Barrier:alphaUp()
  tween(self.color, 1, { [4] = 240 }, nil, self.alphaDown, self)
end
