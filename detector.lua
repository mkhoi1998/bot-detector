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

function Detector:parse ()
    hash = StringHash(self.userAgent)
    self.isBot = self.getParseCache(self, hash)
    if self.isBot == nil then
        local regex = require("regex")
        for _, value in ipairs(self.fixtures) do
            local ok, _ = regex.test(self.userAgent, tostring(value["regex"]))
            if ok then
                self.isBot = ok
                return self.setParseCache(self, hash)
            end
        end
        self.isBot = false
    end

    return self.setParseCache(self, hash)
end

-- TODO: cache using redis
function Detector:getParseCache(_, hash)
    return nil
end

function Detector:setParseCache(_, hash)
    return self.isBot
end

function StringHash(str)
    local md5 = require 'md5'
    return md5.sumhexa(str)
end
