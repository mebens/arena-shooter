bloom = {}

function bloom:init()
  self.active = true
  self.effect = assets.effects.bloom
  self.supported = postfx.effectsSupported
  self.active = self.supported
  if self.supported then self:updateResolution() end
end

function bloom:draw(canvas)
  love.graphics.setCanvas(postfx.alternate)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0)
  postfx.swap()
  
  love.graphics.setCanvas(postfx.alternate)
  love.graphics.setPixelEffect(self.effect)
  love.graphics.draw(postfx.canvas, 0, 0)
  love.graphics.setPixelEffect()
  postfx.swap()
end

function bloom:updateResolution()
  self.effect:send("size", { love.graphics.width, love.graphics.height })
end
