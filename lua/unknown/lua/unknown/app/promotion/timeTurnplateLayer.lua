-- [Comment]
-- jnmo
timeTurnplateLayer = class("timeTurnplateLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
timeTurnplateLayer.__index = timeTurnplateLayer
function timeTurnplateLayer:create(...)
    local layer = timeTurnplateLayer.new(...)
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
function timeTurnplateLayer:ctor()
    print("timeTurnplateLayer ctor")
end
function timeTurnplateLayer:init()
    print("timeTurnplateLayer init")
    self.giftmark = me.assignWidget(self, "giftmark")
    self.Button_Run = me.registGuiClickEventByName(self, "Button_Run", function(node)
        if user.diamond < self.cost1[2] then
            askToRechage(0)
        else
            NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_TIME_TURNPLATE,nil ,nil, 1))
            me.setButtonDisable(self.Button_Run,false)
            me.setButtonDisable(self.Button_Run10,false)
        end
    end )
    self.Button_Run10 = me.registGuiClickEventByName(self, "Button_Run10", function(node)
        if user.diamond < self.cost10[2] then
            askToRechage(0)
        else
            NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_TIME_TURNPLATE,nil ,nil, 10))   
        end    
    end )
    me.registGuiClickEventByName(self, "Button_Shop", function(node)
        NetMan:send(_MSG.initShop(14))
        local shop = timeTurnplateShop:create("timeTurnplateShop.csb")
        me.popLayer(shop)
    end )
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Image_Icon:loadTexture("turnplateScore.png", me.localType)
    self.Text_time = me.assignWidget(self, "Text_time")
    self.scrolllist = { }
    self.lisener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_TIME_TURNPLATE then
                if msg.c.type == 0 then
                    if #msg.c.items == 1 then
                        self.bRun = true
                        self.startTime = me.sysTime()
                        self.xofw = 2
                        self.ofw = 1
                        for key, var in pairs(self.data) do
                            if msg.c.items[1].id == var.id then
                                self.stopnum = key                               
                                break
                            end
                        end
                        self.haverecode = false
                    else                      
                        local awardPanel = timeTurnplateAward:create("defSoldierPatrolAward.csb")
                        me.popLayer(awardPanel)
                        awardPanel:setData(msg.c.items)
                    end
                    local s = msg.c.score
                    user.turnplateScore = msg.c.score
                    self.Text_Score:setString(msg.c.score)
                elseif msg.c.type == 1 then
                    local s = msg.c.score
                    self.Text_Score:setString(msg.c.score)
                    me.setButtonDisable(self.Button_Run,true)
                    me.setButtonDisable(self.Button_Run10,true)
                elseif msg.c.type == 2 then
                    showTips("操作频繁，请稍后再试")
                    me.setButtonDisable(self.Button_Run,true)
                    me.setButtonDisable(self.Button_Run10,true)
                end
            end
        elseif checkMsg(msg.t, MsgCode.TIME_TURNPLARE_RECODE) then
            for key, var in pairs(msg.c.items) do
                local pcfg = cfg[CfgType.ETC][var[1]]
                local c, _ = me.getColorByQuality(pcfg.quality)
                local item = me.assignWidget(self, "Image_recode"):clone()
                local name = me.assignWidget(item, "Text_name")
                local Text_item_name = me.assignWidget(item, "Text_item_name")
                local Text_get = me.assignWidget(item, "Text_get")
                name:setString(msg.c.name)
                Text_item_name:setString(pcfg.name .. "x" .. var[2])
                me.putNodeOnRight(name, Text_get, 0, cc.p(0, 2))
                me.putNodeOnRight(Text_get, Text_item_name, 0, cc.p(0, 2))
                Text_item_name:setColor(c)
                item:setContentSize(cc.size(Text_item_name:getContentSize().width + Text_get:getContentSize().width + name:getContentSize().width + 20, 24))
                self.list:pushBackCustomItem(item)
                table.insert(self.scrolllist, item)
            end
            if #self.scrolllist < 6 then
                for key, var in pairs(self.scrolllist) do
                    local name = me.assignWidget(var, "Text_name")
                    local Text_item_name = me.assignWidget(var, "Text_item_name")
                    local Text_get = me.assignWidget(var, "Text_get")
                    local opt = math.min(50 + key * 40, 255)
                    name:setOpacity(opt)
                    Text_get:setOpacity(opt)
                    Text_item_name:setOpacity(opt)
                end
            else
                for var = 0, 5 do
                    local item = self.scrolllist[#self.scrolllist - var]
                    local name = me.assignWidget(item, "Text_name")
                    local Text_item_name = me.assignWidget(item, "Text_item_name")
                    local Text_get = me.assignWidget(item, "Text_get")
                    local opt = math.min(50 +(6 - var) * 40, 255)
                    name:setOpacity(opt)
                    Text_get:setOpacity(opt)
                    Text_item_name:setOpacity(opt)
                end
            end
            me.DelayRun( function(args)
                self.list:scrollToBottom(2, true)
            end )
        elseif checkMsg(msg.t, MsgCode.SHOP_BUY_AMOUNT) then
            user.turnplateScore = msg.c.score
            self.Text_Score:setString(user.turnplateScore)
        end

    end )
    self.Text_Score = me.assignWidget(self, "Text_Score")
    self.giftList = me.assignWidget(self, "giftList")
    self.list = me.assignWidget(self, "list")

    return true
end
function timeTurnplateLayer:initWithData(data)
    self.cost1 = data.c.onceNeed
    self.cost10 = data.c.tenNeed
    me.assignWidget(self,"Text_Item_num1"):setString( self.cost1[2])
    me.assignWidget(self,"Text_Item_num10"):setString( self.cost10[2])
    for var = 1, 1000 do
        local n = me.getRandom(#data.c.items)
        local m = me.getRandom(#data.c.items)        
        if n ~= m then
            local tmp = me.copyTab(data.c.items[n])
            data.c.items[n] = data.c.items[m]
            data.c.items[m] = tmp
        end
    end
    self.list:removeAllChildren()
    for key, var in pairs(data.c.history) do
        local pcfg = cfg[CfgType.ETC][var.itemId]
        local c, _ = me.getColorByQuality(pcfg.quality)
        local item = me.assignWidget(self, "Image_recode"):clone()
        local name = me.assignWidget(item, "Text_name")
        local Text_item_name = me.assignWidget(item, "Text_item_name")
        local Text_get = me.assignWidget(item, "Text_get")
        name:setString(var.name)
        Text_item_name:setString(pcfg.name .. "x" .. var.itemNum)
        me.putNodeOnRight(name, Text_get, 0, cc.p(0, 2))
        me.putNodeOnRight(Text_get, Text_item_name, 0, cc.p(0, 2))
        Text_item_name:setColor(c)

        item:setContentSize(cc.size(Text_item_name:getContentSize().width + Text_get:getContentSize().width + name:getContentSize().width + 20, 24))
        self.list:pushBackCustomItem(item)

        table.insert(self.scrolllist, item)
    end

    for key, var in pairs(self.scrolllist) do
        local name = me.assignWidget(var, "Text_name")
        local Text_item_name = me.assignWidget(var, "Text_item_name")
        local Text_get = me.assignWidget(var, "Text_get")
        name:setOpacity(50 + key * 40)
        Text_get:setOpacity(50 + key * 40)
        Text_item_name:setOpacity(50 + key * 40)
    end
    self.data = data.c.items
    self.Text_Score:setString(data.c.score)

    self.Text_time:setString(me.formartSecTime(data.c.countdown / 1000))
    local time = data.c.countdown / 1000
    self.timer = me.registTimer(-1, function(dt)
        time = time - 1
        if time > 0 then
            self.Text_time:setString(me.formartSecTime(time))
        else
            self.Text_time:setString("已结束")
        end
    end , 1)

    local Button_item = me.assignWidget(self, "Button_item")
    self.gifts = { }
    local sumnum = 10
    local function setCelldata(node, data)
        local pcfg = cfg[CfgType.ETC][data.item[1]]
        me.assignWidget(node, "Goods_Icon"):loadTexture("item_" .. pcfg.icon .. ".png", me.localType)
        me.assignWidget(node, "Image_quality"):loadTexture(getQuality(pcfg.quality), me.localType)
        local plabel = me.assignWidget(node, "label_num")
        plabel:setString(data.item[2])
    end
    for var = 1, sumnum do
        local item = Button_item:clone()
        item:setVisible(true)
        self.giftmark:addChild(item)
        item:setPositionX(item:getContentSize().width * var - item:getContentSize().width / 2)
        item:setPositionY(item:getContentSize().height / 2)
        self.gifts[var] = item
        self.gifts[var].giftindex = var
        setCelldata(item, self.data[var])

    end
    self.giftList:removeAllChildren()
    for key, var in pairs(data.c.itemsView) do
        local pcfg = cfg[CfgType.ETC][tonumber(var)]
        local item = me.assignWidget(self, "Button_item_0"):clone()
        local temp = { }
        temp.item = { }
        temp.item[1] = var
        temp.item[2] = 1
        setCelldata(item, temp)
        self.giftList:pushBackCustomItem(item)
        me.registGuiClickEvent(item, function(args)
            local defId = tonumber(var)
            local pNum = 1
            showPromotion(defId, pNum)
        end )
    end
    self.bRun = false
    self.curIdx = 7
    self.ofw = 1
    local lastIdx = sumnum
    self.xofw = 1
    self.xxx = 0
    self.giftindex = 7
    local num = #self.data
    print("max num = " .. num)
    local xstep = 2
    local curidx = 0
    self.haverecode = false
    self.runtimer = me.registTimer(-1, function(dt)
        if self.bRun then
            for var = 1, sumnum do
                self.gifts[var]:setPositionX(self.gifts[var]:getPositionX() - self.ofw)
            end
            for var = 1, sumnum do
                if self.gifts[var]:getPositionX() < - self.gifts[var]:getContentSize().width - 100 then
                    self.gifts[var]:setPositionX(self.gifts[lastIdx]:getPositionX() + self.gifts[var]:getContentSize().width)
                    if self.giftindex < num then
                        self.gifts[var].giftindex = self.giftindex
                        self.giftindex = self.giftindex + 1
                    else
                        local x = self.gifts[lastIdx].giftindex
                        if tonumber(x) == num then
                            self.gifts[var].giftindex = 1
                        else
                            self.gifts[var].giftindex = tonumber(x) + 1
                        end
                    end
                    setCelldata(self.gifts[var], self.data[self.gifts[var].giftindex])
                    lastIdx = var
                    curidx = tonumber(self.gifts[lastIdx].giftindex)
                    -- print("curidx = "..curidx)
                    break
                end
            end

            if me.sysTime() - self.startTime >= 4000 then
                if self.haverecode == false then
                    local st = 0
                    if self.stopnum <= 37 then
                        st = self.stopnum + num - 37
                    else
                        st = self.stopnum - 37
                    end
                    if curidx == st then
                        self.xofw = -1
                        self.haverecode = true
                        self.xxx = 0
                        xstep = 2
                    end
                end
                if self.haverecode then
                    self.xxx = self.xxx + 1
                    if self.xxx % xstep == 0 then
                        self.ofw = self.ofw + self.xofw
                        xstep = xstep + 1
                        self.xxx = 1
                    end
                end
            else
                self.ofw = self.ofw + self.xofw
                self.ofw = math.min(self.ofw, 30)
            end
            if self.ofw == 0 then
                self.bRun = false
                NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_TIME_TURNPLATE,nil ,nil, 0))
            end

        end
    end )
end
function timeTurnplateLayer:onEnter()
    print("timeTurnplateLayer onEnter")
    me.doLayout(self, me.winSize)
    removeRedpoint(ACTIVITY_ID_TIME_TURNPLATE)
end
function timeTurnplateLayer:onEnterTransitionDidFinish()
    print("timeTurnplateLayer onEnterTransitionDidFinish")
end
function timeTurnplateLayer:onExit()
    print("timeTurnplateLayer onExit")
    me.clearTimer(self.runtimer)
    UserModel:removeLisener(self.lisener)
    me.clearTimer(self.timer)
end
function timeTurnplateLayer:close()
    self:removeFromParent()
end

