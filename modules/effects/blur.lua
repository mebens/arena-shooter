blur = {}
blur.active = true
blur.count = 10
blur.alphaMultipler = 20
blur.time = 1 / 60
blur.timer = 0

function blur:init()
  self.supported = postfx.supported
  if self.supported then self:reset() end
end

function blur:draw(canvas, alternate)
  if blur.timer < 0 then
    blur.timer = blur.timer + blur.time
    
    local c = table.remove(self.canvases)
    self.canvases[self.count] = c
    c:clear()
    love.graphics.setCanvas(c)
    love.graphics.draw(canvas, 0, 0)
  else
    blur.timer = blur.timer - love.timer.getDelta()
  end
  
  love.graphics.setCanvas(alternate)
  love.graphics.storeColor()
  
  for i = 1, self.count do
    love.graphics.setColor(255, 255, 255, i * self.alphaMultipler)
    love.graphics.draw(self.canvases[i])
  end
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(canvas)
  love.graphics.resetColor()
  postfx.swap()
end

function blur:reset()
  self.canvases = {}
  
  for i = 1, self.count do
    self.canvases[i] = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  end
end
