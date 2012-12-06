data = {}
data.filename = "data"
data.resolutions = { "800x600", "1024x768", "1280x720", "1440x900", "1680x1050", "1680x1200", "1920x1080", "1920x1200", "2560x1440", "2560x1600" }

function data.init()
  if love.filesystem.exists(data.filename) then
    local t = loadstring(love.filesystem.read(data.filename))()
    for k, v in pairs(t) do data[k] = v end
  else
    data.resetOptions()
    data.highscore = 0
  end
  
  data.apply()
end

function data.apply()
  local width, height = data.resolutions[data.resolution]:match("(%d+)x(%d+)")
  width = tonumber(width)
  height = tonumber(height)
  
  if love.graphics.checkMode(width, height, data.fullscreen) then
    love.graphics.setMode(width, height, data.fullscreen, data.vsync)
    data.safeResolution = data.resolution
    data.safeFullscreen = data.fullscreen
    postfx.updateResolution()
    if Game.id then Game.id:resolutionChanged() end
  else
    -- revert to something that works if we can
    if data.safeResolution then data.resolution = data.safeResolution end
    if data.safeFullscreen then data.fullscreen = data.safeFullscreen end
    print("DISPLAY MODE NOT SUPPORTED")
  end
    
  blur.active = postfx.supported and data.blur or false
  bloom.active = (postfx.supported and postfx.effectsSupported) and data.bloom or false
  print(bloom.active, data.bloom)
  love.mouse.setGrab(data.mouseGrab)
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
  data.resolution = 3
  data.fullscreen = false
  data.vsync = true
  data.blur = true
  data.bloom = true
  data.mouseGrab = false
end

function data.score(score)
  data.highscore = math.max(score, data.highscore)
  data.save()
end
