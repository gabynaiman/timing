require 'minitest_helper'

describe Helpers do

  let(:time) { Time.parse '2015-08-10 02:11:38' }
  
  it 'Beginning of day' do
    Timing.beginning_of_day(time).to_time.must_equal Time.parse('2015-08-10 00:00:00')
  end

  it 'End of day' do
    Timing.end_of_day(time).to_time.must_equal Time.parse('2015-08-10 23:59:59')
  end

end