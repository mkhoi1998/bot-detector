local testList = {}

testList["APIs-Google"] = {
    res = "IS_VALID_BOT",
    ip = "64.18.0.3"
}
testList["Mozilla/5.0 (Linux; Android 4.3; C5502 Build/10.4.1.B.0.101) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.136 Mobile Safari/537.36"] = {
    res = "IS_NOT_BOT",
    ip = "125.234.115.178"
}


local detector = require "src.detector"
local params = {
    host = 'localhost',
    port = 6379,
}
local client = detector.new(params)
for ua, want in pairs(testList) do
    local res = client.isBot(ua, want.ip)
    if want.res == res then
        print(ua, want.ip, "ok")
    else
        print(ua, want.ip, "got", res, "ERROR: expected", want.res)
        break
    end
end