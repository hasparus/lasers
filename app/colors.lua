colors = colors or {}
COLORS = {}
COLORS.new = function(r, g, b, a)
  return lue:newColor():setColor({r, g, b, a or 255})
end
COLORS.feel = {
  darkGray  = COLORS.new(15, 17, 20),
  gray      = COLORS.new(51, 51, 51),
  darkBlue  = COLORS.new(0, 49, 77),
  pink      = COLORS.new(236, 0, 140),
  green     = COLORS.new(102, 255, 188),
  yellow    = COLORS.new(255, 252, 96),
  lightBlue = COLORS.new(121, 205, 255),
  orange    = COLORS.new(255, 166, 82)
}