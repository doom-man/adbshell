--http服务器url
http = {}

http.autoReg = http_ip.."/autoReg?source=" --自动注册
http.login = http_ip.."/login?" --登录
http.login_yj = http_ip.."/login_yj?" --登录
http.servsers = http_ip.."/servers?ver=" --获取服务器列表
http.reg = http_ip.."/reg?" --手动注册
http.jj_verify = http_ip.."/sdkLogin?"
http.quicklogin = http_ip.."/quickLogin?"
msgHttpURL = {
    autoRegUrl = function ()
        return http.autoReg.. (getMetaData("UMENG_CHANNEL") or "NAN")
    end,
    loginUrl = function (acc_,pwd_,sid_)
        local url = http.login.."account="..acc_.."&pwd="..pwd_.."&sid="..sid_.."&source="..(getMetaData("UMENG_CHANNEL") or "NAN")
        return url
    end,
    servsersUrl = function (v)
        return http.servsers..v
    end,
    ios_servsersUrl = function (v)
        return http.servsers..v.."&source="..(getMetaData("UMENG_CHANNEL") or "NAN")
    end,
    regUrl = function (acc_, pwd_)
        local url = http.reg.."account="..acc_.."&pwd="..pwd_.."&source="..(getMetaData("UMENG_CHANNEL") or "NAN")
        return url
    end,
    ios_provenUrl = function (token,sid_) --服务器ID
        local url = http.login_yj.."token="..token.."&sid="..sid_.."&source="..(getMetaData("UMENG_CHANNEL") or "NAN")
        return url
    end,
    jjverify = function (token,sid)
        local url = http.jj_verify.."token="..token.."&sid="..sid.."&source="..(getMetaData("UMENG_CHANNEL") or "NAN")
        return url
    end,
    quicklogin = function (sid)
        local url = http.quicklogin.."sid="..sid.."&source="..(getMetaData("UMENG_CHANNEL") or "NAN")
        return url
    end
}

