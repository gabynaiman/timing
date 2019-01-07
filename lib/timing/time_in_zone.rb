module Timing
  class TimeInZone

    extend Forwardable

    REGEXP = /[+-]\d\d:?\d\d$/

    def_delegators :time, :to_i, :to_f, :to_date, :to_datetime, :between?, :==, :<, :<=, :>, :>=, :<=>, :hash
    def_delegators :time_with_offset, :year, :month, :day, :hour, :min, :sec, :wday, :yday, :sunday?, :monday?, :tuesday?, :wednesday?, :thursday?, :friday?, :saturday?

    attr_reader :zone_offset
    
    def initialize(time, zone_offset=nil)
      @time = time
      @zone_offset = build_zone_offset(zone_offset || time.utc_offset)
    end

    def zone_offset=(zone_offset)
      @zone_offset = build_zone_offset zone_offset
    end

    alias_method :utc_offset, :zone_offset
    alias_method :gmt_offset, :zone_offset
    alias_method :gmtoff,     :zone_offset

    def +(seconds)
      raise ArgumentError, "#{seconds} must be a valid seconds count" unless seconds.is_a? Numeric
      self.class.new (time + seconds), zone_offset
    end

    def -(seconds)
      raise ArgumentError, "#{seconds} must be a time or a valid seconds count" unless seconds.respond_to? :to_f
      result = self.class.at (time.to_f - seconds.to_f), zone_offset
      seconds.is_a?(Numeric) ? result : result.to_f
    end

    alias_method :eql?, :==

    def utc?
      zone_offset == 0
    end
    alias_method :gmt?, :utc?

    def to_utc
      self.class.new time, 0
    end
    alias_method :getutc, :to_utc
    # alias_method :utc, :to_utc

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
      sanitized_format = format.gsub('%Z', '')
                               .gsub('%z', zone_offset.to_s)
                               .gsub('%:z', zone_offset.to_s(':'))
                               .gsub('%::z', "#{zone_offset.to_s(':')}:00")

      time_with_offset.strftime sanitized_format
    end

    def iso8601
      strftime "%FT%T#{zone_offset.iso8601}"
    end

    def as_json(*args)
      iso8601
    end

    def to_json(*args)
      "\"#{as_json(*args)}\""
    end

    %w(hour day week month year).each do |interval|
      beginning_method_name = "beginning_of_#{interval}"
      define_method beginning_method_name do
        Timing.send beginning_method_name, self
      end

      end_method_name = "end_of_#{interval}"
      define_method end_method_name do
        Timing.send end_method_name, self
      end
    end

    def months_ago(count)
      Timing.months_ago self, count
    end

    def months_after(count)
      Timing.months_after self, count
    end

    def years_ago(count)
      Timing.years_ago self, count
    end

    def years_after(count)
      Timing.years_after self, count
    end

    def self.now(zone_offset=nil)
      new Time.now, zone_offset
    end

    def self.at(seconds, zone_offset=nil)
      new Time.at(seconds), zone_offset
    end

    def self.parse(text)
      match = text.length > 10 ? REGEXP.match(text) : nil
      zone_offset = match ? match.to_s : nil
      new Time.parse(text), zone_offset
    end

    private

    attr_reader :time

    def build_zone_offset(zone_offset)
      case zone_offset
        when ZoneOffset then zone_offset
        when Numeric then ZoneOffset.new(zone_offset)
        else ZoneOffset.parse(zone_offset)
      end
    end

    def time_with_offset
      time.getutc + zone_offset
    end

    def method_missing(method, *args, &block)
      time.public_send method, *args, &block
    end

    def respond_to_missing?(method, include_private=false)
      super || time.respond_to?(method)
    end

  end
end