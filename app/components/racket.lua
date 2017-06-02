class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
Vector2 = require 'libs.hump.vector'

require 'components.component'
require 'components.body'

Racket = class('Racket', Body)

colors.racket = COLORS.feel.yellow

function Racket:initialize(px, py, sx, sy)
  Body.initialize(self, px, py, sx, sy)
end

function Racket:rotate(phi)
  self.size:rotateInPlace(phi)
end

function Racket:draw()
  love.graphics.rectangle(self:unpack())
end

function Racket:update(deltaTime)
  -- on collision shake screen
  -- collide with lasers : emit particles, push lasers
  -- collide with racket : emit particles
end