# Timing

[![Gem Version](https://badge.fury.io/rb/timing.svg)](https://rubygems.org/gems/timing)
[![Build Status](https://travis-ci.org/gabynaiman/timing.svg?branch=master)](https://travis-ci.org/gabynaiman/timing)
[![Coverage Status](https://coveralls.io/repos/gabynaiman/timing/badge.svg?branch=master)](https://coveralls.io/r/gabynaiman/timing?branch=master)
[![Code Climate](https://codeclimate.com/github/gabynaiman/timing.svg)](https://codeclimate.com/github/gabynaiman/timing)
[![Dependency Status](https://gemnasium.com/gabynaiman/timing.svg)](https://gemnasium.com/gabynaiman/timing)

Time utils

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'timing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timing

## Usage

#### TimeInZone

Acts like Time with specific utc offset.

```ruby
Time.now                                  # => 2015-10-19 22:10:47 -0300
Timing::TimeInZone.now                    # => 2015-10-19 22:10:47 -0300
Timing::TimeInZone.now '-0400'            # => 2015-10-19 21:10:47 -0400

Timing::TimeInZone.at 1445303855          # => 2015-10-19 22:17:35 -0300
Timing::TimeInZone.at 1445303855, '+0200' # => 2015-10-20 03:17:35 +0200

Timing::TimeInZone.now                    # => 2015-10-19 22:22:52 -0300
Timing::TimeInZone.now.to_zone('-0100')   # => 2015-10-20 00:22:52 -0100

time = Timing::TimeInZone.now '+0200'     # => 2015-10-20 03:36:14 +0200
time.zone_offset = '-0100'
time                                      # => 2015-10-20 00:36:14 -0100

time = Timing::TimeInZone.now '-0700'     # => 2015-10-19 18:29:29 -0700
time + 3600                               # => 2015-10-19 19:29:29 -0700
Timing::TimeInZone.now - time             # => 250.85015296936035
time.to_time                              # => 2015-10-19 22:29:29 -0300
```


#### Interval

Seconds wrapper with helper methods.

```ruby
Timing::Interval.new 10       # => 10s (10.0)

Timing::Interval.seconds(20)  # => 20s (20.0)
Timing::Interval.minutes(15)  # => 15m (900.0)
Timing::Interval.hours(7)     # => 7h (25200.0)
Timing::Interval.days(5)      # => 5d (432000.0)
Timing::Interval.weeks(2)     # => 2w (1209600.0)

Timing::Interval.parse('20s') # => 20s (20.0)
Timing::Interval.parse('15m') # => 15m (900.0)
Timing::Interval.parse('7h')  # => 7h (25200.0)
Timing::Interval.parse('5d')  # => 5d (432000.0)
Timing::Interval.parse('2w')  # => 2w (1209600.0)

interval = Timing::Interval.weeks(1)
interval.to_seconds           # => 604800.0
interval.to_minutes           # => 10080.0
interval.to_hours             # => 168.0
interval.to_days              # => 7.0
interval.to_weeks             # => 1.0

interval = Timing::Interval.seconds(1299785)
interval.to_s(biggest_unit: 'w', smallest_unit: 's')  # => 2w 1d 1h 3m 5s
interval.to_s(biggest_unit: 'd', smallest_unit: 's')  # => 15d 1h 3m 5s
interval.to_s(biggest_unit: 'd', smallest_unit: 'm')  # => 15d 1h 3m
```


#### NaturalTimeLanguage

Natural language to specify times.

```ruby
Timing::NaturalTimeLanguage.parse 'now'
```

Named moments
- now
- Now -0500
- today
- today +0000
- Today -0600
- yesterday -0400
- tomorrow -0300

Last/Next day name
- last Monday +0200
- last fri +0100
- next tuesday +0000
- next sat -0100
- last thursday including today -0300
- next mon including today +0200

Date (at 00:00:00)
- 6 April
- 14 Jul 2010 +0400
- 2015-09-03
- 2015-06-20 -0800
    
Beginning/End of interval
- Beginning of month
- end of year +0700
- beginning of week
- End of Day -0100
- end of hour +0400

Time ago (now - interval)
- 1 minute ago
- 3 hours ago -0500
- 5 days ago -0100
- 4 weeks ago +0100
- 10 months ago +0330
- 7 years ago -0700

Date at time
- today at 15:40
- last sunday at 08:43:21 -0300
- yesterday at beginning
- next friday at beginning -0100
- beginning of year at end
- 14 May 2011 at end -0400
- 25 Nov at 13:25
- 2001-07-14 at 18:41
- 2012-08-17 14:35:20
- 1980-04-21T08:15:03-0500

Before/After moment
- 15 minutes from now
- 3 days before yesterday
- 1 month from today
- 1 week from last monday at 08:30 -0400
- 5 days before next friday at end
- 1 month before beginning of month
- 1 year before 9 Sep +0300
- 2 years from 2001-05-21T12:30:40 -0500

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabynaiman/timing.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

