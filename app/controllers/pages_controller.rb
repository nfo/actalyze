class PagesController < ApplicationController
  def index
    render layout: 'user'
  end

  def index2
    render layout: 'user'
  end

  def user
    render layout: 'user'
  end

  def registered
    render layout: 'user'
  end

  def dashboard
  end

  def chart
    @costs = {acquisition: 0.15, visitor_page: 0.001, user_page: 0.005}
    @revenues = {user_day: 1}
  end

  def pusher
    REDIS.publish('conversion_load_time_range_channel', 
      '{"conversion": [0, '+rand(150).to_s+', 0.5, '+rand(120).to_s+', 1.0, '+rand(90).to_s+', 1.5, '+rand(60).to_s+', 2, '+rand(30).to_s+'],'+
      '"users": [0, '+rand(150).to_s+', 0.5, '+rand(120).to_s+', 1.0, '+rand(90).to_s+', 1.5, '+rand(60).to_s+', 2, '+rand(30).to_s+']}')
    render nothing: true
  end
end
