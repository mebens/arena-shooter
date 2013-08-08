Menu = class("Menu", Entity)

function Menu:initialize(y, active, parent)
  Entity.initialize(self, 0, y)
  self.padding = 0
  self.parent = parent
  self.list = {}
  self.current = 1
  self.visible = false
  self.currentY = 0
  
  if active == nil then active = true end
  self.active = active
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
  self.active = false
  delay(0, function() menu.active = true end)
end

function Menu:back()
  if self.parent then self:switch(self.parent) end
end
