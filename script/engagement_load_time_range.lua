local uuid = KEYS[1]
local load_time = tonumber(ARGV[1]) / 1000.0

local load_time_range = math.floor(load_time * 2) / 2 -- Split by 0.5

local load_time_uuid_hash = 'engagement_load_time_' .. uuid
local load_time_range_users_hash = 'engagement_time_range_users'
local load_time_range_views_hash = 'engagement_time_range_views'

local publish = true

if redis.call('hlen', load_time_uuid_hash) == 0 then
  -- Still no data for this visitor/user

  -- Set the hash of load time for the visitor/user
  local average = load_time
  redis.call('hmset', load_time_uuid_hash, 'total', load_time, 'views', 1, 'average', average)

  -- Add the visitor/user to the "load time range" data structures
  local range = math.floor(average * 2) / 2 -- Split by 0.5
  redis.call('hincrby', load_time_range_users_hash, range, 1)
  redis.call('hincrby', load_time_range_views_hash, range, 1)
else
  -- Increment the total load time and the number of views, and re-compute the load time average
  local total = redis.call('hincrbyfloat', load_time_uuid_hash, 'total', load_time)
  local views = redis.call('hincrby', load_time_uuid_hash, 'views', 1)

  local previous_average = redis.call('hget', load_time_uuid_hash, 'average')
  local new_average = total / views
  redis.call('hset', load_time_uuid_hash, 'average', new_average)

  -- Did the range change ?
  local previous_range = math.floor(previous_average * 2) / 2 -- Split by 0.5
  local new_range = math.floor(new_average * 2) / 2 -- Split by 0.5
  if (previous_range ~= new_range) then
    redis.call('hincrby', load_time_range_users_hash, previous_range, -1)
    redis.call('hincrby', load_time_range_users_hash, new_range, 1)
    redis.call('hincrby', load_time_range_views_hash, previous_range, -(views - 1))
    redis.call('hincrby', load_time_range_views_hash, new_range, views)
  else
    redis.call('hincrby', load_time_range_views_hash, previous_range, 1)
  end
end

-- Get the full hash of ranged load times for users (as an array)
local load_time_range_users = redis.call('hgetall', load_time_range_users_hash)

-- Get the full hash of ranged load times for views (as an array)
local load_time_range_views = redis.call('hgetall', load_time_range_views_hash)

-- Transform the array to a JSON string (Lua can't do it by itself, lulz)
local message = '[['
for i,v in ipairs(load_time_range_users) do message = message .. v .. ',' end
message = string.sub(message, 0, -2) .. '],['
for i,v in ipairs(load_time_range_views) do message = message .. v .. ',' end
message = string.sub(message, 0, -2) .. ']]'

return redis.call('publish', 'engagement_load_time_range_channel', message)
-- return message
