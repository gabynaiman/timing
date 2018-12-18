require 'minitest_helper'

describe ZoneOffset do
  
  def assert_parsed_hours(expression, expected_hours)
    ZoneOffset.parse(expression).must_equal expected_hours * (60 * 60)
  end

  def assert_to_string(offset_hours, expected_text)
    ZoneOffset.new(offset_hours * (60 * 60)).to_s.must_equal expected_text
  end

  def assert_iso8601(offset_hours, expected_text)
    ZoneOffset.new(offset_hours * (60 * 60)).iso8601.must_equal expected_text
  end

  it 'Parsing' do
    assert_parsed_hours '-03:00', -3.0
    assert_parsed_hours '+05:00',  5.0
    assert_parsed_hours '+04:30',  4.5
    assert_parsed_hours '0230',    2.5
    assert_parsed_hours '-0600',  -6.0

    error = proc { ZoneOffset.parse 'xyz' }.must_raise ArgumentError
    error.message.must_equal 'Invalid time zone offset xyz'
  end

  it 'To string' do
    assert_to_string -1.0, '-0100'
    assert_to_string  6.0, '+0600'
    assert_to_string  3.5, '+0330'
    assert_to_string -2.5, '-0230'
    assert_to_string  0.0, '+0000'
  end

  it 'ISO 8601' do
    assert_iso8601 -1.0, '-01:00'
    assert_iso8601  6.0, '+06:00'
    assert_iso8601  3.5, '+03:30'
    assert_iso8601 -2.5, '-02:30'
    assert_iso8601  0.0, '+00:00'
  end

  it 'Inspect' do
    ZoneOffset.parse('-03:00').inspect.must_equal '-0300 (-10800.0)'
    ZoneOffset.parse('+07:00').inspect.must_equal '+0700 (25200.0)'
    ZoneOffset.parse('+00:00').inspect.must_equal '+0000 (0.0)'
  end

end