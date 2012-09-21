blur = {}
blur.active = true
blur.alphaMultipler = 15
blur.minAlpha = 10

function blur.init()
  blur.supported = love.graphics.isSupported("canvas")
  blur.active = blur.supported
  if blur.supported then blur.canvas = love.graphics.newCanvas() end
end

function blur.start()
  if not blur.active then return end
  love.graphics.setCanvas(blur.canvas)
  love.graphics.pushColor(0, 0, 0, math.clamp(dt * 255 * blur.alphaMultipler, blur.minAlpha, 255))
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.popColor()
end

function blur.stop()
  if not blur.active then return end
  love.graphics.setCanvas()
  love.graphics.draw(blur.canvas, 0, 0)
end
