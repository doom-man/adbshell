-- jnmogod
cityView = class("cityView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
cityView.__index = cityView
function cityView:create(csb, b)
    cityView.cloudOpenDone = false
    local layer = cityView.new(csb)
    layer.haveData = b
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
SOLDIER_SHOW_NUM = 20
function cityView:ctor()
    mAudioMusic:setBackMusic(MUSIC_TYPE.MUSIC_BACK_CITY, true)
    print("cityView  ctor")
    self.bshopBox = nil
    -- mainCity唯一的商城界面实例
    self.bLevelUpLayer = nil
    -- mainCity唯一的升级界面实例
    self.maplayer = nil
    -- 所有地基集合
    self.groundworks = nil
    -- 当前要建造的地基
    self.curGwork = nil
    -- 所有建筑  显示层
    self.buildingMoudles = { }
    -- 所有资源显示
    self.resMoudles = nil
    self.bInited_Building = false
    self.farmerMoudles = nil
    -- 军队
    self.armyMoudles = nil
    -- 城内军队显示队列
    self.armyShowQueues = { }
    self.armyShowQueues[1] = Queue.new()
    self.armyShowQueues[2] = Queue.new()
    self.armyShowQueues[3] = Queue.new()
    self.armyShowQueues[4] = Queue.new()
    -- 巡逻队
    self.PatrolMoudles = nil

    self.crowds = nil
    -- 当前最大农民数用于 增加农民MOUDLE
    self.curMaxFarmer = 0
    -- 士兵巡逻路径
    self.soldierPath_ = { }

    -- 待机的农民
    self.standbyFarmers = { }
    self.floor = nil
    self.floor_food = nil

    m_optMenu = nil

    self.allianceInfor = false
    -- 联盟界面

    self.mRankView = nil
    -- 排行榜
    self.resMoudleBool = true
    -- 初始化主城 采集点

    self.ActionKind = 0
    -- 1： 建筑物 2：采集点

    self.ActionIndex = 0
    -- 收获的ID

    self.foodNum = { }
    -- 记录每个的材料的数据  1：粮食 2：木材 3：石头 4：金币

    self.marketToftId = nil
    -- 记录市场的id

    self.stoneBuildingToftId = { }

    self.foodBuildingToftId = { }

    self.woodBuildingToftId = { }

    self.woodPointTable = { }

    self.farmerPath = { }

    self.taskAmintion = false
    -- 初始化任务，没有特效

    self.timesAmination = 0
    -- 封建时代

    self.allianceExitview = nil

    -- 信息
    self.InforOpen = false

    if user.packageData then
        self.packageDidInit = true
    else
        self.packageDidInit = false
    end
    self.pTaskTime = nil

    self.allot = nil
    -- 分配界面的对象

    self.mTaskData = nil

    self.pRecomond = nil
end
function cityView:init()
    print("cityView  init")
    self.maplayer = mapLayer:create("mapLayer.csb")
    self:addChild(self.maplayer, -1)
    self.maplayer.mNode:setPosition(cc.p(-524, -1072))
    self.ui_bar = me.assignWidget(self, "ui_bar")
    --  self.ui_bar:setLocalZOrder(me.MAXZORDER + 100)
    self.skyLayer = me.assignWidget(self.maplayer, "sky")
    self:initGroundworks()
    self.floor = me.assignWidget(self.maplayer, "floor")
    local ffood = me.assignWidget(self.floor, "floor_food")
    self.floor_food = cc.p(ffood:getPositionX(), ffood:getPositionY())
    --  local res_panel = me.assignWidget(self,"res_panel")
    --  res_panel:setLocalZOrder(me.MAXZORDER+100)
    self.gold_label = me.assignWidget(self, "gold")
    self.paygem = me.assignWidget(self, "paygem")
    self.food_label = me.assignWidget(self, "food")
    self.level_label = me.assignWidget(self, "ulevel")
    self.lumber_label = me.assignWidget(self, "lumber")
    self.stone_label = me.assignWidget(self, "stone")
    self.diamond_label = me.assignWidget(self, "diamond")
    self.farmer_label = me.assignWidget(self, "farmer")
    self.daodao_1 = me.assignWidget(self, "daodao_1")
    self.grade_label = me.assignWidget(self, "grade")
    self.vip_label = me.assignWidget(self, "vip")
    
    self.name_label = me.assignWidget(self, "uname")
    self.icon_gold = me.assignWidget(self, "icon_gold")
    self.age = me.assignWidget(self, "age_icon")
    self.age:ignoreContentAdaptWithSize(true)
    self.battleBtn = me.assignWidget(self, "battleBtn")
    self.Text_crood = me.assignWidget(self.battleBtn, "coord")
    self.Button_warning = me.assignWidget(self, "Button_warning")
    self.promotionBtn = me.assignWidget(self, "promotionBtn")
    self.rank_Btn = me.assignWidget(self, "rank_Btn")
    self.elevenBtn = me.assignWidget(self, "elevenBtn")    
    self.Node_chat = me.assignWidget(self, "Node_chat")
    require("app/cityViewChatBox"):create(self, "Node_chat")

    --    self.Panel_chatBoard = me.assignWidget(self, "Panel_chatBoard")
    --    self.Panel_chatBoard:setVisible(true)
    self.bathNode = cc.SpriteBatchNode:create("img_path0.png", 2048)
    self.floor:addChild(self.bathNode)
    self.Button_heroSkill = me.assignWidget(self, "Button_heroSkill")
    self.Panel_heroSkill = nil
    self.Panel_touchHeroSkill = me.assignWidget(self, "Panel_touchHeroSkill")
    self.Panel_touchHeroSkill:setSwallowTouches(false)
    self.Button_warning:setVisible(#user.warningList > 0)
    self.localTime = me.assignWidget(self.Node_chat, "Text_chatTime")
    self.Panel_HongBao = me.assignWidget(self, "Panel_HongBao")
    self.Image_hongbao_bg = me.assignWidget(self, "Image_hongbao_bg")
    self.hongbao_btn = me.assignWidget(self, "hongbao_btn")
    self.Cross_throne = me.assignWidget(self, "Cross_throne")
    self.Button_achievement = me.assignWidget(self, "Button_achievement")
    self.age_times = me.assignWidget(self, "age_times")
    me.registGuiClickEvent(self.Button_achievement, function()
        NetMan:send(_MSG.achievenment_init())
    end )
    me.Helper:grayImageView(me.assignWidget(self, "vipgray_bg"))
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
            self:addChild(promotionView, me.MAXZORDER)
            me.showLayer(promotionView, "bg_frame")
            buildingOptMenuLayer:getInstance():clearnButton()
        end
    end
    self.act_btn_firstpay = me.registGuiClickEventByName(self, "act_btn_firstpay", function(rev)
        local promotionView = promotionView:create("promotionView.csb")
        promotionView:setViewTypeID(1)
        promotionView:setTaskGuideIndex(1)
        self:addChild(promotionView, me.MAXZORDER)
        me.showLayer(promotionView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    for key, var in pairs(act_btn_list) do
        local btn = me.registGuiClickEventByName(self, "act_btn_" .. var, act_callback)
        btn.idx = var
    end
    self.netbattleBtn_gift = me.registGuiClickEventByName(self, "netbattleBtn_gift", function(node)

    end )
    self.netbattleBtn_rank = me.registGuiClickEventByName(self, "netbattleBtn_rank", function(node)

    end )
    self.taskCaphterBtn = me.registGuiClickEventByName(self, "taskCaphterBtn", function(node)
        local caphter = taskCaphterLayer:create("Layer_TaskChapter.csb")
        self:addChild(caphter, me.MAXZORDER)
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    me.registGuiClickEventByName(self, "Image_TaskCaphter_process", function(node)
        buildingOptMenuLayer:getInstance():clearnButton()
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

    self.serverTaskBtn = me.registGuiClickEventByName(self, "serverTaskBtn", function(node)
        self.serverTaskBtn:getChildByName("ArmatureNode_Panel"):setVisible(false)
        NetMan:send(_MSG.world_task_name_list())
        local servetask = serverTaskLayer:create("serverTask.csb")
        me.popLayer(servetask)
    end )
    -- 光圈，用于成长之路开启提示
    local tempSize = self.serverTaskBtn:getContentSize()
    local subNode = createArmature("i_button_activit_1")
    subNode:setPosition(cc.p(tempSize.width / 2 + 0, tempSize.height / 2 - 4))
    self.serverTaskBtn:addChild(subNode)
    subNode:setName("ArmatureNode_Panel")
    subNode:setVisible(false)
    subNode:getAnimation():play("i_button_activity")
    subNode:setScale(0.5)

    self.netbattleBtn_gift:setVisible(false)
    self.netbattleBtn_gift:setVisible(false)
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
        switchHongBaoAnim(self.Panel_HongBao, false)
        toRechageShop()
    end )
    me.assignWidget(self, "rune_Btn"):setVisible(false)
    me.assignWidget(self, "Image_miniMap"):setVisible(false)
    me.assignWidget(self, "task_hint_bg"):setVisible(false)

    me.registGuiClickEvent(self.Button_heroSkill, function(node)
        NetMan:send(_MSG.worldSkillList())
    end )
    me.registGuiClickEventByName(self, "uname", function(node)
        self.lordView = overlordView:create("overlordView.csb")
        self:addChild(self.lordView, me.MAXZORDER)
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    self.relicBtn = me.registGuiClickEventByName(self, "relicBtn", function(node)
        local runeAltar = runeAltarView:create("rune/runeAltarView.csb", 1, 1)
        mainCity:addChild(runeAltar, me.MAXZORDER)
        me.showLayer(runeAltar, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    me.registGuiTouchEvent(self.Panel_touchHeroSkill, function(node, event)
        self:closeHeroSkillAnim()
    end )
    --        me.registGuiClickEvent(self.Cross_throne_out,function (node)
    --         me.showMessageDialog("是否退出跨服活动", function(args)
    --        if args == "ok" then
    --           GMan():send(_MSG.Cross_Sever_onExit())
    --        end
    --       end )
    --    end)
    me.registGuiClickEvent(self.Button_warning, function(node)
        local warning = warningView:create("warningView.csb")
        warning:setInCityStatus(true)
        self:addChild(warning, me.MAXZORDER)
        me.showLayer(warning, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    me.registGuiClickEvent(self.icon_gold, function(node)
        cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
    end )
    me.assignWidget(self, "fixLayout"):setSwallowTouches(false)
    self.allotBtn = me.assignWidget(self, "icon_farmer")
    me.registGuiClickEvent(self.allotBtn, function(node)
        self.allot = allotLayer:create("allotLayer.csb")
        self:addChild(self.allot, me.MAXZORDER)
        me.showLayer(self.allot, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )

    local function getRecourceView(typeKey_)
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(typeKey_)
        mainCity:addChild(tmpView, self:getLocalZOrder())
        me.showLayer(tmpView, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
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
        if buildingOptMenuLayer:getInstance() then
            buildingOptMenuLayer:getInstance():clearnButton()
        end
        toRechageShop()
    end )
    me.registGuiClickEventByName(self, "rechargeBtn_0", function(node)
        if buildingOptMenuLayer:getInstance() then
            buildingOptMenuLayer:getInstance():clearnButton()
        end
        toExpchageShop()
    end )
    me.registGuiClickEventByName(self, "allotBtn_gem", function(node)
        if buildingOptMenuLayer:getInstance() then
            buildingOptMenuLayer:getInstance():clearnButton()
        end
        toExpchageShop()
    end )
    self.idle_farmer_label = me.assignWidget(self, "idle_farmer_label")
    self.idle_farmer_label:setVisible(false)
    self.Text_idlefarmer = me.assignWidget(self, "idlefarmer")
    self.buildBtn = me.assignWidget(self, "buildBtn")
    me.registGuiTouchEventByName(self, "buildBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.bshopBox = buildShopView:create("buildShopLayer.csb")
        self:addChild(self.bshopBox, me.MAXZORDER);
        -- me.showLayer(self.bshopBox, "shopbg")
        buildingOptMenuLayer:getInstance():clearnButton()
        SharedDataStorageHelper():setNewBuildingPage(0, 0)
        self:setNewBuildingTypeOpen()
    end )
    -- 背包
    me.registGuiTouchEventByName(self, "bagBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.backpack = BackpackView:create("backpack/backpackdialog.csb")
        self:addChild(self.backpack, me.MAXZORDER);
        me.showLayer(self.backpack, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()

        --       local kmv = kingdomMainView:create("kingdomMainView.csb")
        --                self:addChild(kmv,me.MAXZORDER)
        --                me.showLayer(kmv,"fixLayout")
        --  GMan():send(_MSG.Cross_Sever_onExit())

    end )
    -- 跨服战
    me.registGuiTouchEventByName(self, "Cross_throne", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        NetMan:send(_MSG.Cross_Promotion_List())
        local netBattleEnterLayer = netBattleEnterLayer:create("netBattleEnterLayer.csb")
        me.popLayer(netBattleEnterLayer)
    end )
    me.registGuiClickEvent(self.battleBtn, function(node)
        me.assignWidget(node, "ArmatureNode_Panel"):setVisible(false)
        buildingOptMenuLayer:getInstance():clearnButton()
        node:setTouchEnabled(false)
        if user.Cross_Sever_Status == mCross_Sever_Out then
            self:cloudClose( function(node)
                local loadlayer = loadWorldMap:create("loadScene.csb")
                me.runScene(loadlayer)
            end )
        else
            if n_netWorkManager and netBattleMan:netBattleOpen() then
                self:cloudClose( function(node)
                    local loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                    me.runScene(loadlayer)
                end )
            else
                NetMan:send(_MSG.getNetBattleDataMsg())
            end
        end
    end )
    -- 领主信息
    me.registGuiTouchEventByName(self, "userInfoBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.lordView = overlordView:create("overlordView.csb")
        self:addChild(self.lordView, me.MAXZORDER)
        buildingOptMenuLayer:getInstance():clearnButton()
    end )

    -- 考古
    self.Button_Arch = me.assignWidget(self, "Button_Arch")

    me.registGuiClickEventByName(self, "Button_Arch", function(node)
        --[[
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
                        pCityCommon:CommonSpecific(ALL_COMMON_TASK)
                        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 100))
                        me.runningScene():addChild(pCityCommon, me.ANIMATION)
]]

        me.assignWidget(self.Button_Arch, "ArmatureNode_Panel"):setVisible(false)
        self.archbool = false
        self.pBookMewnu = cfg[CfgType.BOOKMENU]
        self.BookMenuId = mAppBookMenuId
        NetMan:send(_MSG.initBook(self.BookMenuId))
        showWaitLayer()
    end )
    -- 充值活动界面
    self.payBtn = me.registGuiTouchEventByName(self, "payBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.promotionView = promotionView:create("paymentView.csb")
        self.promotionView:setViewTypeID(99)
        self:addChild(self.promotionView, me.MAXZORDER);
        me.showLayer(self.promotionView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    me.registGuiTouchEventByName(self, "Button_Shop", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.promotionView = promotionView:create("paymentView.csb")
        self.promotionView:setViewTypeID(2)
        self:addChild(self.promotionView, me.MAXZORDER);
        me.showLayer(self.promotionView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )

    -- 活动
    me.registGuiTouchEventByName(self, "promotionBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.promotionView = promotionView:create("promotionView.csb")
        self.promotionView:setViewTypeID(1)
        self:addChild(self.promotionView, me.MAXZORDER);
        me.showLayer(self.promotionView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    me.registGuiClickEventByName(self, "Button_Troop", function(node)
        -- NetMan:send(_MSG.armyinfo())
        me.setWidgetCanTouchDelay(node, 1)
        local cstate = roleBuffLayer:create("cityStateView.csb")
        me.popLayer(cstate, "bg_frame")
    end )
    -- 双十一活动按钮
    me.registGuiClickEventByName(self, "elevenBtn", function()
        --  NetMan:send(_MSG.initElevenShop())
        NetMan:send(_MSG.initShop(ELEVENSHOP))

    end )

    -- 邮件
    self.mailBtn = me.registGuiTouchEventByName(self, "mailBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.mailview = mailview:create("mail/mailview.csb")
        self:addChild(self.mailview, me.MAXZORDER);
        me.showLayer(self.mailview, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
        me.assignWidget(self, "mail_red_hint"):setVisible(false)
        mMailRead = false
    end )
    self.taskBtn = me.registGuiTouchEventByName(self, "taskBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        if mainCity.taskview then
            mainCity.taskview:removeFromParent()
        end

        mainCity.taskview = TaskView:create("task/taskview.csb")
        self:addChild(mainCity.taskview, me.MAXZORDER);
        me.showLayer(mainCity.taskview, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()

    end )
    me.registGuiClickEventByName(self, "commend", function(node)
        if mainCity.taskview then
            mainCity.taskview:removeFromParent()
        end

        local pData = user.taskList[node.taskId]
        if pData.progress >= 3 then
            -- 完成任务直接领取
            NetMan:send(_MSG.completedTask(node.taskId))
            self:setTaskData(pData)
        else
            buildingOptMenuLayer:getInstance():clearnButton()
            TaskHelper.taskJump(pData)
        end
    end )
    -- 联盟
    me.registGuiTouchEventByName(self, "guildBtn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        jumpToAlliancecreateView()
    end )
    me.registGuiClickEventByName(self, "chat_area", function(node)
        local chatView = weChatView:create("chatView.csb")
        me.runningScene():addChild(chatView, me.MAXZORDER);
        --me.showLayer(chatView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )

    -- 聊天按钮
    me.registGuiClickEventByName(self, "Button_weChat", function(node, event)
        local chatView = weChatView:create("chatView.csb")
        me.runningScene():addChild(chatView, me.MAXZORDER);
        me.showLayer(chatView, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
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
        -- 获取邮件
        showWaitLayer()
    end )
    -- 推广
    me.registGuiTouchEventByName(self, "popularize_Btn", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        NetMan:send(_MSG.Popularize_Info_Data())
    end )
    local function gm_cmd_callback(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then


        elseif eventType == ccui.TextFiledEventType.detach_with_ime then


        elseif eventType == ccui.TextFiledEventType.insert_text then
            self.gm_cmd_text = sender:getString()
        elseif eventType == ccui.TextFiledEventType.delete_backward then
            self.gm_cmd_text = sender:getString()
        end
    end
    me.registGuiClickEventByName(self, "rechargeBtn", function(node)
        if buildingOptMenuLayer:getInstance() then
            buildingOptMenuLayer:getInstance():clearnButton()
        end
        toRechageShop()
    end )

    -- 士兵详情点击事件
    for i = 1, 4 do
        local gui = "soldierInfoBtn" .. i
        me.registGuiClickEventByName(self, gui, function(node)
            -- 引导前期不响应
            if getCenterBuildingLevel()>5 then
                NetMan:send(_MSG.armyinfo())
                me.setWidgetCanTouchDelay(node, 1)
            end
        end )
    end
    me.registGuiClickEventByName(self, "Image_army", function(node)
        NetMan:send(_MSG.armyinfo())
        me.setWidgetCanTouchDelay(node, 1)
    end )
    -- 工人集结点点击事件
    me.registGuiClickEventByName(self, "soldierInfoBtn5", function(node)
        self.allot = allotLayer:create("allotLayer.csb")
        self.allot:initialize()
        mainCity:addChild(self.allot, me.MAXZORDER)
        me.showLayer(self.allot, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    end )

    me.assignWidget(self, "fortBtn"):setVisible(false)
    self:fishAni()
    -- 鱼的动画
    self:updataSleep()
    --   self:showIdleFarmerNumAction()
    self.unlockPrompt = me.assignWidget(self, "unlockPrompt")
    me.registGuiClickEventByName(self.unlockPrompt, "unlockIcon", function(node)
        local unlock = unlockPrompt:create("unlockPrompt.csb")
        me.runningScene():addChild(unlock, me.MAXZORDER)
        me.showLayer(unlock, "bg")
        unlock:setUnlockId(self.unlockPrompt.unlockId)
        buildingOptMenuLayer:getInstance():clearnButton()
    end )
    self.unlockPrompt:setVisible(false)
    me.registGuiClickEventByName(self, "Image_vip_g", function(node)
        self:showVipView()
    end )

    self:setMailTask()
    self:archHint()
    -- 邮件提示
    if mMailRead then
        me.assignWidget(self, "mail_red_hint"):setVisible(true)
    end
    self:CitySceneAmination()
    CUR_GAME_STATE = GAME_STATE_CITY
    mFirstWorld = 0
    -- 保护
    self.ProtectedIcon = me.registGuiClickEventByName(self, "icon_protected", function(node)
        me.assignWidget(self, "img_tips"):setVisible(true)
        self.pal_protected:setTouchEnabled(true)
    end )

    self.pal_protected = me.registGuiTouchEventByName(self, "pal_protected", function(node, event)
        if event == ccui.TouchEventType.began then
            local img = me.assignWidget(self, "img_tips")
            if img:isVisible() then
                img:setVisible(false)
                self.pal_protected:setTouchEnabled(false)
            end
        end
    end )
    self.pal_protected:setTouchEnabled(false)
    self.age:setVisible(false)
    me.assignWidget(self, "img_tips"):setVisible(false)
    self:updateProected()
    self:setAllianceHint()
    self:WarshipMaplayer()
    self.buildOverview = buildOverview:create("buildOverview.csb")
    self.buildOverview:setPositionY(me.winSize.height / 2 - 198)
    me.assignWidget(self, "btnPanel"):addChild(self.buildOverview)
    me.assignWidget(self, "Image_TroopLine_Bg"):setVisible(false)

    -- 考古道具小红点
    self.img_red_dot_equip = me.assignWidget(self, "img_red_dot_equip")
    self.img_red_dot_equip:setVisible(false)
    self:calArchEquipHeroRedDot()

    return true
end

-- 计算考古道具小红点
function cityView:calArchEquipHeroRedDot()
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

function cityView:closeHeroSkillAnim()
    if self.Panel_heroSkill ~= nil then
        self.Panel_heroSkill:closeHeroSkillAnim()
    end
end
function cityView:openHeroSkillAnim()
    buildingOptMenuLayer:getInstance():clearnButton()
    if self.Panel_heroSkill == nil then
        self.Panel_heroSkill = fortHeroSkillPanel:create("Layer_HeroSkillsPanel.csb")
        self.Panel_heroSkill:setPosition(cc.p(me.winSize.width / 2, 0))
        self.Panel_heroSkill:setAnchorPoint(cc.p(0.5, 0))
        self.Panel_touchHeroSkill:addChild(self.Panel_heroSkill)
        me.DelayRun( function()
            self.Panel_heroSkill:openHeroSkillAnim()
        end )
    end
end
function cityView:showFire()
    for var = 1, 11 do
        local fire = me.assignWidget(self, "fire" .. var)
        fire:setVisible(user.showfire or false)
        me.DelayRun( function(args)
            fire:getAnimation():playWithIndex(0)
        end , var)
    end
end
function cityView:CitySceneAmination()
    local pSceneId = seasonId
    -- 4 冬天
    local pFramSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    if pSceneId == 4 then
        me.assignWidget(self, "Particle_Snow"):setVisible(true)
    elseif pSceneId == 3 then
        -- 秋天
        local pCityAutumn = allAnimation:createAnimation("scene_city_season_3_3")
        pCityAutumn:cityAutumn()
        pCityAutumn:setPosition(cc.p(self:getContentSize().width / 2 + 70, self:getContentSize().height - 70))
        self:addChild(pCityAutumn)
    elseif pSceneId == 2 then
        -- 春天
        --        local pCityCloud = allAnimation:createAnimation("scene_city_season_2_2")
        --        pCityCloud:CityCloud()
        --        pCityCloud:setPosition(cc.p(self:getContentSize().width / 2 + 150 * me.assignWidget(self, "ui_bar"):getScaleX(), -20 * self:getScale()))
        --        me.assignWidget(self, "ui_bar"):addChild(pCityCloud, -1)
        local pCityRain = allAnimation:createAnimation("scene_city_season_2-3")
        pCityRain:CitySummer()
        pCityRain:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
        self:addChild(pCityRain, -1)
    elseif pSceneId == 1 then
        -- 夏天
        me.assignWidget(self, "Particle_Rain"):setVisible(true)
    end

end
function cityView:archHint()
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
-- 建筑按钮新开启提示
function cityView:setNewBuildingTypeOpen()
    if self.buildBtn then
        local status = SharedDataStorageHelper():getNewBuildingPage(0)
        me.assignWidget(mainCity.buildBtn, "newBuilding_red_hint"):setVisible(false)
        if status == 1 then
            me.assignWidget(mainCity.buildBtn, "newBuilding_red_hint"):setVisible(true)
        end
    end
end
function cityView:CommonAnimation(pStr)
    local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
    pCityCommon:CommonSpecific(pStr)
    pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
    me.runningScene():addChild(pCityCommon, me.ANIMATION)
    return pCityCommon
end
function cityView:updateCroodText()
    if user.majorCityCrood.x == 0 and user.majorCityCrood.y == 0 then
        self.Text_crood:setString("(" .. "-" .. "," .. "-" .. ")")
    else
        self.Text_crood:setString("(" .. user.majorCityCrood.x .. "," .. user.majorCityCrood.y .. ")")
    end

end
-- function cityView:showIdleFarmerNumAction()
--    self.idle_farmer_label:runAction(cc.FadeOut:create(0))
--    local a1 = cc.FadeIn:create(0.5)
--    local a2 = cc.DelayTime:create(5)
--    local a3 = cc.FadeOut:create(0.5)
--    local a4 = cc.DelayTime:create(5)

--    local seq1 = cc.Sequence:create(a1, a2, a3, a4)
--    local rept = cc.RepeatForever:create(seq1)
--    self.farmer_label:runAction(rept)
--    local b1 = cc.DelayTime:create(5)
--    local b2 = cc.FadeIn:create(0.5)
--    local b3 = cc.DelayTime:create(5)
--    local b4 = cc.FadeOut:create(0.5)

--    local seq2 = cc.Sequence:create(b1, b2, b3, b4)
--    local rept1 = cc.RepeatForever:create(seq2)
--    self.idle_farmer_label:runAction(rept1)

-- end
function cityView:onEnterTransitionDidFinish()
    print("cityView:onEnterTransitionDidFinish()")
end
function cityView:updateLocalTime()
    self.localtimeTimer = me.registTimer(-1, function(dt)
        if self.localTime then
            self.localTime:setString(me.formartServerTime(me.sysTime() / 1000))
        end
    end , 1)
end
function cityView:updateActBtnTimes(dt)
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
function cityView:onEnter()
    print("cityView  onEnter")
    me.doLayout(self, me.winSize)
    me.doLayout(self.Panel_touchHeroSkill, me.winSize)
    me.doLayout(me.assignWidget(self, "btnPanel"), me.winSize)
    me.doLayout(me.assignWidget(self, "Panel_HongBao"), me.winSize)

    self.modelkey = UserModel:registerLisener( function(msg)
        self:updateMsg(msg)
    end )
    local function updateTimer(dt)
        self:updateNodeZorder()
        --     self:updateFarmerBehavior(dt)
        self:updateActBtnTimes(dt)
    end
    self:updateLocalTime()
    self.updateNodeZorderTimer = me.registTimer(-1, updateTimer, 1)
    buildingOptMenuLayer:getInstance()
    -- UserModel:familyCenterHelp()
    -- 时间到通知
    self.sailTimeOverListener = me.RegistCustomEvent("sailTimeOver", function(event)
        self:WarshipMaplayer()
    end )

    -- 活动等UI红点显示
    self.uiRedPointListener = me.RegistCustomEvent("UI_RED_POINT", handler(self, self.updateUIRedPoint))
    self:updateUIRedPoint()

    -- 成就按钮的红点记录
    local num = SharedDataStorageHelper():getAchievementRedPoint()
    if me.isValidStr(num) then
        me.assignWidget(self.Button_achievement, "hongbao_red_hint"):setVisible(me.toNum(num) == 1)
    end
    if guideHelper.getGuideIndex() ~= guideHelper.guide_End then
        guideHelper.showWaitLayer()
    end
    self.bShowNetInterrupt = false

    -- 推荐任务显示
    self.uiCommendTaskListener = me.RegistCustomEvent("UI_COMMEND_TASK", handler(self, self.showCommendTask))
    self.uiCompleteTaskListener = me.RegistCustomEvent("UI_TASK_COMPLETE", handler(self, self.TaskRewardsTask))

    -- 战力提升
    self.fapChangedListener = me.RegistCustomEvent("Fap_Changed", handler(self, self.fapChanged))

    -- 成就UI红点显示
    self.cjRedPointListener = me.RegistCustomEvent("Achievenment_Redpoint", handler(self, self.updateAchievenmentRedPoint))
    self:updateAchievenmentRedPoint()
    me.assignWidget(self, "redpoint_vip"):setVisible(user.iget_free == false and user.vipTime > 0)
    if user.activity_buttons_show[18] then
        self:showActivityShip()
    else
        self:hideActivityShip()
    end
    if user.activity_buttons_down_show[1] then
        self.act_btn_firstpay:setVisible(guideHelper.getGuideIndex()>23)
    else
        self.act_btn_firstpay:setVisible(false)
    end
    --self:unlockFunc()
    self:updateTasskCaphter()  
    self.taskBtn:setVisible(user.newBtnIDs[me.toStr(OpenButtonID_TaskBtn)]~=nil)
end
function cityView:updateTasskCaphter()
    local pro = me.assignWidget(self, "Text_taskCaphter_process")
    if user.taskCaphterDataTitle then
        if user.taskCaphterDataTitle.status ~= 3 then
            me.assignWidget(self, "Image_taskCaphter_bg"):setVisible(true)
            me.assignWidget(self, "Image_TaskCaphter_process"):setVisible(true)
            me.assignWidget(self, "Image_caphter_complete"):setVisible(user.taskCaphterDataTitle.status == 2)
            local data = getCurTaskCaphter()
            if data then
                local taskdata = cfg[CfgType.CAPHTER_TASK][data.id]
                pro:setString(taskdata.gole.."["..data.value.."/"..data.maxValue.."]")
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
            --me.assignWidget(self, "taskCaphter_ani"):setVisible(user.taskCaphterDataTitle.status == 2 or num > 0)
            if user.taskCaphterDataTitle.status == 0 then
                --章节未开启
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
function cityView:updateUIRedPoint()
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

-- 成就UI红点显示
function cityView:updateAchievenmentRedPoint(evt)
    local flag = false
    for _, v in pairs(user.Achievenment_Redpoint) do
        flag = true
        break
    end

    if flag == false then
        me.assignWidget(self.Button_achievement, "hongbao_red_hint"):setVisible(false)
    else
        me.assignWidget(self.Button_achievement, "hongbao_red_hint"):setVisible(true)
    end
end

-- 推荐任务显示
function cityView:showCommendTask()
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
        commendUI:setVisible(user.taskCaphterDataTitle and user.taskCaphterDataTitle.nextId == 0 )
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

-- 更新正在升级科技的建筑物倒计时
function cityView:initBuildingForTech()
    for key, var in pairs(user.techServerDatas) do
        if me.toNum(var:getLockStatus()) == techData.lockStatus.TECH_TECHING then
            local buildTofid = mainCity.buildingMoudles[var:getTofid()]
            if buildTofid then
                buildTofid:showTechingBar(var:getBuildTime() / 1000 -(me.sysTime() - var:getStartTime()) / 1000)
            else
                print("showTechingBar mainCity.buildingMoudles tofId = " .. var:getTofid() .. " is nil !!!")
            end
        end
    end
end

function cityView:initOrderByFarmer()
    self.crowds = me.assignWidget(self, "crowds")
    local crowdsPos = cc.p(self.crowds:getPositionX(), self.crowds:getPositionY())
    for var = 1, 20 do
        local arm = farmerMoudle:createAni("nongminAni")
        arm.fid = #self.standbyFarmers + 1
        self.standbyFarmers[arm.fid] = arm
        local fp = me.circular(crowdsPos, 37, me.getRandom(360))
        arm:setBasePoint(fp)
        arm:setPosition(fp)
        arm:dirToPoint(crowdsPos)
        arm:doAction("idle")
        arm:setVisible(false)
        arm:setFarmerJob(FARMER_JOB_STANDBY)
        self.buildLayer:addChild(arm)
        --  coroutine.yield()
    end
end
-- function cityView:revProduceFarmer()
--    local center = self.buildingMoudles[user.centerBuild.index]
--    if  user.produceframerdata then
--    local num = user.produceframerdata.num
--    if center and num then
--        if num > 0 then
--            center:ProduceFarmer()
--        end
--    end
--    end
-- end
function cityView:revProduceFarmerComplete(index_, addNum_)
    local house = self.buildingMoudles[index_]
    local num = math.min(addNum_, 8)
    if num <= 0 then
        return
    end
    if house then
        house:ProduceFarmerComplete()
        house:showProduceFarmer(num)

        --        center.produce_time = user.produceframerdata.time
        --        local crowdsPos = cc.p(self.crowds:getPositionX(), self.crowds:getPositionY())
        --        local arm = farmerMoudle:createAni("nongminAni")
        --        local fp = me.circular(crowdsPos, 60, me.getRandom(360))
        --        arm:setBasePoint(fp)
        --        arm:setPosition(house:getBottomPoint())
        --        self.buildLayer:addChild(arm)
        --        local idlefarmer = user.curfarmer - user.workfarmer
        --        if idlefarmer >= MAX_SHOW_FARMER then
        --            arm:moveToPoint(fp, function(node)
        --                arm:doAction(MANI_STATE_IDLE)
        --                arm:stopAllActions()
        --                arm:removeFromParentAndCleanup(true)
        --            end )
        --        else
        --            arm.fid = #self.farmerMoudles + 1
        --            self.farmerMoudles[arm.fid] = arm
        --            arm:moveToPoint(fp, function(node)
        --                arm:doAction(MANI_STATE_IDLE)
        --            end )
        --        end
    end
end
function cityView:updateFarmerBehavior(dt)
    if self.farmerMoudles == nil then return end
    for key, var in pairs(self.farmerMoudles) do
        if var.state == MANI_STATE_MOVE then
            local p = cc.p(var:getPositionX(), var:getPositionY())
            for k, v in pairs(self.buildingMoudles) do
                local box = var:getBoundingBox()
                if cc.rectContainsPoint(box, p) then
                    if var:getPositionY() < v:getCenterPoint().y or v:getState() == BUILDINGSTATE_BUILD.key then
                        var:setLocalZOrder(v:getLocalZOrder() + 1)
                    else
                        var:setLocalZOrder(v:getLocalZOrder() -1)
                    end
                end
            end
        end
    end
end

function cityView:onExit()
    print("cityView  onExit")
    self:stopAllActions()
    mCloudAnimDone = false
    UserModel:removeLisener(self.modelkey)
    me.clearTimer(self.updateNodeZorderTimer)
    me.clearTimer(self.fish_time)
    me.clearTimer(self.Sleep_time)
    me.clearTimer(self.pTaskTime)
    me.clearTimer(self.elevenShopTimer)
    me.clearTimer(self.protectedTimer)
    me.clearTimer(self.localtimeTimer)
    me.clearTimer(self.OpenThron)
    m_optMenu:removeFromParentAndCleanup(true)
    m_optMenu = nil
    -- 添加city onExit事件 用于加载的时候监听 便于释放内存
    me.dispatchCustomEvent("cityViewOnExit")

    if self.sailTimeOverListener then
        me.RemoveCustomEvent(self.sailTimeOverListener)
    end
    me.RemoveCustomEvent(self.uiRedPointListener)
    me.RemoveCustomEvent(self.uiCommendTaskListener)
    me.RemoveCustomEvent(self.uiCompleteTaskListener)
    me.RemoveCustomEvent(self.fapChangedListener)
    me.RemoveCustomEvent(self.cjRedPointListener)
end
function cityView:collect(toftid)
    local res = self.resMoudles[toftid]

    local icon_lumber = me.assignWidget(self, "icon_lumber")
    if res then
        local pStr = "collection_food.plist"
        if res.data.def.type == 1 then
            -- 粮食
            pStr = "collection_food.plist"
            self:ResUIAction(1)
        elseif res.data.def.type == 2 then
            -- 金币
            pStr = "collection_gold.plist"
            self:ResUIAction(4)
        end
        local cItem = cc.ParticleSystemQuad:create(pStr)
        self:addChild(cItem, me.MAXZORDER)
        local pworld = res.gain_img:convertToWorldSpace(cc.p(0, 0))

        local p1 = self:convertToNodeSpace(pworld)
        cItem:setPosition(p1)

        pworld = icon_lumber:convertToWorldSpace(cc.p(0, 0))
        cItem:setVisible(true)
        local function arrive(node)
            node:removeFromParentAndCleanup(true)
        end
        local p2 = self:convertToNodeSpace(pworld)
        local moveto = cc.MoveTo:create(1, p2)
        local callback = cc.CallFunc:create(arrive)

        cItem:runAction(cc.Sequence:create(moveto, callback))
    end
end

-- 随机点资源收获动画
function cityView:collectAction(toftid)
    local res = self.resMoudles[toftid]
    local tempPic, tempPos
    if res.data.def.type == 1 then
        -- 粮食
        tempPic = "gongyong_tubiao_liangshi.png"
        tempPos = cc.p(self.food_label:getPosition())
    elseif res.data.def.type == 2 then
        -- 金币
        tempPic = "gongyong_tubiao_jingbi.png"
        tempPos = cc.p(self.gold_label:getPosition())
    end
    if tempPic and tempPos then
        local toPos_world = self.ui_bar:convertToWorldSpace(cc.p(tempPos.x - 15, tempPos.y))
        local toPos_local = self:convertToNodeSpace(toPos_world)
        local resSize = res:getContentSize()
        local fromPos_world = res:convertToWorldSpace(cc.p(resSize.width / 2, resSize.height / 2))
        local fromPos_local = self:convertToNodeSpace(fromPos_world)
        -- 飞向顶部
        self:resItemFlyToTop(10, tempPic, self, fromPos_local, toPos_local)
    end
end

-- 资源上飞
function cityView:resItemFlyToTop(itemNum, resPic, parentNode, fromPos, toPos)
    -- self.maplayer:getEventDispatcher():pauseEventListenersForTarget(self.maplayer)
    for i = 1, itemNum do
        local sprite = cc.Sprite:create(resPic)
        sprite:setPosition(fromPos)
        parentNode:addChild(sprite, me.MAXZORDER)
        sprite:setVisible(false)
        -- 曲线
        local x1 = fromPos.x +(i % 2 ~= 0 and -60 or 60)
        local y1 = fromPos.y + 60
        local x2 = toPos.x +(i % 2 ~= 0 and -60 or 60)
        local y2 = toPos.y - 60
        local bezier = {
            cc.p(x1,y1),
            cc.p(x2,y2),
            toPos,
        }
        sprite:runAction(cc.Sequence:create(
        cc.DelayTime:create((i - 1) * 0.1),
        cc.Show:create(),
        cc.BezierTo:create(0.45, bezier),
        cc.CallFunc:create( function()
            sprite:removeFromParentAndCleanup(true)
            -- if i == 10 then
            -- self.maplayer:getEventDispatcher():resumeEventListenersForTarget(self.maplayer)
            -- end
        end )
        ))
        sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.0, 360)))
    end
end

function cityView:checkAddFarmers()
    if self.curMaxFarmer < user.curfarmer then
        self.crowds = me.assignWidget(self, "crowds")
        local add = user.curfarmer - self.curMaxFarmer
        local crowdsPos = cc.p(self.crowds:getPositionX(), self.crowds:getPositionY())
        for var = 1, add do
            if self.farmerMoudles == nil then
                self.farmerMoudles = { }
            end
            local arm = farmerMoudle:createAni("nongminAni")
            arm.fid = #self.farmerMoudles + 1
            self.farmerMoudles[arm.fid] = arm
            local fp = me.circular(crowdsPos, 60, arm.fid * 36)
            arm:setBasePoint(fp)
            arm:setPosition(fp)
            arm:dirToPoint(crowdsPos)
            arm:doAction("idle")
            self.buildLayer:addChild(arm)
        end
        self.curMaxFarmer = user.maxfarmer
    end
end
function cityView:initAchievenmentView()
    if self.av == nil then
        self.av = achievementView:create("achievementView.csb")
        self:addChild(self.av, me.MAXZORDER)
        me.showLayer(self.av, "bg")
    end
end
function cityView:initializeCity()
    -- 禁卫军巡逻队
    self:checkShowGuards()
    -- 初始化巡逻队
    -- self:initPatrol()
    -- 初始化鹰
    self:initFreeEagle()
    -- 初始化待命农民
    self:initOrderByFarmer()
    -- 初始化农民
    -- self:initFarmerMoudles()
    -- 羊
    self:initFreeSheep()
    -- 农民种田
    self:showPeasantPlant()
    -- 农民采石
    self:showMinerWork()
    -- 农民伐木
    self:showWoodWork()
    -- 初始化已经存在的建筑
    self:initBuilding()
    -- 初始化随机资源
    self:initResourcePoint()
    -- 初始化士兵
    self:initSoldier()
    -- 初始化正在建造的
    self:initStructDateLine()
    -- 初始化正在生产的农民
    --    self:revProduceFarmer()
    -- 初始化正在升级的科技
    self:initBuildingForTech()
    -- 初始化正在治疗的伤兵
    self:initRevertSoldierLineMsg()
    for key, var in pairs(self.buildingMoudles) do
         var:updateCityBuffAni()
    end
    SharedDataStorageHelper():getNoticeInfo(user.uid)
    InforBtn(self, 1, mInforOpen)
    self:cloudOpen( function(args)
        mCloudAnimDone = true
        -- self.maplayer:scaleto(0.6,1)
        me.DelayRun( function()
            guideHelper.startStep()
        end )
    end )
    --  初始化当前时代
    self.timesAmination = getCenterBuildingTime()
    self.maplayer:setLookAtNode(self.buildingMoudles[user.centerBuild.index])

    switchButtons()
    self:UpButtonPosition()
    self:setTaskHint()
    self:showFire()
    -- 时代旗帜
    me.assignWidget(self, "Button_Troop"):loadTexture("tiem_flag" .. getCenterBuildingTime() .. ".png", me.localType)
    me.assignWidget(self, "Button_Troop"):setVisible(true)
    UserModel:familyCenterHelp()
end
-- 排行榜，活动，月卡开启,名将技能按钮
function cityView:UpButtonPosition()
    me.assignWidget(self, "promotionBtn"):setVisible(false)
    me.assignWidget(self, "rank_Btn"):setVisible(false)
    me.assignWidget(self, "noticeBtn"):setVisible(false)
    me.assignWidget(self, "payBtn"):setVisible(false)
    me.assignWidget(self, "popularize_Btn"):setVisible(false)
    me.assignWidget(self, "Button_achievement"):setVisible(false)
    local showbtn =  guideHelper.getGuideIndex() > 23 
    local nodeBtn = { }
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
    if user.newBtnIDs[me.toStr(OpenButtonID_Share)] ~= nil and nodeBtn[btnIndex] ~= nil then
        setBtnLive("popularize_Btn")
    end
    if nodeBtn[btnIndex] ~= nil then
        setBtnLive("Button_achievement")
    end
    -- 天下大事
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
    if user.cross_st == 1 then
        if nodeBtn[btnIndex] ~= nil then
            setBtnLive("Cross_throne")
        end
    end
    self.act_btn_firstpay:setVisible(showbtn)
    self.Button_heroSkill:setVisible(user.heroSkillStatus == true or user.heroSkillStatus == 1)
end
function cityView:updateMsg(msg)
    -- TODO 处理其它业务消息
    if checkMsg(msg.t, MsgCode.MSG_ACHIEVENMENT_INIT) then
        self:initAchievenmentView()
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif checkMsg(msg.t, MsgCode.ROLE_INFO) then
        self:updateResUI()
        self:initializeCity()
        self:updateProected()
        jjGameSdk.UMLOG_EnterGamePage(math.floor((me.sysTime() - enterLoadtingTime) / 1000))
        if guideHelper.getGuideIndex() ~= guideHelper.guide_End then
            guideHelper.showWaitLayer()
        else
            guideHelper.removeWaitLayer()
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_SKILL_LIST) then
        self:openHeroSkillAnim()
    elseif checkMsg(msg.t, MsgCode.CITY_UPDATE) then
        -- 城市信息刷新
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_OPEN_SKILL) then
        self:setHeroSkillStatus(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_DATELINE_DATA) then
        self:updateResUI()
        self:initializeCity()
    elseif checkMsg(msg.t, MsgCode.ROLE_EXP_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_STRUCT_FINISH) then
        -- 建造完成
        self:revMsgBuildComplete(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_INIT) then
        -- 初始化建筑
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_DATE_LINE) then

    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_STRUCT) then
        -- 建造开始
        self:startBuild(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_UPLEVEL) then
        -- 升级开始
        self:startLevelUpBuilding(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_UPLEVEL_FINISH) then
        -- 升级完成
        self:buildingLevelUpComplete(msg)
        self:setTimesAmination(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_ADORNMENT_LIST) then
        local skin = citySkinLayer:create("buildingSkinLayer.csb")
        skin:initList()
        me.popLayer(skin)
    elseif checkMsg(msg.t, MsgCode.MSG_ADORNMENT_EQUIPT) then
        local pCenter = self.buildingMoudles[user.centerBuild.index]
        pCenter:updateSkin()
    elseif checkMsg(msg.t, MsgCode.WONDER_CHANGE) then
        -- 转换开始
        self:startChangeWonder(msg)
    elseif checkMsg(msg.t, MsgCode.TASK_CAPHTER_TITLE) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_GET_TITLE) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_DATA) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_GET_TASK) or
        checkMsg(msg.t, MsgCode.TASK_CAPHTER_DATA_UPDATA)
    then
        self:updateTasskCaphter()        
        self:showCommendTask()          
    elseif checkMsg(msg.t, MsgCode.WONDER_CHANGE_FINISH) then
        -- 转换完成
        self:wonderChangeComplete(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_RAND_RESOURCE_UPDATE) then
        -- 更新资源点
        self:initResourcePoint()
        --    elseif checkMsg(msg.t, MsgCode.CITY_P_FARMER) then
        --        self:revProduceFarmer(msg)
        --    elseif checkMsg(msg.t, MsgCode.CITY_P_FARMER_FINISH) then
        --        self:revProduceFarmerComplete(msg)
        --        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then
        self:upActionFood(1)
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) then
        local pNum = self.foodNum[2]
        local pAddNum = user.wood - pNum
        if pAddNum > 0 then
            self:upActionFood(2)
        end
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_BUFF_UPDATE) then
        for key, var in pairs(self.buildingMoudles) do
            var:updateCityBuffAni()
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) then
        self:upActionFood(3)
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.CITY_GET_RESOURCE) then
        for key, var in pairs(msg.c.list) do
            self:setActionNum(1, var.index)
            self:upActionRes(var.data)
            -- self:showGainParticl(var.index)
            self:showGainAction(var)
        end
        -- 顶部飘字
        self:showResUp(msg.c.list)
    elseif checkMsg(msg.t, MsgCode.ROLE_GEM_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_PAYGEM_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) then
        self:upActionFood(4)
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_INIT) then


    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST) then
        local fifv = fortIdentifyView:create("fortIdentifyView.csb")
        me.popLayer(fifv)
    elseif checkMsg(msg.t, MsgCode.ROLE_RESOURCE_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_VIEW) then
        -- 训练士兵界面信息
        self:revProduceSoldierViewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_INIT) then
        -- 初始化士兵
    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER) then
        -- 生产士兵
        self:revProduceSoldierMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_SOLDIER_FINISH) then
        -- 生产完成士兵
        self:revProduceSoldierCompleteMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_UP_SOLDIER_INIT) then
        -- 升级士兵
        local up = soldierLevelUpLayer:create("soldlierLevelUpLayer.csb")
        up:initWithData(msg.c)
        mainCity:addChild(up, me.MAXZORDER)
        me.showLayer(up, "Image_frame")
    elseif checkMsg(msg.t, MsgCode.CITY_BUILDING_FARMERCHANGE) then
        self:revAllotMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_UPLEVEL) then
        self:upTechMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_FINISH) then
        -- 科技升级完毕
        self:revTechCompleteMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER_VIEW) then
        -- 伤兵恢复界面信息
        self:revInitRevertSoldierMSg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_RELIVE_SOLDIER_VIEW) then
        -- 死兵恢复界面信息
        self:revInitReliveSoldierMSg(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER) then
        -- 开始恢复伤兵
        self:revUpdateRevertSoldierMsg(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_CITY_FIRE) then
        user.showfire = msg.c.show
        self:showFire()
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER_LINE) then
        -- 首次登陆的时候 ，恢复伤兵
    elseif checkMsg(msg.t, MsgCode.FAMILY_INIT) then
        if mainCity.allianceInfor == false then
            self:revAlliance()
        end
    elseif checkMsg(msg.t, MsgCode.TASK_LIST) or checkMsg(msg.t, MsgCode.TASK_UPDATE) or checkMsg(msg.t, MsgCode.TASK_COMPLETE) then
        self:setTaskHint()
        self:TaskAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_P_REVERT_SOLDIER_FINISH) then
        print("伤兵恢复完毕")
        self:revRevertSoldierFinish(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_ARMY_INFO) then
        if self.armyView == nil then
            self.armyView = armyView:create("armyView.csb")
            self:addChild(self.armyView, me.MAXZORDER)
            me.showLayer(self.armyView, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_NEW) then
        me.assignWidget(self, "mail_red_hint"):setVisible(true)
        mMailRead = true
    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER_ESC) or checkMsg(msg.type, MsgCode.FAMILY_BE_KICK) then
        self:revQuitFamlily()
        mainCity.allianceInfor = false
    elseif checkMsg(msg.t, MsgCode.FAMILY_NOT_INFOR_HINT) then
        -- self:revQuitFamlily()
        if self.allianceExitview ~= nil and msg.c.alertId == 562 then
            self:setExitAlliance()
            self:revQuitFamlily()
            -- elseif msg.c.alertId == 564 then
            --  showTips("玩家已退出联盟")
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT) or checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT_REMOVE) then
        print("cityView #user.warningList = " .. #user.warningList)
        if user.warningListNum < #user.warningList then
            me.assignWidget(self.Button_warning, "ArmatureNode_Jishi"):setVisible(true)
        end
        user.warningListNum = #user.warningList
        self.Button_warning:setVisible(#user.warningList > 0)
    elseif checkMsg(msg.t, MsgCode.PACKAGE_UPDATE) then
        self:updatePackageStatus()
    elseif checkMsg(msg.t, MsgCode.BOOK_INIT) then
        disWaitLayer()
        if self.archbool == false then
            self:setArch()
            self:archHint()
            self.archbool = true
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT) then
        if msg.c.status ~= 2000 then
            -- 2000 挖矿被攻击
            self:setcenterBuildFire()
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT_REMOVE) then
        if msg.c.status ~= 2000 then
            self:removeCenterFire()
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_HELP_HINT) then
        self:AllianceHelpHint(msg)
    elseif checkMsg(msg.t, MsgCode.FAMLIY_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CAMOP_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_INFO) then
        self:popNewMsg(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_FIGHT_UPDATE) then
        self:updateFightPower(msg)
    elseif checkMsg(msg.t, MsgCode.CITY_TAX_INFO) then
        if msg.c.init == true then return end

        if self.tax then
            self.tax:initWithData(msg.c)
        else
            self:showTaxView(msg)
        end
        --    elseif checkMsg(msg.t, MsgCode.SWITCH_PROMOTION_MONTH) then
        --       self:saveButtonStatus(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST_LIST) then
        -- 联盟邀请列表
        self:setAlliaceHint()
        if msg.c.type ~= 0 then
            self:Allinvite(msg.c.list)
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_UPDATA_INFO) then
        -- 联盟邀请列表
        me.assignWidget(self, "guildBtn_hint"):setVisible(false)
    elseif checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
        disWaitLayer()
        if self.mRankView == nil and msg.c.typeId ~= 12
            and msg.c.typeId ~= 17
            and msg.c.typeId ~= 18
            and msg.c.typeId ~= 19
            and msg.c.typeId ~= rankView.BOSS_ACT_FAMILY_RANK
            and msg.c.typeId ~= rankView.PAY_RANK
            and msg.c.typeId ~= rankView.COST_RANK
            and msg.c.typeId ~= rankView.NET_PAY_RANK
            and msg.c.typeId ~= rankView.NET_COST_RANK
            and msg.c.typeId ~= rankView.PROMITION_NEWYEAR and msg.c.typeId ~= rankView.PROMITION_NEWYEARTOTAL

        then
            self:setRank(msg.c.typeId)
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_NOTICE) then
        local noticeId = msg.c.id
        if noticeId < 40 then
            mInforHint = mInforHint + 1
            mInforHint = math.min(mInforHint, 20)
            setInfortHint(self)
            if mInforOpen then
                if mInforNum == 1 then
                    showInfor(self)
                else
                    InforHintBtn(self)
                end
            end
        elseif noticeId == 102 then
            -- 抵御蛮族成功播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_RESIST_VICTORY)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        elseif noticeId == 103 then
            -- 抵御蛮族失败播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_RESIST_FAILURE)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        elseif noticeId == 199 then
            -- 挖矿掠夺成功播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_VICTORY)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        elseif noticeId == 198 then
            -- 挖矿掠夺失败播放效果
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_FAILURE)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.MAXZORDER)
        end
    elseif checkMsg(msg.t, MsgCode.TASK_BUTTON_STATUS) then
        switchButtons()
        self:UpButtonPosition()
        me.setButtonDisable(self.battleBtn, user.newBtnIDs[tostring(OpenButtonID_Battle)] == 3)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_BUTTON_SHOW) then
        self:UpButtonPosition()

        if user.activity_buttons_show[18] then
            self:showActivityShip()
        else
            self:hideActivityShip()
        end
        if user.activity_buttons_down_show[1] then
            self.act_btn_firstpay:setVisible(guideHelper.getGuideIndex()>23)
        else
            self.act_btn_firstpay:setVisible(false)
        end
    elseif checkMsg(msg.t, MsgCode.CITY_SOLDIER_UPDATE) then
        if msg.c.process == 51 then
            self:fastRevertSoilderComplete()
            -- 快速治疗伤兵结束
        end
    elseif checkMsg(msg.t, MsgCode.CITY_P_RELIVE_SOLDIER) then
        self:fastRevertSoilderComplete()
    elseif checkMsg(msg.t, MsgCode.ROLE_VIP_UPDATE) then
        self:updateResUI()
    elseif checkMsg(msg.t, MsgCode.FAMILY_CAPTIVE) then
        UserModel:familyCenterHelp()
    elseif checkMsg(msg.t, MsgCode.FAMILY_CAPTIVE_REVERT_SUCCESS) then
        UserModel:familyCenterHelp()
    elseif checkMsg(msg.t, MsgCode.ROLE_PROTECTED_INFO) then
        self:updateProected()
    elseif checkMsg(msg.t, MsgCode.CHECK_MONTH) then
        self:openMonthView()
    elseif checkMsg(msg.t, MsgCode.SHOP_INIT) then
        if msg.c.shopId == ELEVENSHOP then
            user.elevenShopInfos = ElevenShopData.new(msg.c.time, msg.c.list, msg.c.comsumeAgio, msg.c.comsume)
            self:openElevenShopView()
        end
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_HINT) then
        self:setAllianceHint()
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CREATE) then
        self:setAllianceHint()
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_RENIVE_HINT) then
        self:setAllianceHint()
    elseif checkMsg(msg.t, MsgCode.ELEVEN_SHOP) then
        -- 打开双十一商店
        self:openElevenShopView()
    elseif checkMsg(msg.t, MsgCode.ELEVEN_SHOP_CD) then
        for key, var in pairs(msg.c.list) do
            if var.id == ACTIVITY_ID_VEVRYDAY then
                self:EveryDay()
            elseif var.id == ACTIVITY_ID_SHOP then
                self:initElevenShopTime(var.time)
            end
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_INIT_VIEW) then
        --        if self.promotionView == nil then
        --           self:setEveryDay()
        --        end

    elseif checkMsg(msg.t, MsgCode.POPULARIZE_ONFO_DATA) then
        self:setrecomondPromView()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
        self:getHongbaoAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
        self:getHongbaoAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.REDBAO_OPEN) then
        self.Image_hongbao_bg:setVisible(false)
    elseif checkMsg(msg.t, MsgCode.REDBAO_CLODE) then
        self:setHongBaoInfo()
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_STATUS) then
        self:CrossOpen(msg)
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_PROMOTION_LIST) then
        --  self:setCross_City()
    elseif checkMsg(msg.t, MsgCode.CROSS_THRONE_OCCUPY) then
        self:setCross_Out()
    elseif checkMsg(msg.t, MsgCode.CROSS_THRONE_END) then
        self:setCross_End()
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_FIND_GUARD_INIT) then
        -- self:FindRuneCreate(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_UNLOCK_FUNC) then
        user.unlock_func_id = msg.c.id
        --self:unlockFunc()
    elseif checkMsg(msg.t, MsgCode.MSG_WARSHIP_INIT) or checkMsg(msg.t, MsgCode.MSG_WARSHIP_UPDATE) or checkMsg(msg.t, MsgCode.MSG_WARSHIP_STATUS)
        or checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION_UPDATE) then
        self:WarshipMaplayer()
        -- 禁卫军巡逻
    elseif checkMsg(msg.t, MsgCode.MSG_GUARD_STATUS_CHANGE) then
        self:checkShowGuards()
        -- 更新头像
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
    disWaitLayer()
end

-- 是否显示禁卫军巡逻动画
function cityView:checkShowGuards()
    for i, v in ipairs(self.guardMoudles or { }) do
        v:removeFromParentAndCleanup(true)
    end
    self.guardMoudles = { }
    -- 0:守城状态，1:巡逻状态,2:巡逻结束，可领取奖励
    if user.guard_patrol_status == 1 then
        -- 入住的是否全是车兵
        local isAllVehicle = true
        for i, v in ipairs(user.guard_patrol_army) do
            local def = cfg[CfgType.CFG_SOLDIER][v[1]]
            if def.bigType ~= 4 then
                isAllVehicle = false
                break
            end
        end
        local idList = { }
        if isAllVehicle then
            for k, v in pairs(user.building) do
                local def = v:getDef()
                if def.type == cfg.BUILDING_TYPE_BARRACK or def.type == cfg.BUILDING_TYPE_RANGE
                    or def.type == cfg.BUILDING_TYPE_HORSE or def.type == cfg.BUILDING_TYPE_WONDER then
                    if def.show and def.show ~= "" then
                        local tmp = { }
                        for _, str in ipairs(me.split(def.show, ",")) do
                            local t = me.split(str, ":")
                            local id_ = tonumber(t[1])
                            local level_ = tonumber(t[2])
                            if level_ <= 0 then
                                table.insert(tmp, { id = id_, level = level_ })
                            end
                        end
                        table.sort(tmp, function(a, b)
                            return a.id > b.id
                        end )
                        -- 取已解锁的最高级的那个兵种
                        table.insert(idList, tmp[1].id)
                    end
                end
            end
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
            table.sort(idList, function(a, b)
                local defA = cfg[CfgType.CFG_SOLDIER][a]
                local defB = cfg[CfgType.CFG_SOLDIER][b]
                local priorityA = getPriority(defA)
                local priorityB = getPriority(defB)
                if priorityA ~= priorityB then
                    return priorityA < priorityB
                else
                    return defA.id > defB.id
                end
            end )
        else
            for i, v in ipairs(user.guard_patrol_army) do
                -- 排除车兵
                local def = cfg[CfgType.CFG_SOLDIER][v[1]]
                if def.bigType ~= 4 then
                    table.insert(idList, v[1])
                end
                if #idList >= 6 then
                    break
                end
            end
            for i = 1, 4 - #idList do
                table.insert(idList, idList[#idList])
            end
        end
        -- 正在巡逻随机一个点，否则以禁卫军营帐为起点
        if user.guard_patrol_army_isWalking then
            local index = me.getRandom(#guardsPath)
            local tempPath = { }
            for i = index, #guardsPath do
                table.insert(tempPath, guardsPath[i])
            end
            for i = 1, index - 1 do
                table.insert(tempPath, guardsPath[i])
            end
            for i, v in ipairs(idList) do
                local pQ = self:getSoldierPath(tempPath, "guardsPath1")
                if pQ == nil then return end
                local pos = Queue.pop(pQ)
                local sani = soldierMoudle:createSoldierById(v)
                self.guardMoudles[i] = sani
                self.buildLayer:addChild(sani)
                sani:setPosition(cc.p(pos.x -(i - 1) * 40, pos.y +(i - 1) * 40))
                sani:setVisible(false)
                local function arrive(node)
                    sani:setVisible(true)
                    local pQ = self:getSoldierPath(tempPath, "guardsPath1")
                    node:moveOnPaths(pQ, arrive)
                end
                sani:moveToPoint(pos, arrive)
            end
        else
            user.guard_patrol_army_isWalking = true
            for i, v in ipairs(idList) do
                local pQ = self:getSoldierPath(guardsPath, "guardsPath2")
                if pQ == nil then return end
                local pos = Queue.pop(pQ)
                local sani = soldierMoudle:createSoldierById(v)
                self.guardMoudles[i] = sani
                self.buildLayer:addChild(sani)
                sani:setPosition(cc.p(pos.x -(i - 1) * 40, pos.y +(i - 1) * 40))
                sani:setVisible(false)
                local function arrive(node)
                    sani:setVisible(true)
                    local pQ = self:getSoldierPath(guardsPath, "guardsPath2")
                    node:moveOnPaths(pQ, arrive)
                end
                sani:moveToPoint(pos, arrive)
            end
        end
    else
        user.guard_patrol_army_isWalking = false
    end
end

function cityView:unlockFunc()
    if user.unlock_func_id > 0 then
        self.unlockPrompt.unlockId = user.unlock_func_id
        self.unlockPrompt:setVisible(true)
        me.assignWidget(self.unlockPrompt, "unlockIcon"):loadTexture("unlock_icon_" .. user.unlock_func_id .. ".png", me.localType)
        me.assignWidget(self.unlockPrompt, "unlockIcon"):ignoreContentAdaptWithSize(true)
        me.assignWidget(self.unlockPrompt, "unlockName"):setString(cfg[CfgType.UNLOCK_FUNC_PROMPT][user.unlock_func_id].name)

    else
        self.unlockPrompt:setVisible(false)
    end

end

-- 开启英雄技能的特效
function cityView:setHeroSkillStatus(msg)
    if msg.c.hss == 1 and self.Button_heroSkill:isVisible() == false then
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
            self.Button_heroSkill:setVisible(user.heroSkillStatus == true or user.heroSkillStatus == 1)
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
function cityView:FindRuneCreate()
    if self.findRuneBoos == nil then
        self.findRuneBoos = find_rune_boos:create("find_rune_boos.csb")
        self:addChild(self.findRuneBoos, me.MAXZORDER)
        me.showLayer(self.findRuneBoos, "bg")
    end
end
function cityView:setCross_End()
    self.kingdomView_Cross_Out = kingdomView_Cross_Out:create("kingdomView_Cross_Out.csb")
    self.kingdomView_Cross_Out:setEnd()
    self:addChild(self.kingdomView_Cross_Out, me.MAXZORDER)
end
function cityView:setCross_Out()
    self.kingdomView_Cross_Out = kingdomView_Cross_Out:create("kingdomView_Cross_Out.csb")
    self.kingdomView_Cross_Out:setWin()
    self:addChild(self.kingdomView_Cross_Out, me.MAXZORDER)
end
function cityView:setCross_City(msg)
    self.kingdomView_Cross_City = kingdomView_Cross_City:create()
    -- self.kingdomView_Cross_City:setData()
    self:addChild(self.kingdomView_Cross_City, me.MAXZORDER)
    buildingOptMenuLayer:getInstance():clearnButton()
end
function cityView:CrossOpen(msg)
    me.clearTimer(self.OpenThron)
    if msg.c.st == 1 then
        self.Cross_throne:setVisible(true)
        local time = me.assignWidget(self.Cross_throne, "Text_time")
        local xtime = msg.c.time
        if xtime then
            time:setString(me.formartSecTime(xtime / 1000))
            time:setVisible(true)
            self.OpenThron = me.registTimer(-1, function(dt)
                if xtime > 0 then
                    xtime = xtime - dt * 1000
                    time:setString(me.formartSecTime(xtime / 1000))
                else
                    time:setString("已结束")
                    me.clearTimer(self.OpenThron)
                end
            end , 1)
        end
        self:UpButtonPosition()
    else
        self.Cross_throne:setVisible(false)
    end
    for key, var in pairs(self.buildingMoudles) do
        if var:getDef().type == cfg.BUILDING_TYPE_HALL then
            if user.Cross_Sever_Status == mCross_Sever then
                var:showNetBattleBtn()
            else
                var:hideNetBattleBtn()
            end
        end
    end

end
function cityView:setHongBaoInfo()
    if user.hongBao_name and user.hongBao_union then
        me.assignWidget(self.Panel_HongBao, "Text_hongBao_name"):setString("[" .. user.hongBao_union .. "]" .. user.hongBao_name .. "的红包")
    else
        me.assignWidget(self.Panel_HongBao, "Text_hongBao_name"):setString(user.hongBao_name)
    end
    me.assignWidget(self.Panel_HongBao, "Text_Hongbao_Zhuanshi"):setString(user.hongBao_nums)
end
function cityView:getHongbaoAnimation(msg)
    if msg.c.iteminfo and msg.c.processValue and(msg.c.processValue == 112 or msg.c.processValue == 176 or msg.c.processValue == 258 or msg.c.processValue == 263 or msg.c.processValue == 264  or msg.c.processValue == 268) then
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
function cityView:setEveryDay()
    local EveryDay = EveryDayBuy:create("EveryDayBuy.csb")
    self:addChild(EveryDay, me.MAXZORDER)
end
function cityView:setrecomondPromView()
    if self.pRecomond == nil then
        self.pRecomond = recomondPromView:create("promotionView.csb")
        self:addChild(self.pRecomond, me.MAXZORDER)
        me.showLayer(self.pRecomond, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end
end
-- 每日特惠
function cityView:EveryDay()
    local pBool = false
    for key, var in pairs(user.newBtnIDs) do
        if me.toNum(var) == OpenButtonID_WVERYDAY then
            pBool = true
        end
    end
    if pBool then
        -- self.Button_EveryDay:setVisible(true)
    end
end
function cityView:initElevenShopTime(time)
    local pBool = false
    for key, var in pairs(user.newBtnIDs) do
        if me.toNum(var) == OpenButtonID_Eleven then
            pBool = true
        end
    end
    if pBool then
        if time and time > 0 then
            self.elevenBtn:setVisible(true)
            me.assignWidget(self.elevenBtn, "Text_leftTime"):setVisible(true)
            user.elevenLeftTime = time / 1000
            self.elevenShopTimer = me.registTimer(-1, function()
                me.assignWidget(self.elevenBtn, "Text_leftTime"):setString(me.formartSecTime(user.elevenLeftTime))
                user.elevenLeftTime = user.elevenLeftTime - 1
            end , 1)
        else
            self.elevenBtn:setVisible(true)
        end
    end
end
function cityView:openElevenShopView()
    if mainCity.esv == nil then
        mainCity.esv = elevenShopView:create("elevenShopView.csb")
        me.runningScene():addChild(mainCity.esv, me.MAXZORDER)
        me.showLayer(mainCity.esv, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
    end
end
function cityView:setAllianceHint()
    local pHint = user.allianceConvergeHint.attack + user.allianceConvergeHint.defener
    if pHint > 0 and user.familyUid > 0 then
        me.assignWidget(self, "guildBtn_hint"):setVisible(true)
        for key, var in pairs(self.buildingMoudles) do
            if var:getDef().type == cfg.BUILDING_TYPE_TOWER then
                var:seeGain()
                break
            end
        end
    else
        me.assignWidget(self, "guildBtn_hint"):setVisible(false)
        for key, var in pairs(self.buildingMoudles) do
            if var:getDef().type == cfg.BUILDING_TYPE_TOWER then
                var:closeGain()
                break
            end
        end
    end
end
function cityView:fastRevertSoilderComplete()
    for key, var in pairs(mainCity.buildingMoudles) do
        if var:getDef().type == "abbey" then
            var:faseRevertComplete()
        end
    end
end
function cityView:setRank(typeId)
    local pRank = rankView:create("rank/rankview.csb")
    pRank:setRankRype(typeId)
    me.popLayer(pRank, "bg_frame")
    pRank:ParentNode(self)
    buildingOptMenuLayer:getInstance():clearnButton()
    self.mRankView = pRank
end
function cityView:Allinvite(pData)
    if guideHelper.getGuideIndex() == guideHelper.guide_End then
        local mScene = me.runningScene()
        if me.assignWidget(mScene, "close") == nil and me.assignWidget(mScene, "Button_cancel") == nil then
            local pInvite = allianceAllInvite:create("alliance/allianceinvitehint.csb")
            self:addChild(pInvite, me.MAXZORDER);
            pInvite:setData(pData[1])
            me.showLayer(pInvite, "bg_frame")
            buildingOptMenuLayer:getInstance():clearnButton()
        end
    end
end
function cityView:setAlliaceHint()
    if user.familyUid < 1 then
        local pTab = user.familyRequestList
        if table.maxn(pTab) ~= 0 then
            me.assignWidget(self, "guildBtn_hint"):setVisible(true)
        else
            me.assignWidget(self, "guildBtn_hint"):setVisible(false)
        end
    else
        me.assignWidget(self, "guildBtn_hint"):setVisible(false)
    end
end
function cityView:setExitAlliance()
    local function exitAlliance(node)
        if self.allianceExitview ~= nil then
            self.allianceExitview:removeFromParent()
            self.allianceExitview = nil
            mainCity.allianceInfor = false
        end
    end
    local box = MessageBox:create("MessageBox.csb")
    box:setText("你被踢出联盟了")
    box:register(exitAlliance)
    box:setButtonMode(1)
    self:addChild(box, me.ANIMATION)
end
function cityView:updateFightPower(msg)
    self.grade_label:setString(UserGrade())
end

function cityView:fapChanged(event)
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
function cityView:showFapUp(addNum)
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

function cityView:popNewMsg(msg)
--    self.Text_chat:stopAllActions()
--    self.Text_chat:setVisible(true)
--    self.Text_chat:setOpacity(255)
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
-- 联盟帮助悬浮提示
function cityView:AllianceHelpHint(msg)
    if msg then
        local pData = msg.c
        local pStr = ""
        local pBuidData = mainCity.buildingMoudles[pData.bid]:getDef()
        local pBuidName = ""
        if pData["ptype"] == 0 then
            pStr = "研究科技"
        elseif pData["ptype"] == 1 then
            pStr = "升级"
            dump(pBuidData[pData["bid"]])
            pBuidName = pBuidData.name
        elseif pData["ptype"] == 2 then
            pStr = "建设"
            pBuidName = pBuidData.name
        elseif pData["ptype"] == 3 then
            pStr = "恢复"
            pBuidName = "伤兵"
        end
        showTips("【" .. pData["name"] .. "】" .. "帮助了我" .. pStr .. pBuidName)
    end
end
-- 城镇中心攻击特效
function cityView:setcenterBuildFire()
    local pCenter = self.buildingMoudles[user.centerBuild.index]
    pCenter:showCenterFire()
end
function cityView:removeCenterFire()
    local pCenter = self.buildingMoudles[user.centerBuild.index]
    pCenter:removeCneter()
end
function cityView:setTimesAmination(msg)
    if (user.building[msg.c.index]:getDef().type == cfg.BUILDING_TYPE_CENTER) then
        local pTimes = getCenterBuildingTime()
        if self.timesAmination ~= pTimes then
            self.timesAmination = getCenterBuildingTime()          
             --pTimes
             local ani = Layer_Times_Ani:create("Layer_Times_Ani.csb")
             ani:playTimesAni(tonumber(pTimes))
             me.popLayer(ani)
        end
    end
end
function cityView:TaskAnimation(msg)
    if self.taskAmintion == true then
        if msg.c.list ~= nil then
            for key, var in pairs(msg.c.list) do
                if me.toNum(var.progress) == 3 then
                    me.DelayRun( function()
                        --    self:CommonAnimation(ALL_COMMON_TASK)
                        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
                        pCityCommon:CommonSpecific(ALL_COMMON_TASK)
                        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 100))
                        me.runningScene():addChild(pCityCommon, me.ANIMATION)
                    end , 0.6)
                    break
                end
            end
        end
    else
        self.taskAmintion = true
    end
end
function cityView:setArch()
    self.arch = archLayer:create("archLayer.csb")
    self.arch:setLayerType(mainCity)
    setBookAltas()
    self.arch:setData()
    self:addChild(self.arch, me.MAXZORDER)
    buildingOptMenuLayer:getInstance():clearnButton()
end
function cityView:setMailTask()
    local pBool = getMailHintRed()
    pBool = getMailSystemHintRed()
    if pBool == true then
        me.assignWidget(self, "mail_red_hint"):setVisible(true)
        mMailRead = true
    end
end
function cityView:setTaskHint()
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
-- 推出联盟，隐藏所有帮助按钮
function cityView:revQuitFamlily()
    for key, var in pairs(self.buildingMoudles) do
        var:hideHelpBtn()
    end
end
function cityView:initRevertSoldierLineMsg()
    dump(user.revertingSoldiers)
    for key, var in pairs(user.revertingSoldiers) do
        local building = self.buildingMoudles[key]
        if building then
            building:revertSoldier()
        else
            print("msg.c.bid = nil !!!")
        end
    end
    for key, var in pairs(user.revertingSoldiers_c) do
        local building = self.buildingMoudles[key]
        if building then
            building:revertSoldier_c()
        else
            print("msg.c.bid = nil !!!")
        end
    end
end
function cityView:revAlliance()
    mainCity.allianceInfor = true
    self.allianceview = allianceview:create("alliance/allianceview.csb")
    self:addChild(self.allianceview, me.MAXZORDER)
    self.allianceExitview = self.allianceview
    buildingOptMenuLayer:getInstance():clearnButton()
end
function cityView:revUpdateRevertSoldierMsg(msg)
    local building = self.buildingMoudles[msg.c.bid]
    if building then
        if msg.c.type == 0 then
            building:revertSoldier()
        else
            building:revertSoldier_c()
        end
        building:CityAnimation()
    end
end
function cityView:revInitRevertSoldierMSg(msg)
    local building = self.buildingMoudles[msg.c.bid]
    if building then
        building:showTreat(msg.c.bid)
    end
end
function cityView:revInitReliveSoldierMSg(msg)
    local building = self.buildingMoudles[msg.c.bid]
    if building then
        building:showRelive(msg.c)
    end
end
function cityView:revRevertSoldierFinish(msg)
    local building = self.buildingMoudles[msg.c.bid]
    if building then
        building:revertSoldierComplete()
        building:stopCityAniation()
    end
end
function cityView:startBuild(msg)
    local bdata = user.buildingDateLine[msg.c.index]
    if bdata then
        self:buildBaseAni(bdata)
        if mainCity.bLevelUpLayer and mainCity.bLevelUpLayer.close then
            mainCity.bLevelUpLayer:close()
        end
        if self.bshopBox and self.bshopBox.close then
            self.bshopBox:close()
        end
    else
        showTips("没有该建筑数据", "ff0000")
    end
    guideHelper.nextStepByOpt(true)
end
function cityView:startLevelUpBuilding(msg)
    local bdata = user.buildingDateLine[msg.c.index]
    local building = self.buildingMoudles[msg.c.index]
    if msg.c.quick then
        -- 如果是快速升级就不显示 进度条
        if mainCity.bLevelUpLayer and mainCity.bLevelUpLayer.close then
            mainCity.bLevelUpLayer:close()
        end
        if building and building.seeGain and building.isResBuilding then
            building:closeGain()
        end
        return
    end
    if bdata and building then
        if building.seeGain and building.isResBuilding then
            building:closeGain()
        end
        building:showLevelUpAni(bdata, bdata.countdown)
        if mainCity.bLevelUpLayer and mainCity.bLevelUpLayer.close then
            mainCity.bLevelUpLayer:close()
        end
        if self.bshopBox and self.bshopBox.close then
            self.bshopBox:close()
        end
        guideHelper.nextStepByOpt(true)
    end
end
function cityView:startChangeWonder(msg)
    print("startChangeWonder")
    if msg.c.quick then
        -- 如果是快速升级就不显示 进度条
        if buildChangeView and buildChangeView.close then
            buildChangeView:close()
        end
        return
    end
    local bdata = user.buildingDateLine[msg.c.index]
    local building = self.buildingMoudles[msg.c.index]
    if bdata and building then
        building:showChangeAni(bdata, bdata.countdown)
        if buildChangeView and buildChangeView.close then
            buildChangeView:close()
        end
        if self.bshopBox and self.bshopBox.close then
            self.bshopBox:close()
        end
    end
end
-- 初始化正在建造的建筑
function cityView:initStructDateLine()
    for key, var in pairs(user.buildingDateLine) do
        self:updateBuildingByData(var)
    end
end
function cityView:initSoldier()
    for key, var in pairs(user.produceSoldierData) do
        me.LogTable(var, "---------------")
        if var.num > 0 then
            local building = self.buildingMoudles[var.bindex]
            local def = building:getDef()
            if building then
                building:produceSoldier(var.sid)
            end
        end
    end
    for key, var in pairs(user.soldierData) do
        self:initArmy(var.defId, var.num)
    end
end
function cityView:upTechMsg(msg)
    -- 设置科技所在的建筑物的升级时间
    local tarBuild = self.buildingMoudles[msg.c.index]
    local techData = nil
    -- 别的科技类型的showTechingBar函数在techCellView里有调用,此处只用于集火科技
    if tarBuild and tarBuild:getDef().type == cfg.BUILDING_TYPE_TOWER then
        techData = user.techServerDatas[msg.c.techDefId]
        tarBuild:showTechingBar(math.floor(techData:getBuildTime() / 1000) - math.floor((me.sysTime() - techData.startTime) / 1000))
    end
end
function cityView:revTechCompleteMsg(msg)
    if user.techServerDatas[msg.c.defId] then
        local var = user.techServerDatas[msg.c.defId]
        local buildTofid = mainCity.buildingMoudles[var:getTofid()]
        if buildTofid then
            buildTofid:hideTechingBar()
        else
            print("mainCity.buildingMoudles tofId = " .. var:getTofid() .. " is nil !!!")
        end
    end
end
function cityView:revProduceSoldierViewMsg(msg)
    local building = self.buildingMoudles[msg.c.bindex]
    if building then
        building:showTrain()
    end
end

function cityView:revProduceSoldierMsg(msg)
    local pData = msg.c
    -- (var.num,var.time,var.ptime,var.buildIndex,var.defId)
    local pBuilding = self.buildingMoudles[pData.buildIndex]
    if pBuilding then
        pBuilding:produceSoldier(pData.defId)
    end
end
function cityView:revProduceSoldierCompleteMsg(msg)
    local pData = msg.c
    -- (var.num,var.time,var.ptime,var.buildIndex,var.defId)
    local pBuilding = self.buildingMoudles[pData.buildIndex]
    if pBuilding then
        pBuilding:produceSoldierComplete()
        if pBuilding:getDef().type ~= cfg.BUILDING_TYPE_DOOR then
            self:trainArmy(pData.buildIndex, pData.defId)
        end
    end
end
-- 初始化农民种植动画
function cityView:showPeasantPlant()
    -- 200*200
    local plantNode = me.assignWidget(self.maplayer, "floor_food")
    if bHaveLevelBuilding(cfg.BUILDING_TYPE_FOOD, 1) and plantNode:getChildrenCount() == 0 then
        local peasantNum = me.getRandom(4)
        local plantPos = cc.p(plantNode:getPositionX(), plantNode:getPositionY())
        for var = 1, peasantNum do
            if self.farmerMoudles == nil then
                self.farmerMoudles = { }
            end
            local pDirectionType = self:RandWorkerDirection()
            local arm = farmerMoudle:createAni("nongminAni")
            arm.fid = #self.farmerMoudles + 1
            local fp = me.randInCircle(plantPos, 100)
            self.farmerMoudles[arm.fid] = arm
            arm:setCentre(fp)
            arm:setFarmerJob(FARMER_JOB_PLANT)
            arm:setBasePoint(fp)
            arm:setPosition(fp)
            arm:doAction(MANI_STATE_PLANT, pDirectionType)
            self.buildLayer:addChild(arm)
            -- coroutine.yield()
        end
    end
end
-- 初始化农民挖石头
function cityView:showMinerWork()
    -- 200*200
    local minerNode = me.assignWidget(self.maplayer, "floor_stone")
    if bHaveLevelBuilding(cfg.BUILDING_TYPE_STONE, 1) and minerNode:getChildrenCount() == 0 then
        local peasantNum = me.getRandom(3)
        local minerPos = cc.p(minerNode:getPositionX(), minerNode:getPositionY())
        for var = 1, peasantNum do
            if self.farmerMoudles == nil then
                self.farmerMoudles = { }
            end
            local pDirectionType = self:RandWorkerDirection()
            local arm = farmerMoudle:createAni("nongminAni")
            arm.fid = #self.farmerMoudles + 1
            local fp = me.randInCircle(minerPos, 80)
            self.farmerMoudles[arm.fid] = arm
            arm:setCentre(fp)
            arm:setFarmerJob(FARMER_JOB_MINER)
            arm:setBasePoint(fp)
            arm:setPosition(fp)
            arm:doAction(MANI_STATE_MINING, pDirectionType)
            self.buildLayer:addChild(arm)
        end
    end
end
-- 初始化农民伐木
function cityView:showWoodWork()
    -- 200*200
    local minerNode = me.assignWidget(self.maplayer, "floor_wood")
    if bHaveLevelBuilding(cfg.BUILDING_TYPE_LUMBER, 1) and minerNode:getChildrenCount() == 0 then
        local peasantNum = me.getRandom(4)
        self.woodPointTable = { 1, 2, 3, 4 }
        local woodPointId = me.getRandom(4)
        local restPoints
        self.woodPointTable[woodPointId] = nil

        -- local minerPos = cc.p(minerNode:getPositionX(), minerNode:getPositionY()-100)
        for var = 1, peasantNum do
            if self.farmerMoudles == nil then
                self.farmerMoudles = { }
            end
            --            local pDirectionType = self:RandWorkerDirection()
            if restPoints then
                woodPointId = restPoints[me.getRandom(5 - var)]
                self.woodPointTable[woodPointId] = nil
            end
            restPoints = { }
            for key, var in pairs(self.woodPointTable) do
                table.insert(restPoints, var)
            end
            --            for key,var in pairs(self.woodPointTable) do
            --                  if woodPointId == var then
            --                    local a = true
            --                    while(a)
            --                    do
            --                         woodPointId = me.getRandom(4)
            --                         if woodPointId ~= var then
            --                           a = false
            --                         end
            --                    end
            --                  end
            --            end
            --            table.insert(self.woodPointTable,woodPointId)
            local pDirectionType = 0
            if woodPointId == 1 then
                pDirectionType = DIR_RIGHT
            elseif woodPointId == 2 then
                pDirectionType = DIR_LEFT
            elseif woodPointId == 3 then
                pDirectionType = DIR_RIGHT_TOP
            elseif woodPointId == 4 then
                pDirectionType = DIR_TOP
            end
            local arm = farmerMoudle:createAni("nongminAni")
            arm.woodPointId = woodPointId
            arm.fid = #self.farmerMoudles + 1
            -- local fp = me.randInCircle(minerPos, 80)
            local point = me.assignWidget(self.maplayer, "wood_" .. woodPointId)
            local fp = cc.p(point:getPositionX(), point:getPositionY())
            self.farmerMoudles[arm.fid] = arm
            arm:setCentre(fp)
            arm:setFarmerJob(PARMER_JOB_WOOD)
            arm:setBasePoint(fp)
            arm:setPosition(fp)
            arm:doAction(MANI_STATE_WOOD, pDirectionType)
            self.buildLayer:addChild(arm)
        end
    end
end
-- 工人的方向随机
function cityView:RandWorkerDirection()
    local pNum = me.rand()
    local pLen = string.len(pNum)
    local pafterNum = me.toNum(string.sub(pNum, pLen))
    local pType = DIR_BOTTOM
    if pafterNum == 1 then
        pType = DIR_BOTTOM
    elseif pafterNum == 2 then
        pType = DIR_LEFT_BOTTOM
    elseif pafterNum == 3 then
        pType = DIR_LEFT
    elseif pafterNum == 4 then
        pType = DIR_LEFT_TOP
    elseif pafterNum == 5 or pafterNum == 0 then
        pType = DIR_TOP
    elseif pafterNum == 6 then
        pType = DIR_RIGHT_TOP
    elseif pafterNum == 7 or pafterNum == 9 then
        pType = DIR_RIGHT
    elseif pafterNum == 8 then
        pType = DIR_RIGHT_BOTTOM
    end
    return pType
end

function cityView:initResourcePoint()
    local temp = { }
    for key, var in pairs(user.cityRandResource) do
        temp[var.place] = var
    end
    if self.resMoudles then
        for key, var in pairs(self.resMoudles) do
            --     dump(var.data)
            if var.data ~= nil then
                local resdata = temp[var.data.place]
                if resdata then
                    var:initWithData(resdata)
                    if var:getstate() ~= resdata.work then
                        var:setstate(resdata.work)
                    end
                    if resdata.work == resMoudle.RES_STATE_EXHAUSTED and me.toNum(resdata.outValue) == 0 then
                        self:orderFarmerBack(var:getToftId())
                        var:removeFromParentAndCleanup(true)
                        self.resMoudles[key] = nil
                    end
                else
                    self:orderFarmerBack(var:getToftId())
                    var:removeFromParentAndCleanup(true)
                    self.resMoudles[key] = nil
                end
            end
        end
        for key, var in pairs(temp) do
            local res = self.resMoudles[var.place]
            local resdata = temp[var.place]
            if nil == res and(resdata.work ~= resMoudle.RES_STATE_EXHAUSTED or me.toNum(resdata.outValue) > 0) then
                res = resMoudle:create("build/resLayer.csb")
                res:initWithData(var)
                local toft = self:getCroundworkById(var.place)
                if toft then
                    res:setPosition(toft:getPosition())
                    res:setstate(var.work)
                    self.buildLayer:addChild(res)
                    self.resMoudles[var.place] = res
                end
            end
        end
    else
        self.resMoudles = { }
        for key, var in pairs(user.cityRandResource) do
            local resdata = temp[var.place]
            if (resdata.work ~= resMoudle.RES_STATE_EXHAUSTED or me.toNum(resdata.outValue) > 0) then
                local res = resMoudle:create("build/resLayer.csb")
                res:initWithData(var)
                local toft = self:getCroundworkById(var.place)
                if toft then
                    res:setPosition(toft:getPosition())
                    res:setstate(var.work)
                    self.buildLayer:addChild(res)
                    self.resMoudles[var.place] = res
                end
            end
        end
    end
end
function cityView:updateNodeZorder()
    local function comp(a, b)
        return a:getPositionY() + a:getBoundingBox().height / 4 > b:getPositionY() + b:getBoundingBox().height / 4
    end
    local zorder = 1
    if self.buildLayer then
        local chs = self.buildLayer:getChildren()
        -- me.LogTable(chs,"before comp")
        local temp = { }
        for key, var in pairs(chs) do
            if var:isVisible() and var.__index ~= resMoudle then
                temp[#temp + 1] = var
            end
        end
        table.sort(temp, comp)
        --  me.LogTable(chs,"after comp")
        for var = 1, #temp do
            if temp[var].__index == buildingObj then
                if temp[var]:getState() == BUILDINGSTATE_BUILD.key then
                    temp[var]:setLocalZOrder(0)
                else
                    temp[var]:setLocalZOrder(zorder)
                end
            else
                temp[var]:setLocalZOrder(zorder)
            end
            zorder = zorder + 1
        end
    else
        self.buildLayer = me.assignWidget(self, "buildLayer")
    end
end
function cityView:initGroundworks()
    self.buildLayer = me.assignWidget(self, "buildLayer")
    local chs = self.buildLayer:getChildren()
    self.groundworks = { }
    for key, var in pairs(chs) do
        local name = var:getName()
        local _, _, range, index = string.find(name, "bPace(.-)_(.+)")
        if range and index then
            var.range = range
            var.index = index
            var.used = false
            var.tid = me.toNum(range) * 1000 + me.toNum(index)
            table.insert(self.groundworks, var)
        end
        --  self.groundworks[]
    end
end
age_times_name = {
    [0] = "黑暗时代",
    [1] = "封建时代",
    [2] = "城堡时代",
    [3] = "帝王时代",
    [4] = "后帝王时代",
}

function cityView:updateResUI()
    self.gold_label:setString(Scientific(user.gold))
    self.food_label:setString(Scientific(user.food))
    self.lumber_label:setString(Scientific(user.wood))
    self.stone_label:setString(Scientific(user.stone))
    self.paygem:setString(user.paygem or 0)
    self.level_label:setString(user.lv)
    local time = getCenterBuildingTime()
    self.age_times:setString(age_times_name[time])
    me.assignWidget(self,"exp_loadbar"):setPercent(user.exp*100 / getNextExp(user.lv))
    me.assignWidget(self,"tili_loadbar"):setPercent((user.currentPower or 0 )*100/getUserMaxPower())    
    if self.ActionKind == 0 then
        self.foodNum[1] = user.food
        --   粮食
        self.foodNum[2] = user.wood
        --   木材
        self.foodNum[3] = user.stone
        --  石头
        self.foodNum[4] = user.gold
        --  金币
    end
    self.diamond_label:setString(user.diamond)
    self.farmer_label:setString(user.idlefarmer .. "/" .. user.maxfarmer)
    self.Text_idlefarmer:setString(user.idlefarmer)
    if me.toNum(user.idlefarmer) <= 0 then
        self.Text_idlefarmer:setTextColor(COLOR_RED)
        self.idle_farmer_label:setTextColor(COLOR_RED)
    else
        self.Text_idlefarmer:setTextColor(COLOR_GREEN)
        self.idle_farmer_label:setTextColor(COLOR_GREEN)
    end
    self.grade_label:setString(UserGrade())
    self.vip_label:setString(user.vip)    
    self.name_label:setString(user.name)
    local curTime = overlordView.Time["TIME_" .. getCenterBuildingTime()]
    self.age:loadTexture(curTime.icon, me.localType)
    if user.head and user.head > 0 then
        local cfg = cfg[CfgType.ROLE_HEAD]
        self.age:loadTexture(cfg[user.head].icon .. ".png", me.localType)
    end
    self:updateCroodText()
    self.age:setVisible(true)
    me.assignWidget(self, "ulevel"):setVisible(true)
    me.assignWidget(self, "age_times"):setVisible(true)
    if user.vipTime >= 0 then
        me.assignWidget(self, "icon_vip"):setVisible(true)        
        me.assignWidget(self, "vipgray_bg"):setVisible(user.vipTime == 0)
    end
    me.assignWidget(self, "redpoint_vip"):setVisible(user.iget_free == false and user.vipTime > 0)
end
-- 收获材料的动画
function cityView:ResUIAction(kind)
    local pStr = ""
    if kind == 1 then
        -- 粮食
        pStr = "icon_food"
    elseif kind == 2 then
        -- 木材
        pStr = "icon_lumber"
    elseif kind == 3 then
        -- 石头
        pStr = "icon_stone"
    elseif kind == 4 then
        -- 金币
        pStr = "icon_gold"
    end
    local pIcon = me.assignWidget(self, pStr)

    local pScale1 = cc.ScaleTo:create(1, 1.5)
    local pScale2 = cc.ScaleTo:create(1, 1)
    pIcon:runAction(cc.Sequence:create(pScale1, pScale2))
end

function cityView:initFarmerMoudles()
    self.crowds = me.assignWidget(self, "crowds")
    local crowdsPos = cc.p(self.crowds:getPositionX(), self.crowds:getPositionY())
    local idlefarmer = user.curfarmer - user.workfarmer
    idlefarmer = math.min(idlefarmer, MAX_SHOW_FARMER)
    for var = 1, idlefarmer do
        if self.farmerMoudles == nil then
            self.farmerMoudles = { }
        end
        local arm = farmerMoudle:createAni("nongminAni")
        arm.fid = #self.farmerMoudles + 1
        self.farmerMoudles[arm.fid] = arm
        local fp = me.circular(crowdsPos, 60, arm.fid * 36)
        arm:setFarmerJob(FARMER_JOB_STROLL)
        arm:setCentre(fp)
        arm:setBasePoint(fp)
        arm:setPosition(fp)
        arm:dirToPoint(crowdsPos)
        arm:doAction("idle")
        self.buildLayer:addChild(arm)
        -- coroutine.yield()
    end
end

function cityView:initFreeSheep()
    local function arrive(node)
        local centerPos = node:getCenterPos()
        local p = me.randInRect(cc.p(centerPos.x, centerPos.y), 100, 100)
        node:moveToPoint(p, arrive)
    end

    for index = 1, me.getRandom(3) + 1 do
        local sheep = sheepModel:createAni("yang_3634")
        self.buildLayer:addChild(sheep)
        local p = self:getSoldierNode(me.getRandom(#sheepPath), 1)
        local tmpPos = { }
        tmpPos.x, tmpPos.y = p:getPosition()
        sheep:setCenterPos(tmpPos.x, tmpPos.y)
        sheep:setPosition(cc.p(tmpPos.x, tmpPos.y))
        local tarP = me.randInRect(cc.p(tmpPos.x, tmpPos.y), 100, 100)
        sheep:moveToPoint(tarP, arrive)
    end
end

function cityView:initFreeEagle()
    local function getCityRandomPos()
        local pos = { }
        pos["x"] = me.getRandom(self.skyLayer:getContentSize().width / 4) + self.skyLayer:getContentSize().width / 4
        pos["y"] = me.getRandom(self.skyLayer:getContentSize().height / 4) + self.skyLayer:getContentSize().height / 4
        return pos
    end

    local function arrive(node)
        local randomPos = getCityRandomPos()
        local curPosX, curPosY = node:getPosition()
        if curPosX >= self.skyLayer:getContentSize().width then
            curPosX = curPosX - randomPos.x
        else
            curPosX = curPosX + randomPos.x
        end
        if curPosY >= self.skyLayer:getContentSize().height then
            curPosY = curPosY - randomPos.y
        else
            curPosY = curPosY + randomPos.y
        end

        local animName = "dh"
        -- 飞行动画
        if me.getRandom(10) < 4 then
            animName = "dhh"
            -- 滑行动画
            -- 滑行距离限制
            curPosX = 400
            curPosX = 400
        end
        node:moveToPoint(cc.p(curPosX, curPosY), arrive, animName)
    end

    for index = 1, me.getRandom(2) do
        local ealge = eagleModel:createAniWithShadow("ying_fx", "ying_fxy")
        self.skyLayer:addChild(ealge)
        local posX = me.getRandom(self.skyLayer:getContentSize().width / 2) + me.getRandom(self.skyLayer:getContentSize().width / 2)
        local posY = me.getRandom(self.skyLayer:getContentSize().height / 2) + me.getRandom(self.skyLayer:getContentSize().height / 2)
        ealge:setPosition(cc.p(posX, posY))
        ealge:moveToPoint(getCityRandomPos(), arrive, "dh")
        --   coroutine.yield()
    end
end

function cityView:initPatrol()
    if self.PatrolMoudles == nil then
        self.PatrolMoudles = { }
        for var = 1, 4 do
            local pQ = self:getSoldierPath(soldierPath, "left")
            if pQ == nil then return end
            local pos = Queue.pop(pQ)
            local sani = soldierMoudle:createSoldierById(102)
            self.PatrolMoudles[#self.PatrolMoudles + 1] = sani
            self.buildLayer:addChild(sani)
            sani:setPosition(cc.p(pos.x, pos.y + 4 * 60 - var * 40))
            sani:setVisible(false)
            local function arrive(node)
                local pQ = self:getSoldierPath(soldierPath, "left")
                if not node:isVisible() then
                    node:setVisible(true)
                end
                node:moveOnPaths(pQ, arrive)
            end
            sani:moveToPoint(pos, arrive)
            --  coroutine.yield()
        end
        for var = 1, 4 do
            local pQ = self:getSoldierPath(soldierPathRight, "right")
            if pQ == nil then return end
            local pos = Queue.pop(pQ)
            local sani = soldierMoudle:createSoldierById(102)
            self.PatrolMoudles[#self.PatrolMoudles + 1] = sani
            self.buildLayer:addChild(sani)
            sani:setPosition(cc.p(pos.x, pos.y + 4 * 60 - var * 40))
            sani:setVisible(false)
            local function arrive(node)
                local pQ = self:getSoldierPath(soldierPathRight, "right")
                if not node:isVisible() then
                    node:setVisible(true)
                end
                node:moveOnPaths(pQ, arrive)
            end
            sani:moveToPoint(pos, arrive)
            -- coroutine.yield()
        end
    end
end
-- 更新全部建筑
function cityView:initBuilding()

    for key, var in pairs(user.building) do
        local def = var:getDef()
        if var.state == BUILDINGSTATE_NORMAL.key then
            self:updateBuildingByData(var)
        end
        -- coroutine.yield()
    end
end
-- 更新某一建筑
function cityView:updateBuildingByData(bData_)
    -- me.LogTable(bData_)
    -- print(bData_.index)
    print("----------------------------ds--------------------")
    local build_moudle = self.buildingMoudles[bData_.index]
    if build_moudle then
        build_moudle:initBuildForData(bData_)
    else
        local build_m = buildingFactroy:createBuilding(bData_)
        local toft = self:getCroundworkById(bData_.index)
        if toft then
            toft.used = true
            build_m:setPosition(toft:getPosition())
            build_m:initBuildForData(bData_)
            if bData_.data and bData_.data > 0 and build_m.isResBuilding then
                build_m.gainBtn:setVisible(true)
                build_m.gainBtn:stopAllActions()
                local pMoveBy1 = cc.MoveTo:create(1.5, cc.p(build_m.gainBtn:getPositionX(), build_m.gainBtn:getPositionY() + 30))
                local pMoveBy2 = cc.MoveTo:create(1.5, cc.p(build_m.gainBtn:getPositionX(), build_m.gainBtn:getPositionY() -30))
                build_m.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))
            end
            if bData_:getDef().type == cfg.BUILDING_TYPE_MONK and(user.guard_patrol_status == 2 or user.guard_resist_status == 1) then
                build_m:seeGain()
            end

            self.buildLayer:addChild(build_m)
            print("bData_.index = " .. bData_.index)
            self.buildingMoudles[bData_.index] = build_m

        end
    end
    -- 增加多个箭塔
    if bData_:getDef().type == cfg.BUILDING_TYPE_TOWER then
        local tower1 = me.assignWidget(self.maplayer, "tower_1")
        local tower2 = me.assignWidget(self.maplayer, "tower_2")
        tower1:setVisible(true)
        tower2:setVisible(true)
        tower1:ignoreContentAdaptWithSize(true)
        tower2:ignoreContentAdaptWithSize(true)
        tower1:loadTexture(buildIcon(bData_:getDef()), me.plistType)
        tower2:loadTexture(buildIcon(bData_:getDef()), me.plistType)
        tower2:loadNormalTransparentInfoFromFile()
        tower1:loadNormalTransparentInfoFromFile()
        local function tower_callback(node)
            selectBuilding(self.buildingMoudles[bData_.index], function()
                self.buildingMoudles[bData_.index]:showBuildingMenu()
            end )
        end
        me.registGuiClickEvent(tower1, tower_callback)
        me.registGuiClickEvent(tower2, tower_callback)
    end
    -- 更新跨服战按钮
    if bData_:getDef().type == cfg.BUILDING_TYPE_HALL then
        if user.Cross_Sever_Status == mCross_Sever then
            self.buildingMoudles[bData_.index]:showNetBattleBtn()
        else
            self.buildingMoudles[bData_.index]:hideNetBattleBtn()
        end
    end
    
end
function cityView:revAllotMsg(msg)
    for key, var in pairs(msg.c.list) do
        local building = self.buildingMoudles[var.index]
        if building then
            local data = building:getData()
            if var.build and var.build == 0 then
                -- 建筑工的调配
                if data.state == BUILDINGSTATE_WORK_STUDY.key then
                    building:updateTechAllot()
                elseif data.state == BUILDINGSTATE_WORK_TRAIN.key then
                    building.curTime = 0
                elseif data.state == BUILDINGSTATE_CHANGE.key then

                end
            elseif data.state == BUILDINGSTATE_BUILD.key or data.state == BUILDINGSTATE_LEVEUP.key or data.state == BUILDINGSTATE_CHANGE.key then
                building:updateBuildAllot()
                building:showFarmerChange(var.addFarmer)
                -- 添加工人入驻或者出来的动画
            end
        end
    end
end
function cityView:buildingLevelUpComplete(msg)
    local bData = user.building[msg.c.index]
    local build_moudle = self.buildingMoudles[bData.index]
    if build_moudle then
        build_moudle:levelUpComplete()
        build_moudle:initNormalState(bData)
        self:orderFarmerBack(bData.index)
    end
    -- 如果是房屋升级，就播放生产工人的动画
    if build_moudle:getDef().type == "house" then
        self:revProduceFarmerComplete(bData.index, msg.c.addFarmer or 0)
    end
    if build_moudle.seeGain and build_moudle.isResBuilding then
        build_moudle:seeGain()
    end

    if guideHelper.getGuideIndex() >= guideHelper.guideAllot and guideHelper.getGuideIndex() < guideHelper.guideConquest then
        return
    end
    guideHelper.nextStepByOpt(true)
    
end
function cityView:wonderChangeComplete(msg)
    local bData = user.building[msg.c.index]
    local build_moudle = self.buildingMoudles[bData.index]
    if build_moudle then
        build_moudle:changeComplete()
        build_moudle:initNormalState(bData)
        self:orderFarmerBack(bData.index)
    end
end
function cityView:getCroundwork(def)
    for key, var in pairs(self.groundworks) do
        if not var.used and me.toNum(var.range) == me.toNum(def.iconWeight) then
            print("find the gwork")
            if def.posi and def.posi == 0 then
                return var
            elseif def.posi > 0 then
                if tonumber(var.index) == tonumber(def.posi) then
                    return var
                end
            end
        end
    end
    print("can't find the gwork")
    return nil
end
function cityView:getBoatwork(index)
    for key, var in pairs(self.groundworks) do
        if not var.used and me.toNum(var.index) == index then
            print("find the gwork")
            return var
        end
    end
    print("can't find the gwork")
    return nil
end
function cityView:getIdleFarmer()
    if (self.standbyFarmers) then
        for key, var in pairs(self.standbyFarmers) do
            if var.farmerJob == FARMER_JOB_STANDBY then
                var:setFarmerJob(FARMER_JOB_WORKER)
                var:setVisible(true)
                return var
            end
        end
    end

    return nil
end

-- 得到一个士兵巡逻的桩点(CCNode)
function cityView:getSoldierNode(index, nodeType)
    local pname
    if nodeType and nodeType == 1 then
        pname = "paht_p" .. sheepPath[me.toNum(index)]
    else
        pname = "paht_p" .. soldierPath[me.toNum(index)]
    end
    local pathNode = me.assignWidget(self.maplayer, "path")
    local p = me.assignWidget(pathNode, pname)
    return p
end
function cityView:getSoldierPath(cfg_, name)
    if self.soldierPath_[name] == nil then
        self.soldierPath_[name] = Queue.new()
        local pathNode = me.assignWidget(self.maplayer, "path")
        local lastP = nil
        for key = 1, #cfg_ do
            -- print("-------------" .. cfg_[key])
            local pname = "paht_p" .. cfg_[key]
            local p = me.assignWidget(pathNode, pname)
            lastP = cc.p(p:getPositionX(), p:getPositionY())
            Queue.push(self.soldierPath_[name], lastP)
        end
    end

    local path = me.copyTab(self.soldierPath_[name])

    return path
end

-- 训练军队
-- @建筑位置ID
-- @士兵id
-- -
function cityView:trainArmy(btoftid, sid)
    --[[
    if nil == self.buildingMoudles then
        print("building is nil")
        return
    end
    local sdata = cfg[CfgType.CFG_SOLDIER][sid]
    if nil == self.armyMoudles then
        self.armyMoudles = { }
    end
    if self["crowds_army"] == nil then
        self["crowds_army"] = {}
        for i = 1, 7 do
            local node_ = me.assignWidget(self.maplayer, "crowds_army" .. i)
            self["crowds_army"][#self["crowds_army"]+1] = cc.p(node_:getPositionX(), node_:getPositionY())
        end
    end
    local building = self.buildingMoudles[btoftid]
    local function aniend(node)
        node:getAnimation():setSpeedScale(0.2)
        node:doAction(MANI_STATE_IDLE)
        print("----------------------")
    end
    local function findClearP(startP)
        local p = nil
        local tmpR = 100000
        for key, var in pairs(self["crowds_army"]) do
            local tmp = cc.pGetDistance(startP,var)
            if tmp < tmpR then
                tmpR = tmp
                p = var
            end
        end

        return me.circular(p, me.getRandom(100), me.getRandom(360))
    end

    if building then
        local p = findClearP(building:getLeftPoint())
        -- building:getRoundRandPoint()
        local i = #self.armyMoudles + 1
        print("sid = " .. sid)
        self.armyMoudles[i] = soldierMoudle:createSoldierById(sid)
        -- 士兵生产点
        self.armyMoudles[i]:setPosition(building:getLeftPoint())
        self.armyMoudles[i]:moveToPoint(p, aniend)
        self.armyMoudles[i]:standby()
        self.buildLayer:addChild(self.armyMoudles[i])

        if Queue.count(self.armyShowQueues[sdata.bigType]) > SOLDIER_SHOW_NUM then
            local s = Queue.pop(self.armyShowQueues[sdata.bigType])
            s:stopAllActions()
            s:removeFromParentAndCleanup(true)
        end
        Queue.push(self.armyShowQueues[sdata.bigType], self.armyMoudles[i])
    end
    ]]
    if nil == self.buildingMoudles then
        print("building is nil")
        return
    end
    local sdata = cfg[CfgType.CFG_SOLDIER][sid]
    if nil == self.armyMoudles then
        self.armyMoudles = { }
    end
    if self["crowds_army" .. sdata.bigType] == nil then
        local node_ = me.assignWidget(self.maplayer, "crowds_army" .. sdata.bigType)
        self["crowds_army" .. sdata.bigType] = cc.p(node_:getPositionX(), node_:getPositionY())
    end
    local building = self.buildingMoudles[btoftid]
    local function aniend(node)
        node:getAnimation():setSpeedScale(0.2)
        node:doAction(MANI_STATE_IDLE)
        print("----------------------")
    end
    if building then
        local p = me.circular(self["crowds_army" .. sdata.bigType], me.getRandom(100), me.getRandom(360))
        local i = #self.armyMoudles + 1
        local paths = Queue.new()
        print("sid = " .. sid)
        self.armyMoudles[i] = soldierMoudle:createSoldierById(sid)
        -- 士兵生产点

        if building:getData():getDef().type == cfg.BUILDING_TYPE_WONDER then
            -- 32,35
            Queue.push(paths, building:getLeftPoint())
            Queue.push(paths, self:getPathPosition(32))
            Queue.push(paths, self:getPathPosition(35))
        else
            if tonumber(sdata.bigType) == 1 then
                -- 步兵
                Queue.push(paths, building:getLeftPoint())
            elseif tonumber(sdata.bigType) == 2 then
                -- 起步
                Queue.push(paths, building:getLeftPoint())
            elseif tonumber(sdata.bigType) == 3 then
                -- 弓
                Queue.push(paths, building:getLeftPoint())
            elseif tonumber(sdata.bigType) == 4 then
                -- 车
                Queue.push(paths, building:getRightPoint())
            end
        end
        Queue.push(paths, p)
        if tonumber(sdata.bigType) == 1 then
            -- 步兵
            self.armyMoudles[i]:setPosition(building:getLeftPoint())
        elseif tonumber(sdata.bigType) == 2 then
            -- 起步
            self.armyMoudles[i]:setPosition(building:getLeftPoint())
        elseif tonumber(sdata.bigType) == 3 then
            -- 弓
            self.armyMoudles[i]:setPosition(building:getLeftPoint())
        elseif tonumber(sdata.bigType) == 4 then
            -- 车
            self.armyMoudles[i]:setPosition(building:getRightPoint())
        end
        self.armyMoudles[i]:moveOnPaths(paths, aniend)
        self.armyMoudles[i]:standby()
        self.buildLayer:addChild(self.armyMoudles[i])
        if Queue.count(self.armyShowQueues[sdata.bigType]) > SOLDIER_SHOW_NUM then
            local s = Queue.pop(self.armyShowQueues[sdata.bigType])
            s:stopAllActions()
            s:removeFromParent()
        end
        Queue.push(self.armyShowQueues[sdata.bigType], self.armyMoudles[i])
    end
end
function cityView:getPathPosition(pid)
    local node_ = me.assignWidget(self.maplayer, "paht_p" .. pid)
    return cc.p(node_:getPositionX(), node_:getPositionY())
end
function cityView:initArmy(sid, num)
    num = me.toNum(num)
    local sdata = cfg[CfgType.CFG_SOLDIER][sid]
    if sdata == nil then
        __G__TRACKBACK__(sid .. "is nil!!!")
    end
    if sdata.bigType == 99 then
        -- 等于陷阱就返回，不显示任何动画
        return
    end
    if nil == self.armyMoudles then
        self.armyMoudles = { }
    end
    if self["crowds_army" .. sdata.bigType] == nil then
        local node_ = me.assignWidget(self.maplayer, "crowds_army" .. sdata.bigType)
        self["crowds_army" .. sdata.bigType] = cc.p(node_:getPositionX(), node_:getPositionY())
    end

    local function aniend(node)
        node:getAnimation():setSpeedScale(0.2)
        node:doAction(MANI_STATE_IDLE)
        print("----------------------")
    end
    if num > 2 then
        num = 2
    end
    for var = 1, num do
        local p =
        -- building:getRoundRandPoint()
        me.circular(self["crowds_army" .. sdata.bigType], me.getRandom(100), me.getRandom(360))
        local i = #self.armyMoudles + 1
        self.armyMoudles[i] = soldierMoudle:createSoldierById(sid)
        self.armyMoudles[i]:setPosition(p)
        self.armyMoudles[i]:moveToPoint(p, aniend)
        self.armyMoudles[i]:standby()
        self.buildLayer:addChild(self.armyMoudles[i])
        if Queue.count(self.armyShowQueues[sdata.bigType]) > SOLDIER_SHOW_NUM then
            local s = Queue.pop(self.armyShowQueues[sdata.bigType])
            s:stopAllActions()
            s:removeFromParentAndCleanup(true)
        end
        Queue.push(self.armyShowQueues[sdata.bigType], self.armyMoudles[i])
    end
end
function cityView:getCroundworkById(id)
    self.buildLayer = me.assignWidget(self, "buildLayer")
    local range = math.floor(id / 1000)
    local index = id % 1000
    local name = "bPace" .. range .. "_" .. index
    print("getCroundworkById " .. id .. " name = " .. name)
    local toft = self.buildLayer:getChildByName(name)
    if not toft then
        showTips(TID_BUILD_NO_TILED)
        return nil
    end
    return toft
end
function cityView:orderFarmerBack(toftid)
    for key, var in pairs(self.standbyFarmers) do
        if var:getTagBuildingId() == toftid then
            var:gobackAndIdle()
        end
    end
end
function cityView:revMsgBuildComplete(msg)
    local tid = msg.c.index
    local toft = self:getCroundworkById(tid)
    if toft then
        toft.used = true
        local build_moudle = self.buildingMoudles[tid]
        build_moudle:buildComplete()
        -- 如果是房屋建造完成，就播放生产工人的动画
        if build_moudle:getDef().type == "house" then
            self:revProduceFarmerComplete(tid, msg.c.addFarmer or 0)
        end
        toft:removeFromParentAndCleanup(true)
        self:orderFarmerBack(tid)
        UserModel:addBuildingNum(user.building[tid]:getDef().type)
        -- 增加多个箭塔
        if user.building[tid]:getDef().type == cfg.BUILDING_TYPE_TOWER then
            local tower1 = me.assignWidget(self.maplayer, "tower_1")
            local tower2 = me.assignWidget(self.maplayer, "tower_2")
            tower1:setVisible(true)
            tower2:setVisible(true)
            tower1:ignoreContentAdaptWithSize(true)
            tower2:ignoreContentAdaptWithSize(true)
            tower1:loadTexture(buildIcon(user.building[tid]:getDef()), me.plistType)
            tower2:loadTexture(buildIcon(user.building[tid]:getDef()), me.plistType)
            tower2:loadNormalTransparentInfoFromFile()
            tower1:loadNormalTransparentInfoFromFile()
            local function tower_callback(node)
                selectBuilding(self.buildingMoudles[user.building[tid].index], function()
                    self.buildingMoudles[user.building[tid].index]:showBuildingMenu()
                end )
            end
            me.registGuiClickEvent(tower1, tower_callback)
            me.registGuiClickEvent(tower2, tower_callback)
        end
    end
    if guideHelper.getGuideIndex() >= guideHelper.guideAllot and guideHelper.getGuideIndex() < guideHelper.guideConquest then
        return
    end
    guideHelper.nextStepByOpt(true)
end
function cityView:buildBaseAni(bdata)
    local gp = self:getCroundworkById(bdata.index)
    if gp then
        gp.used = true
        cameraLookAtNode(gp)
        local bMouldle = buildingFactroy:createBuilding(bdata)
        bMouldle:setPosition(gp:getPosition())
        bMouldle:initBuildForData(bdata)
        self.buildLayer:addChild(bMouldle)
        self.buildingMoudles[bdata.index] = bMouldle
        print("bdata.index = " .. bdata.index)
    else
        showTips(TID_BUILD_NO_TILED)
    end
end
function cityView:getBuildingMoudles()
    return self.buildingMoudles
end
function cityView:cloudClose(callfunc_)
    if guideViewInstace ~= nil then
        guideViewInstace:close()
    end
    selectBuilding(self.buildingMoudles[user.centerBuild.index], function(args)
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
        self.maplayer:scaleto(t, 0.7)
    end )
end
function cityView:cloudOpen(callfunc)
    --  self.maplayer:scaleto(0,0.7)
    local cloudLayer = me.assignWidget(self, "Panel_Cloud")
    cloudLayer:setVisible(true)
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
-- 收获的数字
function cityView:setActionNum(kind, pIndex)
    self.ActionIndex = pIndex
    self.ActionKind = kind
end
-- 获取坐标
function cityView:getHarvestAction()
    if self.ActionKind == 1 then
        -- 建筑物
        local house = self.buildingMoudles[self.ActionIndex]
        if house then
            local pPoint = house:getCenterPoint()
            return pPoint
        end
    elseif self.ActionKind == 2 then
        -- 采集点
        local res = self.resMoudles[self.ActionIndex]
        local icon_lumber = me.assignWidget(self, "icon_lumber")
        if res then
            local pworld = res.gain_img:convertToWorldSpace(cc.p(0, 0))
            local p1 = self:convertToNodeSpace(pworld)
            return p1
        end
    end
    return nil
end
function cityView:showGainParticl(index)
    local house = self.buildingMoudles[index]
    house:gainParticl()
end

-- 粮食、石头、木材 收获动画
function cityView:showGainAction(v)
    local house = self.buildingMoudles[v.index]
    local function callback()
        local tempPic, tempPos
        if v.kind == 1 then
            -- 粮食
            tempPic = "gongyong_tubiao_liangshi.png"
            tempPos = cc.p(self.food_label:getPosition())
        elseif v.kind == 2 then
            -- 木材
            tempPic = "gongyong_tubiao_mucai.png"
            tempPos = cc.p(self.lumber_label:getPosition())
        elseif v.kind == 3 then
            -- 矿石
            tempPic = "gongyong_tubiao_shitou.png"
            tempPos = cc.p(self.stone_label:getPosition())
        end
        if tempPic and tempPos then
            local toPos_world = self.ui_bar:convertToWorldSpace(cc.p(tempPos.x - 15, tempPos.y))
            local toPos_local = self:convertToNodeSpace(toPos_world)
            local houseSize = house:getContentSize()
            local fromPos_world = house:convertToWorldSpace(cc.p(houseSize.width / 2, houseSize.height / 2))
            local fromPos_local = self:convertToNodeSpace(fromPos_world)
            -- 飞向顶部
            self:resItemFlyToTop(10, tempPic, self, fromPos_local, toPos_local)
        end
    end
    house:gainAction(callback)
end

-- 展示资源增加
function cityView:showResUp(list)
    local addNum, tempPos = 0, nil
    for i, v in ipairs(list) do
        addNum = addNum + v.data
        if i == #list then
            if v.kind == 1 then
                -- 粮食
                tempPos = cc.p(self.food_label:getPosition())
            elseif v.kind == 2 then
                -- 木材
                tempPos = cc.p(self.lumber_label:getPosition())
            elseif v.kind == 3 then
                -- 石头
                tempPos = cc.p(self.stone_label:getPosition())
            elseif v.kind == 4 then
                -- 金币
                tempPos = cc.p(self.gold_label:getPosition())
            end
        end
    end
    local pos_world = self.ui_bar:convertToWorldSpace(cc.p(tempPos.x - 5, tempPos.y - 30))
    local pos_local = self:convertToNodeSpace(pos_world)
    local addLabel = self.food_label:clone()
    addLabel:setString(string.format("+%s", addNum))
    addLabel:setPosition(pos_local)
    self:addChild(addLabel, me.MAXZORDER)
    addLabel:runAction(cc.Sequence:create(
    cc.MoveBy:create(1.0, cc.p(0, 10)),
    cc.CallFunc:create( function()
        addLabel:removeFromParentAndCleanup(true)
    end )
    ))
end

-- 收获的消息
function cityView:upActionFood(kind)
    if self.ActionIndex ~= 0 and self.ActionKind ~= 0 then
        local pAddNum = 0
        if kind == 1 then
            -- 粮食
            local pNum = self.foodNum[1]
            pAddNum = user.food - pNum
        elseif kind == 2 then
            -- 木材
            local pNum = self.foodNum[2]
            pAddNum = user.wood - pNum
        elseif kind == 3 then
            -- 石头
            local pNum = self.foodNum[3]
            pAddNum = user.stone - pNum
        elseif kind == 4 then
            -- 金币
            local pNum = self.foodNum[4]
            pAddNum = user.gold - pNum
        end
        local pp = me.assignWidget(self, "food")
        local pActionlabel = pp:clone()
        pActionlabel:setName("----")
        pActionlabel:setString("+" .. pAddNum)
        pActionlabel:setAnchorPoint(cc.p(0.5, 0.5))
        if self.ActionKind == 1 then
            local house = self.buildingMoudles[self.ActionIndex]
            pActionlabel:setPosition(cc.p(100 * pActionlabel:getScale(), 100 * pActionlabel:getScale()))
            house:addChild(pActionlabel, me.MAXZORDER)
        elseif self.ActionKind == 2 then
            pActionlabel:setPosition(self:getHarvestAction())
            self:addChild(pActionlabel, me.MAXZORDER)
        end

        local pFadeOut = cc.FadeOut:create(2)
        local pMoveBy = cc.MoveBy:create(2, cc.p(0, 60))
        local pScale = cc.ScaleTo:create(2, 3)
        local pSpawn = cc.Spawn:create(pFadeOut, pMoveBy, pScale):clone()

        local function arrive(node)
            node:removeFromParentAndCleanup(true)
        end

        local callback = cc.CallFunc:create(arrive)

        pActionlabel:runAction(cc.Sequence:create(pSpawn, callback))
        self.ActionIndex = 0
        self.ActionKind = 0

        -- 顶部飘字
        local list = {
            { kind = kind, data = pAddNum },
        }
        self:showResUp(list)
    end
end
function cityView:upActionRes(num)
    if self.ActionIndex ~= 0 and self.ActionKind ~= 0 then
        local pp = me.assignWidget(self, "food")
        local pActionlabel = pp:clone()
        pActionlabel:setName("----")
        pActionlabel:setString("+" .. num)
        pActionlabel:setAnchorPoint(cc.p(0.5, 0.5))
        if self.ActionKind == 1 then
            local house = self.buildingMoudles[self.ActionIndex]
            pActionlabel:setPosition(cc.p(100 * pActionlabel:getScale(), 100 * pActionlabel:getScale()))
            house:addChild(pActionlabel, me.MAXZORDER)
        elseif self.ActionKind == 2 then
            pActionlabel:setPosition(self:getHarvestAction())
            self:addChild(pActionlabel, me.MAXZORDER)
        end
        local pFadeOut = cc.FadeOut:create(2)
        local pMoveBy = cc.MoveBy:create(2, cc.p(0, 60))
        local pScale = cc.ScaleTo:create(2, 3)
        local pSpawn = cc.Spawn:create(pFadeOut, pMoveBy, pScale):clone()

        local function arrive(node)
            node:removeFromParentAndCleanup(true)
        end

        local callback = cc.CallFunc:create(arrive)

        pActionlabel:runAction(cc.Sequence:create(pSpawn, callback))
        self.ActionIndex = 0
        self.ActionKind = 0
    end
end
function cityView:fishAni()
    self.fishData = { }
    -- 鱼的动画
    local pRands = me.getRandom(5)
    local fishNode = me.assignWidget(self.maplayer, "fish")
    local pTotal = 4
    local function getPoint(pPoint)
        local pBool = true
        for key, var in pairs(self.fishData) do
            local pFishPoint = var:getfishPoint()
            if pFishPoint == pPoint then
                pBool = false
                break
            end
        end
        return pBool
    end
    local function setfish(pRands)
        for var = 1, pRands do
            local pCountDRand = me.getRandom(30)
            if pCountDRand < 5 then
                pCountDRand = 6
            end
            local pPoint = me.getRandom(7)
            local pBool = getPoint(pPoint)
            if pBool == true then
                local pFish = allAnimation:createAnimation("nong_yu")
                pFish:setfishData(fishNode, pCountDRand, pPoint)
                table.insert(self.fishData, 1, pFish)
            end
        end
    end
    setfish(pRands)

    self.fish_time = me.registTimer(-1, function(dt)
        for key, var in pairs(self.fishData) do
            var:setCountDown(3)
            local pCD = var:getCountDown()
            if pCD < 1 then
                var:removeFromParentAndCleanup(true)
                self.fishData[key] = nil
                --  print("1111111111111111")
            end
        end
        local pNum = #self.fishData
        --    print("aaaaaaaaaaaaa"..pNum)
        if pNum < pTotal then
            local pSurplus = pTotal - pNum
            local pRands = me.getRandom(pSurplus)
            setfish(pRands)
        end
    end , 3)
end
function cityView:updataSleep()
    self.Sleep_time = me.registTimer(-1, function(dt)
        if self.buildingMoudles then
            for key, var in pairs(self.buildingMoudles) do
                var:setSleepTime()
            end
        end
    end , 1)
end

-- 礼包领完后更新按钮
-- function cityView:updateMarketBtn()
--    if user.packageStatus == 5 then
--        buildingOptMenuLayer:getInstance():updateTradeButton()
--        local obj = self.buildingMoudles[self.marketToftId]
--        if obj then
--            local index = 1
--            self:packageAni(obj:getGoodsIcon(obj.awardsData[index][1]), obj.awardsData[index][2])
--            index = index + 1
--            self.packageAniTimer = me.registTimer(-1, function(dt)
--                if index <= #obj.awardsData then
--                    print("obj.awardsData[index][1]", obj.awardsData[index][1])
--                    self:packageAni(obj:getGoodsIcon(obj.awardsData[index][1]), obj.awardsData[index][2])
--                    index = index + 1
--                else
--                    me.clearTimer(self.packageAniTimer)
--                end
--            end , 0.5)
--            obj.gainBtn:setVisible(false)
--        end
--    end
-- end

-- 更新礼包马车按钮
function cityView:updatePackageStatus()
    if self.packageDidInit then
        buildingOptMenuLayer:getInstance():updateTradeButton()
        if user.packageData.status == 2 then
            if self.marketToftId then
                local obj = self.buildingMoudles[self.marketToftId]
                if obj then
                    obj.packageId = user.packageData.id
                    obj.awardsData = { }
                    for key, var in pairs(user.packageData.award) do
                        table.insert(obj.awardsData, var)
                    end
                    obj:seeGain()
                end
            end
        else
            local obj = self.buildingMoudles[self.marketToftId]
            if obj then
                if #obj.awardsData > 0 then
                    local index = 1
                    -- me.GoodsSpecific(me.assignWidget(self,"taskBtn"),obj:getGoodsIcon(obj.awardsData[index][1]),obj.awardsData[index][2])
                    self:packageAni(obj:getGoodsIcon(obj.awardsData[index][1]), obj.awardsData[index][2])
                    index = index + 1
                    self.packageAniTimer = me.registTimer(-1, function(dt)
                        if obj.awardsData and index <= #obj.awardsData then
                            print("obj.awardsData[index][1]", obj.awardsData[index][1])
                            -- me.GoodsSpecific(me.assignWidget(self,"taskBtn"),obj:getGoodsIcon(obj.awardsData[index][1]),obj.awardsData[index][2])
                            self:packageAni(obj:getGoodsIcon(obj.awardsData[index][1]), obj.awardsData[index][2])
                            index = index + 1
                        else
                            me.clearTimer(self.packageAniTimer)
                        end
                    end , 0.5)
                    obj.gainBtn:setVisible(false)
                end
            end
        end
    end
    self.packageDidInit = true
end

function cityView:removeFarmerPathById(tofId_)
    if self.farmerPath[tofId_] then
        self.farmerPath[tofId_]:purge()
        self.farmerPath[tofId_] = nil
    end
end

function cityView:showFarmerPath(que_, tofId_, farmerPos_)
    if que_ == nil or tofId_ == nil then
        return
    end
    if farmerPos_ then
        que_ = Queue.insert(que_, 0, farmerPos_)
    end
    if self.farmerPath[tofId_] == nil then
        self.farmerPath[tofId_] = expedPath:createFarmerPath(que_)
    end
end

function cityView:packageAni(pIcon, pNum)
    local good = ccui.ImageView:create(pIcon)
    local goodNum = ccui.Text:create("x " .. pNum, "", 26)
    goodNum:setPosition(cc.p(good:getContentSize().width / 2, -1))
    good:addChild(goodNum, me.MAXZORDER)

    print("good", good)
    good:setAnchorPoint(0.5, 0.5)
    good:setPosition(cc.p(cc.Director:getInstance():getWinSize().width / 2, cc.Director:getInstance():getWinSize().height / 4))
    good:setScale(0.1)

    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end

    -- local pRewards = me.assignWidget(pCell,"rewards_bg"):clone():setVisible(true)
    self:addChild(good, me.MAXZORDER)


    --         local pRewardsIcon = me.assignWidget(pCell,"rewards_icon")
    --         pRewardsIcon:loadTexture(pIcon,me.localType)
    --         local pRewardsNum = me.assignWidget(pCell,"rewards_num")
    --         pRewardsNum:setString("×"..pNum)


    local pMoveBy = cc.MoveBy:create(0.4, cc.p(0, cc.Director:getInstance():getWinSize().height / 3 + 110))
    local moveBy = cc.MoveBy:create(0.1, cc.p(0, -30))
    local moveByR = moveBy:reverse()
    local delay = cc.DelayTime:create(0.2)
    -- local fadeOut = cc.FadeOut:create(0.5)
    local shake = cc.Sequence:create(moveBy, moveByR, moveBy)
    local pSpawn = cc.Spawn:create(pMoveBy, cc.ScaleTo:create(0.4, 1.0))
    local bagBtn = me.assignWidget(self, "bagBtn")
    local away = cc.MoveTo:create(0.5, cc.p(bagBtn:getPositionX() - bagBtn:getContentSize().width / 2, bagBtn:getPositionY()))
    local rotate = cc.RotateBy:create(0.5, 720)
    local spawn = cc.Spawn:create(away, cc.ScaleTo:create(0.5, 0.3))

    local callback = cc.CallFunc:create(arrive)

    good:runAction(cc.Sequence:create(pSpawn, shake, delay, spawn, callback))
    print("packageAni")
end

function cityView:showTaxView(msg)
    self.tax = taxView:create("taxView.csb")
    self.tax:initWithData(msg.c)
    self:addChild(self.tax)
    me.showLayer(self.tax, "bg")
    buildingOptMenuLayer:getInstance():clearnButton()
end

function cityView:openAllianceViewAgain()
    if self.allianceview then
        if self.allianceview.close then
            self.allianceview:close()
        end
    end
    jumpToAlliancecreateView()
end

function cityView:updateLordName()
    self.name_label:setString(user.name)
end
function cityView:showVipView()
    buildingOptMenuLayer:getInstance():clearnButton()
    local vipview = vipView:create("vipView.csb")
    me.runningScene():addChild(vipview, me.MAXZORDER)
    me.showLayer(vipview, "bg")
end
-- --function cityView:saveButtonStatus(msg)
-- --   local str = ""
-- --   for key,var in pairs(msg.c.list) do
-- --       str = str..var.buttonId.."|"..var.buttonStatus..";"
-- --   end
-- --   SharedDataStorageHelper():setButtonStatus(str)
-- --   self:switchButtons()
-- --end
-- --function cityView:switchButtons()
-- --   local str = SharedDataStorageHelper():getButtonStatus()
-- --   if str and str ~= "" then
-- --       local strTb = me.split(str,";")
-- --       for key,var in pairs(strTb) do
-- --           local tb = me.split(var,"|")
-- --           local btn
-- --           if me.toNum(tb[1]) == 1 then
-- --              btn = me.assignWidget(self,"monthBtn")
-- --           elseif me.toNum(tb[1]) == 2 then
-- --              btn = me.assignWidget(self,"promotionBtn")
-- --           end
-- --           btn:setVisible(me.toNum(tb[2]) == 1)
-- --       end
-- --   end
-- --end
function cityView:setTaskData(pData)
    self.mTaskData = pData
end
function cityView:TaskRewardsTask(event)
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
function cityView:RewardsAnimation(pNode, pData, pIndx)

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
function cityView:getTaskGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_" .. pCfgData["icon"] .. ".png"
    return pIconStr
end

function cityView:openMonthView()
    buildingOptMenuLayer:getInstance():clearnButton()
    if self.monthCardView == nil then
        self.monthCardView = monthCardView:create("monthCardView.csb")
        mainCity:addChild(self.monthCardView)
        me.showLayer(self.monthCardView, "bg")
    end
end

function cityView:updateProected()
    local protectedType = user.protectedType
    local protectedTime = user.protectedTime
    self.ProtectedIcon:setVisible(false)
    self.ProtectedIcon:loadTexture("waicheng_mianzhan_kuang.png", me.localType)

    local tips = me.assignWidget(self.ProtectedIcon, "t_tips")

    if protectedType == PROTECTED_TYPE_CAPTIVE then
        self.ProtectedIcon:setVisible(true)
        tips:setString("免战保护期，主城不可被征服或掠夺，土地可以被征服或掠夺")
        -- self.ProtectedIcon:loadTexture("waicheng_mianzhan_kuang.png",me.localType)
    elseif protectedType == PROTECTED_TYPE_NEWPLAYER then
        self.ProtectedIcon:setVisible(true)
        tips:setString("新手保护期，主城不可被征服或掠夺，土地不可被征服，但可以被掠夺，伤兵率大幅提升。")
        self.ProtectedIcon:loadTexture("waicheng_tubiao_xinshou_huang.png", me.localType)
    elseif protectedType == PROTECTED_TYPE_MINE then
        self.ProtectedIcon:setVisible(true)
        tips:setString("坚守保护期，主城不可被征服或掠夺，土地可以被征服或掠夺")
        self.ProtectedIcon:loadTexture("waicheng_tubiao_shou_huang.png", me.localType)
    end

    if protectedTime and protectedTime > 0 then
        me.clearTimer(self.protectedTimer)
        local t = 1
        self.protectedTimer = me.registTimer(-1, function(dt)
            local restTime = protectedTime - t
            if restTime > 0 then
                me.assignWidget(self, "Text_protected_time"):setString(me.formartSecTime(restTime))
            else
                me.clearTimer(self.protectedTimer)
                NetMan:send(_MSG.RoleProtectedInfo())
            end
            t = t + 1
        end , 1)
    end
end

function cityView:jumpToPromotion(index)
    self.promotionView = promotionView:create("promotionView.csb")
    self.promotionView:setTaskGuideIndex(index)
    self:addChild(self.promotionView, me.MAXZORDER);
    me.showLayer(self.promotionView, "bg_frame")
    buildingOptMenuLayer:getInstance():clearnButton()
end
function cityView:WarshipMaplayer()
    local pdata = user.warshipData
    local pAction = { { 2, 2 }, { 2, 3 }, { 1, 2 }, { 2, 3 } }

    local bCreatNewShip = false

    for key, var in pairs(pdata) do
        if var.isNew == true then
            bCreatNewShip = true
        end
        local pConfig = var.baseShipCfg
        local pNode = me.assignWidget(self.maplayer, "warship_" .. pConfig.type)
        pNode:removeAllChildren()

        local taskId = 0
        for k, v in pairs(user.shipSailData.taskData) do
            if v.shipId == var.type and v.taskStatus == 2 then
                taskId = v.taskId
                break
            end
        end
        if var.status == 2 or var.status == 3 or(var.status == 4 and taskId ~= 0) then
            local warship_cell = me.assignWidget(self.maplayer, "warship_cell"):clone():setVisible(true)
            -- local pIconStr = "zhanjian_tupian_zhanjian_" .. pConfig.icon .. ".png"
            local pIconStr = "default.png"
            local pIcon = me.assignWidget(warship_cell, "cell_icon")
            pIcon:loadTexture(pIconStr, me.plistType)
            local sk = sp.SkeletonAnimation:create("animation/anim_zhanjian_0" .. pConfig.icon .. ".json", "animation/anim_zhanjian_0" .. pConfig.icon .. ".atlas", 0.6)
            pIcon:addChild(sk)
            sk:setPosition(100, 100)
            sk:setAnimation(0, "animation2", true)
            local Button_cell = me.assignWidget(warship_cell, "Button_cell")
            Button_cell:setTag(pConfig.type)
            me.registGuiClickEvent(Button_cell, function(node)
                local pTag = node:getTag()
                local warshipView = warshipView:create("warning/warshipView.csb")
                mainCity:addChild(warshipView, me.MAXZORDER)
                warshipView:setCurShipType(pTag)
                me.showLayer(warshipView, "bg")
            end )
            if var.maxExp and var.nowExp >= var.maxExp and
                bLessLevelBuilding(cfg.BUILDING_TYPE_BOAT, var.baseShipCfg.lv) then
                me.assignWidget(warship_cell, "cell_up"):setVisible(true)
            else
                me.assignWidget(warship_cell, "cell_up"):setVisible(false)
            end
            Button_cell:setSwallowTouches(false)
            --[[
            local pTable = pAction[pConfig.type]
            local pLayer = cc.LayerColor:create(cc.c3b(144, 144, 100), 200, 200)
            local waves = cc.Waves:create(5, cc.size(15, 10), pTable[1], pTable[2], true, true)
            local MoveBy = cc.MoveBy:create(2, cc.p(2, 4))
            local target1 = cc.NodeGrid:create()
            target1:runAction(cc.RepeatForever:create(waves))
            target1:addChild(warship_cell)
            ]]
            pNode:addChild(warship_cell)

            if var.status == 4 then
                local btnCellSize = Button_cell:getContentSize()
                local btnGain = ccui.Button:create("zhucheng_anniu_tishi.png", "zhucheng_anniu_tishi.png", me.localType)
                btnGain:setPressedActionEnabled(true)
                btnGain:setPosition(cc.p(btnCellSize.width / 2, 300))
                pNode:addChild(btnGain)
                local function finishTaskCallback(sender)
                    btnGain:setVisible(false)
                    -- 领取奖励
                    NetMan:send(_MSG.ship_expedition_reward(taskId))
                    showWaitLayer()
                end
                btnGain:addClickEventListener(finishTaskCallback)
                local pMoveBy1 = cc.MoveTo:create(1.5, cc.p(btnGain:getPositionX(), btnGain:getPositionY() + 30))
                local pMoveBy2 = cc.MoveTo:create(1.5, cc.p(btnGain:getPositionX(), btnGain:getPositionY() -30))
                btnGain:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))

                local btnSize = btnGain:getContentSize()
                local imageItem = ccui.ImageView:create("item_5.png")
                imageItem:setPosition(cc.p(btnSize.width / 2, 50))
                imageItem:setScale(0.3)
                btnGain:addChild(imageItem)
            end
        end
    end
    if bCreatNewShip == true then
        print("play effect create ship ")
        self:CommonAnimation("texiao_zhi_jianzao.png")
    end
end

function cityView:showActivityShip()
    local shipNode = me.assignWidget(self.maplayer, "activityShipNode")
    local target1 = shipNode:getChildByName("activityShip")
    if target1 ~= nil then
        return
    end
    local shipIcon = ccui.ImageView:create("activityShip.png")
    me.registGuiClickEvent(shipIcon, function()
        local promotionView = promotionView:create("promotionView.csb")
        promotionView:setViewTypeID(1)
        promotionView:setTaskGuideIndex(18)
        self:addChild(promotionView, me.MAXZORDER)
        me.showLayer(promotionView, "bg_frame")
    end )

    local waves = cc.Waves:create(5, cc.size(15, 10), 2, 2, true, true)
    local MoveBy = cc.MoveBy:create(2, cc.p(2, 4))
    local target1 = cc.NodeGrid:create()
    target1:runAction(cc.RepeatForever:create(waves))
    target1:addChild(shipIcon)
    target1:setName("activityShip")
    shipNode:addChild(target1)
end

function cityView:hideActivityShip()
    local shipNode = me.assignWidget(self.maplayer, "activityShipNode")
    local target1 = shipNode:getChildByName("activityShip")
    if target1 ~= nil then
        target1:stopAllActions()
        shipNode:removeChild(target1)
    end
end