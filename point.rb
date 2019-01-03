

class Point
    attr_accessor :x, :y
    def initialize (x, y)
        @x = x
        @y = y
    end
    def to_s
        return "(#{@x}, #{@y})"
    end
    def == (other)
        return @x == other.x && @y == other.y
    end
    def eql? (other)
        return self == other
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

class Line
    attr_reader :from, :to
    def initialize(from, to)
        @from = from
        @to = to
    end
    def to_s
        return "#{@from} - #{@to}"
    end
    def ==(other)
        return (@from == other.from && @to == other.to) ||
               (@from == other.to && @to == other.from)
    end
    def eql?(other)
        return self == other
    end
    def length
        return Math.sqrt((to.x - from.x)**2 + (to.y - from.y)**2)
    end
    def <=>(other)
        return self.length <=> other.length
    end
end
