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
  width = 1440,
  height = 900,
  func = function(self, width, height)
    self:createExternalBarrier()
    fourSpawners(self, width, height, 40)
  end
}

arenas[#arenas + 1] = {
  title = "Box in a Box",
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
  title = "Hexagon",
  width = 1680,
  height = 1680,
  func = function(self, width)
    self:createExternalBarrier(8)
    --self:addInternalBarrier(InternalBarrier:new(8, width / 2, width / 2, width / 8))
  end
}
