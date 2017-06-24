class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'

require 'components.component'
require 'components.body'
require 'components.racket'
require 'components.dynamic_body'

ROBOT_SPEED = 500

local Vector2 = require 'libs.hump.vector'

colors = colors or {}
colors.robotish1 = COLORS.feel.pink
colors.robotish2 = COLORS.feel.green

Robot = class('Robot', Entity)

function Robot:initialize(x, y, sx, sy, playerID)
  Entity.initialize(self)

  self.playerID = playerID
  self:attach(Body:new(x, y, sx, sy))
  self:attach(Racket:new(x, y))
  
  self.collider = hc.circle(x, y, sx)
  self.collider.entity = self
end

function Robot:update(deltaTime)
  Entity.update(self, deltaTime)

  self:handleCollisions(deltaTime)
  self:moveInTime(deltaTime)
end

function Robot:moveInTime(deltaTime)
  local move = Vector2(game.controls.pad[self.playerID]:getLeftStick())
  move = move * deltaTime * ROBOT_SPEED
  self:move(move)
end

function Robot:getHitByLaser()
  love.audio.play('assets/playerhit.wav', 'static')
  love.audio.play('assets/playerdeath.wav', 'static')
  self:destroy()
end

function Robot:handleCollisions(deltaTime)
  local skipMove = false

  for other, separating_vector in pairs(hc.collisions(self.collider)) do
    separating_vector = Vector2.new(separating_vector)
    if other.entity then
      if other.entity.class.name == 'Racket' then
      -- do nothing 
      elseif other.entity and other.entity.move then
        if other.entity.class.name == 'LaserHead' then
          if other.entity.entity.mode == Laser.static.mode.AGGRESIVE then 
            self:getHitByLaser()
          end
          skipMove = true -- gameState.end() -- timescale *= 0.5, po sekundzie pokaż wyniki itditp
        else
      
          if not skipMove then
            other.entity:move(-separating_vector / 2) -- *blinker* reversing vector to pass throught walls? 
            self:move(separating_vector / 2)
          end
        end
      else
        if not skipMove then
          self:move(separating_vector)
        end
      end
    end
  end
end

function Robot:move(moveVector)
  propagate(self.components, 'move', moveVector)
  self.collider:move(moveVector:unpack())
end

function Robot:draw()
  love.graphics.withColor(colors['robotish' .. self.playerID],
    love.graphics.ellipse, 'fill', self.body:unpack())
  Entity.draw(self)
end

function Robot:destroy()
  self.racket:destroy()
  Entity.destroy(self)
end
