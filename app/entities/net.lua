class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'

require 'components.component'
require 'components.body'
require 'components.racket'
require 'components.dynamic_body'

local Vector2 = require 'libs.hump.vector'

colors.net = COLORS.feel.orange
colors.netEdge = COLORS.feel.darkBlue

Net = class('Net', Wall)

function Net:initialize(x, y, sx, sy)
  Wall.initialize(self, x, y, sx, sy)
end

function Net:update(deltaTime)
  Wall.update(self, deltaTime)
end

function Net:draw()
  self:drawEdges(colors.netEdge)
  self:drawInside(colors.net)
  Wall.draw(self)
end