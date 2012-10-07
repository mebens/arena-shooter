local t = {}

function t:slowmo(limit)
  ammo.world.maxSlowmo = tonumber(limit)
  ammo.world.slowmo = ammo.world.maxSlowmo
end

function t:inv()
  ammo.world.player.invincible = not ammo.world.player.invincible
  return "Player is " .. (ammo.world.player.invincible and "now" or "no longer") .. " invincible."
end

function t:dtf(factor)
  ammo.world.deltaFactor = tonumber(factor)
end

function t:smf(factor)
  ammo.world.slowmoFactor = tonumber(factor)
end

return t
