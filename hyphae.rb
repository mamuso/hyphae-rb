require 'rubygems'
require 'cairo'
require 'numo/narray'
require 'distribution'
# require ''

# Configuration
NMAX = 2*1e7
SIZE = 10000
ONE = 1.00/SIZE

RAD = 40*ONE # CHECK  
ZONEWIDTH = 2.00*(RAD/ONE)
ZONES = (SIZE/ZONEWIDTH).to_i

# BACK = 1.
# FRONT = 0.
# MID = 0.5

# X_MIN = 0.+10.*ONE # border
# Y_MIN = 0.+10.*ONE #
# X_MAX = 1.-10.*ONE #
# Y_MAX = 1.-10.*ONE #

# filename = 'generations_a'
# DRAW_SKIP = 10000 # write image this often

RAD_SCALE = 0.92 # CHECK
SEARCH_ANGLE_MAX = Math::PI

# R_RAND_SIZE = 6
CK_MAX = 15 # max number of allowed branch attempts from a node

CIRCLE_RADIUS = 0.45

SOURCE_NUM = 9

# ALPHA = 0.09
# GRAINS = 10

INIT_CIRCLE = 0.45


class Hyphae
  attr_writer :surface
  attr_writer :context

  def initialize (size)
    # Cairo
    surface = Cairo::ImageSurface.new(:argb32, size, size)
    context = Cairo::Context.new(surface)
    context.scale(size, size)
    context.set_source_rgb(1,1,1) # parametrize?
    context.rectangle(0,0,1,1)
    context.fill()

    self.surface = surface
    self.context = context
  end

  def get_z(x,y)
    i = 1 + (x*ZONES).to_i 
    j = 1 + (y*ZONES).to_i
    z = i * ZONES + j
    return z
  end 

  def generate
    cz = []
    ((ZONES+2)**2).times { cz << [] }

    cr = Numo::DFloat.zeros(NMAX)
    cx = Numo::DFloat.zeros(NMAX)
    cy = Numo::DFloat.zeros(NMAX)
    cthe = Numo::DFloat.zeros(NMAX) # CHECK
    cge = Numo::DFloat.zeros(NMAX) # CHECK
    cp = Numo::DFloat.zeros(NMAX) # PARENT
    cc = Numo::DFloat.zeros(NMAX) # CHECK
    cd = Numo::DFloat.zeros(NMAX).fill(-1)

    ## number of nodes
    i = 0

    ## initialize source nodes
    while i < SOURCE_NUM
      
      ## in circle
      x = rand
      y = rand
      if Math.sqrt( (x-0.5)**2 + (y-0.5)**2 ) < INIT_CIRCLE
        cx[i] = x
        cy[i] = y
        cr[i] = (RAD + 0.2 * RAD * (1 - 2 * rand)) # CHECK
      else
        redo # run the current iteration again
      end

      cthe[i] = rand * Math::PI * 2
      cge[i] = 1
      cp[i] = -1 # NO PARENT
      # cr[i] = RAD
      z = get_z(cx[i], cy[i])
      cz[z].push(i)
      
      i += 1
    end

    num = i
    itt = 0
    ti = Time.now
    drawn = -1


    while true
      begin
        itt += 1
        if itt%1000 == 0
          # puts ("#{itt}, #{num}")
        end
        added_new = false

        k = (rand * num).to_i
        cc[k] += 1
        if cc[k] > CK_MAX
          next
        end

        r = (cd[k] > -1) ? cr[k] * RAD_SCALE : cr[k]
        if r < ONE
          ## node dies
          cc[k] = CK_MAX+1
          next
        end

        ge = (cd[k] > -1) ? cge[k]+1 : cge[k]
        the = cthe[k] + (1 - 1/( (ge+1)**0.1) ) * Distribution::Normal.pdf(rand) * SEARCH_ANGLE_MAX

        x = cx[k] + Math.sin(the)*r
        y = cy[k] + Math.cos(the)*r

        circle_rad = sqrt((x-0.5)**2 + square(y-0.5)**2)
        if circle_rad > CIRCLE_RADIUS:
          ## node is outside circle
          next
        end
      

        num += 1
        added_new = true


      rescue
        redo # run the current iteration again
      end
    end

  end
end

# Paint
paint = Hyphae.new(SIZE)
paint.generate()

