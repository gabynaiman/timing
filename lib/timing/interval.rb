module Timing
  class Interval < SimpleDelegator
    
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

    REGEXP = /^([\d\.]+)([smhdw])$/

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

    # def next_begin_of(time)
    #   previous_begin_of(time) + self
    # end

    # def previous_begin_of(time)
    #   normalized_time = time + time.utc_offset
    #   gap = normalized_time.to_i % self
    #   normalized_time - gap - time.utc_offset
    # end

    # def next_end_of(time)
    #   previous_end_of(time) + self
    # end

    # def previous_end_of(time)
    #   previous_begin_of(time) - 1
    # end

    def to_s
      integer = CONVERSIONS.map { |u,f| [to_f / f, "#{to_i / f}#{u}"] }
                           .sort_by { |v,t| v }
                           .detect { |v,t| v == v.to_i }
      integer ? integer[1] : "#{to_seconds}s"
    end

    def inspect
      "#{to_s} (#{to_seconds}s)"
    end

    def self.parse(expression)
      match = REGEXP.match expression.strip
      raise "Invalid interval expression #{expression}" unless match
      new match.captures[0].to_f * CONVERSIONS[match.captures[1].to_sym]
    end

    def self.between(time_1, time_2)
      new (time_1 - time_2).round
    end

  end
end