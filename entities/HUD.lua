HUD = class("HUD", Entity)
HUD.static.lifeImage = makeRectImage(18, 20, 255, 255, 255, 230)
HUD.static.lostLifeImage = makeRectImage(18, 20, 255, 255, 255, 80)

function HUD:initialize()
  Entity.initialize(self)
  self.layer = -1
  self.padding = 20
  self.debug = false
  self.drawCursor = true
  self.over = false
  self.playColor = { 255, 255, 255, 255 }
  self.overColor = { 255, 255, 255, 0 }
  
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
  
  self:adjustText()
  self.debugInfo = Text:new{x = self.padding, y = self.padding, font = assets.fonts.main[16]}
  self.backgroundAlpha = 0
end

function HUD:update(dt)
  if input.pressed("debug") then self.debug = not self.debug end
end

function HUD:draw()
  if self.over then
    drawBlackBg(self.backgroundAlpha) -- a bit of black to bring text into focus more
    self.overMsg:draw()
    self.overScore:draw()
    self.overHighscore:draw()
    self.resetMsg:draw()
  end
  
  if self.debug then
    self.debugInfo.text = ("FPS: %s\nCount: %s\nMemory: %.2f MB"):format(love.timer.getFPS(), self.world.count, collectgarbage("count") / 1000)
    self.debugInfo:draw()
  end
  
  self.score.text = self.world.score
  self.score:draw()
  self.lives.text:draw()
  love.graphics.pushColor(self.playColor)
  
  for i = 0, Player.maxLives - 1 do
    local x = self.lives.x + (HUD.lifeImage:getWidth() + self.lives.spacing) * i
    love.graphics.draw(i > self.world.player.lives - 1 and HUD.lostLifeImage or HUD.lifeImage, x, self.lives.y)
  end
  
  love.graphics.popColor()
  if self.drawCursor then self:drawImage(assets.images.crosshair, love.mouse.getRawX(), love.mouse.getRawY()) end
end

-- contains stuff dependent on resolution
function HUD:adjustText()
  -- lives
  self.lives.text.y = love.graphics.height - self.lives.text.fontHeight - self.padding
  self.lives.x = love.graphics.width / 2 - (HUD.lifeImage:getWidth() * Player.maxLives + self.lives.spacing * (Player.maxLives - 1)) / 2
  self.lives.y = self.lives.text.y - HUD.lifeImage:getHeight() - 5
  
  -- width
  for _, v in pairs{self.score, self.overMsg, self.overScore, self.overHighscore, self.resetMsg, self.lives.text} do
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
  self.overScore.text = "Score: " .. self.world.score
  self.overHighscore.text = "Highscore: " .. data.highscore
  tween(self.playColor, 1, { [4] = 0 })
  tween(self.overColor, 1, { [4] = 255 })
  self:animate(1, { backgroundAlpha = 100 })
end
