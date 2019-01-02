

class Point
    attr_accessor :x, :y
    def initialize (x, y)
        @x = x
        @y = y
    end
    def to_s
        return "(#{@x}, #{@y})"
    end
end
