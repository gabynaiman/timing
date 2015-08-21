module Timing
  module NaturalTimeLanguage

    class << self

      def parse(expression)
        parsed_expression = parser.parse expression
        raise parser.failure_reason unless parsed_expression
        parsed_expression.evaluate
      end

      private

      def parser
        @parser ||= NaturalTimeLanguageParser.new
      end

    end

    class Expression < Treetop::Runtime::SyntaxNode
      def evaluate
        moment.evaluate zone_offset.empty? ? nil : zone_offset.value
      end
    end

    class Now < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        TimeInZone.now zone_offset
      end
    end

    class Today < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        TimeInZone.now(zone_offset).beginning_of_day
      end
    end

    class Yesterday < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        TimeInZone.now(zone_offset).beginning_of_day - Interval.days(1)
      end
    end

    class Tomorrow < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        TimeInZone.now(zone_offset).beginning_of_day + Interval.days(1)
      end
    end

    class LastNextDayName < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        today = TimeInZone.now(zone_offset).beginning_of_day

        if direction.last?
          if today.wday > day_name.value
            today - Interval.days(today.wday - day_name.value)
          else
            today - Interval.weeks(1) + Interval.days(day_name.value - today.wday)
          end
        else
          if today.wday < day_name.value
            today + Interval.days(day_name.value - today.wday)
          else
            today + Interval.weeks(1) - Interval.days(today.wday - day_name.value)
          end
        end
      end
    end

    class BeginningEndDateInterval < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        now = TimeInZone.now zone_offset
        if direction.beginning?
          interval_type.beginning_of now
        else
          interval_type.end_of now
        end
      end
    end

    class DayMonthNameYear < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        now = TimeInZone.now zone_offset
        yyyy = year.empty? ? now.year : year.value
        mm = month.value.to_s.rjust(2, '0')
        dd = day.value.to_s.rjust(2, '0')
        TimeInZone.parse "#{yyyy}-#{mm}-#{dd} 00:00:00 #{now.zone_offset}"
      end
    end

    class YearMonthDay < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        yyyy = year.value
        mm = month.value.to_s.rjust(2, '0')
        dd = day.value.to_s.rjust(2, '0')
        TimeInZone.parse "#{yyyy}-#{mm}-#{dd} 00:00:00 #{zone_offset}"
      end
    end

    class BeginningEnd < Treetop::Runtime::SyntaxNode
      def beginning?
        direction.text_value.downcase == 'beginning'
      end

      def end?
        direction.text_value.downcase == 'end'
      end
    end

    class LastNext < Treetop::Runtime::SyntaxNode
      def last?
        text_value.downcase == 'last'
      end

      def next?
        text_value.downcase == 'next'
      end
    end

    class DayInterval < Treetop::Runtime::SyntaxNode
      def beginning_of(time)
        time.beginning_of_day
      end

      def end_of(time)
        time.end_of_day
      end
    end

    class WeekInterval < Treetop::Runtime::SyntaxNode
      def beginning_of(time)
        time.beginning_of_week
      end

      def end_of(time)
        time.end_of_week
      end
    end

    class MonthInterval < Treetop::Runtime::SyntaxNode
      def beginning_of(time)
        time.beginning_of_month
      end

      def end_of(time)
        time.end_of_month
      end
    end

    class YearInterval < Treetop::Runtime::SyntaxNode
      def beginning_of(time)
        time.beginning_of_year
      end

      def end_of(time)
        time.end_of_year
      end
    end    

    class DayName < Treetop::Runtime::SyntaxNode
      SHORT_NAMES = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      def value
        SHORT_NAMES.index text_value[0..2].downcase
      end
    end

    class MonthName < Treetop::Runtime::SyntaxNode
      SHORT_NAMES = ['', 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
      def value
        SHORT_NAMES.index text_value[0..2].downcase
      end
    end

    class ZoneOffset < Treetop::Runtime::SyntaxNode
      def value
        ::ZoneOffset.parse text_value
      end
    end

    class Int < Treetop::Runtime::SyntaxNode
      def value
        text_value.to_i
      end
    end

  end
end