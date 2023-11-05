-- {"order":1,"arguments":[]}
lastfm_config = require "scripts/lastfm_config"
lastfm_lib = require "scripts/lastfm_lib"

-- main
rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Scrobble: Not playing"
end

local artist = result.Artist[1]
local title = result.Title
local album = result.Album
local albumArtist = result.AlbumArtist[1]

data = {
  method      = "track.scrobble",
  api_key     = lastfm_config.API_KEY,
  timestamp   = tostring(os.time()-30),
  track       = title,
  artist      = artist,
  album       = album,
  albumArtist = albumArtist,
  sk          = lastfm_config.SESSION_KEY,
}

local rc, body = lastfm_lib.sendData(data)
if rc ~= 0 then
  return "Scrobble: Error"
end

ret = json.decode(body)
code = ret.scrobbles.scrobble.ignoredMessage.code
if code ~= "0" then
  return "Scrobble: " .. artist .. " - " .. title .. " ignored, code " .. code
end

return "Scrobble: " .. artist .. " - " .. title .. " OK"
