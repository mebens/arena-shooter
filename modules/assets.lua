assets = setmetatable({}, {
  __index = function(self, key) return self.get(key) end
})

assets.path = "assets"
assets.imagePath = assets.path .. "/images"
assets.sfxPath = assets.path .. "/sfx"
assets.musicPath = assets.path .. "/music"
assets.effectsPath = assets.path .. "/effects"
assets.fontsPath = assets.path .. "/fonts"

assets.images = {}
assets.sfx = {}
assets.music = {}
assets.effects = {}
assets.fonts = {}

function assets.get(key)
  return assets.images[key] or assets.sfx[key] or assets.music[key] or assets.effects[key] or assets.fonts[key]
end

function assets.loadImage(file, name)
  local img = love.graphics.newImage(assets.imagePath .. "/" .. file)
  assets.images[name or assets.getName(file)] = img
  return img
end

function assets.loadSfx(file, name)
  local sound = Sound:new(assets.sfxPath .. "/" .. file, false)
  assets.sfx[name or assets.getName(file)] = sound
  return sound
end

function assets.loadMusic(file, name)
  local sound = Sound:new(assets.musicPath .. "/" .. file, true)
  assets.music[name or assets.getName(file)] = sound
  return sound
end

function assets.loadEffect(file, name)
  local effect = love.graphics.newPixelEffect(love.filesystem.read(assets.effectsPath .. "/" .. file))
  assets.effects[name or assets.getName(file)] = effect
  print(assets.getName(file))
  return effect
end

function assets.loadFont(file, size, name)
  name = name or assets.getName(file)
  size = size or 12
  
  if type(size) == "table" then
    for i = 1, #size do assets.loadFont(file, size[i], name) end
    return assets.fonts[name]
  end
  
  local font = love.graphics.newFont(assets.fontsPath .. "/" .. file, size)
  if not assets.fonts[name] then assets.fonts[name] = {} end
  assets.fonts[name][size] = font
  return font
end

function assets.getName(filepath)
  return filepath:gsub("(%.%w+)$", "")
end
