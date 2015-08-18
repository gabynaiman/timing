module Timing
  module Helpers

    TIME_REGEXP = /(\d\d:\d\d:\d\d)/

    def beginning_of_day(time)
      TimeWithZone.parse time.to_s.sub(TIME_REGEXP, '00:00:00')
    end

    def end_of_day(time)
      TimeWithZone.parse time.to_s.sub(TIME_REGEXP, '23:59:59')
    end

  end
end