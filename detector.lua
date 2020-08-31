require "utils"

Detector = {
    fixtureFile = "bot.yaml"
}

function Detector:newDetector (userAgent)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.userAgent = userAgent
    local lyaml = require "lyaml"
    local f = io.open (self.fixtureFile)
    self.fixtures = lyaml.load(f:read("*a"))
    return o
end

-- TODO: cache using redis
function Detector:getParseCache(_)
    return nil
end

function Detector:setParseCache(_)
    return self.isBot
end

function Detector:parse ()
    self.isBot = self.getParseCache(self)
    if self.isBot == nil then
        local regex = require("regex")
        for _, value in ipairs(self.fixtures) do
            local ok, _ = regex.test(self.userAgent, tostring(value["regex"]))
            if ok then
                self.isBot = ok
                return self.setParseCache(self)
            end
        end
        self.isBot = false
    end

    return self.setParseCache(self)
end

print(Detector:newDetector('APIs-Google'):parse())
print(Detector:newDetector('Mozilla/5.0 (Linux; Android 4.3; C5502 Build/10.4.1.B.0.101) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.136 Mobile Safari/537.36'):parse())