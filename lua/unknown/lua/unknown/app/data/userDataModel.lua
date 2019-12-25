
UserDataModel = class("UserDataModel")
UserDataModel.__index = UserDataModel
m_userDataModel = nil
function UserDataModel:ctor()
    print("userDataModel:ctor()")
    self.msglisener = { }
    self.msgControlQueue = Queue.new()
end
function UserDataModel.getInstance()
    if nil == m_userDataModel then
        m_userDataModel = UserDataModel.new()
        m_userDataModel.msgkey = NetMan:registMsgLisener( function(msg)
            m_userDataModel:reviceData(msg, mCross_Sever_Out)
        end )
    end
    return m_userDataModel
end
function UserDataModel:registNetBattleLisener()
    UserModel.netbattlekey = netBattleMan:registMsgLisener( function(msg)
        UserModel:reviceData(msg, mCross_Sever)
    end )
end
function UserDataModel:removeNetBattleLisener(args)
    netBattleMan:removeMsgLisener(UserModel.netbattlekey)
end
function UserDataModel:goLogon()
    cfg = nil
    user = nil  
    self:purge()  
    me.clearAllTimer()
    NetMan:close()
    mainCity = nil
    pWorldMap = nil
    unLoadPackage()
    luaReload("main")
    if self.mScheduler then
        me.clearTimer(self.mScheduler);
        self.mScheduler = nil
    end
end
function UserDataModel:reviceData(msg, pType,control)
    if checkMsg(msg.t, MsgCode.PONG) then
        -- 心跳消息
        --         print("me.sysTime()"..me.sysTime().."----"..server.sysoffset.."------"..server.systime)
        if mCross_Sever == pType then
            server.Cross_systime = me.toNum(msg.c.t)
            server.Cross_sysoffset = server.Cross_systime - socket.gettime() * 1000
        end
        if mCross_Sever_Out == pType then
            server.systime = me.toNum(msg.c.t)
            server.sysoffset = server.systime - socket.gettime() * 1000
        end
        return
    elseif checkMsg(msg.t, MsgCode.ERROR_ALERT) then
        self:errorAlert(msg)
        return
    elseif checkMsg(msg.t, MsgCode.ROLE_INFO) then
        -- 实始化角色信息
        self:initUserInfo(msg)
        if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
            payMgr:getInstance():checkIapOrder()
            payMgr:getInstance():inquireAllItem()
        end

    --装扮列表和装扮更新
    elseif checkMsg(msg.t, MsgCode.MSG_ADORNMENT_LIST) or checkMsg(msg.t, MsgCode.MSG_ADORNMENT_UPDATE) then
        user.showTotem = msg.c.showTotem
        user.citySkinDatas = { }
        local center = { }
        center.id = 0
        if tonumber(msg.c.curr) == 0 then
            center.status = 1
        else
            center.status = 0
        end
        center.duration = -1
        -- 写死的
        center.strengthen = 100
        table.insert(msg.c.list, center)
        for key, var in pairs(cfg[CfgType.CITY_SKIN]) do
            if var.type == 1 then
                local defid = 0
                for k, v in pairs(cfg[CfgType.SKIN_STRENGTHEN]) do
                    if var.id == tonumber(v.typeid) and v.lv == 1 then
                        defid = v.id
                        break
                    end
                end
                local skin = skinData.new(var.id, defid)
                for k, v in pairs(msg.c.list) do
                    if v.id == var.id then
                        skin.status = v.status
                        skin.duration = v.duration
                        skin.defid = v.strengthen
                    end
                end
                user.citySkinDatas[var.id] = skin
            end
        end
        -- 图腾
        user.citySkinTotemDatas = { }
        for key, var in pairs(cfg[CfgType.CITY_SKIN]) do
            if var.type == 2 then
                local defid = 0
                for k, v in pairs(cfg[CfgType.SKIN_STRENGTHEN]) do
                    if var.id == tonumber(v.typeid) and v.lv == 1 then
                        defid = v.id
                        break
                    end
                end
                local skin = skinData.new(var.id, defid)
                for k, v in pairs(msg.c.totem) do
                    if v.id == var.id then
                        skin.status = v.status
                        skin.duration = v.duration
                        skin.defid = v.strengthen
                    end
                end
                user.citySkinTotemDatas[var.id] = skin
            end
        end
    -- 隐藏/展示外城图腾
    elseif checkMsg(msg.t, MsgCode.MSG_SHOW_TOTEM) then
        user.showTotem = msg.c.showTotem
    elseif checkMsg(msg.t, MsgCode.WORLD_TASK_NAME_LIST) then
        user.serverTaskList = msg.c
    elseif checkMsg(msg.t, MsgCode.WORLD_TASK_NAME_VIEW) then

    elseif checkMsg(msg.t, MsgCode.MSG_ADORNMENT_EQUIPT) then
        user.adornment = msg.c.id
        user.totem = msg.c.totem
        if tonumber(user.adornment) ~= 0 or user.totem ~= 0 then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_SKIN)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 100))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        end
    elseif checkMsg(msg.t, MsgCode.UPDATE_ROLE_TITLE) then
        user.title = msg.c.title
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_MOVE_CITY) then
        self:updatamoveCity(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_RANK) then
        me.tableClear(user.CrossSeverRank)
        if msg.c.list then
            for key, var in pairs(msg.c.list) do
                local pData = Cross_SeverRank.new(var.server, var.data, var.begin, var.close, var.name)
                table.insert(user.CrossSeverRank, pData)
            end
        end
    -- 充值检测
    elseif checkMsg(msg.t, MsgCode.RECHARGE_CHECK) then
        if cc.PLATFORM_OS_IPHONE == targetPlatform or cc.PLATFORM_OS_IPAD == targetPlatform then
            payMgr:getInstance():getOrderId(ORDER_SOURCE_APPLE)
        else
            payMgr:getInstance():getOrderId(ORDER_SOURCE_JJ)
        end
    -- 禁卫军科技初始化
    elseif checkMsg(msg.t, MsgCode.MSG_GUARD_TECH_UP_LEVLE) or checkMsg(msg.t, MsgCode.MSG_GUARD_TECH_INIT) then
        user.guard_tech = msg.c.list
    -- 
    elseif checkMsg(msg.t, MsgCode.MSG_BOOK_TECH_MENU) then
        if msg.c.list then
            user.arch_tech_book = msg.c.list
        end
    -- 图鉴科技1415
    elseif checkMsg(msg.t, MsgCode.MSG_BOOK_TECH_UP_LEVL) then
        for key, var in pairs(user.arch_tech_book) do
            if var.id == msg.c.id then
                var.techId = msg.c.techId
                var.exp = msg.c.exp
            end
        end
    -- 战舰改装
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT) then 
        user.shipRefixData = msg.c      
    -- 战舰改装背包
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_BAG) then 
        user.shipRefixBagData = msg.c.shipArmours
    -- 重连
    elseif checkMsg(msg.t, MsgCode.AUTH_SIGN_RELOGIN) then
        -- 为0 的时候直接连接服务器，暂时不用
        --        if me.toNum(msg.c.v) == 0 then
        --            NetMan:send(_MSG.loadDataMsg(1))
        --            gameMap.mapCellDatas = { }
        --            gameMap.troopData = { }
        --            initUserData()
        --            mainCity = nil
        --            local load_ = loadingLayer:create("loadScene.csb", false)
        --            me.runScene(load_)
        --        else
        -- self:goLogon()--退回到菜单
        local loadtomenu = loadBackMenu:create("loadScene.csb")
        me.runScene(loadtomenu)
        --  end
    -- 领主经验更新
    elseif checkMsg(msg.t, MsgCode.ROLE_EXP_UPDATE) then
        if me.toNum(msg.c.level) ~= me.toNum(user.lv) then
            showRoleUpgradeBox(msg.c)
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_LEVELUP)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 100))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        else
            if msg.c.process then
                if me.toNum(msg.c.process) == 48 and me.toNum(msg.c.exp) > 0 then
                    showTipsNoBg("经验x" .. msg.c.exp - user.exp)
                elseif me.toNum(msg.c.process) == 106 or me.toNum(msg.c.process) == 268  and me.toNum(msg.c.exp) > 0 then
                    showTips("领主经验 +" .. msg.c.exp - user.exp)
                end
            end
        end        
        user.lv = msg.c.level
        user.exp = msg.c.exp
    -- 荣誉科技565
    elseif checkMsg(msg.t, MsgCode.MSG_CITY_HONOUR_TECH) then
        user.hornor_tech = msg.c

    elseif checkMsg(msg.t, MsgCode.MSG_GUARD_TECH_INIT) then
        --- 守军科技
        user.guard_tech = msg.c.list
    -- VIP礼包
    elseif checkMsg(msg.t, MsgCode.VIP_DAY_BUY) then
        if tonumber(msg.c.daily) == 0 then
            showTips("VIP每日礼包领取成功")
        elseif tonumber(msg.c.daily) == 1 then
            showTips("VIP尊享礼包购买成功")
        end
    -- 充值结果
    elseif checkMsg(msg.t, MsgCode.RECHAGE_RESULT) then
        me.showMessageDialog("支付成功", function(evt) end, 1)
        if getMetaData("cn.jj.sdk.promoteid") ~= "0" 
        and getMetaData("cn.jj.sdk.promoteid") ~= "4503983" 
        and getMetaData("cn.jj.sdk.promoteid") ~= "4504004"
        and getMetaData("cn.jj.sdk.promoteid") ~= "4504025"
        and getMetaData("cn.jj.sdk.promoteid") ~= "4504036"
        and getMetaData("cn.jj.sdk.promoteid") ~= "4503444"
        and getMetaData("cn.jj.sdk.promoteid") ~= "4503457"
        then
            jjGameSdk.UMLOG_PAY(msg.c.id)
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_GEM_UPDATE) then
        -- 钻石
        self:updateGem(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_PAYGEM_UPDATE) then
        self:updatePayGem(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then
        -- 食物
        self:updateFood(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) then
        -- 木材
        self:updateWood(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) then
        -- 更新石头
        self:updateStone(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) then
        -- 更新黄金
        self:updateGold(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_RESOURCE_UPDATE) then
        -- 资源更新 包含 木材 石头 食物
        self:updateResource(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM) then
        -- 初始化背包道具
        self:initUserBackPack(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_CITY_HONOUR_TECH_UP_LEVEL) then
        local beforeDefId = msg.c.beforeDefId
        for key, var in pairs(user.hornor_tech.rankList) do
            for k, v in pairs(var.techList) do
                if tonumber(beforeDefId) == v.defId then
                    user.hornor_tech.rankList[key].techList[k].defId = msg.c.defId
                    user.hornor_tech.rankList[key].techList[k].lv = msg.c.lv
                    break
                end
            end
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_CROSS_APPLY_AUTH) then
        -- 请求跨服数据
        local uid = msg.c.uid
        local time = msg.c.time
        local sid = msg.c.sid
        local token = msg.c.token
        local url = msg.c.url
        local port = msg.c.port
        UserDataModel._netbattlekey = netBattleMan:registNetLisener( function(msg)
            if msg.cmd == USER_EVT_WEBSOCKET_OPEN then
                -- 注册跨服消息监听
                self:registNetBattleLisener()
                netBattleMan:send(_MSG.NetBattlePlayerAuthMsg(uid, time, sid, token))
            else
                --  showTips("跨服服务器连接失败")
            end
        end )
        netBattleMan:connect("ws://" .. url .. ":" .. port)
    elseif checkMsg(msg.t, MsgCode.MSG_CROSS_PLAYER_ENTRY) then
        -- 游戏服的基础数据
        user.x = msg.c.x
        user.y = msg.c.y
        -- 是否是盟主 用于标记
        user.officeDegree = msg.c.familyDegree
        -- msg.c.deg
        user.majorCityCrood = cc.p(user.x, user.y)
        me.tableClear(user.throne_plot)
        user.throne_plot = msg.c.ts
        user.lansize = msg.c.lansize
        user.Maxlansize = msg.c.maxLansize
        GMan():send(_MSG.Cross_Chat_Record())
        if First_City then
            for key, var in pairs(msg.c.ts) do
                local state = 0
                if var.my == 1 then
                    -- 自己阵营
                    state = 4
                else
                    state = 1
                end
                cellData = mapCellData.new(var.x, var.y, POINT_THRONE, 0, state, -1, -1, 0, 0, 0, 0, 0, nil, nil)
                local id = cellData:getId()
                gameMap.mapCellDatas[id] = cellData
                local near = getThroneNearCrood(cc.p(var.x, var.y)) or { }
                local fid = me.getFortIdByCoord(cc.p(var.x, var.y))
                for k, v in pairs(near) do
                    local cellData = mapCellData.new(v.x, v.y, POINT_TBASE, 0, state, -1, -1, 0, 0, 0, 0, 0, nil, nil)
                    cellData:setFortId(fid)
                    local id_ = cellData:getId()
                    gameMap.mapCellDatas[id_] = cellData
                end
            end
            pWorldMap = WorldMapView:create("cityScene.csb")
            pWorldMap:setWarningPoint(netBattleLookAt)
            me.runScene(pWorldMap)
        end
        First_City = true
        user.movecity_canable = msg.c.lock
        if user.movecity_canable == true then
            user.movecity_num = msg.c.moveCity
            user.movecity_cd = msg.c.minOfsetTime
            user.movecity_st = me.sysTime()
        end
    elseif checkMsg(msg.t, MsgCode.MSG_CITY_FIRE) then
        user.showfire = msg.c.show
    elseif checkMsg(msg.t, MsgCode.MSG_CROSS_PLAYER_INIT_RE) then
        -- 跨服服务器初始化完成
        user.Cross_Sever_Status = mCross_Sever
        -- 进入跨服
        me.tableClear(user.Cross_Sever_User)
        user.Cross_Sever_User.UserX = user.x
        user.Cross_Sever_User.UserY = user.y
        user.Cross_Sever_User.lansize = user.lansize
        user.Cross_Sever_User.Maxlansize = user.Maxlansize
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
            pWorldMap:cloudClose( function(args)
                local loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                me.runScene(loadlayer)
            end )
        elseif CUR_GAME_STATE == GAME_STATE_CITY and NewnetWork == 1 then
            mainCity:cloudClose( function(args)
                local loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                me.runScene(loadlayer)
            end )
        else
            netBattleMan:send(_MSG.NetBattleEnterMsg())
        end
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_ONEXIT) then
        -- 断开跨服
        if user.Cross_Sever_User then
            user.x = user.Cross_Sever_User.UserX
            user.y = user.Cross_Sever_User.UserY
            user.lansize = user.Cross_Sever_User.lansize
            user.Maxlansize = user.Cross_Sever_User.Maxlansize
            user.majorCityCrood = cc.p(user.x, user.y)
        end
        me.tableClear(user.Cross_Sever_User)
        me.tableClear(user.throne_plot)
        gameMap.fortDatas = { }
        -- 要塞重置
        gameMap.mapCellDatas = { }
        -- 地块重置
        user.Cross_Sever_Status = mCross_Sever_Out
        initFortData()
        if netBattleMan then
            netBattleMan:removeAllNetLisener()
            netBattleMan:removeAllMsgLisener()
            netBattleMan:closeQuiet()
        end
        -- 清除沦陷
        CaptiveMgr:clearMasterInfo()
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_PATH) then
        user.needaskBattle = msg.c.notice
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_BUTTON_SHOW) then
        user.activity_buttons_show = {}
        for _, v in ipairs(msg.c.list) do
            user.activity_buttons_show[v.id]= v
        end
        for _, v in ipairs(msg.c.acts) do
            user.activity_buttons_down_show[v.id]= v
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_MAIL_NEW) then
        user.activity_mail_new[msg.c.mailType]=msg.c.num
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
        -- 背包道具增加
        self:userBackPackChange(msg)
    elseif checkMsg(msg.t, MsgCode.EXPCHAGE_GEM) then
        showTips("操作成功")
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_REMOVE) then
        -- 背包道具移除
        self:userBackPackRemove(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_TITLE_LIST) then
        -- 称号列表
        user.title_list = msg.c.list
    elseif checkMsg(msg.t,MsgCode.TASK_CAPHTER_TITLE) then
        --章节任务
        user.taskCaphterDataTitle = msg.c
    elseif checkMsg(msg.t,MsgCode.TASK_CAPHTER_DATA_UPDATA) then
        --章节任务      
        local show = false  
        for key, var in pairs(user.taskCaphterData ) do 
             for k, v in pairs(msg.c.list) do
                 if var.id == v.id then
                      user.taskCaphterData[key] = v
                      if v.status == 2 then
                          show = true
                      end
                 end             
             end             
        end        
        --显示任务完成特效
        if show then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_TASK)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 100))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
        end
    elseif  checkMsg(msg.t,MsgCode.TASK_CAPHTER_GET_TITLE) then    
            if msg.c.items and   table.nums(msg.c.items) > 0 then              
                local i = { }
                for key, var in pairs(msg.c.items) do
                    i[#i + 1] = { }
                    i[#i]["defId"] = var[1]
                    i[#i]["itemNum"] = var[2]
                    i[#i]["needColorLayer"] = true
                end
                if msg.c.unlock then
                    local reward = me.split(msg.c.unlock, ",")
                    for key, var in pairs(reward) do
                        local data = me.split(var, ":")
                         i[#i + 1] = { }
                            i[#i]["defId"] = tonumber( data[1] )
                            i[#i]["itemNum"] =tonumber( data[2])
                            i[#i]["needColorLayer"] = true
                    end
                end
                getItemAnim(i)    
            end    
            if msg.c.openChapter then
                local gmsg = {}
                gmsg.t = MsgCode.TASK_CAPHTER_OPEN 
                gmsg.c = msg.c.openChapter
                Queue.push(self.msgControlQueue,gmsg)
            end
            if msg.c.openButton then
                local gmsg = {}
                gmsg.t = MsgCode.OPEN_FUNTION 
                gmsg.c = msg.c.openButton
                Queue.push(self.msgControlQueue,gmsg)
            end
    elseif checkMsg(msg.t,MsgCode.TASK_CAPHTER_DATA) then
        user.taskCaphterData = msg.c.list
    elseif checkMsg(msg.t,MsgCode.TASK_CAPHTER_OPEN) then      
               if msg.c.id  == 1 and control == nil then
                    Queue.push(self.msgControlQueue,msg)
                    return
               else
                    local ani = taskCaphterAni:create("Layer_TaskChapterAni.csb")
                    ani:initWithData(msg.c.id)
                    me.runningScene():addChild(ani,me.GUIDEZODER-1)    
                end      
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
        -- 背包道具修改
        self:userBackPackChange(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_SOLDIER_ADDS) then
        for key, var in pairs(msg.c.list) do
             local def = cfg[CfgType.CFG_SOLDIER][var.defId]
             showTips("获得"..def.name.."*"..var.num)
        end        
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_DATE_LINE) then
        -- 建造队列
        self:initStructDateLine(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_INIT) then
        -- 建筑实始化
        self:initBuilding(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_STRUCT) then
        -- 建筑建造
        self:structDateLine(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_STRUCT_FINISH) then
        -- 建筑建造完成
        self:structFinishBuild(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_UPLEVEL) then
        -- 升级建筑
        self:upLevelDateLine(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_UPLEVEL_FINISH) then
        -- 建筑升级完成
        self:upLevelFinishBuild(msg)

    elseif checkMsg(msg.t, MsgCode.WONDER_CHANGE) then
        -- 转换奇迹
        self:changeDateLine(msg)
    elseif checkMsg(msg.t, MsgCode.WONDER_CHANGE_FINISH) then
        -- 转换奇迹完成
        self:changeFinish(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_RAND_RESOURCE_UPDATE) then
        -- 更新随机资源点
        self:updateRandResource(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_WORLD_REMOVE) then
        self:removeData(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_UPDATE) then
        -- 更新内城信息
        self:updateCityInfo(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_P_FARMER_INIT) or checkMsg(msg.t, MsgCode.CITY_P_FARMER) then
        -- 初始化农民
        --        self:produceFarmer(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_P_FARMER_FINISH) then
        -- 农民生产完成

        --        self:produceFarmer(msg)
        --        user.curfarmer  = user.curfarmer + 1
        --        user.idlefarmer  = user.curfarmer - user.workfarmer
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_INIT) then
        -- 初始化科技
        self:initTech(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_UPLEVEL) then
        -- 科技升级
        self:upLevelTech(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_FINISH) then
        -- 科技升级完成
        self:upLevelTechFinish(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH) then
        -- 联盟科技初始化
        self:initAllianceTech(msg)
    elseif checkMsg(msg.t, MsgCode.UPDATE_FAMILY_TECH) then
        -- 联盟科技更新
        self:updateAllianceTechByGiven(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_FINISH_UPDATING) then
        -- 联盟科技升级结束
        self:updateAllianceTechFinish(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_UPDATING) then
        -- 联盟升级科技
        self:updatingAllianceTech(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_GIVEN) then
        -- 联盟科技徽章更新
        self:updateAllianceGivenData(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_CLEAR_TIME) then
        -- 清零联盟科技的冷却时间
        self:clearAllianceCD(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_VIEW) then
        -- 训练界面消息
        self:initProduceSoldierView(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_SOLDIER_UPDATE) then
        -- 士兵更新
        self:updateSoldier(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_INIT) then
        -- 初始化士兵
        self:initSoldier(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER) then
        -- 生产士兵
        self:productionSoldier(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_FINISH) then
        -- 生产完成士兵
        self:productionSoldierComplete(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_CREATE) then
        -- 创建家族信息
        self:createFamilyInfo(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_UPDATA_INFO) then
        -- 创建家族信息
        self:familyupdatainfor(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_CREATE_ERROR) then
        -- 创建家族失败信息
        self:errorAlertFamily(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_LIST) then
        -- 家族列表
        self:famliyList(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_RECRUIT_OPEN) then
        -- 更新招募状态信息
        self:UpdatafamliyInit(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_INIT) then
        -- 家族初始化界面
        self:famliyInit(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER) then
        -- 单个成员信息
        self:famliyMember(msg)

    elseif checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) then
        -- 家族成员列表
        self:familyMemberList(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_FAMILY_UPDATA_MEMBER_LIST) then
        -- 更新家族成员列表
        self:familyUpdataMemberList(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY) then
        -- 申请家族
        self:famliyApply(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_SET_RESTRI) then
        -- 设置加入家族的最低战力和等级
        self:familySetMinData(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY_ERROR) then
        -- 申请家族失败
        self:errorApplyFamily(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY_LIST) then
        -- 申请家族列表
        self:famliyApplyList(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_BE_AGREE) then
        -- 被同意家族申请
        self:famliyAgree(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST_LIST) then
        -- 领主收到家族邀请的列表
        self:familyRequestList(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST_INIT) then
        -- 家族邀请成员的列表
        self:familyRequestMemberInit(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_INVITE_LIST) then
        -- 家族申请成员的列表
        self:familyInviteMemberInit(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY_INVITE) then
        -- 更新申请成员的列表
        self:UpdataInviteMenber(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST) then
        -- 邀请成员
        self:familyRequest(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_STRONG_HOLD_UPDATE) then
        -- 更新据点
        self:revBastionUpdate(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_STRONG_HOLD_REMOVE) then
        -- 据点移除
        self:revBastionDelete(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_STRONG_HOLD_LIST) then
        -- 据点列表
        self:updatastrongHoldList(msg)
    elseif checkMsg(msg.t, MsgCode.AUTH_LOGIN) then
        me.showMessageDialog(msg.c.v, nil, 1)
    elseif checkMsg(msg.t, MsgCode.FAMILY_BE_KICK) then
        -- 被踢出联盟
        self:familyBeKick(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER_ESC) then
        -- 退出联盟
        self:familyMemberEsc(msg)
        -- 清理联盟科技数据
        self:clearAllFailmyTech()
    elseif checkMsg(msg.t, MsgCode.FAMILY_NOTICE_EDIT) then
        -- 修改联盟公告
        self:familyUpdateNotice(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER_UPDATE) then
        -- 更新联盟贡献
        self:familyContribution(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_BE_DEGREE) then
        -- 被设置职位familySetDegree
        self:familySetDegree(msg)

    elseif checkMsg(msg.t, MsgCode.FAMILY_HELP) then
        -- 帮助
        self:familyCenterUpdataHelp()
    elseif checkMsg(msg.t, MsgCode.FAMILY_HELP_CREATE) then
        --  初始化帮助
        self:familyCenterUpdataHelp()
    elseif checkMsg(msg.t, MsgCode.FAMILY_HELP_LIST) then
        -- 帮助列表
        self:familyHelpList(msg)

    elseif checkMsg(msg.t, MsgCode.BULID_HELP_REMOVE) then
        -- 移除请求过帮助的建筑ID
        self:removeBulid(msg)

    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_FARMERCHANGE) then
        -- 农民效率分配
        self:updateBuildingFarmer(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_NEW) then
        -- 新邮件
        self:newMail(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_INFO) then
        -- 邮件信息
        self:mailList(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_GET_ITEM) then
        -- 邮件获取道具返回
        self:mailGet(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_BATTTLE_REPORT) then
        -- 邮件战报
        self:mailBattleReport(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_SPY_REPORT) then
        -- 邮件战报
        self:mailSpyReport(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_CANCEL) then
        -- 取消建筑工作
        self:cancelBuildingWork(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER_VIEW) then
        -- 恢复伤兵初始化
        self:revertSoldierInit(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER) then
        -- 恢复伤兵
        self:revertSoldier(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER_LINE) then
        -- 恢复伤兵生产线
        self:revertSoldierLine(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER_FINISH) then
        -- 伤兵恢复完成
        self:revertSoldierFinish(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_ARMY_INFO) then
        -- 军队信息
        self:armyInfo(msg)

    elseif checkMsg(msg.t, MsgCode.SHOP_INIT) then
        -- 商店初始化
        self:initShop(msg)
    elseif checkMsg(msg.t, MsgCode.SHOP_BUY) then
        -- 商店购买
        self:buyShop(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT) then
        -- 攻击警示
        self:attackAlert(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT_REMOVE) then
        -- 攻击警示移除
        self:attackAlertRemove(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_PROPERTY_UPDATE) then
        -- 角色属性
        me.tableClear(user.propertyValue)
        user.propertyValue = { }
        user.propertyValue_temp = { }
        for key, var in pairs(msg.c.list) do
            user.propertyValue[var.name] = var.value
        end
        user.maxTroopsNum = math.floor( user.propertyValue["BingliAdd"] *(1 + user.propertyValue["BingliAddPct"]))
        if msg.c.temp then
            for key, var in pairs(msg.c.temp) do
                user.propertyValue_temp[var.name] = var.value
            end
        end
        -- 原服务器的出兵上限
    elseif checkMsg(msg.t, MsgCode.ROLE_PROPERTY_UPDATE_SERVER) then
        -- 跨服角色属性
        me.tableClear(user.propertyValue_Server)
        user.propertyValue_Server = { }
        for key, var in pairs(msg.c.list) do
            user.propertyValue_Server[var.name] = var.value
        end

        if user.propertyValue["BingliAdd"] and user.propertyValue_Server["BingliAddPct"] then
            user.maxTroopsNum =  math.floor( user.propertyValue["BingliAdd"] *(1 + user.propertyValue_Server["BingliAddPct"]))
            user.propertyValue_Server["BingliAdd"] = user.maxTroopsNum - user.propertyValue["BingliAdd"]
            -- 跨服的出兵上限增加值
            if user.propertyValue["BingliAddPct"] then
                user.maxTroopsNum =  math.floor(  user.propertyValue["BingliAdd"] *(1 + user.propertyValue_Server["BingliAddPct"] + user.propertyValue["BingliAddPct"]))
                user.propertyValue_Server["BingliAdd"] = user.maxTroopsNum - user.propertyValue["BingliAdd"]
            end
        else
            user.maxTroopsNum =  math.floor( user.propertyValue["BingliAdd"] *(1 + user.propertyValue["BingliAddPct"]))
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_VIEW) then
        self:worldMapView(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_POINT) then
        self:updateOverLordDatas(msg)
        self:updateCellData(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_ARMY_DP) then
        local t = me.sysTime()
        self:revTroopLineData(msg)
        -- showErrorMsg( ""..(me.sysTime() - t))
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_ARMY_REMOVE) then
        self:revRemoveArmy(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_ARMY_REMOVE_TABLE) then
        self:revRemoveArmyTable(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_BATTLE_INFO) then
        -- 开始战斗
        self:batteStart(msg)
    elseif checkMsg(msg.t, MsgCode.BULID_ID_LIST) then
        -- 请求帮助过的Build ID
        self:familyHelpedBuildList(msg)
    elseif checkMsg(msg.t, MsgCode.TASK_LIST) then
        -- 任务初始化列表
        self:initListTask(msg)
    elseif  checkMsg(msg.t, MsgCode.OPEN_FUNTION) then
         --是否需要进行控制
         
        openNewButtonByOpenBtnId(msg.c.id)
         
    elseif checkMsg(msg.t, MsgCode.TASK_UPDATE) then
        -- 更新任务
        self:updateTask(msg)
    elseif checkMsg(msg.t, MsgCode.TASK_COMPLETE) then
        -- 完成任务
        self:completeTask(msg)  
    elseif checkMsg(msg.t, MsgCode.PACKAGE_UPDATE) then
        -- 礼包状态更新
        self:packageUpdata(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM) then
        -- 初始化考古背包道具
        self:initUserBookPkg(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_ADD) then
        -- 增加修改考古背包道具
        self:userBookPkgChange(msg)

    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_REMOVE) then
        -- 移除考古背包道具
        self:userBookPkgRemove(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_CHANGE) then
        -- 修改考古背包道具
        self:userBookPkgChange(msg)
    elseif checkMsg(msg.t, MsgCode.BOOK_INIT) then
        -- 考古界面初始化
        self:bookInit(msg)
    elseif checkMsg(msg.t, MsgCode.BOOK_MENU_ADD) then
        -- 增加图鉴册
        self:bookMenuAdd(msg)
    elseif checkMsg(msg.t, MsgCode.BOOK_ADD) then
        -- 增加图鉴
        self:bookAdd(msg)
    elseif checkMsg(msg.t, MsgCode.BOOK_COMPOUND) then
        -- 图鉴合成
        self:bookCompound(msg)
    elseif checkMsg(msg.t, MsgCode.UPDATE_MONTH) then
        -- 更新月卡/周卡信息
        -- self:updateMonthInfo(msg)
    elseif checkMsg(msg.t, MsgCode.CHECK_MONTH) then
        -- 月卡/周卡信息
        self:monthInfo(msg)
    elseif checkMsg(msg.t, MsgCode.RECHARGE) then
        -- 充值商品信息
        self:recharge(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_NOTICE) then
        -- 事件信息
        self:noticeInfo(msg)
    elseif checkMsg(msg.t, MsgCode.HERO_SKILL_NOTICE) then
        self:heroSkillNoticeInfo(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_DP_TRADINGPOST) then
        -- 建立驿站成功
        user.stageX = msg.c.x
        user.stageY = msg.c.y
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_LIST) then
        -- 开启的活动ID
        self:activityList(msg)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_INIT_VIEW) then
        -- 初始活动界面信息
        self:activityInitView(msg)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
        -- 更新活动详情里的状态
        self:updateActivityDetail(msg)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_DARW_RECORD) then
        -- 抽奖的获奖记录
        self:updateAcitityInfo(msg)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_VIGOUR_INFO) then
        -- 积分帮助信息
        self:updateAcitityInfo(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_INIT) then
        -- 征服世界个人初始化
        self:fortressInit(msg)
        gameMap.postFortData = msg.c.post
        -----------------------
    elseif checkMsg(msg.t, MsgCode.WORLD_TASK_GET) then
        if msg.c.items == nil or table.nums(msg.c.items) <= 0 then
            return
        end
        local i = { }
        for key, var in pairs(msg.c.items) do
            i[#i + 1] = { }
            i[#i]["defId"] = var[1]
            i[#i]["itemNum"] = var[2]
            i[#i]["needColorLayer"] = true
        end
        if msg.c.unlock then
            local reward = me.split(msg.c.unlock, ",")
            for key, var in pairs(reward) do
                local data = me.split(var, ":")
                 i[#i + 1] = { }
                    i[#i]["defId"] = tonumber( data[1] )
                    i[#i]["itemNum"] =tonumber( data[2])
                    i[#i]["needColorLayer"] = true
            end
        end
        getItemAnim(i)
    -- 成长之路领奖
    elseif checkMsg(msg.t, MsgCode.GROW_WAY_GET) then
        if msg.c.reward and type(msg.c.reward) == "table" and #msg.c.reward > 0 then
            local tempList = {}
            for i, v in ipairs(msg.c.reward) do
                table.insert(tempList, {defId = v[1], itemNum = v[2]})
            end
            getItemAnim(tempList)
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_TASK_COMPLETE) then
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_WORLD_TASK)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_INIT) then
        -- 征服世界帮会初始化
        self:fortressFamilyInit(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_UPDATE) then
        -- 征服世界个人数据更新
        self:fortressUpdate(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_UPDATE) then
        -- 征服世界帮会更新
        self:fortressFamilyUpdate(msg)
        self:updateCellData_Fort(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_RESOURCE_INFO) then
        -- 资源信息
        self:resourceBuildingInfo(msg)
    elseif checkMsg(msg.t, MsgCode.TASK_BUTTON_STATUS) then
        -- 按钮开启状态
        self:initButtonStatus(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_OUT_INFO) then
        -- 资源产出更新
        self:updateProducePer(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_FIGHT_UPDATE) then
        -- 领主战力更新
        self:updateFightPower(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_POWER_UPDATE) then
        -- 体力更新
        self:updatePower(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_LANDSIZE_UPDATE) then
        -- 地块数量更新
        self:updateLandSize(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_MAP_LAND_INFO) then
        -- 地块数据详情
        self:updateLandInfo(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_TAX_INFO) then
        -- 征税信息
        self:updateTaxInfo(msg)
    elseif checkMsg(msg.t, MsgCode.GET_CHAT_RECORD) then
        -- 获得最近聊天记录
        self:flushChatMsg(msg)
    elseif checkMsg(msg.t, MsgCode.FAMLIY_CHAT_INFO) then
        -- 家族聊天
        self:addFamliyMsg(msg.c)
    elseif checkMsg(msg.t, MsgCode.WORLD_CHAT_INFO) then
        -- 世界聊天
        self:addWorldMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_TRUMPET) then
        -- 喇叭广播聊天
        self:addTrumpetMsg(msg.c)
        showTrumpetWithCfg(msg.c)
    elseif checkMsg(msg.t, MsgCode.CHAT_MAIL) then
        -- 收到聊天邮件
        self:newChatMail(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
        -- 排行榜
        self:rankData(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_VIP_UPDATE) then
        -- VIP信息更新
        self:updateVipInfo(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_ORIGIN_UPDATE) then
        -- 更新主城坐标
        self:updataroleorigin(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_CAPTIVE_LIST) then
        CaptiveMgr:updateCapticesList(msg.c)
    elseif checkMsg(msg.t, MsgCode.FAMILY_CAPTIVE) then
        CaptiveMgr:updateMasterInfo(msg.c)
    elseif checkMsg(msg.t, MsgCode.FAMILY_CAPTIVE_REVERT_SUCCESS) then
        CaptiveMgr:clearMasterInfo()
    elseif checkMsg(msg.t, MsgCode.FAMILY_FORT_LIST) then
        self:updateFortDatas(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_PROTECTED) then
        self:updateProtected(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_CLEAN_PROTECTED_COUNTDON) then
        self:updateProtected(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_CANCEL_PROTECTED) then
        self:updateProtected(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_PROTECTED_INFO) then
        self:updateProtected(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BUFF_UPDATE) then
        self:updateBuff(msg)
    elseif checkMsg(msg.t, MsgCode.BOX_REMAKE) then
        showTips("兑换成功")
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_FINISH_REWARD) then
        self:popActivityReward(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CREATE) then
        if msg.c.atc == 1 then
            if user.Cross_Sever_Status == mCross_Sever then
                showTips("阵营集结令跨服海战开启，为了荣誉积极参与！")
            else
                showTips("联盟集结令盟战开启，为了荣誉盟友们积极参与！")
            end
            user.allianceConvergeHint.attack = user.allianceConvergeHint.attack + 1
        else
            user.allianceConvergeHint.defener = user.allianceConvergeHint.defener + 1
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_INFO) then
        self:WorldTeamInfo(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_DETAIL) then
        self:WorldArmyTeamInfo(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CITY_ARMY) then
        self:WorldCityArmy(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_HISTORY) then
        self:worldTeamHistory(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_ARMY_DETAIL) then
        self:WorldAidDetail(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_DEFENS_HISTORY) then
        self:DefensHistoroy(msg)
    elseif checkMsg(msg.t, MsgCode.REWARD_MONTH) then
        self:popRewardItems(msg)
    elseif checkMsg(msg.t, MsgCode.GLOBAL_TIPS_POPITEM) then
        self:popRewardName(msg)
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_HINT) then
        self:AlliaceHint(msg)
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_RENIVE_HINT) then
        self:removeAllianceHint(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_GENERAL) then
        self:fortheroGeneral(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_RANK) then
        self:fortheroRankGeneral(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_ACTIVITION) then
        self:worldHeroOpenActivity(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST) then
        self:worldHeroIdentifyList(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE) then
        self:worldHeroUpgrading(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE_FINISH) then
        self:worldHeroUpgradeFinsh(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE_DETIAL) then
        self:worldHeroUpgradeDetailInfo(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_EXCHANGE) then
        self:worldHeroExchange(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_SKILL_LIST) then
        self:setHeroSkillDatas(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_USE_SKILL) then
        self:setUseSkillData(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_BUFF) then
        self:setHeroBuff(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_OPEN) then
        self:fortressExperUpdate(msg)
    elseif checkMsg(msg.t, MsgCode.WORLF_FORT_HERO_SOLDIER) then
        self:fortHeroSoldier(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_RECURIT_SOLDIER) then
        self:fortRecuritSoldier(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_SOLDIER_BUY) then
        self:fortRecuritSoldierUpdata(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_HOSTORY_GENERAL) then
        self:fortHistoryGeneral(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_OPEN_SKILL) then
        -- 首次拥有主动技能
        user.heroSkillStatus = 1
    elseif checkMsg(msg.t, MsgCode.ELEVEN_SHOP) then
        self:initElevenShopData(msg)
    elseif checkMsg(msg.t, MsgCode.ELEVEN_SHOP_CD) then
        for key, var in pairs(msg.c.list) do
            if var.id == ACTIVITY_ID_SHOP then
                self:initElevenShopTime(var.time)
            end
        end
    elseif checkMsg(msg.t, MsgCode.EXCHANGE_ACTIVITY) then
        self:popTips(me.toNum(msg.c.value))
    elseif checkMsg(msg.t, MsgCode.POPULARIZE_ONFO_DATA) then
        self:popularizeInfo(msg)
    elseif checkMsg(msg.t, MsgCode.POPULARIZE_SKIP_TIME) then
        self:popularizeSkipInfo(msg)
    elseif checkMsg(msg.t, MsgCode.REDBAO_OPEN) then
        self:openMainSceneAnim(msg)
    elseif checkMsg(msg.t, MsgCode.REDBAO_CLODE) then
        user.hongBao_nums = msg.c.gem
        self:closeMainSceneAnim(msg, true)
    elseif checkMsg(msg.t, MsgCode.REDBAO_CLICK) then
        self:HongBao_Clicked_Succeed(msg)
    elseif checkMsg(msg.t, MsgCode.KINGDOM_TYPE_DETAIL) then
        self:Kingdom_detail(msg)
    elseif checkMsg(msg.t, MsgCode.KINGDOM_GIVEN_ITEM) then
        self:refreshFoundationData(msg)
    elseif checkMsg(msg.t, MsgCode.KINGDOM_ADMIN_OFFICER) then
        self:reloadOfficerList(msg)
    elseif checkMsg(msg.t, MsgCode.KINGDOM_NATIONAL_POLICY_PUBLISH) then
        self:reloadPublishList_National(msg)
    elseif checkMsg(msg.t, MsgCode.KINGDOM_CHANGE_MOTTO) then
        if msg.c.result and msg.c.result == 1 then
            user.kingdom_OfficerData.kingWorlds = msg.c.kingWorlds
            user.kingdom_OfficerData.updateAble = msg.c.updateAble
        end
    elseif checkMsg(msg.t, MsgCode.PAYMODE) then

    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_CREATE) then
        self:Throne_CreateData(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_MORALE) then
        self:ThroneMorle(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_INIT) then
        self:ThroneInif(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_STRATEGY) then
        self:ThroneStrategy(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_STRATEGY_START) then
        self:ThroneStrategyAllAni(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_FIGHT_RECORD) then
        self:Cross_Fight_Record(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_PROMOTION_LIST) then
        self:Cross_PolicyData_military(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_STATUS) then
        user.cross_st = msg.c.st
        user.Cross_Sever_Status = msg.c.status
        if n_netWorkManager and netBattleMan:netBattleOpen() == false and user.Cross_Sever_Status == mCross_Sever then
            NetMan:send(_MSG.getNetBattleDataMsg())
            NewnetWork = 0
        end
        --
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_SHUT_DOWN) then
        if user.Cross_Sever_Status == mCross_Sever then
            --[[
            if netBattleMan then
                    netBattleMan:removeAllNetLisener()
                    netBattleMan:closeQuiet()
            end
            First_City = true
            me.showMessageDialog("跨服结束", function(evt)
                if evt == "ok" then
                    user.Cross_Sever_Status = mCross_Sever_Out
                    if CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                        NetMan:send(_MSG.loadDataMsg(0))
                        loadingLayer.initFortData()
                        pWorldMap:goCityView()
                    end
                end
            end ,1)
            ]]
            if user.Cross_Sever_User then
                user.x = user.Cross_Sever_User.UserX
                user.y = user.Cross_Sever_User.UserY
                user.lansize = user.Cross_Sever_User.lansize
                user.Maxlansize = user.Cross_Sever_User.Maxlansize
                user.majorCityCrood = cc.p(user.x, user.y)
            end
            me.tableClear(user.Cross_Sever_User)
            me.tableClear(user.throne_plot)
            gameMap.fortDatas = { }
            -- 要塞重置
            gameMap.mapCellDatas = { }
            -- 地块重置
            user.Cross_Sever_Status = mCross_Sever_Out
            initFortData()
            if netBattleMan then
                netBattleMan:removeAllNetLisener()
                netBattleMan:removeAllMsgLisener()
                netBattleMan:closeQuiet()
            end
            me.showMessageDialog("跨服结束", function(evt)
                if evt == "ok" then
                    user.Cross_Sever_Status = mCross_Sever_Out
                    if CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                        NetMan:send(_MSG.loadDataMsg(0))
                        loadingLayer.initFortData()
                        pWorldMap:goCityView()
                    end
                end
            end , 1)
        end
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_SCORE_RANK) then
        self:Cross_Thron_Rank(msg)
    elseif checkMsg(msg.t, MsgCode.CAMOP_CHAT_INFO) then
        self:addCampdMsg(msg.c)
    elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_INFO) then
        self:addCrossMsg(msg.c)
    elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_RECORD) then
        self:addCrossRecord(msg)
    elseif checkMsg(msg.t, MsgCode.MAP_MARK_KING) then
        self:setMarkKing(msg.c)
    elseif checkMsg(msg.t, MsgCode.CROSS_THRONE_OCCUPY) then
        self:setThroneOccupy(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_THRONE_END) then
        self:setThroneEnd(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_INFO) then
        self:initRuneInfo(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_BACKPACK) then
        self:initRuneBackpack(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_UPDATE) then
        self:updateRuneBackpack(msg)

    elseif checkMsg(msg.t, MsgCode.RUNE_REMOVE) then
        self:removeRuneBackpack(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_FIND_GUARD_INIT) then
        self:FindRuneCreate(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_UPDATE_GUARD_LEVEL) then
        user.Rune_Create_info_level = msg.c.lv
        -- 当前挑战等级
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_AURGURY) then
        if me.isValidStr(msg.c.haveNum) then
            user.activityDetail.haveNum = msg.c.haveNum
        end
    elseif checkMsg(msg.t, MsgCode.BOX_REMAKE) then
        self:refreshWishNum(msg.c, MsgCode.BOX_REMAKE)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_WISH) then
        self:refreshWishNum(msg.c, MsgCode.ACTIVITY_WISH)
    elseif checkMsg(msg.t, MsgCode.MSG_WARSHIP_INIT) then
        self:warshipDataInit(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_WARSHIP_UPDATE) then
        self:warshipDataUpdate(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_TECH_UP) then
        self:warshiptechupdata(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_ACHIEVENMENT_INIT) then
        self:achievementDataInit(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_ACHIEVENMENT_GET) then
        self:resetAchievementData(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_ACHIEVENMENT_NOTICE) then
        self:popAchievenmentNotice(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION_INIT) then
        self:shipSailInit(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION_UPDATE) then
        self:updateShipSailTask(msg)
    elseif checkMsg(msg.t, MsgCode.NSG_SHIP_EXPEDITION_REWARD) then
        self:shipSailTaskReward(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION) then
        self:updateShipSailTimes(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_RED_POINT_UPDATE) then
        self:updateRedpointData(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_EXILE) then
        -- 放逐成功消息
        self:exileSucess(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_BE_EXILE) then
        -- 被放逐领地的玩家收到消息
        self:exilePromptBox(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_SEARCH_RIGHT_INIT) then
        -- 圣物搜索数据
        self:runeNormalSearch(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_GUARD_STATUS_CHANGE) then
        -- 禁卫军巡逻状态
        self:guardPatrolStatus(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_GUARD_RESIST_STATUS) then
        -- 禁卫军 抵御蛮族攻城状态
        self:guardResistStatus(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_HANDBOOK_NEW) then
        -- 圣物图鉴有新增
        user.rune_handbook_new = 1
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_TECH_SPEED_UP_TIMES_LEFT) then
        -- 联盟科技加速剩余次数
        user.allTechTimesLeft = msg.c.cTimes
    elseif checkMsg(msg.t, MsgCode.CHANGE_HEAD) then
        user.head = msg.c.id
    elseif checkMsg(msg.t, MsgCode.CHANGE_LORD_IMAGE) then
        user.image = msg.c.id
    end

    for key, var in pairs(self.msglisener) do
        var(msg)
    end
end
function UserDataModel:resetAchievementData(msg)
    if user.AchievementData and user.AchievementData.list then
        for key, var in pairs(user.AchievementData.list) do
            local i = { }
            if var.id == msg.c.id then
                var.status = msg.c.status
                var.value = msg.c.value
                local tmpcfg = cfg[CfgType.ACHIEVEMENT][var.id]
                local rewards = me.split(tmpcfg.awards, ",")
                for ikey, ivar in pairs(rewards) do
                    local str = me.split(ivar, ":")
                    i[#i + 1] = { }
                    i[#i]["defId"] = me.toNum(str[1])
                    i[#i]["itemNum"] = me.toNum(str[2])
                    i[#i]["needColorLayer"] = true
                end
            end
            dump(i)
            getItemAnim(i)
        end
    end
    if user.AchievementData and user.AchievementData.total then
        user.AchievementData.total = msg.c.total
    end
    if user.AchievementData and user.AchievementData.com then
        user.AchievementData.com = msg.c.com
    end
    if user.AchievementData and user.AchievementData.score then
        user.AchievementData.score = msg.c.score
    end
end
function UserDataModel:popAchievenmentNotice(msg)
    --    local tmpcfg = cfg[CfgType.ACHIEVEMENT][msg.c.id]
    --    showTips("成就达成："..tmpcfg.name)
    if msg.c.type == 1 then
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_ACHIEVENMENT)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 100))
        me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        user.Achievenment_Redpoint[msg.c.list[1].id] = 1

        me.dispatchCustomEvent("Achievenment_Redpoint")
    elseif msg.c.type == 0 then
        user.Achievenment_Redpoint = { }
        for _, v in ipairs(msg.c.list) do
            user.Achievenment_Redpoint[v.id] = 1
        end
        me.dispatchCustomEvent("Achievenment_Redpoint")
    end

end
function UserDataModel:achievementDataInit(msg)
    user.AchievementData = AchievementData.new(msg.c.list, msg.c.total, msg.c.score, msg.c.com)
end
function UserDataModel:FindRuneCreate(msg)
    user.Rune_Create_info.free = msg.c.free
    -- 免费次数
    user.Rune_Create_info.gem = msg.c.gem
    -- 花费钻石数
end
function UserDataModel:setThroneEnd(msg)
    me.tableClear(user.Cross_Throne_End)
    for key, var in pairs(msg.c.list) do
        local CrossThroneEnd = CrossThroneEnd.new(var.id, var.sn, var.nm, var.sc, var.mstSn or nil, var.mstNm or nil)
        user.Cross_Throne_End[#user.Cross_Throne_End + 1] = CrossThroneEnd
    end
end

function UserDataModel:setThroneOccupy(msg)
    local pCross_Throne_Occupy = CrossThroneOccpy.new(msg.c.mstShortName, msg.c.mstName, msg.c.shortName, msg.c.name, msg.c.win)
    user.Cross_Throne_Occupy = pCross_Throne_Occupy
end
function UserDataModel:setMarkKing(msg)
    me.tableClear(user.markKingPos)
    user.markKingPos = { }
    for key, var in pairs(msg.list) do
        if user.markKingPos[me.getIdByCoord(cc.p(var.x, var.y))] and user.markKingPos[me.getIdByCoord(cc.p(var.x, var.y))].mine == true then
        else
            user.markKingPos[me.getIdByCoord(cc.p(var.x, var.y))] = var
        end
    end
end

function UserDataModel:addCrossRecord(msg)
    for key, var in pairs(msg.c.worldList) do
        self:addCrossMsg(var)
    end

    for key, var in pairs(msg.c.campList) do
        self:addCampdMsg(var)
    end
end
function UserDataModel:addCampdMsg(msg)
    local newMsg = MsgData.new(msg.uid, msg.name, msg.date, msg.content, msg.familyName, msg.c.shorName, msg.degree, msg.fightNum, msg.noticeId)
    newMsg.title = msg.title or 0
    newMsg.head = msg.head
    newMsg.image = msg.image
    newMsg.vip = msg.vip or 0
    if #user.msgCampInfo <= 30 then
        user.msgCampInfo[#user.msgCampInfo + 1] = newMsg
    else
        table.insert(user.msgCampInfo, #user.msgCampInfo + 1, newMsg)
        table.remove(user.msgCampInfo, 1)
    end
end
function UserDataModel:addCrossMsg(msg)
    local newMsg = MsgData.new(msg.uid, msg.name, msg.date, msg.content, msg.familyName, msg.c.shorName, msg.degree, msg.fightNum, msg.noticeId, msg.camp or "")
    newMsg.title = msg.title or 0
    newMsg.head = msg.head
    newMsg.image = msg.image
    newMsg.vip = msg.vip or 0
    if #user.msgCrossInfo <= 30 then
        user.msgCrossInfo[#user.msgCrossInfo + 1] = newMsg
    else
        table.insert(user.msgCrossInfo, #user.msgCrossInfo + 1, newMsg)
        table.remove(user.msgCrossInfo, 1)
    end
end
function UserDataModel:Cross_Thron_Rank(msg)
    me.tableClear(user.CrossScoreRank)
    for key, var in pairs(msg.c.list) do
        local prank = CrossScoreRank.new(var["item"], key)
        user.CrossScoreRank[key] = prank
    end
end
function UserDataModel:Cross_PolicyData_military(msg)
    me.tableClear(user.Cross_PolicyData_Military)
    for key, var in pairs(msg.c.list) do
        local Cross_PolicyData = Cross_PolicyData.new(var.id, var.name, var.des, var.status, var.time, var.ext)
        user.Cross_PolicyData_Military[#user.Cross_PolicyData_Military + 1] = Cross_PolicyData
    end
end
function UserDataModel:Cross_Fight_Record(msg)
    me.tableClear(user.CrossSeverRank)
    for key, var in pairs(msg.c.list) do
        local pData = Cross_SeverRank.new(var.server, var.data, var.begin, var.close, var.name)
        user.CrossSeverRank[#user.CrossSeverRank + 1] = pData
    end
end
function UserDataModel:reloadOfficerList(msg)
    me.tableClear(user.kingdom_OfficerData.list)
    user.kingdom_OfficerData.list = { }
    for key, var in pairs(msg.c.list) do
        user.kingdom_OfficerData.list["degree_" .. var.degree] = var
    end
end
function UserDataModel:refreshFoundationData(msg)
    showTips("赏赐成功！")
    user.kingdon_foundationData = kingdom_foundationData.new(msg.c.food, msg.c.wood, msg.c.stone, msg.c.gold, msg.c.crystal, msg.c.exHistory, 2, msg.c.contribute)
end
function UserDataModel:reloadPublishList_National(msg)
    user.kingdom_policyData_national.crystal = msg.c.crystal
    user.kingdom_policyData_national.list = msg.c.list
    if msg.c.x and msg.c.y and pWorldMap ~= nil then
        -- 跳转坐标
        local pos = { }
        pos.x = msg.c.x
        pos.y = msg.c.y
        if pWorldMap.kmv then
            pWorldMap.kmv:close()
        end
        pWorldMap:RankSkipPoint(pos)
    end
end
function UserDataModel:Kingdom_detail(msg)
    if msg.c.type == kingdomMainView.type_officer then
        -- 官职
        user.kingdom_OfficerData = kingdom_officerData.new(msg.c.list, msg.c.countDown, msg.c.kingWorlds, msg.c.updateAble, msg.c.identity, msg.c.autoCountDown)
        user.kingdom_OfficerData.defs = msg.c.defs
    elseif msg.c.type == kingdomMainView.type_foundation then
        -- 国库
        user.kingdon_foundationData = kingdom_foundationData.new(msg.c.food, msg.c.wood, msg.c.stone, msg.c.gold, msg.c.crystal, msg.c.exHistory, msg.c.type, msg.c.contribute, msg.c.salary)
    elseif msg.c.type == kingdomMainView.type_nationalPolicy then
        -- 国政
        user.kingdom_policyData_national = kingdom_policyData.new(msg.c.crystal, msg.c.list, msg.c.type)
    elseif msg.c.type == kingdomMainView.type_militaryPolicy then
        -- 军政
        --   user.kingdom_policyData_military = kingdom_policyData.new(msg.c.crystal, msg.c.list, msg.c.type)
    end
end

function UserDataModel:ThroneStrategyAllAni(msg)
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        local cdata = pWorldMap:getCellDataByCrood(cc.p(600, 600))
        if cdata then
            local pStratAni = Throne_StrategyAni.new(msg.c.type, msg.c.strategyId)
            ThroneAnim(pStratAni)
        end
    end

end
function UserDataModel:ThroneStrategy(msg)
    user.throne_Strategy = Throne_Strategy.new(msg.c.type, msg.c.list, msg.c.countdown)
end
function UserDataModel:ThroneInif(msg)
    me.tableClear(user.throne_InitData)
    user.throne_InitData = ThroneInit(msg.c.list)
end
function UserDataModel:ThroneMorle(msg)
    user.throne_morleRank = Throne_MorleRank.new(msg.c.st, msg.c.msc, msg.c.list, msg.c.fnm)
end
function UserDataModel:Throne_CreateData(msg)
    user.throne_create = Throne_CreateData.new(msg.c.st, msg.c.fsn, msg.c.fnm, msg.c.sc, msg.c.msc, msg.c.list, msg.c.tm, msg.c.xy, msg.c.kingName)
end
function UserDataModel:closeMainSceneAnim(msg, closeAnim)
    local curScene = nil
    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity ~= nil then
        curScene = mainCity
    elseif (CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE) and pWorldMap ~= nil then
        curScene = pWorldMap
    end
    if curScene and curScene.Panel_HongBao then
        user.hongBao_openState = 0
        switchHongBaoAnim(curScene.Panel_HongBao, false, closeAnim)
        curScene.hongbao_btn:setVisible(false)
        curScene.Image_hongbao_bg:setVisible(true)
    end
end

function UserDataModel:openMainSceneAnim(msg)
    local curScene = nil
    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity ~= nil then
        curScene = mainCity
    elseif (CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE) and pWorldMap ~= nil then
        curScene = pWorldMap
    end
    if curScene and curScene.Panel_HongBao then
        user.hongBao_ID = msg.c.id
        user.hongBao_openState = 1
        if msg.c.union and msg.c.name then
            user.hongBao_name = msg.c.name
            user.hongBao_union = msg.c.union
        else
            user.hongBao_name = "天降红包"
            user.hongBao_union = nil
        end
        if user.hongBao_State == 1 then
            switchHongBaoAnim(curScene.Panel_HongBao, true)
        end
        curScene.hongbao_btn:setVisible(true)
        me.assignWidget(curScene.hongbao_btn, "hongbao_red_hint"):setVisible(true)
    end
end
function UserDataModel:heroSkillNoticeInfo(msg)
    local def = cfg[CfgType.HERO_SKILL][msg.c.id]
    if msg.c.success == true then
        showTips(msg.c.text)
    else
        showTips(msg.c.text, "ff0000")
    end
end
function UserDataModel:fortHistoryGeneral(msg)
    local var = msg.c
    user.fortheroHistoryRankList = FortHeroHistoryRankData.new(var.id, var.nm, var.tm, var.dt, var.kn)
end
function UserDataModel:setHeroBuff(msg)
    me.tableClear(user.heroBuffList)
    user.heroBuffList = { }

    for key, var in pairs(msg.c.list) do
        user.heroBuffList[#user.heroBuffList + 1] = { }
        user.heroBuffList[#user.heroBuffList].id = me.toNum(var.id)
        user.heroBuffList[#user.heroBuffList].tm = math.floor(var.tm / 1000)
        if var.tm and var.tm > 0 then
            user.heroBuffList[#user.heroBuffList].sysT = me.sysTime()
        end
    end
end
function UserDataModel:setUseSkillData(msg)
    for key, var in pairs(user.heroSkillList) do
        if me.toNum(var.id) == me.toNum(msg.c.id) then
            user.heroSkillList[me.toNum(key)].tm = math.floor(msg.c.tm / 1000)
            user.heroSkillList[me.toNum(key)].sysT = math.floor(me.sysTime() / 1000)
        end
    end
    for key, var in pairs(user.totemSkillList) do
        if me.toNum(var.id) == me.toNum(msg.c.id) then
            user.totemSkillList[me.toNum(key)].tm = math.floor(msg.c.tm / 1000)
            user.totemSkillList[me.toNum(key)].sysT = math.floor(me.sysTime() / 1000)
            user.totemSkillList[me.toNum(key)].atime = math.floor(msg.c.aTime / 1000)
        end
    end
    for key, var in pairs(user.worldSkillList) do
        if me.toNum(var.id) == me.toNum(msg.c.id) then
            user.worldSkillList[me.toNum(key)].tm = math.floor(msg.c.tm / 1000)
            user.worldSkillList[me.toNum(key)].sysT = math.floor(me.sysTime() / 1000)
        end
    end
end
function UserDataModel:setHeroSkillDatas(msg)
    me.tableClear(user.heroSkillList)
    user.heroSkillList = { }
    for key, var in pairs(msg.c.list) do
        user.heroSkillList[#user.heroSkillList + 1] = { }
        user.heroSkillList[#user.heroSkillList].id = me.toNum(var.id)
        user.heroSkillList[#user.heroSkillList].tm = math.floor(var.tm / 1000)
        user.heroSkillList[#user.heroSkillList].sysT = math.floor(me.sysTime() / 1000)
    end
    user.totemSkillList = { }
    for key, var in pairs(msg.c.totem) do
        local totem = { }
        totem.id = me.toNum(var.id)
        totem.tm = math.floor(var.tm / 1000)
        totem.sysT = math.floor(me.sysTime() / 1000)
        totem.atime = math.floor(var.aTime / 1000)
        table.insert(user.totemSkillList, totem)
    end
    user.worldSkillList = { }
    for key, var in pairs(msg.c.worldSkill) do
        local worldSkill = { }
        worldSkill.id = me.toNum(var.id)
        worldSkill.tm = math.floor(var.tm / 1000)
        worldSkill.sysT = math.floor(me.sysTime() / 1000)
        table.insert(user.worldSkillList, worldSkill)
    end
end

function UserDataModel:fortHeroSoldier(msg)
    me.tableClear(user.fortHeroSoldierList)
    for key, var in pairs(msg.c.list) do
        local pfortHeroSoldier = fortHeroSoldier.new(var.id, var.sd)
        table.insert(user.fortHeroSoldierList, pfortHeroSoldier)
    end
end
function UserDataModel:fortRecuritSoldier(msg)
    me.tableClear(user.fortRecuritSoldierList)
    user.fortRecuritSoldierData.soldierid = msg.c.id
    -- 招募配置id
    user.fortRecuritSoldierData.recuritNum = msg.c.cn
    -- 招募的次数
    user.fortRecuritSoldierData.CountTime = msg.c.cd
    user.fortRecuritSoldierData.max = msg.c.max
    -- 当前奇迹兵与上限
    user.fortRecuritSoldierData.curWonder = msg.c.curWonder
    user.fortRecuritSoldierData.wonderMax = msg.c.wonderMax
    -- 倒计时
    local pInedx = 0
    for key, var in pairs(msg.c.list) do
        local pfortRecuritSoldier = fortRecuritSoldier.new(pInedx, var.id, var.nm, var.tp, var.nd, var.hs)
        user.fortRecuritSoldierList[pInedx + 1] = pfortRecuritSoldier
        pInedx = pInedx + 1
    end
end
function UserDataModel:fortRecuritSoldierUpdata(msg)
    local pInedx = msg.c.dx
    user.fortRecuritSoldierData.recuritNum = msg.c.tm
    user.fortRecuritSoldierList[pInedx + 1].halfrecurit = 1
    user.fortRecuritSoldierData.curWonder = msg.c.curWonder
    user.fortRecuritSoldierData.wonderMax = msg.c.wonderMax
end
function UserDataModel:worldHeroExchange(msg)
    --    dump(msg)
end
function UserDataModel:worldHeroUpgradeFinsh(msg)
    for key, var in pairs(user.worldIdentifyList.heroList) do
        local tmpDef = var:getDef()
        local msgDef = cfg[CfgType.HERO_BOOK_TYPE][msg.c.heroBookId]
        if me.toNum(tmpDef.herobookid) == me.toNum(msgDef.herobookid) then
            showTips("附加攻击+ " .. msgDef.atkplus - tmpDef.atkplus)
            showTips("附加防御+ " .. msgDef.defplus - tmpDef.defplus)
            showTips("附加伤害+ " .. msgDef.dmgplus - tmpDef.dmgplus)
            showTips("战斗力+ " .. msgDef.fight - tmpDef.fight)
            local tmpData = fortIdentifyData.new(msg.c.heroBookId, 2)
            user.worldIdentifyList.heroList[key] = tmpData
            break
        end
    end
end
function UserDataModel:worldHeroUpgrading(msg)
    for key, var in pairs(user.worldIdentifyList.heroList) do
        local tmpDef = var:getDef()
        if me.toNum(tmpDef.id) == me.toNum(msg.c.heroBookId) then
            if msg.c.herobookStatus then
                var.herobookStatus = msg.c.herobookStatus
            end
            if msg.c.advancedValue then
                local pg = msg.c.advancedValue - var.progress
                showTips("进度 +" .. pg .. "%")
                var.progress = msg.c.advancedValue
            end
            if msg.c.time then
                var.countTime = msg.c.time / 1000
            end
            break
        end
    end
end
function UserDataModel:worldHeroOpenActivity(msg)
    for key, var in pairs(user.worldIdentifyList.heroList) do
        local tmpDef = var:getDef()
        if me.toNum(tmpDef.id) == me.toNum(msg.c.herobookId) then
            var.herobookStatus = msg.c.herobookStatus
            showTips("附加攻击 +" .. tmpDef.atkplus)
            showTips("附加防御 +" .. tmpDef.defplus)
            showTips("附加伤害 +" .. tmpDef.dmgplus)
            showTips("综合战力 +" .. tmpDef.fight)
            break
        end
    end
end
function UserDataModel:worldHeroUpgradeDetailInfo(msg)
    for key, var in pairs(user.worldIdentifyList.heroList) do
        local tmpDef = var:getDef()
        if me.toNum(tmpDef.id) == me.toNum(msg.c.heroBookId) then
            var.progress = string.format("%.2f", msg.c.advancedValue)
            -- 进度
            var.countTime = msg.c.time / 1000
            var.diamondCost = msg.c.diamondCost
            break
        end
    end
end
function UserDataModel:worldHeroIdentifyList(msg)
    me.tableClear(user.worldIdentifyList)
    user.worldIdentifyList = { }

    local tmpDataList = { }
    local tmpHeroId, tmpHeroStatus = nil, nil

    local function getLvOneHeroID(bookId, lv)
        for key, var in pairs(cfg[CfgType.HERO_BOOK_TYPE]) do
            if var.herobookid == bookId and var.herobooklv == lv then
                return var.id
            end
        end
    end

    for key, var in pairs(cfg[CfgType.HERO_BOOK]) do
        tmpHeroId = nil
        for inKey, inVar in pairs(msg.c.list) do
            local msgDef = cfg[CfgType.HERO_BOOK_TYPE][inVar.herobookId]
            local varDef = cfg[CfgType.HERO_BOOK_TYPE][var.herobookid]
            if me.toNum(varDef.herobookid) == me.toNum(msgDef.herobookid) then
                tmpHeroId = inVar.herobookId
                tmpHeroStatus = inVar.herobookStatus
                break
            end
        end
        if tmpHeroId == nil then
            tmpHeroId = getLvOneHeroID(var.needherotypeid, 1)
            tmpHeroStatus = fortIdentifyView.Hero_NoEnough
        end
        local tmpData = fortIdentifyData.new(tmpHeroId, tmpHeroStatus)
        tmpDataList[#tmpDataList + 1] = tmpData
    end
    user.worldIdentifyList = fortIdentifyDataList.new(tmpDataList)

    dump(user.worldIdentifyList.heroList)
end
function UserDataModel:fortheroRankGeneral(msg)
    local pData = msg.c
    user.fortheroRankList = FortHeroRankData.new(pData.id, pData.tm, pData.cnm, pData.hp, pData.list, pData.mrk, pData.cd)
end
function UserDataModel:fortheroGeneral(msg)
    me.tableClear(user.fortheroData)
    if msg.c and msg.c.list then
        for key, var in pairs(msg.c.list) do
            local pFortHero = FortHeroData.new(var.st, var.stid, var.x, var.y, var.id, var.lv, var.nm, var.tm, var.hp, var.exp, var.initNm)
            table.insert(user.fortheroData, pFortHero)
        end
    end
end
function UserDataModel:popTips(tag)
    if tag == 0 then
        showErrorMsg("格式错误", 1)
    elseif tag == -1 then
        showErrorMsg("错误码", 1)
    elseif tag == -2 then
        showErrorMsg("已使用", 1)
    elseif tag == -3 then
        showErrorMsg("已领取该类型礼包", 1)
    elseif tag == -4 then
        showErrorMsg("没有对应的道具类型", 1)
    elseif tag == 1 then
        showTips("领取成功,查收邮件")
    else
        showErrorMsg("领取失败", 1)
    end
end
function UserDataModel:initElevenShopTime(time)
    user.elevenLeftTime = time / 1000
end
function UserDataModel:initElevenShopData(msg)
    user.elevenShopInfos = ElevenShopData.new(msg.c.time, msg.c.list, msg.c.comsumeAgio, msg.c.comsume)
end
function UserDataModel:popularizeSkipInfo(msg)
    user.popularizeData[msg.c.id].status = msg.c.status
end
function UserDataModel:popularizeInfo(msg)
    me.tableClear(user.popularizeData)
    for key, var in pairs(msg.c.list) do
        local pPopularize = PopulaiizeData.new(var.id, var.link, var.image, var.text, var.hortations, var.type, var.status)
        user.popularizeData[var.id] = pPopularize
    end
end
function UserDataModel:removeAllianceHint(msg)
    if msg.c.atc == 1 then
        user.allianceConvergeHint.attack = user.allianceConvergeHint.attack - 1
    else
        user.allianceConvergeHint.defener = user.allianceConvergeHint.defener - 1
    end
end
function UserDataModel:AlliaceHint(msg)
    user.allianceConvergeHint.attack = user.allianceConvergeHint.attack + msg.c.atc
    user.allianceConvergeHint.defener = user.allianceConvergeHint.defener + msg.c.def
end
function UserDataModel:DefensHistoroy(msg)
    me.tableClear(user.defensHistoryList)
    for key, var in pairs(msg.c.list) do
        local defensHistory = DefensHistoryData.new(var.name, var.num, var.time)
        table.insert(user.defensHistoryList, defensHistory)
    end
end
function UserDataModel:WorldAidDetail(msg)
    user.ConvergeAid = ArmyAidData.new(msg.c.armyId, msg.c.status, msg.c.counttime, msg.c.time, msg.c.army, msg.c.name, msg.c.shipId)
end
function UserDataModel:WorldTeamInfo(msg)
    me.tableClear(user.teamArmyData)
    for key, var in pairs(msg.c.teamAttack) do
        -- 进攻
        local pConvergeOnfo = allianceConverge.new(1, var.teamId, var.name, var.status, var.countTime, var.time, var.centerId or nil, var.x, var.y, var.attacker, var.defener or nil, var.tp, nil,var.isJoin)
        user.teamArmyData[var.teamId] = pConvergeOnfo
    end
    for key, var in pairs(msg.c.teamDefen) do
        -- 防御
        local pConvergeOnfo = allianceConverge.new(0, var.teamId, var.name, var.status, var.countTime, var.time, var.centerId, var.x, var.y, var.attacker, var.defener, 0,nil,var.isJoin)
        user.teamArmyData[var.teamId] = pConvergeOnfo
    end
end
function UserDataModel:WorldArmyTeamInfo(msg)
    dump(msg)
    user.teamArmyQueueData = ConvergeQueue.new(msg.c.teamId, msg.c.targetName, msg.c.status, msg.c.countTime, msg.c.time, msg.c.targetCenterId, msg.c.x, msg.c.y, msg.c.familyName, msg.c.leaderName, msg.c.maxSoliderNum, msg.c.soliderNum, msg.c.playerNum, msg.c.maxPlayerNum, msg.c.ox, msg.c.oy, msg.c.tp, msg.c.camp or "")
    me.tableClear(user.teamArmyInfoData)
    for key, var in pairs(msg.c.list) do
        local pArmyInfo = TeamArmyData.new(var.armyId, var.status, var.counttime, var.army, var.name, var.shipId)
        dump(pArmyInfo)
        user.teamArmyInfoData[var.armyId] = pArmyInfo
    end
end
function UserDataModel:worldTeamHistory(msg)
    me.tableClear(user.teamHistoryList)
    user.teamHistoryList = { }
    for key, var in pairs(msg.c.list) do
        user.teamHistoryList[#user.teamHistoryList + 1] = TeamHistoryData.new(var.win, var.rType, var.time, var.attacker, var.defener)
    end
end
function UserDataModel:WorldCityArmy(msg)
    dump(msg)
    user.CityteamArmyMaxSoliderNum = msg.c.maxSoliderNum or 0
    user.CityteamArmysoliderNum = msg.c.soliderNum or 0
    user.CityteamArmyteamId = msg.c.teamId or 0
    me.tableClear(user.teamCityArmyInfoData)
    for key, var in pairs(msg.c.list) do
        local pArmyInfo = TeamArmyData.new(var.armyId, var.status, var.counttime, var.army, var.name, var.shipId, var.ctiy, var.fightPower)
        user.teamCityArmyInfoData[var.armyId] = pArmyInfo
    end
    dump(user.teamCityArmyInfoData)
end
-- 奖励文字描述
function UserDataModel:popRewardName(msg)
    for key, var in pairs(msg.c.items) do
        local def = cfg[CfgType.ETC][var[1]]
        if def then
            local str = "获得：" .. def.name .. " x" .. var[2]
            dump(str)
            showTips(str)
        end
    end
end

-- 奖励物品弹窗
function UserDataModel:popRewardItems(msg)
    local i = { }
    for key, var in pairs(msg.c.items) do
        i[#i + 1] = { }
        i[#i]["defId"] = var[1]
        i[#i]["itemNum"] = var[2]
        i[#i]["needColorLayer"] = true
    end
    getItemAnim(i)
end

function UserDataModel:popActivityReward(msg)
    if msg.c.activityId == ACTIVITY_ID_TURNPLATE or msg.c.activityId == ACTIVITY_ID_FRESHMEAT then
        -- 积分抽奖/体力领取，不能立即弹出
        return
    end

    if msg.c.items == nil or table.nums(msg.c.items) <= 0 then
        return
    end

    local i = { }
    for key, var in pairs(msg.c.items) do
        i[#i + 1] = { }
        i[#i]["defId"] = var[1]
        i[#i]["itemNum"] = var[2]
        i[#i]["needColorLayer"] = true
    end
    getItemAnim(i)
end

function UserDataModel:updateBuff(msg)
    user.Role_Buff = { }
    for key, var in pairs(msg.c.list) do
        local def = cfg[CfgType.CITY_BUFF][tonumber(var.id)]
        if user.Role_Buff[def.stype] == nil then
            user.Role_Buff[def.stype] = { }
        end
        user.Role_Buff[def.stype][def.type] = BuffData.new(var.id, var.countDown, def.stype)
    end
end

function UserDataModel:updateProtected(msg)
    user.protectedTime = msg.c.time
    user.protectedType = msg.c.ptype
end
-- 更新主城坐标
function UserDataModel:updataroleorigin(msg)
    user.x = msg.c.x
    user.y = msg.c.y
    user.majorCityCrood = cc.p(msg.c.x, msg.c.y)
end
STEP_SEG = 50
function initFortSegmentData()
    local num = 0
    for key, var in pairs(gameMap.fortDatas) do
        local fcp = var:getCrood()
        local fdis = cc.pGetDistance(user.majorCityCrood, fcp)
        gameMap.fortDatas[key].dis = fdis
        table.insert(gameMap.sortFortDatas, gameMap.fortDatas[key])
        if var.occ == 1 then
            var:resetDirGroups()
        end
        for k, v in pairs(var.dirGroups) do

            local op = me.getCoordByFortId(var.id)
            -- 起始点
            local tp = cc.pAdd(op, cc.pMul(v, STEP_SEG))
            tp = cc.p(math.max(tp.x, 0), math.max(tp.y, 0))
            -- 下一个点
            local sid = me.converDualId(op, tp)
            -- 转换为线段ID
            local sdata = gameMap.lineSegmentDatas[sid]
            if not sdata then
                sdata = segmentData.new(sid)
                gameMap.lineSegmentDatas[sid] = sdata
            end
            -- 构建线段
            if var.occ == 1 then
                -- 如果我当前要塞为已演武
                sdata.state = 1
            end
            local nid = me.getFortIdByCoord(tp)
            -- 下一个点的要塞ID
            local ndata = gameMap.fortDatas[nid]
            if ndata then
                -- 下一个点要塞数据
                ndata:removeDirGroups(v)
            end
            -- 剔除下一个点的。。。
            num = num + 1
        end
    end
    local postdata = gameMap.postFortData
    if postdata then
        local op = postdata[1]
        -- 起始点
        local tp = postdata[2]
        -- 下一个点
        local sid = me.converDualId(op, tp)
        -- 转换为线段ID
        local sdata = segmentData.new(sid)
        -- 构建线段
        gameMap.lineSegmentDatas[sid] = sdata
        sdata.state = 1
        --  dump(gameMap.lineSegmentDatas)
    end
    local function comp(a, b)
        return a.dis < b.dis
    end
    table.sort(gameMap.sortFortDatas, comp)
end
function UserDataModel:fortressInit(msg)
    me.tableClear(user.plotData)
    me.tableClear(user.allianceplot)
    user.plotData = msg.c.point
    user.allianceplot = msg.c.mpoint
    -- 战役标记
    user.battleList = { }
    if msg.c.battleList then
        user.battleList = msg.c.battleList
    end
    -- 地图页面，是否展示王座提示
    user.show_throne_flag = msg.c.show
end
function UserDataModel:fortressFamilyInit(msg)
    for key, var in pairs(msg.c.list) do
        local gu = math.floor(var.giveup / 1000)
        -- 是否放弃要塞
        local x = var.x
        -- 实际坐标
        local y = var.y
        -- 实际坐标
        local name = var.name
        -- 帮会名字
        local mine = var.mine or -1
        -- 1为自已帮会
        local indexX = var.indexX
        -- 1-26的索引坐标
        local indexY = var.indexY
        -- 1-26的索引坐标
        local type_ = var.type
        -- 0 普通 1 占领  2 保护 3 争夺
        local fid = me.getFortIdByCoord(cc.p(x, y))
        local pFortWorld = FortWorldData.new(fid, x, y, name, mine, gu)
        pFortWorld.vType = type_
        pFortWorld.start = var.start or 0
        user.fortWorldData[fid] = pFortWorld
    end
end

function UserDataModel:updateFortDatas(msg)
    for key, var in pairs(msg.c.list) do
        if var.mine and var.mine == 1 then
            local x, y = var.x, var.y
            local fid = me.getFortIdByCoord(cc.p(x, y))
            if fid and gameMap.fortDatas[fid] then
                gameMap.fortDatas[fid].occ = 1
            end
        end
    end
end
-- 更新要塞试炼完成状态
function UserDataModel:fortressExperUpdate(msg)
    local var = msg.c
    local x = var.x
    -- 实际坐标
    local y = var.y
    -- 实际坐标
    local fid = me.getFortIdByCoord(cc.p(x, y))
    local fdata = gameMap.fortDatas[fid]
    fdata.start = var.st or 0
end
function UserDataModel:fortressFamilyUpdate(msg)
    local var = msg.c
    local x = var.x
    -- 实际坐标
    local y = var.y
    -- 实际坐标
    local name = var.name
    -- 帮会名字
    local mine = var.mine or 0
    -- 1为自已帮会
    local indexX = var.indexX
    -- 1-26的索引坐标
    local indexY = var.indexY
    -- 1-26的索引坐标
    local type_ = var.type
    -- 0 普通 1 占领  2 保护 3 争夺 4 锁定
    local camp = var.camp or ""
    -- 跨服 的区服
    local fid = me.getFortIdByCoord(cc.p(x, y))
    local fdata = gameMap.fortDatas[fid]
    local giveup = nil
    if var.giveup then
        giveup = math.floor(var.giveup / 1000)
    end
    if fdata then
        if name then
            local familydata = { }
            -- 工会数据
            familydata.name = name
            familydata.mine = mine
            familydata.camp = camp
            fdata.famdata = familydata
        else
            fdata.famdata = nil
        end
        fdata.oType = type_
        fdata.dtime = var.countDown
        fdata.revTime = me.sysTime()
        -- 收到消息的时间
        fdata.defense = var.defense
        fdata.srcDefense = var.srcDefense
        fdata.npc = var.npc
        fdata.srcNpc = var.srcNpc
        fdata.start = var.start or 0
        fdata.giveup = giveup or 0
    end
end
function UserDataModel:fortressUpdate(msg)
    local count = msg.c.drillCount
    -- 可演武次数
    user.drillCount = count
    for key, var in pairs(msg.c.list) do
        local x = var.x
        -- 实际坐标
        local y = var.y
        -- 实际坐标
        local indexX = var.indexX
        -- 1-26的索引坐标
        local indexY = var.indexY
        -- 1-26的索引坐标
        local occ = var.occ or 0
        -- 1为已经占领 0为可占领
        local fid = me.getFortIdByCoord(cc.p(x, y))
        local fdata = gameMap.fortDatas[fid]
        fdata.occ = occ
    end
end
function UserDataModel:registerLisener(lisener_, key_)
    local guid = me.sysTime() .. "_UserDataModel_" ..(me.sysTime() % 10234) .. "jnmogod"
    if key_ then
        guid = guid .. key_
    end
    self.msglisener[guid] = lisener_
    return guid
end
function UserDataModel:removeLisener(key)
    if key ~= nil then
        self.msglisener[key] = nil
    end

end
function UserDataModel:removeAllLisener()
    me.tableClear(self.msglisener)
    self.msglisener = { }
end
-- 攻击警示
function UserDataModel:attackAlert(msg)
    local wData = warningData.new(msg.c.uid, msg.c.name, msg.c.family, msg.c.time, msg.c.ox, msg.c.oy, msg.c.x, msg.c.y, msg.c.status, msg.c.city, msg.c.countTime, me.sysTime(), msg.c.shorName)
    user.warningList[#user.warningList + 1] = wData
end

-- 攻击警示移除
function UserDataModel:attackAlertRemove(msg)
    for key, var in pairs(user.warningList) do
        if me.toNum(var.uid) == me.toNum(msg.c.uid) then
            print("移除警告队列 index = " .. key)
            table.remove(user.warningList, key)
        end
    end
end

-- 商店购买
function UserDataModel:buyShop(msg)
    if msg.c.defId and msg.c.amount then
        for key, var in pairs(user.shopList[tonumber(msg.c.shopId)]) do
            if var.id == msg.c.id then
                if user.shopList[tonumber(msg.c.shopId)][key].buyed and msg.c.amount then
                    user.shopList[tonumber(msg.c.shopId)][key].buyed = user.shopList[tonumber(msg.c.shopId)][key].buyed + msg.c.amount
                    --                    if user.shopList[tonumber(msg.c.shopId)][key].buyed >= user.shopList[tonumber(msg.c.shopId)][key].limit then
                    --                        user.shopList[tonumber(msg.c.shopId)][key] = nil
                    --                    end
                    break
                end
            end
        end
        local def = cfg[CfgType.ETC][msg.c.defId]
        local str = "购买【" .. def.name .. "x" .. msg.c.amount .. "】成功"
        showTips(str)
    end
end

-- 商店
function UserDataModel:initShop(msg)
    user.shopList[11] = { }
    user.shopList[12] = { }
    user.shopLimit = { [12] = { } }

    local shopId = msg.c.shopId
    if shopId then
        if not user.shopList[shopId] then
            user.shopList[shopId] = { }
        end
        for key, var in pairs(msg.c.list) do
            local sData = ShopItemData.new(var)
            sData.buyed = var.buyed
            sData.limit = var.limit
            user.shopList[shopId][var.id] = sData
        end
        if shopId == 12 then
            user.shopLimit[shopId].buyed = msg.c.buyed
            user.shopLimit[shopId].limit = msg.c.limit
        end
    end
end
-- 军队信息
function UserDataModel:armyInfo(msg)
    armyData.soliderNum = msg.c.soliderNum
    -- 部分数
    armyData.atkTrap = msg.c.atkTrap
    -- 陷井
    armyData.totalAtkTrap = msg.c.totalAtkTrap
    -- 陷井上限
    armyData.toops = msg.c.toops
    -- 队列
    armyData.totalToops = msg.c.totalToops
    -- 队列上限
    armyData.desableSoliderNum = msg.c.desableSoliderNum

    armyData.wonderMax = msg.c.wonderMax
    armyData.curWonder = msg.c.curWonder
    armyData.normalMax = msg.c.normalMax
    armyData.curNormal = msg.c.curNormal
    -- 伤兵
    armyData.totalDesableSoliderNum = msg.c.totalDesableSoliderNum
    armyData.outArmyNum = msg.c.outArmyNum
    armyData.outDisableNum = msg.c.outDisableNum    
    -- 伤兵上限
    -- 禁卫军
    if msg.c.guardArmy then
        user.guardSoldier = { }
        for key, var in pairs(msg.c.guardArmy) do
            user.guardSoldier[tonumber(var.id)] = soldierData.new(tonumber(var.id), tonumber(var.num))
        end
    end
    --本服外城
     user.soldierOut = {}
    if msg.c.armys  then
        for key, var in pairs(msg.c.armys) do
           local cdatas = {}
           cdatas.army = {}
           for k, v in pairs(var.army) do
                 cdatas.army[tonumber(v.id)] = soldierData.new(tonumber(v.id), tonumber(v.num))           
           end  
           cdatas.disable = {}
           for k, v in pairs(var.disable) do
                 cdatas.disable[tonumber(v.id)] = soldierData.new(tonumber(v.id), tonumber(v.num))      
                 cdatas.disable[tonumber(v.id)] .idisable = true     
           end        
           cdatas.x = var.x
           cdatas.y = var.y
           cdatas.id = var.id
           cdatas.index = var.index
           table.insert(user.soldierOut,cdatas)
        end
    end
    --据点
    if msg.c.shs  then        
        for key, var in pairs(msg.c.shs) do
           local cdatas = {}   
           cdatas.army = {}       
           for k, v in pairs(var.army) do
                 cdatas.army[tonumber(v.id)] = soldierData.new(tonumber(v.id), tonumber(v.num))           
           end          
           cdatas.x = var.x
           cdatas.y = var.y
           cdatas.name = var.name
           table.insert(user.soldierOut,cdatas)
        end
    end
end
-- 伤兵初始化
function UserDataModel:revertSoldierInit(msg)
    me.tableClear(user.desableSoldiers)
    for key, var in pairs(msg.c.list) do
        local desableSoldiersNum = 0
        if user.revertingSoldiers[msg.c.bid] ~= nil and table.nums(user.revertingSoldiers[msg.c.bid]) > 0 then
            -- 若有正在治疗的伤兵，则重新给伤兵总数赋值
            desableSoldiersNum = var.num
            user.revertingSoldiers[msg.c.bid]:updateDate(var.defId, desableSoldiersNum)
        end
        local soldierData = revertSoilderData.new(var.defId, var.num, desableSoldiersNum)
        user.desableSoldiers[var.defId] = soldierData
    end
    user.treatNumAdd = msg.c.treatNumAdd
    me.tableClear(user.desableSoldiers_c)
    for key, var in pairs(msg.c.listc) do
        local desableSoldiersNum = 0
        if user.desableSoldiers_c[msg.c.bid] ~= nil and table.nums(user.desableSoldiers_c[msg.c.bid]) > 0 then
            -- 若有正在治疗的伤兵，则重新给伤兵总数赋值
            desableSoldiersNum = var.num
            user.desableSoldiers_c[msg.c.bid]:updateDate(var.defId, desableSoldiersNum)
        end
        local soldierData = revertSoilderData.new(var.defId, var.num, desableSoldiersNum)
        user.desableSoldiers_c[var.defId] = soldierData
    end
end
-- 伤兵恢复返回
function UserDataModel:revertSoldier(msg)
    local rData = revertingData.new(msg.c.bid, msg.c.time, msg.c.ptime, msg.c.army, msg.c.type)
    if msg.c.type == 0 then
        user.revertingSoldiers[msg.c.bid] = rData
    else
        user.revertingSoldiers_c[msg.c.bid] = rData
    end
    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end
-- 伤兵恢复完成
function UserDataModel:revertSoldierFinish(msg)
    local bid = msg.c.bid
    if msg.c.type == 0 then
        if user.revertingSoldiers[msg.c.bid] then
            me.tableClear(user.revertingSoldiers[msg.c.bid])
            user.revertingSoldiers[msg.c.bid] = nil
        end
    else
        if user.revertingSoldiers_c[msg.c.bid] then
            me.tableClear(user.revertingSoldiers_c[msg.c.bid])
            user.revertingSoldiers_c[msg.c.bid] = nil
        end
    end
    if buildingOptMenuLayer:getInstance() then
        buildingOptMenuLayer:getInstance():clearnButton()
    end
    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end
-- 伤兵恢复队列
function UserDataModel:revertSoldierLine(msg)
    local rData = revertingData.new(msg.c.bid, msg.c.time, msg.c.ptime, msg.c.army, msg.c.type)
    if msg.c.type == 0 then
        user.revertingSoldiers[msg.c.bid] = rData
    else
        user.revertingSoldiers_c[msg.c.bid] = rData
    end
end
function UserDataModel:updateBuildingFarmer(msg)
    for key, var in pairs(msg.c.list) do
        if var.build and var.build == 0 then
            -- 0代表非建造/升级的类型
            user.building[var.index].worker = var.farmer
            if (user.produceSoldierData[var.index]) then
                -- 更新在生产士兵倒计时
                if user.produceSoldierData[var.index].stype == 1 then
                    user.produceSoldierData[var.index].ptime = var.time - var.countdown
                else
                    user.produceSoldierData[var.index].ptime = var.time - var.countdown
                end
                user.produceSoldierData[var.index].time = var.time
                user.produceSoldierData[var.index].num = var.pnum
            else
                for key, var2 in pairs(user.techServerDatas) do
                    -- 更新科技倒计时
                    if (var.index == var2.index) then
                        var2.buildTime = var.countdown
                        var2.startTime = me.sysTime()
                    end
                end
                for key, var3 in pairs(user.techTypeDatas) do
                    if (var.index == var3.index) then
                        var3.buildTime = var.countdown
                    end
                end
                for key, var4 in pairs(user.revertingSoldiers) do
                    if (var.index == var4.bid) then
                        -- 使用加速道具后，重新赋值时间
                        user.revertingSoldiers[var.index].ptime = var.time - var.countdown
                        var4.recvTime = me.sysTime()
                    end
                end
                for key, var4 in pairs(user.revertingSoldiers_c) do
                    if (var.index == var4.bid) then
                        -- 使用加速道具后，重新赋值时间
                        user.revertingSoldiers_c[var.index].ptime = var.time - var.countdown
                        var4.recvTime = me.sysTime()
                    end
                end
            end
        else
            -- 调整的是建筑工
            if (user.buildingDateLine[var.index]) then
                -- 正在建设或升级
                user.buildingDateLine[var.index].builder = var.farmer
                user.buildingDateLine[var.index].countdown = var.countdown
            else
                __G__TRACKBACK__("没有找到tofId = " .. var.index .. "的建筑物")
            end
        end
    end

    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end

-- 更新士兵
function UserDataModel:updateSoldier(msg)
    local processValue = msg.process
    -- 更新的来源
    for key, var in pairs(msg.c.list) do
        if var.num > 0 then
            local soldierData = soldierData.new(var.defId, var.num)
            user.soldierData[var.defId] = soldierData
        else
            user.soldierData[var.defId] = nil
        end
    end
end

-- 初始化士兵
function UserDataModel:initSoldier(msg)
    for key, var in pairs(msg.c.soldier) do
        if var.num > 0 then
            local soldierData = soldierData.new(var.defId, var.num)
            -- 士兵升级有此字段，记录升级之前的士兵id
            soldierData.oid = var.oid
            user.soldierData[var.defId] = soldierData
        else
            user.soldierData[var.defId] = nil
        end
    end
    user.produceSoldierData = { }
    if msg.c.prod then
        for key, var in pairs(msg.c.prod) do
            local tData = trainData.new(var.num, var.time, var.ptime, var.buildIndex, var.defId, var.type)
            tData.oid = var.oid
            user.produceSoldierData[var.buildIndex] = tData
        end
        if #msg.c.prod > 0 then

        end
    end

end
-- 训练界面
function UserDataModel:initProduceSoldierView(msg)
    local temp = { }
    for key, var in pairs(msg.c.list) do
        var.num = var.num * 1000
        -- 时间
        temp[var.defid] = var
    end
    user.produceSoldierLockData[msg.c.bindex] = trainViewData.new(msg.c.bindex, msg.c.tranum, temp, msg.c.totalNum, msg.c.wonderMax, msg.c.curWonder)
    dump(user.produceSoldierLockData)
end
-- 生产士兵
function UserDataModel:productionSoldier(msg)
    local var = msg.c
    local soldierData = trainData.new(var.num, var.time, var.ptime, var.buildIndex, var.defId, var.type)
    -- 士兵升级有此字段，记录升级之前的士兵id
    soldierData.oid = var.oid
    user.produceSoldierData[var.buildIndex] = soldierData

    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end
-- 完成生产士兵
function UserDataModel:productionSoldierComplete(msg)
    local var = msg.c
    local trainsoldierData = trainData.new(var.num, var.time, var.ptime, var.buildIndex, var.defId, var.type)
    --   dump(user.produceSoldierData[var.buildIndex])
    --  local lastNum = user.produceSoldierData[var.buildIndex].num or 0
    user.produceSoldierData[var.buildIndex] = trainsoldierData
    if var.num <= 0 then
        if CUR_GAME_STATE == GAME_STATE_CITY and buildingOptMenuLayer:getInstance() then
            buildingOptMenuLayer:getInstance():clearnButton()
        end
        me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
    end
end

-- 升级联盟科技结束
function UserDataModel:updateAllianceTechFinish(msg)
    local dataObj = allianceTechData.new(me.toNum(msg.c.id))
    dataObj:setGivenInfo(1, msg.c.point)
    local def = dataObj:getDef()
    user.familyTechServerDatas[def.techid] = dataObj
    techDataMgr.getFamilyTehcDatas()
end

-- 根据贡献更新当前联盟科技
function UserDataModel:updateAllianceTechByGiven(msg)
    --    dump(msg.c)
    local dataObj = allianceTechData.new(me.toNum(msg.c.id))
    dataObj:setGivenInfo(msg.c.active, msg.c.point)
    local def = dataObj:getDef()
    user.familyTechServerDatas[def.techid] = dataObj
    if user.familyTechDatas[def.techid] then
        user.familyTechDatas[def.techid] = dataObj
    end
end

-- 联盟徽章数据更新
function UserDataModel:updateAllianceGivenData(msg)
    user.allianceGivenData.countDown = msg.c.countDown / 1000
    user.allianceGivenData.gongxian = msg.c.gongxian
    user.allianceGivenData.starTime = me.sysTime() / 1000
end

function UserDataModel:clearAllianceCD(msg)
    user.allianceGivenData.countDown = 0
end

-- 正在升级的联盟科技
function UserDataModel:updatingAllianceTech(msg)
    dump(msg.c)
    for key, var in pairs(msg.c.list) do
        local dataObj = allianceTechData.new(me.toNum(var.id))
        dataObj:setUpdateInfo(var.countdown)
        local def = dataObj:getDef()
        user.familyTechServerDatas[def.techid] = dataObj
        user.familyTechDatas[def.techid] = dataObj
    end
end

-- 初始化联盟科技
function UserDataModel:initAllianceTech(msg)
    --    dump(msg.c)
    for key, var in pairs(msg.c.list) do
        local tmp = allianceTechData.new(var.id)
        tmp:setGivenInfo(var.active, var.point)
        local def = tmp:getDef()
        user.familyTechServerDatas[def.techid] = tmp
    end
end

-- 军旗科技初始化
function UserDataModel:initFlagTech(msg)
    if user.flagTechServerDatas then
        me.tableClear(user.flagTechServerDatas)
    end

    for key, var in pairs(msg.c.old) do
        local tmp = techData.new(var)
        tmp:setLockStatus(techData.lockStatus.TECH_USED)
        user.flagTechServerDatas[var] = tmp
    end

    for key, var in pairs(msg.c.teching) do
        local tmp = techData.new(var.techDefId)
        tmp:setLockStatus(techData.lockStatus.TECH_TECHING)
        tmp:setServerInfo(var.countdown, var.index, me.sysTime())
        user.flagTechServerDatas[var.techDefId] = tmp
    end
end

-- 军旗科技升级
function UserDataModel:upFlagTech(msg)
    local testDef = cfg[CfgType.TECH_UPDATE][me.toNum(msg.c.techDefId)]
    if user.flagTechServerDatas[msg.c.techDefId] then
        user.flagTechServerDatas[msg.c.techDefId]:setLockStatus(techData.lockStatus.TECH_TECHING)
        user.flagTechServerDatas[msg.c.techDefId]:setServerInfo(msg.c.countdown, msg.c.index, me.sysTime())
    else
        local tmp = techData.new(msg.c.techDefId)
        tmp:setLockStatus(techData.lockStatus.TECH_TECHING)
        tmp:setServerInfo(msg.c.countdown, msg.c.index, me.sysTime())
        user.flagTechServerDatas[msg.c.techDefId] = tmp
    end

    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end

-- 军旗科技升级完毕
function UserDataModel:finishFlagTech(msg)
    if user.flagTechServerDatas[me.toNum(var)] then
        -- 不做老科技删除操作
        user.flagTechServerDatas[var]:setLockStatus(techData.lockStatus.TECH_FINISH)
        local def = cfg[CfgType.TECH_UPDATE][me.toNum(var)]
        local oldServerDefif = techDataMgr.getTechIDByTypeAndLV(me.toNum(def.techid), me.toNum(def.level - 1))
        if oldServerDefif and user.flagTechServerDatas[oldServerDefif] then
            user.flagTechServerDatas[oldServerDefif] = nil
        end
    else
        __G__TRACKBACK__("in user.flagTechServerDatas msg.c.defId = " .. var .. "not found !!!")
    end

    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end

-- 初始化服务器下发的全类型科技
function UserDataModel:initTech(msg)
    if user.techServerDatas then
        me.tableClear(user.techServerDatas)
    end
    for key, var in pairs(msg.c.old) do
        local tmp = techData.new(var)
        tmp:setLockStatus(techData.lockStatus.TECH_USED)
        user.techServerDatas[var] = tmp
    end

    for key, var in pairs(msg.c.teching) do
        local tmp = techData.new(var.techDefId)
        tmp:setLockStatus(techData.lockStatus.TECH_TECHING)
        dump(var.countdown)
        tmp:setServerInfo(var.countdown, var.index, me.sysTime())
        user.techServerDatas[var.techDefId] = tmp
    end
end

function UserDataModel:stopTeching(tofbid_)
    for key, var in pairs(user.techServerDatas) do
        if var:getTofid() == tofbid_ and var:getLockStatus() == techData.lockStatus.TECH_TECHING then
            user.techServerDatas[key] = nil
        end
    end
    for key, var in pairs(user.techTypeDatas) do
        if var:getTofid() == tofbid_ and var:getLockStatus() == techData.lockStatus.TECH_TECHING then
            user.techTypeDatas[key]:setLockStatus(techData.lockStatus.TECH_UNUSED)
        end
    end
end

-- 科技开始升级
function UserDataModel:upLevelTech(msg)
    -- 修改服务器下发的数据
    local cfgDef = cfg[CfgType.TECH_UPDATE][me.toNum(msg.c.techDefId)]
    if user.techServerDatas[msg.c.techDefId] then
        user.techServerDatas[msg.c.techDefId]:setLockStatus(techData.lockStatus.TECH_TECHING)
        user.techServerDatas[msg.c.techDefId]:setServerInfo(msg.c.countdown, msg.c.index, me.sysTime())
    else
        local tmp = techData.new(msg.c.techDefId)
        tmp:setLockStatus(techData.lockStatus.TECH_TECHING)
        tmp:setServerInfo(msg.c.countdown, msg.c.index, me.sysTime())
        user.techServerDatas[msg.c.techDefId] = tmp
    end

    if cfgDef.techid == getFlagTechIdByCountryID(22000) or cfgDef.techid == getFlagTechIdByCountryID(21000) then
        -- 如果是军旗科技，不需要设置user.techTypeDatas数据
        return
    end

    -- 修改本地客户端数据
    if user.techTypeDatas[msg.c.techDefId] then
        -- 解锁科技开始研究
        user.techTypeDatas[msg.c.techDefId]:setLockStatus(techData.lockStatus.TECH_TECHING)
        user.techTypeDatas[msg.c.techDefId]:setServerInfo(msg.c.countdown, msg.c.index, me.sysTime())
    else
        -- 已开启科技开始升级,找到老科技，重新赋值，但不构造新科技
        local tmpDef = cfg[CfgType.TECH_UPDATE][msg.c.techDefId]
        local oldId = techDataMgr.getTechIDByTypeAndLV(tmpDef.techid, tmpDef.level - 1)
        if user.techTypeDatas[oldId] then
            user.techTypeDatas[oldId]:setLockStatus(techData.lockStatus.TECH_TECHING)
            user.techTypeDatas[oldId]:setServerInfo(msg.c.countdown, msg.c.index, me.sysTime())
        else
            __G__TRACKBACK__("user.techTypeDatas[oldId] = " .. oldId .. " not found !!!")
        end
    end

    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
    --    dump(user.techServerDatas)
end

-- 科技升级完成
function UserDataModel:upLevelTechFinish(msg)
    local var = msg.c.defId
    local def = cfg[CfgType.TECH_UPDATE][me.toNum(var)]
    if user.techServerDatas[me.toNum(var)] then
        user.techServerDatas[var]:setLockStatus(techData.lockStatus.TECH_FINISH)
        local oldServerDefif = techDataMgr.getTechIDByTypeAndLV(me.toNum(def.techid), me.toNum(def.level - 1))
        if def.techid == getFlagTechIdByCountryID(22000) or def.techid == getFlagTechIdByCountryID(21000) then
            oldServerDefif = techDataMgr.getTechIDByTypeAndLV(me.toNum(def.techid), me.toNum(def.level - 1), user.countryId)
        end
        if oldServerDefif and user.techServerDatas[oldServerDefif] then
            user.techServerDatas[oldServerDefif] = nil
        end
    else
        __G__TRACKBACK__("in user.techServerDatas msg.c.defId = " .. var .. "not found !!!")
    end

    if def.techid == me.toNum(20002) or def.techid == me.toNum(20001) then
        -- 如果是军旗科技，不需要设置user.techTypeDatas数据
        return
    end

    if user.techTypeDatas[me.toNum(var)] then
        -- 解锁完毕
        user.techTypeDatas[var]:setLockStatus(techData.lockStatus.TECH_FINISH)
    else
        -- 升级完毕
        local tmpDef = cfg[CfgType.TECH_UPDATE][me.toNum(var)]
        local oldId = techDataMgr.getTechIDByTypeAndLV(tmpDef.techid, tmpDef.level - 1)
        if user.techTypeDatas[oldId] then
            user.techTypeDatas[oldId] = nil
        end
        local tmp = techData.new(me.toNum(var))
        tmp:setLockStatus(techData.lockStatus.TECH_USED)
        user.techTypeDatas[me.toNum(var)] = tmp
    end

    if buildingOptMenuLayer:getInstance() then
        buildingOptMenuLayer:getInstance():clearnButton()
    end

    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
end

function UserDataModel:errorAlert(msg)

    disWaitLayer()
    -- 错误提示id
    local alert = msg.c.alert
    -- 错误提示name
    local alertType = msg.c.alertType
    -- 错误提示类型  1是警示框,2是警示飘文本 3常规飘文本
    local content = msg.c.content
    if alert == "PUBLIC_ALERT" then
        me.showMessageDialog(content[1] or "未定义", function(args) end)
        return
    elseif alert == "PUBLIC_MSG" then
        showErrorMsg(content[1] or "未定义")
        return
    end
    -- 错误提示中如果有道具需求
    if alertType == 2 then
        showTips(errorAlertMsg[alert] or alert, "ff0000")
        if alert == "TEAM_THAN_MAX_SOLIDER" or alert == "TEAM_THAN_MAX" then
            -- 联盟刷新
            me.dispatchCustomEvent("rev_event_convergeFire")
        end
    elseif alertType == 3 then
        print(errorAlertMsg[alert])
        if errorAlertMsg[alert] then
            if content then
                dump(content)
                -- local c = me.cjson.decode(content)
                -- dump(c)
                if content then
                    showTips(fitAlertMsg(errorAlertMsg[alert], content), "ffffff")
                end
            end
        else
            showTips(alert, "ffffff")
        end
    elseif alertType == 1 then
        if "OTHER_LOGIN" == alert then
            NetMan:close()
        end
        me.showMessageDialog(errorAlertMsg[alert], function(args)
            if args == "ok" then
                -- me.Helper:endGame()
                if "OTHER_LOGIN" == alert then
                    -- self:goLogon()
                    local loadtomenu = loadBackMenu:create("loadScene.csb")
                    me.runScene(loadtomenu)
                end
            end
        end )
    end
    print("++++++++++error alert+++++++++ " .. alert)
end
-- 初始化已经建好的建筑
function UserDataModel:initBuilding(msg)
    local typeBuild = { }
    user.buildingTypeNum = nil
    user.buildingTypeNum = { }
    for key, var in pairs(msg.c.list) do
        local building = BuildIngData.new(var.index, var.defId, var.data, var.farmer)
        building.state = BUILDINGSTATE_NORMAL.key
        user.building[var.index] = building
        local typeNum = user.buildingTypeNum[building:getDef().type]
        if (typeNum == nil) then
            typeNum = 1
        else
            typeNum = typeNum + 1
        end
        user.buildingTypeNum[building:getDef().type] = typeNum

        if (building:getDef().type == cfg.BUILDING_TYPE_CENTER) then
            user.centerBuild = building
        end
    end
    print("UserDataModel:initBuilding")
    SharedDataStorageHelper():flushNewBuildings()
end

-- 本地增加在建或者正在升级的建筑
function UserDataModel:addStructDateLine(index, defId, countdown)

    local building = BuildIngStructData.new(index, defId, countdown, upLevel)
    local upLevel = true
    if user.building[index] then
        upLevel = true
        user.building[var.index].state = BUILDINGSTATE_LEVEUP.key
    else
        upLevel = false
    end
    building.needWorker = false
    user.buildingDateLine[index] = building
end

-- 初始化正在建或者正在升级的建筑
function UserDataModel:initStructDateLine(msg)
    for key, var in pairs(msg.c.list) do
        -- 是否升级
        local upLevel = true
        if user.building[var.index] then
            upLevel = true
            user.building[var.index].state = BUILDINGSTATE_LEVEUP.key
            if me.isValidStr(var.newDefId) then
                user.building[var.index].state = BUILDINGSTATE_CHANGE.key
            end
        else
            upLevel = false
        end

        local building = BuildIngStructData.new(var.index, var.defId, var.countdown, upLevel, var.farmer)
        if upLevel then
            building.state = BUILDINGSTATE_LEVEUP.key
            if me.isValidStr(var.newDefId) then
                building.state = BUILDINGSTATE_CHANGE.key
            end
        else
            building.state = BUILDINGSTATE_BUILD.key
        end
        building.needWorker = true
        -- 区分建造状态
        user.buildingDateLine[var.index] = building
    end
end

-- 在建建筑
function UserDataModel:structDateLine(msg)
    local var = msg.c
    local building = BuildIngStructData.new(var.index, var.defId, var.countdown, false, var.farmer)
    building.state = BUILDINGSTATE_BUILD.key
    user.buildingDateLine[var.index] = building
    if user.building[var.index] then
        user.building[var.index].state = BUILDINGSTATE_BUILD.key
    end
end
-- 升级建筑
function UserDataModel:upLevelDateLine(msg)
    local var = msg.c
    local building = BuildIngStructData.new(var.index, var.defId, var.countdown, true, var.farmer)
    building.state = BUILDINGSTATE_LEVEUP.key
    building.recvTime = me.sysTime()
    user.buildingDateLine[var.index] = building
    if user.building[var.index] then
        user.building[var.index].state = BUILDINGSTATE_LEVEUP.key
    end
end
-- 转换奇迹
function UserDataModel:changeDateLine(msg)
    local var = msg.c
    local building = BuildIngStructData.new(var.index, var.defId, var.countdown, true, var.farmer)
    building.state = BUILDINGSTATE_CHANGE.key
    building.recvTime = me.sysTime()
    user.buildingDateLine[var.index] = building
    if user.building[var.index] then
        user.building[var.index].state = BUILDINGSTATE_CHANGE.key
    end
    SharedDataStorageHelper():flushNewBuildings()
end
-- 建筑建造完成返回
function UserDataModel:structFinishBuild(msg)

    user.buildingDateLine[msg.c.index] = nil
    -- 从升级队列移除
    local building = BuildIngData.new(msg.c.index, msg.c.defId, 0, msg.c.farmer)
    building.state = BUILDINGSTATE_NORMAL.key
    user.building[msg.c.index] = building
    if (building:getDef().type == cfg.BUILDING_TYPE_CENTER) then
        user.centerBuild = building
    end
    SharedDataStorageHelper():flushNewBuildings()
    if buildingOptMenuLayer:getInstance() then
        buildingOptMenuLayer:getInstance():clearnButton()
    end
end
-- 返回在建(新建的或者正在升级的)的指定类型建筑物的数目
function UserDataModel:getBuildingLineTypeNumWithStatus(type_, state_)
    local num = 0
    local function findStatus(d_, s_)
        if me.toNum(d_.state) == me.toNum(s_) then
            return 1
        end
        return 0
    end
    for key, var in pairs(user.buildingDateLine) do
        if var:getDef().type == type_ then
            if state_ then
                num = num + findStatus(var, state_)
            else
                num = num + 1
            end
        end
    end
    return num
end
function UserDataModel:addBuildingNum(type_)
    local typeNum = user.buildingTypeNum[type_]
    if (typeNum == nil) then
        typeNum = 1
    else
        typeNum = typeNum + 1
    end
    user.buildingTypeNum[type_] = typeNum
end
-- 建筑升级完成返回
function UserDataModel:upLevelFinishBuild(msg)

    user.buildingDateLine[msg.c.index] = nil
    -- 从升级队列移除
    local building = BuildIngData.new(msg.c.index, msg.c.defId, 0, msg.c.farmer)
    building.state = BUILDINGSTATE_NORMAL.key
    user.building[msg.c.index] = building
    if (user.building[msg.c.index]:getDef().type == cfg.BUILDING_TYPE_CENTER) then
        user.centerBuild = user.building[msg.c.index]
        -- me.LogTable(user.centerBuild,"user.centerBuild ========================")
    end
    SharedDataStorageHelper():flushNewBuildings()
    if buildingOptMenuLayer:getInstance() then
        buildingOptMenuLayer:getInstance():clearnButton()
    end
end
-- 奇迹转换完成
function UserDataModel:changeFinish(msg)
    user.buildingDateLine[msg.c.index] = nil
    -- 从升级队列移除
    local building = BuildIngData.new(msg.c.index, msg.c.defId, 0, msg.c.farmer)
    building.state = BUILDINGSTATE_NORMAL.key
    user.building[msg.c.index] = building
    if buildingOptMenuLayer:getInstance() then
        buildingOptMenuLayer:getInstance():clearnButton()
    end
end
----生产农民数据
-- function UserDataModel:produceFarmer(msg)
--    if user.produceframerdata == nil then
--        user.produceframerdata = produceframerData.new(msg.c.num,msg.c.time/1000,msg.c.ptime/1000)
--    else
--        user.produceframerdata.num = msg.c.num    --要生产的个数
--        user.produceframerdata.time = msg.c.time/1000 --生产一个农民需要的时间
--        user.produceframerdata.ptime = msg.c.ptime/1000 --当前生产农民走了多少时间
--    end
--    print(user.produceframerdata.num)
-- end
-- 初始化背包
function UserDataModel:initUserBackPack(msg)
    for key, var in pairs(msg.c.list) do
        local etcItem = EtcItemData.new(var.uid, var.defId, var.count, var.locValue, var.locData, var.remateTime)
        print(var.uid)
        local varCfg = cfg[CfgType.ETC][var.defId]

        if varCfg.useType == 124 or varCfg.useType == 125 then
            -- 符文材料
            user.materBackpack[var.uid] = etcItem
            if varCfg.useType == 125 then
                user.strengthStone = etcItem
            end
            if var.defId == 80 or var.defId == 885 then
                -- 特殊处理洗炼石放放背包
                user.pkg[var.uid] = etcItem
            end
        elseif varCfg.useType == 136 or varCfg.useType == 137 then
            --战舰改装材料
            user.metaRefitBackpack[var.uid] = etcItem
        else
            user.pkg[var.uid] = etcItem
            if var.defId == 268 then
                user.zhaohuanItemNums = user.zhaohuanItemNums + var.count
            end
        end
    end
end

-- 增加修改道具背包
function UserDataModel:userBackPackChange(msg)
    -- 来源 这个操作来自哪里
    local processValue = msg.c.processValue
    local var = msg.c.iteminfo
    local etcItem = EtcItemData.new(var.uid, var.defId, var.count, var.locValue, var.locData, var.remateTime, true)
    local varCfg = cfg[CfgType.ETC][var.defId]
    if varCfg.useType == 124 or varCfg.useType == 125 then
        -- 符文材料
        if user.materBackpack[var.uid] == nil then
            etcItem.isnew = true
        else
            etcItem.isnew = user.materBackpack[var.uid].isnew
        end
        user.materBackpack[var.uid] = etcItem
        if varCfg.useType == 125 then
            user.strengthStone = etcItem
        end
        if var.defId == 80 or var.defId == 885 then
            -- 特殊处理洗炼石、幸运石放放背包
            user.pkg[var.uid] = etcItem
        end
    elseif varCfg.useType == 136 or varCfg.useType == 137 then
            --战舰改装材料
            user.metaRefitBackpack[var.uid] = etcItem 
    else
        local incremental = var.count
        if user.pkg[var.uid] then
            incremental = var.count - user.pkg[var.uid].count
            if var.defId == 268 then
                -- 缓存召唤马车道具数量
                user.zhaohuanItemNums = user.zhaohuanItemNums + incremental
            end
        else
            if var.defId == 268 then
                -- 缓存召唤马车道具数量
                user.zhaohuanItemNums = user.zhaohuanItemNums + var.count
            end
        end
        etcItem.incremental = incremental
        user.pkg[var.uid] = etcItem
    end
    if me.toNum(processValue) == 131 then
        payMgr:getInstance():closeChooseIap()
    end
end

-- 移除道具背包
function UserDataModel:userBackPackRemove(msg)
    local processValue = msg.c.processValue
    local uid = msg.c.uid
    if user.pkg[uid] then
        if user.pkg[uid].defid == 268 then
            -- 缓存召唤马车道具数量
            user.zhaohuanItemNums = user.zhaohuanItemNums - user.pkg[uid].count
        end

        user.pkg[uid] = nil
    end
    if user.materBackpack[uid] then
        user.materBackpack[uid] = nil
    end
    if user.strengthStone then
        if user.strengthStone.id == uid then
            user.strengthStone = nil
        end
    end
end

-- 更新钻石
function UserDataModel:updatePayGem(msg)
    if me.toNum(msg.c.process) == 11 and me.toNum(msg.c.value) > 0 then
        -- 道具使用
        showTips("+元宝" .. msg.c.value - user.paygem)
    elseif me.toNum(msg.c.process) == 48 and me.toNum(msg.c.value) > 0 then
        -- 考古来源
        showTipsNoBg("元宝x" .. msg.c.value - user.paygem)
    elseif me.toNum(msg.c.process) == 106 and me.toNum(msg.c.value) > 0 then
        -- 进阶名将来源
        --        showTips("使用钻石x" .. user.diamond - msg.c.value)
    end
    local processValue = msg.c.p
    local v = msg.c.value
    user.paygem = v
    if me.toNum(msg.c.process) == 12 or me.toNum(msg.c.process) == 81 then
        payMgr:getInstance():closeChooseIap()
    end
end
-- 更新钻石
function UserDataModel:updateGem(msg)
    if me.toNum(msg.c.process) == 11 and me.toNum(msg.c.value) > 0 then
        -- 道具使用
        showTips("+钻石" .. msg.c.value - user.diamond)
    elseif me.toNum(msg.c.process) == 48 and me.toNum(msg.c.value) > 0 then
        -- 考古来源
        showTipsNoBg("钻石x" .. msg.c.value - user.diamond)
    elseif me.toNum(msg.c.process) == 106 and me.toNum(msg.c.value) > 0 then
        -- 进阶名将来源
        --        showTips("使用钻石x" .. user.diamond - msg.c.value)
    end
    local processValue = msg.c.p
    local v = msg.c.value
    user.diamond = v
    if me.toNum(msg.c.process) == 12 or me.toNum(msg.c.process) == 81 then
        payMgr:getInstance():closeChooseIap()
    end
end
-- 更新粮食
function UserDataModel:updateFood(msg)
    if me.toNum(msg.c.process) == 11 and me.toNum(msg.c.value) > 0 then
        showTips("+粮食" .. msg.c.value - user.food)
    elseif me.toNum(msg.c.process) == 48 and me.toNum(msg.c.value) > 0 then
        showTipsNoBg("粮食x" .. msg.c.value - user.food)
    end
    local processValue = msg.c.p
    local v = msg.c.value
    user.food = v
end
-- 更新黄金
function UserDataModel:updateGold(msg)
    if me.toNum(msg.c.process) == 11 and me.toNum(msg.c.value) > 0 then
        showTips("+黄金" .. msg.c.value - user.gold)
    elseif me.toNum(msg.c.process) == 48 and me.toNum(msg.c.value) > 0 then
        showTipsNoBg("黄金x" .. msg.c.value - user.gold)
    end
    local processValue = msg.c.p
    local v = msg.c.value
    user.gold = v
end
-- 更新石头
function UserDataModel:updateStone(msg)
    -- 使用石头
    if me.toNum(msg.c.process) == 11 and me.toNum(msg.c.value) > 0 then
        showTips("+石头" .. msg.c.value - user.stone)
    elseif me.toNum(msg.c.process) == 48 and me.toNum(msg.c.value) > 0 then
        showTipsNoBg("石头x" .. msg.c.value - user.stone)
    end
    local processValue = msg.c.p
    local v = msg.c.value
    user.stone = v
end
-- 更新木材
function UserDataModel:updateWood(msg)
    if me.toNum(msg.c.process) == 11 and me.toNum(msg.c.value) > 0 then
        showTips("+木材" .. msg.c.value - user.wood)
    elseif me.toNum(msg.c.process) == 48 and me.toNum(msg.c.value) > 0 then
        showTipsNoBg("木材x" .. msg.c.value - user.wood)
    end
    local processValue = msg.c.p
    local v = msg.c.value
    user.wood = v
end

-- 更新资源
function UserDataModel:updateResource(msg)
    if msg.c.process == 57 and msg.c.food > 0 and msg.c.gold > 0 and msg.c.stone > 0 and msg.c.wood > 0 then
        local str = "粮食+%d 木材+%d 石材+%d 黄金+%d"
        str = string.format(str, msg.c.food - user.food, msg.c.wood - user.wood, msg.c.stone - user.stone, msg.c.gold - user.gold)
        dump(str)
        --showTips(str)
    elseif msg.c.process == 106 then
        -- 进阶后资源更新
        local str = ""
        local num = 0
        if me.toNum(msg.c.food) > 0 then
            num = msg.c.food
            str = "消耗粮食-"
        elseif me.toNum(msg.c.wood) > 0 then
            num = msg.c.wood
            str = "消耗木材-"
        elseif me.toNum(msg.c.stone) > 0 then
            num = msg.c.stone
            str = "消耗石材-"
        elseif me.toNum(msg.c.gold) > 0 then
            num = msg.c.gold
            str = "消耗黄金-"
        end
        showTips(str .. num)
    end
    local processValue = msg.c.p
    user.food = msg.c.food
    user.wood = msg.c.wood
    user.gold = msg.c.gold
    user.stone = msg.c.stone
end

-- 更新城市数据
function UserDataModel:updateCityInfo(msg)
    user.maxFood = msg.c.maxFood
    user.maxWood = msg.c.maxWood
    user.maxStone = msg.c.maxStone
    user.maxGold = msg.c.maxGold
    user.workfarmer = msg.c.workFarmer
    -- 工作中的工人
    user.maxfarmer = msg.c.farmer
    -- 工人上限
    user.curfarmer = msg.c.farmer
    -- 当前工人
    user.idlefarmer = user.curfarmer - user.workfarmer
    -- 空闲工人
end

-- 更新内城资源点数据
function UserDataModel:updateRandResource(msg)
    user.cityRandResource = { }
    for key, var in pairs(msg.c.list) do
        local resource = CityRandResource.new(var.defId, var.place, var.value, var.work, var.outValue)
        user.cityRandResource[var.place] = resource
    end
end
-- 初始化用户数据
function UserDataModel:initUserInfo(msg)
    dump(msg)
    user.heroSkillStatus = msg.c.hss
    user.uid = msg.c.uid
    user.name = msg.c.name
    user.faceIcon = msg.c.faceIcon
    user.food = msg.c.food
    user.wood = msg.c.wood
    user.gold = msg.c.gold
    user.stone = msg.c.stone
    user.vip = msg.c.vipLevel
    user.vipExp = msg.c.vipExp
    user.vipTime = msg.c.vipTime
    user.vip_buys = msg.c.buy
    user.iget_free = msg.c.daily
    user.todayExp = msg.c.todayExp
    user.vipLastUpdateTime = os.time()
    user.countryId = msg.c.country
    user.curfarmer = msg.c.farmer
    user.paygem = msg.c.paygem
    user.title = msg.c.title
    user.vipshow = msg.c.showVip
    user.idlefarmer = user.curfarmer - user.workfarmer
    -- 城市皮肤
    user.adornment = msg.c.adornment
    user.totem = msg.c.totem
    user.showTotem = msg.c.showTotem
    -- 头像
    user.head = msg.c.head
    -- 形象
    user.image = msg.c.image
    -- msg.c.country
    print("----------------------" .. user.countryId)
    user.diamond = msg.c.gem
    user.grade = msg.c.fightPower
    -- 战斗力
    server.systime = msg.c.sysTime
    user.lv = msg.c.level
    user.exp = msg.c.exp
    user.familyUid = msg.c.familyUid
    user.familyName = msg.c.familyName
    user.familyDegree = msg.c.familyDegree
    user.maxPower = msg.c.maxPower
    -- 体力上限
    user.currentPower = msg.c.power
    -- 当前体力
    user.lansize = msg.c.lansize
    user.sid = msg.c.sid
    -- 服务器id
    user.source = msg.c.source
    -- 平台id
    user.x = msg.c.x
    user.y = msg.c.y
    user.majorCityCrood = cc.p(user.x, user.y)

    user.protectedTime = msg.c.protectedTime
    user.protectedType = msg.c.protectedType
    user.recover.restTime = msg.c.updatePowerTime
    user.recover.recvTime = os.time()

    user.updateName = msg.c.updateName
    user.movecity = msg.c.moveCity
    -- 新手引导索引
    guideHelper.setGuideIndex(msg.c.guideIndex)
end
-- 迁城状态
function UserDataModel:updatamoveCity(msg)
    user.movecity = msg.c.moveCity
    -- 迁城成功移除原来的城市土地
    -- local id = me.getIdByCoord(c)
    -- local city = gameMap.mapCellDatas[id]
    user.movecity_num = msg.c.moveCity
end
function UserDataModel:mailList(msg)
    for key, var in pairs(msg.c.list) do
        if msg.c.type ~= mailview.MAILHEROLEVEL and msg.c.type ~= mailview.MAILRESIST and msg.c.type ~= mailview.MAILDIGORE then
            local mail = mailData.new(var)
            user.mailList[var.uid] = mail
        end
    end
    --引导战报
--    if mCloudAnimDone == true and guideHelper.getGuideIndex() == guideHelper.guideReport then
--        guideHelper.nextTaskStep()
--    end
end
function UserDataModel:newMail(msg)
    local infoNew = 0
    local battleNew = 0
    local sysNew = 0
    local unionNew = 0
    local total = 0
    local spyNew = 0
    for key, var in pairs(msg.c.list) do
        local type = me.toNum(var[1])
        local num = me.toNum(var[2])
        if type == mailview.MAILPERSONAL then
            infoNew = infoNew + num
        elseif type == mailview.MAILUNION then
            unionNew = unionNew + num
        elseif type == mailview.MAILFIGHT then
            battleNew = battleNew + num
        elseif type == mailview.MAILSYSTEM then
            sysNew = sysNew + num
        elseif type == mailview.MAILSPY then
            spyNew = spyNew + num
        end
        total = total + num
    end
    if msg.c.tp and msg.c.tp == 1 then
        -- 1 跨服邮件
        local NetBattle = { }
        NetBattle.infoNew = infoNew
        NetBattle.battleNew = battleNew
        NetBattle.sysNew = sysNew
        NetBattle.unionNew = unionNew
        NetBattle.spyNew = spyNew
        user.newMail.NetBattle = NetBattle
        user.newMail.SeverType = msg.c.tp
    else
        local Netan = { }
        Netan.infoNew = infoNew
        Netan.battleNew = battleNew
        Netan.sysNew = sysNew
        Netan.unionNew = unionNew
        Netan.spyNew = spyNew
        user.newMail.Netan = Netan
        user.newMail.SeverType = 0
    end
end

function UserDataModel:mailGet(msg)
    user.mailList[msg.c.uid].status = -2
end

function UserDataModel:mailBattleReport(msg)
    local mail
    if msg.c.mtype == 8 then
        mail = user.mailHeroLevelList[msg.c.uid]
    elseif msg.c.mtype == mailview.MAILDIGORE then
        mail = user.mailDigoreList[msg.c.uid]
    elseif msg.c.mtype == mailview.MAILSHIPPVP then
        mail = user.mailShipPvpList[msg.c.uid]
    elseif msg.c.mtype == 9 then
        mail = user.mailResistList[msg.c.uid]
    else
        mail = user.mailList[msg.c.uid]
    end

    mail.success = msg.c.success
    if (msg.c.index == 1) then
        mail.gold = msg.c.gold
        mail.wood = msg.c.wood
        mail.stone = msg.c.stone
        mail.food = msg.c.food
        mail.itemList = msg.c.itemList
        mail.attacker.info = msg.c.attacker
        mail.attacker.infoship = msg.c.attackerShip or nil
        mail.attacker.inforune = msg.c.attackerRune or nil
        mail.defender.info = msg.c.defender
        mail.defender.infoship = msg.c.defenderShip or nil
        mail.defender.inforune = msg.c.defenderRune or nil
    else
        if mail.rType > 2 then
            mail.attacker.fullinfo = msg.c.teamAttacker
            mail.defender.fullinfo = msg.c.teamDefneder
        else
            mail.attacker.fullinfo = msg.c.attacker
            mail.attacker.fullinfoship = msg.c.attackerShip or nil
            mail.defender.fullinfo = msg.c.defender
            mail.defender.fullinfoship = msg.c.defenderShip or nil
            -- 禁卫军
            mail.gArmy = msg.c.gArmy
        end
    end
    if msg.c.detail then
        dump(msg.c.detail)
        print("=============战报详情============")
        local i = 1
        local npc = { }
        npc["1"] = "进攻方"
        npc["0"] = "防守方"
        for key, var in pairs(msg.c.detail) do
            print("第" ..(51 - me.toNum(var[2])) .. "回合")
            local s = ""
            if me.toNum(var[3]) == -1 then
                s = "箭塔"
            else
                s = cfg[CfgType.CFG_SOLDIER][tonumber(var[3])].name
            end
            local str = npc[var[1]] .. "的攻击力为" .. math.floor(var[5]) .. "的" .. var[4] .. "个" .. s .. "攻击防御力为" .. var[9] .. "血量为" .. var[8] .. "的" .. var[7] .. "个" .. cfg[CfgType.CFG_SOLDIER][tonumber(var[6])].name
            .. "造成" .. math.floor(var[10]) .. "伤害" .. "歼敌" .. var[11] .. ",损失" .. var[12]
            print(str)
        end
        print("=============战斗结束============")
    end
end

function UserDataModel:mailSpyReport(msg)
    local mail = user.mailList[msg.c.uid]

    mail.item = msg.c.item
    -- 资源
    mail.npc = msg.c.npc
    --
    mail.army = msg.c.army
    -- 军队
    mail.trap = msg.c.trap
    -- 陷井
    mail.tower = msg.c.tower
    -- 箭塔
    mail.property = msg.c.property
    -- 属性
end

-- 取消建筑物当前工作状态
function UserDataModel:cancelBuildingWork(msg)
    local bid = msg.c.bid
    user.buildingDateLine[bid] = nil
    for key, var in pairs(mainCity.buildingMoudles) do
        if me.toNum(key) == me.toNum(bid) then
            var:cancelWorking()
        end
    end
end
-- 加入/创建联盟，更新个人的联盟信息
function UserDataModel:familyupdatainfor(msg)
    user.familyUid = msg.c.familyUid
    user.familyName = msg.c.familyName
    if msg.c.familyDegree ~= nil then
        user.familyDegree = msg.c.familyDegree
    end
end
-- 创建联盟
function UserDataModel:createFamilyInfo(msg)
    user.family = familyData.new(msg.c.uid, msg.c.exp, msg.c.level, msg.c.ownerName, msg.c.name, msg.c.power, msg.c.memberNumber, msg.c.maxMember, msg.c.levelExp, msg.c.notice)
    user.family.shortname = msg.c.shorName
end

-- 创建联盟失败
function UserDataModel:errorAlertFamily(msg)
    print(msg)
    local alertId = msg.c.alertId
    -- 450-家族名字不匹配 451-家族公告不匹配 408-钻石不足
    if alertId == 450 then
        print("家族名字不匹配")
    elseif alertId == 451 then
        print("家族公告不匹配")
    elseif alertId == 408 then
        print("钻石不足")
    end
end

-- 申请联盟失败
function UserDataModel:errorApplyFamily(msg)
    print(msg)
    local alertId = msg.c.alertId
    -- 440失败
    if alertId == 440 then
        print("等级或者战力不足")
    end
end


-- 联盟列表
function UserDataModel:famliyList(msg)
    for key, var in pairs(msg.c.list) do
        local family = familyData.new(var.uid, var.exp, var.level, var.ownerName, var.name, var.power, var.memberNumber, var.maxMember, var.levelExp, var.notice, var.minLevel, var.minPower, var.recruit, var.appalyStatus)
        family.shortname = msg.c.shorName
        user.familyList[var.uid] = family
    end
end

-- 联盟初始化界面
function UserDataModel:famliyInit(msg)
    user.famliyInit = familyData.new(msg.c.uid, msg.c.exp, msg.c.level, msg.c.ownerName, msg.c.name, msg.c.power, msg.c.memberNumber, msg.c.maxMember, msg.c.levelExp, msg.c.notice, msg.c.minLevel, msg.c.minPower, msg.c.recruit)
    user.famliyInit.shortname = msg.c.shorName
end
-- 更新联盟的招募状态
function UserDataModel:UpdatafamliyInit(msg)
    user.famliyInit.recruit = msg.c.recruit
end
-- 单个成员信息
function UserDataModel:famliyMember(msg)
    dump(msg)
    user.familyMember = familyMemberData.new(msg.c.uid, msg.c.level, msg.c.name, msg.c.power, msg.c.helpNumber, msg.c.maxHelp, msg.c.degree, msg.c.lastlogout, msg.c.x, msg.c.y, msg.c.contribution)
end

-- 联盟成员列表
function UserDataModel:familyMemberList(msg)
    local i = 1
    user.familyabdicatetime = me.toNum(msg.c.abdicate or 0) / 1000
    -- 盟主禅让
    for key, var in pairs(msg.c.list) do
        local member = familyMemberData.new(var.uid, var.level, var.name, var.power, var.helpNumber, var.maxHelp, var.degree, var.lastlogout, var.x, var.y, var.contribution)
        user.familyMemberList[var.uid] = member
        i = i + 1
    end
end
-- 更新联盟成员列表
function UserDataModel:familyUpdataMemberList(msg)
    user.familyMemberList[msg.c.uid] = nil
end
-- 申请联盟
function UserDataModel:famliyApply(msg)
    -- user.familyApply = familyData.new(msg.c.uid, msg.c.exp, msg.c.level, msg.c.ownerName, msg.c.name, msg.c.power, msg.c.memberNumber, msg.c.maxMember, msg.c.levelExp, msg.c.maxHelp, msg.c.notice, msg.c.minLevel, msg.c.minPower)
    user.familyList[msg.c.uid].appalyStatus = msg.c.status
end

-- 申请联盟列表
function UserDataModel:famliyApplyList(msg)
    for key, var in pairs(msg.c.list) do
        local family = familyData.new(var.uid, var.exp, var.level, var.ownerName, var.name, var.power, var.memberNumber, var.maxMember, var.levelExp, var.notice, var.minLevel, var.minPower)
        family.shortname = msg.c.shorName
        user.familyApplyList[var.uid] = family
    end
end

-- 邀请列表
function UserDataModel:familyRequestList(msg)
    me.tableClear(user.familyRequestList)
    for key, var in pairs(msg.c.list) do
        local family = familyData.new(var.uid, var.exp, var.level, var.ownerName, var.name, var.power, var.memberNumber, var.maxMember, var.levelExp, var.notice, var.minLevel, var.minPower)
        family.shortname = msg.c.shorName
        user.familyRequestList[var.uid] = family
    end
end

-- 邀请成员初始化列表
function UserDataModel:familyRequestMemberInit(msg)
    for key, var in pairs(msg.c.list) do
        local member = familyMemberData.new(var.uid, var.level, var.name, var.power, var.degree, 0, var.helpNumber, var.maxMember, var.x, var.y, var.contribution, var.status)
        user.familyRequestMemberInit[var.uid] = member
    end
end
-- 邀请成员初始化列表
function UserDataModel:familyInviteMemberInit(msg)
    dump(msg.c.list)
    for key, var in pairs(msg.c.list) do
        local member = familyInviteData.new(var.uid, var.leve, var.nickName, var.power, var.x, var.y)
        user.familyInviteMemberInit[var.uid] = member
    end
    dump(user.familyInviteMemberInit)
end
--
function UserDataModel:UpdataInviteMenber(msg)
    user.familyInviteMemberInit[msg.c.uid] = nil
end
-- 更新邀请数据
function UserDataModel:familyRequest(msg)
    local pMember = user.familyRequestMemberInit[msg.c.uid]
    pMember.inviteStatus = msg.c.status
end

-- 请求帮助
function UserDataModel:famliyHelp(msg)
    user.familyHelp = msg.c.roleUid
end

-- 更新联盟贡献
function UserDataModel:familyContribution(msg)
    user.familyContribution = msg.c.contribution
end


-- 加入联盟等级和战力设置
function UserDataModel:familySetMinData(msg)
    user.familySetMinData = msg.c.isSuccess
end
-- 请求帮助过的build id
function UserDataModel:familyHelpedBuildList(msg)
    for key, var in pairs(msg.c.list) do
        user.familyHelpedBid[#user.familyHelpedBid + 1] = var
    end
end
-- 联盟帮助更新，请求帮助数据
function UserDataModel:familyCenterUpdataHelp()
    NetMan:send(_MSG.helpListFamily())
    -- 联盟帮助
end
-- 显示城镇中心帮助按钮 或者 沦陷
function UserDataModel:familyCenterHelp()
    local captiveMasterInfo = CaptiveMgr:getMasterInfo()
    if mainCity and mainCity.buildingMoudles then
        local cBuildMoudle = mainCity.buildingMoudles[user.centerBuild.index]
        if cBuildMoudle then
            if captiveMasterInfo then
                cBuildMoudle:showCenterCaptiveBtn()
            elseif table.nums(user.familyHelpList) > 0 then
                cBuildMoudle:showCenterHelpBtn()
            else
                cBuildMoudle:closeCenterCaptiveBtn()
            end
        end
    end
end
-- 帮助列表
function UserDataModel:familyHelpList(msg)
    user.familyHelpList = { }
    for key, var in pairs(msg.c.help) do
        local familyHelp = familyHelpData.new(var.uid, var.defId, var.roleUid, var.name, var.helpNumber, var.countHelpNumber, var.type)
        local id = var.uid .. '-' .. var.defId .. '-' .. var.roleUid
        user.familyHelpList[id] = familyHelp
    end
    user.familyBeHelpList = { }
    for key, var in pairs(msg.c.behelp) do
        local familyHelp = familyHelpData.new(var.uid, var.defId, var.roleUid, var.name, var.helpNumber, var.countHelpNumber, var.type)
        local id = var.uid .. '-' .. var.defId .. '-' .. var.roleUid
        user.familyBeHelpList[id] = familyHelp
    end
    self:familyCenterHelp()
end

-- 同意申请
function UserDataModel:famliyAgree(msg)
    user.familyAgree = familyData.new(msg.c.uid, msg.c.exp, msg.c.level, msg.c.ownerName, msg.c.name, msg.c.power, msg.c.memberNumber, msg.c.maxMember, msg.c.levelExp, msg.c.notice, msg.c.minLevel, msg.c.minPower)
    user.familyAgree.shortname = msg.c.shorName
end

-- 踢出联盟
function UserDataModel:familyBeKick(msg)
    user.familyBeKick = familyData.new(msg.c.uid, msg.c.exp, msg.c.level, msg.c.ownerName, msg.c.name, msg.c.power, msg.c.memberNumber, msg.c.maxMember, msg.c.levelExp, msg.c.notice, msg.c.minLevel, msg.c.minPower)
    user.familyBeKick.shortname = msg.c.shorName
end

-- 修改公告
function UserDataModel:familyUpdateNotice(msg)
    user.familyNotice = msg.c.notice
end

-- 清理当前的所有的联盟科技数据
function UserDataModel:clearAllFailmyTech()
    me.tableClear(user.familyTechServerDatas)
    me.tableClear(user.familyTechDatas)
    user.familyTechServerDatas = { }
    user.familyTechDatas = { }
end

-- 退出联盟
function UserDataModel:familyMemberEsc(msg)
    user.familyESC = msg.c.isSuccess
end

-- 移除被帮助过的建筑ID
function UserDataModel:removeBulid(msg)
    dump(msg.c)
    local helpAll = false
    for key, var in pairs(msg.c.list) do
        local familyHelpBid = familyMemberData.new(var.bid, var.defId, var.roleUid)
        local id = var.bid .. '-' .. var.defId .. '-' .. var.roleUid
        user.bulidId[id] = familyHelpBid

        if not helpAll then
            if table.nums(msg.c.list) > 1 then
                showTips("成功帮助所有盟友")
                helpAll = true
            else
                local helpListData = user.familyHelpList[id]
                local str = ""
                if helpListData then
                    local uName = helpListData.name
                    if helpListData.ptype == 1 then
                        local bName = cfg[CfgType.BUILDING][helpListData.defId].name
                        str = "成功帮助【" .. uName .. "】建造" .. bName
                    elseif helpListData.ptype == 2 then
                        local bName = cfg[CfgType.BUILDING][helpListData.defId].name
                        str = "成功帮助【" .. uName .. "】升级" .. bName
                    elseif helpListData.ptype == 3 then
                        str = "成功帮助【" .. uName .. "】恢复伤兵"
                    elseif helpListData.ptype == 0 then
                        str = "成功帮助【" .. uName .. "】研究科技"
                    end
                    if str ~= "" then
                        showTips(str)
                    end
                end
            end
        end
    end
end

-- 设置成员地位
function UserDataModel:familySetDegree(msg)
    user.familySetDegree = familyMemberData.new(msg.c.uid, msg.c.level, msg.c.name, msg.c.power, msg.c.degree, msg.c.helpNumber, msg.c.maxHelp, msg.c.x, msg.c.y, msg.c.contribution)
end
function UserDataModel:batteStart(msg)
    local data = msg.c
    gameMap.troopData[data.id] = nil
end
function UserDataModel:purge()
    self:removeAllLisener()
    NetMan:removeMsgLisener(self.msgkey)
end
function UserDataModel:revTroopLineData(msg)
    --  dump(msg)
    local data = msg.c
    --  dump(data.list)
    -- [LUA-print] rev msg:{"t":1557,"c":{"id":1452163855344,"uid":10035,"name":"jkl_20900","ox":18,"oy":177,"x":21,"y":248,"time":42720,"countdown":42720,"speed":8,"status":42,"list":[{"x":22,"y":198},{"x":49,"y":249},{"x":21,"y":248}]}}
    gameMap.troopData[data.id] = troopLineData.new(data.id, cc.p(data.ox, data.oy), cc.p(data.x, data.y), data.time / 1000.0, data.countdown / 1000.0, data.status, data.list, data.speed, data.uid, data.name, data.cTotalData, data.cData, data.cSpeed,
    data.power, data.shorName, data.familyName, data.degree, data.archBookTime, data.hero, data.leader, data.teamUid)
    gameMap.troopData[data.id].occ = data.type
    gameMap.troopData[data.id].queueTag = data.index or -1
    gameMap.troopData[data.id].adornment = data.adornment or 0
    gameMap.troopData[data.id].tm = data.tm
    gameMap.troopData[data.id].pet = data.pet
    -- 1 自己，0 盟友，-1，-2 敌人
    -- paths经过的路径点
end
function UserDataModel:revRemoveArmyTable(msg)
    for key, var in pairs(msg.c.ids) do

    end
    -- 军队
end
function UserDataModel:revRemoveArmy(msg)
    local id = msg.c.id
    -- 军队
end
function UserDataModel:revBastionUpdate(msg)
    local id = msg.c.strongHoldId
    -- 唯一id哦
    local state = msg.c.state
    local bdata = bastionData.new(id, state, msg.c.strongHoldName, cc.p(msg.c.x, msg.c.y), msg.c.strongHoldLv, msg.c.army, msg.c.defense, msg.c.strongHoldtime)
    gameMap.bastionData[id] = bdata
end
function UserDataModel:revBastionDelete(msg)
    local id = msg.c.strongHoldId
    -- 唯一id哦
    gameMap.bastionData[id] = nil
end
function UserDataModel:updatastrongHoldList(msg)
    me.tableClear(gameMap.bastionData)
    for key, var in pairs(msg.c.list) do
        local pStongHold = bastionData.new(var.strongHoldId, var.state, var.strongHoldName, cc.p(var.x, var.y), var.strongHoldLv, var.army, var.defense, var.strongHoldtime)
        gameMap.bastionData[var.strongHoldId] = pStongHold
    end
end
-- 查看地图区域
function UserDataModel:worldMapView(msg)
    for key, var in pairs(msg.c.list) do
        --  dump(var)
        if var.name and var.uid then
            local overdata = overLordData.new(var)
            -- 角色
            gameMap.overLordDatas[var.uid] = overdata
        elseif var.list[1].origin and var.list[1].origin == 1 and var.list[1].type == POINT_CITY then
            -- 跨服没出生
            local pData = var.list[1]
            local overdata = overLordData.new(pData)
            local pUid = me.getFortIdByCoord(cc.p(pData.x, pData.y))
            -- 角色
            gameMap.overLordDatas[- pUid] = overdata
        elseif var.list[1].type == POINT_THRONE then
            local pData = var.list[1]
            local overdata = overLordData.new(pData)
            local pUid = me.getFortIdByCoord(cc.p(pData.x, pData.y))
            -- 角色
            gameMap.throneDatas[pUid] = overdata
        end

        for key2, var2 in pairs(var.list) do
            -- 地块
            local cellData = nil
            if var2.type == POINT_THRONE then
                local pUid = me.getFortIdByCoord(cc.p(var2.x, var2.y))
                cellData = mapCellData.new(var2.x, var2.y, var2.type, pUid, var2.state, -1, -1, 0, 0, 0, 0, 0, nil, nil)
                local near = getThroneNearCrood(cc.p(var2.x, var2.y)) or { }
                local fid = me.getFortIdByCoord(cc.p(var2.x, var2.y))
                for k, v in pairs(near) do
                    local cellData = mapCellData.new(v.x, v.y, POINT_TBASE, pUid, var2.state, -1, -1, 0, 0, 0, 0, 0, nil, nil)
                    cellData:setFortId(fid)
                    local id_ = cellData:getId()
                    gameMap.mapCellDatas[id_] = cellData
                end
            elseif var2.origin and var2.origin == 1 then
                -- 跨服没有出生
                local pUid = me.getFortIdByCoord(cc.p(var2.x, var2.y))
                cellData = mapCellData.new(var2.x, var2.y, var2.type, - pUid, var2.state, -1, -1, 0, 0, 0, 0, 0, nil, var2.origin)
            else
                cellData = mapCellData.new(var2.x, var2.y, var2.type, var.uid, var2.state, var2.px or -1, var2.py or -1, var2.eventId, var2.etime, var2.data, var2.time, var2.pstatus, var.buffs, nil, var2.cityMasterName, var2.masterCamp)
                cellData:setWagonType(var2.wagon)
                cellData.show = var2.show
                cellData.title = var2.title
            end
            local id = cellData:getId()
            if var2.type == POINT_NORMAL then
                -- 初始化世界BOSS数据
                if var2.bossId and var2.bossTime and var2.bossHp then
                    gameMap.bossDatas[id] = bossData.new(var2.bossId, var2.bossTime, var2.bossHp, var2.bossType, var2.bossUn)
                    cellData.bossId = var2.bossId
                    gameMap.bossDatas[id].fk = var2.fk
                else
                    cellData.bossId = -1
                end
            end
            if var2.type == POINT_STRONG_HOLD then
                cellData.strongHoldId = var2.strongHoldId
                cellData.strongHoldLv = var2.strongHoldLv
                cellData.strongHoldtime = var2.strongHoldtime
                cellData.strongHoldName = var2.strongHoldName
                cellData.strongHoldNew = var2.strongHoldNew
                cellData.strongHoldDef = var2.strongHoldDef
            elseif var2.type == POINT_THRONE then
                cellData.throneStatus = var2.throneStatus  -- 王座状态  0:普通,1:争夺中,2:占领中,3:被占领
            end

            gameMap.mapCellDatas[id] = cellData
            gameMap.mapCellDatas[id].adornment = var2.adornment
            gameMap.mapCellDatas[id].totem = var2.totem
            gameMap.mapCellDatas[id].showTotem = var2.showTotem
        end
    end
    if msg.c.mini then
        for key, var in pairs(msg.c.mini) do
            local posX, posY, status = var[1], var[2], var[3]
            if me.toNum(status) == FORTRESS_TAG then
                local cellData = mapCellData.new(posX, posY, POINT_FORT, nil, OCC_STATE_NONE, -1, -1, 0, 0, 0)
                local id = cellData:getId()
                local fid = me.getFortIdByCoord(cc.p(posX, posY))
                cellData:setFortId(fid)
                gameMap.mapCellDatas[id] = cellData
            end
        end
    end

    if msg.c.flist then
        local var = msg.c.flist
        for key2, var2 in pairs(var) do
            -- 地块
            local cellData = mapCellData.new(var2.x, var2.y, POINT_FORT, var.uid, var2.state, var2.px or -1, var2.py or -1, var2.eventId, var2.etime, var2.data)
            cellData:setWagonType(var2.wagon)
            if var2.giveup then
                cellData:setGiveup(math.floor(var2.giveup / 1000))
            end
            local id = cellData:getId()
            gameMap.mapCellDatas[id] = cellData
            --            dump(cellData)
            local fid = me.getFortIdByCoord(cc.p(var2.x, var2.y))
            local fdata = gameMap.fortDatas[fid]

            if var2.name then
                local familydata = { }
                -- 工会数据
                familydata.name = var2.name
                familydata.mine = var2.mine
                familydata.camp = var2.camp or ""
                fdata.famdata = familydata
            end
            fdata.oType = var2.type
            fdata.dtime = var2.countDown
            fdata.defense = var2.defense
            fdata.srcDefense = var2.srcDefense
            fdata.revTime = me.sysTime()
            -- 收到消息的时间
            fdata.npc = var2.npc
            fdata.srcNpc = var2.srcNpc
            fdata.start = var2.start or 0
            fdata.heroId = var2.heroId
            cellData:setFortId(fid)
            -- dump(fdata)

            -- 处理要塞区域8格数据
            local near = getNearCrood(cc.p(var2.x, var2.y)) or { }
            for k, v in pairs(near) do
                --    dump(near)
                local fcellData = mapCellData.new(v.x, v.y, POINT_FBASE, var2.uid, var2.state, var2.px or -1, var2.py or -1, var2.eventId, var2.etime, var2.data)
                fcellData:setWagonType(var2.wagon)
                if var2.giveup then
                    fcellData:setGiveup(math.floor(var2.giveup / 1000))
                end
                fdata.heroId = var2.heroId
                fcellData:setFortId(fid)
                local id_ = fcellData:getId()
                gameMap.mapCellDatas[id_] = fcellData
            end
        end
    end
end
function UserDataModel:updateCellData_Fort(msg)
    if CUR_GAME_STATE ~= GAME_STATE_WORLDMAP_NETBATTLE then return end

    local var = msg.c
    local id = me.getIdByCoord(var)
    if id then
        local cellData = mapCellData.new(var.x, var.y, POINT_FORT, var.uid, var.state, var.px or -1, var.py or -1, var.eventId, var.etime, var.data)
        cellData:setWagonType(var.wagon)
        cellData:setGiveup(math.floor(var.giveup / 1000))
        gameMap.mapCellDatas[id] = cellData
        local fid = me.getFortIdByCoord(cc.p(var.x, var.y))
        local fdata = gameMap.fortDatas[fid]
        if var.name then
            local familydata = { }
            -- 工会数据
            familydata.name = var.name
            familydata.mine = var.mine
            familydata.camp = var.camp or ""
            fdata.famdata = familydata
        end
        fdata.oType = var.type
        fdata.dtime = var.countDown
        fdata.defense = var.defense
        fdata.srcDefense = var.srcDefense
        fdata.revTime = me.sysTime()
        -- 收到消息的时间
        fdata.npc = var.npc
        fdata.srcNpc = var.srcNpc
        fdata.start = var.start or 0
        cellData:setFortId(fid)
        -- 处理要塞区域8格数据
        local near = getNearCrood(cc.p(var.x, var.y)) or { }
        for k, v in pairs(near) do
            local id_ = me.getIdByCoord(cc.p(v.x, v.y))
            if id_ and gameMap.mapCellDatas[id_] then
                local fcellData = mapCellData.new(v.x, v.y, POINT_FBASE, var.uid, var.state, var.px or -1, var.py or -1, var.eventId, var.etime, var.data)
                fcellData:setWagonType(var.wagon)
                fcellData:setGiveup(math.floor(var.giveup / 1000))
                fcellData:setFortId(fid)
                local id_ = fcellData:getId()
                gameMap.mapCellDatas[id_] = fcellData
            end
        end
    end
end
function UserDataModel:updateCellData(msg)
    local var = msg.c
    local cellData = nil
    local id = 1
    local fid = me.getFortIdByCoord(cc.p(var.x, var.y))
    if var.type == POINT_THRONE then
        local pUid = me.getFortIdByCoord(cc.p(var.x, var.y))
        cellData = mapCellData.new(var.x, var.y, var.type, pUid, var.state, -1, -1, 0, 0, 0, 0, 0, nil, nil)
        local near = getThroneNearCrood(cc.p(var.x, var.y)) or { }
        for k, v in pairs(near) do
            local pcellData = mapCellData.new(v.x, v.y, POINT_TBASE, pUid, var.state, -1, -1, 0, 0, 0, 0, 0, nil, nil)
            pcellData:setFortId(fid)
            local id_ = pcellData:getId()
            gameMap.mapCellDatas[id_] = pcellData
        end
    else
        cellData = mapCellData.new(var.x, var.y, var.type, var.uid, var.state, var.px or -1, var.py or -1, var.eventId, var.etime, var.data, var.time, var.pstatus, nil, var.origin)
        cellData:setWagonType(var.wagon)
    end
    local id = cellData:getId()
    cellData:setFortId(fid)
    if var.type == POINT_NORMAL then
        -- 初始化世界BOSS数据
        if var.bossId and var.bossTime and var.bossHp then
            gameMap.bossDatas[id] = bossData.new(var.bossId, var.bossTime, var.bossHp, var.bossType, var.bossUn)
            cellData.bossId = var.bossId
            gameMap.bossDatas[id].fk = var.fk
        else
            cellData.bossId = -1
        end
    end
    if var.type == POINT_STRONG_HOLD then
        cellData.strongHoldId = var.strongHoldId
        cellData.strongHoldLv = var.strongHoldLv
        cellData.strongHoldtime = var.strongHoldtime
        cellData.strongHoldName = var.strongHoldName
        cellData.strongHoldNew = var.strongHoldNew
        cellData.strongHoldDef = var.strongHoldDef
    end
    -- 判断
    local pOldCell = gameMap.mapCellDatas[id]
    if pOldCell ~= nil then
        if pOldCell.pointType == POINT_STRONG_HOLD and var.type ~= POINT_STRONG_HOLD then
            cellData.oldStronghold = OLD_STRONGHOLD
        end
    end

    gameMap.mapCellDatas[id] = cellData
    if var.type == POINT_FORT then
        -- 处理要塞区域8格数据
        local near = getNearCrood(cc.p(var.x, var.y)) or { }
        for k, v in pairs(near) do
            local fcellData = mapCellData.new(v.x, v.y, POINT_FBASE, var.uid, var.state, var.px or -1, var.py or -1, var.eventId, var.etime, var.data)
            fcellData:setWagonType(var.wagon)
            fcellData:setFortId(fid)
            local id_ = fcellData:getId()
            gameMap.mapCellDatas[id_] = fcellData
        end
    end

    if var.type == POINT_CITY and var.uid == user.uid then
        user.majorCityCrood = cc.p(var.x, var.y)
    end
    gameMap.mapCellDatas[id].adornment = var.adornment
    gameMap.mapCellDatas[id].totem = var.totem
end
function UserDataModel:removeData(msg)
    local x = msg.c.x
    local y = msg.c.y

end
-- 任务初始化列表
function UserDataModel:initListTask(msg)
    user.taskList = { }
    for key, var in pairs(msg.c.list) do
        local task = taskData.new(var.id, var.defId, var.progress, var.item, var.value, var.count, var.awards)
        user.taskList[var.id] = task
    end
    if mCloudAnimDone == true and guideHelper.isTaskGuideOver() == false then
        guideHelper.nextTaskStep()
    end
end

-- 更新任务
function UserDataModel:updateTask(msg)
    local commendFlag = false
    for key, var in pairs(msg.c.list) do
        print("UserDataModel:updateTask(msg)  var.id = " .. var.id)
        local task = taskData.new(var.id, var.defId, var.progress, var.item, var.value, var.count, var.awards, var.quick)
        if commendFlag == false and(user.taskList[var.id] == nil or var.progress ~= user.taskList[var.id].progress) then
            commendFlag = true
        end
        user.taskList[var.id] = task
        if SharedDataStorageHelper():getNewTask(var.id) == nil or SharedDataStorageHelper():getNewTask(var.id) == 0 then
            SharedDataStorageHelper():setNewTask(var.id, 1)
        end
        if mCloudAnimDone == true and guideHelper.isTaskGuideOver() == false then
            if me.toNum(var.id) == guideHelper.guideReport_TaskID and me.toNum(var.progress) == taskData.completeAble then
                -- 在mailFightInfor里有监听
            elseif me.toNum(var.id) == guideHelper.guideComArch_TaskID and me.toNum(var.progress) == taskData.completeAble then
            elseif me.toNum(var.id) == guideHelper.guideRelic_TaskID and me.toNum(var.progress) == taskData.completeAble then
            elseif me.toNum(var.id) == guideHelper.guideRelicCon_TaskID and me.toNum(var.progress) == taskData.completeAble then
            else
                guideHelper.nextTaskStep()
            end
        end
    end
    if commendFlag == true then
        me.dispatchCustomEvent("UI_COMMEND_TASK")
    end
end

-- 领取完成后的任务
function UserDataModel:completeTask(msg)
    me.dispatchCustomEvent("UI_TASK_COMPLETE", user.taskList[msg.c.id])
    user.taskList[msg.c.id] = nil
    if user.commendTaskId and user.commendTaskId == msg.c.id then
        user.commendTaskId = nil
    end

    if guideHelper.isGuideOver() == false then
        -- 首登任务完成的引导
        guideHelper.nextStepByOpt(false, nil)
    end

    me.dispatchCustomEvent("UI_COMMEND_TASK")
end

-- 礼包状态更新
function UserDataModel:packageUpdata(msg)
    -- dump(msg.c)
    if user.packageData then
        user.packageData.status = msg.c.status
        user.packageData.id = msg.c.id
        user.packageData.award = msg.c.award
        user.packageData.times = msg.c.times
        user.packageData.revtime = me.sysTime()
    else
        user.packageData = packageData.new(msg.c.id, msg.c.status, msg.c.award, msg.c.times)
    end
end

-- 初始化考古背包道具
function UserDataModel:initUserBookPkg(msg)
    -- 分2table个来存储数据
    for key, var in pairs(msg.c.list) do
        local etcItem = EtcItemData.new(var.uid, var.defId, var.count, var.locValue, var.locData, var.remateTime)
        etcItem.equipLoc = var.equipLoc
        etcItem.level = var.level
        if var.locValue == 2 then
            -- 装备
            user.bookEquip[var.uid] = etcItem
        else
            user.bookPkg[var.uid] = etcItem
        end
    end
end

-- 增加考古背包道具
function UserDataModel:userBookPkgChange(msg)
    -- 有可能增加一个table减少另一个
    -- 来源 这个操作来自哪里
    local processValue = msg.c.processValue
    local var = msg.c.iteminfo
    local pNum = getArchPropNum(var.uid)
    local etcItem = EtcItemData.new(var.uid, var.defId, var.count, var.locValue, var.locData, var.remateTime)
    etcItem.equipLoc = var.equipLoc
    etcItem.level = var.level
    if var.locValue == 2 then
        -- 装备
        user.bookEquip[var.uid] = etcItem
        user.bookPkg[var.uid] = nil
    else
        user.bookPkg[var.uid] = etcItem
        user.bookEquip[var.uid] = nil
    end
    -- 显示TIPS
    if (me.toNum(processValue) == EXPED_STATE_ARCHING or me.toNum(processValue) == 14) and(CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_CITY) then
        local def = etcItem:getDef()
        showTipsNoBg(def.name .. "x" ..(etcItem.count - pNum))
    end
end

-- 移除考古背包道具
function UserDataModel:userBookPkgRemove(msg)
    local processValue = msg.c.processValue
    local uid = msg.c.uid
    user.bookPkg[uid] = nil
end

-- 考古界面初始化
function UserDataModel:bookInit(msg)

    local menuList = msg.c.menu
    -- 已开启的图鉴册
    local menuid = msg.c.menuId
    -- 当前图鉴册
    user.bookHand = msg.c.menu
    -- 已开启的图鉴册
    user.bookHandId = msg.c.menuId
    -- 当前图鉴册
    user.bookAtlas = { }
    for key, var in pairs(msg.c.list) do
        local defId = var.id
        -- 图鉴id
        local open = var.open
        -- 是否已经开启
        local pbookAltas = bookAltasData.new(var.id, var.open)
        user.bookAtlas[var.id] = pbookAltas
    end
    -- 红点
    user.archRedPoints = msg.c.bookTech
end
function UserDataModel:bookMenuAdd(msg)
    local pId = msg.c.id
    user.bookHand[pId] = pId
end
function UserDataModel:bookAdd(msg)
    local pId = msg.c.id
    local pbookAltas = bookAltasData.new(pId, 1)
    user.bookAtlas[pId] = pbookAltas
end
-- 图鉴合成
function UserDataModel:bookCompound(msg)
    local defId = msg.c.defId
    -- 合成的id
    local amount = msg.c.amount
    -- 合成的数量
    user.archRedPoints = msg.c.bookTech
    guideHelper.nextStepByOpt()
end

function UserDataModel:updateMonthInfo(msg)
    local newData = nil
    local index = nil
    if #user.monthWeekInfos == 0 then
        newData = monthWeekData.new(msg.c)
        user.monthWeekInfos[1] = newData
    else
        for key, var in pairs(user.monthWeekInfos) do
            if me.toNum(var.id) == me.toNum(msg.c.id) then
                newData = monthWeekData.new(msg.c)
                index = me.toNum(key)
            end
        end
        user.monthWeekInfos[index] = newData
        dump(user.monthWeekInfos)
    end
end

-- 月卡信息
function UserDataModel:monthInfo(msg)
    me.tableClear(user.monthWeekInfos)
    user.monthWeekInfos = { }
    for key, var in pairs(msg.c.list) do
        user.monthWeekInfos[#user.monthWeekInfos + 1] = monthWeekData.new(var)
    end
    dump(user.monthWeekInfos)
end

-- 商店物品信息
function UserDataModel:recharge(msg)
    for key, var in pairs(msg.c.list) do
        local recharge = rechargeData.new(var)
        user.recharge[var.id] = recharge
    end
end

-- 活动List
function UserDataModel:activityList(msg)
    me.tableClear(user.activityList)
    user.activityList = { }
    for key, var in pairs(msg.c.list) do
        user.activityList[#user.activityList + 1] = { }
        user.activityList[#user.activityList]["id"] = var.id
        user.activityList[#user.activityList]["gp"] = var.gp
    end
end
-- 活动初始界面
function UserDataModel:activityInitView(msg)
    if msg.c.activityId == ACTIVITY_ID_NEWCOMER then
        -- 新军礼包
        user.activityDetail = novicePackData.new(msg.c.price, msg.c.items, msg.c.activityId, msg.c.time, msg.c.status)
        user.activityDetail.itemid = msg.c.itemId
    elseif msg.c.activityId == ACTIVITY_ID_SEVENTHLOGIN then
        -- 7日登录
        user.activityDetail = seventhPackData.new(msg.c.list, msg.c.activityId)
    elseif msg.c.activityId == ACTIVITY_ID_SIGNIN then
        -- 签到
        user.activityDetail = SignAwardData.new(msg.c.activityId, msg.c.currentDay, msg.c.list, msg.c.openDate, msg.c.endDate, msg.c.isshow)
    elseif msg.c.activityId == ACTIVITY_ID_RECHARGE then
        -- 充值返利
        user.activityDetail = RechargeRebateData.new(msg.c.activityId, msg.c.startDate, msg.c.closeDate, msg.c.list)
    elseif msg.c.activityId == ACTIVITY_ID_FIRST then
        -- 首充
        user.activityDetail = FirstChargeAwardData.new(msg.c.activityId, msg.c.items, msg.c.status)
    elseif msg.c.activityId == ACTIVITY_ID_EXCHANGE then
        -- 积分商城
        --        user.activityDetail = ExchangeData.new(msg.c.activityId,msg.c.items,msg.c.status)
    elseif msg.c.activityId == ACTIVITY_ID_TURNPLATE then
        -- 积分转盘
        user.activityDetail_trunplate = TurnplateData.new(msg.c.activityId, msg.c.list, msg.c.activityNum, msg.c.rewarder)
    elseif msg.c.activityId == ACTIVITY_ID_FRESHMEAT then
        -- 盛宴
        user.activityDetail = FreshMeatData.new(msg.c.activityId, msg.c.open, msg.c.power, msg.c.dlist)
    elseif msg.c.activityId == ACTIVITY_ID_FOUNDATION then
        -- 基金奖励活动
        user.activityDetail = FoundatonData.new(msg.c.activityId, msg.c.changeCount, msg.c.changeLimit, msg.c.list, msg.c.multiplying)
    elseif msg.c.activityId == ACTIVITY_ID_ALLIANCEATTACK then
        -- 联盟攻城
        user.activityDetail = AttackSHData.new(msg.c.activityId, msg.c.startDate, msg.c.closeDate, msg.c.list)
    elseif msg.c.activityId == ACTIVITY_ID_PLUNDER then
        -- 掠夺天下
        user.activityDetail = PlunderWorldData.new(msg.c.activityId, msg.c.day, msg.c.gls, msg.c.num, msg.c.list)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT or msg.c.activityId == ACTIVITY_SHIP_PACKAGE or msg.c.activityId == ACTIVITY_ID_DAYGIFT then
        -- 活动奖励
        user.activityDetail = GiftData.new(msg.c)
    elseif msg.c.activityId == ACTIVITY_ID_TIMELIMIT or msg.c.activityId == ACTIVITY_ID_TIMELIMIT_NEW then
        -- 限时活动
        if msg.c.open == nil or msg.c.open == 0 then
            -- 活动未开启
            user.activityDetail = timeLimitData.new(msg.c.activityId, msg.c.countDown, msg.c.list)
        elseif msg.c.open ~= nil and msg.c.open == 1 then
            -- 活动开启
            user.activityDetail = timeLimitDetailData.new(msg.c.activityId, msg.c.countDown, msg.c.list, msg.c.number, msg.c.smallId, msg.c.stage, msg.c.singleRanking, msg.c.totalRanking)
        end
    elseif msg.c.activityId == ACTIVITY_ID_VIPTIMEL or msg.c.activityId == ACTIVITY_ID_VIPTIMEL_SKIP then
        -- VIP特惠
        user.activityDetail = VipTimelData.new(msg.c.activityId, msg.c.gls, msg.c.list, msg.c.cd, msg.c.std or 0, msg.c.cd)
    elseif msg.c.activityId == ACTIVITY_ID_NATIONALDAY then
        -- 国庆特庆祝
        user.activityDetail = NationalDayData.new(msg.c.activityId, msg.c.items, msg.c.needs)
        user.activityDetail.openDate = msg.c.openDate
        user.activityDetail.endDate = msg.c.endDate
    elseif msg.c.activityId == ACTIVITY_ID_BOSS or msg.c.activityId == ACTIVITY_ID_BOSS_NEW then
        -- boss战
        user.activityDetail = ActivityBossData.new(msg.c.activityId, msg.c.items, msg.c.countDown, msg.c.open)
        user.activityDetail.val = msg.c.value
        user.activityDetail.single = msg.c.single
        user.activityDetail.timedesc = msg.c.timedesc or ""
    elseif msg.c.activityId == ACTIVITY_ID_DAILY_HAPPY then
        -- 每日狂欢
        user.activityDetail = DailyHappyData.new(msg.c.activityId, msg.c.open, msg.c.list, msg.c.integralItems, msg.c.countDown, msg.c.numIntegral)
    elseif msg.c.activityId == ACTIVITY_ID_DAYPAY or
        msg.c.activityId == ACTIVITY_ID_SUM_DAYPAY or
        msg.c.activityId == ACTIVITY_ID_DAY_SPENDING or
        msg.c.activityId == ACTIVITY_ID_SUMPAY or
        msg.c.activityId == ACTIVITY_ID_RUNE or
        msg.c.activityId == ACTIVITY_ID_SUMCOST or
        msg.c.activityId == ACTIVITY_ID_COSTRANK or
        msg.c.activityId == ACTIVITY_ID_NET_COSTRANK or
        msg.c.activityId == ACTIVITY_ID_PAYRANK or
        msg.c.activityId == ACTIVITY_ID_NET_PAYRANK

    then
        -- 每日充值 每日总充值 每日消费
        user.activityPayData[msg.c.activityId] = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_MONTHCARD then
        user.activityMonthCardData[msg.c.activityId] = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_EXCHANGE then
        -- 礼包兑换
        --        dump(msg.c)
    elseif msg.c.activityId == ACTIVITY_ID_LIMITED_REDEMPTION then
        -- 限时兑换
        user.activityDetail = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR then
        -- 元旦集字
        user.activityDetail = NationalDayData.new(msg.c.activityId, msg.c.items, msg.c.needs)
    elseif msg.c.activityId == ACTIVITY_ID_MID_AUTUMN_BLESS then
        -- 中秋集福
        user.activityDetail = NationalDayData.new(msg.c.activityId, msg.c.items, msg.c.needs)
        user.activityDetail.openDate = msg.c.openDate
        user.activityDetail.endDate = msg.c.endDate
    elseif msg.c.activityId == ACITVITY_ID_NEW_SPRING then
        -- 新春礼包
        user.activityDetail = NewSpringData.new(msg.c.activityId, msg.c.rewarder, msg.c.time)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA or msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW then
        user.activityDetail = NewYearDayData.new(msg.c.activityId, msg.c.gd, msg.c.sc, msg.c.er, msg.c.tr, msg.c.gls, msg.c.openDate, msg.c.endDate)
        user.activityDetail.exg = msg.c.exg
        user.activityDetail.cd = msg.c.countdown or 0
        user.activityDetail.open = msg.c.open
        user.activityDetail.show = msg.c.show
        user.activityDetail.desc = msg.c.desc
    elseif msg.c.activityId == ACTIVITY_ID_HONGBAO then
        -- 红包
        user.activityDetail = HongBaoData.new(msg.c)
    elseif msg.c.activityId == ACTIVITY_ID_VEVRYDAY then
        -- 每日抢购
        user.activityDetail = EveryDayData.new(msg.c.activityId, msg.c.rid, msg.c.rwd, msg.c.tr, msg.c.ls, msg.c.buy, msg.c.nm, msg.c.tl)
    elseif msg.c.activityId == ACTIVITY_ID_LADOUR or msg.c.activityId == ACTIVITY_ID_LADOUR_ then
        user.activityDetail = LadourDayData.new(msg.c.activityId, msg.c.countDown, msg.c.list)
    elseif msg.c.activityId == ACTIVITY_ID_WEEKYSIGN then
        -- 周签到
        user.activityDetail = WeekySignData.new(msg.c.activityId, msg.c.got, msg.c.dayNum, msg.c.weekNum, msg.c.currentWeek, msg.c.records, msg.c.rewards, msg.c.extras)
    elseif msg.c.activityId == ACTIVITY_ID_MEDAL then
        -- 武勋兑换活动
        user.activityDetail = MedalData.new(msg.c.activityId, msg.c.wuXunNm, msg.c.list, msg.c.openDate, msg.c.endDate, msg.c.integral)
    elseif msg.c.activityId == ACTIVITY_ID_WISH then
        -- 许愿珠活动
        user.activityDetail = WishData.new(msg.c.activityId, msg.c.openDate, msg.c.endDate, msg.c.needId, msg.c.haveNum, msg.c.synId, msg.c.synHave, msg.c.x, msg.c.y)
    elseif msg.c.activityId == ACTIVITY_SHIP_PACKAGE then
        -- 许愿珠活动
        user.activityDetail = WishData.new(msg.c.activityId, msg.c.openDate, msg.c.endDate, msg.c.needId, msg.c.haveNum, msg.c.synId, msg.c.synHave, msg.c.x, msg.c.y)
    elseif msg.c.activityId == ACTIVITY_ID_MID_AUTUMN_FESTIVAL then
        user.activityDetail = MidAutumnFestivalData.new(msg.c.activityId, msg.c.countDown, msg.c.list)
    elseif msg.c.activityId == ACTIVITY_ID_REDEEM then
        user.activityDetail = RedeemData.new(msg.c.activityId, msg.c.moonScore, msg.c.list, msg.c.openDate, msg.c.endDate, msg.c.desc)
    elseif msg.c.activityId == ACTIVITY_ID_RESIST_INVASION or msg.c.activityId == ACTIVITY_ID_RESIST_INVASION_NEW then
        user.activityDetail = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_DRAGON or msg.c.activityId == ACTIVITY_ID_DRAGON_NEW then
        user.activityDetail = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_NETBATTLE then
        user.activityDetail = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_TIME_TURNPLATE then
        user.turnplateScore = msg.c.score
    elseif msg.c.activityId == ACTIVITY_ID_DIGORE or msg.c.activityId == ACTIVITY_ID_SHOP  then
        user.activityDetail = msg.c
    end
end
-- 更新许愿珠的数量
function UserDataModel:refreshWishNum(msgC, t)
    if t == MsgCode.BOX_REMAKE then
        if user.activityDetail then
            user.activityDetail.synHave = msgC.dec
        end
    elseif t == MsgCode.ACTIVITY_WISH then
        for key, var in pairs(msgC.items) do
            local i = { }
            i[#i + 1] = { }
            i[#i]["defId"] = var[1]
            i[#i]["itemNum"] = var[2]
            i[#i]["needColorLayer"] = true
            getItemAnim(i)
        end
        local tmpIndex = nil
        local insertItem = { }
        for key, var in pairs(user.activityDetail.synHave) do
            if me.toNum(var[1]) == msgC.id then
                tmpIndex = key
                insertItem[#insertItem + 1] = msgC.id
                insertItem[#insertItem + 1] = msgC.num
                break
            end
        end
        if tmpIndex and insertItem then
            table.remove(user.activityDetail.synHave, tmpIndex)
            table.insert(user.activityDetail.synHave, tmpIndex, insertItem)
        end
    end
end
-- 活动积分界面的信息更新
function UserDataModel:updateAcitityInfo(msg)
    if checkMsg(msg.t, MsgCode.ACTIVITY_VIGOUR_INFO) then
        if user.activityDetail and user.activityDetail.activityId == ACTIVITY_ID_TURNPLATE then
            --            user.activityDetail:setHelpData()
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_DARW_RECORD) then
        if user.activityDetail_trunplate and user.activityDetail_trunplate.activityId == ACTIVITY_ID_TURNPLATE then
            user.activityDetail_trunplate:setRewardList(msg.c)
        end
    end
end
-- 更新活动界面
function UserDataModel:updateActivityDetail(msg)
    if msg.c.activityId == ACTIVITY_ID_NEWCOMER then
        -- 新军礼包
        user.activityDetail.status = msg.c.status
        user.activityDetail.price = msg.c.price
    elseif msg.c.activityId == ACTIVITY_ID_SEVENTHLOGIN then
        -- 7日登录
        for key, var in pairs(user.activityDetail.list) do
            if me.toNum(key) == msg.c.id then
                var.status = msg.c.status
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_SIGNIN then
        -- 签到
        for key, var in pairs(user.activityDetail.items) do
            if me.toNum(var.defId) == msg.c.id then
                var.status = msg.c.status
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_RECHARGE then
        -- 充值返利
        for key, var in pairs(user.activityDetail.list) do
            if me.toNum(key) == msg.c.id then
                var.status = msg.c.status
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_FIRST then
        -- 首充
        user.activityDetail.status = msg.c.status
    elseif msg.c.activityId == ACTIVITY_ID_EXCHANGE then
        -- 积分商城
        --        dump(msg)
    elseif msg.c.activityId == ACTIVITY_ID_TURNPLATE then
        -- 积分转盘 (获得奖励的弹窗,在turnplateSubcell界面里有监听了)
    elseif msg.c.activityId == ACTIVITY_ID_FRESHMEAT then
        dump(msg)
    elseif msg.c.activityId == ACTIVITY_ID_BOSS or msg.c.activityId == ACTIVITY_ID_BOSS_NEW then
        -- boss战
        user.activityDetail = ActivityBossData.new(msg.c.activityId, msg.c.items, msg.c.countDown, msg.c.open)
        user.activityDetail.val = msg.c.value
        user.activityDetail.single = msg.c.single
        user.activityDetail.timedesc = msg.c.timedesc or ""
    elseif msg.c.activityId == ACTIVITY_ID_FOUNDATION then
        -- 基金奖励
        --        dump(msg)
        --        dump(user.activityDetail.dlist)
        for key, var in pairs(user.activityDetail.dlist) do
            if me.toNum(var.lv) == msg.c.lv then
                var.status = msg.c.status
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_ALLIANCEATTACK then
        -- 联盟攻城
        dump(msg)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT then
        -- 活动礼包
        for key, var in pairs(msg.c.gls) do
            for inKey, inVar in pairs(user.activityDetail.rewards) do
                if me.toNum(key) == me.toNum(inVar.id) then
                    showTips("购买成功")
                    inVar.value = var
                end
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_PLUNDER then
        -- 掠夺天下
        user.activityDetail.gls = msg.c.gls
    elseif msg.c.activityId == ACTIVITY_ID_TIMELIMIT or msg.c.activityId == ACTIVITY_ID_TIMELIMIT_NEW then
        -- 限时活动更新
        user.activityDetail:update(msg.c.stage, msg.c.status)
    elseif msg.c.activityId == ACTIVITY_ID_VIPTIMEL or msg.c.activityId == ACTIVITY_ID_VIPTIMEL_SKIP then
        -- vip特惠
        user.activityDetail.gls = msg.c.gls
    elseif msg.c.activityId == ACTIVITY_ID_NATIONALDAY then
        -- 国庆特庆祝
        user.activityDetail:sortByNeeds(msg.c.needs)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_EXCHANGE then
        -- 礼包兑换
        dump(msg.c)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR then
        -- 元旦集字
        user.activityDetail:sortByNeeds(msg.c.needs)
    elseif msg.c.activityId == ACTIVITY_ID_MID_AUTUMN_BLESS then
        -- 中秋集福
        user.activityDetail:sortByNeeds(msg.c.needs)
    elseif msg.c.activityId == ACTIVITY_ID_DAYPAY or
        msg.c.activityId == ACTIVITY_ID_SUM_DAYPAY or
        msg.c.activityId == ACTIVITY_ID_DAY_SPENDING or
        msg.c.activityId == ACTIVITY_ID_SUMPAY or
        msg.c.activityId == ACTIVITY_ID_RUNE or
        msg.c.activityId == ACTIVITY_ID_SUMCOST or
        msg.c.activityId == ACTIVITY_ID_COSTRANK or
        msg.c.activityId == ACTIVITY_ID_NET_COSTRANK or
        msg.c.activityId == ACTIVITY_ID_PAYRANK or
        msg.c.activityId == ACTIVITY_ID_NET_PAYRANK or
        msg.c.activityId == ACTIVITY_ID_RECHARGE_GEM then
        -- 每日充值 每日总充值 每日消费
        user.activityPayData[msg.c.activityId] = msg.c
    elseif msg.c.activityId == ACTIVITY_ID_MONTHCARD then
        for key, var in pairs(user.activityMonthCardData[msg.c.activityId].list) do
            if var.id == msg.c.id then
                user.activityMonthCardData[msg.c.activityId].list[key] = msg.c
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA or msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW then
        -- 新春活动
        if msg.c.typeid == NewYear.INTEGR then
            user.activityDetail.IntegrReward = msg.c.gls
        else
            user.activityDetail.GoogLuckNum = msg.c.nm
        end
        user.activityDetail.exg = msg.c.exg
        user.activityDetail.show = msg.c.show
    elseif msg.c.activityId == ACITVITY_ID_NEW_SPRING then
        -- 新春礼包
        for key, var in pairs(msg.c.gls) do
            for inKey, inVar in pairs(user.activityDetail.rewards) do
                if me.toNum(key) == me.toNum(inVar.id) then
                    showTips("购买成功")
                    inVar.value = var
                end
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_HONGBAO then
        -- 红包活动
    elseif msg.c.activityId == ACTIVITY_ID_VEVRYDAY then
        --
        user.activityDetail.isbuy = msg.c.buy
        user.activityDetail.BuyDayNum = msg.c.nm
        user.activityDetail.ReceiceReward = msg.c.gls
        -- 已领取奖励

    elseif msg.c.activityId == ACTIVITY_ID_WEEKYSIGN then
    elseif msg.c.activityId == ACTIVITY_ID_TIME_TURNPLATE then
        user.turnplateScore = msg.c.score
    elseif msg.c.activityId == ACTIVITY_ID_MEDAL then
        -- 武勋兑换活动
        user.activityDetail = MedalData.new(msg.c.activityId, msg.c.wuXunNm, msg.c.list, msg.c.openDate, msg.c.endDate, msg.c.integral)
    elseif msg.c.activityId == ACTIVITY_ID_WISH then
        -- 许愿珠活动更新
        if msg.c.synHave and table.nums(msg.c.synHave) > 0 then
            user.activityDetail.synHave = msg.c.synHave
        end
        if me.isValidStr(msg.c.haveNum) then
            user.activityDetail.haveNum = msg.c.haveNum
        end
    elseif msg.c.activityId == ACTIVITY_ID_REDEEM then
        user.activityDetail.wuXunNm = msg.c.moonScore
        for k, v in pairs(msg.c.list) do
            for _k, _v in pairs(user.activityDetail.list) do
                if v.defId == _v.defId then
                    _v.limit = v.limit
                    break
                end
            end
        end
    elseif msg.c.activityId == ACTIVITY_ID_RESIST_INVASION or msg.c.activityId == ACTIVITY_ID_RESIST_INVASION_NEW then
        user.activityDetail = msg.c
    end
end

function UserDataModel:noticeInfo(msg)
    local noticeId = msg.c.id
    local noticetxt = msg.c.txt
    if noticeId == 98 then
        -- 失败
    elseif noticeId == 10000 then
        -- 发什么显示什么的跑马灯
        local quee = { }
        quee.num = 1
        quee.plv = 1
        quee.txt = string.gsub(noticetxt[1], "#38 ", "")
        -- quee.txt = "<txt0018,fcf33e>"..quee.txt.."&"
        quee.txt = quee.txt
        marqueeMgr.getInstance():addQuee(quee)
    elseif noticeId == 99 then
    elseif noticeId == 102 then
    elseif noticeId == 103 then
    elseif noticeId == 199 then
    elseif noticeId == 198 then
        -- 胜利
    elseif noticeId == 97 then
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_SKIP_FORT)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 100))
        me.runningScene():addChild(pCityCommon, me.MAXZORDER)
    elseif noticeId < 500 then
        -- 邮件信息
        me.DelayRun( function()
            showEventTips(msg)
        end , 0.6)
        setNoticeinfo(noticeId, noticetxt, true)
    elseif noticeId < 1000 then
        --
        showNoticeWithCfg(msg)
        -- 配置跑马灯
    end
end
function UserDataModel:resourceBuildingInfo(msg)
    local data = msg.c.data
    -- 资源量
    local bindex = msg.c.bindex
    -- 建筑id
    if mainCity.buildingMoudles[bindex] then
        mainCity.buildingMoudles[bindex].resInfo = data
    end
end
OpenButtonID_Month = 1          -- 1	月卡	zhucheng_yk_zhengchang
OpenButtonID_Activity = 2       -- 2	活动	zhucheng_hd_zhengchang
OpenButtonID_Battle = 3         -- 3	外城	zhucheng_wc_anniu_zhengchang
OpenButtonID_Arch = 4           -- 4	考古	zhucheng_kg_zhengchang
OpenButtonID_Event = 5          -- 5	事件
OpenButtonID_Collection = 6     -- 6	内城采集点
OpenButtonID_Tax = 7            -- 7	税收	zhucheng_shuishou_zhengchang
OpenButtonID_Iap = 8            -- 支付
OpenButtonID_Ranking = 9            -- 9    排行榜 zhucheng_anniu_paiming_zhengchang
OpenButtonID_Pay = 10           -- 活动充值
OpenButtonID_Eleven = 11           -- 双十一活动
OpenButtonID_Share = 12        -- 分享活动
OpenButtonID_WVERYDAY = 13 --    每日抢购
OpenButtonID_RELIC = 14 --    圣物按钮
OpenButtonID_WorldTask = 16 --外城任务
OpenButtonID_GrowWay = 17   -- 成长之路
OpenButtonID_TaskBtn = 18   -- 任务
OpenButtonID_LookMail = 19   -- 查看战报邮件
OpenButtonID_ALLOTERWORKER = 20 --分配工人
OpenButtonID_ComArch = 21 --考古合成
function UserDataModel:initButtonStatus(msg)
    me.tableClear(user.newBtnIDs)
    for key, var in pairs(msg.c.buttonId) do
        user.newBtnIDs[me.toStr(var)] = var
    end
    switchButtons()
end
-- 更新战斗力
function UserDataModel:updateFightPower(msg)
    if false == msg.c.notShow then
        if msg.c.v - user.grade > 0 then
            -- 飘字提示
            local scene = cc.Director:getInstance():getRunningScene()
            local fapNode = me.createNode("Node_FapChange.csb")
            fapNode:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 170))
            scene:addChild(fapNode, 999999 + 1)
            fapNode:setVisible(false)
            local panel = me.assignWidget(fapNode, "panel")
            panel:setScale(2.5)
            local text_fap = me.assignWidget(panel, "text_fap")
            text_fap:setString(msg.c.v)
            local size = text_fap:getContentSize()
            local x, y = text_fap:getPosition()
            local img_fap = me.assignWidget(panel, "img_fap")
            img_fap:setPosition(cc.p(x - size.width / 2 - 25, y))
            local text_add = me.assignWidget(panel, "text_add")
            text_add:setString("+"..(msg.c.v - user.grade))
            text_add:setPosition(cc.p(x + size.width / 2 + 30, y))
            -- 数字列表
            local tmpList = {}
            local tmpFap = msg.c.v
            while (tmpFap > 0) do
                local n = tmpFap % 10
                table.insert(tmpList, n)
                tmpFap = (tmpFap - n) / 10
            end
            local numList = {}
            for i = #tmpList, 1, -1 do
                table.insert(numList, tmpList[i])
            end
            local tmpCount = 0
            fapNode:runAction(cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.Show:create(),
                cc.CallFunc:create(function()
                    panel:runAction(cc.Sequence:create(
                        cc.ScaleTo:create(0.1, 1.0),
                        cc.CallFunc:create(function()
                            fapNode:scheduleUpdateWithPriorityLua(function(t)
                                tmpCount = tmpCount + 1
                                local newList = {}
                                for i, v in ipairs(numList) do
                                    newList[i] = (v + tmpCount) % 10
                                end
                                text_fap:setString(table.concat(newList))
                                if tmpCount >= 40 then
                                    fapNode:unscheduleUpdate()
                                    fapNode:runAction(cc.Sequence:create(
                                        cc.DelayTime:create(1.0),
                                        cc.CallFunc:create(function()
                                            fapNode:removeFromParentAndCleanup(true)
                                        end)
                                    ))
                                end
                            end, 1)
                        end)
                    ))
                end)
            ))
        end
    end
    user.grade = msg.c.v
end
-- 更新体力
function UserDataModel:updatePower(msg)
    local process = msg.c.process

    if (process == 58 and msg.c.value - user.currentPower == 1) or(user.currentPower == getUserMaxPower() and getUserMaxPower() - msg.c.value > 0) then
        local strTb = me.split(cfg[CfgType.CFG_CONST][23].data, ":")
        user.recover.restTime = me.toNum(strTb[1])
        if user.propertyValue["EnergySpeed"] and user.propertyValue["EnergySpeed"] > 0 then
            user.recover.restTime = user.recover.restTime /(1 + user.propertyValue["EnergySpeed"])
        end
        user.recover.recvTime = os.time()
        local parent = mainCity or pWorldMap
        if parent and parent.lordView and parent.lordView.close then
            parent.lordView.Text_strengthNum:setString(msg.c.value .. "/" .. getUserMaxPower())
            if parent.lordView.recoverTimer then
                me.clearTimer(parent.lordView.recoverTimer)
                parent.lordView.recoverTimer = nil
            end
            parent.lordView:setRecoverTimer()
        end
    end

    if (process == 11 or process == 3) and msg.c.value - user.currentPower > 0 then
        showTips("体力+" .. msg.c.value - user.currentPower)
    end

    if msg.c.value >= getUserMaxPower() then
        user.recover.restTime = 0
        if parent and parent.lordView and parent.lordView.close then
            if parent.lordView.recoverTimer then
                me.clearTimer(parent.lordView.recoverTimer)
                parent.lordView.recoverTimer = nil
            end
            parent.lordView:setRecoverTimer()
        end
    end

    -- 当前体力
    user.currentPower = msg.c.value
end
-- 更新地块数量
function UserDataModel:updateLandSize(msg)
    user.lansize = msg.c.v
end
-- 获取地块详情
function UserDataModel:updateLandInfo(msg)
    for key, var in pairs(msg.c.list) do
        local x = var.x
        local y = var.y
    end
end
-- 征税
function UserDataModel:updateTaxInfo(msg)
    local freeCountTime = msg.c.freeCountTime
    -- 免费倒计时
    local freeCount = msg.c.freeCount
    -- 已经使用免费次数
    local freeMaxCount = msg.c.freeMaxCount
    -- 最大免费次数
    local payCount = msg.c.payCount
    -- 已经强征次数
    local payCost = msg.c.payCost
    -- 强征花费
    local payMaxCount = msg.c.payMaxCount
    -- 最大的强征次数
    local resource = msg.c.info

    user.taxInfo = msg.c
    me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
    -- food wood stone gold 可征收的数量
end

-- 圣物普通搜索
function UserDataModel:runeNormalSearch(msg)
    if msg.c.id == 1 then
        user.runeNormalSearch = msg.c
        user.runeNormalSearch.recvTime = me.sysTime()
        me.dispatchCustomEvent("BUILD_OVERVIEW_UPDATE")
    end
    -- food wood stone gold 可征收的数量
end

-- 更新资源单位产出
function UserDataModel:updateProducePer(msg)
    user.foodPer = msg.c.food
    user.woodPer = msg.c.wood
    user.stonePer = msg.c.stone
end

function UserDataModel:flushChatMsg(msg)
    if msg.c.broadList then
        for key, var in pairs(msg.c.broadList) do
            self:addTrumpetMsg(var)
        end
    end

    if msg.c.familyList then
        for key, var in pairs(msg.c.familyList) do
            self:addFamliyMsg(var)
        end
    end

    --    dump(user.msgFamilyInfo)
    if msg.c.worldList then
        for key, var in pairs(msg.c.worldList) do
            local tmpMsg = { }
            tmpMsg.c = { }
            tmpMsg.c.name = var.name
            tmpMsg.c.uid = var.uid
            tmpMsg.c.content = var.content
            tmpMsg.c.date = var.date
            tmpMsg.c.fightNum = var.fightNum
            tmpMsg.c.degree = var.degree
            tmpMsg.c.familyName = var.familyName
            tmpMsg.c.shorName = var.shorName
            tmpMsg.c.title = var.title
            tmpMsg.c.worldDegree = var.worldDegree
            tmpMsg.c.head = var.head
            tmpMsg.c.image = var.image
            tmpMsg.c.vip = var.vip
            self:addWorldMsg(tmpMsg)
        end
    end
end
function UserDataModel:addTrumpetMsg(data)
    local newMsg = TrumpetData.new(data.uid, data.nm, data.fsn, data.deg, data.ct, data.pst, data.tp, data.sn, data.date)
    newMsg.worldDegree = data.worldDegree
    if #user.msgTrumpetInfo <= 30 then
        user.msgTrumpetInfo[#user.msgTrumpetInfo + 1] = newMsg
    else
        table.insert(user.msgTrumpetInfo, #user.msgTrumpetInfo + 1, newMsg)
        table.remove(user.msgTrumpetInfo, 1)
    end
end
function UserDataModel:addFamliyMsg(data)
    local newMsg = MsgData.new(data.uid, data.name, data.date, data.content, data.familyName, data.shorName, data.degree, data.fightNum, data.noticeId)
    newMsg.title = data.title or 0
    newMsg.worldDegree = data.worldDegree
    newMsg.head = data.head
    newMsg.image = data.image
    newMsg.vip = data.vip
    if #user.msgFamilyInfo <= 30 then
        user.msgFamilyInfo[#user.msgFamilyInfo + 1] = newMsg
    else
        table.insert(user.msgFamilyInfo, #user.msgFamilyInfo + 1, newMsg)
        table.remove(user.msgFamilyInfo, 1)
    end
end

function UserDataModel:HongBao_Clicked_Succeed(msg)
    if msg.c.result == 1 then
        if msg.c.gem and msg.c.gem >= 0 then
            showTips("获得钻石 +" .. msg.c.gem)
        end
        if msg.c.itemId and msg.c.itemNm and msg.c.itemId > 0 and msg.c.itemNm > 0 then
            local idata = cfg[CfgType.ETC][msg.c.itemId]
            showTips("获得" .. idata.name .. "x" .. msg.c.itemNm)
        end
    else
        showTips("红包中空空如也，请再接再厉")
    end
end

function UserDataModel:addWorldMsg(msg)
    local newMsg = MsgData.new(msg.c.uid, msg.c.name, msg.c.date, msg.c.content, msg.c.familyName, msg.c.shorName, msg.c.degree, msg.c.fightNum, msg.c.noticeId, msg.c.camp, msg.c.title, msg.c.worldDegree)
    newMsg.head = msg.c.head
    newMsg.image = msg.c.image
    newMsg.vip = msg.c.vip or 0
    if #user.msgWorldInfo <= 30 then
        user.msgWorldInfo[#user.msgWorldInfo + 1] = newMsg
    else
        table.insert(user.msgWorldInfo, #user.msgWorldInfo + 1, newMsg)
        table.remove(user.msgWorldInfo, 1)
    end
end
function UserDataModel:rankData(msg)
    user.rankAlliancedatashow = msg.c.show
    if msg.c.typeId == 1 then
        for key, var in pairs(msg.c.list) do
            local prank = RankData.new(var["item"], key)
            user.rankdata[key] = prank
        end
    elseif msg.c.typeId == 2 then
        for key, var in pairs(msg.c.list) do
            local prank = RankAllianceData.new(var["item"], key)
            user.rankAlliancedata[key] = prank
        end
    elseif msg.c.typeId == 3 then
        for key, var in pairs(msg.c.list) do
            local prank = RankPlunderData.new(var["item"], key)
            user.plunderData[key] = prank
        end
    elseif msg.c.typeId == 4 then
        for key, var in pairs(msg.c.list) do
            local prank = ScoreData.new(var["item"], key)
            user.scoreData[key] = prank
        end
    elseif msg.c.typeId == rankView.PROMITION_HISTORY or
        msg.c.typeId == rankView.PROMITION_TOTAL or
        msg.c.typeId == rankView.PROMITION_SINGLE or
        msg.c.typeId == rankView.PROMITION_NEWYEAR or
        msg.c.typeId == rankView.PROMITION_NEWYEARTOTAL or
        msg.c.typeId == rankView.PROMITION_MEDAL or
        msg.c.typeId == rankView.PROMITION_MEDALTOTAL
    then
        me.tableClear(user.promotin_LimitList)
        user.promotin_LimitList = { }
        for key, var in pairs(msg.c.list) do
            user.promotin_LimitList[key] = LimitData.new(var["item"], key)
        end
    elseif msg.c.typeId == kingdom_Cross_Score_rank.CROSS_SCORE_RANK then
        for key, var in pairs(msg.c.list) do
            local prank = CrossScoreRank.new(var["item"], key)
            user.CrossScoreRank[key] = prank
        end
    elseif msg.c.typeId == rankView.ACHIEVEMENT then
        for key, var in pairs(msg.c.list) do
            local prank = AScoreData.new(var["item"], key)
            user.AScoreData[key] = prank
        end
    elseif msg.c.typeId == rankView.NETBATTLE_PERSON then
        user.netPersonRankList = { }
        for key, var in pairs(msg.c.list) do
            local prank = NetScoreData.new(var["item"], key)
            user.netPersonRankList[key] = prank
        end
    elseif msg.c.typeId == rankView.NETBATTLE_SERVER then
        user.netServerRankList = { }
        for key, var in pairs(msg.c.list) do
            local prank = NetServerScoreData.new(var["item"], key)
            user.netServerRankList[key] = prank
        end
    end
end

function UserDataModel:updateVipInfo(msg)
    if msg.c.addExp > 0 then
        showTips("Vip点数+" .. msg.c.addExp)
    end
    if msg.c.addTime > 0 then
        showTips("Vip时限已延长")
    end
    if msg.c.addExp > 0 and msg.c.addTime > 0 then
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_VIPLEVELUP)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 100))
        me.runningScene():addChild(pCityCommon, me.MAXZORDER + me.MAXZORDER)
    end
    user.vip = msg.c.level
    user.todayExp = msg.c.todayExp
    user.vipExp = msg.c.vipExp
    user.vipTime = msg.c.vipTime
    user.vipLastUpdateTime = os.time()
    user.vip_buys = msg.c.buy
    user.iget_free = msg.c.daily
end

function UserDataModel:updateOverLordDatas(msg)
    if msg.c and msg.c.uid then
        local overLordData = gameMap.overLordDatas[msg.c.uid]
        if overLordData then
            overLordData:update(msg.c)
        end
    end
    if msg.c.type == POINT_THRONE then
        local pUid = me.getFortIdByCoord(cc.p(msg.c.x, msg.c.y))
        local overLordData = gameMap.throneDatas[pUid]
        if overLordData then
            overLordData:update(msg.c)
        end
    end
end


function UserDataModel:newChatMail(msg)
    --    dump(msg)
end

function UserDataModel:initRuneInfo(msg)
    user.runeEquiped = { }
    local runeBaseCfg = cfg[CfgType.RUNE_DATA]
    if msg.c and msg.c.list then
        for k1, v1 in ipairs(msg.c.list) do
            local equip = { }
            for k, v in pairs(v1.list) do
                local rune = { }
                rune.id = v.id
                rune.cfgId = v.defId
                rune.glv = v.glv
                rune.aptPro = v.aptPro
                rune.apt = v.apt
                rune.star = v.star
                rune.index = v.index
                rune.fight = v.fight
                rune.lock = v.lock
                rune.plan = v.plan   --所属方案
                rune.awakeTimes = v.awakeTimes
                rune.runeSkillId = v.runeSkillId
                rune.nextRuneSkillId = v.nextRuneSkillId
                equip[rune.index] = rune
            end
            user.runeEquiped[k1] = equip
            user.runeEquipedRedpoint[k1] = v1.red
        end
        user.runeEquipIndex = msg.c.plan
    end
end

function UserDataModel:initRuneBackpack(msg)
    if msg.c and msg.c.list then
        for k, v in pairs(msg.c.list) do
            local rune = { }
            rune.id = v.id
            rune.cfgId = v.defId
            rune.glv = v.glv
            rune.aptPro = v.aptPro
            rune.apt = v.apt
            rune.star = v.star
            rune.index = v.index
            rune.fight = v.fight
            rune.lock = v.lock
            rune.awakeTimes = v.awakeTimes
            rune.runeSkillId = v.runeSkillId
            rune.nextRuneSkillId = v.nextRuneSkillId
            user.runeBackpack[v.id] = rune
        end
    end
end

function UserDataModel:updateRuneBackpack(msg)
    if msg.c then
        for k, v in pairs(msg.c.list) do
            local rune = { }
            rune.id = v.id
            rune.cfgId = v.defId
            rune.glv = v.glv
            rune.aptPro = v.aptPro
            rune.apt = v.apt
            rune.star = v.star
            rune.index = v.index
            rune.fight = v.fight
            rune.lock = v.lock
            rune.awakeTimes = v.awakeTimes
            rune.runeSkillId = v.runeSkillId
            rune.nextRuneSkillId = v.nextRuneSkillId
            if user.runeBackpack[v.id] == nil then
                rune.isnew = true
            end
            user.runeBackpack[v.id] = rune
        end
        if msg.c.process and tonumber(msg.c.process) == 11 then
            local shows = { }
            for key, var in pairs(msg.c.list) do
                var.cfgId = var.defId
                table.insert(shows, var)
            end
            getRuneAni(shows)
        end
    end
end

function UserDataModel:removeRuneBackpack(msg)
    if msg.c then
        for k, v in pairs(msg.c.ids) do
            user.runeBackpack[v] = nil
        end
    end
end

function UserDataModel:warshipDataInit(msg)
    local tableBaseShipCfg = cfg[CfgType.SHIP_DATA]
    local tableSkillShipCfg = cfg[CfgType.SHIP_SKILL]
    Warship_Tech()
    if msg.c then
        user.restoreResType = msg.c.resource
        for k, v in pairs(msg.c.list) do
            local shipData = { }
            shipData.type = v.type
            -- 战舰类型
            shipData.defId = v.defId
            -- 战舰配置表id
            -- 战舰状态：
            -- IN_ARMY（1）在军队中
            -- IN_CITY(2) 在城市中
            -- FREE(3) 空闲状态
            -- 4 航海状态
            shipData.status = v.staus
            shipData.nowExp = v.exp
            -- 战舰当前经验值
            shipData.nowFire = v.endure
            -- 战舰当前弹药值

            shipData.overfull = v.overfull

            local baseShipCfg = tableBaseShipCfg[v.defId]
            shipData.baseShipCfg = baseShipCfg

            if baseShipCfg.nextid and baseShipCfg.nextid ~= 0 then
                local nextShipCfg = tableBaseShipCfg[baseShipCfg.nextid]
                shipData.maxExp = nextShipCfg.exp
            end

            shipData.skills = { }
            for _k, _v in pairs(v.skills) do
                local skillShipCfg = tableSkillShipCfg[_v.defId]
                shipData.skills[skillShipCfg.order] = skillShipCfg
            end
            user.warshipData[v.type] = shipData

            for key, var in pairs(v.tech) do
                local warshipTech = cfg[CfgType.SHIP_TECH][var.defId]
                local pdata = WarshipTechData.new(warshipTech, var.exp)
                user.Warship_Tech[me.toNum(warshipTech.type)][me.toNum(warshipTech.order)] = pdata
            end
        end
    end
end

function UserDataModel:warshipDataUpdate(msg)
    local tableBaseShipCfg = cfg[CfgType.SHIP_DATA]
    local tableSkillShipCfg = cfg[CfgType.SHIP_SKILL]
    for k, v in pairs(user.warshipData) do
        if v.isNew == true then
            v.isNew = nil
        end
    end
    if msg.c then
        local shipData = { }
        shipData.type = msg.c.type
        shipData.defId = msg.c.defId
        shipData.status = msg.c.staus
        shipData.nowExp = msg.c.exp
        shipData.nowFire = msg.c.endure
        shipData.overfull = msg.c.overfull

        local baseShipCfg = tableBaseShipCfg[msg.c.defId]
        shipData.baseShipCfg = baseShipCfg

        if baseShipCfg.nextid and baseShipCfg.nextid ~= 0 then
            local nextShipCfg = tableBaseShipCfg[baseShipCfg.nextid]
            shipData.maxExp = nextShipCfg.exp
        end
        shipData.skills = { }
        for _k, _v in pairs(msg.c.skills) do
            local skillShipCfg = tableSkillShipCfg[_v.defId]
            shipData.skills[skillShipCfg.order] = skillShipCfg
        end
        if user.warshipData[msg.c.type] == nil then
            shipData.isNew = true
        end
        user.warshipData[msg.c.type] = shipData
    end
end
function UserDataModel:warshiptechupdata(msg)
    local defId = msg.c.defId
    local pType = msg.c.type
    local pexp = msg.c.exp
    local warshipTech = cfg[CfgType.SHIP_TECH][defId]
    local pdata = WarshipTechData.new(warshipTech, pexp)
    user.Warship_Tech[me.toNum(warshipTech.type)][me.toNum(warshipTech.order)] = pdata
end

function UserDataModel:shipSailInit(msg)
    user.shipSailData = { }
    user.shipSailData.taskTm = msg.c.tm
    user.shipSailData.taskMax = msg.c.max
    user.shipSailData.taskFs = msg.c.fs
    user.shipSailData.taskData = { }
    if msg.c and msg.c.list then
        for k, v in pairs(msg.c.list) do
            local taskId = v.id
            -- 远征任务id
            local shipId = v.sd
            -- 远征中的战舰id
            local taskStatus = v.st
            -- 任务状态 0未远征，1远征中，2可领取奖励
            local leftTime = math.floor(v.tm / 1000)
            -- 任务倒计时
            local taskData = { }
            taskData.taskId = taskId
            taskData.shipId = shipId
            taskData.taskStatus = taskStatus
            taskData.taskStatusOld = taskStatus
            taskData.leftTime = leftTime
            taskData.tprice = math.floor(math.floor(getXresPrice(1, leftTime) * leftTime) / 3)

            user.shipSailData.taskData[taskData.taskId] = taskData
        end
    end
    local function timerUpdateCallback(dt)
        local isTimeUpdate = false
        local isOver = false
        for k, v in pairs(user.shipSailData.taskData) do
            if v.taskStatus == 1 and v.leftTime > 0 then
                v.leftTime = v.leftTime - math.ceil(dt)
                v.tprice = math.floor(math.floor(getXresPrice(1, v.leftTime) * v.leftTime) / 3)
                isTimeUpdate = true
                if v.leftTime <= 0 then
                    isOver = true
                    v.taskStatusOld = v.taskStatus
                    v.taskStatus = 2
                end
            end
        end
        if isTimeUpdate == true then
            me.dispatchCustomEvent("leftTimeTick")
        end
        if isOver == true then
            me.dispatchCustomEvent("sailTimeOver")
        end
    end
    -- 注册定时器
    -- TODO:该类是单例，注册的定时器无需释放
    if self.mScheduler == nil then
        self.mScheduler = me.registTimer(-1, timerUpdateCallback, 1)
        -- self.mScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(timerUpdateCallback, 1, false)
    end
end

function UserDataModel:updateShipSailTask(msg)
    if msg.c then
        local taskId = msg.c.id
        -- 远征任务id
        -- 远征任务id
        local shipId = msg.c.sd
        -- 远征中的战舰id
        local taskStatus = msg.c.st
        -- 任务状态 0未远征，1远征中，2可领取奖励
        local leftTime = math.floor(msg.c.tm / 1000)
        -- 任务倒计时
        local taskData = { }
        taskData.taskId = taskId
        taskData.shipId = shipId
        taskData.taskStatus = taskStatus
        taskData.leftTime = leftTime
        taskData.tprice = math.floor(math.floor(getXresPrice(1, leftTime) * leftTime) / 3)
        if user.shipSailData.taskData[taskData.taskId] then
            taskData.taskStatusOld = user.shipSailData.taskData[taskData.taskId].taskStatus
        else
            taskData.taskStatusOld = taskStatus
        end
        user.shipSailData.taskData[taskData.taskId] = taskData
    end
end

function UserDataModel:shipSailTaskReward(msg)
    if msg.c then
        local taskId = msg.c.id
        -- 远征任务id
        user.shipSailData.taskData[taskId] = nil
    end
end

function UserDataModel:updateShipSailTimes(msg)
    if msg.c then
        user.shipSailData.taskTm = msg.c.tm
    end
end

function UserDataModel:updateRedpointData(msg)
    if msg.c then
        user.UI_REDPOINT.promotionBtn = { }
        user.UI_REDPOINT.payBtn = { }
        user.UI_REDPOINT.relicBtn = { }
        -- 天下大势、成长之路
        user.UI_REDPOINT.serverTaskBtn = { }
        user.UI_REDPOINT.Button_Shop = {}
        for id, v in pairs(msg.c) do
            if id == "11" or id == "45" then
                user.UI_REDPOINT.Button_Shop[id] = tonumber(v)
            elseif   id == "1" or   id == "4" or 
            id == "10" or
            id == "34" or
            id == "38" or
            id == "39" or
            id == "42" or
            id == "46" or
            id == "49" or
            id == "64" or
            id == "36"  then
                user.UI_REDPOINT.payBtn[id] = tonumber(v)
            elseif id == "999" then
                -- 圣物搜寻
                user.UI_REDPOINT.relicBtn[id] = tonumber(v)
            elseif id == "world_task_1" or id == "world_task_2" then
                user.UI_REDPOINT.serverTaskBtn[id] = tonumber(v)
            elseif id ~= 0 then
                user.UI_REDPOINT.promotionBtn[id] = tonumber(v)
            end
        end
        me.dispatchCustomEvent("UI_RED_POINT")
    end
end

-- -
-- 放逐成功
function UserDataModel:exileSucess(msg)
    if msg.c then
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_EXILE)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
    end
end

-- -
-- 被放逐成功
function UserDataModel:exilePromptBox(msg)
    if msg.c then
        local confirmView = cc.CSLoader:createNode("ExileRemovePrompt.csb")
        me.doLayout(confirmView, me.winSize)
        me.registGuiClickEventByName(confirmView, "btn1", function(node)
            if CUR_GAME_STATE == GAME_STATE_CITY then
                mainCity:cloudClose( function(node)
                    local loadlayer = loadingLayer:create("loadScene.csb")
                    me.runScene(loadlayer)
                end )
            else
                pWorldMap:cloudClose( function(node)
                    local loadlayer = loadingLayer:create("loadScene.csb")
                    me.runScene(loadlayer)
                end )
            end
            confirmView:removeFromParentAndCleanup(true)
        end )
        cc.Director:getInstance():getRunningScene():addChild(confirmView, MESSAGE_ORDER)
        me.showLayer(confirmView, "bg")
    end
end


-- -
-- 禁卫军巡逻状态
function UserDataModel:guardPatrolStatus(msg)
    user.guard_patrol_status = msg.c.status
    user.guard_patrol_army = msg.c.army

    -- 获取优先级  骑兵>步兵>弓兵>车兵
    local function getPriority(def)
        local p = 100
        if def.bigType == 2 then
            p = 1
        elseif def.bigType == 1 then
            p = 2
        elseif def.bigType == 3 then
            p = 3
        elseif def.bigType == 4 then
            p = 4
        end
        return p
    end
    table.sort(user.guard_patrol_army, function(a, b)
        local defA = cfg[CfgType.CFG_SOLDIER][a[1]]
        local defB = cfg[CfgType.CFG_SOLDIER][b[1]]
        local priorityA = getPriority(defA)
        local priorityB = getPriority(defB)
        if priorityA ~= priorityB then
            return priorityA < priorityB
        else
            return defA.id > defB.id
        end
    end)
    if CUR_GAME_STATE == GAME_STATE_CITY then
        local buildMoudle = mainCity.buildingMoudles[3008]
        if buildMoudle then
            buildMoudle:seeGain()
        end
    end
end

-- -
-- 禁卫军 抵御蛮族攻城状态
function UserDataModel:guardResistStatus(msg)
    user.guard_resist_status = msg.c.status
    if CUR_GAME_STATE == GAME_STATE_CITY then
        local buildMoudle = mainCity.buildingMoudles[3008]
        if buildMoudle then
            buildMoudle:seeGain()
        end
    end
end


UserModel = UserDataModel.getInstance()
