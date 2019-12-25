loginView = class("cultureView", function(csb)
    return cc.CSLoader:createNode(csb)
end )
loginView.__index = loginView
loginView.loginDelyTime = 30
function loginView:create(csb)
    local layer = loginView.new(csb)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
function loginView:ctor()
    self.acc = nil
    self.pwd = nil
    -- 下发的服务器列表1
    self.tableView = nil
    -- 当前服务器Index
    self.cellViews = { }

    self.reconnectHttpTimes = 0
    self.curToken = nil
    -- 当前验证通过的令牌
end

randNames = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
randPsw = "01234567890_"
function loginView:init()



    self.Text_account = me.assignWidget(self, "Text_account")
    self.Text_curServser = me.assignWidget(self, "Text_curServser")
    self.Node_start = me.assignWidget(self, "Node_start")

    self.Node_account = me.assignWidget(self, "Node_account")
    self.Node_account:setVisible(false)

    me.registGuiTouchEventByName(self, "Button_servserList", function(node, event)
        if event == ccui.TouchEventType.ended then
            self:showServerList()
        end
    end )
    me.registGuiTouchEventByName(self, "bg", function(node, event)
        if event == ccui.TouchEventType.ended then
            self:removeCenterNode(self.loginBox)
            self:removeCenterNode(self.registerBox)
        end
    end )
    self.Button_begin = me.registGuiTouchEventByName(self, "Button_begin", function(node, event)
        if event == ccui.TouchEventType.ended then
            me.setWidgetCanTouchDelay(node, 1)
            if isAndroidPlatform() and SERVER_MODE == 1 then
                self:jjbeginGame()
            else
                self:beginGame()
            end
        end
    end )
    local Button_JJAcc = me.registGuiTouchEventByName(self, "Button_JJAcc", function(node, event)
        if event == ccui.TouchEventType.ended then
            if isAndroidPlatform() and SERVER_MODE == 1 then
                jjGameSdk.openUserInfo()
            else
                self:cellRightIn(self.loginBox)
            end
        end
    end )
    Button_JJAcc:setVisible(getMetaData("cn.jj.sdk.promoteid") ~= "0")
    if (isWindowsPlatform() or isIosPlatform()) or SERVER_MODE ~= 1 then
        Button_JJAcc:setVisible(true)
    end
    -- 登录界面控件
    self.loginBox = me.assignWidget(self, "loginBox")
    me.assignWidget(self.loginBox, "acc_input"):setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    me.assignWidget(self.loginBox, "psw_input"):setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    local function login_btn_callback(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        if node:getName() == "btn_login" then
            me.setWidgetCanTouchDelay(node, 1)
            self:beginGame()
        elseif node:getName() == "btn_register" then
            me.leftOutRightIn(self.loginBox, self.registerBox)
            self.acc = nil
            self.psw = nil
            me.assignWidget(self.registerBox, "acc_input"):setString("")
            me.assignWidget(self.registerBox, "psw_input"):setString("")
        elseif node:getName() == "btn_register_fast" then
            me.getHttpString(msgHttpURL.autoRegUrl(), function(response)
                if me.toNum(response.rs) ~= 1 then
                    showTips(TID_REG_ERROR)
                    return
                end
                self.curToken = response
                -- 记录当前令牌
                self:registCallBack(response.cn.uid, response.cn.account, response.cn.pwd)
            end , function()
                showTips(TID_HTTP_CONNECT_ERROR)
            end , true)
        elseif node:getName() == "Text_serverName" then
            self:setServerList()
            me.leftOutRightIn(self.loginBox, self.serverListBox)

        end
    end
    me.registGuiTouchEventByName(self.loginBox, "btn_login", login_btn_callback)
    me.registGuiTouchEventByName(self.loginBox, "btn_register", login_btn_callback)
    me.registGuiTouchEventByName(self.loginBox, "btn_register_fast", login_btn_callback)
    me.registGuiTouchEventByName(self.loginBox, "Text_serverName", login_btn_callback)
    -- me.assignWidget(self.loginBox, "psw_input"):addEventListener(textFiled_callback)
    -- me.assignWidget(self.loginBox, "acc_input"):addEventListener(textFiled_callback)

    -- 注册界面控件
    self.registerBox = me.assignWidget(self, "registerBox")
    me.assignWidget(self.registerBox, "acc_input"):setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    me.assignWidget(self.registerBox, "psw_input"):setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    local function regist_btn_callback(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        if node:getName() == "btn_close" then
            me.leftOutRightIn(self.registerBox, self.loginBox)
        elseif node:getName() == "btn_register" then
            -- t:258 v:1 c:{"account":"","pwd":"","gender":1,"source":""}
            local acc = me.assignWidget(self.registerBox, "acc_input"):getString()
            local pwd = me.assignWidget(self.registerBox, "psw_input"):getString()
            if not me.isValidStr(acc) or not me.isValidStr(pwd) then
                showTips(TID_ACC_PSW_CANNOT_NULL)
                return
            end
            me.getHttpString(msgHttpURL.regUrl(acc, pwd), function(response)
                if me.toNum(response.rs) == -4 then
                    showTips(TID_FAILED_HAS_ACCOUNT)
                    return
                elseif me.toNum(response.rs) == -3 then
                    showTips(TID_UNKNOWN_ERROR)
                    return
                elseif me.toNum(response.rs) == -2 then
                    showTips(TID_FAILED_PWD_NOT_MATCH)
                    return
                elseif me.toNum(response.rs) == -1 then
                    showTips(TID_FAILED_ACCOUNT_NOT_MATCH)
                    return
                end
                if response.cn.uid and response.cn.account and response.cn.pwd then
                    self:removeCenterNode(self.registerBox)
                    self.curToken = response
                    -- 记录当前令牌
                    self:registCallBack(response.cn.uid, response.cn.account, response.cn.pwd)
                else
                    showTips(TID_REG_ERROR)
                end
            end , function()
                showTips(TID_HTTP_CONNECT_ERROR)
            end , true)
        elseif node:getName() == "Text_serverName" then
            self:setServerList()
            me.leftOutRightIn(self.registerBox, self.serverListBox)

        end
    end
    me.registGuiTouchEventByName(self.registerBox, "btn_close", regist_btn_callback)
    me.registGuiTouchEventByName(self.registerBox, "btn_register", regist_btn_callback)
    me.registGuiTouchEventByName(self.registerBox, "Text_serverName", regist_btn_callback)
    -- me.assignWidget(self.registerBox, "acc_input"):addEventListener(textFiled_callback)
    -- me.assignWidget(self.registerBox, "psw_input"):addEventListener(textFiled_callback)
    me.registGuiClickEventByName(self, "Button_Notice", function(node)
        checkHaveNotice(true)
    end )
    self.evt = me.RegistCustomEvent("choose_server", function(rev)
        local sid = tonumber(rev._userData)
        self:sendConnect(sid)
    end )
    me.assignWidget(self, "Button_PlayCG"):setVisible(false)
    -- 注册监听消息
    self.modelkey = UserModel:registerLisener( function(msg)
        self:revMsg(msg)
    end )
    me.registGuiClickEventByName(self, "Text_Del", function(node)
        delUpdate()
    end )
    self.textVer = me.assignWidget(self, "Text_Ver")
    self.textVer:setString(getCurVersion())
    CUR_GAME_STATE = GAME_STATE_LOGON
    self.Button_begin:setVisible(false)
    return true
end
-- 注册成功的回调
function loginView:registCallBack(uid_, acc_, pwd_)
    showTips(TID_REG_SUCESS)
    self.curToken = nil
    self:removeCenterNode(self.loginBox)
    self.acc = acc_
    self.pwd = pwd_
    SharedDataStorageHelper():setUserAccountNEW(self.acc)
    SharedDataStorageHelper():setUserPassword(self.pwd)
    self:setLoginInfo()

    local function afterCaptured(succeed, outputFile)
        if succeed then
            if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
                local args = { name = outputFile }
                local luaoc = require "cocos.cocos2d.luaoc"
                local className = "AppController"
                local ok, ret = luaoc.callStaticMethod(className, "viewDidAppear", args)
                if not ok then
                    cc.Director:getInstance():resume()
                else
                    print("The ret is:", ret)
                end
            end
        else
            print("Capture screen failed.")
        end
    end
    --    if IAP_URL ~= "http://115.231.101.138:8080" then
    --        cc.utils:captureScreen(afterCaptured, "screen.png")
    --    end
    --        me.showMessageDialog(TID_REG_SUCESS, function()
    --            self:beginGame()
    --        end , 1)
    TalkingData_onRegister(acc_)
end
function loginView:revMsg(msg)
    -- 检测是否是注册消息返回
    if checkMsg(msg.t, MsgCode.AUTH_ENTRY_GAME) or checkMsg(msg.t, MsgCode.AUTH_SIGN_LOGIN) then
        -- 登录成功
        disWaitLayer(true)
        SharedDataStorageHelper():setUserAccount(msg.c.uid or "")
        user.countryId = msg.c.value
        if msg.c.time then
            server.systime = msg.c.time
            server.sysoffset = server.systime - socket.gettime() * 1000
        end
        local load_ = loadingLayer:create("loadScene.csb", true)
        me.runScene(load_)
    elseif checkMsg(msg.t, MsgCode.AUTH_SELECT_COUNTRY) then
        SharedDataStorageHelper():setUserAccount(msg.c.uid or "")
        -- 还没有国家需要选择国家
        local clayer = cultureView:create("raceScene.csb")
        me.runScene(clayer)
    end
end
-- 设置登录界面信息
function loginView:setLoginInfo()
    local curName = SharedDataStorageHelper():getLastLoginName()
    local sid = SharedDataStorageHelper():getLastLoginSID()
    self.acc = SharedDataStorageHelper():getUserAccountNEW()
    self.pwd = SharedDataStorageHelper():getUserPassword()
    if me.isValidStr(sid) and me.isValidStr(curName) then
        me.assignWidget(self.loginBox, "acc_input"):setString(self.acc)
        me.assignWidget(self.loginBox, "psw_input"):setString(self.pwd)
    else
        curName = "未选择服务器"
        me.assignWidget(self.loginBox, "acc_input"):setString(self.acc)
        me.assignWidget(self.loginBox, "psw_input"):setString(self.pwd)
    end
    self.Text_curServser:setString(curName)
end
function loginView:sendServerListMsg()
    user.servsers = { }
    me.getHttpString(msgHttpURL.servsersUrl(APP_VER), function(response)
        if me.toNum(response.rs) ~= 1 then
            showTips(TID_SERVER_DOWN)
            return
        end
        for key, var in pairs(response.cn) do
            user.servsers[#user.servsers + 1] = servserData.new(var.sid, "ws://" .. var.ip .. ":" .. var.port .. "/", var.name, var.type, var.status, var.text)
        end
        table.sort(user.servsers, function(a, b)
            return a.sid < b.sid
        end )
        self:setDefaultServer()
        self:setLoginInfo()
    end , function()
        -- 间隔三次重连不上 就弹出选择框
        if self.reconnectHttpTimes < 3 then
            showWaitLayer()
            me.DelayRun( function()
                self:sendServerListMsg()
                disWaitLayer()
            end , 0)
            self.reconnectHttpTimes = self.reconnectHttpTimes + 1
        else
            disWaitLayer()
            self.reconnectHttpTimes = 0
            me.reconnectDialog(TID_HTTP_CONNECT_ERROR, function(args)
                if args == "ok" then
                    self:sendServerListMsg()
                else
                    me.Helper:endGame()
                end
            end )
        end
    end , true)
end
-- 设置默认服务器
function loginView:setDefaultServer()
    local sid = SharedDataStorageHelper():getLastLoginSID()
    local sdata = self:getServerDataBySid(sid)
    if sdata then
        SharedDataStorageHelper():setLoginInfo(sdata.ip, sdata.name, sdata.sid)
    else
        local choose = false
        for key, var in pairs(user.servsers) do
            if me.toNum(var.status) == 3 or me.toNum(var.status) == 2 then
                SharedDataStorageHelper():setLoginInfo(var.ip, var.name, var.sid)
                choose = true
                break
            end
        end
        if choose == false and #user.servsers then
            local v = user.servsers[1]
            SharedDataStorageHelper():setLoginInfo(v.ip, v.name, v.sid)
        end
    end
end
function loginView:showServerList()
    local sl = serverListLayer:create("serverLayer.csb")
    me.popLayer(sl)
end
function loginView:getServerDataBySid(sid)
    for key, var in pairs(user.servsers) do
        if me.toNum(var.sid) == me.toNum(sid) then
            return var
        end
    end
    return nil
end
-- 设置当前所选服务器，并判断有没有登录帐号。
function loginView:sendConnect(sid)
    self.curToken = nil
    -- 重置令牌
    local curSer = self:getServerDataBySid(sid)
    SharedDataStorageHelper():setLoginInfo(curSer.ip, curSer.name, curSer.sid)
    self:setLoginInfo()
end
function loginView:onEnter()
    umengInit()
    me.showMemory()
    me.registTimer(-1, function(args)
        me.showMemory()
    end , 10)
    print("loginView onEnter")
    me.doLayout(self, me.winSize)
    mAudioMusic = AudioMusic:create()
    self:setLoginInfo()
    checkHaveNotice()
    -- 检查是否有公告
    self:sendServerListMsg()
    self:registIDFA()
    local function jjGameSdkLoginCall(result)
        local errcode = tonumber(result)
        if errcode and(errcode == 1001 or errcode == 10001) then
            me.showMessageDialog("登录失败，请重新登录大厅后启动游戏", function(evt)
                if evt == "ok" then
                    me.Helper:endGame()
                end
            end , 1)
        else
            local js = me.cjson.decode(result)
            user.sdkid = js.UserID
        end
    end
    if jjGameSdk.isCurrentLogin() == 0 then
        jjGameSdk.loginSdk(jjGameSdkLoginCall)
    end
    self.Button_begin:setVisible(true)
    jjGameSdk.UMLOG_EnterLoginPage()

    self.sk = sp.SkeletonAnimation:create("animation/diguo.json", "animation/diguo.atlas", 0.26)
    me.assignWidget(self, "spineNode"):addChild(self.sk)
    self.sk:setPosition(me.winSize.width / 2, -100)
    self.sk:setAnimation(0, "animation", true)   
end
function loginView:registIDFA()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) then
        local args = { url = "1" }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "getIDFA", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
        end
    else

    end
end
function loginView:onExit()
    print("loginView onExit")
    NetMan:removeNetLisener(self.netkey)
    UserModel:removeLisener(self.modelkey)
    me.RemoveCustomEvent(self.evt)
    self.curToken = nil
end 
-- 移开在中间显示的框体
function loginView:removeCenterNode(node)
    if me.toNum(node:getPositionX()) == me.toNum(me.winSize.width / 2) then
        self.Node_start:setVisible(true)
        me.leftOut(node)
    end
end
function loginView:cellRightIn(node)
    if me.toNum(node:getPositionX()) == me.toNum(me.winSize.width / 2) then
        return
    end
    self.Node_start:setVisible(false)
    me.RightIn(node)
end
function loginView:onConnectGameServer(msg)
    if msg.cmd == USER_EVT_WEBSOCKET_OPEN then
        local response = self.curToken
        if response then
            showWaitLayer(true)
            NetMan:send(_MSG.signLogin(response.cn))
        else
            showTips(TID_NOT_FIND_TOKEN)
        end
    elseif msg.cmd == USER_EVT_WEBSOCKET_CLOSE then
        showTips(TID_HTTP_CONNECT_ERROR)
    end
end
function loginView:toConnectGameServer(token)
    local serverdata = self:getServerDataBySid(token.cn.sid)
    if self.netkey then
        NetMan:removeNetLisener(self.netkey)
    end
    self.netkey = NetMan:registNetLisener( function(msg)
        if msg.cmd == USER_EVT_WEBSOCKET_OPEN then
            self:onConnectGameServer(msg)
        else
            showTips(TID_HTTP_CONNECT_ERROR)
        end
    end )
    NetMan:connect(serverdata.ip)
end
function loginView:beginGame()
    local sid = SharedDataStorageHelper():getLastLoginSID()
    if self:getServerDataBySid(sid) and self:getServerDataBySid(sid).state_down == true then
        showTips(TID_SERVER_DOWN)
        return
    end
    if not me.isValidStr(sid) then
        self:removeCenterNode(self.loginBox)
        self:removeCenterNode(self.registerBox)
        showTips(TID_CONNECT_NOT_CHOOSE)
        return
    end
    self.acc = me.assignWidget(self.loginBox, "acc_input"):getString()
    self.pwd = me.assignWidget(self.loginBox, "psw_input"):getString()

    if not me.isValidStr(self.acc) or not me.isValidStr(self.pwd) then
        showTips(TID_ACC_PSW_CANNOT_NULL)
        self:cellRightIn(self.loginBox)
        return
    end
    if self.curToken then
        self:toConnectGameServer(self.curToken)
    else
        me.getHttpString(msgHttpURL.loginUrl(self.acc, self.pwd, sid), function(response)
            if me.toNum(response.rs) ~= 1 then
                showTips(TID_ACC_PSW_CANNOT_ERROR)
                return
            end
            if response.cn.time and response.cn.sid and response.cn.token and response.cn.pid and response.cn.gid then
                self.curToken = response
                user.sdkid = self.acc
                SharedDataStorageHelper():setUserAccountNEW(self.acc)
                SharedDataStorageHelper():setUserPassword(self.pwd)
                local msg = SharedDataStorageHelper():loadLastServerList(user.sdkid)
                if me.isValidStr(msg) then
                    local serverdatalist = me.cjson.decode(msg)
                    serverdatalist[sid] = { }
                    serverdatalist[sid].sid = sid
                    serverdatalist[sid].time = me.sysTime()
                    SharedDataStorageHelper():saveLastServerList(user.sdkid, me.cjson.encode(serverdatalist))
                else
                    local serverdatalist = { }
                    serverdatalist[sid] = { }
                    serverdatalist[sid].sid = sid
                    serverdatalist[sid].time = me.sysTime()
                    SharedDataStorageHelper():saveLastServerList(user.sdkid, me.cjson.encode(serverdatalist))
                end
                self:toConnectGameServer(self.curToken)
            else
                showTips(TID_ACC_PSW_CANNOT_ERROR)
            end
        end , function()
            showTips(TID_HTTP_CONNECT_ERROR)
        end , true)
    end
end
function loginView:jjbeginGame()
    local sid = SharedDataStorageHelper():getLastLoginSID()
    local sdata = self:getServerDataBySid(sid)
    if not me.isValidStr(sid) then
        showTips(TID_CONNECT_NOT_CHOOSE)
        return
    end
    local function verifyOid(result)
        local js = me.cjson.decode(result)
        me.getHttpString(msgHttpURL.jjverify(js.RequestToken, sid), function(response)
            if me.toNum(response.rs) ~= 1 then
                me.showMessageDialog(response.cn, function(args)
                    if args == "ok" then
                    end
                end , 1)
                return
            end
            if response.cn.time and response.cn.sid and response.cn.token and response.cn.pid and response.cn.gid then
                self.curToken = response
                self:toConnectGameServer(self.curToken)
                local msg = SharedDataStorageHelper():loadLastServerList(user.sdkid)
                if me.isValidStr(msg) then
                    local serverdatalist = me.cjson.decode(msg)
                    serverdatalist[sid] = { }
                    serverdatalist[sid].sid = sid
                    serverdatalist[sid].time = me.sysTime()
                    SharedDataStorageHelper():saveLastServerList(user.sdkid, me.cjson.encode(serverdatalist))
                else
                    local serverdatalist = { }
                    serverdatalist[sid] = { }
                    serverdatalist[sid].sid = sid
                    serverdatalist[sid].time = me.sysTime()
                    SharedDataStorageHelper():saveLastServerList(user.sdkid, me.cjson.encode(serverdatalist))
                end
                jjGameSdk.UMLOG_UserLogin(response.cn.gid)
            else
                me.reconnectDialog("验证失败，是否重新验证？", function(args)
                    if args == "ok" then
                        jjGameSdk.getOidAndVerify(verifyOid)
                    else
                        me.Helper:endGame()
                    end
                end )
            end
        end , function()
            me.reconnectDialog("请求超时，是否重新验证？", function(args)
                if args == "ok" then
                    jjGameSdk.getOidAndVerify(verifyOid)
                else
                    me.Helper:endGame()
                end
            end )
        end , true)
    end
    local function jjGameSdkLoginCall(result)
        local errcode = tonumber(result)
        if errcode and(errcode == 1001 or errcode == 10001) then
            me.showMessageDialog("登录失败，请重新登录大厅后启动游戏", function(evt)
                if evt == "ok" then
                    me.Helper:endGame()
                end
            end , 1)
        else
            local js = me.cjson.decode(result)
            user.sdkid = js.UserID
            jjGameSdk.getOidAndVerify(verifyOid)
        end
    end
    if jjGameSdk.isCurrentLogin() == 0 then
        jjGameSdk.loginSdk(jjGameSdkLoginCall)
    else
        jjGameSdk.getOidAndVerify(verifyOid)
    end
end
