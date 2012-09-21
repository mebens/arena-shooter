MainMenu = class("MainMenu", World)

function MainMenu:initialize()
  World.initialize(self)
  self.menuInX = 100
  self.menuOutX = -600
  self.menuY = 100
  self.fade = Fade:new()
  self.background = MenuBackground:new()
  
  self.menu = Menu:new(self.menuInX, self.menuOutX, self.menuY)
  self.menu:add(MenuItem:new("Play", self.play, self))
  self.menu:add(MenuItem:new("Options", self.showOptions, self))
  self.menu:add(MenuItem:new("Quit", self.quit, self))
  self.options = OptionsMenu:new(self.menuInX, self.menuOutX, self.menuY, true, self.menu)
  self:add(self.fade, self.menu, self.options)
end

function MainMenu:start()
  self.background:start()
end

function MainMenu:update(dt)
  World.update(self, dt)
  self.background:update(dt)
  
  if not self.background.rm then
    self.background:start()
    self.background.rm = true
  end
end

function MainMenu:draw()
  self.background:draw()
  drawBlackBg(150)
  World.draw(self)
end

function MainMenu:play()
  self.fade:fadeOut(function() ammo.world = Game:new() end)
end

function MainMenu:showOptions()
  self.menu:switch(self.options)
end

function MainMenu:quit()
  love.event.quit()
end
