return (function()
  
  local CRYSTALS_COUNT = 3
  local PLAYERS_COUNT = 2

  local PHASE = {
    READY = 1,
    PLAYING = 2,
    FINISHED = 3
  }

  local state = { 
    playerCrystals = {},
    phase = PHASE.READY
  }

  for i = 1, PLAYERS_COUNT do 
    state.playerCrystals[i] = CRYSTALS_COUNT
  end

  local startGame = function()
    if state.phase == PHASE.READY then
      state.phase = PHASE.PLAYING
    else
      error('You can\'t start if game is not ready.')
    end
  end

  local endGame = function(winnerId)
    if state.phase == PHASE.PLAYING then
      state.phase = PHASE.FINISHED
    else
      error('You can\'t win if game is not playing.')
    end

    game.state.winnerId = winnerId
    game.finished.load()
  end

  local onCrystalDestroyed = function(crystal)
    local player = crystal.owner.playerID
    state.playerCrystals[player] = state.playerCrystals[player] - 1
  
    if state.playerCrystals[player] == 0 then
      endGame(3 - player)
    end
  end

  local onPlayerDeath = function(playerId)
    endGame(3 - playerId)
  end

  return setmetatable({
    PHASE = PHASE,
    onCrystalDestroyed = onCrystalDestroyed,
    onPlayerDeath = onPlayerDeath,
    startGame = startGame,
    endGame = endGame
  }, {__index = state})

end)()