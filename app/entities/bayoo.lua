class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'

require 'components.component'
require 'components.body'
require 'components.dynamic_body'

colors = colors or {}
colors.bayooish = lue:newColor():setColor({
    hue = {180, 180, 255, 1}
})

Bayoo = class('Entity', Entity)

function Bayoo:initialize()
  Entity.initialize(self)
  
  self:attach(Body:new(200, 200, 150, 150))
  
  self.lolololo = 1
  self.sign = 1
end

function Bayoo:update()
  Entity.update(self)
end

function Bayoo:draw()
  Entity.draw(self)

  self.lolololo = self.lolololo + 0.1 * self.sign
  if self.lolololo > 254 or self.lolololo < 1 then
    self.sign = self.sign * -1
  end
  colors.bayooish:setColor({
    hue = {180, 180, 255, self.lolololo}
  })
  love.graphics.setColor(colors.bayooish:getColor())
  love.graphics.rectangle(
    'fill', self.body.pos.x, self.body.pos.y, self.body.size.x, self.body.size.y)
  
end
