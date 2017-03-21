require 'minitest_helper'

describe Interval do

  let(:random) { (rand * 10).round(1) }
  
  let(:minutes_in_seconds) { 60 }
  let(:hours_in_seconds)   { 60 * 60 }
  let(:days_in_seconds)    { 60 * 60 * 24 }
  let(:weeks_in_seconds)   { 60 * 60 * 24 * 7 }

  def assert_parsed_seconds(expression, expected_seconds)
    Interval.parse(expression).must_equal expected_seconds
  end

  def assert_parsed_to_s(expression, expected_string, biggest_unit=nil, smallest_unit=nil)
    options = {}
    options[:biggest_unit] = biggest_unit if biggest_unit
    options[:smallest_unit] = smallest_unit if smallest_unit
    Interval.parse(expression).to_s(options).must_equal expected_string
  end

  it 'Parsing' do
    assert_parsed_seconds "#{random}s", random
    assert_parsed_seconds "#{random}m", random * minutes_in_seconds
    assert_parsed_seconds "#{random}h", random * hours_in_seconds
    assert_parsed_seconds "#{random}d", random * days_in_seconds
    assert_parsed_seconds "#{random}w", random * weeks_in_seconds

    error = proc { Interval.parse 'xyz' }.must_raise RuntimeError
    error.message.must_equal 'Invalid interval expression xyz'
  end

  it 'Builders' do
    Interval.seconds(random).must_equal random
    Interval.minutes(random).must_equal random * minutes_in_seconds
    Interval.hours(random).must_equal   random * hours_in_seconds
    Interval.days(random).must_equal    random * days_in_seconds
    Interval.weeks(random).must_equal   random * weeks_in_seconds
  end

  it 'Conversions' do
    interval = Interval.new random

    interval.to_seconds.must_equal random
    interval.to_minutes.must_equal random / minutes_in_seconds
    interval.to_hours.must_equal   random / hours_in_seconds
    interval.to_days.must_equal    random / days_in_seconds
    interval.to_weeks.must_equal   random / weeks_in_seconds
  end

  it 'To string' do
    assert_parsed_to_s '30s', '30s'
    assert_parsed_to_s '30s', '30s'
    assert_parsed_to_s '60s', '1m'
    assert_parsed_to_s '80s', '80s'
    assert_parsed_to_s '25m', '25m'
    assert_parsed_to_s '60m', '1h'
    assert_parsed_to_s '73m', '73m'
    assert_parsed_to_s '13h', '13h'
    assert_parsed_to_s '24h', '1d'
    assert_parsed_to_s '32h', '32h'
    assert_parsed_to_s '4d',  '4d'
    assert_parsed_to_s '14d', '2w'
    assert_parsed_to_s '3w',  '3w'
  end

  it 'To multiple units string' do
    assert_parsed_to_s '70s', '70s', 's'
    assert_parsed_to_s '70s', '1m 10s', 'm'
    assert_parsed_to_s '70s', '1m 10s', 'h'
    assert_parsed_to_s '70s', '1m', 'h', 'm'
    assert_parsed_to_s '3666s', '1h 1m 6s', 'h'
    assert_parsed_to_s '3666s', '61m 6s', 'm'
    assert_parsed_to_s '3666s', '1h 1m 6s', 'd'
    assert_parsed_to_s '604800s', '1w', 'w'
    assert_parsed_to_s '1209600s', '2w', 'w'
    assert_parsed_to_s '608400s', '1w 1h', 'w'
    assert_parsed_to_s '1299785s', '2w 1d 1h 3m 5s', 'w'
    assert_parsed_to_s '1299785s', '15d 1h 3m 5s', 'd'
    assert_parsed_to_s '1299785s', '15d 1h 3m', 'd', 'm'
  end

  it 'Inspect' do
    Interval.new(30).inspect.must_equal '30s (30.0)'
    Interval.parse('2m').inspect.must_equal '2m (120.0)'
  end

  it 'Between two times' do
    now = Time.now
    a_minute_ago = now - 60
    two_days_ago = now - (60 * 60 * 24 * 2)

    Interval.between(now, a_minute_ago).must_equal Interval.minutes(1)
    Interval.between(two_days_ago, now).must_equal Interval.days(2)
  end

  describe 'Time limits' do

    def assert_limits(moment, interval_expression, expected_begin, expected_end)
      interval = Interval.parse interval_expression
      time = Time.parse moment
      interval.begin_of(time).must_equal Time.parse(expected_begin)
      interval.end_of(time).must_equal Time.parse(expected_end)
    end

    it 'Minutes' do
      assert_limits '2015-08-10 07:03:16', '30m', '2015-08-10 07:00:00', '2015-08-10 07:29:59'
      assert_limits '2015-08-10 02:11:38', '10m', '2015-08-10 02:10:00', '2015-08-10 02:19:59'
      assert_limits '2015-08-10 00:00:00', '15m', '2015-08-10 00:00:00', '2015-08-10 00:14:59'
      assert_limits '2015-08-10 23:59:59', '20m', '2015-08-10 23:40:00', '2015-08-10 23:59:59'
    end

    it 'Hours' do
      assert_limits '2015-08-10 01:45:21', '3h', '2015-08-10 00:00:00', '2015-08-10 02:59:59'
      assert_limits '2015-08-10 22:52:11', '2h', '2015-08-10 22:00:00', '2015-08-10 23:59:59'
      assert_limits '2015-08-10 04:00:00', '1h', '2015-08-10 04:00:00', '2015-08-10 04:59:59'
      assert_limits '2015-08-10 18:59:59', '1h', '2015-08-10 18:00:00', '2015-08-10 18:59:59'
    end

    it 'Days' do
      assert_limits '2015-08-10 11:51:14', '1d', '2015-08-10 00:00:00', '2015-08-10 23:59:59'
      assert_limits '2015-08-10 08:24:55', '2d', '2015-08-09 00:00:00', '2015-08-10 23:59:59'
    end

  end

end