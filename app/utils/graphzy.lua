debugGraph = require 'libs.debugGraph'

return {
  setup = function()
    fpsGraph = debugGraph:new('fps', 0, 0)
    memGraph = debugGraph:new('mem', 0, 30)
    dtGraph = debugGraph:new('custom', 0, 60)
  end,
  update = function(dt)
    fpsGraph:update(dt)
    memGraph:update(dt)
    dtGraph:update(dt, math.floor(dt * 1000))
    dtGraph.label = 'DT: ' ..  math.round(dt, 4)
  end,
  draw = function()
    local saved = {love.graphics.getColor()}
    love.graphics.setColor(colors.bayooish:getColor())
    fpsGraph:draw()
    memGraph:draw()
    dtGraph:draw()
    love.graphics.setColor(unpack(saved))
  end
}