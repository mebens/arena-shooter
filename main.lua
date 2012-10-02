require("ammo")
require("ammo.physics")
require("ammo.input")
require("ammo.tweens")

require("misc.utils")
require("misc.Text")
require("misc.ColorRotator")
require("misc.GameCamera")

require("modules.data")
require("modules.assets")
require("modules.blur")

require("entities.Fade")
require("entities.HUD")
require("entities.Barrier")
require("entities.Player")
require("entities.Enemy")
require("entities.EnemySpawner")
require("entities.EnemyChunk")
require("entities.Missile")
require("entities.MissileSpawner")
require("entities.Shrapnel")

require("entities.menus.MenuItem")
require("entities.menus.SelectionItem")
require("entities.menus.ToggleItem")
require("entities.menus.Menu")
require("entities.menus.OptionsMenu")

require("worlds.Game")
require("worlds.MainMenu")
require("worlds.PauseMenu")
require("worlds.MenuBackground")

function love.load()
  data.init()
  assets.loadFont("quantico.ttf", { 16, 20, 32, 40, 64 }, "main")
  assets.loadImage("crosshair.png")
  love.mouse.setVisible(false)
  
  key = input.key
  mouse = input.mouse
  ammo.world = MainMenu:new()
  
  -- player controls
  input.define("left", "a", "left")
  input.define("right", "d", "right")
  input.define("up", "w", "up")
  input.define("down", "s", "down")
  input.define{"fire", mouse = "l"}
  
  -- world controls
  input.define("slowmo", " ")
  input.define("reset", " ")
  input.define("pause", "escape", "p")
  
  -- menu/hud controls
  input.define("select", "return", " ")
  input.define("debug", "`")
end

function love.update(dt)
  ammo.update(dt)
  input.update()
end

function love.keypressed(key)
  input.keypressed(key)
  
  -- backup quit key; I've also no clue why I need to use input.key instead of key here
  if input.key.down.lctrl and key == "q" then love.event.quit() end
end