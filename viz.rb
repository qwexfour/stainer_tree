#!/usr/bin/ruby

require "rexml/document"
require "test/unit"
include Test::Unit::Assertions
require_relative "point"

class Grid
    def initialize
        @pins = Array.new
        @pins_m2 = Array.new
        @m2_m3 = Array.new
        @m2 = Array.new
        @m3 = Array.new
    end
    def getxml(filename)
        File.open(filename) do |file|
            _xml = REXML::Document.new(file)
            _root = _xml.root
            _grid = _root.elements["grid"]
            @rows = _grid.attributes["max_y"].to_i - _grid.attributes["min_y"].to_i
            @columns = _grid.attributes["max_x"].to_i - _grid.attributes["min_x"].to_i
            _xml.elements.each("root/net/point") do |element|
                if element.attributes["layer"] == "pins"
                    @pins.push(Point.new(element.attributes["x"].to_i, element.attributes["y"].to_i))
                elsif element.attributes["layer"] == "pins_m2"
                    @pins_m2.push(Point.new(element.attributes["x"].to_i, element.attributes["y"].to_i))
                elsif element.attributes["layer"] == "m2_m3"
                    @m2_m3.push(Point.new(element.attributes["x"].to_i, element.attributes["y"].to_i))
                else
                    abort("Unsupported layer")
                end
            end
            _xml.elements.each("root/net/segment") do |seg|
                if seg.attributes["layer"] == "m2"
                    assert(seg.attributes["y1"] == seg.attributes["y2"], "m2 is for horizontal segments")
                    @m2.push(HorLine.new(seg.attributes["x1"].to_i, seg.attributes["x2"].to_i, seg.attributes["y1"].to_i))
                elsif seg.attributes["layer"] == "m3"
                    assert(seg.attributes["x1"] == seg.attributes["x2"], "m2 is for vertical segments")
                    @m3.push(VerLine.new(seg.attributes["x1"].to_i, seg.attributes["y1"].to_i, seg.attributes["y2"].to_i))
                else
                    abort("Unsupported layer")
                end
            end
        end
    end
    def dump
        puts "[#{@rows}x#{@columns}]"
        puts "pins:"
        print_point @pins
        puts "pins_m2:"
        print_point @pins_m2
        puts "m2_m3:"
        print_point @m2_m3
        puts "m2:"
        print_seg @m2
        puts "m3:"
        print_seg @m3
    end
    def print_point(arr)
        _mtx = Array.new(@rows) { |e| e = Array.new(@columns, ".") }
        arr.each do |point|
            _mtx[point.x][point.y] = "@"
        end
        hor_idx()
        _idx = 0
        _mtx.each do |row|
            row.each do |e|
                print e
            end
            puts _idx
            _idx += 1
        end
    end
    def print_seg(arr)
        _mtx = Array.new(@rows) { |e| e = Array.new(@columns, ".") }
        if arr.first.is_a?(HorLine)
            arr.each do |seg|
                for x in seg.x1..seg.x2
                    _mtx[x][seg.y] = "@"
                end
            end
        elsif arr.first.is_a?(VerLine)
            arr.each do |seg|
                for y in seg.y1..seg.y2
                    _mtx[seg.x][y] = "@"
                end
            end
        else
            abort("Unknown segment type")
        end
        hor_idx()
        _idx = 0
        _mtx.each do |row|
            row.each do |e|
                print e
            end
            print _idx
            _idx += 1
            puts
        end
    end
    def hor_idx
        (0...@columns).each { |e| print e / 10}
        puts
        (0...@columns).each { |e| print e % 10}
        puts
    end
end


if ARGV.length != 1
    abort("Wrong nuber of arguments")
end
grid = Grid.new
grid.getxml(ARGV[0])
grid.dump()
