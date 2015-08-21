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

    class DirectionToDayName < Treetop::Runtime::SyntaxNode
      def evaluate(zone_offset)
        today = TimeInZone.now(zone_offset).beginning_of_day

        if direction.last?
          if today.wday > day_name.wday
            today - Interval.days(today.wday - day_name.wday)
          else
            today - Interval.weeks(1) + Interval.days(day_name.wday - today.wday)
          end
        else
          if today.wday < day_name.wday
            today + Interval.days(day_name.wday - today.wday)
          else
            today + Interval.weeks(1) - Interval.days(today.wday - day_name.wday)
          end
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

    class Direction < Treetop::Runtime::SyntaxNode
      def next?
        text_value == 'next'
      end

      def last?
        text_value == 'last'
      end
    end

    class DayName < Treetop::Runtime::SyntaxNode
      SHORT_NAMES = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
      def wday
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