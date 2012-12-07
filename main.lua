require("ammo")
require("ammo.physics")
require("ammo.input")
require("ammo.tweens")
require("ammo.debug")
require("ammo.debug.live")
require("ammo.debug.commands")
require("ammo.assets")
require("lib.carpenter.carpenter")

require("misc.utils")
require("misc.Text")
require("misc.MessageEnabled")
require("misc.ColorRotator")
require("misc.Timers")
require("misc.GameCamera")

require("modules.data")
require("modules.postfx")
debug.include(require("modules.commands"))
require("modules.effects.bloom")
require("modules.effects.blur")
require("modules.effects.noise")

require("entities.ScoreTracker")
require("entities.Fade")
require("entities.HUD")
require("entities.Barrier")
require("entities.Player")
require("entities.Enemy")
require("entities.EnemySpawner")
require("entities.EnemyChunk")
require("entities.ChargerEnemy")
require("entities.Missile")
require("entities.Shrapnel")
require("entities.MissileSpawner")

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
  -- assets
  assets.loadFont("quantico.ttf", { 16, 20, 32, 40, 64 }, "main")
  assets.loadImage("crosshair.png")
  assets.loadEffect("bloom.frag")
  assets.loadEffect("noise.frag")
  
  -- init functions
  postfx.init()
  data.init()
  debug.init()
  
  -- postfx
  postfx.add(blur)
  postfx.add(bloom)
  postfx.add(noise)
  
  -- misc
  love.mouse.setVisible(false)  
  log = debug.log
  ammo.world = MainMenu:new()
  
  -- player controls
  input.define("left", "a", "left")
  input.define("right", "d", "right")
  input.define("up", "w", "up")
  input.define("down", "s", "down")
  input.define{"fire", mouse = "l"}
  input.define{"missile", mouse = "r"}
  
  -- world controls
  input.define("slowmo", " ")
  input.define("reset", " ")
  input.define("pause", "escape", "p")
  
  -- menu/hud controls
  input.define("select", "return", " ")
  input.define("debug", "`")
end

function love.update(dt)
  postfx.update(dt)
  ammo.update(dt)
  debug.update(dt)
  input.update()
end

function love.draw()
  ammo.draw()
  debug.draw()
end

function love.keypressed(k, code)
  input.keypressed(k)
  debug.keypressed(k, code)
  
  -- backup quit key  
  if key.down.lctrl and k == "q" then love.event.quit() end
end
