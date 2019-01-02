

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

class VerLine
    attr_reader :x, :y1, :y2
    def initialize (x, y1, y2)
        @x = x
        if y1 < y2
            @y1, @y2 = y1, y2
        else
            @y1, @y2 = y2, y1
        end
    end
end

class HorLine
    attr_reader :x1, :x2, :y
    def initialize (x1, x2, y)
        @y = y
        if x1 < x2
            @x1, @x2 = x1, x2
        else
            @x1, @x2 = x2, x1
        end
    end
end
