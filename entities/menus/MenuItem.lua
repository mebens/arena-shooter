MenuItem = class("MenuItem", Entity)

function MenuItem:initialize(title, callback, callbackSelf, key)
  Entity.initialize(self)
  self.title = title
  self.callback = callback
  self.callbackSelf = callbackSelf
  self.key = key
  self.activated = false
  self.text = Text:new{title, font = assets.fonts.main[40], color = { 255, 255, 255, 180 }}
  self.width = self.text.fontWidth
  self.height = self.text.fontHeight
end

function MenuItem:update(dt)
  if not self.menu.active then return end
  
  if (self.activated and input.pressed("select")) or (self.key and key.pressed[self.key]) then
    self:selected()
  end
end

function MenuItem:draw()
  self.text:draw(self.menu.x + self.x, self.menu.y + self.y)
end

function MenuItem:selected()
  self.callback(self.callbackSelf)
end

function MenuItem:activate()
  if self.colorTween then self.colorTween:stop() end
  self.colorTween = tween(self.text.color, 0.1, { [4] = 255 })
  self.activated = true
end

function MenuItem:deactivate()
  if self.colorTween then self.colorTween:stop() end
  self.colorTween = tween(self.text.color, 0.1, { [4] = 150 })
  self.activated = false
end
