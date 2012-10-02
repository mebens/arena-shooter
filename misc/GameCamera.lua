GameCamera = class("GameCamera", Camera)

function GameCamera:initialize(x, y, zoom, angle)
  Camera.initialize(self, x, y, zoom, angle)
  self:endShake()
end
  
function GameCamera:update(dt)
  self.x = self.world.player.x - love.graphics.width / 2 + self.shakeX
  self.y = self.world.player.y - love.graphics.height / 2 + self.shakeY
end

function GameCamera:shake(amount, iterDuration, factor)
  if amount < 1 then return end
  if self.shaking then self.shakeTween:stop() end
  self.shaking = true
  self.shakeAmount = self.shakeAmount + amount
  self.shakeDuration = iterDuration or 0.075
  self.shakeFactor = factor or 1.5
  self.shakeState = math.random(1, 2) == 1 and -1 or 1
  self:doShake()
end

function GameCamera:doShake()
  if self.shakeAmount < 1 then return self:endShake() end
  local angle = math.random() * (math.tau / 2)
  
  self.shakeTween = self:animate(self.shakeDuration, {
    shakeX = math.cos(angle) * self.shakeAmount * self.shakeState,
    shakeY = math.sin(angle) * self.shakeAmount * self.shakeState
  }, nil, self.doShake, self)
  
  self.shakeAmount = self.shakeAmount / self.shakeFactor
  self.shakeState = -self.shakeState
end

function GameCamera:endShake()
  self.shakeX = 0
  self.shakeY = 0
  self.shakeAmount = 0
  self.shaking = false
end
