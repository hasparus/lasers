class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'
lue = require 'libs.lue'
require 'entities.entity'

require 'components.component'
require 'components.body'
require 'components.racket'
require 'components.dynamic_body'

local Vector2 = require 'libs.hump.vector'

colors.wall = COLORS.feel.gray
colors.wallEdge = COLORS.feel.orange

Wall = class('Wall', Entity)

function Wall:initialize(x, y, sx, sy)
  Entity.initialize(self)

  self:attach(Body:new(x, y, sx, sy))
  
  self.collider = hc.rectangle(x - 1, y - 1, sx + 1, sy + 1)
  self.collider.entity = self
end

function Wall:update(deltaTime)
  Entity.update(self)
end

function Wall:drawEdges()
  love.graphics.setColor(colors.wallEdge:getColor())
  love.graphics.rectangle('line', self.body.pos.x - 1, self.body.pos.y - 1, self.body.size.x + 1, self.body.size.y + 1)
end

function Wall:drawInside()
  love.graphics.setColor(colors.wall:getColor())
  love.graphics.rectangle('fill', self.body:unpack())
end

function Wall:draw()
  self:drawEdges()
  self:drawInside()
  Entity.draw(self)
end

function Wall:onWhichSide(point)
  local epsilon = 1
  local middles = {
    left = (self.body.pos + Vector2.new(self.body.pos.x, self.body.pos.y + self.body.size.y)) / 2,
    right = (Vector2.new(self.body.pos.x + self.body.size.x, self.body.pos.y) + self.body.size + self.body.pos) / 2,
    top = (self.body.pos + Vector2.new(self.body.pos.x + self.body.size.x, self.body.pos.y)) / 2,
    bottom = (self.body.pos + self.body.size + Vector2.new(self.body.pos.x, self.body.pos.y + self.body.size.y)) / 2
  }
  local closest = { side = 'none', distance = 9999999 }
  for k, v in pairs(middles) do
    local dist = point:dist(v)

    print(k, v, dist)

    if dist < closest.distance then
      closest.side, closest.distance = k, dist
    end
  end
  return closest
end

function Wall:direction()
  local ax, ay = math.abs(self.body.size.x), math.abs(self.body.size.y)
  return ax > ay and 'Horizontal' or 'Vertical'
end

WallComposite = class('WallComposite', Wall)

function WallComposite:initialize(x, y, sx, sy, buildWalls)
  Entity.initialize(self)

  self.buildWalls = buildWalls
  self.walls = {buildWalls()}
end

function WallComposite:drawEdges()
  love.graphics.setColor(colors.wallEdge:getColor())
  for _, w in ipairs(self.walls) do
    love.graphics.rectangle('line', w.body.pos.x - 1, w.body.pos.y - 1, w.body.size.x + 1, w.body.size.y + 1)
  end
end

function WallComposite:drawInside()
  love.graphics.setColor(colors.wall:getColor())
  for _, w in ipairs(self.walls) do
    love.graphics.rectangle('fill', w.body:unpack())
  end
end

function WallComposite:refresh()
  self.walls = {self.buildWalls()}
end