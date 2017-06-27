colors = colors or {}
COLORS = {}
COLORS.new = function(r, g, b, a)
  return lue:newColor():setColor({r, g, b, a or 255})
end
COLORS.feel = {
  white     = COLORS.new(255, 255, 255),
  darkGray  = COLORS.new(18, 20, 23),
  gray      = COLORS.new(31, 32, 34),
  darkBlue  = COLORS.new(0, 49, 77),
  pink      = COLORS.new(236, 0, 140),
  red       = lue:newColor():setColor({hue = {210, 108, 255, 4}}), -- COLORS.new(196, 31, 19),
  blueGray  = COLORS.new(20, 22, 25),
  lightGreen= COLORS.new(134, 238, 60),
  green     = COLORS.new(102, 255, 188),
  yellow    = COLORS.new(255, 252, 96),
  lightBlue = COLORS.new(121, 205, 255),
  orange    = COLORS.new(255, 166, 82),
  black     = COLORS.new(10, 13, 17)
}

do
  local roller = function(color, speed, parameter, min, max, direction)
    return function(dt)
      local s = color[parameter]
      if s > max and direction == 1 then 
        direction = -1 
      elseif s < min and direction == -1 then 
        direction = 1 
      end
      s = s + dt * speed * direction
      color[parameter] = s
    end
  end

  local rollRed = roller(COLORS.feel.red.hue, 35, 2, 68, 153, 1)

  COLORS.roll = function(dt)
    rollRed(dt)
  end
end