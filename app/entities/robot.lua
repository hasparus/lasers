class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'

require 'components.component'
require 'components.body'
require 'components.dynamic_body'

ROBOT_SPEED = 500

local Vector2 = require 'libs.hump.vector'

colors = colors or {}
colors.robotish1 = COLORS.feel.pink
colors.robotish2 = COLORS.feel.green

Robot = class('Entity', Entity)

function Robot:initialize(x, y, sx, sy, playerID)
  Entity.initialize(self)

  self.playerID = playerID
  self:attach(Body:new(x, y, sx, sy))
  
  self.collider = hc.circle(x, y, sx)
  self.collider.entity = self

  -- todo add racket, render racket, rotate racket

  print(self)
end

function Robot:update(deltaTime)
  Entity.update(self)

  self:doCollide(deltaTime)
  self:doMove(deltaTime)
end

function Robot:doMove(deltaTime)
  local move = Vector2(game.controls.pad[self.playerID]:getLeftStick())
  move = move * deltaTime * ROBOT_SPEED
  self:move(move)
end

function Robot:doCollide(deltaTime)
  for other, separating_vector in pairs(hc.collisions(self.collider)) do
    separating_vector = Vector2.new(separating_vector)
    if other.entity and other.entity.move then
      other.entity:move(-separating_vector / 2) -- *blinker* reversing vector to pass throught walls? 
      self:move(separating_vector / 2)
    else
      self:move(separating_vector)
    end
  end
end

function Robot:move(move)
  self.body:move(move)
  self.collider:move(move:unpack())
end

function Robot:draw()
  Entity.draw(self)

  love.graphics.setColor(colors['robotish' .. self.playerID]:getColor())
  love.graphics.ellipse('fill', self.body:unpack())
end
