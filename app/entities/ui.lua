class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'entities.entity'
require 'components.component'
-- UILayer
UI = class('UI', Entity)

function UI:initialize(...)
  Entity.initialize(self)

  for _, v in pairs({...}) do
    self:attach(v)
  end
end

function UI:update(deltaTime)
  Entity.update(self)
end

function UI:draw()
  Entity.draw(self)
end

---

local Background = class('Background', Component)

function Background:draw()
  local oldColor = {love.graphics.getColor()}
  love.graphics.setColor(COLORS.feel.darkGray:getColor())
  love.graphics.rectangle('fill', 0, 0, window.width, window.height)
  love.graphics.setColor(unpack(oldColor))
end

UI.Background = Background