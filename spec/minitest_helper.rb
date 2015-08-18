require 'coverage_helper'
require 'minitest/autorun'
require 'turn'
require 'pry-nav'
require 'timing'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
  c.ansi = true
end

include Timing