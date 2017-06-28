class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'
require 'components.component'
require 'managers.controls'

PadDebug = class('PadDebug', Entity)

function PadDebug:initialize()
  Entity.initialize(self)
  
  self:attach(Body:new(
    window.width / 2 - 120,
    10, 10, 10))
end

function PadDebug:update()
  Entity.update(self)
end

function PadDebug:draw() 
  Entity.draw(self)

  love.graphics.setColor(255, 255, 255)

  local pad = game.controls.pad.lastAction.pad
  love.graphics.print(
    "Last gamepad button pressed: " .. 
    (pad.joystick and pad:getID() or 'none ' ) .. 
    (game.controls.pad.lastAction.button or 'none') , 
    window.width / 2 - 120, 10)
  
  if pad.joystick then
    local ax1, ax2 = pad:getLeftStick()
    local ax3, ax4 = pad:getRightStick()
    local ax5 = pad:getLeftTrigger()
    local ax6 = pad:getRightTrigger()
    love.graphics.print("Left stick: [" .. ax1 .. '], [' .. ax2 .. ']', window.width / 2 - 120, 30)
    love.graphics.print("Right stick: [" .. ax3 .. '], [' .. ax4 .. ']', window.width / 2 - 120, 50)
    love.graphics.print("Triggers: [" .. ax5 .. '], [' .. ax6 .. ']', window.width / 2 - 120, 70)
  end

  local p1 = game.controls.pad[1]
  local p2 = game.controls.pad[2]
  if p1.joystick then
    love.graphics.print("Pink lasers limit: " .. robots[1].racket.lasersLimit, 20, 400)
  end
  if p2.joystick then
    love.graphics.print("Pink lasers limit: " .. robots[2].racket.lasersLimit, 20, 400)
  end
end
