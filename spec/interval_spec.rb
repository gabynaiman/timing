require 'minitest_helper'

describe Timing::Interval do

  let(:random) { (rand * 10).round(1) }
  
  let(:minutes_in_seconds) { 60 }
  let(:hours_in_seconds)   { 60 * 60 }
  let(:days_in_seconds)    { 60 * 60 * 24 }
  let(:weeks_in_seconds)   { 60 * 60 * 24 * 7 }

  def assert_parsed_seconds(expression, expected_seconds)
    Timing::Interval.parse(expression).must_equal expected_seconds
  end

  def assert_parsed_to_s(expression, expected_string)
    Timing::Interval.parse(expression).to_s.must_equal expected_string
  end

  it 'Parsing' do
    assert_parsed_seconds "#{random}s", random
    assert_parsed_seconds "#{random}m", random * minutes_in_seconds
    assert_parsed_seconds "#{random}h", random * hours_in_seconds
    assert_parsed_seconds "#{random}d", random * days_in_seconds
    assert_parsed_seconds "#{random}w", random * weeks_in_seconds

    error = proc { Timing::Interval.parse 'xyz' }.must_raise RuntimeError
    error.message.must_equal 'Invalid interval expression xyz'
  end

  it 'Builders' do
    Timing::Interval.seconds(random).must_equal random
    Timing::Interval.minutes(random).must_equal random * minutes_in_seconds
    Timing::Interval.hours(random).must_equal   random * hours_in_seconds
    Timing::Interval.days(random).must_equal    random * days_in_seconds
    Timing::Interval.weeks(random).must_equal   random * weeks_in_seconds
  end

  it 'Conversions' do
    interval = Timing::Interval.new random

    interval.to_seconds.must_equal random
    interval.to_minutes.must_equal random / minutes_in_seconds
    interval.to_hours.must_equal   random / hours_in_seconds
    interval.to_days.must_equal    random / days_in_seconds
    interval.to_weeks.must_equal   random / weeks_in_seconds
  end

  it 'To string' do
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

  describe 'Time limits' do

    def assert_next(mode, interval, time, expected)
      Timing::Interval.parse(interval).send("next_#{mode}_of", Timing::TimeWithZone.parse(time)).to_time.must_equal Time.parse(expected)
    end

    it 'Minutes' do
      assert_next :begin, '30m', '2015-08-10 07:03:16', '2015-08-10 07:30:00'
      assert_next :end,   '30m', '2015-08-10 07:03:16', '2015-08-10 07:29:59'

      assert_next :begin, '10m', '2015-08-10 02:11:38', '2015-08-10 02:20:00'
      assert_next :end,   '10m', '2015-08-10 02:11:38', '2015-08-10 02:19:59'

      assert_next :begin, '15m', '2015-08-10 00:00:00', '2015-08-10 00:00:00'
      assert_next :end,   '15m', '2015-08-10 00:00:00', '2015-08-10 00:14:59'

      assert_next :begin, '15m', '2015-08-10 23:59:59', '2015-08-11 00:00:00'
      assert_next :end,   '15m', '2015-08-10 23:59:59', '2015-08-10 23:59:59'
    end

    it 'Hours' do
      assert_next :begin, '3h', '2015-08-10 01:45:21', '2015-08-10 03:00:00'
      assert_next :end,   '3h', '2015-08-10 01:45:21', '2015-08-10 02:59:59'

      assert_next :begin, '2h', '2015-08-10 22:52:11', '2015-08-11 00:00:00'
      assert_next :end,   '2h', '2015-08-10 22:52:11', '2015-08-10 23:59:59'

      assert_next :begin, '1h', '2015-08-10 04:00:00', '2015-08-10 04:00:00'
      assert_next :end,   '1h', '2015-08-10 04:00:00', '2015-08-10 04:59:59'

      assert_next :begin, '1h', '2015-08-10 18:59:59', '2015-08-10 19:00:00'
      assert_next :end,   '1h', '2015-08-10 18:59:59', '2015-08-10 18:59:59'
    end

    it 'Days' do
      assert_next :begin, '1d', '2015-08-10 11:51:14', '2015-08-11 00:00:00'
      assert_next :end,   '1d', '2015-08-10 11:51:14', '2015-08-10 23:59:59'

      assert_next :begin, '7d', '2015-08-10 08:24:55', '2015-08-17 00:00:00'
      assert_next :end,   '7d', '2015-08-10 08:24:55', '2015-08-16 23:59:59'
    end

  end

end