require 'minitest_helper'

describe HourMinutesSeconds do

  def assert_parsed(expression, expected_hour, expected_minutes, expected_seconds)
    hhmmss = HourMinutesSeconds.parse expression
    hhmmss.hour.must_equal expected_hour
    hhmmss.minutes.must_equal expected_minutes
    hhmmss.seconds.must_equal expected_seconds
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

  describe 'Serialization' do

    [:to_s, :iso8601, :inspect].each do |method|
      it method do
        HourMinutesSeconds.new(10, 15, 43).public_send(method).must_equal '10:15:43'
        HourMinutesSeconds.new(20, 32    ).public_send(method).must_equal '20:32:00'
        HourMinutesSeconds.new(8         ).public_send(method).must_equal '08:00:00'
      end
    end

  end

  describe 'Comparison' do

    let(:hms) { HourMinutesSeconds.parse '20:31:42' }

    [:==, :eql?].each do |method|
      it method do
        assert HourMinutesSeconds.parse('22:30:45').public_send method, HourMinutesSeconds.parse('22:30:45')
        assert HourMinutesSeconds.parse('22:30'   ).public_send method, HourMinutesSeconds.parse('22:30:00')
        assert HourMinutesSeconds.parse('22'      ).public_send method, HourMinutesSeconds.parse('22:00:00')
        assert HourMinutesSeconds.new(14, 25, 57  ).public_send method, HourMinutesSeconds.parse('14:25:57')

        refute HourMinutesSeconds.parse('22:30:45').public_send method, HourMinutesSeconds.parse('20:03:34')
        refute HourMinutesSeconds.new(14, 25, 57  ).public_send method, HourMinutesSeconds.parse('16:30:42')
      end
    end

    it '>' do
      assert hms > HourMinutesSeconds.parse('20:31:19')
      assert hms > HourMinutesSeconds.parse('20:15:42')
      assert hms > HourMinutesSeconds.parse('18:20:36')

      refute hms > hms
      refute hms > HourMinutesSeconds.parse('20:31:55')
      refute hms > HourMinutesSeconds.parse('20:44:37')
      refute hms > HourMinutesSeconds.parse('21:20:36')
    end

    it '>=' do
      assert hms >= HourMinutesSeconds.parse('19:25:33')
      assert hms >= hms

      refute hms >= HourMinutesSeconds.parse('23:30:22')
    end
    
    it '<' do
      assert hms < HourMinutesSeconds.parse('20:31:55')
      assert hms < HourMinutesSeconds.parse('20:44:37')
      assert hms < HourMinutesSeconds.parse('21:20:36')

      refute hms < hms
      refute hms < HourMinutesSeconds.parse('20:31:19')
      refute hms < HourMinutesSeconds.parse('20:15:42')
      refute hms < HourMinutesSeconds.parse('18:20:36')
    end
    
    it '<=' do
      assert hms <= HourMinutesSeconds.parse('21:25:33')
      assert hms <= hms

      refute hms <= HourMinutesSeconds.parse('19:30:22')
    end
    
    it '<=>' do
      hms_1 = HourMinutesSeconds.new 13, 24, 52
      hms_2 = HourMinutesSeconds.new 15, 42, 33

      assert_equal -1, hms_1 <=> hms_2
      assert_equal -1, hms_1 <=> hms_2

      assert_equal 0, hms_1 <=> hms_1
      assert_equal 0, hms_1 <=> hms_1

      assert_equal 1, hms_2 <=> hms_1
      assert_equal 1, hms_2 <=> hms_1
    end

    it 'Between' do
      assert hms.between?(HourMinutesSeconds.new(19), HourMinutesSeconds.new(23))
      refute hms.between?(HourMinutesSeconds.new(8), HourMinutesSeconds.new(14))
    end

  end

end