MainMenu = class("MainMenu", World)

function MainMenu:initialize()
  World.initialize(self)
  self.menuY = 100
  self.fade = Fade:new(0.5, true)
  self.background = MenuBackground:new()
  
  self.menu = Menu:new(self.menuY)
  self.menu:add(MenuItem:new("Play", self.play, self))
  self.menu:add(MenuItem:new("Options", self.showOptions, self))
  self.menu:add(MenuItem:new("Quit", self.quit, self))
  self.arenas = ArenasMenu:new(self.menuY, false, self.menu, self.fade)
  self.options = OptionsMenu:new(self.menuY, false, self.menu)
  self:add(self.fade, self.menu, self.options, self.arenas)
end

function MainMenu:start()
  self.background:start()
  self.fade:fadeIn()
end

function MainMenu:update(dt)
  World.update(self, dt)
  setMouseCoords(self.background)
  self.background:update(dt)
  setMouseCoords(self)
end

function MainMenu:draw()
  setMouseCoords(self.background)
  self.background:draw()
  setMouseCoords(self)
  drawBlackBg(150)
  World.draw(self)
end

function MainMenu:play()
  self.menu:switch(self.arenas)
end

function MainMenu:showOptions()
  self.menu:switch(self.options)
end

function MainMenu:quit()
  love.event.quit()
end
