postfx = {}
postfx.all = {}
postfx.active = true

local PixelEffect = class("PixelEffect")

function PixelEffect:initialize(effect)
  self.effect = effect
  self.active = true
end

function PixelEffect:draw(canvas, alternate)
  love.graphics.setPixelEffect(self.effect)
  love.graphics.setCanvas(alternate)
  love.graphics.draw(canvas, 0, 0)
  love.graphics.setPixelEffect()
  postfx.swap()
end

function postfx.init()
  postfx.supported = love.graphics.isSupported("canvas")
  postfx.effectsSupported = love.graphics.isSupported("pixeleffect")
  postfx.active = postfx.supported
  if postfx.supported then postfx.updateResolution() end
end

function postfx.add(effect)
  if tostring(effect) == "PixelEffect" then
    effect = PixelEffect:new(effect)
  end
  
  postfx.all[#postfx.all + 1] = effect
end

function postfx.list(t)
  for _, v in ipairs(t) do postfx.add(v) end
end

function postfx.start()
  if not postfx.active then return end
  postfx.canvas:clear()
  postfx.alternate:clear()
  postfx.exclusion:clear()
  love.graphics.setCanvas(postfx.canvas)
end

function postfx.stop()
  if not postfx.active then return end
  local canvas = postfx.canvas
  
  for _, v in ipairs(postfx.all) do
    if v.active then
      canvas = v:draw(canvas, postfx.alternate) or postfx.canvas
    end
  end
  
  love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0)
  love.graphics.draw(postfx.exclusion, 0, 0)
end

function postfx.include()
  if not postfx.active then return end
  love.graphics.setCanvas(postfx.canvas)
end

function postfx.exclude()
  if not postfx.active then return end
  love.graphics.setCanvas(postfx.exclusion)
end

function postfx.swap()
  postfx.canvas, postfx.alternate = postfx.alternate, postfx.canvas
  postfx.alternate:clear()
end

function postfx.updateResolution()
  if not postfx.supported then return end
  postfx.canvas = love.graphics.newCanvas()
  postfx.alternate = love.graphics.newCanvas()
  postfx.exclusion = love.graphics.newCanvas()
  
  for _, v in ipairs(postfx.all) do
    if v.updateResolution then v:updateResolution() end
  end
end
