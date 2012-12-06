bloom = {}
bloom.active = true

function bloom.init()
  bloom.effect = assets.effects.bloom
  bloom.supported = postfx.supported and postfx.effectsSupported
  bloom.active = bloom.active
  bloom.updateResolution()
end

function bloom:draw(canvas, alternate)
  love.graphics.setCanvas(alternate)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0)
  postfx.swap()
  
  love.graphics.setCanvas(postfx.alternate)
  love.graphics.setPixelEffect(bloom.effect)
  love.graphics.draw(postfx.canvas)
  love.graphics.setPixelEffect()
  postfx.swap()
end

function bloom:updateResolution()
  bloom.effect:send("size", { love.graphics.width, love.graphics.height })
end
