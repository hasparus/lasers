class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'

LaserHead = class('LaserHead', DynamicBody)

do

  local playRandomLaserHitSound = function()
    love.audio.play('assets/laserhits/laser' .. love.math.random(9) .. '.wav', 'static')
  end

  local wallCollisionSfx = function()
    shack:setShake(LASER_SHAKE)
    playRandomLaserHitSound()
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
    love.graphics.setColor(colors.racket:getColor())
    love.graphics.translate(self.pos.x, self.pos.y)
    love.graphics.rotate(self.angle)
    love.graphics.ellipse('fill', 0, 0, self.size.x, self.size.y)
    love.graphics.origin()
  end

  function LaserHead:handleCollisions(dt)
    for other, separating_vector in pairs(hc.collisions(self.collider)) do
      if other.entity then
        separating_vector = Vector2.new(separating_vector)
        --print(other.entity.class.name)
        local otherClass = other.entity.class.name
        if otherClass == 'Robot' then
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