blur = {}
blur.active = true
blur.count = 5
blur.totalAlpha = 180
blur.time = 1 / 60
blur.timer = 0

function blur.init()
  blur.supported = postfx.supported
  if blur.supported then blur.reset() end
end

function blur.start()
  if not blur.active then return end
  
  if blur.timer <= 0 then
    blur.timer = blur.timer + blur.time
    local c = table.remove(blur.canvases, 1)
    blur.canvases[blur.count] = c
  else
    blur.timer = blur.timer - love.timer.getDelta()
  end
  
  blur.canvases[blur.count]:clear()
  blur.prevCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(blur.canvases[blur.count])
end

function blur.stop()
  if not blur.active then return end
  love.graphics.setCanvas(blur.prevCanvas)
  love.graphics.storeColor()
    
  for i = 1, blur.count do
    love.graphics.setColor(255, 255, 255, i == blur.count and 255 or i * (blur.totalAlpha / (blur.count - 1)))
    love.graphics.draw(blur.canvases[i])
  end
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.resetColor()
end

function blur.reset()
  blur.canvases = {}
  
  for i = 1, blur.count do
    blur.canvases[i] = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
  end
end
