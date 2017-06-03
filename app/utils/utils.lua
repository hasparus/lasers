List = {}
List.__index = function (_, key)
  return List[key] or table[key]
end

function List.new()
  local self = {}
  setmetatable(self, List)
  return self
end

function List:push(...)
  for _, v in pairs({...}) do
    self:insert(v)
  end
end

AutoIndexedList = {}
AutoIndexedList.__index = function (_, key)
  return AutoIndexedList[key] or table[key]
end

function AutoIndexedList.new()
  local self = { count = 0 }
  setmetatable(self, AutoIndexedList)
  return self
end

function AutoIndexedList:push(...)
  for _, v in pairs({...}) do
    self.count = self.count + 1
    v.ID = self.count
    self[self.count] = v
  end
end

function propagate(collection, methodName, ...)
  for _, elem in pairs(collection) do
    if elem[methodName] then elem[methodName](elem,...) end
  end
end

function math.round(n, deci)
  deci = 10^(deci or 0)
  return math.floor(n*deci+.5)/deci
end


love.graphics.stashingColor = function(action)
  stashed = {love.graphics.getColor()}
  action()
  love.graphics.setColor(unpack(stashed))
end

love.graphics.withColor = function(color, drawingFunction, ...)
  stashed = {love.graphics.getColor()}
  love.graphics.setColor(color:getColor())
  drawingFunction(...)
  love.graphics.setColor(unpack(stashed))
end