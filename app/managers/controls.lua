class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'

require 'entities.entity'
require 'components.component'

local PLAYER_COUNT = 2
-- local LX_INPUT_TRESHOLD = 0.2
-- local LY_INPUT_TRESHOLD = 0.2
-- local RX_INPUT_TRESHOLD = 0.2
-- local RY_INPUT_TRESHOLD = 0.2
local SUM_TRESHOLD = 0.3

function reduceNoise(val, treshold)
  if math.abs(val) < treshold then return 0 end
  return val
end

game = game or {}
game.controls = game.controls or {}

local GamepadController = class('GamepadController')
GamepadController.Axis = {}

game.controls.pad = { lastAction = { button = 'none', pad = {} } }
game.controls.pad.connect = function(id)
  return game.controls.pad[id]:connect(id)
end
for i = 1, PLAYER_COUNT do
  game.controls.pad[i] = GamepadController:new(i)
end

function love.gamepadpressed(joystick, button)
  local id = joystick:getID()
  game.controls.pad.connect(id)
  game.controls.pad.lastAction = 
    { button = button, pad = game.controls.pad[id] }
end

function GamepadController:connected()
  return not not self.joystick
end

function GamepadController:connect(controllerNumber)
  local jstick = love.joystick.getJoysticks()[controllerNumber]
  self.joystick = (jstick and jstick:isGamepad() and jstick) or nil
end

function GamepadController:initialize(controllerNumber)
  self.controllerNumber = controllerNumber
  self:connect(controllerNumber)
end

function GamepadController:getID()
  return self.joystick:getID()
end

function GamepadController:getLeftStick()
  if not self.joystick then return end

  x, y = self.joystick:getGamepadAxis("leftx"), self.joystick:getGamepadAxis("lefty")
  if math.abs(x) + math.abs(y) < SUM_TRESHOLD then x, y = 0, 0 end
  return x, y
end

function GamepadController:getRightStick()
  if not self.joystick then return end

  x, y = self.joystick:getGamepadAxis("rightx"), self.joystick:getGamepadAxis("righty")
  if math.abs(x) + math.abs(y) < SUM_TRESHOLD then x, y = 0, 0 end
  return x, y
end

function GamepadController:getLeftTrigger()
  if not self.joystick then return 0 end
  return self.joystick:getGamepadAxis("triggerleft")
end

function GamepadController:getRightTrigger()
if not self.joystick then return 0 end
  return self.joystick:getGamepadAxis("triggerright")
end