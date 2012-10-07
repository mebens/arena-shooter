ScoreTracker = class("ScoreTracker", Entity)
ScoreTracker.baseScore = 10
ScoreTracker.multiBonusScore = 5
ScoreTracker.multiKillTime = 0.2

function ScoreTracker:initialize()
  Entity.initialize(self)
  self.visible = false
  self.score = 0
  self.timer = 0
  self.multiKills = 0
end

function ScoreTracker:added()
  self.world:addListener("enemy.killed", self.enemyKilled, self)
end

function ScoreTracker:update(dt)
  self.timer = self.timer + dt
  
  if self.timer >= ScoreTracker.multiKillTime and self.multiKills > 0 then
    self.score = self.score + ScoreTracker.baseScore * self.multiKills + ScoreTracker.multiBonusScore * (self.multiKills - 1)
    debug.log(ScoreTracker.baseScore * self.multiKills + ScoreTracker.multiBonusScore * (self.multiKills - 1))
    self.multiKills = 0
  end
end

function ScoreTracker:enemyKilled()
  self.multiKills = self.multiKills + 1
  debug.log(self.multiKills, self.timer)
  self.timer = 0
end
    
