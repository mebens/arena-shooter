function makeRectImage(width, height, r, g, b, a)
  local data = love.image.newImageData(width, height)
  r = r or 255
  g = g or 255
  b = b or 255
  a = a or 255
  data:mapPixel(function() return r, g, b, a end)
  return love.graphics.newImage(data)
end

--[[function makeRectImage(width, height, r, g, b, radius)
  radius = radius or 15
  local cw = width + radius * 2
  local ch = height + radius * 2
  local canvas = love.graphics.newCanvas(cw, ch)
  r = r or 255
  g = g or 255
  b = b or 255
  love.graphics.setCanvas(canvas)
  
  for i = 0, radius - 1 do
    love.graphics.pushColor(r, g, b, 8 * (i + 1))
    love.graphics.rectangle("fill", i, radius, cw - i * 2, ch - radius * 2)
    love.graphics.popColor()
  end
  
  for i = 0, radius - 1 do
    love.graphics.pushColor(r, g, b, 8 * (i + 1))
    love.graphics.rectangle("fill", radius, i, cw - radius * 2, ch - i * 2)
    love.graphics.popColor()
  end
  
  local half = math.floor(radius / 2)
  love.graphics.pushColor(r, g, b, 40)
  love.graphics.rectangle("fill", half, half, cw - half * 2, ch * half * 2)
  love.graphics.popColor()
  
  love.graphics.pushColor(r, g, b, 255)
  love.graphics.rectangle("fill", radius, radius, width, height)
  love.graphics.popColor()
  
  
  love.graphics.setCanvas()
  return love.graphics.newImage(canvas:getImageData())
end]]

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
  love.graphics.pushColor(0, 0, 0, alpha)
  love.graphics.rectangle("fill", 0, 0, love.graphics.width, love.graphics.height)
  love.graphics.popColor()
end

function setMouseCoords(world)
  mouse.x = love.mouse.getX(world.camera)
  mouse.y = love.mouse.getY(world.camera)
end

function Entity:drawImage(image, x, y)
  image = image or self.image
  if self.color then love.graphics.pushColor(self.color) end
  
  love.graphics.draw(
    image or self.image,
    x or self.x,
    y or self.y,
    self.angle,
    self.scale or 1,
    self.scale or 1,
    image:getWidth() / 2,
    image:getHeight() / 2
  )
  
  if self.color then love.graphics.popColor() end
end
