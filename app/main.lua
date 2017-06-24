lovebird = require 'libs.lovebird'
class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
shack = require 'libs.shack.shack'
lue = require 'libs.lue'
hc = require 'libs.HC'

require 'managers.sounds'
require 'colors'
graphzy = require 'utils.graphzy'
korutin = require 'managers.korutin'
pauser = require 'managers.pause'

colors = colors or {}

window = {
  height = love.graphics.getHeight(),
  width = love.graphics.getWidth()
}

-- Game
game = {
  sounds = {
    playMusic = function()
      local music = love.audio.play('assets/loops/loop' .. love.math.random(3) .. '.wav', 'stream', true)
      music:setVolume(0.3)
    end
  },
  load = function()
    shack:setDimensions(window.width, window.height)
    entities = AutoIndexedList.new()
    game.entities = entities

    bax = Bayoo:new()

    local p = 12
    local q = 14

    robots = {
      Robot:new(window.width / 2, 50 + window.height / p, 30, 30, 1),
      Robot:new(window.width / 2, window.height - 50 - window.height / p, 30, 30, 2) }
      
    entities:push(UI:new(UI.Background:new()),
                  bax
                  )

                  --TODO:
    local netSize = 120
    entities:push(Net:new(0, window.height / 2 - (netSize / 2), window.width, netSize))
    walls = nil
    local instantiateWalls = function() --instantiate walls 
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

    pauser.init(entities)
    entities:push(PadDebug:new())

    game.sounds.playMusic()
  end,
  update = function(deltaTime)
    love.audio.update()
    shack:update(deltaTime)

    for i = 1, entities.count do
      local entity = entities[i]
      if entity then entity:update(deltaTime) end
    end

  end,
  draw = function()

    shack:apply()

    for i = 1, entities.count do
      local entity = entities[i]
      if entity then entity:draw() end
    end
  end,
  rackets = {}
}

require 'managers.controls'

require 'entities.entity'
require 'entities.pause_overlay'
require 'entities.pad_debug_ui'
require 'entities.bayoo'
require 'entities.robot'
require 'entities.wall'
require 'entities.net'
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
  korutin.update(deltaTime)
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

  if key == 'u' then
    game.controls.pad[1].joystick = "DEEEBUUUG"
  end

  if key == 'r' then
    love.event.quit('restart')
  end
end

function love.focus(focus)
  pauser.pause(not focus)
  print(focus)
end

function love.resize(w, h)
  window.width, window.height = w, h
  walls:refresh()
end