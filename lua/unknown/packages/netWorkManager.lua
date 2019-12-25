netWorkManager = class("netWorkManager")
netWorkManager.__index = netWorkManager
m_netWorkManager = nil
n_netWorkManager = nil

-- ****************************************  webSoket通信协议  ************************************************************
netState_Disconnected = 1
netState_Connecting = 2
netState_Connected = 3

function netWorkManager:ctor(var, gg)
    print("netWorkManager:ctor()")
    self.websocket = nil
    self.XMLHttp = nil
    self.msglisener = { }
    self.netlisener = { }
    self.bShowNetInterrupt = false
end
function netWorkManager.getInstance()
    if nil == m_netWorkManager then
        m_netWorkManager = netWorkManager.new()

    end
    return m_netWorkManager
end
function netWorkManager.getInstance_netBattle()
    if nil == n_netWorkManager then
        n_netWorkManager = netWorkManager.new()

    end
    return n_netWorkManager
end

function RecurTabel(msg)
    -- value = ""
    -- for k,v in pairs(msg) do
    --     if type(v) == "table" then 
    --         for k2,v2 in pairs(v) do
    --             if
    --             value = "sec "..value .. v2
    --         end
    --     else 
    --         value = value .." " ..v
    --     end
    -- end
    -- print (value)
    -- if msg.t == 543 then 
    --     -- print ("招募士兵")
    --     -- local str = me.cjson.encode(msg)
    --     -- self.websocket:sendString(str)
    --     -- print("send --msg " .. str)

    -- end
    -- if msg.t == 3604 then 
    --     -- msg.c.lv =   -99654635
    --     -- msg.c.army[1].num = -9999999000
    --     -- msg.c.army[1].id = -99999
    --     msg.c.amount = 0x80000000
    -- end
    if msg.t == 1557 then 
        -- msg.c.num = 2
        -- msg.c.ox = -1
    end
end


function netWorkManager:send(msg)
    if self.websocket and self.websocket:getReadyState() == cc.WEBSOCKET_STATE_OPEN then
        RecurTabel(msg)
        local str = me.cjson.encode(msg)
        self.websocket:sendString(str)
        -- print(debug.traceback("Pareto"))
        print("send --msg " .. str)
    else
        if CUR_GAME_STATE == GAME_STATE_CITY or CUR_GAME_STATE == GAME_STATE_WORLDMAP
            or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE
            or CUR_GAME_STATE == GAME_STATE_LOADING_CITY
            or CUR_GAME_STATE == GAME_STATE_LOADING_WORLD
        then
            if user.Cross_Sever_Status == mCross_Sever_Out then
                self:showInterrupt()
            end
            disWaitLayer()
        end
        print("netWorkManager:Error!")
    end
end
-- 跨服socket连接
function netWorkManager:netBattleOpen()
    if self.websocket and self.websocket:getReadyState() == cc.WEBSOCKET_STATE_OPEN then
        return true
    else
        return false
    end
    return false
end
function netWorkManager:showInterrupt()
    if not self.bShowNetInterrupt then
        -- me.clearTimer(self.pingTimer)
        print("网络接收数据异常，是否自动重连服务器？")
        me.reconnectDialog("网络接收数据异常，是否自动重连服务器？", function(args)
            if args == "ok" then
                me.clearTimer(self.pingTimer)
                self.bShowNetInterrupt = false
                local loadtomenu = loadBackMenu:create("loadScene.csb")
                me.runScene(loadtomenu, 1)
            else
                me.Helper:endGame()
            end
        end )
        self.bShowNetInterrupt = true
    end
end
function netWorkManager:ping()
    self.pingTimer = me.registTimer(-1, function(dt)
        self:send(_MSG.pingMsg())
    end , 10, "PING")
end
function netWorkManager:connect(url)
    showWaitLayer()
    if self.websocket and(self.websocket:getReadyState() == cc.WEBSOCKET_STATE_CONNECTING or self.websocket:getReadyState() == cc.WEBSOCKET_STATE_OPEN) then
    	self.websocket:close() 
        self.bShowNetInterrupt = true
        me.clearTimer(self.pingTimer)       
    end
    self.websocket = cc.WebSocket:create(url)
    print("netWorkManager:connect = " .. url)
    local function websocketOpen(strData)
        print("websocketOpen")
        disWaitLayer()
        local msg = { }
        msg.cmd = USER_EVT_WEBSOCKET_OPEN
        msg.data = strData
        self:ping()
        for key, var in pairs(self.netlisener) do
            var(msg)
        end
    end
    local function websocketMessage(strData)
        print("rev msg:" .. strData)
        local msg = me.cjson.decode(strData)
        if msg.t == 517 then 
            local msg2 = { }
            msg2.t = MsgCode.CITY_BUILDING_UPLEVEL
            msg2.v = MSGVER
            msg2.c = { }
            msg2.c.index = 2004
            msg2.c.farmer = 10
            -- 升级的农民数
            msg2.c.quick = 1
            -- 1为快速建造 0为普通
            local str = me.cjson.encode(msg2)
            self.websocket:sendString(str)

        end
        if msg.t == MsgCode.PONG then
            disWaitLayer()
        end
        --    Queue.push(self.msgQueue,msg)
        for key, var in pairs(self.msglisener) do
            var(msg)
        end
    end
    local function websocketClose(strData)
        -- print(type(strData).."-3"..strData)
        disWaitLayer()
        local msg = { }
        msg.cmd = USER_EVT_WEBSOCKET_CLOSE
        msg.data = strData
        for key, var in pairs(self.netlisener) do
            var(msg)
        end
        print("websocketClose")
    end
    local function websocketError(strData)
        -- print(type(strData).."-4"..strData)
        local msg = { }
        msg.cmd = USER_EVT_WEBSOCKET_ERROR
        msg.data = strData
        for key, var in pairs(self.netlisener) do
            var(msg)
        end
        if CUR_GAME_STATE == GAME_STATE_CITY or CUR_GAME_STATE == GAME_STATE_WORLDMAP
            or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE
            or CUR_GAME_STATE == GAME_STATE_LOADING_CITY
            or CUR_GAME_STATE == GAME_STATE_LOADING_WORLD
        then
            if user.Cross_Sever_Status == mCross_Sever then
                if netBattleMan then
                    netBattleMan:removeAllNetLisener()
                    netBattleMan:removeAllMsgLisener()
                    netBattleMan:closeQuiet()
                end
            end
            self:showInterrupt()
            disWaitLayer()
        end
        print("websocketError !!!!")
    end
    if nil ~= self.websocket then
        self.websocket:registerScriptHandler(websocketOpen, cc.WEBSOCKET_OPEN)
        self.websocket:registerScriptHandler(websocketMessage, cc.WEBSOCKET_MESSAGE)
        self.websocket:registerScriptHandler(websocketClose, cc.WEBSOCKET_CLOSE)
        self.websocket:registerScriptHandler(websocketError, cc.WEBSOCKET_ERROR)
    end
end
function netWorkManager:registMsgLisener(lisener_)
    local guid = me.sysTime() .. "_msg_" ..(me.sysTime() % 10234) .. "jnmogod"
    self.msglisener[guid] = lisener_
    return guid
end

function netWorkManager:removeMsgLisener(key)
    self.msglisener[key] = nil
end
function netWorkManager:registNetLisener(lisener_)
    local guid = me.sysTime() .. "_netsys_" ..(me.sysTime() % 10234) .. "jnmogod"
    self.netlisener[guid] = lisener_
    return guid
end
function netWorkManager:removeNetLisener(key)
    if self.netlisener[key] then
        self.netlisener[key] = nil
    end
end
function netWorkManager:removeAllNetLisener()
    for key, var in pairs(self.netlisener) do
        var = nil
    end
    self.netlisener = { }
end
function netWorkManager:removeAllMsgLisener(key)
    for key, var in pairs(self.msglisener) do
        var = nil
    end
    self.msglisener = { }
end
function netWorkManager:reconnect()
    local ip = SharedDataStorageHelper():getLastLoginIp()
    local acc = SharedDataStorageHelper():getUserAccount()
    local pwd = SharedDataStorageHelper():getUserPassword()
    local sid = SharedDataStorageHelper():getLastLoginSID()
    -- me.clearTimer(self.netState)
    me.clearTimer(self.pingTimer)
    me.getHttpString(msgHttpURL.loginUrl(acc, pwd, sid), function(response)
        if me.toNum(response.rs) ~= 1 then
            showTips(TID_ACC_PSW_CANNOT_ERROR)
            return
        end
        local response_ = response
        local function reconnectcall(msg)
            if msg.cmd == USER_EVT_WEBSOCKET_OPEN then
                self:send(_MSG.reSignLogin(response_.cn))
            else
                showTips(TID_HTTP_CONNECT_ERROR)
            end
        end
        if self.reconnectCallback then
            self:removeNetLisener(self.reconnectCallback)
        end
        self.reconnectCallback = self:registNetLisener(reconnectcall)
        if response.cn.time and response.cn.sid and response.cn.token and response.cn.pid and response.cn.gid then
            self:connect(ip)
        else
            showTips("连接中断")
        end
    end , function(msg)
        -- me.showMessageDialog("网络中断，")
    end , true)

end
-- 关闭链接，且不弹窗提示
function netWorkManager:closeQuiet()
    self.bShowNetInterrupt = true
    me.clearTimer(self.pingTimer)
    self:close()
end
function netWorkManager:close()
    if self.websocket and(self.websocket:getReadyState() == cc.WEBSOCKET_STATE_CONNECTING or self.websocket:getReadyState() == cc.WEBSOCKET_STATE_OPEN) then
        self.websocket:close()
    end
    me.clearTimer(self.pingTimer)
    self:removeAllNetLisener()
    self:removeAllMsgLisener()
    self.bShowNetInterrupt = false

end
-- ****************************************  webSoket通信协议  ************************************************************
-- 游戏服
NetMan = netWorkManager.getInstance()
-- 跨服战
netBattleMan = netWorkManager.getInstance_netBattle()
-- 通用 在外城的时候根据状态选择
function GMan()
    if user.Cross_Sever_Status == mCross_Sever then
        return netBattleMan
    else
        return NetMan
    end
    return NetMan
end

