require 'rubygems'
require 'cairo'
# require ''

# Configuration
SIZE = 1000

class Hyphae
  def initialize (size)

    # Cairo
    surface = Cairo::ImageSurface.new(:argb32, size, size)
    context = Cairo::Context.new(surface)
    context.scale(size, size)
    context.set_source_rgb(1,1,1) # parametrize?
    context.rectangle(0,0,1,1)
    context.fill()

    # surface.write_to_png('test.png')
  end
end

# Paint
paint = Hyphae.new(SIZE)
