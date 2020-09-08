local detector = {}

local fixtureFile = "src/bot.yaml"

local respone = {
    is_valid_bot = "IS_VALID_BOT",
    is_invalid_bot = "IS_INVALID_BOT",
    is_not_bot = "IS_NOT_BOT",
}

local function stringHash(str)
    local md5 = require 'md5'
    return md5.sumhexa(str)
end

local function parse_boolean(v)
    if v == '1' or v == 'true' or v == 'TRUE' then
        return true
    elseif v == '0' or v == 'false' or v == 'FALSE' then
        return false
    else
        return nil
    end
end

local function split_string (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

local function ip_2_number(ip)
    if ip == nil or type(ip) ~= "string" then
        return 0
    end
    local chunks = {ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
    if #chunks == 4 then
        local res = 0
        for i,v in pairs(chunks) do
            if (tonumber(v) < 0 or tonumber(v) > 255) then
                return 0
            end
            res = res + tonumber(v)*2^(32-8*i)
        end
        return res
    end
    local chunks = {ip:match("^"..(("([a-fA-F0-9]*):"):rep(8):gsub(":$","$")))}
    if #chunks < 8 and ip:match('::') and not ip:gsub("::","",1):match('::') then
        local _,n = ip:gsub(":","")
        local expander = ":"
        for i = 1, 9-n do
            expander = expander.."0:"
        end
        ip = string.gsub(ip, "::", expander)
    end
    local chunks = {ip:match("^"..(("([a-fA-F0-9]*):"):rep(9):gsub(":$","$")))}
    local res = 0
    for i,v in pairs(chunks) do
        if v ~= "" then
            if (tonumber(v, 16) < 0 or tonumber(v, 16) > 65535) then
                return 0
            end
            res = res + tonumber(v, 16)*2^(128-16*i)
        end
    end
    return res
end

local function match_ip(ip, netip)
    local nets = split_string(netip, "/")
    if #nets > 2 then
        return false
    end
    local netip_string = math.floor(ip_2_number(nets[1])/2^tonumber(nets[2]))
    local ip_string = math.floor(ip_2_number(ip)/2^tonumber(nets[2]))
    return netip_string == ip_string
end

local function setParseCache(client, hash, status)
    client.__redis:set(hash, status)
    client.__redis:expire(hash, 43200)
end

local function getParseCache(client, hash)
    return client.__redis:get(hash)
end

local function isBot(client, userAgent, ip)
    local hash = stringHash(userAgent..ip)
    local cache = getParseCache(client, hash)
    if cache ~= nil then
        return cache
    end
    local regex = require("regex")
    local matchIP = false
    local matchAgent = ""
    for _, bot_agent in ipairs(client.__redis:lrange("agent", 0, -1)) do
        local ok, _ = regex.test(userAgent, tostring(bot_agent))
        if ok then
            matchAgent=bot_agent
        end
    end
    if matchAgent == "" then
        setParseCache(client, hash, respone.is_not_bot)
        return respone.is_not_bot
    end

    for _, bot_ip in ipairs(client.__redis:lrange(matchAgent, 0, -1)) do
        matchIP = match_ip(ip, bot_ip)
        if matchIP then
            setParseCache(client, hash, respone.is_valid_bot)
            return respone.is_valid_bot
        end
    end
    setParseCache(client, hash, respone.is_invalid_bot)
    return respone.is_invalid_bot
end


local client_prototype = {
    __index = function (c, k)
        if k == "isBot" then
            return function (self, ...)
                return isBot(c, self, ...)
            end
        end
    end
}

function detector.new(params)
    local lyaml = require "lyaml"
    local f = io.open (fixtureFile)
    local fixtures = lyaml.load(f:read("*a"))
    local redis = require "redis"
    local redis_client = redis.connect(params)
    for _, fixture in ipairs(fixtures) do
        redis_client:rpush("agent", fixture["regex"])
        if fixture["ip"] ~= nil then
            for _, ip in ipairs(fixture["ip"]) do
                redis_client:rpush(fixture["regex"], ip)
            end
        end
    end
    local o = {
        __redis = redis_client,
    }
    local client = setmetatable(o, client_prototype)
    return client
end

return detector