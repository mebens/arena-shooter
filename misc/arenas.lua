arenas = {}

local function fourSpawners(self, width, height, padding)
  self:add(
    EnemySpawner:new(padding, padding),
    EnemySpawner:new(width - padding, padding),
    EnemySpawner:new(padding, height - padding),
    EnemySpawner:new(width - padding, height - padding)
  )
end

-- default setup
arenas[#arenas + 1] = {
  title = "Rectangle",
  name = "rectangle",
  width = 1440,
  height = 900,
  func = function(self, width, height)
    self:createExternalBarrier()
    fourSpawners(self, width, height, 40)
  end
}

arenas[#arenas + 1] = {
  title = "Box in a Box",
  name = "boxInABox",
  func = function(self, width, height)
    self.player.x = width / 2
    self.player.y = math.random(2) == 1 and 60 or height - 60
    self:createExternalBarrier()
    self:addInternalBarrier(InternalBarrier:new(4, width / 2, height / 2, width / 4, height / 4))
    fourSpawners(self, width, height, 40)
  end
}

arenas[#arenas + 1] = {
  title = "Pillars",
  name = "pillars",
  func = function(self, width, height)
    local bw = self.width / 6 -- box dimensions
    local bh = self.height / 6
    self:createExternalBarrier()
    fourSpawners(self, width, height, 40)
    
    self:addInternalBarrier(
      InternalBarrier:new(4, bw * 1.5, bh * 1.6, bw, bh),
      InternalBarrier:new(4, width - bw * 1.5, bh * 1.6, bw, bh),
      InternalBarrier:new(4, width - bw * 1.5, height - bh * 1.6, bw, bh),
      InternalBarrier:new(4, bw * 1.5, height - bh * 1.6, bw, bh)
    )
  end
}

arenas[#arenas + 1] = {
  title = "Hexanut",
  name = "hexanut",
  width = 1350,
  height = 1350,
  func = function(self, width)
    self.player.x = width / 2
    self.player.y = width / 2 + (math.random(2) == 1 and -width / 8 - 60 or width / 8 + 60)
    self:createExternalBarrier(6)
    self:addInternalBarrier(InternalBarrier:new(6, width / 2, width / 2, width / 6))
    self:add(EnemySpawner:new(width / 2, 120, 1.5), EnemySpawner:new(width / 2, width - 120, 1.5))
  end
}
