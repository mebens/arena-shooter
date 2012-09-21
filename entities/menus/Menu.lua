Menu = class("Menu", Entity)

function Menu:initialize(inX, outX, y, out)
  Entity.initialize(self, out and outX or inX, y)
  self.inX = inX
  self.outX = outX
  self.transitionTime = 0.35
  self.padding = 0
  
  self.list = {}
  self.current = 1
  self.visible = false
  self.currentY = 0
  if out then self.active = false end
end

function Menu:added()
  self.world:add(unpack(self.list))
  self.list[self.current]:activate()
end

function Menu:update(dt)
  local up = input.pressed("up") and self.current > 1  
  local down = input.pressed("down") and self.current < #self.list
  if up or down then self:activate(self.current + (up and -1 or 1)) end
end

function Menu:add(item)
  self.list[#self.list + 1] = item
  item.menu = self
  item.y = self.currentY
  self.currentY = self.currentY + item.height + self.padding
end

function Menu:addSpace(height)
  self.currentY = self.currentY + height
end

function Menu:activate(index)
  self.list[self.current]:deactivate()
  self.current = index
  self.list[self.current]:activate()
end

function Menu:switch(menu)
  self:animate(self.transitionTime, { x = self.outX })
  menu:animate(menu.transitionTime, { x = menu.inX }, nil, function() menu.active = true end)
  self.active = false
end
