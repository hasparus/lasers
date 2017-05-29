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

function propagate(collection, methodName, ...)
  for _, elem in pairs(collection) do
    if elem[methodName] then elem[methodName](elem,...) end
  end
end

function math.round(n, deci)
  deci = 10^(deci or 0)
  return math.floor(n*deci+.5)/deci
end