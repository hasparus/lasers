class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'

LASER_LIFESPAN_MODIFIER = 25
LASER_LENGTH = 30

LaserHead = class('LaserHead', DynamicBody)

function LaserHead:initialize(position, direction, power)
  DynamicBody.initialize(self, position.x, position.y, 3, 2)
  
  self.velocity = direction * lume.clamp(power, 1, 5)
  self.angularVelocity = 5
end

function LaserHead:update(deltaTime)
  DynamicBody.update(self, deltaTime)
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
  --self.tail = position:clone()
  self.middlepoints = {position:clone()}

  self.shooter = shooter

  --head collider
  self.head.collider = hc.circle(self.head.pos.x, self.head.pos.y, 1)
  self.head.collider.entity = self
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
  
  local head = self.head
  for other, separating_vector in pairs(hc.collisions(self.head.collider)) do
    if other.entity then
      separating_vector = Vector2.new(separating_vector)
      print(other.entity.class.name)
      local otherClass = other.entity.class.name
      if otherClass == 'Robot' then
        print('destroyed robot!')
      elseif otherClass == 'Wall' then
        head.pos = head.pos + separating_vector
        local dir = other.entity:direction()
        if dir == 'Horizontal' then
          head.velocity.y = -head.velocity.y
        else
          head.velocity.x = -head.velocity.x
        end

        self.middlepoints[#self.middlepoints + 1] = head.pos:clone()
        -- print(other.entity:direction() .. " direction")
        -- print(other.entity:onWhichSide(self.head.pos).side .. "side")
      end
    end
  end
  
  print(self.ID .. ' lifespan ' .. self.lifespan)

  Entity.update(self, deltaTime)

  head.collider:moveTo(head.pos.x, head.pos.y)

  local mp = self.middlepoints
  local n = #mp
  for i = 1, n - 1 do
    if (mp[i + 1]:dist(mp[i]) > LASER_LENGTH + self.power * 10) then
      mp[i] = mp[i] + 
      (self.head.velocity:len() * (mp[i + 1] - mp[i]):normalizeInPlace())
       * deltaTime
    end
  end
  if (self.head.pos:dist(self.middlepoints[n]) > LASER_LENGTH + self.power * 10) then
      self.middlepoints[n] = self.middlepoints[n] + self.head.velocity * deltaTime
  end

  -- so, this is multiline, head, {middlepoints / collision points}, tail
  -- on head collision: spawn middlepoint
  -- until tail collides draw from head to middlepoint and from middlepoint to tail 
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

  self.head:draw()

  local middlepoints = self.middlepoints
  for i = 1, #middlepoints - 1 do
    local node = middlepoints[i]
    local nextNode = middlepoints[i + 1]
    
    local points = {}
    for _, v in ipairs(middlepoints) do
      points[#points + 1] = v.x
      points[#points + 1] = v.y
    end
    
    love.graphics.line(unpack(points))
    local node = middlepoints[#middlepoints]
    love.graphics.line(node.x, node.y, self.head.pos.x, self.head.pos.y)
  end
end