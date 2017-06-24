class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'

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
  --love.graphics.translate(self.pos.x, self.pos.y)
  --love.graphics.rotate(self.angle)
  --love.graphics.ellipse('fill', 0, 0, self.size.x, self.size.y)
  --love.graphics.origin()
end
