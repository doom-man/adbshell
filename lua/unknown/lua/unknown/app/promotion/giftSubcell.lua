giftSubcell = class("giftSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
giftSubcell.__index = giftSubcell
function giftSubcell:create(...)
    local layer = giftSubcell.new(...)
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

function giftSubcell:ctor()
    print("giftSubcell:ctor()")
end
function giftSubcell:init()
    print("giftSubcell:init()")
    self.timers = {}
    self.Panel_items = {}
    self.ScrollView_Items = me.assignWidget(self,"ScrollView_Items")
    self.ScrollView_Items:setScrollBarEnabled(false)
    self.Image_Reset_Icon = me.assignWidget(self,"Image_Reset_Icon")
    self.Text_Reset_Gem = me.assignWidget(self,"Text_Reset_Gem")
    self.Button_Reset = me.registGuiClickEventByName(self,"Button_Reset",function (node)           
           local num = 0
           for key, var in pairs(user.pkg) do
                 if var.defid == 77 then
                      num = var.count
                      break
                 end
           end    
           if num >= 1 then
                 NetMan:send(_MSG.refreshgift())
           else
            showTips("道具不足")
           end
    end)

    
    return true
end
function giftSubcell:onEnter()  
    me.assignWidget(self, "Panel_item"):setVisible(false)
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create( user.activityDetail.desc or  activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end
    local Text_countDown = me.assignWidget(self,"Text_countDown")
    if user.activityDetail.openDate > 0 and user.activityDetail.endDate then
        Text_countDown:setString(me.GetSecTime(user.activityDetail.openDate).."--"..me.GetSecTime(user.activityDetail.endDate))
    else
        me.assignWidget(self,"Text_title_time"):setVisible(false)
        Text_countDown:setString("永久")
    end
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_GIFT or msg.c.activityId == ACITVITY_ID_NEW_SPRING  then
                self:setScrollView()
            end
        end
    end)
    self:setScrollView()
    me.doLayout(self,me.winSize)    
    removeRedpoint(user.activityDetail.activityId)    
end
local width = 289
function giftSubcell:setScrollView()
    self.Image_Reset_Icon:loadTexture("item_77.png",me.localType)
    local num = 0
    for key, var in pairs(user.pkg) do
         if var.defid == 77 then
              num = var.count
              break
         end
    end 
    me.resizeImage(self.Image_Reset_Icon,37,37)
    me.registGuiClickEvent(self.Image_Reset_Icon,function (node)
          showPromotion(77,1)
    end)
    self.Text_Reset_Gem:setString( num.. "/1")
    if self.activityId == ACTIVITY_ID_GIFT then 
        self.Image_Reset_Icon:setVisible(true)
        self.Text_Reset_Gem:setVisible(true)
        self.Button_Reset:setVisible(true)
    elseif self.activityId == ACTIVITY_SHIP_PACKAGE or self.activityId == ACTIVITY_ID_DAYGIFT  then  
        self.Image_Reset_Icon:setVisible(false)
        self.Text_Reset_Gem:setVisible(false)
        self.Button_Reset:setVisible(false)
    end     
    if table.nums(self.timers) > 0 then
        for key, var in pairs(self.timers) do
            me.clearTimer(var)
        end
    end

    if self.ScrollView_Items then
        self.ScrollView_Items:removeAllChildren()
        me.tableClear(self.Panel_items)
    end

    self.listData = user.activityDetail.rewards   
    if self.listData == nil then
        __G__TRACKBACK__("self.listData = nil !!!")
        return
    end

    if width*#self.listData <= 837 then
        self.ScrollView_Items:setInnerContainerSize(cc.size(837, 390))
    else
        self.ScrollView_Items:setInnerContainerSize(cc.size(width*#self.listData, 390))
    end
    for index = 1, #self.listData do
        self:setScrollCellByIndex(index)
    end
    me.assignWidget(self,"Image_Arrow"):setVisible(#self.listData > 3)
end

function giftSubcell:setScrollCellByIndex(index)
    local cellData = self.listData[index]
    if cellData == nil then
        __G__TRACKBACK__("self.listData[me.toNum(index+1)] 数据为nil   index+1 = "..index+1)
        return
    end

    self.Panel_items[index] = me.assignWidget(self, "Panel_item"):clone()
    self.ScrollView_Items:addChild(self.Panel_items[index])
    self.Panel_items[index]:setVisible(true)
    self.Panel_items[index]:setTag(index)
    self.Panel_items[index]:setPosition(cc.p(width*(index-1) + 10, 8))
    local Panel_sprite = me.assignWidget(self.Panel_items[index],"Panel_sprite")
    local sp = me.createSprite("huodong_beijing_"..cellData.bg..".png")
    sp:setAnchorPoint(cc.p(0.5,0.5))
    sp:setPosition(cc.p(Panel_sprite:getContentSize().width/2, Panel_sprite:getContentSize().height/2))
    sp:setTag(555)
    Panel_sprite:addChild(sp)
    me.assignWidget(self.Panel_items[index],"Text_title"):setString(cellData.name)
    me.assignWidget(self.Panel_items[index],"Text_sale"):setString(cellData.jjgold.."元宝")
    me.assignWidget(self.Panel_items[index],"Text_sale"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))   
    me.assignWidget(self.Panel_items[index],"Text_Price"):setString(cellData.descPrice)         
    me.assignWidget(self.Panel_items[index],"Text_Give"):setString("额外获得价值".. cellData.descGold .."元宝的礼包") 
    me.assignWidget(self.Panel_items[index],"Text_Give"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1)) 
    me.assignWidget(self.Panel_items[index],"Text_limit"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1)) 
    me.assignWidget(self.Panel_items[index],"Text_time"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1)) 
    me.assignWidget(self.Panel_items[index],"Text_Price"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1)) 
    me.assignWidget(self.Panel_items[index],"Text_Rmb"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1)) 

    local Text_Rmb = me.assignWidget(self.Panel_items[index],"Text_Rmb")    
    local btn = me.assignWidget(self.Panel_items[index],"Button_get")
    local chargeItem = user.recharge[cellData.rid]
    if chargeItem then
        Text_Rmb:setString("￥"..chargeItem.rmb)            
    else
        Text_Rmb:setString("￥ ?")
        __G__TRACKBACK__("user.recharge id".." is nil  !!!!")
    end
    local Panel_ship_number = me.assignWidget(self.Panel_items[index],"Panel_ship_number"):removeAllChildren()
    Panel_ship_number:setVisible(false)
    if user.activityDetail.activityId == ACTIVITY_SHIP_PACKAGE or user.activityDetail.activityId == ACTIVITY_ID_DAYGIFT then
        Panel_ship_number:setVisible(true)
         me.setButtonDisable(btn,true)
       me.assignWidget(self.Panel_items[index],"Image_36"):setVisible(false)    
       me.assignWidget(self.Panel_items[index],"Text_time"):setVisible(false)
       me.assignWidget(self.Panel_items[index],"Text_limit"):setString("每日限购"..cellData.limit.."/"..cellData.value.."次")       
       me.assignWidget(self.Panel_items[index],"Text_limit"):setVisible(false)    
       me.registGuiClickEventByName(self.Panel_items[index],"Button_get",function(node)
            local tmpData = self.listData[me.toNum(self.Panel_items[index]:getTag())]
            local chargeItem = user.recharge[tmpData.rid]
            if chargeItem then
                me.setWidgetCanTouchDelay(node,1)
                payMgr:getInstance():checkChooseIap(chargeItem)
            else
                __G__TRACKBACK__("user.recharge id"..tmpData.rid.." is nil  !!!!")
            end
        end)
        local Button = me.assignWidget(self.Panel_items[index],"Button_get")
        local pStrNumber = "<txt0012,B5B5B4>每日限购：&<txt0012,B5B5B4>"..cellData.value.."/"..cellData.limit.."次&"          
        if cellData.limit <= cellData.value then
             pStrNumber = "<txt0012,B5B5B4>每日限购：&<txt0012,B5B5B4>"..cellData.value.."/"..cellData.limit.."次&"
             me.setButtonDisable(btn,false)
        end
        local rcfn = mRichText:create(pStrNumber)
        rcfn:setAnchorPoint(cc.p(0.5,0.5))
        rcfn:setPosition(cc.p(50, 15))
        Panel_ship_number:addChild(rcfn)
    else
        if cellData.value < cellData.limit and cellData.time and cellData.time > 0 then -- 没超限购次数,正常倒计时
            me.setButtonDisable(btn,true)            
            me.assignWidget(self.Panel_items[index],"Text_sale"):setTextColor(cc.c3b(0xff, 0xd6, 0x85))
            
            me.assignWidget(self.Panel_items[index],"Text_limit"):setVisible(true)
           
            me.registGuiClickEventByName(self.Panel_items[index],"Button_get",function(node)
                local tmpData = self.listData[me.toNum(self.Panel_items[index]:getTag())]
                local chargeItem = user.recharge[tmpData.rid]
                if chargeItem then
                    me.setWidgetCanTouchDelay(node,1)
                    payMgr:getInstance():checkChooseIap(chargeItem)
                else
                    __G__TRACKBACK__("user.recharge id"..tmpData.rid.." is nil  !!!!")
                end
            end)
            me.assignWidget(self.Panel_items[index],"Text_limit"):setString("限购"..cellData.limit-cellData.value.."次")
            if self.timers[me.toStr(cellData.id)] == nil then
                local currentT = 0
                if cellData.time - (me.sysTime()/1000-cellData.startTime/1000) > 0 then
                    currentT = cellData.time - (me.sysTime()/1000-cellData.startTime/1000)
                end
                me.assignWidget(self.Panel_items[index],"Text_time"):setString(me.formartSecTime(currentT))    
                local ii = index*3
                self.timers[me.toStr(cellData.id)] = me.registTimer(-1,function ()
                    if cellData.time - (me.sysTime()/1000-cellData.startTime/1000) > 0 then
                        me.assignWidget(self.Panel_items[index],"Text_time"):setString(me.formartSecTime(cellData.time - (me.sysTime()/1000-cellData.startTime/1000)))    
                    else
                        if self.timers[me.toStr(cellData.id)] then
                            me.clearTimer(self.timers[me.toStr(cellData.id)])
                            self.timers[me.toStr(cellData.id)] = nil
                        end
                        cellData.time = 0
                        me.assignWidget(self.Panel_items[index],"Text_limit"):setString("活动结束")    
                        me.assignWidget(self.Panel_items[index],"Text_time"):setString(me.formartSecTime(0))    
                        me.setButtonDisable(btn,false)
                        local spt = me.assignWidget(self.Panel_items[index],"Panel_sprite"):getChildByTag(555)
                        me.graySprite(spt)                        
                        me.assignWidget(self.Panel_items[index],"Text_sale"):setTextColor(COLOR_EXPED_GRAY)
                    end                
                end,1)    
            end  
        elseif cellData.value < cellData.limit and cellData.time and cellData.time <= 0 then -- 没超限购次数,活动时间结束
            if self.timers[me.toStr(cellData.id)] then
                me.clearTimer(self.timers[me.toStr(cellData.id)])
            end
            
            me.assignWidget(self.Panel_items[index],"Text_limit"):setVisible(true)
            
            me.assignWidget(self.Panel_items[index],"Text_limit"):setString("活动结束")    
            me.assignWidget(self.Panel_items[index],"Text_time"):setString(me.formartSecTime(0))    
            me.setButtonDisable(btn,false)
            me.graySprite(sp)
            
            me.assignWidget(self.Panel_items[index],"Text_sale"):setTextColor(COLOR_EXPED_GRAY)
        else 
            if user.activityDetail.activityId == ACTIVITY_ID_GIFT then --有time字段的是 限时礼包活动 (超出限购次数)
                me.graySprite(sp)               
                me.assignWidget(self.Panel_items[index],"Text_sale"):setTextColor(COLOR_EXPED_GRAY)
                me.assignWidget(self.Panel_items[index],"Text_limit"):setVisible(false)
                
                
                me.setButtonDisable(btn,false)
                if self.timers[me.toStr(cellData.id)] then
                    me.clearTimer(self.timers[me.toStr(cellData.id)])
                    self.timers[me.toStr(cellData.id)] = nil
                end
            elseif user.activityDetail.activityId == ACITVITY_ID_NEW_SPRING then --没有time字段的是 新春礼包活动
                me.setButtonDisable(btn,true)                
                me.assignWidget(self.Panel_items[index],"Text_sale"):setTextColor(cc.c3b(0xff, 0xd6, 0x85))
                btn:setButtonText("已购买")
                btn:setTitleColor(me.convert3Color_("a5a5a5"))
                me.assignWidget(self.Panel_items[index],"Text_limit"):setVisible(false)                
                me.assignWidget(self,"Text_newSpringCD"):setVisible(true)
                local currentT = 0
                if user.activityDetail.time - (me.sysTime()/1000-user.activityDetail.newSpringStartTime/1000) > 0 then
                    currentT = user.activityDetail.time - (me.sysTime()/1000-user.activityDetail.newSpringStartTime/1000)
                end
                me.assignWidget(self,"Text_newSpringCD"):setString("结束倒计时："..me.formartSecTime(currentT))
                me.clearTimer(self.newSpringCD)
                self.newSpringCD = me.registTimer(-1,function ()
                    if user.activityDetail.time - (me.sysTime()/1000-user.activityDetail.newSpringStartTime/1000) > 0 then
                        me.assignWidget(self,"Text_newSpringCD"):setString("结束倒计时："..me.formartSecTime( user.activityDetail.time - (me.sysTime()/1000-user.activityDetail.newSpringStartTime/1000) ))
                    else
                        me.clearTimer(self.newSpringCD)
                        self.newSpringCD = nil
                        me.assignWidget(self.Panel_items[index],"Text_limit"):setString("活动结束")    
                        me.assignWidget(self.Panel_items[index],"Text_time"):setString(me.formartSecTime(0))    
                        me.setButtonDisable(btn,false)
                        local spt = me.assignWidget(self.Panel_items[index],"Panel_sprite"):getChildByTag(555)
                        me.graySprite(spt)                        
                        me.assignWidget(self.Panel_items[index],"Text_sale"):setTextColor(COLOR_EXPED_GRAY)
                    end                    
                end,1)
            
                me.registGuiClickEventByName(self.Panel_items[index],"Button_get",function(node)
                    local tmpData = self.listData[me.toNum(self.Panel_items[index]:getTag())]
                    local chargeItem = user.recharge[tmpData.rid]
                    if chargeItem then
                        me.setWidgetCanTouchDelay(node,1)
                        payMgr:getInstance():checkChooseIap(chargeItem)
                    else
                        __G__TRACKBACK__("user.recharge id"..tmpData.rid.." is nil  !!!!")
                    end
                end)
            end
        end
    end  

    me.assignWidget(self.Panel_items[index],"Button_detail"):setSwallowTouches(false)  
    me.registGuiClickEventByName(self.Panel_items[index],"Button_detail",function ()
        local tmpData = self.listData[me.toNum(self.Panel_items[index]:getTag())]
        local def = cfg[CfgType.ETC][tmpData.itemId]
        local gdc = giftDetailCell:create("giftDetailCell.csb")
        gdc:setItemData(def.useEffect)
        me.runningScene():addChild(gdc,me.MAXZORDER)                        
    end)
end
 
function giftSubcell:onExit()
    if self.newSpringCD then
        me.clearTimer(self.newSpringCD)
    end
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
    end
    self.timers = nil
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
