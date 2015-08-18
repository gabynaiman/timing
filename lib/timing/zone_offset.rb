module Timing
  class ZoneOffset < SimpleDelegator

    REGEXP = /^([+-]?)(\d\d):?(\d\d)$/

    def initialize(seconds)
      raise ArgumentError, "#{seconds} is not a number" unless seconds.is_a? Numeric
      super
    end

    def to_s
      hours = Interval.new(to_f).to_hours.to_i
      minutes = Interval.new(to_f % Interval.hours(1)).to_minutes.to_i
      sign = self < 0 ? '-' : '+'

      "#{sign}#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}"
    end

    def inspect
      "#{to_s} (#{to_f})"
    end

    def self.parse(expression)
      match = REGEXP.match expression.strip

      raise "Invalid time zone offset #{expression}" unless match

      sign = match.captures[0] == '-' ? -1 : 1
      hours = match.captures[1].to_i
      minutes = match.captures[2].to_i

      new (Interval.hours(hours) + Interval.minutes(minutes)) * sign
    end

  end
end