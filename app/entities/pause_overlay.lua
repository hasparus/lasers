require 'entities.entity'

PauseOverlay = class('PauseOverlay', Entity) -- refactor to UI.Component
PauseOverlay.static.pausedBlendMode = 'screen'

colors = colors or {}
colors.pauseOverlayColor = lue:newColor():setColor({0, 0, 0, 0})

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
    love.graphics.setBlendMode(PauseOverlay.static.pausedBlendMode)
    love.graphics.rectangle('fill', 0, 0, window.width, window.height)
  end

  love.graphics.setBlendMode('alpha')
  love.graphics.rectangle('fill', 0, 0, window.width, window.height)

  love.graphics.setColor(unpack(oldColor))
  love.graphics.setBlendMode(oldBlendMode)
end

function PauseOverlay:changeState(pause)
  --print("focus: " .. (focus and 'true' or 'false'))
  if pause then
    colors.pauseOverlayColor:setColor({
      color = {220, 220, 221, 150},
      speed = 10
    })
  else
    colors.pauseOverlayColor:setColor({
      color = {0, 0, 0, 0},
      speed = 100
    })
  end
end

