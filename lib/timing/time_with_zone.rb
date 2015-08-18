module Timing
  class TimeWithZone

    extend Forwardable

    REGEXP = /[+-]\d\d:?\d\d/

    def_delegators :time, :to_i, :to_f, :<, :<=, :==, :>, :>=, :between?, :eql?, :hash
    def_delegators :time_with_offset, :year, :month, :day, :hour, :min, :sec

    attr_reader :zone_offset
    
    def initialize(time, zone_offset=nil)
      @time = time
      @zone_offset = build_zone_offset(zone_offset || time.utc_offset)
    end

    def zone_offset=(zone_offset)
      @zone_offset = build_zone_offset zone_offset
    end

    def +(seconds)
      self.class.new (time + seconds), zone_offset
    end

    def -(seconds)
      self.class.new (time - seconds), zone_offset
    end

    def utc?
      zone_offset == 0
    end

    def to_utc
      self.class.new time, 0
    end

    def to_zone(zone_offset)
      self.class.new time, zone_offset
    end

    def to_time
      time
    end

    def to_s
      strftime '%F %T %z'
    end
    alias_method :inspect, :to_s

    def strftime(format)
      time_with_offset.strftime format.gsub('%Z', '').gsub('%z', zone_offset.to_s)
    end

    def self.now(zone_offset=nil)
      new Time.now, zone_offset
    end

    def self.at(seconds, zone_offset=nil)
      new Time.at(seconds), zone_offset
    end

    def self.parse(text)
      match = REGEXP.match text
      zone_offset = match ? match.to_s : nil
      new Time.parse(text), zone_offset
    end

    private

    attr_reader :time

    def build_zone_offset(zone_offset)
      case zone_offset
        when ZoneOffset then zone_offset
        when String then ZoneOffset.parse(zone_offset)
        when Numeric then ZoneOffset.new(zone_offset)
        else raise ArgumentError, "Invalid zone offset #{zone_offset}"
      end
    end

    def time_with_offset
      time.getutc + zone_offset
    end

  end
end