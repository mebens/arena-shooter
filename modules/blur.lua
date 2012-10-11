blur = {}
blur.active = true
blur.alphaMultipler = 15
blur.minAlpha = 10

function blur.init()
  blur.supported = love.graphics.isSupported("canvas")
  blur.active = blur.supported
  
  if blur.supported then
    blur.canvas = love.graphics.newCanvas()
    blur.exclusion = love.graphics.newCanvas()
  end
end

function blur.start()
  if not blur.active then return end
  blur.include()
  blur.exclusion:clear()
  love.graphics.pushColor(0, 0, 0, math.clamp(dt * 255 * blur.alphaMultipler, blur.minAlpha, 255))
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.popColor()
end

function blur.stop()
  love.graphics.setCanvas()
  
  if blur.active then
    love.graphics.draw(blur.canvas, 0, 0)
    love.graphics.draw(blur.exclusion, 0, 0)
  end
end

function blur.include()
  if not blur.active then return end
  love.graphics.setCanvas(blur.canvas)
end

function blur.exclude()
  if not blur.active then return end
  love.graphics.setCanvas(blur.exclusion)
end
