#!/usr/bin/ruby

require "rexml/document"
require_relative "point"

class Grid
    attr_reader :rows, :columns, :pins
    def initialize
        @pins = Array.new
    end
    def getxml(filename)
        File.open(filename) do |file|
            _xml = REXML::Document.new(file)
            _root = _xml.root
            _grid = _root.elements["grid"]
            @rows = _grid.attributes["max_y"].to_i - _grid.attributes["min_y"].to_i
            @columns = _grid.attributes["max_x"].to_i - _grid.attributes["min_x"].to_i
            _net = _root.elements["net"]
            _net.children.each { |pin|
                @pins.push(Point.new(pin.attributes["x"].to_i, pin.attributes["y"].to_i))
            }
        end
    end
    def dump
        puts "[#{@rows}x#{@columns}]"
        puts @pins
    end
end

class Steiner
    def initialize(grid)
        @rows = grid.rows
        @columns = grid.columns
        @pins = grid.pins
    end
    def get_steiner_points
        _xes = @pins.map { |e| e.x }
        _yes = @pins.map { |e| e.y }
        _xes.uniq!
        _yes.uniq!
        _points = _xes.product(_yes)
        _points.map! { |x, y| Point.new(x, y) }
        return _points - @pins
    end
    def mst (points = @pins)
        # getting and sorting edges
        _edges = points.combination(2).to_a
        _edges.map! { |f, t| Line.new(f, t) }
        _edges.sort!
        #groups of same colour a.k. hash:point => group of points of same colour
        _groups = Hash[ points.map { |point| [ point, [point]] } ]
        _mst = Array.new
        _edges.each do |edge|
            if _groups[edge.from] != _groups[edge.to]
                _mst.push(edge)
                # paint to one colour
                _both = _groups[edge.from] + _groups[edge.to]
                _groups[edge.from].each { |e| _groups[e] = _both }
                _groups[edge.to].each   { |e| _groups[e] = _both }
            end
        end
        return _mst
    end
end

grid = Grid.new
grid.getxml("my.xml")
grid.dump()
puts "Steiner points"
steiner = Steiner.new(grid)
puts steiner.get_steiner_points
puts "MST"
puts steiner.mst
