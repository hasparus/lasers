class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

Entity = class('Entity')

function Entity:initialize()
  self.tempCounter = 0
end

function Entity:update()
end