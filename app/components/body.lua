class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
Vector2 = require 'libs.hump.vector'

require 'components.component'

Body = class('Body', Component)

function Body:initialize(posX, posY, sizeX, sizeY)
  Component.initialize(self)
  self.pos = Vector2.new(posX, posY)
  self.size = Vector2.new(sizeX, sizeY)
end

function Body:unpack()
  return self.pos.x, self.pos.y, self.size.x, self.size.y
end

function Body:moveTo(x, y)
  if y == nil then
    self.pos = x
  else
    self.pos.x, self.pos.y = x, y
  end
  return self
end

function Body:move(x, y)
  if y == nil then
    self.pos = self.pos + x
  else
    self.pos.x = self.pos.x + x
    self.pos.y = self.pos.y + y
  end
  return self
end