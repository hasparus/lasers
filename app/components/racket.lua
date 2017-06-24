class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
Vector2 = require 'libs.hump.vector'

require 'components.component'
require 'components.body'
require 'entities.laser'

RACKETPROJECTOR_MAXCHARGE = 3

RACKET_EXTENSION_TRIGGER = 0.945
PROJECTOR_SPEED_MODIFIER = 0.3
RACKETPROJECTOR_SIZE = 4
RACKET_LENGTH = 100
RACKET_SPEED = 18
LASERS_LIMIT = 3
colors.racket = COLORS.feel.yellow

Racket = class('Racket', Body)
Racket.static.mode = {
  REFLECTOR = 1,
  PROJECTOR = 2
}

do

  local power5 = function(x) 
    local x2 = x * x
    return x2 * x2 * x
  end

  local laserPower = function(chargeLevel)
    local p = (0.35 + power5(chargeLevel / (RACKETPROJECTOR_MAXCHARGE / 3)))
    if p > 3.5 * RACKETPROJECTOR_MAXCHARGE then
      return 3.5 * RACKETPROJECTOR_MAXCHARGE
    end
    return p
  end

  local colorRandomizer = function(val)
    return lume.clamp((love.math.random() - 0.5) * 30 + val, 0, 255)
  end

  function Racket:initialize(px, py)
    Body.initialize(self, px, py, 0, 0)
    self.lasersLimit = LASERS_LIMIT
    self.racketMode  = Racket.static.mode.REFLECTOR

    self.chargeLevel = 0
    self.chargingDirection = 1
    self.dt = 0.01

    self.collider = hc.circle(self.pos.x + self.size.x, self.pos.y + self.size.y, 1)
    self.collider.entity = self

    self.id = #game.rackets + 1
    game.rackets[self.id] = self
  end

  function Racket:destroy()
    table.remove(game.rackets, self.id)
    self.body = nil
    self.collider.entity = nil
    self.collider = nil
  end

  function Racket:rotate(dt, x, y)
    if y then
      x = Vector2.new(x, y)
    end

    local v = x:normalized()
    v.x = RACKET_LENGTH * v.x
    v.y = RACKET_LENGTH * v.y
    self.size = (self.size + (v - self.size) * dt * RACKET_SPEED)
    local len = self.size:len()
    if len > RACKET_EXTENSION_TRIGGER * RACKET_LENGTH then
      self.size = self.size * (RACKET_LENGTH / len)
    end
  end

  function Racket:draw()
    if self.racketMode == Racket.static.mode.REFLECTOR then
      love.graphics.withColor(
        colors.racket,
        love.graphics.line, 
        self.pos.x, self.pos.y,
        self.pos.x + self.size.x, self.pos.y + self.size.y)
    elseif self.racketMode == Racket.static.mode.PROJECTOR then
      local sx = 
        RACKETPROJECTOR_MAXCHARGE * laserPower(self.chargeLevel)
      -- no nead to understand line below
      local shift = 
        self.dt * RACKET_LENGTH * sx * 
        Vector2.new(1, 1) / (1.9 + love.math.random() / 2)
      local randomizedColor = {lume.map(colors.racket:getColor(), colorRandomizer)}

      love.graphics.withColor(
        lue:newColor():setColor(unpack(randomizedColor)),
        love.graphics.ellipse, 'fill',
        self.pos.x + self.size.x + shift.x,
         self.pos.y + self.size.y + shift.y,
        sx, sx
      )
    else 
      error('Wrong racket mode: ' .. self.racketMode)
    end
  end

  function Racket:charge(value)
    if self.chargeLevel < RACKETPROJECTOR_MAXCHARGE then
      self.chargeLevel = self.chargeLevel + value
    end
  end

  function Racket:shoot()
    entities:push(Laser:new(self, self.size, laserPower(self.chargeLevel)))
    self.chargeLevel = 0
    self.lasersLimit = self.lasersLimit - 1
  end

  function Racket:update(deltaTime)
    local pad = game.controls.pad[self.entity.playerID]
    if not pad:connected() then return end

    local mode = self.racketMode
    local rotationSpeedModifier = 
      deltaTime * ((mode == Racket.static.mode.PROJECTOR) and PROJECTOR_SPEED_MODIFIER or 1)

    local x, y = pad:getRightStick()
    if x and y and x ~= 0 and y ~= 0 then
      self:rotate(rotationSpeedModifier, x, y)
    end

    local rt = pad:getRightTrigger()
    if rt and rt > 0 and self.lasersLimit > 0 then
      self:charge(rt * deltaTime)
      self.racketMode = Racket.static.mode.PROJECTOR
    else
      if self.chargeLevel > 0 then
        self:shoot()
      end
      self.racketMode = Racket.static.mode.REFLECTOR
    end

    self.collider:moveTo(self:combined():unpack())
    self:handleCollisions(deltaTime)
    self.dt = deltaTime
    -- on collision shake screen
    -- collide with lasers : emit particles, push lasers
    -- collide with racket : emit particles
    -- move laser middlepoints
  end

  function Racket:handleCollisions(deltaTime)
    -- Collisions with the tip.
    for other, separating_vector in pairs(hc.collisions(self.collider)) do
      if other.entity then
        separating_vector = Vector2.new(separating_vector)
        --print(other.entity.class.name)
        local otherClass = other.entity.class.name
        if otherClass == 'Robot' then
          -- do nothing
        elseif otherClass == 'Wall' then
          self.size = self.size + separating_vector
        end
      end
    end
  end

end