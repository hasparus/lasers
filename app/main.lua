lovebird = require 'libs.lovebird'
class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
shack = require 'libs.shack.shack'
lue = require 'libs.lue'

graphzy = require 'utils.graphzy'

colors = colors or {}

window = {
  height = love.graphics.getHeight(),
  width = love.graphics.getWidth()
}

-- Game
game = {
  load = function()
    entities = List:new()
    bax = Bayoo:new()

    pauseOverlay = PauseOverlay:new()

    entities:push(Entity:new(),
                  Entity:new(),
                  bax,
                  pauseOverlay,
                  PadDebug:new()
                  )
  end,
  update = function(deltaTime)

    lume.each(entities, function (entity)
      entity:update(deltaTime)
    end)

    bax.body:move(
      (love.math.random() - 0.5) * 200 * deltaTime,
      (love.math.random() - 0.5) * 200 * deltaTime)
  end,
  draw = function()
    lume.each(entities, function (entity)
          entity:draw()
      end)
  end,
  paused = false
}

require 'managers.controls'

require 'entities.entity'
require 'entities.pause_overlay'
require 'entities.pad_debug_ui'
require 'entities.bayoo'

require 'utils.utils'


-- Love callbacks
function love.load()
  print('Started.')
  graphzy.setup()

  game.load()
end

function love.update(deltaTime)
  graphzy.update(deltaTime)
  lovebird.update()

  propagate(colors, 'update', deltaTime)

  if not game.paused then
    game.update(deltaTime)
  end
end

function love.draw()
  game.draw()
  graphzy.draw()
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.focus(focus)
  game.paused = not focus
  if focus then
    colors.pauseOverlayColor:setColor({
      color = {0, 0, 0, 0},
      speed = 100
    })
  else
    colors.pauseOverlayColor:setColor({
      color = {220, 220, 221, 150},
      speed = 10
    })
  end
  
  pauseOverlay.notifyOnFocusChange(focus)
end