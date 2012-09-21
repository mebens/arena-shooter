Fade = class("Fade", Entity)

function Fade:initialize(time, black)
  Entity.initialize(self)
  self.layer = -1
  self.time = time or 0.5
  self.alpha = black and 255 or 0
end

function Fade:draw()
  if self.alpha == 0 then return end
  drawBlackBg(self.alpha)
end

function Fade:fadeOut(complete, completeArgs)
  if self.tween then self.tween:stop() end
  self.tween = self:animate(self.time, { alpha = 255 }, nil, complete, completeArgs)
end

function Fade:fadeIn(complete, completeArgs)
  if self.tween then self.tween:stop() end
  self.tween = self:animate(self.time, { alpha = 0 }, nil, complete, completeArgs)
end
