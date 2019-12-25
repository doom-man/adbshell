LabourActivity = class("LabourActivity",function(...)
    return cc.CSLoader:createNode(...)
end)
LabourActivity.__index = LabourActivity
function LabourActivity:create(...)
    local layer = LabourActivity.new(...)
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

function LabourActivity:ctor()
    print("LabourActivity:ctor()")
    self.CountDown = nil
end
function LabourActivity:init()
    print("LabourActivity:init()")
    self.timers = {}
    self.Panel_items = {}
    self.ScrollView_Items = me.assignWidget(self,"ScrollView_Items")
    return true
end
function LabourActivity:onEnter()  
    me.assignWidget(self, "Panel_item"):setVisible(false)
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end
    local pCountTime = user.activityDetail.countDown/1000
    me.assignWidget(self,"Text_newSpringCD"):setVisible(true)
    me.assignWidget(self,"Text_newSpringCD"):setString("结束倒计时: "..me.formartSecTime(pCountTime))
    me.clearTimer(self.CountDown)
    self.CountDown = me.registTimer(-1,function (dt)
          if pCountTime > 0 then
             pCountTime = pCountTime - 1
             me.assignWidget(self,"Text_newSpringCD"):setString("结束倒计时: "..me.formartSecTime(pCountTime))
          else
             me.clearTimer(self.CountDown)
             me.assignWidget(self,"Text_newSpringCD"):setVisible(false)
          end
    end,1)   
    
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_LADOUR or ACTIVITY_ID_LADOUR_  then
                self:setScrollView()
            end
        end
    end)
    self:setScrollView()
    me.doLayout(self,me.winSize)
end
function LabourActivity:setType(Type)
     self.pHintStr = "五一"
     if Type ==  ACTIVITY_ID_LADOUR then
        self.pHintStr = "五一"
     elseif  Type ==  ACTIVITY_ID_LADOUR_ then
        self.pHintStr = "端午节"
     elseif  Type ==  ACTIVITY_ID_MID_AUTUMN_FESTIVAL then
        self.pHintStr = "中秋节"
     end
end
function LabourActivity:setScrollView()
    if table.nums(self.timers) > 0 then
        for key, var in pairs(self.timers) do
            me.clearTimer(var)
        end
    end    
    if self.ScrollView_Items then
        self.ScrollView_Items:removeAllChildren()
        me.tableClear(self.Panel_items)
    end

    self.listData = user.activityDetail.list   
     
    if self.listData == nil then
        __G__TRACKBACK__("self.listData = nil !!!")
        return
    end

    if 258*#self.listData <= 775 then
        self.ScrollView_Items:setInnerContainerSize(cc.size(775,391))
    else
        self.ScrollView_Items:setInnerContainerSize(cc.size(258*#self.listData,391))
    end
    for index = 1, #self.listData do
        self:setScrollCellByIndex(index)
    end
end

function LabourActivity:setScrollCellByIndex(index)
    local cellData = self.listData[index]
    if cellData == nil then
        __G__TRACKBACK__("self.listData[me.toNum(index+1)] 数据为nil   index+1 = "..index+1)
        return
    end
    -- dump(cellData)
    self.Panel_items[index] = me.assignWidget(self, "Panel_item"):clone()
    self.ScrollView_Items:addChild(self.Panel_items[index])
    self.Panel_items[index]:setVisible(true)
    self.Panel_items[index]:setTag(index)
    self.Panel_items[index]:setPosition(cc.p(258*(index-1),0))
    local Panel_sprite = me.assignWidget(self.Panel_items[index],"Panel_sprite")
    sp = me.createSprite("huodong_beijing_"..cellData.bg..".png")
    sp:setAnchorPoint(cc.p(0.5,0.5))
    sp:setPosition(cc.p(Panel_sprite:getContentSize().width/2,Panel_sprite:getContentSize().height/2))
    sp:setTag(555)
    Panel_sprite:addChild(sp)
    me.assignWidget(self.Panel_items[index],"Text_title"):setString(cellData.name)
    me.assignWidget(self.Panel_items[index],"Text_sale"):setString("赠 "..cellData.gem.."钻石")
    local btn = me.assignWidget(self.Panel_items[index],"Button_get")
    local chargeItem = user.recharge[cellData.rid]
    if chargeItem then
        btn:setTitleText("￥"..chargeItem.rmb)
    else
        btn:setTitleText("￥ ?")
        __G__TRACKBACK__("user.recharge id".." is nil  !!!!")
    end
    me.assignWidget(self.Panel_items[index],"Image_got"):setVisible(false)   
    me.assignWidget(self.Panel_items[index],"Image_time"):setVisible(false)
    me.assignWidget(self.Panel_items[index],"Text_limit"):setVisible(false)  
    
    me.registGuiClickEventByName(self.Panel_items[index],"Button_get",function()
        local tmpData = self.listData[me.toNum(self.Panel_items[index]:getTag())]
        dump(tmpData)
        local chargeItem = user.recharge[tmpData.rid]
        dump(chargeItem)
        if chargeItem then         
           payMgr:getInstance():checkChooseIap(chargeItem)                     
        else
            __G__TRACKBACK__("user.recharge id"..tmpData.rid.." is nil  !!!!")
        end
    end)
        
    me.assignWidget(self.Panel_items[index],"Button_detail"):setSwallowTouches(false)  
    me.registGuiClickEventByName(self.Panel_items[index],"Button_detail",function ()
        local tmpData = self.listData[me.toNum(self.Panel_items[index]:getTag())]
        local def = cfg[CfgType.ETC][tmpData.itemId]
        local gdc = giftDetailCell:create("giftDetailCell.csb")
        gdc:setItemData(def.useEffect)
        mainCity:addChild(gdc,me.MAXZORDER)                        
    end)
     me.registGuiClickEventByName(self.Panel_items[index],"Image_1",function ()
        self:InterherReward()                  
    end)
end
function  LabourActivity:InterherReward()
     me.reconnectDialog("拥有"..self.pHintStr.."礼品卷会获得额外奖励", function(args)
        if args == "ok" then
         --  
        else
                    
        end
     end )
end
function LabourActivity:onExit()
    if self.CountDown then
        me.clearTimer(self.CountDown)
    end
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
    end
    self.timers = nil
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end


