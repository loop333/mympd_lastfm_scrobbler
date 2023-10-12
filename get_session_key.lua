-- {"order":1,"arguments":[]}
package.path = package.path .. ";/usr/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";/usr/lib/x86_64-linux-gnu/lua/5.2/?.so"

local md5 = require "md5"

local USERNAME    = YOUR_USERNAME
local PASSWORD    = YOUR_PASSWORD
local API_KEY     = YOUR_API_KEY
local SECRET      = YOUR_SECRET
local URL_API     = "https://ws.audioscrobbler.com/2.0/?format=json"

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
  print(body)
  return body
end

data = {
  method   = "auth.getMobileSession",
  username = USERNAME,
  password = PASSWORD,
  api_key  = API_KEY,
}
session_key = sendData(data)
print(session_key)

return session_key
