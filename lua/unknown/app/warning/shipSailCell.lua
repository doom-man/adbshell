shipSailCell = class("shipSailCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)

function shipSailCell:create(...)
    local layer = shipSailCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function shipSailCell:ctor()
    self.qualityColor = {
        cc.c3b (255, 255, 255),
        cc.c3b (0, 255, 0),
        cc.c3b (101, 220, 246),
        cc.c3b (128 , 0, 128),
        cc.c3b (233 , 150 , 122),
        cc.c3b (255, 0, 0),
    }
end

function shipSailCell:onEnter()
    self.customListener = me.RegistCustomEvent ("leftTimeTick", function (event)
        self:updateLeftTime ()
    end)

    self.customListener2 = me.RegistCustomEvent ("sailTimeOver", function (event)
        self:updateView ()
    end)
end

function shipSailCell:onExit()
    if self.customListener then
        me.RemoveCustomEvent (self.customListener)
    end
    if self.customListener2 then
        me.RemoveCustomEvent (self.customListener2)
    end
end

function shipSailCell:init()
    print("shipSailCell init")

    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    self.imageCellBg    = me.assignWidget(self,"image_cellbg")
    self.imageTaskIcon    = me.assignWidget(self,"image_task_icon")
    self.textTaskName     = me.assignWidget(self,"text_cell_name")

    self.textGunNeed = me.assignWidget(self,"text_gun_need")
    self.textGunCount = me.assignWidget(self,"text_gun_count")

    self.textBackSailTime = me.assignWidget(self,"text_sail_time")
    self.imageShipType = me.assignWidget(self,"image_ship_type")
    self.textTaskOver = me.assignWidget(self,"text_task_over")
    self.nodeReward = me.assignWidget(self,"node_reward")

    self.imageItem        = me.assignWidget(self,"image_item")
    self.textItemNum      = me.assignWidget(self,"text_item_num")

    self.imageBack        = me.assignWidget(self,"image_back")

    self.btnSpeed         = me.assignWidget(self,"btn_speed")
    self.btnBack          = me.assignWidget(self,"btn_return")
    self.btnDispatch      = me.assignWidget(self,"btn_dispatch")

    self.imageDiamond     = me.assignWidget(self,"image_diamond")
    self.textDiamond      = me.assignWidget(self,"text_diamond")

    local function speedShipSailCallback (sender)
        -- 加速
        NetMan:send(_MSG.ship_expedition_speed(self.sailTaskData.taskId))
        showWaitLayer ()
    end

    local function backShipSailCallback (sender)
        -- 召回
        local tipStr = "召回后本次航海依然会消耗航海次数且不会获得奖励，确定召回吗？"

        local function sailShipBackCallback(eventStr)
            if eventStr == "ok" then
                NetMan:send(_MSG.ship_expedition_cancel(self.sailTaskData.taskId))
                showWaitLayer ()
            end
        end

        me.showMessageDialog (tipStr, sailShipBackCallback, nil, nil, 30)
    end

    local function dispatchShipSailCallback (sender)
        if sender.status == 1 then -- 未航海
            -- 派遣
            local bHaveShipIdle = false
            for k, v in pairs (user.warshipData) do
                if v.status == 3 then
                    bHaveShipIdle = true
                    break
                end
            end
            if bHaveShipIdle == false then
                showTips ("当前没有可派遣的战舰")
                return
            end
            if user.shipSailData.taskMax - user.shipSailData.taskTm <= 0 then
                showTips ("今日派遣次数已用完")
                return
            end
            local dispatchView = shipDispatchView:create("warning/shipDispatchView.csb")
            me.runningScene():addChild(dispatchView, me.MAXZORDER)
            dispatchView:setCurSailTaskId (self.sailTaskData.taskId)
            me.showLayer(dispatchView,"bg")
        elseif sender.status == 3 then -- 航海已完成
            -- 领取奖励
            NetMan:send(_MSG.ship_expedition_reward(self.sailTaskData.taskId))
            showWaitLayer ()
        end
    end
    self.btnSpeed:addClickEventListener (speedShipSailCallback)
    self.btnBack:addClickEventListener (backShipSailCallback)
    self.btnDispatch:addClickEventListener (dispatchShipSailCallback)

    return true
end

function shipSailCell:setSailTaskData(sailData)
    self.sailTaskData = sailData
end

function shipSailCell:updateView()
    dump (self.sailTaskData.taskId)
    local shipExpeditionCfg = cfg[CfgType.SHIP_EXPEDITION] [self.sailTaskData.taskId]

    local taskIcon = getShipSailTaskTexure (shipExpeditionCfg.icon)
    self.imageTaskIcon:loadTexture (taskIcon)
    local textColor = self.qualityColor[shipExpeditionCfg.quality]
    self.textTaskName:setTextColor (textColor)
    self.textTaskName:setString (shipExpeditionCfg.name)
    self.imageShipType:loadTexture (getWarshipImageTexture (shipExpeditionCfg.type))
    me.resizeImage(self.imageShipType, 100, 90)

    if self.sailTaskData.taskStatus == 0 then  -- 未远征
        self.imageBack:setVisible (false)
        self.btnSpeed:setVisible (false)
        self.btnBack:setVisible (false)
        self.btnDispatch:setVisible (true)
        me.assignWidget(self.btnDispatch,"title"):setString("派遣战舰")
        self.btnDispatch.status = 1
        self.btnDispatch:loadTextureNormal("ui_ty_button_cheng_154x56.png")

        local needTime = shipExpeditionCfg.time
        local hour = math.floor (needTime / 3600)
        local minute = math.fmod (math.floor (needTime / 60), 60)
        local second = math.fmod (needTime, 60)
        local strSailTime = string.format ("出航所需：%02d:%02d:%02d", hour, minute, second)
        self.textBackSailTime:setVisible (true)
        self.textBackSailTime:setString (strSailTime)
        self.textBackSailTime:setTextColor (textColor)

        self.textGunNeed:setVisible (true)
        self.textGunCount:setVisible (true)
        self.textGunCount:setString (tostring (shipExpeditionCfg.ammo))

        self.imageDiamond:setVisible (false)
        self.textDiamond:setVisible (false)
        --self.imageCellBg:loadTexture ("zhanjian_hang_beijing_zhengchang.png")

        self.textTaskOver:setVisible (false)
    elseif self.sailTaskData.taskStatus == 1 then -- 远征中
        self.imageBack:setVisible (true)
        self.btnSpeed:setVisible (true)
        self.btnBack:setVisible (true)
        self.btnDispatch:setVisible (false)
        self.btnDispatch.status = 2

        local needTime = self.sailTaskData.leftTime
        local hour = math.floor (needTime / 3600)
        local minute = math.fmod (math.floor (needTime / 60), 60)
        local second = math.fmod (needTime, 60)
        local strSailTime = string.format ("航行时间：%02d:%02d:%02d", hour, minute, second)
        self.textBackSailTime:setVisible (true)
        self.textBackSailTime:setString (strSailTime)
        self.textBackSailTime:setTextColor (cc.c4b (253, 246, 64, 255))

        self.textGunNeed:setVisible (false)
        self.textGunCount:setVisible (false)

        self.imageDiamond:setVisible (true)
        self.textDiamond:setVisible (true)
        self.textDiamond:setString (tostring (self.sailTaskData.tprice))
        --self.imageCellBg:loadTexture ("zhanjian_hang_beijing_zhengchang.png")

        local shipIcon = getWarshipImageTexture (self.sailTaskData.shipId)
        self.imageBack:loadTexture (shipIcon)

        self.textTaskOver:setVisible (false)
    elseif self.sailTaskData.taskStatus == 3 then -- 任务已完成
        self.imageBack:setVisible (false)
        self.btnSpeed:setVisible (false)
        self.btnBack:setVisible (false)
        self.btnDispatch:setVisible (false)
        self.textBackSailTime:setVisible (false)
        self.textTaskOver:setVisible (true)

        self.imageDiamond:setVisible (false)
        self.textDiamond:setVisible (false)

        self.textGunNeed:setVisible (false)
        self.textGunCount:setVisible (false)
        --self.imageCellBg:loadTexture ("zhanjian_hang_beijing_wanchen.png")
    elseif self.sailTaskData.taskStatus == 2 then  -- 可领取奖励
        self.imageBack:setVisible (false)
        self.btnSpeed:setVisible (false)
        self.btnBack:setVisible (false)
        self.btnDispatch:setVisible (true)
        me.assignWidget(self.btnDispatch,"title"):setString("领取")
        self.btnDispatch.status = 3
        self.btnDispatch:loadTextureNormal("ui_ty_button_lv154x56.png")

        local strSailTime = "已完成"
        self.textBackSailTime:setVisible (true)
        self.textBackSailTime:setString (strSailTime)
        self.textBackSailTime:setTextColor (cc.c4b (0, 255, 0, 255))

        self.textGunNeed:setVisible (false)
        self.textGunCount:setVisible (false)

        self.imageDiamond:setVisible (false)
        self.textDiamond:setVisible (false)
        --self.imageCellBg:loadTexture ("zhanjian_hang_beijing_wanchen.png")

        self.textTaskOver:setVisible (false)
    end
    -- 奖励
    local strAllReward = string.split (shipExpeditionCfg.reward, ",")
    local offsetX = 150
    self.nodeReward:removeAllChildren ()
    for k, v in pairs (strAllReward) do
        local strReward = string.split (strAllReward [k], ":")
        local rewardIcon = getItemIcon (tonumber (strReward[1]))

        local imageReward = ccui.ImageView:create (rewardIcon)
        local size = imageReward:getContentSize ()
        imageReward:setTouchEnabled (true)
        imageReward:setScale9Enabled (true)
        imageReward:setCapInsets (cc.rect (0, 0, size.width, size.height))
        imageReward:ignoreContentAdaptWithSize (false)
        imageReward:setContentSize (cc.size (35, 35))
        self.nodeReward:addChild (imageReward)

        local textReward = ccui.Text:create ()
        textReward:setAnchorPoint (cc.p (0, 0.5))
        textReward:setTextColor (cc.c4b (255, 255, 255, 255))
        textReward:setFontSize (24)
        textReward:setString ("×" .. strReward [2])
        local textReward2 = ccui.Text:create ()
        textReward2:setAnchorPoint (cc.p (0, 0.5))
        textReward2:setTextColor (cc.c4b (0, 255, 0, 255))
        textReward2:setFontSize (24)
        textReward2:setString ("+" .. strReward [2]*(user.propertyValue["HangHaiBonus"] or 0) ) 
        textReward2:setVisible(tonumber((user.propertyValue["HangHaiBonus"] or 0))~=0)
        self.nodeReward:addChild (textReward)
        self.nodeReward:addChild (textReward2)
        imageReward:setPositionX (offsetX * (k - 1))
        textReward:setPositionX (offsetX * (k - 1) + 30)
        textReward2:setPositionX (textReward:getPositionX()+textReward:getContentSize().width/2 + textReward2:getContentSize().width/2 + 10)
        local function showItemInfoCallback(sender)
            dump(strReward)
            showPromotion (tonumber (strReward[1]), tonumber (strReward [2]))
        end
        imageReward:addClickEventListener (showItemInfoCallback)
    end
    -- 额外奖励
    local extraReward = string.split (shipExpeditionCfg.extreward, ":")
    local rewardIcon = getItemIcon (tonumber (extraReward[1]))
    
    self.imageItem:loadTexture (rewardIcon)
    
    self.imageItem:setContentSize (cc.size (38, 41))

    self.textItemNum:setString ("×" .. extraReward[2])
    local function showItemDetailCallback(sender)
        showPromotion (tonumber (extraReward[1]), tonumber (extraReward [2]))
    end
    self.imageItem:addClickEventListener (showItemDetailCallback)
end

function shipSailCell:updateLeftTime()
    if self.sailTaskData.taskStatus == 1 and self.sailTaskData.leftTime > 0 then -- 远征中
        local needTime = self.sailTaskData.leftTime
        local hour = math.floor (needTime / 3600)
        local minute = math.fmod (math.floor (needTime / 60), 60)
        local second = math.fmod (needTime, 60)
        local strSailTime = string.format ("航行时间：%02d:%02d:%02d", hour, minute, second)
        self.textBackSailTime:setString (strSailTime)

        local speedDiamond = self.textDiamond:getString ()
        if tonumber (speedDiamond) ~= self.sailTaskData.tprice then
            self.textDiamond:setString (tostring (self.sailTaskData.tprice))
        end
    end
end