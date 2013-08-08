Background = class("Background", Entity):include(ColorRotator)
Background.static.boxWidth = 100
Background.static.boxHeight = 100
Background.static.boxPadding = 5

function Background:initialize()
  Entity.initialize(self)
  self.layer = 6
  self.colorTime = 3
  
  self.colors = {
    { 0, 127, 255 },
    { 250, 7, 0 },
    { 207, 39, 250 },
    { 0, 216, 28 }
  }
end

function Background:added()
  self:resize()
  self:advanceColor()
  self.color[4] = 150
end

function Background:draw()
  love.graphics.setColor(self.color)
  love.graphics.draw(self.canvas, self.x, self.y)
end

function Background:resize()
  local bw, bh, bp = Background.boxWidth, Background.boxWidth, Background.boxPadding
  local w, h = self.world.width, self.world.height
  
  -- subtractive layer
  local subLayer = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(subLayer)
  love.graphics.storeColor()
  
  -- initial blank slate
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0, 0, 0)
  
  -- external barrier
  if self.world.barrier.numSides == 4 then
    love.graphics.rectangle("fill", 0, 0, w, h)
  else
    love.graphics.polygon("fill", unpack(self.world.barrier.points))
  end
  
  -- internal barriers
  love.graphics.setColor(255, 255, 255)
  
  for _, v in pairs(self.world.internalBarriers) do
    love.graphics.polygon("fill", v:getWorldPoints(v.shape:getPoints()))
  end
  
  -- main background canvas
  self.canvas = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(self.canvas)
  love.graphics.setColor(255, 255, 255)
  
  for x = 0, math.ceil(self.world.width / (bw + bp)) do
    for y = 0, math.ceil(self.world.height / (bh + bp)) do
      love.graphics.rectangle("fill", x * (bw + bp), y * (bh + bp), bw, bh)
    end
  end
  
  love.graphics.setBlendMode("subtractive")
  love.graphics.draw(subLayer, 0, 0)
  love.graphics.setBlendMode("alpha")
  love.graphics.resetColor()
  love.graphics.setCanvas()
end
