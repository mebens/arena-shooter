SelectionItem = class("SelectionItem", MenuItem)

function SelectionItem:initialize(title, options, callback, callbackSelf, default)
  MenuItem.initialize(self, title, callback, callbackSelf)
  self.options = options
  self.current = default or 1
  self:generateTitle()
end

function SelectionItem:update(dt)
  if not self.activated or not self.menu.active then return end
  local left = input.pressed("left") and self.current > 1  
  local right = input.pressed("right") and self.current < #self.options
  
  if left or right then
    self:select(self.current + (left and -1 or 1))
    
    if self.callbackSelf then
      self.callback(self.callbackSelf, self.options[self.current], self.current)
    else
      self.callback(self.options[self.current], self.current)
    end
  end
end

function SelectionItem:select(index)
  self.current = index
  self:generateTitle()
end

function SelectionItem:generateTitle()
  local title = self.title .. ": "
  if self.current > 1 then title = title .. "< " end
  title = title .. self.options[self.current]
  if self.current < #self.options then title = title .. " >" end
  self.text.text = title
end
