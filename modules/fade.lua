fade = {}
fade.alpha = 0
fade.defaultTime = 0.5

local function doFade(time, complete, completeArgs, alpha)
  -- make time an optional argument
  if type(time) == "function" then
    completeArgs = complete
    complete = time
    time = nil
  end
  
  if fade.tween then fade.tween:stop() end
  fade.tween = AttrTween:new(fade, time or fade.defaultTime, { alpha = alpha }, nil, complete, completeArgs)
  fade.tween:start()
end

function fade.update(dt)
  if fade.tween and fade.tween.active then fade.tween:update(dt) end
end

function fade.draw()
  if fade.alpha == 0 then return end
  drawBlackBg(fade.alpha)
end

function fade.fadeOut(time, complete, completeArgs)
  doFade(time, complete, completeArgs, 255)
end

function fade.fadeIn(time, complete, completeArgs)
  doFade(time, complete, completeArgs, 0)
end
