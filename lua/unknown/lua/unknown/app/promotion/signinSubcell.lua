signinSubcell = class("signinSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
signinSubcell.__index = signinSubcell
function signinSubcell:create(...)
    local layer = signinSubcell.new(...)
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

function signinSubcell:ctor()
    print("signinSubcell:ctor()")
    self.itemDatas = nil
    self.ScrollView_cell = nil
end
function signinSubcell:init()
    print("signinSubcell:init()")
    self.ScrollView_cell = me.assignWidget(self,"ScrollView_item")
    return true
end
function signinSubcell:updateScrollData(msg)
    if user.activityDetail.activityId == msg.c.activityId then
        local cell = self.ScrollView_cell:getChildByTag(msg.c.id)
        self:setCellStatus(cell,msg.c.status)
    end
end
function signinSubcell:setCellStatus(cell,status,index)
    me.assignWidget(cell, "num_bg"):setVisible(status ~= ACTIVITY_STATUS_2)
    me.assignWidget(cell, "ImageView_done"):setVisible(status == ACTIVITY_STATUS_2)
    if status == ACTIVITY_STATUS_2 then
        me.assignWidget(cell, "shuangbei"):setVisible(false)
    end
    me.assignWidget(cell,"Panel_gray"):setVisible(status == ACTIVITY_STATUS_2)
    me.assignWidget(cell,"daysTxt"):setVisible(status ~= ACTIVITY_STATUS_2)
    me.assignWidget(cell,"Button_item"):setTouchEnabled(status == ACTIVITY_STATUS_1)
    if me.toNum(index) == me.toNum(user.activityDetail.currentDay) and status == ACTIVITY_STATUS_1 then
        me.assignWidget(cell,"Panel_today"):setVisible(true)
        local anim = createArmature("huodong_donghua-1")
        anim:getAnimation():play("huodong_donghua")
        anim:setAnchorPoint(cc.p(0.5,0.5))
        anim:setScale(0.7)
        anim:setPosition(cc.p(me.assignWidget(cell,"Panel_today"):getContentSize().width/2,me.assignWidget(cell,"Panel_today"):getContentSize().height/2))
        me.assignWidget(cell,"Panel_today"):addChild(anim)
    else
        me.assignWidget(cell,"Panel_today"):removeAllChildren()
        me.assignWidget(cell,"Panel_today"):setVisible(false)
    end    
        me.registGuiClickEventByName(cell, "Image_quality", function(node)        
            local pTag = me.toNum(node.idx)
            local pData = self.itemDatas[pTag]
            local pDefId = pData.defId
            local pStatus = pData.status          
            if pStatus == ACTIVITY_STATUS_1 then
               NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,pDefId))
               removeRedpoint(user.activityDetail.activityId)
            else             
               local defId = pData.items[1][1]
               local pNum = pData.items[1][2]
               showPromotion(defId,pNum)
            end          
        end )
     
end
function signinSubcell:setCellData(cell,data,index)
    local defId = data.defId
    local cfg = cfg[CfgType.ETC][data.items[1][1]]
    if cfg == nil then
        __G__TRACKBACK__("CfgType.ETC id = "..data.items[1][1].." is nil  !!!")
        return
    end
    local itemNum = data.items[1][2]
    local status = data.status
    me.assignWidget(cell,"Button_item"):setTag(index)
    me.assignWidget(cell, "Goods_Icon"):loadTexture("item_"..cfg.icon..".png",me.localType)
    me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(cfg.quality),me.localType)
    me.assignWidget(cell, "Image_quality").idx = index
    me.assignWidget(cell, "daysTxt"):setString("第"..index.."天")
    me.assignWidget(cell, "label_num"):setString(itemNum)
    
    self:setCellStatus(cell,status,index)
end
function signinSubcell:initScrollData()


    local w,h = 118,120
    local totalH = #self.itemDatas/7
    if #self.itemDatas%7 ~= 0 then
        totalH = totalH+1   
    end
    
    local offH = self.ScrollView_cell:getContentSize().height-(h*totalH+10)
    for key, var in pairs(self.itemDatas) do
        local cell = me.assignWidget(self,"Button_item"):clone()
        cell:setVisible(true)
        if var.dshow==1 then
            me.assignWidget(cell, "shuangbei"):setVisible(true)
        else
            me.assignWidget(cell, "shuangbei"):setVisible(false)
        end
        self:setCellData(cell,var,key)
        local index = me.toNum(key)-1
        cell:setAnchorPoint(cc.p(0,0))
        if offH >= 0 then
            cell:setPosition(cc.p(w*(index%7)+7,self.ScrollView_cell:getContentSize().height-(math.floor(index/7)+1)*h-5))
        else
            cell:setPosition(cc.p(w*(index%7)+7,math.floor(totalH-math.floor(index/7)-1)*h+55))
        end
        self.ScrollView_cell:addChild(cell)
    end

    self.ScrollView_cell:setInnerContainerSize(cc.size(850,h*totalH+10))
    if offH < 0 then
        self.ScrollView_cell:setInnerContainerPosition(cc.p(0,offH))
    end
end
function signinSubcell:onEnter()
    print("signinSubcell:onEnter()")
    --me.doLayout(self,me.winSize)  
    self.itemDatas = user.activityDetail.items   
    self:initScrollData()
    
    if user.activityDetail.isShowDate==1 then
        me.assignWidget(self, "timeTxt"):setVisible(true)
        me.assignWidget(self, "timeTxt"):setString("双倍时间:"..me.GetSecTime_Foundation(user.activityDetail.openDate/1000).."至"..me.GetSecTime_Foundation(user.activityDetail.endDate/1000))
    end

    self.modelkey = UserModel:registerLisener(function(msg) -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_SIGNIN then
                self:updateScrollData(msg)
            end
        end
    end)
end
function signinSubcell:onExit()
    print("signinSubcell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
