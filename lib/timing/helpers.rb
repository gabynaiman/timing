module Timing
  module Helpers

    MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    def beginning_of_day(time)
      TimeInZone.parse time.strftime('%Y-%m-%d 00:00:00 %z')
    end

    def end_of_day(time)
      TimeInZone.parse time.strftime('%Y-%m-%d 23:59:59 %z')
    end

    def beginning_of_month(time)
      TimeInZone.parse time.strftime('%Y-%m-01 00:00:00 %z')
    end

    def end_of_month(time)
      TimeInZone.parse time.strftime("%Y-%m-#{days_in_month(time.month, time.year)} 23:59:59 %z")
    end

    def beginning_of_year(time)
      TimeInZone.parse time.strftime('%Y-01-01 00:00:00 %z')
    end

    def end_of_year(time)
      TimeInZone.parse time.strftime('%Y-12-31 23:59:59 %z')
    end

    def days_in_month(month, year=nil)
      return 29 if month == 2 && Date.leap?(year || TimeInZone.now.year)
      MONTH_DAYS[month-1]
    end

  end
end