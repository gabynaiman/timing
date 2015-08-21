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


class Time
  class << self
    alias_method :__now__, :now
    alias_method :__new__, :new

    def new(*args)
      args.empty? ? now : __new__(*args)
    end

    def now
      @now || __now__
    end

    def now=(time)
      @now = time
    end
  end
end