-- {"order":1,"arguments":[]}
package.path = package.path .. ";/usr/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";/usr/lib/x86_64-linux-gnu/lua/5.2/?.so"

local md5 = require "md5"
local lastfm_config = require "scripts/lastfm_config"

lastfm_lib = {}

local function char_to_hex(c)
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

lastfm_lib.sendData = function(data)
  local headers = 'Content-type: application/x-www-form-urlencoded\r\n'
  local hash = hashRequest(data, lastfm_config.SECRET)
  data["api_sig"] = hash
  data = urlencode_data(data)
  rc, code, header, body = mympd.http_client("POST", lastfm_config.URL_API, headers, data)

  return rc, body
end

return lastfm_lib
