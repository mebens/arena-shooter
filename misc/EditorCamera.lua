EditorCamera = class("EditorCamera", Camera)
EditorCamera.static.speed = 800

function EditorCamera:update(dt)
  self.x = self.x + EditorCamera.speed * input.axisDown("left", "right") * dt
  self.y = self.y + EditorCamera.speed * input.axisDown("up", "down") * dt
  
  if self.world.mode ~= "shapeSelect" then
    local axis = 0
    if mouse.pressed.wu then axis = axis + .1 end
    if mouse.pressed.wd then axis = axis - .1 end
    self.zoom = self.zoom + axis
  end
end
