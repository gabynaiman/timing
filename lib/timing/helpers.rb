module Timing
  module Helpers

    TIME_REGEXP = /(\d\d:\d\d:\d\d)/
    TIME_FORMAT = '%F %T %z'

    MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    def beginning_of_day(time)
      TimeInZone.parse time.strftime(TIME_FORMAT).sub(TIME_REGEXP, '00:00:00')
    end

    def end_of_day(time)
      TimeInZone.parse time.strftime(TIME_FORMAT).sub(TIME_REGEXP, '23:59:59')
    end

    def beginning_of_month(time)
      TimeInZone.parse time.strftime '%Y-%m-01 00:00:00 %z'
    end

    def end_of_month(time)
      day = days_in_month(time.year, time.month)
      TimeInZone.parse time.strftime "%Y-%m-#{day} 23:59:59 %z"
    end

    def beginning_of_year(time)
      TimeInZone.parse time.strftime '%Y-01-01 00:00:00 %z'
    end

    def end_of_year(time)
      TimeInZone.parse time.strftime '%Y-12-31 23:59:59 %z'
    end

    def days_in_month(year, month)
      return 29 if month == 2 && Date.leap?(year)

      MONTH_DAYS[month-1]
    end

  end
end