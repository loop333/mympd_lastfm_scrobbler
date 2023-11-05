-- {"order":1,"arguments":[]}
lastfm_config = require "scripts/lastfm_config"
lastfm_lib = require "scripts/lastfm_lib"

data = {
  method   = "auth.getMobileSession",
  username = lastfm_config.USERNAME,
  password = lastfm_config.PASSWORD,
  api_key  = lastfm_config.API_KEY,
}

local rc, body = lastfm_lib.sendData(data)
local ret = json.decode(body)
session_key = ret.session.key
-- print(session_key)

return session_key
