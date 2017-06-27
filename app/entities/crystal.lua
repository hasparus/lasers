class = require 'libs.middleclass.middleclass'
lume = require 'libs.lume.lume'

require 'utils.utils'
require 'components.dynamic_body'
require 'components.body'

Crystal = class('Crystal', Entity)

do
  colors.crystal = COLORS.feel.red
  
  local crystalDestroyedSfx = function()

  end

  function Crystal:initialize(position, size, owner)
    Entity.initialize(self)

    self:attach(DynamicBody:new(position.x, position.y, size.x, size.y))
    self.body.angle = 45
    self.body.angularVelocity = 0.2

    self.owner = owner
    
    self.collider = hc.rectangle(self.body:unpack())
    self.collider.entity = self
  end
  
  function Crystal:update(deltaTime)
    --self:handleCollisions()

    self.collider:moveTo(self.body.pos:unpack())
    self.collider:setRotation(self.body.angle)
    Entity.update(self, deltaTime)
  end

  function Crystal:explode()
    crystalDestroyedSfx()
    game.state.onCrystalDestroyed(self)
    self:destroy()
  end

  function Crystal:getHitByLaser()
    self:explode()
  end
  
  function Crystal:destroy()
    self.collider.entity = nil
    self.collider = nil
    Entity.destroy(self)
  end
  
  function Crystal:draw()
    local drawProper = function()
      local halfsize = self.body.size / 2
      local pos = self.body.pos
      love.graphics.translate(pos:unpack())
      love.graphics.rotate(self.body.angle)
      love.graphics.translate((-halfsize):unpack())
      love.graphics.withColor(
        colors.crystal,
        function()
          love.graphics.rectangle('fill', 0, 0, self.body.size:unpack())
        end
      )
      love.graphics.origin()
    end
    
    drawProper()

  end

end