class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'
require 'components.lasertail'
require 'components.laserhead'

LASER_LIFESPAN_MODIFIER = 25
LASER_LENGTH = 30
LASER_HEAD_TAIL_DISTANCE = 75
LASER_SHAKE = 15

Laser = class('Laser', Entity)

do

  colors.laser = {
    COLORS.feel.lightBlue,
    COLORS.feel.yellow
  }

  Laser.static.mode = {
    PASSIVE = 1,
    AGGRESIVE = 2
  }

  function playLaserShotSound()
    love.audio.play('assets/lasershoot.wav')
  end

  function Laser:initialize(shooter, direction, power)
    Entity.initialize(self)
    local position = shooter.pos + direction
    
    self.power = power
    self.lifespan = LASER_LIFESPAN_MODIFIER * self.power / 2
    self.mode = Laser.static.mode.AGGRESIVE

    self:attach(LaserHead:new(position, direction, power))
    self:attach(LaserTail:new(position, direction, power))
    --self.tail = position:clone()
    self.middlepoints = {}
  
    self.shooter = shooter
  
    playLaserShotSound()
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
    love.graphics.setColor(colors.laser[self.mode]:getColor())

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

end