-- {"order":1,"arguments":["uri","vote"]}
lastfm_config = require "scripts/lastfm_config"
lastfm_lib = require "scripts/lastfm_lib"

-- main
if arguments.vote == "1" then
  return "Feedback: dislike"
end

rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Feedback: Not playing"
end

local artist = result.Artist[1]
local title = result.Title

data = {
  method      = "track.love",
  api_key     = lastfm_config.API_KEY,
  track       = title,
  artist      = artist,
  sk          = lastfm_config.SESSION_KEY,
}

local rc, body = lastfm_lib.sendData(data)
if rc ~= 0 then
  return "Feedback: Error"
end
--ret = json.decode(body) -- always {}

return "Feedback: " .. artist .. " - " .. title .. " OK"
