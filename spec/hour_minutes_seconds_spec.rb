require 'minitest_helper'

describe HourMinutesSeconds do

  def assert_parsed(expression, expected_hour, expected_minutes, expected_seconds)
    hhmmss = HourMinutesSeconds.parse expression
    hhmmss.hour.must_equal expected_hour
    hhmmss.minutes.must_equal expected_minutes
    hhmmss.seconds.must_equal expected_seconds
  end

  def assert_serialized(hour, minutes, seconds, method, expected_value)
    HourMinutesSeconds.new(hour, minutes, seconds).public_send(method).must_equal expected_value
  end

  it 'Initialization' do
    HourMinutesSeconds.new(9, 45, 11).to_s.must_equal  '09:45:11'
    HourMinutesSeconds.new(16, 38).to_s.must_equal     '16:38:00'
    HourMinutesSeconds.new(22).to_s.must_equal         '22:00:00'

    proc { HourMinutesSeconds.new 43        }.must_raise ArgumentError
    proc { HourMinutesSeconds.new 12, 76    }.must_raise ArgumentError
    proc { HourMinutesSeconds.new 9, 23, 98 }.must_raise ArgumentError
    proc { HourMinutesSeconds.new 'xyz'     }.must_raise ArgumentError
  end

  it 'Parsing' do
    assert_parsed '10:23:57', 10, 23, 57
    assert_parsed '09:12'   ,  9, 12,  0
    assert_parsed '1:2:3'   ,  1,  2,  3
    assert_parsed '4'       ,  4,  0,  0
    assert_parsed  8        ,  8,  0,  0

    error = proc { HourMinutesSeconds.parse 'xyz' }.must_raise ArgumentError
    error.message.must_equal 'Invalid expression xyz'
  end

  [:to_s, :iso8601, :inspect].each do |method|
    it "Serialize #{method}" do
      assert_serialized 10, 15, 43, method, '10:15:43'
      assert_serialized 20, 32,  0, method, '20:32:00'
      assert_serialized  8,  0,  0, method, '08:00:00'
    end
  end

end