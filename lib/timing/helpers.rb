module Timing
  module Helpers

    TIME_REGEXP = /(\d\d:\d\d:\d\d)/
    TIME_FORMAT = '%F %T %z'

    def beginning_of_day(time)
      TimeInZone.parse time.strftime(TIME_FORMAT).sub(TIME_REGEXP, '00:00:00')
    end

    def end_of_day(time)
      TimeInZone.parse time.strftime(TIME_FORMAT).sub(TIME_REGEXP, '23:59:59')
    end

  end
end