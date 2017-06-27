class = require 'libs.middleclass.middleclass'
lovebird = require 'libs.lovebird'
shack = require 'libs.shack.shack'
lume = require 'libs.lume.lume'
shine = require 'libs.shine'
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
    pauser.init(entities)
    
    game.ready.load()
    game.sounds.playMusic()
  end,
  finished = {
    load = function()
      game.ready.load()
    end,
    draw = function()
      shine.filmgrain():chain(shine.glowsimple()):draw(function()
        love.graphics.withColor(
          COLORS.feel.black,
          function()
            love.graphics.rectangle('fill', 0, 0, window.width, window.height)
            love.graphics.setColor(COLORS.feel.green:getColor())
            love.graphics.print([[
              Player ]] .. 79 .. [[ won!
                R -- Restart
                ESC -- Quit
            ]], 100, 200)
          end
        )
      end)
    end
  },
  ready = {
    load = function()
      game.ready.font = love.graphics.newFont('/assets/fonts/mystery_dungeon.ttf', 48)
      game.ready.font:setLineHeight(1.5)
      game.ready.previousFont = love.graphics.getFont()
      love.graphics.setFont(game.ready.font)
    end,
    draw = function()
      shine.filmgrain():chain(shine.glowsimple()):draw(function()
        love.graphics.withColor(
          COLORS.feel.blueGray,
          function()
            love.graphics.rectangle('fill', 0, 0, window.width, window.height)
            love.graphics.setColor(COLORS.feel.green:getColor())
            love.graphics.print([[
              Controls:
                Left Stick -- Move
                Right Stick -- Move Racket
                Right Trigger (hold) -- Charge Racket Laser Projector
                Right Trigger (release) -- Project Laser
                R -- Restart
                ESC -- Quit
              
              Press any key to start.
            ]], 100, 200)
          end
        )
      end)
    end,
    onKeyPressed = function()
      if game.state.phase == game.state.PHASE.READY then
        game.ready.unload()
        game.state.startGame()
        game.playing.load()
      end
    end,
    unload = function()
      love.graphics.setFont(game.ready.previousFont);
    end
  },
  playing = {
    load = function()
      --bax = Bayoo:new()

      local p = 12
      local q = 14

      robots = {
        Robot:new(window.width / 2, 135 + window.height / p, 30, 30, 1),
        Robot:new(window.width / 2, window.height - 135 - window.height / p, 30, 30, 2)}

      entities:push(UI:new(UI.Background:new()))

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

      local spawnCrystals = function(howMany, owner, shift, verticalShift)
        local crystalSize = Vector2.new(40, 40)

        local pos = owner.body.pos - Vector2.new(math.floor(howMany / 2) * shift, verticalShift)
        local crystals = List.new()
        for i = 1, howMany do
          crystals:push(
            Crystal:new(pos, crystalSize, owner)
          )
          pos.x = pos.x + shift
        end

        return crystals
      end
      entities:push(unpack(robots))

      entities:push(unpack(spawnCrystals(3, robots[1], 100, 100)))
      entities:push(unpack(spawnCrystals(3, robots[2], 100, -100)))

      entities:push(PadDebug:new())
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
    end
  },
  update = function(deltaTime)
    love.audio.update()
    shack:update(deltaTime)

    if game.state.phase == game.state.PHASE.PLAYING then
      game.playing.update(deltaTime)
    end
  end,
  draw = function()
    shack:apply()

    if game.state.phase == game.state.PHASE.READY then
      game.ready.draw()
    elseif game.state.phase == game.state.PHASE.PLAYING then
      game.playing.draw()
    elseif game.state.phase == game.state.PHASE.FINISHED then
      game.finished.draw()
    end
  end,
  rackets = {}
}

require 'managers.controls'
game.state = require 'managers.state'

require 'entities.pause_overlay'
require 'entities.pad_debug_ui'
require 'entities.crystal'
require 'entities.entity'
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
  COLORS.roll(deltaTime)

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

  --if key == 'u' then
  --  game.controls.pad[1].joystick = "DEEEBUUUG"
  --end

  if key == 'r' then
    love.event.quit('restart')
  end

  game.ready.onKeyPressed()
end

function love.focus(focus)
  pauser.pause(not focus)
  print(focus)
end

function love.resize(w, h)
  window.width, window.height = w, h
  walls:refresh()
end