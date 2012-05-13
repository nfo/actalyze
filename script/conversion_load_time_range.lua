local uuid = KEYS[1]
local load_time = tonumber(ARGV[1]) / 1000.0
local converted = ARGV[2]

local load_time_range = math.floor(load_time * 2) / 2 -- Split by 0.5

local load_time_uuid_hash = 'conversion_load_time_' .. uuid
local load_time_range_total_hash = 'conversion_time_range_total'
local load_time_range_converted_hash = 'conversion_load_time_range_converted'
local load_time_range_views_hash = 'conversion_load_time_range_views'

local publish = true

if redis.call('hlen', load_time_uuid_hash) == 0 then
  -- Still no data for this visitor

  -- Set the hash of load time for the visitor
  local average = load_time
  redis.call('hmset', load_time_uuid_hash, 'total', load_time, 'views', 1, 'average', average, 'converted', converted)

  -- Add the visitor to the "load time range" data structure
  local range = math.floor(average * 2) / 2 -- Split by 0.5
  redis.call('hincrby', load_time_range_total_hash, range, 1)

  -- Add the visitor to the "load time range views" data structure
  redis.call('hincrby', load_time_range_views_hash, load_time_range, 1)

  -- Add the view to the "load time range conversion" data structure
  if converted == '1' then
    redis.call('hincrby', load_time_range_converted_hash, range, 1)
  end
else
  local already_converted = redis.call('hget', load_time_uuid_hash, 'converted')

  if already_converted == '1' then
    -- If the visitor is already a visitor, then stop considering him
    publish = false
  else
    -- Increment the total load time and the number of views, and re-compute the load time average
    local total = redis.call('hincrbyfloat', load_time_uuid_hash, 'total', load_time)
    local views = redis.call('hincrby', load_time_uuid_hash, 'views', 1)

    -- Set the converted flag
    if already_converted ~= '1' and converted == '1' then
      redis.call('hset', load_time_uuid_hash, 'converted', 1)
    end

    local previous_average = redis.call('hget', load_time_uuid_hash, 'average')
    local new_average = total / views
    redis.call('hset', load_time_uuid_hash, 'average', new_average)

    -- Did the range change ?
    local previous_range = math.floor(previous_average * 2) / 2 -- Split by 0.5
    local new_range = math.floor(new_average * 2) / 2 -- Split by 0.5
    if (previous_range ~= new_range) then
      redis.call('hincrby', load_time_range_total_hash, previous_range, -1)
      redis.call('hincrby', load_time_range_total_hash, new_range, 1)
    end

    -- Add the visitor to the "load time range views" data structure
    redis.call('hincrby', load_time_range_views_hash, load_time_range, 1)

    -- Freshly converted visitor ? Let's add it to the load time range dedicated to conversions
    if already_converted ~= '1' and converted == '1' then
      redis.call('hincrby', load_time_range_converted_hash, new_range, 1)
    end
  end
end

if (publish) then
  -- Get the full hash of ranged load times (as an array)
  local load_time_range_total = redis.call('hgetall', load_time_range_total_hash)

  -- Get the full hash of ranged load times by conversion (as an array)
  local load_time_range_converted = redis.call('hgetall', load_time_range_converted_hash)

  -- Get the full hash of ranged load times by page views (as an array)
  local load_time_range_views = redis.call('hgetall', load_time_range_views_hash)

  -- Transform the arrays to a JSON string, an array of arrays (Lua can't do it by itself, lulz)
  local message = '[['
  for i,v in ipairs(load_time_range_total) do message = message .. v .. ',' end
  message = string.sub(message, 0, -2) .. '],['

  if # load_time_range_converted == 0 then
    message = message .. ']'
  else
    for i,v in ipairs(load_time_range_converted) do message = message .. v .. ',' end
    message = string.sub(message, 0, -2) .. ']'
  end
  message = string.sub(message, 0, -2) .. '],['

  if # load_time_range_views == 0 then
    message = message .. ']'
  else
    for i,v in ipairs(load_time_range_views) do message = message .. v .. ',' end
    message = string.sub(message, 0, -2) .. ']'
  end
  message = message .. ']'

  return redis.call('publish', 'conversion_load_time_range_channel', message)
  -- return message
end