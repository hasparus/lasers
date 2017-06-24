return (function ()
  
  local coroutines = {}

  local new = function(...)
    table.insert(coroutines, coroutine.create(...))
  end

  local update = function(dt)
    local newArr = {}
    
    for i, c in ipairs(coroutines) do
      if coroutine.status(c) == 'suspended' then -- state equals suspended
        coroutine.resume(c, dt)
        table.insert(newArr, c)        
      end
    end

    coroutines = newArr
  end

  return {
    new = new,
    update = update
  }
end)()