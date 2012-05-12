local uuid = KEYS[1]
local load_time = tonumber(string.sub(ARGV[1], 2, -1)) -- 'f0.1' => 0.1

local load_time_uuid_hash = 'load_time_' .. uuid
local load_time_range_hash = 'load_time_range'

if redis.call('hlen', load_time_uuid_hash) == 0 then
  -- Still no data for this user

  -- Set the hash of load time for the user
  local average = load_time
  redis.call('hmset', load_time_uuid_hash, 'total', load_time, 'views', 1, 'average', average)

  -- Add it to the "load time range" data structure
  local range = math.floor(average * 2) / 2 -- Split by 0.5
  redis.call('hincrby', load_time_range_hash, range, 1)
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
    redis.call('hincrby', load_time_range_hash, previous_range, -1)
    redis.call('hincrby', load_time_range_hash, new_range, 1)
  end

end

-- Get the full hash of ranged load times (as an array)
local value = redis.call('hgetall', load_time_range_hash)

-- Transform the array to a string (Lua can't do it by itself, lulz)
local message = '['
for i,v in ipairs(value) do message = message .. v .. ',' end
message = string.sub(message, 0, -2) .. ']'

return redis.call('publish', 'load_time_range_channel', message)
