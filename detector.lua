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

-- TODO: cache using redis
function Detector:getParseCache(_)
    return nil
end

function Detector:setParseCache(_)
    return self.isBot
end

-- utils
function StringSpaceless(str)
    return string.gsub(str, " ", "")
end

function StringHash(str)
    local md5 = require 'md5'
    return md5.sumhexa(str)
end