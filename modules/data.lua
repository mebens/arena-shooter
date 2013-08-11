data = {}
data.filename = "data"
data.resolutions = {
  "800x600",
  "1024x768",
  "1280x720",
  "1280x768",
  "1440x900",
  "1680x1050",
  "1680x1200",
  "1920x1080",
  "1920x1200",
  "2560x1440",
  "2560x1600"
}

local function tableToString(t, str)
  str = (str or "") .. "{"
  
  for k, v in pairs(t) do
    if type(v) == "number" or type(v) == "boolean" then
      str = str .. k .. "=" .. tostring(v) .. ","
    elseif k ~= "resolutions" and type(v) == "table" then
      str = str .. k .. "=" .. tableToString(v) .. ","
    end
  end
  
  str = str .. "}"
  return str
end

function data.init()
  data.resetOptions()
  data.highscores = {}
  
  if love.filesystem.exists(data.filename) then
    local t = loadstring(love.filesystem.read(data.filename))()
    for k, v in pairs(t) do data[k] = v end
  end
  
  data.apply()
end

function data.apply()
  love.mouse.setGrab(data.mouseGrab)
  blur.active = postfx.supported and data.blur or false
  bloom.active = postfx.fxSupported and data.bloom or false
  noise.active = postfx.fxSupported and data.noise or false
  
  local width, height = data.resolutions[data.resolution]:match("(%d+)x(%d+)")
  data.resolutionWidth = tonumber(width)
  data.resolutionHeight = tonumber(height)
  
  if love.graphics.checkMode(data.resolutionWidth, data.resolutionHeight, data.fullscreen) then
    love.graphics.setMode(data.resolutionWidth, data.resolutionHeight, data.fullscreen, data.vsync)
    data.safeResolution = data.resolution
    data.safeFullscreen = data.fullscreen
    postfx.reset()
    if Game.id then Game.id:resolutionChanged() end
    return true
  else
    print("Display mode not supported:")
    print(data.resolutions[data.resolution])
    print("Fullscreen: " .. tostring(data.fullscreen))
    
    -- revert to something that works if we can
    if data.safeResolution then data.resolution = data.safeResolution end
    if data.safeFullscreen ~= nil then data.fullscreen = data.safeFullscreen end
    return false
  end
end

function data.save()
  love.filesystem.write(data.filename, tableToString(data, "return "))
end

function data.resetOptions()
  data.resolution = 4
  data.fullscreen = false
  data.vsync = true
  data.blur = true
  data.bloom = true
  data.noise = true
  data.mouseGrab = false
end

function data.score(game)
  data.highscores[game.design.name] = math.max(game.score, data.highscores[game.design.name] or 0)
  data.save()
end
