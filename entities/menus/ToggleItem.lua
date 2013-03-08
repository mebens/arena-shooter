ToggleItem = class("ToggleItem", MenuItem)

function ToggleItem:initialize(title, callback, callbackSelf, default, key)
  MenuItem.initialize(self, title, callback, callbackSelf, key)
  self.value = (default == nil) and true or default
  self:generateTitle()
end

function ToggleItem:update(dt)
  MenuItem.update(self, dt)
  if not self.menu.active then return end
  
  if self.activated and (input.pressed("left") or input.pressed("right")) then
    self:selected()
  end
end

function ToggleItem:selected()
  self:set(not self.value)
  
  if self.callbackSelf then
    self.callback(self.callbackSelf, self.value)
  else
    self.callback(self.value)
  end
end

function ToggleItem:set(value)
  self.value = value
  self:generateTitle()
end

function ToggleItem:generateTitle()
  self.text.text = self.title .. ": " .. (self.value and "On" or "Off")
end
