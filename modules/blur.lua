blur = {}
blur.alphaMultipler = 15
blur.minAlpha = 1
blur.active = true

function blur.init()
  blur.supported = postfx.supported
  blur.active = blur.supported
  if blur.supported then blur.updateResolution() end
end

function blur:draw(canvas)
  love.graphics.setCanvas(blur.canvas)
  love.graphics.storeColor()
  love.graphics.setColor(0, 0, 0, math.clamp(dt * 255 * blur.alphaMultipler, blur.minAlpha, 255))
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.resetColor()
  love.graphics.draw(canvas, 0, 0)
  return blur.canvas
end

function blur:updateResolution()
  blur.canvas = love.graphics.newCanvas()
end
