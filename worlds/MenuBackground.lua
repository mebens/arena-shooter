MenuBackground = class("MenuBackground", Game)

function MenuBackground:initialize()
  Game.initialize(self)
  self.padding = 20
  self.left = MissileSpawner:new(self.padding, 0, 0)
  self.right = MissileSpawner:new(love.graphics.width - self.padding, 0, math.tau / 2)
  self.top = MissileSpawner:new(0, self.padding, math.tau / 4)
  self.bottom = MissileSpawner:new(0, love.graphics.height - self.padding, math.tau * 0.75)
  self:add(self.left, self.right, self.top, self.bottom)
end

function MenuBackground:start()
  -- removing this stuff like this is a bit messy, but oh well
  self:remove(self.fade, self.hud, self.player)
end

function MenuBackground:update(dt)
  PhysicalWorld.update(self, dt)
  self.left.y = math.random(self.padding, love.graphics.height - self.padding)
  self.right.y = math.random(self.padding, love.graphics.height - self.padding)
  self.top.x = math.random(self.padding, love.graphics.width - self.padding)
  self.bottom.x = math.random(self.padding, love.graphics.width - self.padding)
end
