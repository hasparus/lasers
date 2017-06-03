class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'

Entity = class('Entity')

function Entity:initialize()
  self.components = List.new()
end

function Entity:update(deltaTime)
  propagate(self.components, 'update', deltaTime)
end

function Entity:draw()
  propagate(self.components, 'draw')
end

function Entity:attach(component)
  self.components:push(component)
  component.entity = self
  
  local componentBaseName = 
    component.class.name:match('%u%U+$')
  self[componentBaseName:lower()] = component
end

function Entity:destroy()
  for k, v in ipairs(self.components) do
    v.entity = nil
  end
  entities:remove(self.ID)
end