newComerSubcell = class("newComerSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
newComerSubcell.__index = newComerSubcell
function newComerSubcell:create(...)
    local layer = newComerSubcell.new(...)
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

function newComerSubcell:ctor()
    print("newComerSubcell:ctor()")
    self.itemCells = {}
end
function newComerSubcell:init()
    self.timer = nil
    print("newComerSubcell:init()")
    return true
end
function newComerSubcell:initViewData()
     local function setBtnStatus()
        me.assignWidget(self,"Button_buy"):setEnabled(user.activityDetail.status==ACTIVITY_STATUS_1)
        if user.activityDetail.status==ACTIVITY_STATUS_1 then
            me.assignWidget(self,"Text_Diamond"):setVisible(true)
            me.assignWidget(self,"Image_diamond"):setVisible(true)
            me.assignWidget(self,"Button_buy"):setTitleText("")
        else
            me.assignWidget(self,"Text_Diamond"):setVisible(false)
            me.assignWidget(self,"Image_diamond"):setVisible(false)
            me.assignWidget(self,"Button_buy"):setTitleText("已购买")
        end
    end
    local Text_Diamond = me.assignWidget(self, "Text_Diamond")
    local Node_middle = me.assignWidget(self, "Node_middle")    
    Node_middle:removeAllChildren()
    me.assignWidget(self,"Image_diamond"):loadTexture(getItemIcon(user.activityDetail.itemid),me.localType)
    me.resizeImage(me.assignWidget(self,"Image_diamond"),33,33)
    me.clearTimer(self.timer)
    if user.activityDetail.time - (me.sysTime()/1000-user.activityDetail.startTime/1000) > 0 then
        local leftT = user.activityDetail.time - (me.sysTime()/1000-user.activityDetail.startTime/1000)
        self.timer = me.registTimer(leftT,function ()
            if leftT <=0 then
                me.clearTimer(self.timer)
                me.assignWidget(self, "Text_time"):setString(me.formartSecTime(0))
            else
                me.assignWidget(self, "Text_time"):setString(me.formartSecTime(leftT))
                leftT = leftT-1
            end
        end,1)
    else    
        me.assignWidget(self, "Text_time"):setString(me.formartSecTime(0))
    end
    
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local rt = mRichText:create(activity.desc,695)
        rt:setPosition(0,119)
        rt:setAnchorPoint(cc.p(0,1))
        me.assignWidget(self, "Node_richDetail"):addChild(rt)
    end
                
    me.assignWidget(self,"Button_buy"):setTouchEnabled(user.activityDetail.status==ACTIVITY_STATUS_1)
    setBtnStatus()

    Text_Diamond:setString(user.activityDetail.price)
--    if #self.itemCells > 0 then
--        for key, var in pairs(self.itemCells) do
--            var:removeFromParentAndCleanup(true)
--        end
--    end
    Node_middle:removeAllChildren()
    for key, var in pairs(user.activityDetail.items) do
        local cell = me.assignWidget(self, "Button_item"):clone()
        Node_middle:addChild(cell)
        cell:setVisible(true)
        cell:setTag(key)
        self.itemCells[#self.itemCells+1] = cell
        cell:setPosition(cc.p(135*me.toNum(key)+ 30, 208))
        local etc = cfg[CfgType.ETC][var[1]]
        if etc == nil then
            __G__TRACKBACK__("id = "..var[1].."的物品为空！")
            return
        end
        me.assignWidget(cell, "label_num"):setString(var[2])
        me.assignWidget(cell, "Goods_Icon"):loadTexture("item_"..etc.icon..".png",me.localType)
        me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(etc.quality),me.localType)
        me.registGuiClickEventByName(cell, "Button_item", function(node)        
            local pTag = me.toNum(node:getTag())
            local pData = user.activityDetail.items[pTag]                          
            local defId =pData[1]
            local pNum = pData[2]
            showPromotion(defId,pNum)
        end )
    end
     me.registGuiClickEventByName(self, "Button_buy", function(node)
        if getItemNum(user.activityDetail.itemid) < user.activityDetail.price then
            TaskHelper.jumToPay()
            if mainCity.promotionView then
                mainCity.promotionView:close()
            end
        else
            NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))
        end
    end)
end
function newComerSubcell:onEnter()   
   
    self:initViewData()
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId ~= ACTIVITY_ID_NEWCOMER then
                return
            end
            self:initViewData()
        end
    end)

   
    me.doLayout(self,me.winSize)  
end

function newComerSubcell:onExit()
    me.clearTimer(self.timer)
    if self.modelkey then
        UserModel:removeLisener(self.modelkey) -- 删除消息通知
    end
end
