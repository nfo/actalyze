class PagesController < ApplicationController
  def index
  end

  def user
  end

  def registered
  end

  def dashboard
  end

  def chart
  end

  def pusher
    REDIS.publish('conversion_load_time_range_channel', 
      '{"conversion": [0, '+rand(150).to_s+', 0.5, '+rand(120).to_s+', 1.0, '+rand(90).to_s+', 1.5, '+rand(60).to_s+', 2, '+rand(30).to_s+'],'+
      '"users": [0, '+rand(150).to_s+', 0.5, '+rand(120).to_s+', 1.0, '+rand(90).to_s+', 1.5, '+rand(60).to_s+', 2, '+rand(30).to_s+']}')
    render nothing: true
  end
end
