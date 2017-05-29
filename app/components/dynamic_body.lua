class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
Vector2 = require 'libs.hump.vector'

require 'components.component'
require 'components.body'

DynamicBody = class('DynamicBody', Body)

function DynamicBody:initialize(px, py, sx, sy)
  Body.initialize(self, px, py, sx, sy)
  
  self.acceleration = Vector2:new()
  self.velocity = Vector2:new()
  self.mass = 1

  self.angle = 0
  self.angularVelocity = 0
  self.angularAcceleration = 0
end

function DynamicBody:update(deltaTime)
  self.velocity = self.velocity + self.acceleration
  self.position = self.position + self.velocity

  self.angularVelocity = self.angularVelocity + self.angluarAcceleration
  self.angle = self.angle + self.angularVelocity
end