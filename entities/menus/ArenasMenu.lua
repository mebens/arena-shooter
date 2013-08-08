ArenasMenu = class("ArenasMenu", Menu)

function ArenasMenu:initialize(y, active, parent, fade)
  Menu.initialize(self, y, active, parent)
  self.fade = fade
  local arenaList = {}
  for i, v in ipairs(arenas) do arenaList[i] = v.title end
  
  self.selection = SelectionItem:new("Arena", arenaList, nil, self)
  self.selection.selectCallback = ArenasMenu.start
  self:add(self.selection)
  self:add(MenuItem:new("Start", self.start, self))
  self:add(MenuItem:new("Back", self.back, self, "escape"))
end

function ArenasMenu:start()
  self.fade:fadeOut(function()
    ammo.world = Game:new(arenas[self.selection.current])
  end)
end
