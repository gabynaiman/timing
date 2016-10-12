require 'minitest_helper'

describe TimeInZone do

  let(:time_string) { '2015-08-18 20:17:42 -0300' }
  let(:time_value) { Time.parse(time_string).getlocal }
  let(:local_utc_offset) { time.utc_offset }

  def time
    Time.parse(time_string).getlocal
  end

  def assert_equal_time(actual_time, expected_time)
    actual_time.to_f.must_equal expected_time.to_f
    actual_time.utc_offset.must_equal expected_time.utc_offset
    actual_time.year.must_equal expected_time.year
    actual_time.month.must_equal expected_time.month
    actual_time.day.must_equal expected_time.day
    actual_time.hour.must_equal expected_time.hour
    actual_time.min.must_equal expected_time.min
    actual_time.sec.must_equal expected_time.sec
  end

  describe 'Constructors' do

    describe 'Default zone' do
      
      it 'New' do
        tz = TimeInZone.new time_value
        tz.to_f.must_equal time_value.to_f
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal time_value.hour
      end

      it 'Now' do
        tz = TimeInZone.now
        now = Time.now
        (now.to_f - tz.to_f).must_be :<, 0.01
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal now.hour
      end

      it 'At' do
        tz = TimeInZone.at time_value.to_f
        tz.to_f.must_equal time_value.to_f
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal time_value.hour
      end
      
      it 'Parse date and time' do
        tz = TimeInZone.parse time_value.strftime('%F %T')
        assert_equal_time tz, time_value
      end

      it 'Parse only date' do
        times = ['18/08/2015', '18-08-2015', '2015-08-18']
        times.each do |t|
          tz = TimeInZone.parse t
          time = Time.parse t
          assert_equal_time tz, time
        end
      end

    end

    describe 'With specific zone' do

      it 'New' do
        tz = TimeInZone.new time_value, '+02:00'
        tz.to_f.must_equal time_value.to_f
        tz.utc_offset.must_equal ZoneOffset.parse('+0200')
        tz.day.must_equal 19
        tz.hour.must_equal 1
      end

      it 'Now' do
        tz = TimeInZone.now '-05:00'
        now = Time.now
        (now.to_f - tz.to_f).must_be :<, 0.01
        tz.utc_offset.must_equal ZoneOffset.parse('-0500')
        tz.hour.must_equal (now.getutc - Interval.hours(5)).hour
      end

      it 'At' do
        tz = TimeInZone.at time_value.to_f, '+01:30'
        tz.to_f.must_equal time_value.to_f
        tz.utc_offset.must_equal ZoneOffset.parse('+0130')
        tz.day.must_equal 19
        tz.hour.must_equal 0
        tz.min.must_equal 47
      end

      it 'Parse date and time' do
        one_hour = 60 * 60
        offset = ZoneOffset.new local_utc_offset - one_hour
        tz = TimeInZone.parse time_value.strftime("%F %T #{offset}")
        tz.to_f.must_equal time_value.to_f + one_hour
        tz.utc_offset.must_equal offset
        tz.hour.must_equal time_value.hour
      end

      it 'Invalid zone' do
        error = proc { TimeInZone.new time_value, 'XYZ' }.must_raise ArgumentError
        error.message.must_equal 'Invalid time zone offset XYZ'
      end

    end

  end

  describe 'Conversions' do

    it 'Change zone' do
      tz = TimeInZone.parse time_string
      tz.utc_offset.must_equal ZoneOffset.parse('-0300')
      hour = tz.hour

      tz.zone_offset = ZoneOffset.parse '-0500'
      tz.utc_offset.must_equal ZoneOffset.parse('-0500')
      tz.hour.must_equal hour - 2
    end

    it 'To UTC' do
      tz = TimeInZone.parse time_string
      tz.wont_be :utc?

      utc = tz.to_utc
      utc.must_be :utc?
      utc.hour.must_equal tz.hour + 3
    end

    it 'To zone' do
      tz = TimeInZone.parse time_string
      other = tz.to_zone ZoneOffset.parse('-0200')

      tz.utc_offset.must_equal ZoneOffset.parse('-0300')
      other.utc_offset.must_equal ZoneOffset.parse('-0200')
      other.hour.must_equal tz.hour + 1 
    end

  end

  describe 'Serialization' do

    it 'To string' do
      TimeInZone.new(time_value).to_s.must_equal time_value.to_s
    end

    it 'Formatted' do
      TimeInZone.new(time_value).strftime('%d/%m/%y %H:%M:%S %:z').must_equal time_value.strftime('%d/%m/%y %H:%M:%S %:z')
    end

    it 'ISO 8601' do
      TimeInZone.new(time_value).iso8601.must_equal time_value.iso8601
    end

    it 'As json' do
      TimeInZone.new(time_value).as_json.must_equal time_value.iso8601
    end

    it 'To json' do
      TimeInZone.new(time_value).to_json.must_equal "\"#{time_value.iso8601}\""
    end

  end

  describe 'Math' do

    it '+' do
      tz = TimeInZone.new(time_value) + 15
      tz.must_be_instance_of TimeInZone
      tz.to_f.must_equal time_value.to_f + 15
    end

    it '-' do
      tz = TimeInZone.new(time_value) - 23
      tz.must_be_instance_of TimeInZone
      tz.to_f.must_equal time_value.to_f - 23
    end

    it 'Time - time' do
      diff = TimeInZone.new(time_value) - TimeInZone.new(time_value - 10)
      diff.must_be_kind_of Numeric
      diff.must_equal 10
    end

  end

  describe 'Comparison' do

    it '==' do
      time = '2016-07-18 13:00:00 -0300'

      assert TimeInZone.parse(time) == Time.parse(time)
      assert TimeInZone.parse(time) == TimeInZone.parse(time)
    end

    it 'eql?' do
      time = '2016-07-18 13:00:00 -0300'

      assert TimeInZone.parse(time).eql?(Time.parse(time))
      assert TimeInZone.parse(time).eql?(TimeInZone.parse(time))
    end

    it '>' do
      time_1 = '2016-07-18 13:00:00 -0300'
      time_2 = '2016-07-18 15:00:00 -0300'

      assert TimeInZone.parse(time_2) > Time.parse(time_1)
      assert TimeInZone.parse(time_2) > TimeInZone.parse(time_1)
    end

    it '>=' do
      time_1 = '2016-07-18 13:00:00 -0300'
      time_2 = '2016-07-18 15:00:00 -0300'

      assert TimeInZone.parse(time_2) >= Time.parse(time_1)
      assert TimeInZone.parse(time_2) >= TimeInZone.parse(time_1)

      assert TimeInZone.parse(time_2) >= Time.parse(time_2)
      assert TimeInZone.parse(time_2) >= TimeInZone.parse(time_2)
    end
    
    it '<' do
      time_1 = '2016-07-18 13:00:00 -0300'
      time_2 = '2016-07-18 15:00:00 -0300'

      assert TimeInZone.parse(time_1) < Time.parse(time_2)
      assert TimeInZone.parse(time_1) < TimeInZone.parse(time_2)
    end
    
    it '<=' do
      time_1 = '2016-07-18 13:00:00 -0300'
      time_2 = '2016-07-18 15:00:00 -0300'

      assert TimeInZone.parse(time_1) <= Time.parse(time_2)
      assert TimeInZone.parse(time_1) <= TimeInZone.parse(time_2)

      assert TimeInZone.parse(time_1) <= Time.parse(time_1)
      assert TimeInZone.parse(time_1) <= TimeInZone.parse(time_1)
    end
    
    it '<=>' do
      time_1 = '2016-07-18 13:00:00 -0300'
      time_2 = '2016-07-18 15:00:00 -0300'

      assert_equal -1, TimeInZone.parse(time_1) <=> Time.parse(time_2)
      assert_equal -1, TimeInZone.parse(time_1) <=> TimeInZone.parse(time_2)

      assert_equal 0, TimeInZone.parse(time_1) <=> Time.parse(time_1)
      assert_equal 0, TimeInZone.parse(time_1) <=> TimeInZone.parse(time_1)

      assert_equal 1, TimeInZone.parse(time_2) <=> Time.parse(time_1)
      assert_equal 1, TimeInZone.parse(time_2) <=> TimeInZone.parse(time_1)
    end

  end

end
