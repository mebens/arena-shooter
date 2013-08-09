require("lib.ammo")
require("lib.assets")
require("lib.carpenter.carpenter")
require("lib.debug")
require("lib.debug.live")
require("lib.debug.commands")
require("lib.input")
require("lib.physics")
require("lib.tweens")
require("lib.postfx")

require("misc.utils")
require("misc.arenas")
require("misc.Text")
require("misc.MessageEnabled")
require("misc.ColorRotator")
require("misc.Timers")
require("misc.GameCamera")
require("misc.EditorCamera")

require("modules.data")
debug.include(require("modules.commands"))
require("modules.effects.bloom")
require("modules.effects.blur")
require("modules.effects.noise")

require("entities.Fade")
require("entities.HUD")
require("entities.Barrier")
require("entities.ExternalBarrier")
require("entities.InternalBarrier")
require("entities.Player")
require("entities.Gem")
require("entities.Enemy")
require("entities.EnemySpawner")
require("entities.ExplosionChunk")
require("entities.Missile")
require("entities.Shrapnel")
require("entities.MissileSpawner")
require("entities.Background")

require("entities.menus.MenuItem")
require("entities.menus.SelectionItem")
require("entities.menus.ToggleItem")
require("entities.menus.Menu")
require("entities.menus.OptionsMenu")
require("entities.menus.ArenasMenu")

require("worlds.Game")
require("worlds.MainMenu")
require("worlds.PauseMenu")
require("worlds.MenuBackground")
require("worlds.Editor")

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
  postfx.addList(bloom, noise)
  
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
  
  -- editor controls
  input.define("editorShapeSelect", "1")
  input.define("editorShapeMode", "2")
  input.define("editorShapeNew", "3")
  input.define("editorSpawn", "4")
  input.define("editorPlayer", "5")
  input.define("editorResetMode", "0")
  input.define("editorDelete", "backspace", "delete")
  input.define("editorCancel", "escape", "backspace", "delete")
  input.define("editorReset", "r")
  input.define("editorLock", "lshift", "rshift")
  input.define("editorSnap", "lalt", "ralt")
end

function love.update(dt)
  if key.down.lctrl and key.pressed.e then
    if instanceOf(Editor, ammo.world) then
      ammo.world = MainMenu:new()
    else
      ammo.world = Editor:new()
    end
  end
  
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
