class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'

LASER_LIFESPAN_MODIFIER = 25
LASER_LENGTH = 30
LASER_HEAD_TAIL_DISTANCE = 100
LASER_SHAKE = 15

LaserTail = class('LaserTail', DynamicBody)

function LaserTail:initialize(position, direction, power)
  DynamicBody.initialize(self, position.x, position.y, 5, 5)
  self.velocityLength = (direction * lume.clamp(power, 1, 5)):len()
end

function LaserTail:update(deltaTime)
  DynamicBody.update(self, deltaTime)
  local direction
  local middlepoints = self.entity.middlepoints

  if #middlepoints == 0 then
    if self.entity.head.pos:dist(self.pos) > LASER_HEAD_TAIL_DISTANCE * lume.clamp(self.velocityLength / 3, 1, 2) then
      direction = (self.entity.head.pos - self.pos):normalizeInPlace()
      self.pos = self.pos + direction * self.velocityLength * deltaTime
    end
  else
    local first = middlepoints[1]
    direction = (first - self.pos):normalizeInPlace() 
    self.pos = self.pos + direction * self.velocityLength * deltaTime
    if middlepoints[1]:dist(self.pos) < 2 then
      table.remove(middlepoints, 1)
    end
  end
end

function LaserTail:draw()
  love.graphics.setColor(colors.racket:getColor())
  love.graphics.translate(self.pos.x, self.pos.y)
  love.graphics.rotate(self.angle)
  love.graphics.ellipse('fill', 0, 0, self.size.x, self.size.y)
  love.graphics.origin()
end

LaserHead = class('LaserHead', DynamicBody)

function LaserHead:initialize(position, direction, power)
  DynamicBody.initialize(self, position.x, position.y, 3, 2)
  
  self.velocity = direction * lume.clamp(power, 1, 5)
  self.angularVelocity = 5

  self.collider = hc.circle(self.pos.x, self.pos.y, 3)
  self.collider.entity = self
end

function LaserHead:update(deltaTime)
  DynamicBody.update(self, deltaTime)

  for other, separating_vector in pairs(hc.collisions(self.collider)) do
    if other.entity then
      separating_vector = Vector2.new(separating_vector)
      --print(other.entity.class.name)
      local otherClass = other.entity.class.name
      if otherClass == 'Robot' then
        print('destroyed robot!')
      elseif otherClass == 'Wall' then
        
        shack:setShake(LASER_SHAKE)
        game.sounds.laserbounce:play()
        
        self.pos = self.pos + separating_vector * 5
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
  
  self.collider:moveTo(self.pos.x, self.pos.y)
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
  self.lifespan = LASER_LIFESPAN_MODIFIER * self.power / 2

  self:attach(LaserHead:new(position, direction, power))
  self:attach(LaserTail:new(position, direction, power))
  --self.tail = position:clone()
  self.middlepoints = {}

  self.shooter = shooter
end

function Laser:update(deltaTime)
  if self.lifespan > 0 then
    -- print(self.lifespan .. " lifespan")
    self.lifespan = self.lifespan - deltaTime
  else
    print('Destroying laser no'..self.ID)
    self:destroy()
    return
  end
  
  --print(self.ID .. ' lifespan ' .. self.lifespan)

  Entity.update(self, deltaTime)

end

function Laser:newMiddlepoint(point)
  print('NEW MIDDLEPOINT ' .. tostring(point))
  self.middlepoints[#self.middlepoints + 1] = point:clone()
end

function Laser:destroy()
  self.shooter.lasersLimit = self.shooter.lasersLimit + 1
  if self.head.collider then
    self.head.collider.entity = nil
    self.head.collider = nil
  end
  Entity.destroy(self)
end

function Laser:draw()
  Entity.draw(self)

  self.tail:draw()
  self.head:draw()

  local middlepoints = self.middlepoints    
  local nodes = {self.tail.pos, unpack(middlepoints)}
  nodes[#nodes + 1] = self.head.pos
  local points = {}

  --print(#nodes)
  
  for _, v in ipairs(nodes) do
    points[#points + 1] = v.x
    points[#points + 1] = v.y
  end
  
  love.graphics.line(unpack(points))
    --local node = middlepoints[#middlepoints]
    --love.graphics.line(node.x, node.y, self.head.pos.x, self.head.pos.y)
end