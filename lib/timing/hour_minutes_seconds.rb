module Timing
  class HourMinutesSeconds

    HH_MM_SS_REGEX = /^(?<hour>\d{1,2})(:(?<minutes>\d{1,2}))?(:(?<seconds>\d{1,2}))?$/

    attr_reader :hour, :minutes, :seconds

    def initialize(hour, minutes=0, seconds=0)
      raise ArgumentError, "Invalid hour #{hour}" if !hour.is_a?(Integer) || hour < 0 || hour > 23
      raise ArgumentError, "Invalid minutes #{minutes}" if !minutes.is_a?(Integer) || minutes < 0 || minutes > 59
      raise ArgumentError, "Invalid minutes #{seconds}" if !seconds.is_a?(Integer) || seconds < 0 || seconds > 59

      @hour = hour
      @minutes = minutes
      @seconds = seconds
    end

    def iso8601
      [hour, minutes, seconds].map { |d| d.to_s.rjust(2, '0') }.join(':')
    end
    alias_method :to_s, :iso8601
    alias_method :inspect, :iso8601

    def ==(other)
      other.kind_of?(self.class) && hash == other.hash
    end
    alias_method :eql?, :==

    def hash
      [hour, minutes, seconds].hash
    end

    def >(other)
      raise ArgumentError, "Invalid argument #{other}" unless other.is_a?(HourMinutesSeconds)

      (hour > other.hour) ||
      (hour == other.hour && minutes > other.minutes) ||
      (hour == other.hour && minutes == other.minutes && seconds > other.seconds)
    end

    def <(other)
      raise ArgumentError, "Invalid argument #{other}" unless other.is_a?(HourMinutesSeconds)

      (hour < other.hour) ||
      (hour == other.hour && minutes < other.minutes) ||
      (hour == other.hour && minutes == other.minutes && seconds < other.seconds)
    end

    def >=(other)
      self > other || self == other
    end

    def <=(other)
      self < other || self == other
    end

    def <=>(other)
      if self == other
        0
      elsif self > other
        1
      else
        -1
      end
    end

    def between?(from, to)
      self >= from && self <= to
    end
    
    def self.parse(expression)
      match = expression.to_s.match HH_MM_SS_REGEX
      raise ArgumentError, "Invalid expression #{expression}" unless match
      new(*match.names.map { |n| (match[n] || 0).to_i })
    end

  end
end