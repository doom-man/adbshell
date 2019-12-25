-- [Comment]
-- jnmo
dayPayCell = class("dayPayCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
dayPayCell.__index = dayPayCell
function dayPayCell:create(...)
    local layer = dayPayCell.new(...)
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
function dayPayCell:ctor()
    print("dayPayCell ctor")
end
function dayPayCell:init()
    print("dayPayCell init")
    self.loadbar = me.assignWidget(self, "loadbar")
    self.rmb_val = me.assignWidget(self, "rmb_val")
    self.Text_time = me.assignWidget(self, "Text_time")
    self.Text_Desc = me.assignWidget(self, "Text_Desc")
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Text_Lengqu = me.assignWidget(self,"Text_Lengqu")
    self.Button_pay = me.registGuiClickEventByName(self, "Button_buy", function(node)
        if user.activityPayData[self.activity_id].list[user.activityPayData[self.activity_id].day].status == 1 then
            NetMan:send(_MSG.updateActivityDetail(user.activityPayData[self.activity_id].activityId))
        elseif user.activityPayData[self.activity_id].list[user.activityPayData[self.activity_id].day].status == 2 then            
            me.dispatchCustomEvent("promotionViewclose")
            TaskHelper.jumToPay()
        end
    end )
    me.registGuiClickEventByName(self, "Button_lingqu", function(node)
        NetMan:send(_MSG.updateActivityDetail(user.activityPayData[self.activity_id].activityId))
    end )
    return true
end
function dayPayCell:initActivity(id)
    self.activity_id = id
    local data = user.activityPayData[self.activity_id]
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(data.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        local rich = mRichText:create(activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0, Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0, 1))
        Panel_richText:addChild(rich)
    end

    --    local time = data.countDown-(me.sysTime()-data.openDate)/1000
    --    me.assignWidget(self,"Text_time"):setString(me.formartSecTime(time))
    --    self.timer = me.registTimer(-1,function ()
    --        time = time-1
    --        if time <= 0 then
    --            time = 0
    --            me.clearTimer(self.timer)
    --        end
    --        local t = me.formartSecTime(time)
    --        me.assignWidget(self,"Text_time"):setString(t)
    --    end,1)
    self.Text_time:setString(me.GetSecTime(data.openDate) .. "-" .. me.GetSecTime(data.endDate))
    self.lisener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_DAYPAY or msg.c.activityId == ACTIVITY_ID_SUM_DAYPAY or msg.c.activityId == ACTIVITY_ID_DAY_SPENDING then
                self:setRewardInfo(msg.c.list)
                local data = user.activityPayData[msg.c.activityId]
                self.rmb_val:setString(data.num)
                if data.activityId == ACTIVITY_ID_DAYPAY then
                    self.Text_Desc:setString("今日单笔充值达到")
                    self.rmb_val:setString(data.num)
                elseif data.activityId == ACTIVITY_ID_SUM_DAYPAY then
                    self.Text_Desc:setString("今日累计充值达到")
                    self.rmb_val:setString(data.value .. "/" .. data.num)
                elseif data.activityId == ACTIVITY_ID_DAY_SPENDING then
                    self.Text_Desc:setString("今日累计消费达到")
                    self.Image_Icon:loadTexture("gongyong_tubiao_zuanshi.png", me.localType)
                    self.rmb_val:setString(data.value .. "/" .. data.num)
                end
            end
        end
    end )

    if data.activityId == ACTIVITY_ID_DAYPAY then
        self.Text_Desc:setString("今日单笔充值达到")
        self.rmb_val:setString(data.num)
    elseif data.activityId == ACTIVITY_ID_SUM_DAYPAY then
        self.Text_Desc:setString("今日累计充值达到")
        self.rmb_val:setString(data.value .. "/" .. data.num)
    elseif data.activityId == ACTIVITY_ID_DAY_SPENDING then
        self.Text_Desc:setString("今日累计消费达到")
        self.Image_Icon:loadTexture("gongyong_tubiao_zuanshi.png", me.localType)
        self.rmb_val:setString(data.value .. "/" .. data.num)
    end
    me.putNodeOnRight(self.rmb_val, self.Text_Lengqu,5,cc.p(0,2))    
end
local function addAnim(node)
    local ani = createArmature("keji_jiesuo")
    node:addChild(ani)
    ani:getAnimation():play("donghua")
    ani:setPosition(cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2))
end
function dayPayCell:setRewardInfo(rewards)
    local pngs = { }
    pngs[#pngs + 1] = "huodong_baoxiang_lvse.png"
    pngs[#pngs + 1] = "huodong_baoxiang_lvse.png"
    pngs[#pngs + 1] = "huodong_baoxiang_lvse.png"
    pngs[#pngs + 1] = "huodong_baoxiang_lvse.png"
    pngs[#pngs + 1] = "huodong_baoxiang_lanse.png"
    local showred = false
    local curDay = user.activityPayData[self.activity_id].day
    for var = 1, 5 do
        local dayItem = me.assignWidget(self, "day" .. var)
        local Node_process = me.assignWidget(dayItem, "Node_process")
        local Panel_touch = me.assignWidget(dayItem, "touchWidget")
        local Text_Status = me.assignWidget(dayItem, "Text_Status")
        local data = rewards[var]
        local sp = Node_process:getChildByTag(5555)
        if sp == nil then
            sp = me.createSprite(pngs[var])
            sp:setTag(5555)
            if var ~= 5 then
                sp:setScale(0.5)
            else
                sp:setScale(0.55)
            end
            sp:setAnchorPoint(cc.p(0.5, 0.5))
            sp:setPosition(cc.p(0, 10))
            Node_process:addChild(sp)
        end
        if data.status == 0 then
            -- 已领取
            me.graySprite(sp)
            me.registGuiClickEvent(Panel_touch, function()
                local gdc = giftDetailCell:create("giftDetailCell.csb")
                gdc:setItemData_Limit(data.items)
                 me.popLayer(gdc)
            end )
            Text_Status:setString("已领取")
            Text_Status:setTextColor(me.convert3Color_("67ff02"))
            Text_Status:setVisible(true)
        elseif data.status == 1 then
            -- 未领取
            me.registGuiClickEvent(Panel_touch, function()
                NetMan:send(_MSG.updateActivityDetail(user.activityPayData[self.activity_id].activityId))
            end )
            Text_Status:setVisible(false)          
        elseif data.status == 2 then
            -- 未达到
            me.registGuiClickEvent(Panel_touch, function()
                local gdc = giftDetailCell:create("giftDetailCell.csb")
                gdc:setItemData_Limit(data.items)
                me.popLayer(gdc)
            end )
            if var < curDay then
                Text_Status:setString("未达到")
                Text_Status:setTextColor(me.convert3Color_("ffffff"))
                Text_Status:setVisible(true)
            else
                Text_Status:setVisible(false)
            end
        end
        Panel_touch:removeAllChildren()
        if tonumber(curDay) == var then
            if data.status ~= 0 then
                addAnim(Panel_touch)
            end
        end
    end
    self.loadbar:setPercent(100 * tonumber(curDay) / 5)
    local Panel_item = me.assignWidget(self, "Panel_Table")
    Panel_item:removeAllChildren()
    for key, var in pairs(rewards[tonumber(curDay)].items) do
        dump(var)
        local itemDef = cfg[CfgType.ETC][var[1]]
        local tmpButtonItem = me.assignWidget(self, "Button_item"):clone()
        tmpButtonItem:setVisible(true)
        me.assignWidget(tmpButtonItem, "Image_quality"):loadTexture(getQuality(itemDef.quality), me.localType)
        me.assignWidget(tmpButtonItem, "Goods_Icon"):loadTexture("item_" .. itemDef.icon .. ".png", me.localType)
        me.assignWidget(tmpButtonItem, "label_num"):setString(var[2])
        Panel_item:pushBackCustomItem(tmpButtonItem)
        me.registGuiClickEvent(tmpButtonItem, function(node)
            showPromotion(var[1], var[2])
        end )
    end
    local function setBtnStatus()
        local curState = user.activityPayData[self.activity_id].list[tonumber(curDay)].status
        if curState == 1 then
            me.assignWidget(self, "Button_buy"):setVisible(false)
            me.assignWidget(self, "Button_lingqu"):setVisible(true)
            me.assignWidget(self, "Button_yilingqu"):setVisible(false)
        elseif curState == 2 then
            if self.activity_id == ACTIVITY_ID_DAY_SPENDING then
                me.assignWidget(self, "Button_buy"):setVisible(false)
            else
                me.assignWidget(self, "Button_buy"):setVisible(true)
            end
            me.assignWidget(self, "Button_lingqu"):setVisible(false)
            me.assignWidget(self, "Button_yilingqu"):setVisible(false)
        else
            me.assignWidget(self, "Button_buy"):setVisible(false)
            me.assignWidget(self, "Button_lingqu"):setVisible(false)
            me.assignWidget(self, "Button_yilingqu"):setVisible(true)
        end
    end
    setBtnStatus()
    --移除红点
    if showred == false then    
        removeRedpoint(self.activity_id)
    end
end
function dayPayCell:onEnter()
    print("dayPayCell onEnter")
    self:setRewardInfo(user.activityPayData[self.activity_id].list)
    me.doLayout(self, me.winSize)    
end
function dayPayCell:onEnterTransitionDidFinish()
    print("dayPayCell onEnterTransitionDidFinish")
end
function dayPayCell:onExit()
    print("dayPayCell onExit")
    UserModel:removeLisener(self.lisener)
    -- 删除消息通知
end
function dayPayCell:close()
    self:removeFromParent()
end
