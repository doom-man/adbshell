-- [Comment]
-- 更新界面
updateLayer = class("updateLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
updateLayer.__index = updateLayer
updateLayer.neterrorTimes = 0
function updateLayer:create(...)
    local layer = updateLayer.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
KEYS_UPDATE = "update_ver"
DEFAULT_VER = "1.40"
local function setUpdateZipUrl(value)
    cc.UserDefault:getInstance():setStringForKey(KEYS_UPDATE..getApkMeta(), value)
end
local function getUpdateZipUrl()
    local url = cc.UserDefault:getInstance():getStringForKey(KEYS_UPDATE..getApkMeta())
    return url or ""
end
function updateLayer:ctor()
    print("updateLayer ctor")
    -- 是否需要去APPSTORE下载
    self.bNeedDown = false
end

BTN_COMMAN_UPDATE = 0x11 -- 热更新
BTN_COMMAN_GODOWN = 0x12 -- 去下载
BTN_COMMAN_ENTER = 0x13 -- 进游戏并检测是否有热更新
function updateLayer:init()
    print("updateLayer init")
    me.registGuiClickEventByName(self, "fixLayout", function(args)

    end )
    self.info = me.assignWidget(self, "fbg")
    self.Text_Info = me.assignWidget(self, "Text_Info")
    self.Button_Enter = me.assignWidget(self, "Button_Enter")
    self.Text_jiangli = me.assignWidget(self, "Text_jiangli")
    self.Text_v = me.assignWidget(self, "Text_v")
    local function callback(node)
        local cmd = node.cmd
        if cmd == BTN_COMMAN_ENTER then
            self.info:setVisible(false)
            self:checkUpdate()
        elseif cmd == BTN_COMMAN_GODOWN then
            self:openAppstore( me.urlDecode( node.cfg.downurl))
        elseif cmd == BTN_COMMAN_UPDATE then
            ass:update()
            self.Image_2:setVisible(true)
            self.Text_Update:setString("连接更新服务器...")
            self.info:setVisible(false)
        end
    end
    self.okBtn = me.registGuiClickEventByName(self, "Button_OK", callback)
    me.registGuiClickEvent(self.Button_Enter, callback)
    self.Image_2 = me.assignWidget(self, "Image_2")
    self.LoadingBar_Update = me.assignWidget(self, "LoadingBar_Update")
    self.Text_Update = me.assignWidget(self, "Text_Update")
    self.Text_Ver = me.assignWidget(self, "Text_Ver")
    self.Text_Ver:setVisible(false)
    CUR_GAME_STATE = GAME_STATE_UPDATING
    return true
end
function updateLayer:NetError()
    showTips("网络连接出现问题")
    self:checkWhite()
end

function updateLayer:playCG()
    local function removeVideo()
        me.assignWidget(self, "fixLayout"):setVisible(true)
        me.assignWidget(self, "videoLayer"):setVisible(false)
        self:checkWhite()
        self.video:runAction(cc.Sequence:create(cc.CallFunc:create( function() end), cc.RemoveSelf:create()))
    end

    me.registGuiClickEventByName(self, "Button_skipCG", function(node)
        if self.video then
            removeVideo()
        end
    end )

    cc.UserDefault:getInstance():setStringForKey("isPlayCG", 1)
    cc.UserDefault:getInstance():flush()
    me.assignWidget(self, "fixLayout"):setVisible(false)
    me.assignWidget(self, "videoLayer"):setVisible(true)

    self.video = require("app.VideoLayer").create("startCG.mp4", removeVideo)
    self:addChild(self.video)
end

function updateLayer:onEnter()
    print("updateLayer onEnter")
--    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--    if targetPlatform == cc.PLATFORM_OS_ANDROID then
--        cc.Director:getInstance():setClearColor(cc.c4f(0, 0, 0, 0))
--        local isFirstEnter = cc.UserDefault:getInstance():getStringForKey("isPlayCG", 0)
--        if isFirstEnter == "0" then
--            self:playCG()
--        else
--            self:checkWhite()
--        end
--    else
--        self:checkWhite()
--    end
    self:checkWhite()
    me.doLayout(self, me.winSize)
end
function updateLayer:openAppstore(url_)
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { url = url_ }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "openAppstore", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)
        end
    elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
        local args = { key }
        local sigs = "(Ljava/lang/String;)V"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "OpenUrl", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    else
        print(url_)
    end
end
function updateLayer:checkUpdate()
    local function onReadyStateChange(response)
        print("self.verUrl",self.verUrl)
        print("getUpdateZipUrl",getUpdateZipUrl())
        ass = cc.AssetsManager:new(getUpdateZipUrl(), self.verUrl, pathToSave)
        ass:retain()
        local ver = ass:getVersion()
        print("ver ", ver)
        if ver == "" then
            ver = DEFAULT_VER
        end
        self.Text_Ver:setVisible(true)
        cc.UserDefault:getInstance():setStringForKey("localversion", tostring(ver))
        cc.UserDefault:getInstance():flush()
        self.Text_Ver:setString(getCurVersion())
        print("checkUpdate ver = " .. ver)
        if tonumber(ver) == me.toNum(DEFAULT_VER) then
            delUpdate()
        end
        if tonumber(response) > tonumber(ver) then
            self.curVer = response
            local updateZipUrl = string.format(self.cdnUrl .. "/%s/%s/update.zip", response, ver)
            print("checkUpdate updateZipUrl = " .. updateZipUrl)
            ass:setPackageUrl(updateZipUrl)
            setUpdateZipUrl(updateZipUrl)
            local function onError(errorCode)
                if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
                    print("no new version")
                    self:enterGame()
                elseif errorCode == cc.ASSETSMANAGER_NETWORK then
                    print("network error")
                    self.Text_Update:setString("连接更新服务器失败...")
                    me.DelayRun( function()
                        self:NetError()
                    end , 2)
                elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
                    createDownloadDir(pathToSave)
                else
                    me.DelayRun( function()
                        self:NetError()
                    end , 2)
                end
            end
            local function onProgress(percent)
                local progress = string.format("更新中... %d%%", percent)
                self.Text_Update:setString(progress)
                self.LoadingBar_Update:setPercent(percent)
            end
            local function onSuccess()
                print("downloading ok")
                -- do something
                cc.UserDefault:getInstance():setStringForKey("localversion", tostring(self.curVer))
                cc.UserDefault:getInstance():flush()
                unLoadPackage()
                require "main"
            end
            ass:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR)
            ass:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
            ass:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS)
            ass:setConnectionTimeout(5)
            self.delUrl = string.format(self.cdnUrl .. "/%s/%s/del.txt", response, ver)
            local upsizeUrl = string.format(self.cdnUrl .. "/%s/%s/updatesize.txt", response, ver)
            me.getHttpString(upsizeUrl, function(response_)
                self.info:setVisible(false)
                if response_ then
                    if me.toNum(response_) > 0 then
                        self.info:setVisible(true)
                        self.okBtn:setVisible(true)
                        self.okBtn:setTitleText("更新")
                        self.okBtn.cmd = BTN_COMMAN_UPDATE
                        self.Button_Enter:setVisible(false)
                        self.Text_jiangli:setVisible(false)
                        self.okBtn:setPositionX(self.info:getContentSize().width / 2)
                        self.Text_Info:setString(string.format("更新包大小为:%dkb 请在WIFI环境下更新。", math.floor(response_ / 1024)))
                    end
                end
            end , function()
                ass:setPackageUrl(self.cdnUrl .. "/public/update.zip")
                setUpdateZipUrl(self.cdnUrl .. "/public/update.zip")
                self.delUrl = self.cdnUrl .. "/public/del.txt"
                me.getHttpString(self.cdnUrl .. "/public/updatesize.txt", function(response_)
                    self.info:setVisible(false)
                    if response_ then
                        if me.toNum(response_) > 0 then
                            self.info:setVisible(true)
                            self.okBtn:setVisible(true)
                            self.okBtn:setTitleText("更新")
                            self.okBtn.cmd = BTN_COMMAN_UPDATE
                            self.Button_Enter:setVisible(false)
                            self.Text_jiangli:setVisible(false)
                            self.okBtn:setPositionX(self.info:getContentSize().width / 2)
                            self.Text_Info:setString(string.format("更新包大小为:%dkb 请在WIFI环境下更新。", math.floor(response_ / 1024)))
                        end
                    end
                end , function()
                    me.DelayRun( function()
                        self:NetError()
                    end , 2)
                end )
            end )
        else
            self:enterGame()
        end
    end
    me.getHttpString(self.verUrl , onReadyStateChange, function()
        me.DelayRun( function()
            if updateLayer.neterrorTimes < 5 then
                self:NetError()
                updateLayer.neterrorTimes = updateLayer.neterrorTimes + 1
            else
                showErrorMsg("连接更新服务器失败 code:" .. PACKAGE_CHANNEL, -1)
            end
        end , 2)
    end )
end
-- 检查是否是白名单
function updateLayer:checkWhite()
    me.getHttpString(self:getCheckUrl(), function(response)
        if tonumber(response.rs) == 1 then
            self.verUrl = me.urlDecode(response.cn.url).. "?source=" ..getApkMeta()
            self.cdnUrl = me.urlDecode(response.cn.cdn)      
            if response.cn.state == 0 then
                print(me.urlDecode(response.cn.url))
                print(me.urlDecode(response.cn.cdn))
                self:checkUpdate()
            else
               self:showUpdateDialog(response.cn)
            end
        elseif tonumber(response.rs) == 0 then
            showErrorMsg("未找到source " .. response.cn, -1)
        end
    end , function()
        me.DelayRun( function()
            self:checkWhite()
        end , 1)
    end , true)
end
function updateLayer:checkGlobalUpdate()
    addSearchPath(pathToSave, true)
    me.getHttpString(globalUrl .. "/updatefiles.txt", function(response)
        if response == "" then
            self:enterGame()
        else
            self.Image_2:setVisible(true)
            self.info:setVisible(false)
            self.Text_Update:setString("检查全局更新文件...")
            self.LoadingBar_Update:setPercent(0)
            local sp = self:getGlobalUpdateFiles(response)
            dump(sp)
            if sp then
                self:checkAndDownGlobalFiles(sp)
            else
                self:enterGame()
            end
        end
    end , function(err)
        self:enterGame()
    end )
end
function downFiles(v, callfunc, callerror)
    local path = pathToSave .. "/" .. v.name
    if cc.FileUtils:getInstance():isFileExist(path) then
        local md5 = me.Helper:md5ofile(path)
        print(md5)
        if md5 ~= v.md5 then
            me.getHttpFile(globalUrl .. "/" .. v.name, callfunc, callerror, path)
        else
            callerror()
        end
    else
        me.getHttpFile(globalUrl .. "/" .. v.name, callfunc, callerror, path)
    end
end
function updateLayer:checkAndDownGlobalFiles(tb)
    local index = 1
    local num = #tb
    local function downComplete(args)
        index = index + 1
        local progress = string.format("校验资源中 ... %d%%  ", math.floor(index * 100 / num))
        self.Text_Update:setString(progress)
        self.LoadingBar_Update:setPercent(index * 100 / num)
        if index <= table.nums(tb) then
            if tb[index] then
                downFiles(tb[index], downComplete, downComplete)
            else
                self:enterGame()
            end
        else
            self:enterGame()
        end
    end
    if tb[index] then
        downFiles(tb[index], downComplete, downComplete)
    end
end
function updateLayer:getGlobalUpdateFiles(str)
    local temptable = me.split(str, ",")
    local tp = { }
    if temptable then
        for key, var in pairs(temptable) do
            local r = me.split(var, ":")
            if r then
                local temp = { }
                temp.name = r[1]
                temp.md5 = r[2]
                table.insert(tp, temp)
            end
        end
    end
    return tp
end
function updateLayer:showUpdateDialog(cfg)
    self.info:setVisible(true)
    self.bNeedDown = true    
    self.Text_Info:setString("当前版本已不可用，请下载最新的版本")
    if me.toNum(cfg.state) == 2 then
        -- 必须更新否则无法进入游戏
        self.Text_Info:setString(cfg.text)
        self.Button_Enter:setVisible(false)
        self.okBtn:setVisible(true)
        self.okBtn:setTitleText("更新")
        self.okBtn.cmd = BTN_COMMAN_GODOWN
        self.okBtn.cfg = cfg
        self.okBtn:setPositionX(self.info:getContentSize().width / 2)        
    elseif me.toNum(cfg.state) == 1 then
        -- 不更新也可以进入游戏
        self.Text_Info:setString(cfg.text)
        self.Button_Enter:setVisible(true)
        self.okBtn:setVisible(true)
        self.okBtn:setTitleText("更新")
        self.okBtn.cfg = cfg
        self.Button_Enter:setTitleText("取消")
        self.okBtn.cmd = BTN_COMMAN_GODOWN
        self.Button_Enter.cmd = BTN_COMMAN_ENTER        
    end
end
function updateLayer:getCheckUrl()
    return whiteUrl .. "?source=" .. getApkMeta().."&channel="..getSource().."&version="..getVersionInfo()
end
-- 获取APP版本号
function getAppVersion()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { url = "" }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "getAppVersion", args)
        if not ok then
            cc.Director:getInstance():resume()
            return nil
        else
            print("The ret is:", ret)
            return ret
        end
    end
end
-- 获取渠道号
function getAppBundleIdentifier()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { url = "" }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "getBundleIdentifier", args)
        if not ok then
            cc.Director:getInstance():resume()
            return nil
        else
            print("The ret is:", ret)
            return string.split(ret, ".")[3]
        end
    else
    end
    return nil
end
-- 获取Android  metadata 
function getMetaData(key)
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = { key }
        local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "getMetaData", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    end
end
-- 获取android version
function getVersionInfo()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = { }
        local sigs = "()I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/jnmo/emp/jjgame/AppActivity"
        local ok, ret = luaj.callStaticMethod(className, "getVersionInfo", args, sigs)
        if not ok then
            return ret
        else
            return ret
        end
    else
        return 1
    end
end
-- 获取IOS渠道号
function getAppIosChannelID()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { url = "" }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "getIosChannel", args)
        if not ok then
            cc.Director:getInstance():resume()
            return nil
        else
            print("The ret is:", ret)
            return ret
        end
    end
    return nil
end
-- 获取当前版本标记
function getSource()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        return getMetaData("UMENG_CHANNEL")
    elseif (cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_IPHONE == targetPlatform) then
        return getAppIosChannelID()
    elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        return PACKAGE_CHANNEL
    end
end
function getApkMeta()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        return getMetaData("PACKAGE_CHANNEL")
    elseif (cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_IPHONE == targetPlatform) then
        return getAppIosChannelID()
    elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        return PACKAGE_CHANNEL
    end
end
function getCurVersion()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        return getMetaData("PACKAGE_CHANNEL") .. "." .. getVersionInfo() .. "." ..(cc.UserDefault:getInstance():getStringForKey("localversion") or "1.0.0")
    elseif (cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_IPHONE == targetPlatform) then
        return getAppIosChannelID()
    elseif (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
        return PACKAGE_CHANNEL .. "." .. getVersionInfo() .. "." ..(cc.UserDefault:getInstance():getStringForKey("localversion") or "1.0.0")
    end
end
function updateLayer:enterGame()
    addSearchPath(pathToSave, true)
    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)
    for var = 1,#RES_SEARCH_PATH do
        addSearchPath(pathToSave .. "/" .. RES_SEARCH_PATH[var], true)
    end
    luaReload("requireList")    
    local m = loginView:create("loginScene.csb")
    local s = cc.Scene:create()
    s:addChild(m)
    app:runWithScene(s)
end
function updateLayer:onEnterTransitionDidFinish()
    print("updateLayer onEnterTransitionDidFinish")
end
function updateLayer:onExit()
    ass:release()
    print("updateLayer onExit")
end
function updateLayer:close()
    self:removeFromParentAndCleanup(true)
end

