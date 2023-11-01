-- {"order":1,"arguments":["uri","vote"]}
package.path = package.path .. ";/usr/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";/usr/lib/x86_64-linux-gnu/lua/5.2/?.so"

local md5 = require "md5"

local API_KEY     = <MY_API_KEY>
local SECRET      = <MY_SECRET>
local URL_API     = "https://ws.audioscrobbler.com/2.0/?format=json"
local SESSION_KEY = <MY_SESSION_KEY>

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

  return rc, body
end

-- main
if arguments.vote == "1" then
  return "dislike"
end

rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Not playing"
end

local artist = result.Artist[1]
local title = result.Title

data = {
  method      = "track.love",
  api_key     = API_KEY,
  track       = title,
  artist      = artist,
  sk          = SESSION_KEY,
}
local rc, body = sendData(data)
if rc ~= 0 then
  return "Love Error"
end
--ret = json.decode(body) -- always {}

return "Love " .. artist .. " - " .. title .. " OK"
