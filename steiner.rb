#!/usr/bin/ruby

require "rexml/document"
require_relative "point"

class GridReader
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
                if pin.is_a?(REXML::Element)
                    @pins.push(Point.new(pin.attributes["x"].to_i, pin.attributes["y"].to_i))
                end
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
    def weight(edges)
        _sum = 0
        edges.each { |e| _sum += e.length }
        return _sum
    end
    def steiner
        _cur_added_points = Array.new
        _cur_mst = mst(@pins + _cur_added_points)
        _cur_weight = weight(_cur_mst)
        get_steiner_points().each do |steiner_point|
            _new_added_points = _cur_added_points + [steiner_point]
            _new_mst = mst(@pins + _new_added_points)
            _new_weight = weight(_new_mst)
            if _new_weight < _cur_weight
                # hash point => number of outcomming edges
                _cnt_edges = Hash.new(0)
                _new_mst.each do |edge|
                    _cnt_edges[edge.from] += 1
                    _cnt_edges[edge.to] += 1
                end
                # elim points with two outcomming edges
                _to_del = Array.new
                _new_added_points.each do |point|
                    if _cnt_edges[point] <= 2
                        _to_del.push(point)
                    end
                end
                _cur_added_points = _new_added_points - _to_del
            end
        end
        return mst(@pins + _cur_added_points)
    end
end

class GridWriter
    def initialize(grid, tree_edges)
        @rows = grid.rows
        @columns = grid.columns
        @pins = grid.pins
        @tree_edges = tree_edges
        @m2_m3 = Array.new
        @m2 = Array.new
        @m3 = Array.new
    end
    def fill_data
        @tree_edges.each do |edge|
            # horizontal
            if edge.from.y == edge.to.y
                @m2.push(HorLine.new(edge.from.x, edge.to.x, edge.to.y))
            # vertical
            elsif edge.from.x == edge.to.x
                @m3.push(VerLine.new(edge.from.x, edge.from.y, edge.to.y))
                @m2_m3.push(edge.from)
                @m2_m3.push(edge.to)
            # both
            else
                @m2.push(HorLine.new(edge.from.x, edge.to.x, edge.to.y))
                @m3.push(VerLine.new(edge.from.x, edge.from.y, edge.to.y))
                @m2_m3.push(edge.from)
                #@m2_m3.push(edge.to) wrong
                @m2_m3.push(Point.new(edge.from.x, edge.to.y))
            end
            @m2.uniq!
            @m3.uniq!
            @m2_m3.uniq!
        end
        add_degenerate_segments
    end
    def add_degenerate_segments
        @m2_m3.each do |via|
            if !@m2.any? { |seg| seg.from == via || seg.to == via }
                @m2.push(HorLine.new(via.x, via.x, via.y))
            end
        end
    end
    def putxml(filename)
        _xml = REXML::Document.new
        _root = _xml.add_element("root")
        _root.add_element("grid", {"min_x" => 0, "max_x" => @columns, "min_y" => 0, "max_y" => @rows })
        _net = _root.add_element("net")
        @pins.each do |pin|
            _net.add_element("point", {"layer" => "pins", "type" => "pin", "x" => pin.x, "y" => pin.y})
            _net.add_element("point", {"layer" => "pins_m2", "type" => "via", "x" => pin.x, "y" => pin.y})
        end
        @m2_m3.each do |via|
            _net.add_element("point", {"layer" => "m2_m3", "type" => "via", "x" => via.x, "y" => via.y})
        end
        @m2.each do |hor_line|
            _net.add_element("segment", {"layer" => "m2", "x1" => hor_line.x1, "x2" => hor_line.x2,
                                         "y1" => hor_line.y, "y2" => hor_line.y})
        end
        @m3.each do |ver_line|
            _net.add_element("segment", {"layer" => "m3", "x1" => ver_line.x, "x2" => ver_line.x,
                                         "y1" => ver_line.y1, "y2" => ver_line.y2})
        end
        File.open(filename, "w") do |file|
            file.puts _xml
        end
    end
end

if (ARGV.length < 1)
    puts "Please pass input file name as parameter"
    exit
end
filename = ARGV[0]
grid = GridReader.new
grid.getxml(filename)
steiner = Steiner.new(grid)
out = GridWriter.new(grid, steiner.steiner)
out.fill_data
out.putxml(filename.chomp(".xml") + "_out.xml")
