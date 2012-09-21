OptionsMenu = class("OptionsMenu", Menu)

function OptionsMenu:initialize(inX, outX, y, out, parent)
  Menu.initialize(self, inX, outX, y, out)
  self.parent = parent
  self.resSelect = SelectionItem:new("Resolution", data.resolutions, self.resolution, self, data.resolution)
  self.fsSelect = ToggleItem:new("Fullscreen", self.fullscreen, self, data.fullscreen)
  
  self:add(self.resSelect)
  self:add(self.fsSelect)
  self:add(ToggleItem:new("V-Sync", self.vsync, self, data.vsync))
  if blur.supported then self:add(ToggleItem:new("Motion Blur", self.blur, self, data.blur)) end
  self:add(ToggleItem:new("Constrain Mouse", self.mouseGrab, self, data.mouseGrab))
  self:add(MenuItem:new("Apply", self.apply, self))
  self:addSpace(25)
  self:add(MenuItem:new("Back", self.back, self, "escape"))
end

function OptionsMenu:resolution(value, index)
  data.resolution = index
end

function OptionsMenu:fullscreen(value)
  data.fullscreen = value
end

function OptionsMenu:vsync(value)
  data.vsync = value
end

function OptionsMenu:blur(value)
  data.blur = value
end

function OptionsMenu:mouseGrab(value)
  data.mouseGrab = value
end

function OptionsMenu:apply()
  data.apply()
  data.save()
  self.resSelect:select(data.resolution) -- in case data.apply had to revert to something safe
  self.fsSelect:set(data.fullscreen)
end

function OptionsMenu:back()
  self:switch(self.parent)
end
