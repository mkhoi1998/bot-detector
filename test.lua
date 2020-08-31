require "detector"

testList = {}

testList["APIs-Google"] = true
testList["Mozilla/5.0 (Linux; Android 4.3; C5502 Build/10.4.1.B.0.101) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.136 Mobile Safari/537.36"] = true


for ua, want in pairs(testList) do
    res = Detector:newDetector(ua):parse()
    
    if testList[ua] == res then
        print(ua, "ok")
    else
        print(ua, "got", res, "ERROR: expected", testList[ua])
        break
    end
end