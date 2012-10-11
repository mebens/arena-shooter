ScoreTracker = class("ScoreTracker", Entity)
ScoreTracker.baseScore = 10
ScoreTracker.multiBonusScore = 5
ScoreTracker.multiKillTime = 0.25

function ScoreTracker:initialize()
  Entity.initialize(self)
  self.layer = 0
  self.score = 0
  self.timer = 0
  self.multiKills = 0
  self.additionText = LinkedList:new()
  self.additionText.inactive = LinkedList:new()
end

function ScoreTracker:added()
  self.world:addListener("enemy.killed", self.enemyKilled, self)
end

function ScoreTracker:update(dt)
  self.timer = self.timer + dt
  
  if self.timer >= ScoreTracker.multiKillTime and self.multiKills > 0 then
    local addition = ScoreTracker.baseScore * self.multiKills + ScoreTracker.multiBonusScore * math.max(self.multiKills - 1, 0)
    self.score = self.score + addition
    self.multiKills = 0
    self:addText(addition)
  end
end

function ScoreTracker:draw()
  for text in self.additionText:getIterator() do text:draw() end
end

function ScoreTracker:addText(score)
  local text
  
  if self.additionText.inactive.length > 0 then
    text = self.additionText.inactive:pop()
  else
    text = Text:new{font = assets.fonts.main[20], color = { 255, 255, 255 }}
  end
  
  text.text = "+" .. score
  text.x = self.world.player.x - text.fontWidth / 2
  text.y = self.world.player.y - text.fontHeight / 2
  text.color[4] = 255
  tween(text, 1, { y = text.y - 30 }, nil, self.textDone, self, text)
  tween(text.color, "0.5:0.5", { [4] = 0 }, ease.quintIn)
  self.additionText:push(text)
end

function ScoreTracker:enemyKilled()
  self.timer = 0
  self.multiKills = self.multiKills + 1
end

function ScoreTracker:textDone(text)
  self.additionText:remove(text)
  self.additionText.inactive:push(text)
end
