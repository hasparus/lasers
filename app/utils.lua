List = {}
List.__index = table

function List.new()
  local self = {}
  setmetatable(self, List)
  return self
end