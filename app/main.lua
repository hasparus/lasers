lovebird = require 'libs.lovebird'
class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
shack = require 'libs.shack.shack'

require 'entity'
require 'utils'

entities = List:new()


function love.load()
  print('Started.')
  entities:insert(Entity:new())
  entities:insert(Entity:new())
end

function love.update(deltaTime)
  lovebird.update()

  lume.each(entities, function (entity)
    entity:update()
  end)

end

lolololo = 12
sign = 1

function love.draw()

  lolololo = lolololo + 0.1 * sign
  if lolololo > 254 or lolololo < 1 then
    sign = sign * -1
  end
  love.graphics.setColor(lolololo, 32, 255)
  love.graphics.rectangle('fill', 200, 200, 200, 200)

end