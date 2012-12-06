HUD = class("HUD", Entity)
HUD.static.lifeImageWidth = 18
HUD.static.lifeImageHeight = 20
HUD.static.lifeImage = makeRectImage(HUD.lifeImageWidth, HUD.lifeImageHeight, 255, 255, 255, 230)
HUD.static.lostLifeImage = makeRectImage(HUD.lifeImageWidth, HUD.lifeImageHeight, 255, 255, 255, 150)
HUD.static.lostLifeParticle = makeRectImage(6, 6, 255, 255, 255, 230)

function HUD:initialize()
  Entity.initialize(self)
  self.layer = -1
  self.padding = 20
  self.drawCursor = true
  self.over = false
  self.playColor = { 255, 255, 255, 255 }
  self.overColor = { 255, 255, 255, 0 }
  self.backgroundAlpha = 0
  
  self.score = Text:new{
    x = self.padding,
    y = self.padding,
    align = "center",
    font = assets.fonts.main[32],
    color = self.playColor
  }
  
  self.lives = {
    spacing = 8,
    text = Text:new{"Lives", x = self.padding, align = "center", font = assets.fonts.main[16], color = self.playColor}
  }
    
  self.overMsg = Text:new{
    "GAME OVER",
    x = self.padding,
    align = "center",
    font = assets.fonts.main[64],
    color = self.overColor
  }
  
  self.overScore = Text:new{
    x = self.padding,
    align = "center",
    font = assets.fonts.main[40],
    color = self.overColor
  }
  
  self.overHighscore = Text:new{
    x = self.padding,
    align = "center",
    font = assets.fonts.main[20],
    color = self.overColor
  }
  
  self.resetMsg = Text:new{
    "Press space to play again",
    x = self.padding,
    align = "center",
    font = assets.fonts.main[16],
    color = self.overColor
  }
    
  self.allText = { self.score, self.overMsg, self.overScore, self.overHighscore, self.resetMsg, self.lives.text }
    
  local ps = love.graphics.newParticleSystem(HUD.lostLifeParticle, 20)
  ps:setLifetime(0.05)
  ps:setEmissionRate(1000)
  ps:setParticleLife(0.4, 0.6)
  ps:setSpread(math.tau)
  ps:setColors(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0)
  ps:setRotation(0, math.tau)
  ps:setSpeed(40, 80)
  ps:stop()
  
  self.lifeParticles = ps
  self:adjustText()
end

function HUD:added()
  self.world:addListener("player.lifeLost", self.lifeLost, self)
end

function HUD:update(dt)
  self.lifeParticles:update(dt)
  self.score.text = self.world.score.score
end

function HUD:draw()
  if self.over then
    drawBlackBg(self.backgroundAlpha) -- a bit of black to bring text into focus more
    self.overMsg:draw()
    self.overScore:draw()
    self.overHighscore:draw()
    self.resetMsg:draw()
  end
  
  self.score:draw()
  self.lives.text:draw()
  
  love.graphics.setColor(self.playColor)
  love.graphics.draw(self.lifeParticles)
  
  for i = 0, Player.maxLives - 1 do
    local x = self.lives.x + (HUD.lifeImageWidth + self.lives.spacing) * i
    love.graphics.draw(i > self.world.player.lives - 1 and HUD.lostLifeImage or HUD.lifeImage, x, self.lives.y)
  end
  
  if self.drawCursor and not self.world.paused then
    self:drawImage(assets.images.crosshair, love.mouse.getRawPosition())
  end
end

-- contains stuff dependent on resolution
function HUD:adjustText()
  -- lives
  self.lives.text.y = love.graphics.height - self.lives.text.fontHeight - self.padding
  self.lives.x = love.graphics.width / 2 - (HUD.lifeImageWidth * Player.maxLives + self.lives.spacing * (Player.maxLives - 1)) / 2
  self.lives.y = self.lives.text.y - HUD.lifeImageHeight - 5
  
  -- width
  for _, v in pairs(self.allText) do
    v.width = love.graphics.width - self.padding * 2
  end
  
  -- game over y positioning
  self.overMsg.y = love.graphics.height / 2 - (self.overMsg.fontHeight + self.overScore.fontHeight) / 2
  self.overScore.y = self.overMsg.y + self.overMsg.fontHeight - 10
  self.overHighscore.y = self.overScore.y + self.overScore.fontHeight
  self.resetMsg.y = self.overHighscore.y + self.overHighscore.fontHeight + 50
end

function HUD:gameOver()
  self.over = true
  self.overScore.text = "Score: " .. self.world.score.score
  self.overHighscore.text = "Highscore: " .. data.highscore
  tween(self.playColor, 1, { [4] = 0 })
  tween(self.overColor, 1, { [4] = 255 })
  self:animate(1, { backgroundAlpha = 100 })
end

function HUD:lifeLost()
  local offset = (HUD.lifeImageWidth + self.lives.spacing) * self.world.player.lives + HUD.lifeImageWidth / 2
  self.lifeParticles:setPosition(self.lives.x + offset, self.lives.y + HUD.lifeImageHeight / 2)
  self.lifeParticles:start()
end
