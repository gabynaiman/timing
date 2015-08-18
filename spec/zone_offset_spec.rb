require 'minitest_helper'

describe Timing::ZoneOffset do
  
  def assert_parsed_hours(expression, expected_seconds)
    Timing::ZoneOffset.parse(expression).must_equal expected_seconds * (60 * 60)
  end

  def assert_to_string(offset_hours, expected_text)
    Timing::ZoneOffset.new(offset_hours * (60 * 60)).to_s.must_equal expected_text
  end

  it 'Parsing' do
    assert_parsed_hours '-03:00', -3.0
    assert_parsed_hours '+05:00',  5.0
    assert_parsed_hours '+04:30',  4.5
    assert_parsed_hours '0230',    2.5
    assert_parsed_hours '-0600',  -6.0

    error = proc { Timing::ZoneOffset.parse 'xyz' }.must_raise RuntimeError
    error.message.must_equal 'Invalid time zone offset xyz'
  end

  it 'To string' do
    assert_to_string -1.0, '-01:00'
    assert_to_string  6.0, '+06:00'
    assert_to_string  3.5, '+03:30'
    assert_to_string -2.5, '-02:30'
    assert_to_string  0.0, '+00:00'
  end

end