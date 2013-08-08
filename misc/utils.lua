function makeRectImage(width, height, r, g, b, a)
  local data = love.image.newImageData(width, height)
  r = r or 255
  g = g or 255
  b = b or 255
  a = a or 255
  data:mapPixel(function() return r, g, b, a end)
  return love.graphics.newImage(data)
end

function drawArc(x, y, r, angle1, angle2, segments)
  local i = angle1
  local j = 0
  local step = math.tau / segments
  
  while i < angle2 do
    j = angle2 - i < step and angle2 or i + step
    love.graphics.line(x + (math.cos(i) * r), y - (math.sin(i) * r), x + (math.cos(j) * r), y - (math.sin(j) * r))
    i = j
  end  
end

function drawBlackBg(alpha)
  love.graphics.storeColor()
  love.graphics.setColor(0, 0, 0, alpha)
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.resetColor()
end

function setMouseCoords(world)
  mouse.x = love.mouse.getX(world.camera)
  mouse.y = love.mouse.getY(world.camera)
end

function Entity:drawImage(image, x, y)
  image = image or self.image
  if self.color then love.graphics.setColor(self.color) end
  
  love.graphics.draw(
    image or self.image,
    x or self.x,
    y or self.y,
    self.angle,
    self.scaleX or self.scale or 1,
    self.scaleY or self.scale or 1,
    image:getWidth() / 2,
    image:getHeight() / 2
  )
end

-- currently unused, but I'll keep it for now
function makeFadedRect(width, height, divider, r, g, b, a)
  local data = love.image.newImageData(width, height)
  r = r or 255
  g = g or 255
  b = b or 255
  a = a or 255
  
  data:mapPixel(function(x, y, r, g, b, a)
    local factor = 1
    
    if x <= bw / div then
      factor = x / (bw / div)
    elseif x >= bw - bw / div then
      factor = (bw - x) / (bw / div)
    end
    
    if y <= bh / div then
      factor = y / (bh / div)
    elseif y >= bh - bh / div then
      factor = (bh - y) / (bh / div)
    end
    
    return r * factor, g * factor, b * factor, a
  end)
  
  return love.graphics.newImage(data)
end
