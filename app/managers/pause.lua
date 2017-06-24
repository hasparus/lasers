require 'entities.pause_overlay'

return (function ()
  local pauseOverlay

  local init = function(entitiesList)
    pauseOverlay = PauseOverlay:new()
    entitiesList:push(pauseOverlay)
    game.paused = false
  end
  
  local pause = function(pause)
    game.paused = pause
    pauseOverlay:changeState(pause)
  end

  return {
    init = init,
    pause = pause
  }
end)()