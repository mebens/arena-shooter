MainMenu = class("MainMenu", World)

function MainMenu:initialize()
  World.initialize(self)
  self.menuInX = 100
  self.menuOutX = -600
  self.menuY = 100
    
  self.menu = Menu:new(self.menuInX, self.menuOutX, self.menuY)
  self.menu:add(MenuItem:new("Play", self.play, self))
  self.menu:add(MenuItem:new("Options", self.showOptions, self))
  self.menu:add(MenuItem:new("Quit", self.quit, self))
  self.options = OptionsMenu:new(self.menuInX, self.menuOutX, self.menuY, true, self.menu)
  self:add(Fade:new(), self.menu, self.options)
end

function MainMenu:play()
  Fade.id:fadeOut(function() ammo.world = Game:new() end)
end

function MainMenu:showOptions()
  self.menu:switch(self.options)
end

function MainMenu:quit()
  love.event.quit()
end
