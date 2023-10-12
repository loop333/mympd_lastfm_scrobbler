-- {"order":1,"arguments":[]}
package.path = package.path .. ";/usr/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";/usr/lib/x86_64-linux-gnu/lua/5.2/?.so"

local md5 = require "md5"

local API_KEY     = YOUR_API_KEY
local SECRET      = YOUR_SECRET
local URL_API     = "https://ws.audioscrobbler.com/2.0/?format=json"
local SESSION_KEY = YOUR_SESSION_KEY

local data

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(s)
  s = s:gsub("([^%w ])", char_to_hex)
  s = s:gsub(" ", "+")
  return s
end

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
  local hash = md5.sumhexa(s)

  return hash
end

local function urlencode_data(data)
  local s = ""
  local a = {}
  for k, v in pairs(data) do
    table.insert(a, urlencode(k) .. "=" .. urlencode(v))
  end
 s = table.concat(a, "&")

 return s
end

local function sendData(data)
  local headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  local hash = hashRequest(data, SECRET)
  data["api_sig"] = hash
  data = urlencode_data(data)
  rc, code, header, body = mympd.http_client("POST", URL_API, headers, data)
  return rc
end

-- main
rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Not playing"
end

local artist = result["Artist"][1]
local title = result["Title"]

data = {
  method    = "track.scrobble",
  api_key   = API_KEY,
  timestamp = tostring(os.time()-30),
  track     = title,
  artist    = artist,
  sk        = SESSION_KEY,
}
local rc = sendData(data)
if rc ~= 0 then
  return "Scrobble Error"
end

return "Scrobble " .. artist .. " - " .. title .. " OK"
