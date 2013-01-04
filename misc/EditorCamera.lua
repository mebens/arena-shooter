EditorCamera = class("EditorCamera", Camera)
EditorCamera.static.speed = 800

function EditorCamera:update(dt)
  self.x = self.x + EditorCamera.speed * input.axisDown("left", "right") * dt
  self.y = self.y + EditorCamera.speed * input.axisDown("up", "down") * dt
end
