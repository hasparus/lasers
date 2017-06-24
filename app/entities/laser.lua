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

  function segmentCollisions(a, b)
    local collisionPoints = {}
    for i, racket in ipairs(game.rackets) do
      local c = racket.pos
      local d = racket.pos + racket.size
      
      local cross = Vector2.new(math.linesCrossPoint(
        math.lineFromPoints(a, b),
        math.lineFromPoints(c, d)
      ))

      if math.segment.within(a.x, cross.x, b.x) and
         math.segment.within(c.x, cross.x, d.x) then
        collisionPoints[#collisionPoints + 1] = {
          crossPoint = cross, 
          racketVector = racket.size
        }
      end
    end
    return collisionPoints
  end

  function Laser:initialize(shooter, direction, power, startPosition)
    Entity.initialize(self)
    local position

    if shooter then
      position = shooter.pos + direction
      self.shooter = shooter
      playLaserShotSound()
    else
      position = startPosition
    end

    self.power = power
    self.lifespan = LASER_LIFESPAN_MODIFIER * self.power / 2
    self.mode = Laser.static.mode.AGGRESIVE

    self:attach(LaserHead:new(position, direction, power))
    self:attach(LaserTail:new(position, direction, power))
    --self.tail = position:clone()
    self.middlepoints = {}
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

    if self.mode == Laser.static.mode.AGGRESIVE then
      self:handleCollisions()
    end
    --print(self.ID .. ' lifespan ' .. self.lifespan)
  
    Entity.update(self, deltaTime)
  end

  function Laser:handleCollisions()
    local nodes = {self.tail.pos, unpack(self.middlepoints)}
    nodes[#nodes + 1] = self.head.pos

    local splitPoints = List.new()
    for i = 1, #nodes - 1 do
      splitPoints:push(unpack(segmentCollisions(nodes[i], nodes[i + 1])))
    end

    for i, v in ipairs(splitPoints) do
      self:split(v)
    end
  end

  function Laser:split(splitInfo)
    local laserReflected = Laser:new(
        nil,
        self.head.velocity:mirrorOn(splitInfo.racketVector),
        self.power,
        splitInfo.crossPoint
      )

    laserReflected:becomePassive()
    laserReflected.head.velocity:trimInPlace(1.5 * self.head.velocity:len())
    self:becomePassive()
    self.tail.pos = splitInfo.crossPoint
    entities:push(laserReflected)
  end

  function Laser:becomePassive()
    self.mode = Laser.static.mode.PASSIVE
    --print("Meow.")
    local startTime = love.timer.getTime()
    korutin.new(function()
      --print("INSIDE CORO")
      while (love.timer.getTime() - startTime < LASER_PASSIVE_TIMEOUT) do
        coroutine.yield()
      end
      --print("Roar!")
      self.mode = Laser.static.mode.AGGRESIVE
    end)
  end
  
  function Laser:newMiddlepoint(point)
    --print('NEW MIDDLEPOINT ' .. tostring(point))
    self.middlepoints[#self.middlepoints + 1] = point:clone()
  end
  
  function Laser:destroy()
    if self.shooter then
      self.shooter.lasersLimit = self.shooter.lasersLimit + 1
    end

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