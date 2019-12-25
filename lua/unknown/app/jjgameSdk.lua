jjGameSdk = {}
function jjGameSdk.getOidAndVerify(callback)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {callback}
        local sigs = "(I)I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "getOidAndVerify", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.loginSdk(callback)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {callback}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "loginSdk", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.openSubmissionPage(uname,sname,callback)
        if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {uname,sname,callback}
        local sigs = "(Ljava/lang/String;Ljava/lang/String;I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "openSubmissionPage", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.logoutSdk(callback)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {1}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "logoutSdk", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.pay(p,callback)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {p,callback}
        local sigs = "(Ljava/lang/String;I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "doPay", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.isCurrentLogin()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {1}
        local sigs = "(I)I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "isCurrentLogin", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.openUserInfo()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {1}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "openSdk", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end

function jjGameSdk.UMLOG_UserLogin(uid)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {tostring( uid)}
        local sigs = "(Ljava/lang/String;)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "UMLOG_UserLogin", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.UMLOG_UserLogout()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {user.uid}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "UMLOG_UserLogout", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.UMLOG_EnterGamePage(loadtime)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {1}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "UMLOG_EnterGamePage", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end

function jjGameSdk.UMLOG_EnterLoginPage()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {1}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "UMLOG_EnterLoginPage", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function jjGameSdk.UMLOG_PAY()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = {1}
        local sigs = "(I)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "UMLOG_Pay", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
function logoutGame(s)
    local loadtomenu = loadBackMenu:create("loadScene.csb")
    me.runScene(loadtomenu)
end  