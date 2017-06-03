lovebird = require 'libs.lovebird'
class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
shack = require 'libs.shack.shack'
lue = require 'libs.lue'
hc = require 'libs.HC'

require 'colors'
graphzy = require 'utils.graphzy'

colors = colors or {}

window = {
  height = love.graphics.getHeight(),
  width = love.graphics.getWidth()
}

-- Game
game = {
  load = function()
    entities = AutoIndexedList.new()
    bax = Bayoo:new()

    pauseOverlay = PauseOverlay:new()
    robots = {
      Robot:new(window.width / 2 + 30, window.height / 2 + 30, 30, 30, 1),
      Robot:new(window.width / 2 - 30, window.height / 2 - 30, 30, 30, 2) }
      
    entities:push(UI:new(UI.Background:new()),
                  bax
                  )

    walls = nil
    local instantiateWalls = function() --instantiate walls 
      local p = 12
      local q = 14
      walls = WallComposite:new(0, 0, 0, 0,
        function ()
          local w, h = window.width, window.height
          return Wall:new(0, 0, w / p, h),
            Wall:new((p - 1) * w / p, 0, w / p, h),
            Wall:new(0, 0, w, h / q),
            Wall:new(0, (q - 1) * h / q, w, h / q)
          end
      )
      entities:push(walls)
    end
    instantiateWalls()
                  
    entities:push(unpack(robots))

    entities:push(pauseOverlay,
                  PadDebug:new())

  end,
  update = function(deltaTime)

    for i = 1, entities.count do
      local entity = entities[i]
      if entity then entity:update(deltaTime) end
    end

  end,
  draw = function()
    for i = 1, entities.count do
      local entity = entities[i]
      if entity then entity:draw() end
    end
  end,
  paused = false
}

require 'managers.controls'

require 'entities.entity'
require 'entities.pause_overlay'
require 'entities.pad_debug_ui'
require 'entities.bayoo'
require 'entities.robot'
require 'entities.wall'
require 'entities.ui'

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
  print(focus)
  pauseOverlay:notifyOnFocusChange(focus)
end

function love.resize(w, h)
  window.width, window.height = w, h
  walls:refresh()
end