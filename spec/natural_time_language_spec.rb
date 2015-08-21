require 'minitest_helper'

describe NaturalTimeLanguage do

  before { Time.now = Time.parse '2015-08-20 05:30:46 +0000' }
  after  { Time.now = nil }

  let(:local_offset) { TimeInZone.now.zone_offset }

  def self.it_must_equal_time(expression, &block)
    it expression do
      expected = instance_eval &block
      skip 'Not implemented' unless expected
      tz = NaturalTimeLanguage.parse expression
      tz.must_be_instance_of TimeInZone
      tz.to_s.must_equal expected.to_s
    end
  end

  describe 'Now' do
    it_must_equal_time('now')       { TimeInZone.now }
    it_must_equal_time('Now -0500') { '2015-08-20 00:30:46 -0500' }
  end

  describe 'Named dates' do
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
    it_must_equal_time('End of Day -0100')   { "2015-08-20 23:59:59 -0100" }
  end

  describe 'Date and time' do
    it_must_equal_time('today at 15:40')                        { }
    it_must_equal_time('last sunday at 08:43:21 -0300')         { }
    it_must_equal_time('yesterday at beginning of day')         { }
    it_must_equal_time('next friday at beginning of day -0100') { }
    it_must_equal_time('end of year at end of day')             { }
    it_must_equal_time('2012-08-17 14:35:00 +0600')             { }
    it_must_equal_time('27 Nov 13:25')                          { }
    it_must_equal_time('14 May 2011 at end of day -0400')       { }
  end

  describe 'Time ago (now - interval)' do
    it_must_equal_time('1 minute ago') { }
    it_must_equal_time('3 hours ago')  { }
    it_must_equal_time('5 days ago')   { }
    it_must_equal_time('7 weeks ago')  { }
    it_must_equal_time('2 months ago') { }
    it_must_equal_time('1 year ago')   { }
  end

  describe 'Combined (interval before/from data and time)' do
    it_must_equal_time('3 days before yesterday')                 { }
    it_must_equal_time('1 month from today')                      { }
    it_must_equal_time('1 week from last monday at 08:30 -0400')  { }
    it_must_equal_time('5 days before next friday at end of day') { }
    it_must_equal_time('1 month before beginning of month')       { }
    it_must_equal_time('1 year before 9 Sep')                     { }
  end

end