class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'

require 'components.component'
require 'components.body'
require 'components.dynamic_body'

local Vector2 = require 'libs.hump.vector'

colors = colors or {}
colors.robotish1 = lue:newColor():setColor({
    hue = {240, 230, 255, 40}
})
colors.robotish2 = lue:newColor():setColor({
    hue = {120, 130, 255, 40}
})

Robot = class('Entity', Entity)

function Robot:initialize(x, y, sx, sy, playerID)
  Entity.initialize(self)

  self.playerID = playerID
  self:attach(Body:new(x, y, sx, sy))
  print(self)
end

function Robot:update(deltaTime)
  Entity.update(self)

  local move = Vector2(game.controls.pad[self.playerID]:getLeftStick())
  self.body:move(move * deltaTime * 1000)
end

function Robot:draw()
  Entity.draw(self)

  love.graphics.setColor(colors['robotish' .. self.playerID]:getColor())
  DEBUGFUCK = self.body
  love.graphics.ellipse('fill',
    self.body.pos.x, self.body.pos.y, self.body.size.x, self.body.size.y)
end
