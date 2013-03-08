OptionsMenu = class("OptionsMenu", Menu)

function OptionsMenu:initialize(y, active, parent)
  Menu.initialize(self, y, active, parent)
  self.resolution = SelectionItem:new("Resolution", data.resolutions, self.setResolution, self, data.resolution)
  self.fullscreen = ToggleItem:new("Fullscreen", self.setFullscreen, self, data.fullscreen)
  self.vsync = ToggleItem:new("V-Sync", self.setVsync, self, data.vsync)
  self.mouseGrab = ToggleItem:new("Constrain Mouse", self.setMouseGrab, self, data.mouseGrab)
  self:add(self.resolution)
  self:add(self.fullscreen)
  self:add(self.vsync)
  
  if blur.supported then
    self.blur = ToggleItem:new("Motion Blur", self.setBlur, self, data.blur)
    self:add(self.blur)
  end
  
  if noise.supported then
    self.noise = ToggleItem:new("Noise", self.setNoise, self, data.noise)
    self:add(self.noise)
  end
  
  if bloom.supported then
    self.bloom = ToggleItem:new("Bloom", self.setBloom, self, data.bloom)
    self:add(self.bloom)
  end
  
  self:add(self.mouseGrab)
  self:addSpace(25)
  self:add(MenuItem:new("Apply", self.apply, self))
  self:add(MenuItem:new("Reset", self.reset, self))
  self:add(MenuItem:new("Back", self.back, self, "escape"))
end

function OptionsMenu:resetItems()
  self.resolution:select(data.resolution)
  self.fullscreen:set(data.fullscreen)
  self.vsync:set(data.vsync)
  self.mouseGrab:set(data.mouseGrab)
  if self.blur then self.blur:set(data.blur) end
  if self.bloom then self.bloom:set(data.bloom) end
end

function OptionsMenu:flashRed(item)
  tween(item.text.color, 0.3, { 255, 0, 0 }, nil, function()
    tween(item.text.color, 0.3, { 255, 255, 255 })
  end)
end

function OptionsMenu:setResolution(value, index)
  data.resolution = index
end

function OptionsMenu:setFullscreen(value)
  data.fullscreen = value
end

function OptionsMenu:setVsync(value)
  data.vsync = value
end

function OptionsMenu:setBlur(value)
  data.blur = value
end

function OptionsMenu:setNoise(value)
  data.noise = value
end

function OptionsMenu:setBloom(value)
  data.bloom = value
end

function OptionsMenu:setMouseGrab(value)
  data.mouseGrab = value
end

function OptionsMenu:apply()
  if not data.apply() then
    self:flashRed(self.resolution)
    self:flashRed(self.fullscreen)
    self:resetItems()
  end
  
  data.save()
end

function OptionsMenu:reset()
  data.resetOptions()
  self:apply()
end
