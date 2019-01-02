#!/usr/bin/ruby

require 'matrix'
require 'rexml/document'
require_relative 'point'

class Generator
    def initialize(rows, columns, num_pins = (rows + columns) / 4)
        @rows = rows
        @columns = columns
        @num_pins = num_pins
        @rand = Random.new
        @mtx = Array.new(rows) { |e| e = Array.new(columns, 0) }
        @pins = Array.new
    end

    def dump
        puts "[#{@rows}x#{@columns}]"
        @mtx.each do |row|
            row.each do |e|
                print e
            end
            puts
        end
        puts @pins
    end
    def refill
        @mtx = Array.new(@rows) { |e| e = Array.new(@columns, 0)}
        for i in 1..@num_pins
            begin
                _row = @rand.rand(@rows)
                _column = @rand.rand(@columns)
            end while @mtx[_row][_column] == 1
            @mtx[_row][_column] = 1
            @pins.push(Point.new(_row, _column))
        end
    end
    def putxml(filename)
        _xml = REXML::Document.new
        _root = _xml.add_element("root")
        _root.add_element("grid", {"min_x" => 0, "max_x" => @columns, "min_y" => 0, "max_y" => @rows })
        _net = _root.add_element("net")
        @pins.each do |pin|
            _net.add_element("point", {"layer" => "pins", "type" => "pin", "x" => pin.x, "y" => pin.y})
        end
        File.open(filename, "w") do |file|
            file.puts _xml
        end
    end
end

if ARGV.length < 2
    puts "no matrix size were provided"
else
    if ARGV.length > 2
        gen = Generator.new(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i)
    else
        gen = Generator.new(ARGV[0].to_i, ARGV[1].to_i)
    end
    gen.refill
    #gen.dump
    gen.putxml("my.xml")
end
