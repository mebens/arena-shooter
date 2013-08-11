PauseMenu = class("PauseMenu", World)

function PauseMenu:initialize()
  World.initialize(self)
  self.menuY = 100
  PauseMenu.static.id = self
  
  self.menu = Menu:new(self.menuY)
  self.menu:add(MenuItem:new("Resume", self.resume, self, "escape"))
  self.menu:add(MenuItem:new("Reset", self.reset, self))
  self.menu:add(MenuItem:new("Options", self.showOptions, self))
  self.menu:add(MenuItem:new("Main Menu", self.mainMenu, self))
  self.menu:add(MenuItem:new("Quit", self.quit))
  
  self.options = OptionsMenu:new(self.menuY, false, self.menu)
  self:add(self.menu, self.options)
end

function PauseMenu:start()
  self.menu:activate(1)
  fade.alpha = 0
end

function PauseMenu:draw()
  setMouseCoords(Game.id)
  Game.id:draw()
  setMouseCoords(self)
  drawBlackBg(150)
  World.draw(self)
end

function PauseMenu:resume()
  Game.id:unpause()
end

function PauseMenu:reset()
  fade.fadeOut(self.resetFadeDone, self)
end

function PauseMenu:showOptions()
  self.menu:switch(self.options)
end

function PauseMenu:mainMenu()
  fade.fadeOut(self.menuFadeDone, self)
end

function PauseMenu:quit()
  love.event.quit()
end

function PauseMenu:resetFadeDone()
  Game.id:unpause()
  Game.id:reset()
end

function PauseMenu:menuFadeDone()
  ammo.world = MainMenu:new()
end
