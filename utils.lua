function StringSpaceless(str)
    return string.gsub(str, " ", "")
end

function StringHash(str)
    local md5 = require 'md5'
    return md5.sumhexa(str)
end