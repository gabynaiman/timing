require 'minitest_helper'

describe NaturalTimeLanguage do

  before { Time.now = Time.parse '2015-08-20T05:30:46-0000' }
  after  { Time.now = nil }

  let(:local_offset) { TimeInZone.now.zone_offset }

  def self.it_must_equal_time(expression, &block)
    it expression do
      expected = instance_eval(&block)
      skip 'Not implemented' unless expected
      tz = NaturalTimeLanguage.parse expression
      tz.must_be_instance_of TimeInZone
      tz.to_s.must_equal expected.to_s
    end
  end

  describe 'Named moments' do
    it_must_equal_time('now')             { TimeInZone.now }
    it_must_equal_time('Now -0500')       { '2015-08-20 00:30:46 -0500' }
    it_must_equal_time('today')           { TimeInZone.now.beginning_of_day }
    it_must_equal_time('today +0000')     { '2015-08-20 00:00:00 +0000' }
    it_must_equal_time('Today -0600')     { '2015-08-19 00:00:00 -0600' }
    it_must_equal_time('yesterday -0400') { '2015-08-19 00:00:00 -0400' }
    it_must_equal_time('tomorrow -0300')  { '2015-08-21 00:00:00 -0300' }
  end

  describe 'Last/Next day name' do
    it_must_equal_time('last Monday +0200')  { '2015-08-17 00:00:00 +0200' }
    it_must_equal_time('last fri +0100')     { '2015-08-14 00:00:00 +0100' }
    it_must_equal_time('next tuesday +0000') { '2015-08-25 00:00:00 +0000' }
    it_must_equal_time('next sat -0100')     { '2015-08-22 00:00:00 -0100' }
    
    it_must_equal_time('last thursday -0300')                 { '2015-08-13 00:00:00 -0300' }
    it_must_equal_time('last thursday including today -0300') { '2015-08-20 00:00:00 -0300' }
    it_must_equal_time('next thursday -0300')                 { '2015-08-27 00:00:00 -0300' }
    it_must_equal_time('next thursday including today -0300') { '2015-08-20 00:00:00 -0300' }
  end

  describe 'Date (at 00:00:00)' do
    it_must_equal_time('6 April')           { "2015-04-06 00:00:00 #{local_offset}" }
    it_must_equal_time('14 Jul 2010 +0400') { '2010-07-14 00:00:00 +0400' }
    it_must_equal_time('2015-09-03')        { "2015-09-03 00:00:00 #{local_offset}" }
    it_must_equal_time('2015-06-20 -0800')  { '2015-06-20 00:00:00 -0800' }
  end
    
  describe 'Beginning/End of interval' do
    it_must_equal_time('Beginning of month') { "2015-08-01 00:00:00 #{local_offset}" }
    it_must_equal_time('end of year +0700')  { '2015-12-31 23:59:59 +0700' }
    it_must_equal_time('beginning of week')  { "2015-08-16 00:00:00 #{local_offset}" }
    it_must_equal_time('End of Day -0100')   { '2015-08-20 23:59:59 -0100' }
    it_must_equal_time('end of hour +0400')  { '2015-08-20 09:59:59 +0400' }
  end

  describe 'Time ago (now - interval)' do
    it_must_equal_time('1 minute ago')        { TimeInZone.now - Interval.minutes(1) }
    it_must_equal_time('3 hours ago -0500')   { '2015-08-19 21:30:46 -0500' }
    it_must_equal_time('5 days ago -0100')    { '2015-08-15 04:30:46 -0100' }
    it_must_equal_time('4 weeks ago +0100')   { '2015-07-23 06:30:46 +0100' }
    it_must_equal_time('10 months ago +0330') { '2014-10-20 09:00:46 +0330' }
    it_must_equal_time('7 years ago -0700')   { '2008-08-19 22:30:46 -0700' }
  end

  describe 'Date at time' do
    it_must_equal_time('today at 15:40')                 { "2015-08-20 15:40:00 #{local_offset}" }
    it_must_equal_time('last sunday at 08:43:21 -0300')  { '2015-08-16 08:43:21 -0300' }
    it_must_equal_time('yesterday at beginning')         { "2015-08-19 00:00:00 #{local_offset}" }
    it_must_equal_time('next friday at beginning -0100') { '2015-08-21 00:00:00 -0100' }
    it_must_equal_time('beginning of year at end')       { "2015-01-01 23:59:59 #{local_offset}" }
    it_must_equal_time('14 May 2011 at end -0400')       { '2011-05-14 23:59:59 -0400' }
    it_must_equal_time('25 Nov at 13:25')                { "2015-11-25 13:25:00 #{local_offset}" }
    it_must_equal_time('2001-07-14 at 18:41')            { "2001-07-14 18:41:00 #{local_offset}" }
    it_must_equal_time('2012-08-17 14:35:20')            { "2012-08-17 14:35:20 #{local_offset}" }
    it_must_equal_time('1980-04-21T08:15:03-0500')       { '1980-04-21 08:15:03 -0500' }
    it_must_equal_time('2018-12-07 12:03:00 UTC')        { '2018-12-07 12:03:00 +0000' }
    it_must_equal_time('today utc')                      { '2015-08-20 00:00:00 +0000' }
    it_must_equal_time('today at 13:25 utc')             { '2015-08-20 13:25:00 +0000' }
  end

  describe 'Before/After moment' do
    it_must_equal_time('15 minutes from now')                    { TimeInZone.now + Interval.minutes(15) }
    it_must_equal_time('3 days before yesterday')                { "2015-08-16 00:00:00 #{local_offset}" }
    it_must_equal_time('1 month from today')                     { "2015-09-20 00:00:00 #{local_offset}" }
    it_must_equal_time('1 week from last monday at 08:30 -0400') { '2015-08-24 08:30:00 -0400' }
    it_must_equal_time('5 days before next friday at end')       { "2015-08-16 23:59:59 #{local_offset}" }
    it_must_equal_time('1 month before beginning of month')      { "2015-07-01 00:00:00 #{local_offset}" }
    it_must_equal_time('1 year before 9 Sep +0300')              { '2014-09-09 00:00:00 +0300' }
    it_must_equal_time('2 years from 2001-05-21T12:30:40 -0500') { '2003-05-21 12:30:40 -0500' }
  end

  it 'Thread safe' do
    threads = 300.times.map do
      Thread.new do
        seconds = rand(60).to_s.rjust(2, '0')
        input = "2017-01-05 15:19:#{seconds} -0300"
        assert_equal Time.parse(input), NaturalTimeLanguage.parse(input)
      end
    end
    threads.each(&:join)
  end

end