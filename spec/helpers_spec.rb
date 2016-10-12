require 'minitest_helper'

describe Helpers do

  let(:time_value) { TimeInZone.parse '2015-08-10 02:11:38 +0700' }
  
  it 'Beginning of hour' do
    Timing.beginning_of_hour(time_value).to_time.must_equal Time.parse('2015-08-10 02:00:00 +0700')
  end

  it 'End of hour' do
    Timing.end_of_hour(time_value).to_time.must_equal Time.parse('2015-08-10 02:59:59 +0700')
  end

  it 'Beginning of day' do
    Timing.beginning_of_day(time_value).to_time.must_equal Time.parse('2015-08-10 00:00:00 +0700')
  end

  it 'End of day' do
    Timing.end_of_day(time_value).to_time.must_equal Time.parse('2015-08-10 23:59:59 +0700')
  end

  it 'Begining of week' do
    Timing.beginning_of_week(time_value).to_time.must_equal Time.parse('2015-08-09 00:00:00 +0700')
  end

  it 'End of week' do
    Timing.end_of_week(time_value).to_time.must_equal Time.parse('2015-08-15 23:59:59 +0700')
  end

  it 'Beginning of month' do
    Timing.beginning_of_month(time_value).to_time.must_equal Time.parse('2015-08-01 00:00:00 +0700')
  end

  it 'End of month' do
    Timing.end_of_month(time_value).to_time.must_equal Time.parse('2015-08-31 23:59:59 +0700')
  end

  it 'Beginning of year' do
    Timing.beginning_of_year(time_value).to_time.must_equal Time.parse('2015-01-01 00:00:00 +0700')
  end

  it 'End of year' do
    Timing.end_of_year(time_value).to_time.must_equal Time.parse('2015-12-31 23:59:59 +0700')
  end

  it 'Days in month' do
    Timing.days_in_month(2, 2012).must_equal 29
    Timing.days_in_month(1).must_equal 31
  end

  it 'Months ago' do
    Timing.months_ago(time_value, 4).to_time.must_equal Time.parse('2015-04-10 02:11:38 +0700')
    Timing.months_ago(time_value, 21).to_time.must_equal Time.parse('2013-11-10 02:11:38 +0700')
  end

  it 'Months after' do
    Timing.months_after(time_value, 2).to_time.must_equal Time.parse('2015-10-10 02:11:38 +0700')
    Timing.months_after(time_value, 18).to_time.must_equal Time.parse('2017-02-10 02:11:38 +0700')
  end

  it 'Years ago' do
    Timing.years_ago(time_value, 4).to_time.must_equal Time.parse('2011-08-10 02:11:38 +0700')
  end

  it 'Years ago' do
    Timing.years_after(time_value, 5).to_time.must_equal Time.parse('2020-08-10 02:11:38 +0700')
  end

end