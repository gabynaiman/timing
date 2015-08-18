require 'minitest_helper'

describe TimeInZone do

  let(:time_string) { '2015-08-18 20:17:42 -0300' }
  let(:time) { Time.parse time_string }
  let(:local_utc_offset) { time.utc_offset }

  describe 'Constructors' do

    describe 'Default zone' do
      
      it 'New' do
        tz = TimeInZone.new time
        tz.to_f.must_equal time.to_f
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal time.hour
      end

      it 'Now' do
        tz = TimeInZone.now
        now = Time.now
        (now.to_f - tz.to_f).must_be :<, 0.01
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal now.hour
      end

      it 'At' do
        tz = TimeInZone.at time.to_f
        tz.to_f.must_equal time.to_f
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal time.hour
      end
      
      it 'Parse' do
        tz = TimeInZone.parse time.strftime('%F %T')
        tz.to_f.must_equal time.to_f
        tz.utc_offset.must_equal local_utc_offset
        tz.hour.must_equal time.hour
      end

    end

    describe 'With specific zone' do

      it 'New' do
        tz = TimeInZone.new time, '+02:00'
        tz.to_f.must_equal time.to_f
        tz.utc_offset.must_equal ZoneOffset.parse('+0200')
        tz.day.must_equal 19
        tz.hour.must_equal 1
      end

      it 'Now' do
        tz = TimeInZone.now '-05:00'
        now = Time.now
        (now.to_f - tz.to_f).must_be :<, 0.01
        tz.utc_offset.must_equal ZoneOffset.parse('-0500')
        tz.hour.must_equal now.getutc.hour - 5
      end

      it 'At' do
        tz = TimeInZone.at time.to_f, '+01:30'
        tz.to_f.must_equal time.to_f
        tz.utc_offset.must_equal ZoneOffset.parse('+0130')
        tz.day.must_equal 19
        tz.hour.must_equal 0
        tz.min.must_equal 47
      end

      it 'Parse' do
        tz = TimeInZone.parse time.strftime('%F %T -0400')
        tz.to_f.must_equal time.to_f + (60 * 60) 
        tz.utc_offset.must_equal ZoneOffset.parse('-0400')
        tz.hour.must_equal time.hour
      end

      it 'Inzalid zone' do
        error = proc { TimeInZone.new time, 'XYZ' }.must_raise ArgumentError
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

  describe 'To string' do

    it 'Default' do
      TimeInZone.new(time).to_s.must_equal time.to_s
    end

    it 'Formatted' do
      TimeInZone.new(time).strftime('%d/%m/%y').must_equal time.strftime('%d/%m/%y')
    end

  end

  describe 'Math' do

    it '+' do
      tz = TimeInZone.new(time) + 15
      tz.must_be_instance_of TimeInZone
      tz.to_f.must_equal time.to_f + 15
    end

    it '-' do
      tz = TimeInZone.new(time) - 23
      tz.must_be_instance_of TimeInZone
      tz.to_f.must_equal time.to_f - 23
    end

  end


end
