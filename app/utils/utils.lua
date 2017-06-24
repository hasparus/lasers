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

math.EPSILON = 0.00001

math.softEquals = function(a, b, epsilon)
  epsilon = epsilon or math.EPSILON
  return math.abs(a - b) < epsilon
end

math.lineFromPoints = function(one, two)
  local a = (one.y - two.y) / (one.x - two.x)
  local b = one.y - one.x * a

  return {a = a, b = b}
end

math.linesCrossPoint = function(l, k)
  local x = (k.b - l.b) / (l.a - k.a)
  local y = l.a * x + l.b

  return {x = x, y = y}
end

math.segment = math.segment or {}
math.segment.containsPoint = function(a, b, c)

  local colinear = math.segment.colinear
  local within = math.segment.within
  -- return true if point c is on line segment between ab.

  if (within(a.x, c.x, b.x)
      and within(a.y, c.y, b.y)) then
      
    --print(a, c, b)
    --print(colinear(a, c, b))
    --print((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y))

    return math.softEquals((b.x - a.x) * (c.y - a.y), (c.x - a.x) * (b.y - a.y), 1000)
  end
end

math.segment.colinear = function(a, b, c)
  return math.softEquals((b.x - a.x) * (c.y - a.y), (c.x - a.x) * (b.y - a.y))
end

math.segment.within = function(p, q, r)
  -- Return true iff q is between p and r (inclusive).
  return (p <= q and q <= r) or (r <= q and q <= p)
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