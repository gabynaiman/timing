module Timing
  class Interval < TransparentProxy
    
    UNITS_NAMES = {
      s: :seconds,
      m: :minutes,
      h: :hours,
      d: :days,
      w: :weeks 
    }

    CONVERSIONS = {
      s: 1,
      m: 60,
      h: 60 * 60,
      d: 60 * 60 * 24,
      w: 60 * 60 * 24 * 7
    }

    MULTIPLIER = {
      s: 60,
      m: 60,
      h: 24,
      d: 7,
      w: 1
    }

    UNITS = UNITS_NAMES.map(&:first)

    REGEXP = /^([\d\.]+)([smhdw])$/

    def self.parse(expression)
      match = REGEXP.match expression.strip
      raise "Invalid interval expression #{expression}" unless match
      new match.captures[0].to_f * CONVERSIONS[match.captures[1].to_sym]
    end

    def self.between(time_1, time_2)
      new (time_1 - time_2).round
    end

    def initialize(seconds)
      raise ArgumentError, "#{seconds} is not a number" unless seconds.is_a? Numeric
      super seconds.abs
    end

    CONVERSIONS.each do |unit, factor|
      unit_name = UNITS_NAMES[unit]

      define_method "to_#{unit_name}" do
        to_f / factor
      end

      define_singleton_method unit_name do |number|
        new number * factor
      end
    end

    def begin_of(time)
      normalized_time = time + time.utc_offset
      gap = normalized_time.to_i % self
      normalized_time - gap - time.utc_offset
    end

    def end_of(time)
      begin_of(time) + self - 1
    end

    def to_s
      representations = UNITS.map.with_index do |unit, i|
        representation = to_representation(unit, false, false)
        [representation, "#{representation.to_i}#{unit}"]
      end
      pair = representations.reverse.detect{ |value,representation| value == value.to_i }
      pair && pair[1] || "#{to_seconds}s"
    end

    def to_human(options={})
      biggest_unit = options.fetch(:biggest_unit, :w)
      smallest_unit = options.fetch(:smallest_unit, :s)
      last_index = UNITS.index(biggest_unit.to_sym)
      first_index = UNITS.index(smallest_unit.to_sym)
      units = UNITS[first_index..last_index]
      representations = units.map.with_index do |unit, i|
        acumulate = (i != last_index - first_index)
        representation = to_representation(unit, acumulate)
        [representation, "#{representation}#{unit}"]
      end
      representations.select{ |(value, string)| value > 0 }.map(&:last).reverse.join(' ')
    end

    def inspect
      "#{to_s} (#{to_seconds})"
    end

    protected

    def to_representation(unit, acumulate=false, truncate=true)
      value = to_f / CONVERSIONS[unit]
      value = value % MULTIPLIER[unit] if acumulate
      truncate ? value.truncate : value
    end

  end
end