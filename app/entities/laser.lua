class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'

LASER_LIFESPAN_MODIFIER = 25

LaserHead = class('LaserHead', DynamicBody)

function LaserHead:initialize(position, direction, power)
  DynamicBody.initialize(self, position.x, position.y, 3, 2)
  
  self.velocity = direction * lume.clamp(power, 1, 5)
  self.angularVelocity = 5
end

function LaserHead:update(deltaTime)
  DynamicBody.update(self, deltaTime)
  print(self.velocity)
end

function LaserHead:draw()
  love.graphics.setColor(colors.racket:getColor())
  love.graphics.translate(self.pos.x, self.pos.y)
  love.graphics.rotate(self.angle)
  love.graphics.ellipse('fill', 0, 0, self.size.x, self.size.y)
  love.graphics.origin()
end

Laser = class('Laser', Entity)

function Laser:initialize(shooter, direction, power)
  Entity.initialize(self)
  local position = shooter.pos + direction
  self.power = power
  self.lifespan = LASER_LIFESPAN_MODIFIER * self.power

  self:attach(LaserHead:new(position, direction, power))
  self.tail = position:clone()
  self.middlepoints = {tail, head}

  self.shooter = shooter

  --head collider
  self.head.collider = hc.circle(self.head.pos.x, self.head.pos.y, 1)
  self.head.collider.entity = self
end

function Laser:update(deltaTime)
  Entity.update(self, deltaTime)


  local head = self.head
  head.collider:moveTo(head.pos.x, head.pos.y)

  if (self.head.pos:dist(self.tail) > self.power) then
    self.tail = self.tail + self.head.velocity * deltaTime
  end

  for other, separating_vector in pairs(hc.collisions(self.head.collider)) do
    if other.entity then
      separating_vector = Vector2.new(separating_vector)
      print(other.entity.class.name)
      local otherClass = other.entity.class.name
      if otherClass == 'Robot' then
        print('destroyed robot!')
      elseif otherClass == 'Wall' then
        self.head.velocity = -self.head.velocity
        
      end
    end
  end

  if self.lifespan > 0 then
    print(self.lifespan)
    self.lifespan = self.lifespan - deltaTime
  else
    self:destroy()
  end
  -- so, this is multiline, head, {middlepoints / collision points}, tail
  -- on head collision: spawn middlepoint
  -- until tail collides draw from head to middlepoint and from middlepoint to tail 
end

function Laser:destroy()
  self.shooter.lasersLimit = self.shooter.lasersLimit + 1
  self.head.collider.entity = nil
  self.head.collider = nil
  Entity.destroy(self)
end

function Laser:draw()
  Entity.draw(self)

  self.head:draw()
end