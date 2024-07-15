-- {"order":1,"file":"","version":0,"arguments":["trigger"]}

local lastfm_config = require("scripts/lastfm_config")

local function hashRequest(data, secret)
  local keys = {}
  for key in pairs(data) do
    table.insert(keys, key)
  end
  table.sort(keys)
  local s = ""
  for k, v in pairs(keys) do
    s = s .. v .. data[v]
  end
  s = s .. secret
  local hash = mympd.hash_md5(s)
  return hash
end

local function urlencode_data(data)
  local s = ""
  local a = {}
  for k, v in pairs(data) do
    table.insert(a, mympd.urlencode(k) .. "=" .. mympd.urlencode(v))
  end
  s = table.concat(a, "&")
 return s
end

local function sendData(data)
  local extra_headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  local hash = hashRequest(data, lastfm_config.SECRET)
  data["api_sig"] = hash
  data = urlencode_data(data)
  local rc, code, headers, body = mympd.http_client("POST", lastfm_config.URL_API, extra_headers, data)
  return rc, body
end

-- main
mympd.init()

local play_state = mympd_state.play_state
local elapsed_time = mympd_state.elapsed_time

if mympd_arguments.trigger == "player" then
  if play_state ~= 2 or elapsed_time > 5 then
    return "Now Playing: Not Playing"
  end

  local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
  if rc ~= 0 then
    return "Now Playing: Not Playing"
  end

  if result.webradio or
     string.sub(result.uri, 1, 8) == "https://" or
     string.sub(result.uri, 1, 7) == "http://" then
    return "webradio"
  end

  local artist = result.Artist[1]
  local title = result.Title
  local album = result.Album
  local albumArtist = result.AlbumArtist[1]

  local data = {
    method      = "track.updateNowPlaying",
    api_key     = lastfm_config.API_KEY,
    track       = title,
    artist      = artist,
    album       = album,
    albumArtist = albumArtist,
    sk          = lastfm_config.SESSION_KEY,
  }

  local body
  rc, body = sendData(data)
  if rc ~= 0 then
    return "Now Playing: Error"
  end

  local ret = json.decode(body)
  local code = ret.nowplaying.ignoredMessage.code
  if code ~= "0" then
    return "Now Playing: " .. artist .. " - " .. title .. " - ignored code " .. code
  end

  return "Now Playing: " .. artist .. " - " .. title .. " - OK"
end

if mympd_arguments.trigger == "scrobble" then
  local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
  if rc ~= 0 then
    return "Scrobble: Not playing"
  end

  local artist = result.Artist[1]
  local title = result.Title
  local album = result.Album
  local albumArtist = result.AlbumArtist[1]

  local data = {
    method      = "track.scrobble",
    api_key     = lastfm_config.API_KEY,
    timestamp   = tostring(os.time()-30),
    track       = title,
    artist      = artist,
    album       = album,
    albumArtist = albumArtist,
    sk          = lastfm_config.SESSION_KEY,
  }

  local body
  rc, body = sendData(data)
  if rc ~= 0 then
    return "Scrobble: Error"
  end

  local ret = json.decode(body)
  local code = ret.scrobbles.scrobble.ignoredMessage.code
  if code ~= "0" then
    return "Scrobble: " .. artist .. " - " .. title .. " ignored, code " .. code
  end

  return "Scrobble: " .. artist .. " - " .. title .. " OK"
end

if mympd_arguments.trigger == "feedback" then
  if mympd_arguments.type == "like" then
    if mympd_arguments.vote == "1" then
      return "Feedback: dislike"
    end
  else
    if mympd_arguments.vote <= 5 then
      return "Star rating <= 5"
    end
  end

  local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
  if rc ~= 0 then
    return "Feedback: Not playing"
  end

  local artist = result.Artist[1]
  local title = result.Title

  local data = {
    method      = "track.love",
    api_key     = lastfm_config.API_KEY,
    track       = title,
    artist      = artist,
    sk          = lastfm_config.SESSION_KEY,
  }

  local body
  rc, body = sendData(data)
  if rc ~= 0 then
    return "Feedback: Error"
  end

  return "Feedback: " .. artist .. " - " .. title .. " OK"
end

if mympd_arguments.trigger == "key" then
  data = {
    method   = "auth.getMobileSession",
    username = lastfm_config.USERNAME,
    password = lastfm_config.PASSWORD,
    api_key  = lastfm_config.API_KEY,
  }

  local rc, body = sendData(data)
  local ret = json.decode(body)
  session_key = ret.session.key
  print(session_key)

  return session_key
end

return "lastfm: unknown function"
