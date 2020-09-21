local testList = {}

testList["IS_VALID_BOT"] = {
    agent = "APIs-Google",
    ip = "64.18.0.3"
}
testList["IS_NOT_BOT"] = {
    agent = "Mozilla/5.0 (Linux; Android 4.3; C5502 Build/10.4.1.B.0.101) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.136 Mobile Safari/537.36",
    ip = "125.234.115.178"
}
testList["IS_INVALID_BOT"] = {
    agent = "Riddler",
    ip = "125.234.115.178"
}


local detector = require "src.detector"
local params = {
    host = os.getenv('REDIS_HOST') or 'localhost',
    port = os.getenv('REDIS_PORT') or 6379,
}
local client = detector.new(params)
for want, test in pairs(testList) do
    local res = client.isBot(test.agent, test.ip)
    if want == res then
        print(test.agent, test.ip, "ok")
    else
        print(test.agent, test.ip, "got", res, "ERROR: expected", want)
        break
    end
end