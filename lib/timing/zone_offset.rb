module Timing
  class ZoneOffset < TransparentProxy

    REGEXP = /^([+-]?)(\d\d):?(\d\d)$/

    def initialize(seconds)
      raise ArgumentError, "#{seconds} is not a number" unless seconds.is_a? Numeric
      super
    end

    def to_s
      "#{sign}#{hour.to_s.rjust(2, '0')}#{minute.to_s.rjust(2, '0')}"
    end

    def iso8601
      "#{sign}#{hour.to_s.rjust(2, '0')}:#{minute.to_s.rjust(2, '0')}"
    end

    def inspect
      "#{to_s} (#{to_f})"
    end

    def self.parse(expression)
      match = REGEXP.match expression.strip

      raise ArgumentError, "Invalid time zone offset #{expression}" unless match

      sign = match.captures[0] == '-' ? -1 : 1
      hours = match.captures[1].to_i
      minutes = match.captures[2].to_i

      new (Interval.hours(hours) + Interval.minutes(minutes)) * sign
    end

    private

    def hour
      Interval.new(to_f).to_hours.to_i
    end

    def minute
      Interval.new(to_f % Interval.hours(1)).to_minutes.to_i
    end

    def sign
      self < 0 ? '-' : '+'
    end

  end
end