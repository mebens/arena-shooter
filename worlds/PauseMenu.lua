PauseMenu = class("PauseMenu", World)

function PauseMenu:initialize()
  World.initialize(self)
  self.menuInX = 100
  self.menuOutX = -600
  self.menuY = 100
  PauseMenu.static.id = self
  
  self.menu = Menu:new(self.menuInX, self.menuOutX, self.menuY)
  self.menu:add(MenuItem:new("Resume", self.resume, self, "escape"))
  self.menu:add(MenuItem:new("Options", self.showOptions, self))
  self.menu:add(MenuItem:new("Quit", self.quit))
  self.options = OptionsMenu:new(self.menuInX, self.menuOutX, self.menuY, true, self.menu)
  self:add(self.menu, self.options)
end

function PauseMenu:start()
  self.menu:activate(1)
end

function PauseMenu:draw()
  Game.id:draw()
  drawBlackBg(150)
  World.draw(self)
end

function PauseMenu:resume()
  Game.id:unpause()
end

function PauseMenu:showOptions()
  self.menu:switch(self.options)
end

function PauseMenu:quit()
  love.event.quit()
end
