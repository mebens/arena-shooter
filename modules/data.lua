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

function data.init()
  data.resetOptions()
  data.highscore = 0
  
  if love.filesystem.exists(data.filename) then
    local t = loadstring(love.filesystem.read(data.filename))()
    for k, v in pairs(t) do data[k] = v end
  end
  
  data.apply()
end

function data.apply()
  love.mouse.setGrab(data.mouseGrab)
  blur.active = postfx.supported and data.blur or false
  bloom.active = postfx.effectsSupported and data.bloom or false
  noise.active = postfx.effectsSupported and data.noise or false
  
  local width, height = data.resolutions[data.resolution]:match("(%d+)x(%d+)")
  width = tonumber(width)
  height = tonumber(height)
  
  if love.graphics.checkMode(width, height, data.fullscreen) then
    love.graphics.setMode(width, height, data.fullscreen, data.vsync)
    data.safeResolution = data.resolution
    data.safeFullscreen = data.fullscreen
    postfx.updateResolution()
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
  local str = "return {"
  
  for k, v in pairs(data) do
    if type(v) == "number" or type(v) == "boolean" then
      str = str .. k .. "=" .. tostring(v) .. ","
    end
  end
  
  love.filesystem.write(data.filename, str .. "}")
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

function data.score(score)
  data.highscore = math.max(score, data.highscore)
  data.save()
end
