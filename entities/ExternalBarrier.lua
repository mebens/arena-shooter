ExternalBarrier = class("ExternalBarrier", Barrier)

function ExternalBarrier:initialize(numSides)
  Barrier.initialize(self, numSides)
  self.sides = {}
  self.shapePadding = 50
end

function ExternalBarrier:added()
  Barrier.added(self)
  local w = self.world.width
  local h = self.world.height
  local sp = self.shapePadding
  local vp = self.padding
  
  if self.numSides == 4 then
    self.sides[1] = self:addShape(love.physics.newRectangleShape(w / 2, (vp - sp) / 2, w + sp * 2, sp))
    self.sides[2] = self:addShape(love.physics.newRectangleShape(w / 2, h + (sp - vp) / 2, w + sp * 2, sp))
    self.sides[3] = self:addShape(love.physics.newRectangleShape((vp - sp) / 2, h / 2, sp, h + sp * 2))
    self.sides[4] = self:addShape(love.physics.newRectangleShape(w + (sp - vp) / 2, h / 2, sp, h + sp * 2))
  else
    local n = self.numSides
    self.points = {}
    w = w / 2
    for i = 0, n - 1 do
      local j = (i + 1) % n
      vp = vp / 2
      
      -- angles for the two points and the edge
      local iangle = math.tau * (i / n)
      local jangle = math.tau * (j / n)
      local normAngle = (iangle + (j == 0 and math.tau or jangle)) / 2
      
      -- edges coordinates
      local x1 = w + (w - vp) * math.cos(iangle)
      local y1 = w + (w - vp) * math.sin(iangle)
      local x2 = w + (w - vp) * math.cos(jangle)
      local y2 = w + (w - vp) * math.sin(jangle)
      
      -- create the shape, with extended sides
      self.sides[i] = self:addShape(love.physics.newPolygonShape(
        x1, y1,
        x1 + sp * math.cos(normAngle),
        y1 + sp * math.sin(normAngle),
        x2 + sp * math.cos(normAngle),
        y2 + sp * math.sin(normAngle),
        x2, y2
      ))
      
      -- enter the points in the table
      self.points[i * 2 + 1] = x1
      self.points[i * 2 + 2] = y1
    end
  end
  
  for _, v in ipairs(self.sides) do v:setCategory(16) end
end

function ExternalBarrier:draw()
  local w = self.world.width
  local h = self.world.height
  local p = self.padding
  
  love.graphics.setColor(self.color)
  
  if self.numSides == 4 then
    love.graphics.rectangle("fill", 0, 0, w, p) -- top
    love.graphics.rectangle("fill", 0, h - p, w, p) -- bottom
    love.graphics.rectangle("fill", 0, p, p, h - p * 2) -- left
    love.graphics.rectangle("fill", w - p, p, p, h - p * 2) -- right
  else
    love.graphics.setLineWidth(self.padding)
    love.graphics.polygon("line", unpack(self.points))
    love.graphics.setLineWidth(1)
  end
end
