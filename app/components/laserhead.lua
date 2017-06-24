class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'

LaserHead = class('LaserHead', DynamicBody)
LASER_PASSIVE_TIMEOUT = 1.5

do

  local playRandomLaserHitSound = function()
    love.audio.play('assets/laserhits/laser' .. love.math.random(9) .. '.wav', 'static')
  end

  local racketCollisionSfx = function(pos)
    shack:setShear(love.math.random(-1, 1) * LASER_SHAKE / 5)
    love.audio.play('assets/racketbounce.wav')
  end

  local wallCollisionSfx = function()
    shack:setShake(LASER_SHAKE)
    playRandomLaserHitSound()
  end

  local collidedWithRacket = function(laserHeadPosition)
    for i, racket in ipairs(game.rackets) do
      local a = racket.pos
      local b = racket.pos + racket.size

      local res = math.segment.containsPoint(a, b, laserHeadPosition) and (
        racket:canReflect() and racket or false)
      if res then return res end
    end
    return false
  end

  function LaserHead:initialize(position, direction, power)
    DynamicBody.initialize(self, position.x, position.y, 3, 2)
    
    self.velocity = direction * lume.clamp(power, 1, 5)
    self.angularVelocity = 5

    self.collider = hc.circle(self.pos.x, self.pos.y, 3)
    self.collider.entity = self

  end

  function LaserHead:update(deltaTime)
    DynamicBody.update(self, deltaTime)

    self:handleCollisions(deltaTime)

    self.collider:moveTo(self.pos.x, self.pos.y)
  end

  function LaserHead:draw()
    --love.graphics.translate(self.pos.x, self.pos.y)
    --love.graphics.rotate(self.angle)
    --love.graphics.ellipse('fill', 0, 0, self.size.x, self.size.y)
    --love.graphics.origin()
  end

  function LaserHead:becomePassive()
    self.entity:becomePassive()
  end

  function LaserHead:reactToRacketCollision(racket)
    racketCollisionSfx(self.pos)
    print('Collided with racket.')

    self.entity:newMiddlepoint(self.pos)
    self.velocity = self.velocity:mirrorOn(racket.size)
    self:becomePassive()
  end

  --todo: kiedy rakietka przetnie laser -> 
    -- ucinam mój stary laser, teleportując laserTail za miejsce kolizji
    -- robię nowy laser, który ma głowę w miejscu kolizji i od razu wywoluję mu reactToRacketCollision

  function LaserHead:handleCollisions(dt)
    local aggresive = self.entity.mode == Laser.static.mode.AGGRESIVE
    
    if aggresive then
      local racket = collidedWithRacket(self.pos)
      if racket then
        self:reactToRacketCollision(racket)
        return
      end
    end
    
    for other, separating_vector in pairs(hc.collisions(self.collider)) do
      if other.entity then
        separating_vector = Vector2.new(separating_vector)
        --print(other.entity.class.name)
        local otherClass = other.entity.class.name
        
        if otherClass == 'Robot' and aggresive then
          print('destroyed robot!')
        
        elseif otherClass == 'Wall' then
          
          wallCollisionSfx()
          self:move(separating_vector * 5)
          local dir = other.entity:direction()
          if dir == 'Horizontal' then
            self.velocity.y = -self.velocity.y
          else
            self.velocity.x = -self.velocity.x
          end

          --print(dir .. ' direction')
          --print(other.entity:onWhichSide(self.pos).side .. 'side')

          self.entity:newMiddlepoint(self.pos)
          -- print(other.entity:direction() .. " direction")
          -- print(other.entity:onWhichSide(self.head.pos).side .. "side")
        end
      end
    end
  end
end