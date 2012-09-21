ColorRotator = {}

function ColorRotator:advanceColor()
  if not self.color then self.color = table.copy(self.colors[1]) end
  self.colorIndex = (self.colorIndex or 0) % #self.colors + 1
  tween(self.color, self.colorTime or 1, self.colors[self.colorIndex], nil, self.advanceColor, self)
end
