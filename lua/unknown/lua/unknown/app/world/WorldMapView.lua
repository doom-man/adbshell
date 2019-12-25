
-- 世界地图
WorldMapView = class("WorldMapView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        print(arg[1])
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
WorldMapView.__index = WorldMapView
function WorldMapView:create(...)
    local layer = WorldMapView.new(...)
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
cellSize = cc.size(247, 124)
function WorldMapView:ctor()
    print("WorldMapView ctor")
    mCloudAnimDone = false
    self.iNum = 0
    -- 图块集合
    self.cellMoudels = { }
    -- 主城.据点名字
    self.cellNameMoudels = { }
    self.bGoHome = false
    self.mapOptmenuView = nil
    self.troopsGroup = { }
    -- 是否是警告
    self.m_WarningPoint = nil
    self.queueNum = nil
    self.mapMoveDis = 0
    self.FortBool = false
    -- 请求自己的地图信息
    self.FortMapTime = nil
    self.myCityCellId = nil
    self.kenPoint = nil
    self.allianceInfor = false
    self.pTaskTime = nil
    -- 联盟
    self.allianceExitview = nil
    -- 联盟的任一界面
    self.lastShowPoint = nil
    self.mArmy = nil
    -- 出征的军队
    self.AidPoint = cc.p(0, 0)
    self.mPitchFortId = nil
    self.mFortHeroBool = true
    self.pfortGeneralView = nil
    self.ThroneStratAniBool = false
    self.mbossType = 0
    self.troopDataQueue = Queue.new()
end
-- [Comment]
-- 警示点
function WorldMapView:getWarningPoint()
    return self.m_WarningPoint
end
function WorldMapView:setWarningPoint(m_WarningPoint_)
    self.m_WarningPoint = m_WarningPoint_
end
-- -
-- 设置打开世界地图默认操作
--
function WorldMapView:setOpenOpt(cate)
    self.optCate = cate
end

TAG_GREEN_CURSOR = 0xffffff01
TAG_RED_CURSOR = 0xffffff02

STATE_AMICABLE = 1
STATE_HOSTILE = 2
WorldMapView.SignPoints = { }
function WorldMapView:init()
    print("WorldMapView init")

    -- 获取UserDefault中的数据
    local t = me.sysTime()
    self.Panel_Map = cc.Layer:create()
    self.touchLayer = cc.Layer:create()
    -- 单位层
    self.unitLayer = cc.Layer:create()

    self.unitfortLayer = cc.Layer:create()
    self.unitNameLayer = cc.Layer:create()
    self.mapBg = cc.Layer:create()
    self.cellSigns = { }
    self.markKing_signs = { }
    self.Panel_Map:setLocalZOrder(-1)
    self.Panel_Map:addChild(self.mapBg)
    self.queueNum = 0
    self.bathNode = cc.Node:create()
    self.troopLine_Node = me.assignWidget(self, "troopLine_Node")
    local mapname = "map.tmx"
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        mapname = "netbattle/netMap.tmx"
    end
    tmxMap = ccexp.TMXTiledMap:create(mapname)
    self.floor = tmxMap:getLayer("floor")
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        self.floor_water = tmxMap:getLayer("floor1")
        self.floor_water:setLocalZOrder(-11)
        self.floor_water:setVisible(false)
        local gaodi = tmxMap:getLayer("gaodi")
        local wujian = tmxMap:getLayer("wujian")
        local hill = tmxMap:getLayer("hill")
        local tree = tmxMap:getLayer("tree")
        gaodi:setLocalZOrder(-9)
        wujian:setLocalZOrder(-8)
        hill:setLocalZOrder(-7)
        tree:setLocalZOrder(-6)
        self.floor:setLocalZOrder(-10)
    end
    me.registGuiClickEventByName(self, "Image_army", function(node)
        NetMan:send(_MSG.armyinfo())
        me.setWidgetCanTouchDelay(node, 1)
    end )
    self.act_btn_firstpay = me.registGuiClickEventByName(self, "act_btn_firstpay", function(rev)
        local promotionView = promotionView:create("promotionView.csb")
        promotionView:setViewTypeID(1)
        promotionView:setTaskGuideIndex(1)
        self:addChild(promotionView, me.MAXZORDER)
        me.showLayer(promotionView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    self.act_btn_firstpay:setVisible(false)
    self.serverTaskBtn = me.registGuiClickEventByName(self, "serverTaskBtn", function(node)
        NetMan:send(_MSG.world_task_name_list())
        local servetask = serverTaskLayer:create("serverTask.csb")
        me.popLayer(servetask)
    end )
    -- map:setScale(0.1)
    self.Panel_Map:addChild(tmxMap)
    self.Panel_touchHeroSkill = me.assignWidget(self, "Panel_touchHeroSkill")
    self.Button_heroSkill = me.assignWidget(self, "Button_heroSkill")
    self.Panel_touchHeroSkill:setSwallowTouches(false)
    self.ui_bar = me.assignWidget(self, "ui_bar")
    self.gold_label = me.assignWidget(self, "gold")
    self.food_label = me.assignWidget(self, "food")
    self.lumber_label = me.assignWidget(self, "lumber")
    self.stone_label = me.assignWidget(self, "stone")
    self.diamond_label = me.assignWidget(self, "diamond")
    self.farmer_label = me.assignWidget(self, "farmer")
    self.paygem = me.assignWidget(self, "paygem")
    self.daodao_1 = me.assignWidget(self, "daodao_1")
    self.grade_label = me.assignWidget(self, "grade")
    self.vip_label = me.assignWidget(self, "vip")
    
    self.name_label = me.assignWidget(self, "uname")
    self.icon_gold = me.assignWidget(self, "icon_gold")
    self.idle_farmer_label = me.assignWidget(self, "idle_farmer_label")
    self.Text_idlefarmer = me.assignWidget(self, "idlefarmer")
    self.Text_crood = me.assignWidget(me.assignWidget(self, "homeBtn"), "coord")
    self.age = me.assignWidget(self, "age_icon")
    self.age:ignoreContentAdaptWithSize(true)
    self.Panel_miniMap = me.assignWidget(self, "Panel_miniMap")
    self.Image_selfNode = me.assignWidget(self, "Image_selfNode")
    self.level_label = me.assignWidget(self, "ulevel")
    --self.Text_chat = me.assignWidget(self, "Text_chat")
    self.Node_chat = me.assignWidget(self, "Node_chat")
    require("app/cityViewChatBox"):create(self, "Node_chat")

    self.localTime = me.assignWidget(self.Node_chat, "Text_chatTime")
    self.Panel_HongBao = me.assignWidget(self, "Panel_HongBao")
    self.Image_hongbao_bg = me.assignWidget(self, "Image_hongbao_bg")
    self.hongbao_btn = me.assignWidget(self, "hongbao_btn")
    self.Cross_throne = me.assignWidget(self, "Cross_throne")
    self.age_times = me.assignWidget(self, "age_times")
    me.Helper:grayImageView(me.assignWidget(self, "vipgray_bg"))
    self.Text_Troop_lines = me.assignWidget(self, "Text_Troop_lines")
    me.assignWidget(self, "Image_TroopLine_Bg"):setVisible(true)
    me.registGuiClickEvent(self.hongbao_btn, function(node)
        switchHongBaoAnim(self.Panel_HongBao, true)
        me.assignWidget(node, "hongbao_red_hint"):setVisible(false)
        self.hongbao_btn:setVisible(true)
        user.hongBao_State = 1
    end )
    self.hongbao_btn:setVisible(user.hongBao_openState == 1)
    me.registGuiClickEvent(me.assignWidget(self.Panel_HongBao, "Button_close"), function(node)
        user.hongBao_State = 0
        switchHongBaoAnim(self.Panel_HongBao, false)
    end )
    me.registGuiClickEvent(me.assignWidget(self.Panel_HongBao, "Button_send"), function(node)
        toRechageShop()
        switchHongBaoAnim(self.Panel_HongBao, false)
    end )
    me.registGuiClickEventByName(self, "uname", function(node)
        self.lordView = overlordView:create("overlordView.csb")
        self:addChild(self.lordView, me.MAXZORDER)
    end )
    me.registGuiTouchEventByName(self, "Cross_throne", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        NetMan:send(_MSG.Cross_Promotion_List())

    end )
    self.taskCaphterBtn = me.registGuiClickEventByName(self, "taskCaphterBtn", function(node)
        local caphter = taskCaphterLayer:create("Layer_TaskChapter.csb")
        me.popLayer(caphter)
    end )
    me.registGuiClickEventByName(self, "Image_TaskCaphter_process", function(node)
        if user.taskCaphterDataTitle.status == 2 then
            NetMan:send(_MSG.task_caphter_get_title())
            return
        end
        local data = getCurTaskCaphter()
        if data then
            if data.status == 1 then
                local taskdata = cfg[CfgType.CAPHTER_TASK][data.id]
                TaskHelper.taskCaphterJump(taskdata)
            elseif data.status == 2 then
                NetMan:send(_MSG.task_caphter_get_task(data.id))
            end
        end
    end )
    self.uiCommendTaskListener = me.RegistCustomEvent("UI_COMMEND_TASK", handler(self, self.showCommendTask))
    self.uiCompleteTaskListener = me.RegistCustomEvent("UI_TASK_COMPLETE", handler(self, self.TaskRewardsTask))
    self.relicBtn = me.registGuiClickEventByName(self, "relicBtn", function(node)
        local runeAltar = runeAltarView:create("rune/runeAltarView.csb", 1, 1)
        pWorldMap:addChild(runeAltar, me.MAXZORDER)
        me.showLayer(runeAltar, "bg")
    end )
    -- me.assignWidget(self,"icon_vip"):setVisible(false)
    --self.Text_chat:setVisible(false)
    me.assignWidget(self, "rechargeBtn"):setVisible(true)
    me.registGuiClickEventByName(self, "rechargeBtn", function(node)
        toRechageShop()
    end )
    me.registGuiClickEventByName(self, "chat_area", function(node)
        local chatView = weChatView:create("chatView.csb")
        me.runningScene():addChild(chatView, me.MAXZORDER);
        --me.showLayer(chatView, "bg_frame")
    end )
    me.assignWidget(self, "Image_miniMap"):setVisible(true)
    me.assignWidget(self, "Button_Troop"):setVisible(false)
    local allotBtn = me.assignWidget(self, "icon_farmer")
    allotBtn:setVisible(false)
    me.registGuiClickEventByName(self, "Button_achievement", function(node)
        SharedDataStorageHelper():setAchievementRedPoint(me.toStr(0))
        me.assignWidget(node, "hongbao_red_hint"):setVisible(false)
        NetMan:send(_MSG.achievenment_init())
    end )
    self.map_signBtn = me.registGuiClickEventByName(self, "map_signBtn", function(node)
        self:showSignLayer()
    end ):setVisible(true)
    -- self.map_signBtn:setPosition(self.Button_heroSkill:getPosition())
    -- self.Button_heroSkill:setPosition(allotBtn:getPosition())
    self.Button_warning = me.assignWidget(self, "Button_warning")
    self.Button_warning:setVisible(#user.warningList > 0)
    me.registGuiClickEvent(self.Button_warning, function(node)
        local warning = warningView:create("warningView.csb")
        warning:setInCityStatus(false)
        self:addChild(warning, me.MAXZORDER)
        me.showLayer(warning, "bg")
    end )
    local x = 0
    self.mCur = user.majorCityCrood
    self.cloudBool = true
    self.ealge = true
    self.pTime = me.registTimer(-1, function(dt)
        -- self:eagMode(self.mCur)
        if self.cloudBool == true then
            local pRand = me.rand()
            local pNum = self:getafterNum(pRand, 3)
            if pNum % 37 <= 5 then
                self:randCloud(self.mCur)
                self.cloudBool = false
            end
        end
        if self.ealge == true then
            self.ealge = false
            self:eagMode(self.mCur)
        end
    end , 60)
    self.payBtn = me.registGuiTouchEventByName(self, "payBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.promotionView = promotionView:create("paymentView.csb")
        self.promotionView:setViewTypeID(99)
        self:addChild(self.promotionView, me.MAXZORDER);
        me.showLayer(self.promotionView, "bg_frame")
    end )
    self.netbattleBtn_gift = me.registGuiClickEventByName(self, "netbattleBtn_gift", function(node)
        NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.countryRewardType, 1))
    end )
    self.netbattleBtn_rank = me.registGuiClickEventByName(self, "netbattleBtn_rank", function(node)
        NetMan:send(_MSG.rankList(rankView.NETBATTLE_PERSON))
    end )
    self.netbattleBtn_gift:setVisible(false)
    self.netbattleBtn_gift:setVisible(false)
    me.registGuiClickEvent(self.icon_gold, function(node)
        --- self.Panel_Map:setRotation3D(cc.vec3(345, 0, 0))

        --      x = x+ 10
        --    local action = CCOrbitCamera:create(0.5, 1, 0, 0, x, 0, 0)
        --    self.Panel_Map:runAction(action)
    end )
    me.assignWidget(self, "battleBtn"):setVisible(false)
    self.homeBtn = me.registGuiClickEventByName(self, "homeBtn", function(node)
        self:cloudClose( function(args)
            self:goCityView()
            me.setWidgetCanTouchDelay(node, 2)
        end )
    end ):setVisible(true)
    local btn_icon = me.assignWidget(self.homeBtn, "home_btn_icon")
    btn_icon:ignoreContentAdaptWithSize(true)
    if user.adornment == 0 then
        btn_icon:loadTexture(buildIcon(user.centerBuild:getDef()), me.localType)
    else
        local skindata = cfg[CfgType.SKIN_STRENGTHEN][tonumber(user.adornment)]
        btn_icon:loadTexture("cityskin" .. skindata.icon .. "_1.png", me.localType)
    end
    btn_icon:setScale(116 / btn_icon:getContentSize().width)
    local pAlliance = me.assignWidget(self, "guildBtn"):setVisible(true)
    me.registGuiTouchEventByName(self, "promotionBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.promotionView = promotionView:create("promotionView.csb")
        self.promotionView:setViewTypeID(1)
        self:addChild(self.promotionView, me.MAXZORDER);
        me.showLayer(self.promotionView, "bg_frame")
    end )
    --    pAlliance:setPosition(cc.p(pTask:getPositionX(),pTask:getPositionY()))
    -- 联盟
    me.registGuiTouchEventByName(self, "Button_Shop", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.promotionView = promotionView:create("paymentView.csb")
        self.promotionView:setViewTypeID(2)
        self:addChild(self.promotionView, me.MAXZORDER);
        me.showLayer(self.promotionView, "bg_frame")
    end )
    self.GuildBtn = me.assignWidget(self, "guildBtn")
    me.registGuiTouchEventByName(self, "guildBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        print("user.familyUid" .. user.familyUid)
        jumpToAlliancecreateView()
    end )
    -- 战力提升
    self.fapChangedListener = me.RegistCustomEvent("Fap_Changed", handler(self, self.fapChanged))
    local bmove = false
    local bclick = false
    -- self:lookMapAt(500,500)
    local function onTouchBegin(touch, event)
        if (#touch == 1) then
            self.touchBeinPos = touch[1]:getLocation()
            bmove = false
            bclick = true
        end
        if self.findRuneBoos ~= nil then
            self.findRuneBoos:setVisible(false)
        end
        -- 点击特效
        local cItem = cc.ParticleSystemQuad:create("click.plist")
        cItem:setPosition(self:convertToNodeSpace(touch[1]:getLocation()))
        self:addChild(cItem)
        local function arrive(node)
            node:removeFromParentAndCleanup(true)
        end
        local callback = cc.CallFunc:create(arrive)
        cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1), callback))
        return true;
    end
    local function onTouchMove(touch, event)
        if guideHelper.getGuideIndex() ~= guideHelper.guide_End and guideHelper.guideNeed == true then
            -- 如果在引导阶段，不能滑动地图
            return
        end
        if (#touch == 1) then
            local p1 = touch[1]:getLocation()
            self.mapMoveDis = cc.pDistanceSQ(p1, self.touchBeinPos)
            if self.mapMoveDis > 10 then
                bmove = true
            end
            local d = touch[1]:getDelta();
            local px, py = tmxMap:getPosition();
            if me.isInMap(tmxMap, cc.p(px + d.x, py + d.y)) then
                tmxMap:setPosition(cc.p(px + d.x, py + d.y));
                self:moveMiniMap(cc.p(d.x, d.y))
                self:scrollBg()
                self:showCompass()
                if self.mapOptmenuView and self.mapOptmenuView:isVisible()==true then
                    self.mapOptmenuView:move(d.x, d.y)
                end

            end
        end
        --
    end
    local function onTouchEnd(touch, event)
        if self.mapOptmenuView and self.mapOptmenuView:isVisible() == true then
            self.mapOptmenuView:hide()
        end

        if (#touch == 1 and not bmove and bclick) then
            local p1 = touch[1]:getLocation()
            local tiled_p = me.convertToTiledCoord(tmxMap, p1)
            local sp = me.convertToScreenCoord(tmxMap, tiled_p)
            if self.cursor then
                self.cursor:setPosition(sp)
            else
                self.cursor = ccui.ImageView:create("cursor_green.png")
                self.cursor:setPosition(sp)
                self.cursor:setLocalZOrder(-1)
                self.unitLayer:addChild(self.cursor)
                me.blink(self.cursor)
            end
            local cell = self.cellMoudels[me.getIdByCoord(tiled_p)]
            if cell then
                 print(cell:getLocalZOrder())
            end
            if bclick and mCloudAnimDone == true then
                if (guideHelper.guideIndex == guideHelper.guideConquest + 3) and(CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE) then
                    print("guideHelper.guideIndex == getFirstCell. !!")
                    local _, pos = pWorldMap:getFirstCell()
                    self:doClickEvent(pos)
                elseif (guideHelper.guideIndex == guideHelper.guideExplore + 2)
                    and CUR_GAME_STATE == GAME_STATE_WORLDMAP then
                    print("guideHelper.guideIndex == getEventCell. !!")
                    local _, pos = pWorldMap:getEventCell()
                    self:doClickEvent(pos)
                else
                    -- 要塞试炼排名数据
                    local celldata = pWorldMap:getCellDataByCrood(tiled_p)
                    if celldata then
                        local cellType = celldata.pointType
                        if cellType == POINT_FBASE or cellType == POINT_FORT then
                            local fdata = celldata:getFortData()
                            if fdata then
                                if fdata.famdata and me.toNum(fdata.famdata.mine) == 1 and fdata.start == 1 then
                                    self.m_cp = tiled_p
                                    local pPoint = me.getCoordByFortId(celldata["m_FortId"])
                                    NetMan:send(_MSG.worldfortherorankgeneral(pPoint))

                                else
                                    self:doClickEvent(tiled_p)
                                end
                            end
                        elseif cellType == POINT_THRONE or cellType == POINT_TBASE then
                            if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
                                self.m_cp = tiled_p
                                NetMan:send(_MSG.worldthronecreate())
                            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                                self:doClickEvent(tiled_p)
                            end
                        else
                            self:doClickEvent(tiled_p)
                        end
                    else
                        self:doClickEvent(tiled_p)
                    end
                end
                bclick = false
            end
        else
            if bmove then
                self:getScreenCenterCoord()
                -- self:updateTroopPath()
                if self.findRuneBoos ~= nil then
                    self.findRuneBoos:setVisible(true)
                    self.findRuneBoos:gotoFind()
                end
            end
        end
        local px, py = tmxMap:getPosition()



    end
    local listener = cc.EventListenerTouchAllAtOnce:create();
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCHES_BEGAN);
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCHES_MOVED);
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCHES_ENDED);
    self.unitLayer:addChild(self.bathNode, me.MAXZORDER - 1)
    self.touchLayer:setTouchEnabled(true);
    self.touchLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.touchLayer);
    self.touchLayer:setLocalZOrder(-1)
    self:addChild(self.touchLayer)
    self:addChild(self.Panel_Map)
    tmxMap:addChild(self.unitLayer)
    tmxMap:addChild(self.unitfortLayer)
    tmxMap:addChild(self.unitNameLayer)
    self:updateResUI()
    -- self:showIdleFarmerNumAction()
    print("WorldMapView init time = " ..(me.sysTime() - t))
    -- 邮件
    self.mailBtn = me.registGuiTouchEventByName(self, "mailBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.mailview = mailview:create("mailview.csb")
        self:addChild(self.mailview, me.MAXZORDER);
        me.showLayer(self.mailview, "bg_frame")
        me.assignWidget(self, "mail_red_hint"):setVisible(false)
        mMailRead = false
    end )
    -- 征服
    self.fortBtn = me.assignWidget(self, "fortBtn")
    self.fortBtnPoint = cc.p(self.GuildBtn:getPositionX(), self.GuildBtn:getPositionY())
    self.fortBtn:setVisible(true)

    me.registGuiTouchEventByName(self, "fortBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        me.assignWidget(self.fortBtn, "ArmatureNode_Panel"):setVisible(false)
        --        if user.stageX == -1 and user.stageY == -1 then
        --           showTips("修建驿站，开启本功能")
        --        else
        --        local fortlayer = fortWorld:create("fort/fortWorld.csb")
        --        self:addChild(fortlayer, me.MAXZORDER);
        --        me.showLayer(fortlayer, "fixLayout")
        --        end

        if self.FortBool == false then
            showWaitLayer()
            GMan():send(_MSG.fortressInit())
            self.mFortHeroBool = true
            self.FortBool = true
            self.FortMapTime = me.registTimer(-1, function(dt)
                self.FortBool = false
            end , 20)
        else
            self.fortlayer = fortWorld:create("fort/fortWorld.csb")
            self:addChild(self.fortlayer, me.MAXZORDER)
            me.showLayer(self.fortlayer, "fixLayout")
        end
    end )
    --    me.registGuiClickEventByName(self, "icon_vip", function(node)
    --        self:showVipView()
    --    end )
    --    me.registGuiClickEventByName(self, "icon_vipGray", function(node)
    --        self:showVipView()
    --    end )
    me.registGuiClickEventByName(self, "Image_vip_g", function(node)
        self:showVipView()
    end )
    -- 聊天按钮
    me.registGuiClickEventByName(self, "Button_weChat", function(node, event)
        local chatView = weChatView:create("chatView.csb")
        me.runningScene():addChild(chatView, me.MAXZORDER);
        --me.showLayer(chatView, "bg_frame")
    end )
    local function getRecourceView(typeKey_)
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(typeKey_)
        pWorldMap:addChild(tmpView, self:getLocalZOrder())
        me.showLayer(tmpView, "bg")
    end

    local Btn_food = me.assignWidget(self, "allotBtn_food")
    me.registGuiClickEvent(Btn_food, function(node)
        -- 粮食
        getRecourceView("food")
    end )

    local Btn_wood = me.assignWidget(self, "allotBtn_wood")
    me.registGuiClickEvent(Btn_wood, function(node)
        -- 木材
        getRecourceView("wood")
    end )

    local Btn_stone = me.assignWidget(self, "allotBtn_stone")
    me.registGuiClickEvent(Btn_stone, function(node)
        -- 石头
        getRecourceView("stone")
    end )

    local Btn_gold = me.assignWidget(self, "allotBtn_gold")
    me.registGuiClickEvent(Btn_gold, function(node)
        -- 金币
        getRecourceView("gold")
    end )
    me.registGuiClickEventByName(self, "allotBtn_paygem", function(node)


        toRechageShop()

    end )
    me.registGuiClickEventByName(self, "rechargeBtn_0", function(node)

        toExpchageShop()

    end )
    me.registGuiClickEventByName(self, "allotBtn_gem", function(node)
        toExpchageShop()
    end )
    -- 背包
    me.registGuiTouchEventByName(self, "bagBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.backpack = BackpackView:create("backpack/backpackdialog.csb")
        self:addChild(self.backpack, me.MAXZORDER);
        me.showLayer(self.backpack, "bg_frame")
    end )
    -- 任务
    self.taskBtn = me.registGuiTouchEventByName(self, "taskBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        if pWorldMap.taskview then
            pWorldMap.taskview:removeFromParent()
        end
        pWorldMap.taskview = TaskView:create("task/taskview.csb")
        self:addChild(pWorldMap.taskview, me.MAXZORDER);
        me.showLayer(pWorldMap.taskview, "bg_frame")
    end )
    self.Button_Arch = me.assignWidget(self, "Button_Arch")
    self.archBtnPoint = cc.p(self.Button_Arch:getPositionX(), self.Button_Arch:getPositionY())
    me.registGuiClickEventByName(self, "Button_Arch", function(node)
        me.assignWidget(self.Button_Arch, "ArmatureNode_Panel"):setVisible(false)
        self.archbool = false
        self.pBookMewnu = cfg[CfgType.BOOKMENU]
        self.BookMenuId = mAppBookMenuId
        NetMan:send(_MSG.initBook(self.BookMenuId))
        showWaitLayer(true)
    end )
    -- 领主信息
    me.registGuiTouchEventByName(self, "userInfoBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.lordView = overlordView:create("overlordView.csb")
        self:addChild(self.lordView, me.MAXZORDER)
    end )
    -- 排行榜
    me.registGuiTouchEventByName(self, "rank_Btn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        local building = user.building[4001]
        if building:getDef().level < 5 then
            showTips("城镇中心5级可查看排行榜")
            return
        end

        NetMan:send(_MSG.rankList(1))
        --  获取排行榜
        showWaitLayer()
    end )

    --    me.registGuiClickEvent(self.Cross_throne_out,function (node)
    --         me.showMessageDialog("是否退出跨服活动", function(args)
    --        if args == "ok" then
    --           GMan():send(_MSG.Cross_Sever_onExit())
    --        end
    --       end )
    --    end)
    me.assignWidget(self, "buildBtn"):setVisible(false)
    local node_X, node_Y = me.assignWidget(self, "Node_actBtn_1"):getPosition()
    local pRankBtn = me.assignWidget(self, "rank_Btn")
    local pRanking = user.newBtnIDs[me.toStr(OpenButtonID_Ranking)]
    if pRankBtn ~= nil then
        pRankBtn:setPosition(cc.p(node_X, node_Y))
    end
    pRankBtn:setVisible(pRanking ~= nil and CUR_GAME_STATE ~= GAME_STATE_WORLDMAP_NETBATTLE)
    pRankBtn:setVisible(false)
    local rune_Btn = me.assignWidget(self, "rune_Btn"):setVisible(true)
    me.registGuiTouchEventByName(self, "rune_Btn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self:FindRuneCreate()
        --
        --  NetMan:send(_MSG.Rune_find_guard(1))
        --  showWaitLayer()

    end )
    rune_Btn:setVisible(pRanking ~= nil and CUR_GAME_STATE ~= GAME_STATE_WORLDMAP_NETBATTLE)
    -- 外城只有排行榜
    --  me.assignWidget(self,"Button_Arch"):setVisible(false)

    local function act_callback(node)
        local id = node.idx
        -- 跨服争霸
        if id == 65 then
            local view = PvpMainView:create("pvp/PvpMainView.csb")
            me.popLayer(view)
        else
            local promotionView = promotionView:create("promotionView.csb")
            promotionView:setViewTypeID(1)
            promotionView:setTaskGuideIndex(id)
            me.runningScene():addChild(promotionView, me.MAXZORDER)
            me.showLayer(promotionView, "bg_frame")
        end
    end
    for key, var in pairs(act_btn_list) do
        local btn = me.registGuiClickEventByName(self, "act_btn_" .. var, act_callback)
        btn.idx = var
    end
    self.majorCityScreenPoint = me.convertToScreenCoord(tmxMap, user.majorCityCrood)
    self:initScrollBg()
    mTroopLineData = { }
    self:setDownTime()
    self:setMailTask()
    self:archHint()
    self:setAllianceHint()
    self:initBattleAni()
    InforBtn(self, 2)
    if mMailRead then
        me.assignWidget(self, "mail_red_hint"):setVisible(true)
    end
    me.assignWidget(self, "icon_protected"):setVisible(false)
    -- 不显示跨服
    -- self:worldCrossOpen()

    -- 移动地图显示指针
    self.worldCompass = me.assignWidget(self, "worldCompass")
    self.compassIco = me.assignWidget(self.worldCompass, "compassIco")
    self.compassTxt = me.assignWidget(self.worldCompass, "disTxt")
    me.registGuiClickEvent(self.compassIco, function()
        self:lookMapAt(user.majorCityCrood.x, user.majorCityCrood.y)
        self.worldCompass:setVisible(false)
    end)

    -- 考古道具小红点
    self.img_red_dot_equip = me.assignWidget(self, "img_red_dot_equip")
    self.img_red_dot_equip:setVisible(false)
    self:calArchEquipHeroRedDot()

    return true
end

-- 计算考古道具小红点
function WorldMapView:calArchEquipHeroRedDot()
    local map_equip = {
        [1] = 6,      -- 头盔
        [2] = 7,      -- 衣服
        [3] = 8,      -- 盾牌
        [4] = 5,      -- 武器
        [5] = 9,      -- 戒指
    }
    -- 找出已穿戴的装备
    local equipList = {}
    for k, v in pairs(user.bookEquip) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == 6 or tonumber(cfg_item.useType) == 7 or tonumber(cfg_item.useType) == 8
            or tonumber(cfg_item.useType) == 5 or tonumber(cfg_item.useType) == 9 then
            equipList[tonumber(cfg_item.useType)] = true
        end
    end
    local show_equip = false
    for i, v in ipairs(map_equip) do
        -- 空位
        if not equipList[v] then
            for k_, v_ in pairs(user.bookPkg) do
                local cfg_item = cfg[CfgType.ETC][v_.defid]
                if tonumber(cfg_item.useType) == v then
                    show_equip = true
                    break
                end
            end
        end
        if show_equip then
            break
        end
    end
    --========================================
    local map_hero = {
        [1] = 10,      -- 英雄
        [2] = 10,      -- 英雄
        [3] = 10,      -- 英雄
        [4] = 10,      -- 英雄
        [5] = 10,      -- 英雄
    }
    local heroList = {}
    for k, v in pairs(user.bookEquip) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == 10 and v.equipLoc > 0 then
            heroList[tonumber(v.equipLoc)] = true
        end
    end
    local show_hero = false
    for i, v in ipairs(map_hero) do
        -- 空位
        if not heroList[i] then
            for k_, v_ in pairs(user.bookPkg) do
                local cfg_item = cfg[CfgType.ETC][v_.defid]
                if tonumber(cfg_item.useType) == v then
                    show_hero = true
                    break
                end
            end
        end
        if show_hero then
            break
        end
    end
    self.img_red_dot_equip:setVisible(show_equip or show_hero)
end

function WorldMapView:setTaskData(pData)
    self.mTaskData = pData
end
function WorldMapView:updateActBtnTimes(dt)
    for key, var in pairs(act_btn_list) do
        if user.activity_buttons_show[var] then
            if user.activity_buttons_show[var].countdown > 0 then
                local di = me.assignWidget(me.assignWidget(self, "act_btn_" .. var), "time_di")
                di:setVisible(true)
                me.assignWidget(di, "Text_Act_time"):setString(me.formartSecTimeHour(user.activity_buttons_show[var].countdown))
                user.activity_buttons_show[var].countdown = user.activity_buttons_show[var].countdown - dt
            end
        end
    end
end
function WorldMapView:setTaskHint()
    local pNum = 0
    for key, var in pairs(user.taskList) do
        if var["progress"] == 3 then
            pNum = pNum + 1
        end
    end
    local rlevel = 3
    if getCenterBuildingLevel() < rlevel then
        me.assignWidget(self, "task_hint_bg"):setVisible(false)
    else
        me.assignWidget(self, "task_hint_bg"):setVisible(true)
    end
    if pNum > 0 then
        me.assignWidget(self, "task_hint_bg"):setVisible(true)
        me.assignWidget(self, "task_Hint_num"):setString(pNum)
        me.assignWidget(self, "ArmatureNode_task"):setVisible(true)
    else
        me.assignWidget(self, "task_hint_bg"):setVisible(false)
        me.assignWidget(self, "ArmatureNode_task"):setVisible(false)
    end
    if getCenterBuildingLevel() < rlevel then
        me.assignWidget(self, "ArmatureNode_task"):setVisible(true)
    end
end
function WorldMapView:jumpToPromotion(index)
    self.promotionView = promotionView:create("promotionView.csb")
    self.promotionView:setTaskGuideIndex(index)
    self:addChild(self.promotionView, me.MAXZORDER);
    me.showLayer(self.promotionView, "bg_frame")
end
function WorldMapView:showCompass()
    local wpos = tmxMap:convertToWorldSpace(self.mainCtiyPos)
    if wpos.x + 124 < 0 or wpos.y + 170 < 54 or wpos.x - 150 > me.winSize.width or wpos.y - 70 > me.winSize.height - 54 then
        local cur = me.getScreenCenterTileCrood(tmxMap)
        local dis = cc.pGetDistance(cur, user.majorCityCrood)

        local targetPos = me.convertToScreenCoord(tmxMap, user.majorCityCrood)
        local startPos = me.convertToScreenCoord(tmxMap, cur)
        -- local degree = me.getAngle(targetPos, startPos)

        local flagX = targetPos.x - startPos.x
        local flagY = targetPos.y - startPos.y
        local degree = math.deg(math.atan2(flagX, flagY))

        self.worldCompass:setVisible(true)
        self.compassIco:setRotation(degree)
        dis = math.floor(dis)
        self.compassTxt:setString("距离" .. dis)
    else
        self.worldCompass:setVisible(false)
    end
end

function WorldMapView:UpButtonPosition()
    me.assignWidget(self, "promotionBtn"):setVisible(false)
    me.assignWidget(self, "rank_Btn"):setVisible(false)
    me.assignWidget(self, "noticeBtn"):setVisible(false)
    me.assignWidget(self, "payBtn"):setVisible(false)
    me.assignWidget(self, "popularize_Btn"):setVisible(false)
    me.assignWidget(self, "Button_achievement"):setVisible(false)
    local nodeBtn = { }
    local showbtn = guideHelper.getGuideIndex() > 23
    for var = 1, 11 do
        nodeBtn[#nodeBtn + 1] = { x = me.assignWidget(self, "Node_actBtn_" .. var):getPositionX(), y = me.assignWidget(self, "Node_actBtn_" .. var):getPositionY() }
    end
    local btnIndex = 1
    local function setBtnLive(btnStr)
        local tmpBtn = me.assignWidget(self, btnStr)
        local tmpPos = nodeBtn[btnIndex]
        if tmpPos then
            tmpBtn:setPosition(cc.p(tmpPos.x, tmpPos.y))
            tmpBtn:setVisible(showbtn)
            btnIndex = btnIndex + 1
        end
    end
    local function addJustBtn(btnStr)
        local tmpBtn = me.assignWidget(self, btnStr)
        local tmpPos = nodeBtn[btnIndex]
        if tmpPos == nil then return end
        tmpBtn:setPosition(cc.p(tmpPos.x, tmpPos.y))
        btnIndex = btnIndex + 1
    end
    if user.newBtnIDs[me.toStr(OpenButtonID_Pay)] ~= nil then
        setBtnLive("payBtn")
    end
    if user.newBtnIDs[me.toStr(OpenButtonID_Activity)] ~= nil and nodeBtn[btnIndex] ~= nil then
        setBtnLive("promotionBtn")
    end
    if user.newBtnIDs[me.toStr(OpenButtonID_Ranking)] ~= nil and nodeBtn[btnIndex] ~= nil then
        setBtnLive("rank_Btn")
    end
    --    if user.newBtnIDs[me.toStr(OpenButtonID_Share)] ~= nil and nodeBtn[btnIndex] ~= nil then
    --        setBtnLive("popularize_Btn")
    --    end
    if nodeBtn[btnIndex] ~= nil then
        setBtnLive("Button_achievement")
    end
    setBtnLive("serverTaskBtn")
    if self.hongbao_btn:isVisible() then
        addJustBtn("hongbao_btn")
    end
    for key, var in pairs(act_btn_list) do
        me.assignWidget(self, "act_btn_" .. var):setVisible(false)
        if user.activity_buttons_show[var] then
            setBtnLive("act_btn_" .. var)
        end
    end
    if user.Cross_Sever_Status == mCross_Sever then
        addJustBtn("netbattleBtn_gift")
        addJustBtn("netbattleBtn_rank")
        self.netbattleBtn_gift:setVisible(true)
        self.netbattleBtn_rank:setVisible(true)
    else
        self.netbattleBtn_gift:setVisible(false)
        self.netbattleBtn_rank:setVisible(false)
    end
    self.act_btn_firstpay:setVisible(false)
    self.Button_heroSkill:setVisible(user.heroSkillStatus == true or user.heroSkillStatus == 1)
end
function WorldMapView:worldCrossOpen()
    me.clearTimer(self.OpenThron)
    if user.OpenCrossThroneTime and user.OpenCrossThroneTime.OpenThrone == 1 then
        self.Cross_throne:setVisible(true)
        local pOpen = ""
        local pEnd = ""
        if user.OpenCrossThroneTime.Data[1].status == 1 then
            pOpen = "开启:"
            pEnd = "结束了"

        else
            pOpen = "结束:"
            pEnd = "开启中"

        end
        self.OpenThron = me.registTimer(-1, function(dt)
            if user.OpenCrossThroneTime.Data[1].Time > 0 then
                user.OpenCrossThroneTime.Data[1].Time = user.OpenCrossThroneTime.Data[1].Time - 1
                me.assignWidget(self.Cross_throne, "Text_time"):setString(pOpen .. me.formartSecTime(user.OpenCrossThroneTime.Data[1].Time)):setVisible(true)
            else
                me.assignWidget(self.Cross_throne, "Text_time"):setString(pEnd)
                me.clearTimer(self.OpenThron)
                self.OpenThron = nil
            end
        end , 1)
    else
        self.Cross_throne:setVisible(false)
    end
end
function WorldMapView:initAchievenmentView()
    if self.av == nil then
        self.av = achievementView:create("achievementView.csb")
        self:addChild(self.av, me.MAXZORDER)
        me.showLayer(self.av, "bg")
    end
end
function WorldMapView:archHint()
    local pBool = false
    for key, var in pairs(user.bookHand) do
        local pData = mBookAltasNum[var]
        for key, var in pairs(pData) do
            if var["num"] > 0 then
                local pConfig = cfg[CfgType.ETC][var["id"]]
                if var["num"] < pConfig["maxPile"] then
                    pBool = true
                    break
                end
            end
        end
    end
    if pBool then
        me.assignWidget(self, "arch_hint"):setVisible(true)
    else
        me.assignWidget(self, "arch_hint"):setVisible(false)
    end
end
function WorldMapView:initScrollBg()
    for var = 1, 9 do
        local img_ = cc.Sprite:create("map_bg.png")
        img_:getTexture():setAliasTexParameters()
        img_:setTag(var * 1000)
        self.mapBg:addChild(img_)
    end
end
function WorldMapView:getCellZOrder(tp)
    
    local sprite = self.floor:getTileAt(tp)
    if sprite then
        print(tp.x,tp.y,sprite:getLocalZOrder())
        return sprite:getLocalZOrder()
    end
    return 1
end
function WorldMapView:scrollBg()
    local x, y = tmxMap:getPosition()
    local w = 2700
    local h = 2700
    local ofx = me.mod(x, w)
    local ofy = me.mod(y, h)
    for var = 0, 8 do
        local img = self.mapBg:getChildByTag((var + 1) * 1000)
        img:setPositionX(ofx + w / 2 +(var % 3) * w)
        img:setPositionY(ofy + h / 2 + math.floor(var / 3) * h)
    end
end
function WorldMapView:getFirstCell()
    local tag = cc.p(user.majorCityCrood.x + 1, user.majorCityCrood.y)
    local cell = me.getTiledByTileCoord(tmxMap, tag)
    self:LookMapAtSing(tag.x, tag.y)
    return cell, tag
end
function WorldMapView:getEventCell()
    for key, var in pairs(gameMap.mapCellDatas) do
        local tmpCell = var
        if tmpCell.ownerId and tmpCell:bHaveEvent() and me.toNum(tmpCell.ownerId) == me.toNum(user.uid) then
            local tag = tmpCell.crood
            self:LookMapAtSing(tag.x, tag.y)
            local cell = mapObjFactroy:createMapObj(var)
            local sp = me.convertToScreenCoord(tmxMap, cc.p(tag.x, tag.y))
            cell:setVisible(false)
            cell:setPos(sp)
            self.unitLayer:addChild(cell, self:getCellZOrder(var.crood))
            return cell, tag
        end
    end
    print("WorldMapView:getEventCell !!! stack  error !")
    return nil
end
function WorldMapView:doClickEvent(cp, pBool)
    -- 检测是否点击了自己的主城
    if pBool == nil then
        if self.lastCp == cp then
            return
        end
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch or  guideHelper.guideIndex == guideHelper.guideGoToArch  + 1 or guideHelper.guideIndex == guideHelper.guideGoToArch + 2 then 
         --考古引导不允许点击地面
         return 
    end
    self.lastCp = cp
    local bmycity = false
    local data = self:getCellDataByCrood(cp)
    if data and data.occState == OCC_STATE_OWN and(data.pointType == POINT_CITY or data.pointType == POINT_CBASE) then
        --  self:goCityView()
        --  self.disLoadNode:setVisible(true)
        bmycity = true
    end
    if self.mapOptmenuView == nil then
        self.mapOptmenuView = mapOptMenuLayer:create("mapOptMenuLayer.csb")
        self:addChild(self.mapOptmenuView, me.MAXZORDER)
    else
        self.mapOptmenuView:setVisible(true)
    end


    print("doClickEvent")
    local sp = me.convertToScreenCoord(tmxMap, cp)
    local screenPos = cc.pAdd(sp, cc.p(tmxMap:getPosition()))
    self.mapOptmenuView:setPosition(screenPos.x-me.winSize.width/2, screenPos.y-me.winSize.height/2)

    self.mapOptmenuView:initOptMenu(cp)
    self.mapOptmenuView:initStationInfo()
    self.mapOptmenuView:adjust(sp)


    if pBool then
        self.mapOptmenuView:initFortHeroRank(sp)
    end
end
function WorldMapView:openAllianceViewAgain()
    if self.allianceview then
        if self.allianceview.close then
            self.allianceview:close()
        end
    end
    jumpToAlliancecreateView()
end
function WorldMapView:pointHasTroop(cp)
    local id = me.getIdByCoord(cp)
    local obj = self.cellMoudels[id]
    if obj then
        if obj:getTroopId() then

        end
    end
    return false
end
function WorldMapView:hideRoadDisTips()
    if self.disLoadNode then
        -- self.disLoadNode:setVisible(false)
    end
end
function WorldMapView:setWorldArmy(pData, pType, bossType)
    self.mArmy = pData
    self.mStartType = pType
    self.mbossType = bossType
end
-- 显示出征界面
function WorldMapView:showExped(msg)
    -- rev msg:{"t":1562,"c":{"ox":18,"oy":177,state,"x":18,"y":298,"list":[{"x":22,"y":198},{"x":49,"y":249},{"x":49,"y":299},{"x":18,"y":298}]}}

    if self.buildTrade and self.buildTrade.close then
        self.buildTrade:close()
    end
    if self.fort and self.fort.close then
        self.fort:close()
    end

    local ori = cc.p(msg.c.ox, msg.c.oy)
    local tag = cc.p(msg.c.x, msg.c.y)
    local list = msg.c.list
    local path = { }

    path.ori = ori
    path.tag = tag
    path.list = list
    if self.exped == nil then
        self.exped = expedLayer:create("expeditionLayer.csb")
        self.exped:setExpedState(msg.c.status)
        self.exped:setQueueNum(self.queueNum)
        self.exped:setPaths(path)

        local cellData = gameMap.mapCellDatas[me.getIdByCoord(tag)]
        -- 新增随机事情（宝箱）消耗体力
        local randEvent = nil
        if cellData then
            randEvent = cellData:getEventDef()

            if randEvent and(randEvent.type == 5 or randEvent.type == 6) then
                self.exped:setBoosType("randevent")
            else
                local bossdata = cellData:getBossData()
                if bossdata then
                    local bossDef = bossdata:getDef()
                    if me.toNum(bossDef.icon) == 84 then
                        self.exped:setBoosType("bigdragon")
                    elseif me.toNum(bossDef.icon) == 83 then
                        self.exped:setBoosType("smalldragon")
                    else
                        self.exped:setBoosType(self.mbossType)
                    end
                else
                    self.exped:setBoosType(self.mbossType)
                end
            end
        end

        self.exped:setNpc(msg.c.npc, msg.c.show)
        self.exped:setStar(self.mArmy)
        pWorldMap:addChild(self.exped, me.MAXZORDER + 10)
    end
end
-- 显示出征界面
function WorldMapView:showMobilize(ori, tag, status, pArmy, pStronghold, npc, pStronghold_other)
    -- rev msg:{"t":1562,"c":{"ox":18,"oy":177,state,"x":18,"y":298,"list":[{"x":22,"y":198},{"x":49,"y":249},{"x":49,"y":299},{"x":18,"y":298}]}}
    if self.buildTrade and self.buildTrade.close then
        self.buildTrade:close()
    end
    if self.fort and self.fort.close then
        self.fort:close()
    end

    local path = { }
    path.ori = ori
    path.tag = tag
    self.exped = expedLayer:create("expeditionLayer.csb")
    self.exped:setExpedState(status)
    self.exped:setStrongholdData(pStronghold, pStronghold_other)
    self.exped:setQueueNum(self.queueNum)
    self.exped:setPaths(path)
    self.exped:setNpc(npc)
    self.exped:setStartType(self.mStartType)
    self.exped:setStar(pArmy)
    pWorldMap:addChild(self.exped, me.MAXZORDER)
end
-- 显示出征界面 集火
function WorldMapView:showconverge(ori, tag, status, waitTime, teamId)
    -- rev msg:{"t":1562,"c":{"ox":18,"oy":177,state,"x":18,"y":298,"list":[{"x":22,"y":198},{"x":49,"y":249},{"x":49,"y":299},{"x":18,"y":298}]}}
    user.needaskBattle = false
    -- 不显示伤兵
    if self.buildTrade and self.buildTrade.close then
        self.buildTrade:close()
    end
    if self.fort and self.fort.close then
        self.fort:close()
    end

    local path = { }
    path.ori = ori
    path.tag = tag
    self.exped = expedLayer:create("expeditionLayer.csb")
    self.exped:setExpedState(status)
    self.exped:setQueueNum(self.queueNum)
    self.exped:setPaths(path)
    self.exped:setNpc(0)
    self.exped:setConver(waitTime, teamId)
    self.exped:setStar(user.soldierData)

    local cellData = gameMap.mapCellDatas[me.getIdByCoord(tag)]
    local bossdata = cellData:getBossData()
    if bossdata then
        local bossDef = bossdata:getDef()
        if me.toNum(bossDef.icon) == 84 then
            self.exped:setBoosType("bigdragon")
        elseif me.toNum(bossDef.icon) == 83 then
            self.exped:setBoosType("smalldragon")
        end
    end

    pWorldMap:addChild(self.exped, me.MAXZORDER)
end
-- 国王目标线条
function WorldMapView:doExped_KingTarget()
    --    if self.troop_KingTarget ~= nil then
    --        self.troop_KingTarget:purge()
    --    end
    --    self.troop_KingTarget = troopMartix:create("troopsLayer.csb")
    --    self.troop_KingTarget:initTroops_KingTarget()
    --    self.unitfortLayer:addChild(self.troop_KingTarget, me.MAXZORDER)
end
-- 派兵出征
function WorldMapView:doExped(msg)
    --    dump(msg)
    local status = msg.c.status
    local troopid = msg.c.id
    local troop = self.troopsGroup[troopid]
    if troop and troop.moveOnPaths then
        --  troop:moveOnPaths(gameMap.troopData[troopid])
    else
        --  self.troopsGroup[troopid] = troopMartix:create("troopsLayer.csb")
        --  self.troopsGroup[troopid]:initTroops(gameMap.troopData[troopid])
        --  self.unitfortLayer:addChild(self.troopsGroup[troopid], me.MAXZORDER)

        Queue.push(self.troopDataQueue, troopid)
    end
end
function WorldMapView:checkTroop()
    self.troopTimer = me.registTimer(-1, function(dt)
        if not Queue.isEmpty(self.troopDataQueue) then
            local troopid = Queue.pop(self.troopDataQueue)
            local troop = self.troopsGroup[troopid]
            if troop and troop.moveOnPaths then
                -- troop:moveOnPaths(gameMap.troopData[troopid])
            else
                self.troopsGroup[troopid] = troopMartix:create("troopsLayer.csb")
                self.troopsGroup[troopid]:initTroops(gameMap.troopData[troopid])
                self.unitfortLayer:addChild(self.troopsGroup[troopid], me.MAXZORDER)
            end
        end
    end , 0.2)
end
function WorldMapView:revExpedMsg(msg)
    local tdata = gameMap.troopData[msg.c.id]
    local landKey = me.getIdByCoord(tdata:getOriPoint())
    if tdata:getStatus() == EXPED_STATE_STATIONED or tdata:getStatus() == TEAM_ARMY_DEFENS_WAIT or tdata:getStatus() == EXPED_STATE_COLLECTING or tdata:getStatus() == EXPED_STATE_ARCHING or tdata:getStatus() == THRONE_DEFEND then
        self:doEvent(tdata)
    else
        self:doExped(msg)
    end
end
function WorldMapView:doEvent(tdata)
    local cid = me.getIdByCoord(tdata:getOriPoint())
    local cell = self.cellMoudels[cid]
    if cell and cell.updateEventState then
        cell:updateEventState()
    end
end
function WorldMapView:initBattleAni()
    self.battleAnis = Queue.new()
    local function aniEnd(node)
        node:setVisible(false)
        Queue.push(self.battleAnis, node)
    end
    for var = 1, 20 do
        local ani = battleAni:create("battle_fight")
        ani:setVisible(false)
        ani:registLisenter(aniEnd)
        Queue.push(self.battleAnis, ani)
        self.unitfortLayer:addChild(ani, me.MAXZORDER)
    end
end
function WorldMapView:showBattleAni(msg)
    --    local troop = self.troopsGroup[msg.c.id]
    --    if troop and troop.removeFromParent then
    --        troop:removeFromParentAndCleanup(true)
    --        self.troopsGroup[msg.c.id] = nil
    --    end
    -- todo 播放战斗ANI
    local tag = cc.p(msg.c.x, msg.c.y)
    local ctag = me.convertToScreenCoord(tmxMap, tag)
    if not Queue.isEmpty(self.battleAnis) then
        local ani = Queue.pop(self.battleAnis)
        ani:setPosition(ctag)
        ani:setVisible(true)
        ani:playAni()
    end
end
-- @迁城目标点
function WorldMapView:showFortView(tag)

    self.fort = fortLayer:create("rmLayer.csb")
    self.fort:initState(tag)
    self:addChild(self.fort, me.MAXZORDER)
    me.showLayer(self.fort, "bg")

end
function WorldMapView:goCityView()
    self.bGoHome = true
    local load_ = loadingLayer:create("loadScene.csb", false)
    me.runScene(load_)
end
function WorldMapView:initCellSign()
    if WorldMapView.SignPoints then
        for key, var in pairs(WorldMapView.SignPoints) do
            if var then
                self.cellSigns[key] = ccui.ImageView:create("waicheng_tubiao_dingwei_wai.png")
                local sp = me.convertToScreenCoord(tmxMap, me.converCoordbyId(key))
                self.cellSigns[key]:setPosition(cc.p(sp.x + 50, sp.y))
                -- me.CCOrbitCamera(self.cellSigns[key])
                self.unitLayer:addChild(self.cellSigns[key], me.MAXZORDER)
            end
        end
    end
    for key, var in pairs(user.markKingPos) do
        if var then
            self.markKing_signs[key] = ccui.ImageView:create("waicheng_tubiao_qizhi.png")
            local sp = me.convertToScreenCoord(tmxMap, me.converCoordbyId(key))
            self.markKing_signs[key]:setPosition(cc.p(sp.x + 30, sp.y))
            self.unitLayer:addChild(self.markKing_signs[key], me.MAXZORDER)
        end
    end
end
-- 选中地图的点加入到table中
function WorldMapView:setMapPoint(mMapX, mMapY, name)
    if mMapTablepoint ~= nil then
        local pTabPoint = { }
        pTabPoint.X = mMapX
        pTabPoint.Y = mMapY
        pTabPoint.name = name
        pTabPoint.types = 1
        table.insert(mMapTablepoint, pTabPoint)
        local id = me.getIdByCoord(cc.p(mMapX, mMapY))
        SharedDataStorageHelper():setMapPoint(user.uid)
        self.cellSigns[id] = ccui.ImageView:create("waicheng_tubiao_dingwei_wai.png")
        local sp = me.convertToScreenCoord(tmxMap, cc.p(mMapX, mMapY))
        self.cellSigns[id]:setPosition(cc.p(sp.x + 50, sp.y))
        --  me.CCOrbitCamera(self.cellSigns[id])
        self.unitLayer:addChild(self.cellSigns[id], me.MAXZORDER)
        -- 写入UserDefault中的数据
        -- end
    end
    WorldMapView.SignPoints[me.getIdByCoord(cc.p(mMapX, mMapY))] = true
end
function WorldMapView:removeMapPoint(cp)
    if mMapTablepoint then
        for key, var in pairs(mMapTablepoint) do
            if var.types ~= POINT_STRONG_HOLD then
                if me.toNum(cp.x) == me.toNum(var.X) and me.toNum(cp.y) == me.toNum(var.Y) then
                    table.remove(mMapTablepoint, key)
                    local id = me.getIdByCoord(cc.p(var.X, var.Y))
                    WorldMapView.SignPoints[id] = false
                    if self.cellSigns[id] then
                        self.cellSigns[id]:removeFromParentAndCleanup(true)
                        self.cellSigns[id] = nil
                    end
                    break
                end
            end

        end
    end
    --    dump(mMapTablepoint)
    SharedDataStorageHelper():setMapPoint(user.uid)
end
function WorldMapView:getScreenCenterCoord()
    local cur = me.getScreenCenterTileCrood(tmxMap)
    user.curMapCrood = cur
    self.mCur = cur
    self:updateCroodText()
    if self.delaySend then
        self:stopAction(self.delaySend)
    end
    local a1 = cc.DelayTime:create(0.8)
    local a2 = cc.CallFunc:create( function(a)
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
            if self.lookMapJumpFrom == "searchBoss" then
                self.lookMapJumpFrom = ""
                NetMan:send(_MSG.worldMapView(cur.x, cur.y, mFirstWorld, 1))
            else
                NetMan:send(_MSG.worldMapView(cur.x, cur.y, mFirstWorld))
            end
            self:firstWorld()
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            netBattleMan:send(_MSG.worldMapView(cur.x, cur.y, mFirstWorld))
            self:firstWorld()
        end
    end )
    self.delaySend = cc.Sequence:create(a1, a2)
    self:runAction(self.delaySend)
end
function WorldMapView:firstWorld()
    if mFirstWorld == 0 then
        mFirstWorld = 1
    end
end
function WorldMapView:showIdleFarmerNumAction()
    self.idle_farmer_label:runAction(cc.FadeOut:create(0))
    local a1 = cc.FadeIn:create(0.5)
    local a2 = cc.DelayTime:create(5)
    local a3 = cc.FadeOut:create(0.5)
    local a4 = cc.DelayTime:create(5)

    local seq1 = cc.Sequence:create(a1, a2, a3, a4)
    local rept = cc.RepeatForever:create(seq1)
    self.farmer_label:runAction(rept)
    local b1 = cc.DelayTime:create(5)
    local b2 = cc.FadeIn:create(0.5)
    local b3 = cc.DelayTime:create(5)
    local b4 = cc.FadeOut:create(0.5)

    local seq2 = cc.Sequence:create(b1, b2, b3, b4)
    local rept1 = cc.RepeatForever:create(seq2)
    self.idle_farmer_label:runAction(rept1)

end
function WorldMapView:showSignLayer()
    local signBox = mapSignLayer:create("mapSignLayer.csb")
    self:addChild(signBox, me.MAXZORDER)
    signBox:setVisitor(self)
    signBox:setPositionX(320)
    local a1 = cc.MoveTo:create(0.2, cc.p(0, 0))
    signBox:runAction(a1)
end
function WorldMapView:showPointTroops(cp)
    local signBox = pointTroopsLayer:create("mapSignLayer.csb")
    self:addChild(signBox, me.MAXZORDER)
    signBox:setVisitor(self)
    signBox:setPositionX(320)
    local a1 = cc.MoveTo:create(0.2, cc.p(0, 0))
    signBox:runAction(a1)
end
function WorldMapView:initUser()
    self:updateCroodText()
    if self:getWarningPoint() then
        self:lookMapAt(self.m_WarningPoint.x, self.m_WarningPoint.y, 0)
        self.m_WarningPoint = nil
    else
        self:lookMapAt(user.x, user.y, 0)
    end

    if self.optCate ~= nil then
        if self.optCate == 1 then
            -- 打开搜索圣地窗口
            self:FindRuneCreate(8)
        elseif self.optCate == 2 then
            -- 打开王座
            if user.throne_create.Thronr_type == 0 then
                local ThroneOpen = ThroneOpen:create("ThroneOpen.csb")
                ThroneOpen:setType(ThroneOpen.OPEN)
                pWorldMap:addChild(ThroneOpen, me.MAXZORDER)
            else
                if pWorldMap.kmv == nil then
                    pWorldMap.kmv = kingdomMainView:create("kingdomMainView.csb", 1, 3)
                    pWorldMap:addChild(pWorldMap.kmv, me.MAXZORDER)
                    me.showLayer(pWorldMap.kmv, "fixLayout")
                end
            end
        elseif self.optCate == 3 then
            self:FindRuneCreate(6)
        end
    end
end
function WorldMapView:initCell()
    for key, var in pairs(gameMap.mapCellDatas) do
        self:initCellWithData(var)
    end
    self:initUserDistenceLoad()
    self:initFort()
    self:initThrone()
end
function WorldMapView:initFort()
    local data = GFortData()
    for key, var in pairs(data) do
        local tiled_p = me.getCoordByFortId(var.id)
        local cdata = mapCellData.new(tiled_p.x, tiled_p.y, POINT_FORT, nil, OCC_STATE_NONE, -1, -1, 0, 0, 0)
        cdata:setFortId(var.id)
        gameMap.mapCellDatas[cdata:getId()] = cdata
        local near = getNearCrood(cc.p(tiled_p.x, tiled_p.y)) or { }
        for k, v in pairs(near) do
            local cellData = mapCellData.new(v.x, v.y, POINT_FBASE, nil, OCC_STATE_NONE, -1, -1, 0, 0, 0)
            local id_ = cellData:getId()
            gameMap.mapCellDatas[id_] = cellData
        end
        local cell = mapObjFactroy:createMapObj(cdata)
        local sp = me.convertToScreenCoord(tmxMap, cdata.crood)
        cell:setPos(sp)
        self.unitfortLayer:addChild(cell)
        cell:setLocalZOrder(99999999999)
        self.cellMoudels[cdata:getId()] = cell
    end
end
function WorldMapView:initThrone()
    local x = 600
    local y = 600
    local id = me.getIdByCoord(cc.p(x, y))
    local cdata = mapCellData.new(x, y, POINT_THRONE, nil, OCC_STATE_NONE, -1, -1, 0, 0, 0)
    gameMap.mapCellDatas[id] = cdata
    local near = getThroneNearCrood(cc.p(x, y)) or { }
    for k, v in pairs(near) do
        local cellData = mapCellData.new(v.x, v.y, POINT_TBASE, nil, OCC_STATE_NONE, -1, -1, 0, 0, 0)
        local id_ = cellData:getId()
        gameMap.mapCellDatas[id_] = cellData
    end
    local cell = mapObjFactroy:createMapObj(cdata)
    local sp = me.convertToScreenCoord(tmxMap, cdata.crood)
    cell:setPos(sp)
    self.unitfortLayer:addChild(cell, self:getCellZOrder(cdata.crood))
    self.cellMoudels[id] = cell
end
function WorldMapView:initUserDistenceLoad()
    local ld = getUserLordData()
    self.disLoadNode = cc.DrawNode:create()
    self.unitLayer:addChild(self.disLoadNode, -1)
    --[[
    if ld.roadLen then
        local topdis = ld.roadLen[1]
        if topdis > 0 then
            local top = me.convertToScreenCoord(tmxMap, cc.p(user.x, user.y - topdis))
            self.disLoadNode:drawLine(self.majorCityScreenPoint, top, cc.c4f(1, 1, 1, 1))
            local text = ccui.Text:create("距道路:" .. topdis, "", 18)
            text:setColor(cc.c3b(255, 0, 0))
            text:setPosition(me.convertToScreenCoord(tmxMap, cc.pAdd(cc.p(0, -1), cc.p(user.x, user.y))))
            local a = me.getAngle(self.majorCityScreenPoint, top)
            text:setRotation(360 - a)
            self.disLoadNode:addChild(text, me.MAXZORDER)
        end
        local bottomdis = ld.roadLen[2]
        if bottomdis > 0 then
            local bottom = me.convertToScreenCoord(tmxMap, cc.p(user.x, user.y + bottomdis))
            self.disLoadNode:drawLine(self.majorCityScreenPoint, bottom, cc.c4f(1, 1, 1, 1))
            local text = ccui.Text:create("距道路:" .. bottomdis, "", 18)
            text:setColor(cc.c3b(255, 0, 0))
            text:setPosition(me.convertToScreenCoord(tmxMap, cc.pAdd(cc.p(0, 1), cc.p(user.x, user.y))))
            local a = me.getAngle(self.majorCityScreenPoint, bottom)
            text:setRotation(360 - a)
            self.disLoadNode:addChild(text, me.MAXZORDER)
        end
        local leftdis = ld.roadLen[3]
        if leftdis > 0 then
            local left = me.convertToScreenCoord(tmxMap, cc.p(user.x - leftdis, user.y))
            self.disLoadNode:drawLine(self.majorCityScreenPoint, left, cc.c4f(1, 1, 1, 1))
            local text = ccui.Text:create("距道路:" .. leftdis, "", 18)
            text:setColor(cc.c3b(255, 0, 0))
            text:setPosition(me.convertToScreenCoord(tmxMap, cc.pAdd(cc.p(-1, 0), cc.p(user.x, user.y))))
            local a = me.getAngle(self.majorCityScreenPoint, left)
            text:setRotation(360 - a)
            self.disLoadNode:addChild(text, me.MAXZORDER)
        end
        local rightdis = ld.roadLen[4]
        if rightdis > 0 then
            local right = me.convertToScreenCoord(tmxMap, cc.p(user.x + rightdis, user.y))
            self.disLoadNode:drawLine(self.majorCityScreenPoint, right, cc.c4f(1, 1, 1, 1))
            local text = ccui.Text:create("距道路:" .. rightdis, "", 18)
            text:setColor(cc.c3b(255, 0, 0))
            text:setPosition(me.convertToScreenCoord(tmxMap, cc.pAdd(cc.p(1, 0), cc.p(user.x, user.y))))
            local a = me.getAngle(self.majorCityScreenPoint, right)
            text:setRotation(360 - a)
            self.disLoadNode:addChild(text, me.MAXZORDER)
        end
    end
    self.disLoadNode:setVisible(false)
    ]]
    local mapSize = tmxMap:getMapSize()
    local tileWidth = tmxMap:boundingBox().width / mapSize.width
    local tileHeight = tmxMap:boundingBox().height / mapSize.height
    local left = me.convertToScreenCoord(tmxMap, cc.p(0, getWorldMapHeight()))
    left = cc.pAdd(left, cc.p(- tileWidth / 2, 0))
    local top = me.convertToScreenCoord(tmxMap, cc.p(0, 0))
    top = cc.pAdd(top, cc.p(0, tileHeight / 2))
    local right = me.convertToScreenCoord(tmxMap, cc.p(getWorldMapWidth(), 0))
    right = cc.pAdd(right, cc.p(tileWidth / 2, 0))
    local bottom = me.convertToScreenCoord(tmxMap, cc.p(getWorldMapWidth(), getWorldMapHeight()))
    bottom = cc.pAdd(bottom, cc.p(tileWidth / 2, tileHeight / 2))
    self.disLoadNode:drawLine(left, top, cc.c4f(1, 0, 0, 1))
    self.disLoadNode:drawLine(top, right, cc.c4f(1, 0, 0, 1))
    self.disLoadNode:drawLine(right, bottom, cc.c4f(1, 0, 0, 1))
    self.disLoadNode:drawLine(bottom, left, cc.c4f(1, 0, 0, 1))
end
MINE_TAG = 1 -- 自己城堡/领地的点
FAMILY_TAG = 2 -- 联盟的点
ENEMY_TAG = 3-- 敌对阵营的点
FORTRESS_TAG = 4-- 要塞
THRONE_TAG = 5 -- 王座
MINI_MAP_SCALE = 50
function WorldMapView:moveMiniMap(pos_)
    local offPosX = pos_.x / MINI_MAP_SCALE
    local offPosY = pos_.y / MINI_MAP_SCALE
    local nodes = self.Panel_miniMap:getChildren()
    for key, var in pairs(nodes) do
        if var:getTag() == 999 then
            local x, y = var:getPosition()
            var:setPosition(cc.p(x + offPosX, y + offPosY))
        end
    end
end

function WorldMapView:updateMiniMap(mapData)
    self.Panel_miniMap:removeAllChildren()
    local function getImageNameByStatus(status_)
        local png = nil
        if status_ == MINE_TAG then
            png = "xiaoditu_ziji.png"
        elseif status_ == FAMILY_TAG then
            png = "xiaoditu_lianmeng.png"
        elseif status_ == ENEMY_TAG then
            png = "xiaoditu_dieren.png"
        elseif status_ == FORTRESS_TAG then
            png = "xiaoditu_yaosai.png"
        elseif status_ == THRONE_TAG then
            png = "xiaoditu_yaosai.png"
        end
        return png
    end
    local function getPosByOffPos(tarPos)
        -- 根据大地图的每个点之间的差距来缩放比例得到小地图上的坐标
        local p = me.convertToScreenCoord(tmxMap, user.curMapCrood)
        local userX, userY = p.x, p.y
        tarPos = me.convertToScreenCoord(tmxMap, tarPos)
        local miniCX, miniCY = self.Image_selfNode:getPosition()
        offPosX =(tarPos.x - userX) / MINI_MAP_SCALE
        offPosY =(tarPos.y - userY) / MINI_MAP_SCALE
        local newPos = cc.pAdd(cc.p(miniCX, miniCY), cc.p(offPosX, offPosY))
        return cc.p(newPos.x, newPos.y)
    end
    for key, var in pairs(mapData) do
        local posX, posY, status = var[1], var[2], var[3]
        local newPos = getPosByOffPos(cc.p(posX, posY))
        local png = getImageNameByStatus(me.toNum(status))
        local Img = ccui.ImageView:create()
        Img:setAnchorPoint(cc.p(0.5, 0.5))
        Img:loadTexture(png, me.localType)
        Img:setPosition(newPos)
        Img:setTag(999)
        self.Panel_miniMap:addChild(Img)
    end
end
-- 获取地图块当前数据
function WorldMapView:getCellDataByCrood(c)
    local id = me.getIdByCoord(c)
    return gameMap.mapCellDatas[id]
end
-- 初始化cell 
function WorldMapView:initCellWithData(cData)
    local id = cData:getId()
    local cell = self.cellMoudels[id]
    local pCellName = self.cellNameMoudels[id]
    local function createObj()
        local cell = mapObjFactroy:createMapObj(cData)
        local sp = me.convertToScreenCoord(tmxMap, cData.crood)
        cell:setPos(sp)
        local pCellName = cell:initName()
        if cData.pointType == POINT_CITY then
            pCellName:setVisible(true)
            pCellName:setPosition(cc.p(sp.x, sp.y + cellSize.height / 2 + pCellName:getPositionY()))
        elseif cData.pointType == POINT_STRONG_HOLD then
            pCellName:setVisible(true)
            pCellName:setPosition(cc.p(sp.x, sp.y + pCellName:getPositionY() - cell:getContentSize().height / 2))
        elseif cData.pointType == POINT_FORT and cell.giveupTimeBar then
            cell.giveupTimeBar:setPosition(cc.p(cell:getContentSize().width / 2 - cell.giveupTimeBar:getContentSize().width / 2,
            cell:getContentSize().height / 2))
        end
        self.unitNameLayer:addChild(pCellName)
        if cData.pointType == POINT_FORT or cData.pointType == POINT_THRONE then
            self.unitfortLayer:addChild(cell, self:getCellZOrder(cData.crood))
        else
            self.unitLayer:addChild(cell, self:getCellZOrder(cData.crood))
        end
        self.cellMoudels[id] = cell
        self.cellNameMoudels[id] = pCellName
    end
    if cell then
        if cData.pointType == POINT_CITY then
            --
            if cell.__index ~= mapCityObj then
                self:removeCellName(pCellName)
                cell:removeFromParentAndCleanup(true)
                createObj()
            else
                cell:initObj()
                local x, y = pCellName:getPosition()
                self:removeCellName(pCellName)
                local xCellName = cell:initName()
                if cData.pointType == POINT_CITY then
                    xCellName:setVisible(true)
                    xCellName:setPosition(x, y)
                elseif cData.pointType == POINT_STRONG_HOLD then
                    xCellName:setVisible(true)
                    xCellName:setPosition(x, y)
                end
                self.unitNameLayer:addChild(xCellName)
                self.cellNameMoudels[id] = xCellName
            end
        elseif cData.pointType == POINT_POST then
            if cell.__index ~= mapPostObj then
                self:removeCellName(pCellName)
                cell:removeFromParentAndCleanup(true)
                createObj()
            else
                cell:initObj()
            end
        elseif cData.pointType == POINT_STRONG_HOLD then
            if cell.__index ~= mapBastionObj then
                self:removeCellName(pCellName)
                cell:removeFromParentAndCleanup(true)
                createObj()
            else
                cell:initObj()
                local x, y = pCellName:getPosition()
                self:removeCellName(pCellName)
                local xCellName = cell:initName()
                if cData.pointType == POINT_CITY then
                    xCellName:setVisible(true)
                    xCellName:setPosition(x, y)
                elseif cData.pointType == POINT_STRONG_HOLD then
                    xCellName:setVisible(true)
                    xCellName:setPosition(x, y)
                end
                self.unitNameLayer:addChild(xCellName)
                self.cellNameMoudels[id] = xCellName
            end
        elseif cData.pointType == POINT_THRONE then

            if cell.__index ~= mapThroneObj then
                cell:removeFromParentAndCleanup(true)
                createObj()
            else
                cell:initObj()
            end
        else
            if cData.pointType == POINT_NORMAL and cData:getOccState() == OCC_STATE_NONE and cData:getOwnerData() == nil and cData.bossId == -1 then
                -- 删除地块
                cell:removeFromParentAndCleanup(true)
                self:removeCellName(pCellName)
                self.cellMoudels[id] = nil
                self.cellNameMoudels[id] = nil
                gameMap.mapCellDatas[id] = nil
            elseif cData.oldStronghold ~= nil and cData.oldStronghold == OLD_STRONGHOLD then
                -- 据点更新
                self:removeCellName(pCellName)
                cell:removeFromParentAndCleanup(true)
                createObj()
            else
                cell:initObj()
            end
        end
    else
        createObj()
    end
end
function WorldMapView:removeCellName(pCellName)
    if pCellName then
        pCellName:removeFromParentAndCleanup(true)
    end
end
function WorldMapView:updateCroodText()
    self.Text_crood:setString("(" .. user.curMapCrood.x .. "," .. user.curMapCrood.y .. ")")
end 
function WorldMapView:lookMapAt(x, y, time, from)
    self.lookMapJumpFrom = from or ""

    x = me.toNum(x)
    y = me.toNum(y)
    if x < 0 or x > tmxMap:getMapSize().width or y < 0 or y > tmxMap:getMapSize().height then
        showErrorMsg("此坐标为无效点！")
        return
    end
    tmxMap:stopAllActions();
    --   self.unitLayer:stopAllActions();
    local s = tmxMap:getContentSize()
    local sp = self.floor:getPositionAt(cc.p(x, y))
    local tagP = cc.p(- sp.x - tmxMap:getTileSize().width / 2 + me.winSize.width / 2, - sp.y - tmxMap:getTileSize().height / 2 + me.winSize.height / 2)
    local move = cc.MoveTo:create(time or 0.2, tagP)
    -- tmxMap:runAction(move)
    tmxMap:setPosition(tagP)
    self:scrollBg()
    -- self:updateTroopPath()
    self:LookMapAtSing(x, y)
    self:getScreenCenterCoord()

    self:showCompass()
    --  self.unitLayer:runAction(move)
end
function WorldMapView:LookMapAtSing(x, y)
    local sp = me.convertToScreenCoord(tmxMap, cc.p(x, y))
    if self.cursor then
        self.cursor:setPosition(sp)
    else
        self.cursor = ccui.ImageView:create("cursor_green.png")
        self.cursor:setPosition(sp)
        self.cursor:setLocalZOrder(-1)
        self.unitLayer:addChild(self.cursor)
        me.blink(self.cursor)
    end
end
function WorldMapView:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_INFO) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_SKILL_LIST) then
        self:openHeroSkillAnim()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_OPEN_SKILL) then
        self:setHeroSkillStatus(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_GEM_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_PAYGEM_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_RESOURCE_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_FIGHT_UPDATE) then
        self:updateFightPower(msg)
    elseif checkMsg(msg.t, MsgCode.TASK_CAPHTER_TITLE) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_GET_TITLE) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_DATA) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_GET_TASK) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_DATA_UPDATA)
    then
        self:updateTasskCaphter()       
        self:showCommendTask()          
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_VIEW) then
        me.coroClear(self.schid)
        self.cellThread = coroutine.create( function()
            -- 这里为调用的方法 然后在该方法中加入coroutine.yield()
            self:revMapCellDatas(msg)
        end )
        self.schid = me.coroStart(self.cellThread)
    elseif checkMsg(msg.t, MsgCode.MSG_WORLD_REMOVE) then
        local id = me.getIdByCoord(cc.p(msg.c.x, msg.c.y))
        local cell = self.cellMoudels[id]
        local pCellname = self.cellNameMoudels[id]
        if pCellname then
            pCellname:removeFromParentAndCleanup(true)
        end
        if cell then
            cell:removeFromParentAndCleanup(true)
        end
        self.cellMoudels[id] = nil
        self.cellNameMoudels[id] = nil
        gameMap.mapCellDatas[id] = nil
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_INIT) then        

    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then
        -- 奖励
        if msg.c.type == kingdom_cross_rewards.RankRewardType or msg.c.type == kingdom_cross_rewards.totalRewardType
            or msg.c.type == kingdom_cross_rewards.countryRewardType
            or msg.c.type == kingdom_cross_rewards.personRewardType then
            if self.kingdom_cross_rewards == nil then
                self.kingdom_cross_rewards = nil
                self.kingdom_cross_rewards = kingdom_cross_rewards:create("kingdom_cross_rewards.csb")
                self.kingdom_cross_rewards:setRewardType(msg.c.type, msg.c.stp, msg.c.award, function()
                    self.kingdom_cross_rewards = nil
                end )
                me.popLayer(self.kingdom_cross_rewards)
            else
                self.kingdom_cross_rewards:setRewardType(msg.c.type, msg.c.stp, msg.c.award, function()
                    self.kingdom_cross_rewards = nil
                end )
                self.kingdom_cross_rewards:setRewardInfos()
            end
        end
    elseif checkMsg(msg.t, MsgCode.CITY_ARMY_INFO) then
        if self.armyView == nil then
            self.armyView = armyView:create("armyView.csb")
            self:addChild(self.armyView, me.MAXZORDER)
            me.showLayer(self.armyView, "bg")
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_POINT) or checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_UPDATE) then
        local var = msg.c
        local cdata = self:getCellDataByCrood(cc.p(var.x, var.y))
        self:initCellWithData(cdata)
        if cdata and cdata.pointType == POINT_THRONE then
            local near = getThroneNearCrood(cc.p(var.x, var.y)) or { }
            for k, v in pairs(near) do
                local fdata = self:getCellDataByCrood(cc.p(v.x, v.y))
                if fdata then
                    self:initCellWithData(fdata)
                end
            end
        elseif cdata and cdata.pointType == POINT_FORT then
            local near = getNearCrood(cc.p(var.x, var.y)) or { }
            for k, v in pairs(near) do
                local fdata = self:getCellDataByCrood(cc.p(v.x, v.y))
                if fdata then
                    self:initCellWithData(fdata)
                end
            end
        end
    elseif checkMsg(msg.t, MsgCode.TASK_LIST) or checkMsg(msg.t, MsgCode.TASK_UPDATE) or checkMsg(msg.t, MsgCode.TASK_COMPLETE) then
        self:setTaskHint()
        self:TaskAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_ARMY_DP) then
        local function isRightGuide(status_)
            if (status_ == EXPED_STATE_ARCH and guideHelper.getGuideIndex() == guideHelper.guideGoToArch + 5) or
                (status_ == EXPED_STATE_PILLAGE and guideHelper.getGuideIndex() == guideHelper.guideExplore + 4) or
                (status_ == EXPED_STATE_OCC and guideHelper.getGuideIndex() == guideHelper.guideConquest + 5) then
                return true
            end
            return false
        end
        if isRightGuide(msg.c.status) then
            guideHelper.nextStepByOpt()
        end
        self:revExpedMsg(msg)
        self:TroopLine(msg, true)
    elseif checkMsg(msg.t, MsgCode.WORLD_BATTLE_INFO) then
        self:showBattleAni(msg)

    elseif checkMsg(msg.t, MsgCode.WORLD_FIRST_BATTLE) then
        self:cloudClose( function(args)
            local battle = firstBattleLayer:create("firstBattleLayer.csb")
            me.runningScene():addChild(battle, me.MAXZORDER + me.MAXZORDER)
        end )
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_PATH) then
        -- 获取路径主要用于计算时间
        self:showExped(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_ARMY_REMOVE) then
        -- 删除军队
        self:revRemoveArmy(msg)
        if pWorldMap.av then
            if pWorldMap.av:getUsed() == true then
                showTips("使用成功！")
            end
            pWorldMap.av:close()
        end
    elseif checkMsg(msg.t, MsgCode.MSG_ACHIEVENMENT_INIT) then
        self:initAchievenmentView()
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_ARMY_REMOVE_TABLE) then
        self:revRemoveArmyTable(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_NEW) then
        me.assignWidget(self, "mail_red_hint"):setVisible(true)
        mMailRead = true
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_UPDATE) then
        self:updateRoadState(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT) or checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT_REMOVE) then
        print("worldMapView  #user.warningList = " .. #user.warningList)
        if user.warningListNum < #user.warningList then
            me.assignWidget(self.Button_warning, "ArmatureNode_Jishi"):setVisible(true)
        end
        user.warningListNum = #user.warningList
        self.Button_warning:setVisible(#user.warningList > 0)
    elseif checkMsg(msg.t, MsgCode.BOOK_INIT) then
        -- disWaitLayer()
        if self.archbool == false then
            self:setArch()
            self:archHint()
            self.archbool = true
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_MAP_DP_TRADINGPOST) then
        --    mMapPost = true
    elseif checkMsg(msg.t, MsgCode.FAMLIY_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CAMOP_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_BUTTON_SHOW) then
        self:UpButtonPosition()
    elseif checkMsg(msg.t, MsgCode.ROLE_NOTICE) then
        -- 事件信息
        local noticeId = msg.c.id
        if noticeId == 98 then
            -- 失败
            self:FailAnimation()
        elseif noticeId == 99 then
            -- 胜利
            self:VictoryAnimation()
        elseif noticeId == 102 then
            -- 抵御蛮族成功播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_RESIST_VICTORY)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        elseif noticeId == 103 then
            -- 抵御蛮族失败播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_RESIST_FAILURE)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        elseif noticeId == 199 then
            -- 挖矿掠夺成功播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_VICTORY)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        elseif noticeId == 198 then
            -- 挖矿掠夺失败播放效果L
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_FAILURE)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        else
            if noticeId < 40 then
                mInforHint = mInforHint + 1
                mInforHint = math.min(mInforHint, 20)
                setInfortHint(self)
                if mInforNum == 1 then
                    showInfor(self)
                else
                    InforHintBtn(self)
                end
            end
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
        disWaitLayer()
        if self.mRankView == nil and msg.c.typeId ~= 12 and msg.c.typeId ~= rankView.PAY_RANK
            and msg.c.typeId ~= rankView.NET_PAY_RANK
            and msg.c.typeId ~= rankView.NET_COST_RANK
            and msg.c.typeId ~= 17
            and msg.c.typeId ~= 18
            and msg.c.typeId ~= 19
            and msg.c.typeId ~= rankView.BOSS_ACT_FAMILY_RANK
            and msg.c.typeId ~= rankView.COST_RANK
            and msg.c.typeId ~= rankView.PROMITION_NEWYEAR and msg.c.typeId ~= rankView.PROMITION_NEWYEARTOTAL
        then
            self:setRank(msg.c.typeId)
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_NOT_INFOR_HINT) then
        --    self:revQuitFamlily()
        if self.allianceExitview ~= nil and msg.c.alertId == 562 then
            self:setExitAlliance()
            -- elseif msg.c.alertId == 564 then
            --    showTips("玩家已退出联盟")
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_INIT) then
        if pWorldMap.allianceInfor == false then
            self:revAlliance()
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER_ESC) or checkMsg(msg.type, MsgCode.FAMILY_BE_KICK) then
        pWorldMap.allianceInfor = false
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_INIT) then
        if self.pfortGeneralView == nil then
            if self.mFortHeroBool then
                disWaitLayer()
                self:setFortworld()
            else
                self:setHeroGeneral()
            end
        end

    elseif checkMsg(msg.t, MsgCode.ROLE_VIP_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.WORLD_CITY_TEAM_VIEW) then
        local pconvergeAid = convergeAid:create("Node_convergeAid.csb")
        pconvergeAid:setPoint(self.AidPoint, msg.c.nowSolider, msg.c.maxSoliderNum)
        pconvergeAid:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
        pWorldMap:addChild(pconvergeAid, me.MAXZORDER)
    elseif checkMsg(msg.t, MsgCode.WORLD_ARMY_DETAIL) then
        local convergeAidRecord = convergeAidRecord:create("convergeAidRecord.csb")
        pWorldMap:addChild(convergeAidRecord, me.MAXZORDER)
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_DETAIL) then
        if self.allianceExitview == nil then
            self.pconvergeFire = convergeFire:create("convergeFire.csb")
            self.pconvergeFire:setData(nil)
            pWorldMap:addChild(self.pconvergeFire, me.MAXZORDER)
        end
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_HINT) then
        self:setAllianceHint()
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CREATE) then
        self:setAllianceHint()
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_RENIVE_HINT) then
        self:setAllianceHint()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_RANK) then
        self:doClickEvent(self.m_cp, true)
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_CREATE) then
        self:doClickEvent(self.m_cp)
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_MORALE) then
        self:ThroneMoarleRank()
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_INIT) then
        self:ThroneInit()
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_STRATEGY) then
        self:ThroneStartegy()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_OPEN) then
        -- 试炼特效
        local var = msg.c
        local cdata = self:getCellDataByCrood(cc.p(var.x, var.y))
        if cdata then
            self:initCellWithData(cdata)
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_STRATEGY_START) then

        local var = msg.c
        local cdata = self:getCellDataByCrood(cc.p(600, 600))
        if cdata then
            self:initCellWithData(cdata)
        end
        if pWorldMap.ThroneStrategy ~= nil and self.ThroneStratAniBool then
            pWorldMap.ThroneStrategy:close()
            self.ThroneStratAniBool = false
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
        self:getHongbaoAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
        self:getHongbaoAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.REDBAO_OPEN) then
        self.Image_hongbao_bg:setVisible(false)
    elseif checkMsg(msg.t, MsgCode.REDBAO_CLODE) then
        self:setHongBaoInfo()
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_ONEXIT) then
        self:cloudClose( function(args)
            self:goCityView()
            --   me.setWidgetCanTouchDelay(node, 2)
        end )
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_PROMOTION_LIST) then
        --        if pWorldMap.kmv == nil then
        --            self:setCross_City()
        --        end
    elseif checkMsg(msg.t, MsgCode.MAP_MARK_KING) then
        self:setMarkKing()
        -- self:doExped_KingTarget()
    elseif checkMsg(msg.t, MsgCode.CROSS_THRONE_OCCUPY) then
        self:setCrossThroneOccpy()
    elseif checkMsg(msg.t, MsgCode.CROSS_THRONE_END) then
        self:setCrossThroneEnd()
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_STATUS) then
        -- self:worldCrossOpen()
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_FIND_GUARD_INIT) then
        -- self:FindRuneCreate()
    elseif checkMsg(msg.t, MsgCode.WORLD_ARMY_INFO) then
        self:WorldArmyInfo(msg)
    elseif checkMsg(msg.t, MsgCode.SHOP_INIT) then
        if msg.c.shopId == ELEVENSHOP then
            user.elevenShopInfos = ElevenShopData.new(msg.c.time, msg.c.list, msg.c.comsumeAgio, msg.c.comsume)
            local esv = elevenShopView:create("elevenShopView.csb")
            me.runningScene():addChild(esv, me.MAXZORDER)
            me.showLayer(esv, "bg_frame")
        end
    elseif checkMsg(msg.t, MsgCode.MAP_ZHAOHUAN_SHANGDUI) then
        -- 召唤商队成功
        local callback = function()
            showTips(msg.c.content)
        end
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_ZHAOHUAN, callback)
        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
        -- 主城位置改变
    elseif checkMsg(msg.t, MsgCode.ROLE_ORIGIN_UPDATE) then
        self.mainCtiyPos = me.convertToScreenCoord(tmxMap, user.majorCityCrood)
        self:RankSkipPoint(user.majorCityCrood)
        -- 更换头像
    elseif checkMsg(msg.t, MsgCode.CHANGE_HEAD) then
        if user.head then
            local cfg = cfg[CfgType.ROLE_HEAD]
            self.age:loadTexture(cfg[user.head].icon .. ".png", me.localType)
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM) then
        self:calArchEquipHeroRedDot()
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_CHANGE) then
        self:calArchEquipHeroRedDot()
    end
end
function WorldMapView:backCity()
    self:cloudClose( function(args)
        self:goCityView()

    end )
end
function WorldMapView:WorldArmyInfo(msg)

    self.StongHoldList = strongholdlist:create("strongholdtransfer.csb")
    self.StongHoldList:lookTroops(msg)
    pWorldMap:addChild(self.StongHoldList, me.MAXZORDER)
end
function WorldMapView:FindRuneCreate(cate)
    if self.findRuneBoos == nil then
        cate = cate or 0
        self.findRuneBoos = find_rune_boos:create("find_rune_boos.csb", 1, cate)
        self:addChild(self.findRuneBoos, me.MAXZORDER)
        me.showLayer(self.findRuneBoos, "bg")
    end
end
function WorldMapView:setCrossThroneEnd()
    self.kingdomView_Cross_Out = kingdomView_Cross_Out:create("kingdomView_Cross_Out.csb")
    self.kingdomView_Cross_Out:setEnd()
    self:addChild(self.kingdomView_Cross_Out, me.MAXZORDER)
end
function WorldMapView:setCrossThroneOccpy()
    self.kingdomView_Cross_Out = kingdomView_Cross_Out:create("kingdomView_Cross_Out.csb")
    self.kingdomView_Cross_Out:setWin()
    self:addChild(self.kingdomView_Cross_Out, me.MAXZORDER)
end
function WorldMapView:setMarkKing()
    for key, var in pairs(self.markKing_signs) do
        var:setVisible(false)
    end
    for key, var in pairs(user.markKingPos) do
        if var then
            self.markKing_signs[key] = ccui.ImageView:create("waicheng_tubiao_qizhi.png")
            local sp = me.convertToScreenCoord(tmxMap, me.converCoordbyId(key))
            self.markKing_signs[key]:setPosition(cc.p(sp.x + 30, sp.y))
            self.unitLayer:addChild(self.markKing_signs[key], me.MAXZORDER)
        end
    end
end
function WorldMapView:setCross_City(msg)
    self.kingdomView_Cross_City = kingdomView_Cross_City:create()
    --  self.kingdomView_Cross_City:setData()
    self:addChild(self.kingdomView_Cross_City, me.MAXZORDER)
end
function WorldMapView:ThroneStartegy()
    if pWorldMap.ThroneStrategy == nil then
        self.ThroneStrategy = ThroneStrategy:create("ThroneStrategy.csb")
        pWorldMap:addChild(self.ThroneStrategy, me.MAXZORDER)
    else
        self.ThroneStrategy:setStrategy()
    end
end
function WorldMapView:ThroneInit()
    local pThroneRecord = ThroneRecord:create("ThroneRecord.csb")
    pWorldMap:addChild(pThroneRecord, me.MAXZORDER)
end
function WorldMapView:ThroneMoarleRank()
    local ThroneOpen = ThroneOpen:create("ThroneOpen.csb")
    ThroneOpen:setType(ThroneOpen.CLOSE)
    pWorldMap:addChild(ThroneOpen, me.MAXZORDER)
end
function WorldMapView:setHongBaoInfo()
    if user.hongBao_name and user.hongBao_union then
        me.assignWidget(self.Panel_HongBao, "Text_hongBao_name"):setString("[" .. user.hongBao_union .. "]" .. user.hongBao_name .. "的红包")
    else
        me.assignWidget(self.Panel_HongBao, "Text_hongBao_name"):setString(user.hongBao_name)
    end
    me.assignWidget(self.Panel_HongBao, "Text_Hongbao_Zhuanshi"):setString(user.hongBao_nums)
end
function WorldMapView:getHongbaoAnimation(msg)
    if msg.c.iteminfo and msg.c.processValue and msg.c.processValue == 112 then
        local pConfigData = cfg[CfgType.ETC][msg.c.iteminfo.defId]
        local i = { }
        local showNum = 0
        i[#i + 1] = { }
        i[#i]["defId"] = msg.c.iteminfo.defId
        i[#i]["needColorLayer"] = true
        for key, var in pairs(user.pkg) do
            if var:getDef().id == msg.c.iteminfo.defId then
                if var.prevCount then
                    showNum = var.count - var.prevCount
                else
                    showNum = var.count
                end
            end
        end
        i[#i]["itemNum"] = showNum
        getItemAnim(i)
    end
end

-- 开启英雄技能的特效
function WorldMapView:setHeroSkillStatus(msg)
    if msg.c.hss == 1 and self.Button_heroSkill:isVisible() == false then
        if self.pfortGeneralView then
            self.pfortGeneralView:close()
        end
        local scence = nil
        if CUR_GAME_STATE == GAME_STATE_CITY then
            scence = mainCity
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            scence = pWorldMap
        end

        local img = ccui.ImageView:create("zhucheng_jn_zhengchang.png", me.localType)
        scence:addChild(img)
        img:setAnchorPoint(cc.p(1, 0))
        img:setPosition(me.winSize.width / 2 - img:getContentSize().width / 2, me.winSize.height / 2)
        local call = cc.CallFunc:create( function()
            self.Button_heroSkill:setVisible(true)
            self:setSkillButtonPos()
            local guide = guideView:getInstance()
            guide:showGuideView(scence.Button_heroSkill, false, false)
            scence:addChild(guide, me.GUIDEZODER)
            img:stopAllActions()
            img:removeFromParent()
        end )
        local move = cc.MoveTo:create(1.2, cc.p(scence.Button_heroSkill:getPositionX(), scence.Button_heroSkill:getPositionY()))
        local seq = cc.Sequence:create(move, call)
        img:runAction(seq)
    end
end
function WorldMapView:setFortHero()
    self.mFortHeroBool = false
end 
-- 要塞坐标
function WorldMapView:setPitchFortPoint(id)
    self.mPitchFortId = id
end
function WorldMapView:getPichFortPoint()
    return self.mPitchFortId
end
function WorldMapView:setParentHero()
    self.pfortGeneralView = nil
end
function WorldMapView:setClearTimeExper()
    self.mClearTimeExper = true
end
function WorldMapView:setHeroGeneral()
    self.mFortHeroBool = true
    if self.pfortGeneralView == nil then
        self.pfortGeneralView = fortGeneralView:create("fortgeneralView.csb")
        pWorldMap:addChild(self.pfortGeneralView, me.MAXZORDER)
    end
end
function WorldMapView:setAllianceHint()
    local pHint = user.allianceConvergeHint.attack + user.allianceConvergeHint.defener
    if pHint > 0 and user.familyUid > 0 then
        me.assignWidget(self, "guildBtn_hint"):setVisible(true)
    else
        me.assignWidget(self, "guildBtn_hint"):setVisible(false)
    end
end
function WorldMapView:setConvergeAidPoint(cp)
    self.AidPoint = cp
end
function WorldMapView:updateFightPower(msg)
    self.grade_label:setString(UserGrade())
end

function WorldMapView:fapChanged(event)
    local data = event._userData
    if data.newFap > data.oldFap then
        -- 光效
        local fromPos = cc.p(self:getContentSize().width / 2 - 105, self:getContentSize().height / 2 - 70)
        local x, y = self.daodao_1:getPosition()
        local toPos = self:convertToNodeSpace(self.ui_bar:convertToWorldSpace(cc.p(x, y)))
        local angle = me.getAngle(fromPos, toPos)

        -- 图片中点坐标
        local imgSize = cc.size(300 - 60, 130)
        local startX = fromPos.x + imgSize.width / 2 * math.cos(angle * math.pi / 180)
        local startY = fromPos.y + imgSize.width / 2 * math.sin(angle * math.pi / 180)
        local endX = toPos.x + imgSize.width / 2 * math.cos((angle - 180) * math.pi / 180)
        local endY = toPos.y + imgSize.width / 2 * math.sin((angle - 180) * math.pi / 180)
        local ani = createArmature("fap_up")
        ani:setPosition(cc.p(startX, startY))
        ani:setRotation(- angle)
        self:addChild(ani)
        ani:getAnimation():play("lan")
        ani:setVisible(false)
        ani:runAction(cc.Sequence:create(
        cc.DelayTime:create(2.1),
        cc.Show:create(),
        cc.MoveTo:create(0.3, cc.p(endX, endY)),
        cc.CallFunc:create( function()
            self.grade_label:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.1, 1.25), cc.ScaleTo:create(0.1, 1.2)
            ))
            ani:removeFromParentAndCleanup(true)
        end )
        ))
        -- self:showFapUp(data.newFap - data.oldFap)
    end
end

-- 展示战力增加
function WorldMapView:showFapUp(addNum)
    local tempPos = cc.p(self.grade_label:getPosition())
    local pos_world = self.ui_bar:convertToWorldSpace(cc.p(tempPos.x - 5, tempPos.y - 30))
    local pos_local = self:convertToNodeSpace(pos_world)
    local addLabel = self.food_label:clone()
    addLabel:setString(string.format("+%s", addNum))
    addLabel:setPosition(pos_local)
    self:addChild(addLabel, me.MAXZORDER)
    addLabel:runAction(cc.Sequence:create(
    cc.DelayTime:create(1.0),
    cc.MoveBy:create(1.0, cc.p(0, 10)),
    cc.CallFunc:create( function()
        addLabel:removeFromParentAndCleanup(true)
    end )
    ))
end

function WorldMapView:revMapCellDatas(msg)
    local cp = cc.p(msg.c.x, msg.c.y)
    self:clearnNormalCells(msg.c.max_cell_nums)
    for key, var in pairs(msg.c.list) do
        if var.list then
            for k, v in pairs(var.list) do
                local cdata = self:getCellDataByCrood(cc.p(v.x, v.y))
                if cdata then
                    self:initCellWithData(cdata)
                    coroutine.yield()
                    if cdata.pointType == POINT_THRONE then
                        local near = getThroneNearCrood(cc.p(cdata.crood.x, cdata.crood.y)) or { }
                        for kk, vv in pairs(near) do
                            local fdata = self:getCellDataByCrood(cc.p(vv.x, vv.y))
                            if fdata then
                                self:initCellWithData(fdata)
                                coroutine.yield()
                            end
                        end
                    end
                end
            end
        end
    end
    if msg.c.mini then
        self:updateMiniMap(msg.c.mini)
    end
    if table.nums(msg.c.flist) > 0 then
        for key, var in pairs(msg.c.flist) do
            local cdata = self:getCellDataByCrood(cc.p(var.x, var.y))
            if cdata then
                self:initCellWithData(cdata)
                coroutine.yield()
            end
            local near = getNearCrood(cc.p(var.x, var.y)) or { }
            for k, v in pairs(near) do
                local fdata = self:getCellDataByCrood(cc.p(v.x, v.y))
                if fdata then
                    self:initCellWithData(fdata)
                    coroutine.yield()
                end
            end
        end
    end
end
function WorldMapView:setFortworld()
    self.fortlayer = fortWorld:create("fort/fortWorld.csb")
    self:addChild(self.fortlayer, me.MAXZORDER)
    me.showLayer(self.fortlayer, "fixLayout")
end
function WorldMapView:setExitAlliance()
    local function exitAlliance(node)
        if self.allianceExitview ~= nil then
            self.allianceExitview:removeFromParent()
            self.allianceExitview = nil
            pWorldMap.allianceInfor = false
        end
    end
    local box = MessageBox:create("MessageBox.csb")
    box:setText("你被踢出联盟了")
    box:register(exitAlliance)
    box:setButtonMode(1)
    self:addChild(box, me.ANIMATION)
end
function WorldMapView:AllianceSkipPoint(pPoint)
    if self.allianceExitview ~= nil then
        self.allianceExitview:removeFromParent()
        self.allianceExitview = nil
        pWorldMap.allianceInfor = false
        self:lookMapAt(pPoint.x, pPoint.y, 0)
    end
end
function WorldMapView:updateLocalTime()
    self.localtimeTimer = me.registTimer(-1, function(dt)
        if self.localTime then
            self.localTime:setString(me.formartServerTime(me.sysTime() / 1000))
        end
    end , 1, "updateLocalTime")
end
function WorldMapView:RankSkipPoint(pPoint)
    self:lookMapAt(pPoint.x, pPoint.y, 0)
end
function WorldMapView:revAlliance()
    pWorldMap.allianceInfor = true
    self.allianceview = allianceview:create("alliance/allianceview.csb")
    self:addChild(self.allianceview, me.MAXZORDER)
    self.allianceExitview = self.allianceview
end
function WorldMapView:setRank(typeId)
    local pRank = rankView:create("rank/rankview.csb")
    pRank:setRankRype(typeId)
    pRank:ParentNode(self)
    me.popLayer(pRank, "bg_frame")
    self.mRankView = pRank
end
function WorldMapView:TaskAnimation(msg)
    if msg.c.list ~= nil then
        for key, var in pairs(msg.c.list) do
            if me.toNum(var.progress) == 3 then
                me.DelayRun( function()
                    self:CommonAnimation(ALL_COMMON_TASK)
                end , 0.6)
                break
            end
        end
    end
end
function WorldMapView:CommonAnimation(pStr)
    local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
    pCityCommon:CommonSpecific(pStr)
    pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 100))
    me.runningScene():addChild(pCityCommon, me.MAXZORDER)
end
function WorldMapView:setArch()
    local arch = archLayer:create("archLayer.csb")
    arch:setLayerType(pWorldMap)
    setBookAltas()
    arch:setData()
    self:addChild(arch, me.MAXZORDER - 1)
    me.showLayer(arch, "bg")
    --  buildingOptMenuLayer:getInstance():clearnButton()
end
function WorldMapView:setMailTask()
    local pBool = getMailHintRed()
    pBool = getMailSystemHintRed()
    if pBool == true then
        me.assignWidget(self, "mail_red_hint"):setVisible(true)
        mMailRead = true
    end
end

function WorldMapView:revRemoveArmy(msg)
    local troop = self.troopsGroup[msg.c.id]
    local tdata = gameMap.troopData[msg.c.id]
    if tdata then
        local obj = self.cellMoudels[me.getIdByCoord(tdata:getOriPoint())]
        if obj and obj.updateEventState then
            -- obj:setTroopId(nil)
            gameMap.troopData[msg.c.id].m_Status = -1
            obj:updateEventState()
        end
    end
    if troop and troop.removeFromParent then
        troop:purge()
        self.troopsGroup[msg.c.id] = nil
    end
    gameMap.troopData[msg.c.id] = nil
    self:TroopLine(msg, false)
end
function WorldMapView:revRemoveArmyTable(msg)
    for key, var in pairs(msg.c.ids) do
        local msg = { }
        msg.c = { }
        msg.c.id = me.toNum(var)
        self:revRemoveArmy(msg)
    end
end
function WorldMapView:onEnter()
    print("WorldMapView onEnter")
    me.doLayout(self, me.winSize)
    me.doLayout(self.Panel_touchHeroSkill, me.winSize)
    me.doLayout(me.assignWidget(self, "btnPanel"), me.winSize)
    me.doLayout(me.assignWidget(self, "Panel_HongBao"), me.winSize)
    self.globalItems = me.createNode("Node_troopLineItem.csb")
    self.globalItems:retain()
    --   me.Helper:DirectorSetProjection2D()
    self:updateLocalTime()
    self.modelkey = UserModel:registerLisener( function(msg)
        self:update(msg)
    end )
    local function updateTimer(dt)
        self:updateActBtnTimes(dt)
    end
    self.updateNodeZorderTimer = me.registTimer(-1, updateTimer, 1)
    me.registGuiClickEvent(self.Button_heroSkill, function(node)
        NetMan:send(_MSG.worldSkillList())
    end )
    me.registGuiTouchEvent(self.Panel_touchHeroSkill, function(node, event)
        self:closeHeroSkillAnim()
    end )
    self:checkTroop()
    -- 活动等UI红点显示
    self.uiRedPointListener = me.RegistCustomEvent("UI_RED_POINT", handler(self, self.updateUIRedPoint))
    me.assignWidget(self, "redpoint_vip"):setVisible(user.iget_free == false and user.vipTime > 0)
    self:updateUIRedPoint()
    self:setTaskHint()
    self:setSkillButtonPos()
    switchButtons()
    self:UpButtonPosition()
    if guideHelper.getGuideIndex() ~= guideHelper.guide_End then
        guideHelper.showWaitLayer()
    end
    self.bShowNetInterrupt = false
    self.mainCtiyPos = me.convertToScreenCoord(tmxMap, user.majorCityCrood)
    self:showCompass()
    self:updateTasskCaphter()
    self.taskBtn:setVisible(user.newBtnIDs[me.toStr(OpenButtonID_TaskBtn)]~=nil)
end
function WorldMapView:updateTasskCaphter()
    local pro = me.assignWidget(self, "Text_taskCaphter_process")
    if user.taskCaphterDataTitle then
        if user.taskCaphterDataTitle.status ~= 3 then
            me.assignWidget(self, "Image_taskCaphter_bg"):setVisible(true)
            me.assignWidget(self, "Image_TaskCaphter_process"):setVisible(true)
            me.assignWidget(self, "Image_caphter_complete"):setVisible(user.taskCaphterDataTitle.status == 2)
            local data = getCurTaskCaphter()
            if data then
                local taskdata = cfg[CfgType.CAPHTER_TASK][data.id]
                dump(data)
                pro:setString(taskdata.gole .. "[" .. data.value .. "/" .. data.maxValue .. "]")
                if data.status == 1 then
                    pro:setColor(me.convert3Color_("FEEFC1"))
                elseif data.status == 2 then
                    pro:setColor(COLOR_GREEN)
                    me.assignWidget(self, "Image_caphter_complete"):setVisible(true)
                end
            end
            if user.taskCaphterDataTitle.status == 2 then
                pro:setString("本章任务已完成，可领奖")
            end
            local num = 0
            if user.taskCaphterData then
                for key, var in pairs(user.taskCaphterData) do
                    if var.status == 2 then
                        num = num + 1
                    end
                end
            end
            local Image_taskCaphter_bg = me.assignWidget(self, "Image_taskCaphter_bg")
            me.assignWidget(Image_taskCaphter_bg, "redpoint"):setVisible(user.taskCaphterDataTitle.status == 2 or num > 0)
            me.assignWidget(Image_taskCaphter_bg, "caphter_Hint_num"):setString(num)
            me.assignWidget(Image_taskCaphter_bg, "caphter_Hint_num"):setVisible(num > 0)
            me.assignWidget(Image_taskCaphter_bg, "ArmatureNode_taskCaphter"):setVisible(user.taskCaphterDataTitle.status == 2 or num > 0)
            -- me.assignWidget(self, "taskCaphter_ani"):setVisible(user.taskCaphterDataTitle.status == 2 or num>0)
            if user.taskCaphterDataTitle.status == 0 then
                -- 章节未开启
                me.assignWidget(self, "Image_taskCaphter_bg"):setVisible(false)
                me.assignWidget(self, "Image_TaskCaphter_process"):setVisible(false)
            end
        else
            if user.taskCaphterDataTitle.nextId == 0 then
                me.assignWidget(self, "Image_taskCaphter_bg"):setVisible(false)
                me.assignWidget(self, "Image_TaskCaphter_process"):setVisible(false)
                self.taskBtn:setPosition(me.assignWidget(self,"Image_taskCaphter_bg"):getPosition())    
                me.assignWidget(self,"commend"):setPosition(71,207)
            else
                me.assignWidget(self, "Image_taskCaphter_bg"):setVisible(true)
                me.assignWidget(self, "Image_TaskCaphter_process"):setVisible(true)
                local nextdata = cfg[CfgType.CAPHTER_TITLE][user.taskCaphterDataTitle.nextId]
                if nextdata then
                    pro:setString("城镇中心" .. nextdata.centerLevel .. "级开启下一章")
                end
            end
            me.assignWidget(self, "Image_caphter_complete"):setVisible(false)
        end
    end
end
-- 活动等UI红点显示
function WorldMapView:updateUIRedPoint()
    for k, v in pairs(user.UI_REDPOINT) do
        local redpoint = me.assignWidget(me.assignWidget(self, k), 'redpoint')
        redpoint:setVisible(false)
        for k1, v1 in pairs(v) do
            if v1 == 1 then
                redpoint:setVisible(true)
                break
            end
        end
    end
    me.assignWidget(self, "redpoint_vip"):setVisible(user.iget_free == false and user.vipTime > 0)
end

function WorldMapView:closeHeroSkillAnim()
    if self.Panel_heroSkill ~= nil then
        self.Panel_heroSkill:closeHeroSkillAnim()
    end
end
function WorldMapView:openHeroSkillAnim()
    if self.Panel_heroSkill == nil then
        self.Panel_heroSkill = fortHeroSkillPanel:create("Layer_HeroSkillsPanel.csb")
        self.Panel_heroSkill:setPosition(cc.p(me.winSize.width / 2, 0))
        self.Panel_heroSkill:setAnchorPoint(cc.p(0.5, 0))
        self.Panel_touchHeroSkill:addChild(self.Panel_heroSkill)
        me.DelayRun( function()
            self.Panel_heroSkill:openHeroSkillAnim()
        end )
    else
        self.Panel_heroSkill:openHeroSkillAnim()
    end
end

-- 初始化要塞信息
function WorldMapView:initRoadState()
    initFortSegmentData()
    self:openRoad(gameMap.lineSegmentDatas)
end
function WorldMapView:openRoad(list)
    for key, var in pairs(list) do
        if var.state == 1 then
            local c1, c2 = me.converDualCrood(var.id)
            if c1.x == c2.x then
                local n1 = math.min(c1.y, c2.y)
                local n2 = math.max(c1.y, c2.y)
                for var = n1 + 1, n2 - 1, 1 do
                    local sprite = pWorldMap.floor:getTileAt(cc.p(c1.x, var))
                    if sprite then
                        me.clickAni(sprite)
                    end
                    local gid, _ = pWorldMap.floor:getTileGIDAt(cc.p(c1.x, var))
                    local newgid = getConnectedRoadByGird(gid)
                    pWorldMap.floor:setTileGID(newgid, cc.p(c1.x, var))
                end
            elseif c1.y == c2.y then
                local n1 = math.min(c1.x, c2.x)
                local n2 = math.max(c1.x, c2.x)
                for var = n1 + 1, n2 - 1, 1 do
                    local sprite = pWorldMap.floor:getTileAt(cc.p(var, c1.y))
                    if sprite then
                        me.clickAni(sprite)
                    end
                    local gid, _ = pWorldMap.floor:getTileGIDAt(cc.p(var, c1.y))

                    local newgid = getConnectedRoadByGird(gid)

                    pWorldMap.floor:setTileGID(newgid, cc.p(var, c1.y))
                end
            end
        end
    end
end
function WorldMapView:isWater(cp)
    local gid, _ = self.floor_water:getTileGIDAt(cp)
    print(gid)
    return gid
end
function WorldMapView:updateRoadState(msg)
    local data = msg.c.list
    local segments = { }
    if data then
        for key, var in pairs(data) do
            local fid = me.getFortIdByCoord(cc.p(var.x, var.y))
            local fdata = gameMap.fortDatas[fid]
            local fdis = cc.pGetDistance(user.majorCityCrood, cc.p(var.x, var.y))
            gameMap.fortDatas[fid].dis = fdis
            -- 因为是更新所以要把他的方向全部打开
            if fdata.occ == 1 then
                fdata:resetDirGroups()
            end
            for k, v in pairs(fdata.dirGroups) do
                local op = me.getCoordByFortId(fdata.id)
                -- 起始点
                local tp = cc.pAdd(op, cc.pMul(v, STEP_SEG))
                tp = cc.p(math.max(tp.x, 0), math.max(tp.y, 0))
                local cp = cc.pMul(cc.pAdd(op, tp), 0.5)
                local dis = cc.pGetDistance(user.majorCityCrood, cp)
                -- 下一个点
                local sid = me.converDualId(op, tp)
                -- 转换为线段ID
                local sdata = gameMap.lineSegmentDatas[sid]
                if not sdata then
                    sdata = segmentData.new(sid)
                    gameMap.lineSegmentDatas[sid] = sdata
                end
                sdata.dis = dis
                -- 排序用
                -- 构建线段
                gameMap.lineSegmentDatas[sid] = sdata

                -- if fdata.occ == 1 then
                -- 如果我当前要塞为已占领
                sdata.state = var.occ
                -- end
                segments[sid] = sdata
                local nid = me.getFortIdByCoord(tp)
                -- 下一个点的要塞ID
                local ndata = gameMap.fortDatas[nid]
                if ndata then
                    -- 下一个点要塞数据
                    ndata:removeDirGroups(v)
                end
                -- 剔除下一个点的。。。

            end
        end
    end
    local postdata = msg.c.post
    if postdata then
        local op = postdata[1]
        -- 起始点
        local tp = postdata[2]
        local cp = cc.pMul(cc.pAdd(op, tp), 0.5)
        local dis = cc.pGetDistance(user.majorCityCrood, cp)
        -- 下一个点
        local sid = me.converDualId(op, tp)
        -- 转换为线段ID
        local sdata = gameMap.lineSegmentDatas[sid]
        if not sdata then
            sdata = segmentData.new(sid)
            gameMap.lineSegmentDatas[sid] = sdata
        end
        sdata.state = 1
        sdata.dis = dis
        segments[sid] = sdata
        --  dump(gameMap.lineSegmentDatas)
    end
    self:openRoad(segments)
end
function WorldMapView:updateResUI()
    self.gold_label:setString(Scientific(user.gold))
    self.food_label:setString(Scientific(user.food))
    self.lumber_label:setString(Scientific(user.wood))
    self.stone_label:setString(Scientific(user.stone))
    self.paygem:setString(user.paygem)
    self.diamond_label:setString(user.diamond)
    self.farmer_label:setString(user.idlefarmer .. "/" .. user.maxfarmer)
    self.Text_idlefarmer:setString(user.idlefarmer)
    self.grade_label:setString(UserGrade())
    self.vip_label:setString(user.vip)
    me.assignWidget(self,"exp_loadbar"):setPercent(user.exp*100 / getNextExp(user.lv))
    me.assignWidget(self,"tili_loadbar"):setPercent((user.currentPower or 0 )*100/getUserMaxPower())   
    self.name_label:setString(user.name)
    self.level_label:setString(user.lv)
    local curTime = overlordView.Time["TIME_" .. getCenterBuildingTime()]
    local time = getCenterBuildingTime()
    self.age_times:setString(age_times_name[time])
    self.age:loadTexture(curTime.icon, me.localType)
    if user.head and user.head > 0 then
        local cfg = cfg[CfgType.ROLE_HEAD]
        self.age:loadTexture(cfg[user.head].icon .. ".png", me.localType)
    end
    if user.vipTime >= 0 then
        me.assignWidget(self, "icon_vip"):setVisible(true)        
        me.assignWidget(self, "vipgray_bg"):setVisible(user.vipTime == 0)
    end
    self.age:setVisible(true)
    me.assignWidget(self, "ulevel"):setVisible(true)
    me.assignWidget(self, "age_times"):setVisible(true)
    if self.queueNum then
        self.Text_Troop_lines:setString("可用行军队列:" ..(user.propertyValue["TroopsAdd"] - self.queueNum) .. "/" .. user.propertyValue["TroopsAdd"])
    else
        self.Text_Troop_lines:setString("可用行军队列:??/??")
    end
    me.assignWidget(self, "redpoint_vip"):setVisible(user.iget_free == false and user.vipTime > 0)
end
function WorldMapView:setSkillButtonPos()
    self.Button_heroSkill:setVisible(user.heroSkillStatus == true or user.heroSkillStatus == 1)
    --   self.Button_heroSkill:setPositionX(me.assignWidget(self, "fortBtn"):getPositionX() - me.assignWidget(self, "fortBtn"):getContentSize().width / 2)
    --    if user.heroSkillStatus == true or user.heroSkillStatus == 1 then
    --        self.Button_warning:setPosition(self.Button_heroSkill:getPositionX() - self.Button_heroSkill:getContentSize().width - 10, 7.5)
    --    else
    --        self.Button_warning:setPosition(self.Button_heroSkill:getPositionX(), 7.5)
    --    end
end
-- 推荐任务显示
function WorldMapView:showCommendTask()
    local taskData = commendTask()
    if user.commendTaskId == nil then
        if taskData ~= nil then
            user.commendTaskId = taskData.id
        end
    else
        if taskData.progress < 3 then
            taskData = user.taskList[user.commendTaskId]
        end
    end

    local commendUI = me.assignWidget(self, "commend")

    if taskData == nil then
        commendUI:setVisible(false)
    else
        commendUI.taskId = taskData.id
        commendUI:setVisible( user.taskCaphterDataTitle and user.taskCaphterDataTitle.nextId == 0 )
        local taskTitle = me.assignWidget(commendUI, "taskTitle")
        local str = string.gsub(taskData:getDef().gole, "&", "")
        local str = string.gsub(str, "<[^>]*>", "")
        taskTitle:setString(str)
        if taskData.progress > 2 then
            local taskCompleteFlag = me.assignWidget(commendUI, "taskCompleteFlag")
            taskCompleteFlag:setVisible(true)
            taskCompleteFlag:setPositionX(taskTitle:getPositionX() + taskTitle:getContentSize().width + 5)
            taskTitle:setTextColor(cc.c3b(0, 225, 42))
        else
            me.assignWidget(commendUI, "taskCompleteFlag"):setVisible(false)
            taskTitle:setTextColor(cc.c3b(255, 225, 255))
        end
    end
end
function WorldMapView:TaskRewardsTask(event)
    local taskData = event._userData
    local pGoodsData = cfg[CfgType.TASK_LIST][taskData["defid"]]["awardProps"]
    self.mTaskData = nil
    if pGoodsData ~= nil then
        if self.pTaskTime ~= nil then
            me.clearTimer(self.pTaskTime)
        end

        self.pReardsNum = table.maxn(pGoodsData)
        self.mGoodsData = { }
        self.pTaskNode = me.createNode("Node_rewards_bg.csb")
        for key, var in pairs(pGoodsData) do
            table.insert(self.mGoodsData, 1, var)
        end
        self.pTaskIndx = 1
        self:RewardsAnimation(self.pTaskNode, self.mGoodsData, self.pTaskIndx)
        self.pTaskIndx = self.pTaskIndx + 1
        if self.pReardsNum > 1 then
            self.pTaskTime = me.registTimer(-1, function(dt)
                self:RewardsAnimation(self.pTaskNode, self.mGoodsData, self.pTaskIndx)
                if self.pTaskIndx == self.pReardsNum then
                    me.clearTimer(self.pTaskTime)
                    self.pTaskTime = nil
                end
                self.pTaskIndx = self.pTaskIndx + 1
            end , 0.5)
        end
    end
end
function WorldMapView:clearnCells()
    me.tableClear(gameMap.mapCellDatas)
    for key, var in pairs(self.cellMoudels) do
        var:purge()
    end
    self.cellMoudels = { }
end
function WorldMapView:clearnNormalCells(num)
    if table.nums(self.cellMoudels) > me.toNum(num) then
        local tempCells = { }
        for key, var in pairs(self.cellMoudels) do
            local cdata = var:getCellData()
            if cdata.pointType == POINT_NORMAL then
                var:purge()
                coroutine.yield()
            else
                tempCells[key] = var
            end
        end
        self.cellMoudels = tempCells
    end
end
function WorldMapView:onExit()
    print("WorldMapView onExit")
    me.RemoveCustomEvent(self.uiRedPointListener)
    self:stopAllActions()
    mCloudAnimDone = false
    for key, var in pairs(self.troopsGroup) do
        var:purge()
    end
    self:clearnCells()
    me.clearTimer(self.pTime)
    me.clearTimer(self.troopTimer)
    me.clearTimer(self.pTroopLineTime)
    me.clearTimer(self.localtimeTimer)
    me.clearTimer(self.OpenThron)
    me.coroClear(self.schid)
    me.clearTimer(self.pTaskTime)
    me.clearTimer(self.updateNodeZorderTimer)
    me.RemoveCustomEvent(self.uiCompleteTaskListener)
    me.RemoveCustomEvent(self.fapChangedListener)
    me.RemoveCustomEvent(self.uiCommendTaskListener)
    me.RemoveCustomEvent(self.uiCompleteTaskListener)
    self.troopLine_Node:removeAllChildren()
    --  me.Helper:DirectorSetProjectionDefault()
    UserModel:removeLisener(self.modelkey)
    tmxMap = nil
    if self.globalItems then self.globalItems:release() end
end
function WorldMapView:RewardsAnimation(pNode, pData, pIndx)

    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end

    local var = pData[pIndx]
    local globalItems = me.createNode("Node_rewards_bg.csb")
    local pRewards = me.assignWidget(globalItems, "rewards_bg"):clone():setVisible(true)
    pRewards:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self:addChild(pRewards, me.ANIMATION)


    local pRewardsIcon = me.assignWidget(pRewards, "rewards_icon")
    pRewardsIcon:loadTexture(self:getTaskGoodsIcon(var[1]), me.plistType)
    local pRewardsNum = me.assignWidget(pRewards, "rewards_num")
    pRewardsNum:setString("×" .. Scientific(var[2]))


    local pMoveBy = cc.MoveBy:create(0.8, cc.p(0, 90))
    local pFadeOut = cc.FadeOut:create(0.8)
    local pFadeOut1 = cc.FadeOut:create(0.8)
    local pFadeOut2 = cc.FadeOut:create(0.8)
    local pSpawn = cc.Spawn:create(pMoveBy, pFadeOut)

    local callback = cc.CallFunc:create(arrive)
    pRewardsIcon:runAction(pFadeOut1)
    pRewardsNum:runAction(pFadeOut2)
    pRewards:runAction(cc.Sequence:create(pSpawn, callback))
end
function WorldMapView:getTaskGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_" .. pCfgData["icon"] .. ".png"
    return pIconStr
end

function WorldMapView:playBgMusic()
    mAudioMusic:setBackMusic(MUSIC_TYPE.MUSIC_BACK_MAP, true)
end
function WorldMapView:onEnterTransitionDidFinish()
    SharedDataStorageHelper():getMapPoint(user.uid)
    self:playBgMusic()
    self:initCellSign()
    self:initUser()
    self:initCell()
    self:cloudOpen( function(args)
        me.DelayRun( function()
            mCloudAnimDone = true
            guideHelper.nextStepByOpt(false, nil, nil)
        end , 0.5)
    end )
    switchButtons()
end
function WorldMapView:cloudClose(callfunc_)
    local cloudLayer = me.assignWidget(self, "Panel_Cloud")
    cloudLayer:setVisible(true)
    local cloud_left = me.assignWidget(cloudLayer, "cloud_left")
    local cloud_right = me.assignWidget(cloudLayer, "cloud_right")
    cloud_left:setPosition(cc.p(- cloud_left:getContentSize().width / 2, - cloud_left:getContentSize().height / 2))
    cloud_right:setPosition(cc.p(cloud_right:getContentSize().width * 3 / 2, cloud_left:getContentSize().height * 3 / 2))
    local t = 0.5
    local a1 = cc.MoveTo:create(t, cc.p(cloud_left:getContentSize().width / 2, cloud_left:getContentSize().height / 2))
    local a2 = cc.MoveTo:create(t, cc.p(cloud_right:getContentSize().width / 2, cloud_right:getContentSize().height / 2))
    local function call(node)
        callfunc_(node)
    end
    local a3 = cc.CallFunc:create(call)
    cloud_left:runAction(cc.Sequence:create(a1, a3))
    cloud_right:runAction(a2)
end
function WorldMapView:cloudOpen(callfunc)
    local cloudLayer = me.assignWidget(self, "Panel_Cloud")
    cloudLayer:setVisible(true)
    cloudLayer:setSwallowTouches(true)
    local cloud_left = me.assignWidget(cloudLayer, "cloud_left")
    local cloud_right = me.assignWidget(cloudLayer, "cloud_right")
    cloud_left:setPosition(cc.p(cloud_left:getContentSize().width / 2, cloud_left:getContentSize().height / 2))
    cloud_right:setPosition(cc.p(cloud_right:getContentSize().width / 2, cloud_left:getContentSize().height / 2))
    local t = 0.5
    local a1 = cc.MoveTo:create(t, cc.p(- cloud_left:getContentSize().width / 2, - cloud_left:getContentSize().height / 2))
    local a2 = cc.MoveTo:create(t, cc.p(cloud_right:getContentSize().width * 3 / 2, cloud_right:getContentSize().height * 3 / 2))
    local function call(node)
        callfunc(node)
        cloudLayer:setVisible(false)
    end
    local a3 = cc.CallFunc:create(call)
    cloud_left:runAction(cc.Sequence:create(a1, a3))
    cloud_right:runAction(a2)
end

-- 地图随机云
function WorldMapView:randCloud(cur)
    self.cloudBool = false
    local p1 = me.rand()
    local p2 = me.rand()
    --   self:getafterNum(p1,3)
    local cloud = ccui.ImageView:create("waicheng_yun_jiazai_2.png", me.localType)
    cloud:setOpacity(0)
    tmxMap:addChild(cloud)

    -- 计算云出现的位置
    local pRandX = self:getafterNum(p1, 1)
    local pRandY = self:getafterNum(p2, 1)

    if (pRandX % 2 == 0 and pRandY % 2 == 0) then
        pRandX = pRandX + 1
    end
    if (pRandX % 2 ~= 0 and pRandY % 2 ~= 0) then
        pRandY = pRandY + 1
    end
    local pNegtiveX = 1
    local pNegtiveY = 1
    local pTotalX = pRandX
    local pTotalY = pRandY
    local pTotal = math.sqrt(pTotalX * pTotalX + pTotalY * pTotalY)
    if pRandX % 2 == 0 then
        pNegtiveX = 1
    else
        pNegtiveX = -1
    end

    pRandX = math.floor(pRandX / 2) * pNegtiveX

    if pRandY % 2 == 0 then
        pNegtiveY = 1
    else
        pNegtiveY = -1
    end

    pRandY = math.floor(pRandY / 2) * pNegtiveY

    local pPoint = cc.p(cur.x + pRandX, cur.y + pRandY)
    local sp = me.convertToScreenCoord(tmxMap, pPoint)
    cloud:setPosition(sp)
    -- 计算云出现的动作
    local pOneTotalX = pTotalX * 0.8
    local pOneTotalY = pTotalY * 0.8
    local pOneTime = pTotal / 2 * 8 * 0.8
    local pOneMoveTo = cc.MoveTo:create(pOneTime, cc.p(me.convertToScreenCoord(tmxMap, cc.p(cur.x + pOneTotalX, cur.y + pOneTotalY))))

    local pFadeIn = cc.FadeIn:create(2)
    local pScale = cc.ScaleTo:create(pOneTime, 0.6)
    local pSpawn1 = cc.Spawn:create(pOneMoveTo, pFadeIn)

    -- cloud:runAction(cc.Sequence:create(pSpawn))

    -- 计算云消失
    local pTwoTotalX = pTotalX
    local pTwoTotalY = pTotalY
    local pTwoTime = pTotal / 2 * 8 * 0.2
    local pTwoMoveTo = cc.MoveTo:create(pTwoTime, cc.p(me.convertToScreenCoord(tmxMap, cc.p(cur.x + pTwoTotalX, cur.y + pTwoTotalY))))
    local pFTime = 2
    if pTwoTime > 2 then

    end

    local pFadeOut = cc.FadeOut:create(pTwoTime)
    local pSpawn2 = cc.Spawn:create(pTwoMoveTo, pFadeOut)

    local function arrive(node)
        node:removeFromParentAndCleanup(true)
        self.cloudBool = true
    end

    local callback = cc.CallFunc:create(arrive)
    cloud:runAction(cc.Sequence:create(pSpawn1, pSpawn2, callback))

end
-- 获取后三位随机数
function WorldMapView:getafterNum(pNum, p)
    local pLen = string.len(pNum)
    local pafterNum = string.sub(pNum, pLen -(p - 1))
    return pafterNum
end
-- 老鹰运动
function WorldMapView:eagMode(cur)
    local p1 = me.rand()
    local p2 = me.rand()
    local p3 = me.rand()
    local pRand = self:getafterNum(p1, 1)
    local pPlus = 1
    if pRand % 2 == 0 then
        pPlus = -1
    else
        pPlus = 1
    end

    local pRandX = self:getafterNum(p1, 1) + 1
    local pRandY = self:getafterNum(p2, 1) + 1
    if (pRandX % 2 == 0 and pRandY % 2 == 0) then
        pRandX = pRandX + 1
    end
    if (pRandX % 2 ~= 0 and pRandY % 2 ~= 0) then
        pRandY = pRandY + 1
    end
    self.pNegtiveX = 1
    self.pNegtiveY = 1
    self.mRandX = pRandX
    self.mRandY = pRandY
    local pTotalX = pRandX
    local pTotalY = pRandY
    local pTotal = math.sqrt(pTotalX * pTotalX + pTotalY * pTotalY)


    if pRandX % 2 == 0 then
        self.pNegtiveX = 1
    else
        self.pNegtiveX = -1
    end

    if pRandY % 2 == 0 then
        self.pNegtiveY = 1
    else
        self.pNegtiveY = -1
    end

    local pX, pY = self:getStart(pRandX, pRandY, 3, true)

    local pX1, pY1 = self:getStartMax(pX, pY)
    --  print("CCCCCCCCCCCCC"..pX1)
    --  print("DDDDDDDDDDDDDD"..pY1)
    pRandX = pX1 * self.pNegtiveX

    pRandY = pY1 * self.pNegtiveY
    --  print("CCCCCCCCCCCCC"..pRandX)
    -- print("DDDDDDDDDDDDDD"..pRandY)
    local pPoint = cc.p(cur.x + pRandX, cur.y + pRandY)

    local pEndX, pEndY = self:getStart(pRandX, pRandY, 8)
    self.mendPoint = cc.p(cur.x + pEndX * self.pNegtiveX *(pPlus), cur.y + pEndY * self.pNegtiveY *(pPlus))
    local function arrive(node)
        local pBool = self:setealge(node)
        if pBool == false then
            node:removeFromParentAndCleanup(true)
            self.ealge = true
        else

            local pEndX, pEndY = self:getStart(self.mRandX, self.mRandY, 8)
            self.mendPoint = cc.p(self.mendPoint.x + pEndX * self.pNegtiveX *(-1), self.mendPoint.y + pEndY * self.pNegtiveY *(-1))
            node:moveToPoint(me.convertToScreenCoord(tmxMap, self.mendPoint), arrive, "dh")
        end
    end

    local ealge = eagleModel:createAniWithShadow("ying_fx", "ying_fxy")
    tmxMap:addChild(ealge)
    local sp = me.convertToScreenCoord(tmxMap, pPoint)
    ealge:setPosition(sp)
    ealge:moveToPoint(me.convertToScreenCoord(tmxMap, self.mendPoint), arrive, "dh")
    --  dump(cur)
    --   dump(pPoint)
    --   dump(self.mendPoint)
end
function WorldMapView:getStart(pRandX, pRandY, pNum)
    local pMin = math.min(pRandX, pRandY)

    local pRange = pNum
    if pMin < pRange then
        if pRandX < pRange and pRandY > pRange then
            for var = 1, pRange do
                if pRandX * var > pRange then
                    return(pRandX * var),(pRandY * var)
                end
            end
        elseif pRandY < pRange and pRandX > pRange then
            for var = 1, pRange do
                if pRandY * var > pRange then
                    return(pRandX * var),(pRandY * var)
                end
            end
        else
            for var = 1, pRange do
                if pMin * var > pRange then
                    return(pRandX * var),(pRandY * var)
                end
            end
        end
    end
    return pRandX, pRandY
end
function WorldMapView:getStartMax(pRandX, pRandY)
    local pMax = math.max(pRandX, pRandY)
    local pMin = math.min(pRandX, pRandY)
    if pMin > 3 then
        if pMax > 4 then
            i = 3
            for var = 1, 3 do
                if (pMax / i) > 3 then
                    -- print("gggggggg"..pMax)
                    return(pRandX / i),(pRandY / i)
                end
                i = i - 1
            end
        end
    end
    return(pRandX),(pRandY)
end
-- 判断鹰是否在屏幕内
function WorldMapView:setealge(Node)
    local pUp = me.convertToScreenCoord(tmxMap, cc.p(self.mCur.x, self.mCur.y + 4))
    local pNext = me.convertToScreenCoord(tmxMap, cc.p(self.mCur.x, self.mCur.y - 4))
    local pLeft = me.convertToScreenCoord(tmxMap, cc.p(self.mCur.x - 4, self.mCur.y))
    local pRight = me.convertToScreenCoord(tmxMap, cc.p(self.mCur.x + 4, self.mCur.y))
    local pPoint = cc.p(Node:getPositionX(), Node:getPositionY())

    if me.toNum(pPoint.x) > me.toNum(pLeft.x) and me.toNum(pPoint.x) < me.toNum(pRight.x) then
        if me.toNum(pPoint.y) > me.toNum(pNext.y) and me.toNum(pPoint.y) < me.toNum(pUp.y) then

            return true
        end
    else
        return false
    end

end

-- 国王目标
function WorldMapView:TroopLine_KingTarget(msg)

end

-- 出征队列
function WorldMapView:TroopLine(msg, pBool)
    --    dump(user.uid)
    if pBool == true then
        -- 添加
        if user.uid == msg.c.uid then
            local tdata = gameMap.troopData[msg.c.id]
            mTroopLineData[msg.c.id] = tdata
        end
    else
        mTroopLineData[msg.c.id] = nil
    end
    local pTroopLineData = { }

    for key, var in pairs(mTroopLineData) do
        table.insert(pTroopLineData, 1, var)
    end

    if table.maxn(pTroopLineData) ~= 0 then
        self.queueNum = #pTroopLineData
        table.sort(pTroopLineData, function(a, b) return a.tm > b.tm end)
        self:TroopLineTable(pTroopLineData)
        if self.exped then
            self.exped:setQueueNum(self.queueNum)
        end
    else
        self.queueNum = 0
        self.troopLine_Node:removeAllChildren()
        self.tableView = nil
        self.tableOffSet = nil
        self.troopLine_Node:setContentSize(cc.size(1, 1))
        if self.exped then
            self.exped:setQueueNum(self.queueNum)
        end
    end
    if self.queueNum then
        self.Text_Troop_lines:setString("可用行军队列:" ..(user.propertyValue["TroopsAdd"] - self.queueNum) .. "/" .. user.propertyValue["TroopsAdd"])
    else
        self.Text_Troop_lines:setString("可用行军队列:??/??")
    end
end
function WorldMapView:TroopLineTable(pTroopLineData)
    local pBool = self.queueNum == self.iNum

    print("self.queueNum = " .. self.queueNum, " self.iNum = " .. self.iNum)
    self.tabledata = pTroopLineData
    self.iNum = #self.tabledata
    local pMax = math.min(self.iNum, 3)
    self.troopLine_Node:setContentSize(cc.size(250,(3 * 70 + 45)))
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pIdx = cell:getIdx() + 1
        local pData = self.tabledata[pIdx]
        if pData then
            local troopid = pData["m_TroopId"]
            if pData["m_Status"] == EXPED_STATE_ARCHING or pData["m_Status"] == EXPED_STATE_COLLECTING or pData["m_Status"] == EXPED_STATE_STATIONED or pData["m_Status"] == THRONE_DEFEND then
                local pPointX = pData["m_OriPoint"]["x"]
                local pPointY = pData["m_OriPoint"]["y"]
                self:lookMapAt(pPointX, pPointY, 0)
            elseif pData["m_Status"] == TEAM_ARMY_DEFENS_WAIT then
                local pPointX = pData["m_Paths"]["tag"]["x"]
                local pPointY = pData["m_Paths"]["tag"]["y"]
                self:lookMapAt(pPointX, pPointY, 0)
            else
                local pTroop = self.troopsGroup[troopid]
                if pTroop then
                    local pPoint = pTroop:getToopPosition()
                    local tiled_p = me.converScreenToTiledCoord(tmxMap, pPoint)
                    self:lookMapAt(tiled_p.x, tiled_p.y, 0)
                end
            end
        end
    end

    local function cellSizeForTable(table, idx)
        return 250, 70
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pTrooplineCell = trooplineCell:create(self.globalItems, "troopLineItem")
            pTrooplineCell:setAnchorPoint(cc.p(0, 0))
            pTrooplineCell:setPosition(cc.p(30, 0))
            pTrooplineCell:setData(self.tabledata[idx + 1], idx)
            cell:addChild(pTrooplineCell)
        else
            local pTrooplineCell = me.assignWidget(cell, "troopLineItem")
            pTrooplineCell:setData(self.tabledata[idx + 1], idx)
        end
        return cell
    end

    function numberOfCellsInTableView(table)

        return self.iNum
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(259,(3 * 70 + 45)))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setAnchorPoint(0, 0)
        self.tableView:setPosition(0, 0)
        self.tableView:setDelegate()
        self.troopLine_Node:addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    else
        self.tableOffSet = self.tableView:getContentOffset()
    end
    self.tableView:reloadData()
    if self.tableOffSet and pBool then
        self.tableView:setContentOffset(self.tableOffSet)
    end
    self.troopLine_Node:setSwallowTouches(true)
end
function WorldMapView:setDownTime()
    self.pTroopLineTime = me.registTimer(-1, function(dt)
        if table.maxn(mTroopLineData) ~= 0 then
            for key, var in pairs(mTroopLineData) do
                local pTime = var["countdown"]
                var["countdown"] = pTime - 1
            end
        end
    end , 1)
end
-- 收到聊天内容
function WorldMapView:popNewMsg(msg)
--    self.Text_chat:stopAllActions()
--    self.Text_chat:setVisible(true)
--    self.Text_chat:setOpacity(255)
--    self.Text_chat:enableOutline(cc.c3b(0, 0, 0), 2)
--    local str = rebuildChatString(msg.c.content, msg.c.noticeId)
--    if msg.c.noticeId then
--        str = string.gsub(str, "&", "")
--        str = string.gsub(str, "(<)(.-)(>)", "")
--    end
--    self.Text_chat:setString(str)
--    local del = cc.DelayTime:create(5)
--    local fo = cc.FadeOut:create(3)
--    local call = cc.CallFunc:create( function()
--        self.Text_chat:setVisible(false)
--    end )
--    local seq = cc.Sequence:create(del, fo, call)
--    self.Text_chat:runAction(seq)
end
-- 胜利
function WorldMapView:VictoryAnimation()
    local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
    pCityCommon:CommonSpecific(ALL_COMMON_VICTORY)
    pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
    self:addChild(pCityCommon, me.MAXZORDER)
end
-- 失败
function WorldMapView:FailAnimation()
    --[[
    local pCityFail = allAnimation:createAnimation("ui_battle_defeat")
    pCityFail:FailMapAniamtion()
    pCityFail:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self:addChild(pCityFail, me.MAXZORDER)
	]]
    local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
    pCityCommon:CommonSpecific(ALL_COMMON_FAILURE)
    pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
    self:addChild(pCityCommon, me.MAXZORDER)
end

function WorldMapView:updateLordName()
    self.name_label:setString(user.name)
    local lordData = gameMap.overLordDatas[user.uid]
    if lordData then
        lordData.name = user.name
    end
    if self.myCityCellId then
        local cityCell = self.cellMoudels[self.myCityCellId]
        if cityCell then
            cityCell:initObj()
            local CellName = self.cellNameMoudels[self.myCityCellId]
            if CellName then
                local point = cc.p(CellName:getPositionX(), CellName:getPositionY())
                CellName:removeFromParentAndCleanup(true)
                local pCellName = cityCell:initName()
                pCellName:setVisible(true)
                pCellName:setPosition(point)
                self.unitNameLayer:addChild(pCellName)
                self.cellNameMoudels[self.myCityCellId] = pCellName
            end
        end

    end
end

function WorldMapView:showVipView()
    local vipview = vipView:create("vipView.csb")
    me.runningScene():addChild(vipview, me.MAXZORDER)
    me.showLayer(vipview, "bg")
end