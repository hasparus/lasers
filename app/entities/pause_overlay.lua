require 'entities.entity'

PauseOverlay = class('PauseOverlay', Entity)

colors = colors or {}
colors.pauseOverlayColor = lue:newColor():setColor({255, 255, 255, 180})

function PauseOverlay:initialize()

end

function PauseOverlay:update()

end

function PauseOverlay:draw()
  -- if not game.paused then return end

  oldBlendMode = oldBlendMode or love.graphics.getBlendMode()
  local oldColor = {love.graphics.getColor()}

  love.graphics.setColor(colors.pauseOverlayColor:getColor())
  
  if game.paused then
    love.graphics.setBlendMode('screen')
    love.graphics.rectangle('fill', 0, 0, window.width, window.height)
  end

  love.graphics.setBlendMode('alpha')
  love.graphics.rectangle('fill', 0, 0, window.width, window.height)

  love.graphics.setColor(unpack(oldColor))
  love.graphics.setBlendMode(oldBlendMode)
end

function PauseOverlay:notifyOnFocusChange(focus)

end

