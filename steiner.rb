#!/usr/bin/ruby

require "rexml/document"
require_relative "point"

class Grid
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
                @pins.push(Point.new(pin.attributes["x"], pin.attributes["y"]))
            }
        end
    end
    def dump
        puts "[#{@rows}x#{@columns}]"
        puts @pins
    end
end



grid = Grid.new
grid.getxml("my.xml")
grid.dump()
