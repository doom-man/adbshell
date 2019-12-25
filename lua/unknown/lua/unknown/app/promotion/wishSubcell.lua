wishSubcell = class("wishSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
wishSubcell.__index = wishSubcell

function wishSubcell:create(...)
    local layer = wishSubcell.new(...)
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

function wishSubcell:ctor()
    print("wishSubcell:ctor()")
end

function wishSubcell:init()
    print("wishSubcell:init()")
    self.Text_wishNum = me.assignWidget(self,"Text_wishNum")
    self.Text_auguryNum = me.assignWidget(self,"Text_auguryNum")
    self.Text_myAuguryNum = me.assignWidget(self,"Text_myAuguryNum")
    self.Text_box_wishNum = me.assignWidget(self, "Text_box_wishNum")
    self.Button_box = me.assignWidget(self,"Button_box")
    self.Panel_touchPos = me.assignWidget(self,"Panel_touchPos")
    self.Panel_pearls = me.assignWidget(self,"Panel_pearls")
    self.Text_mywishTime = me.assignWidget(self,"Text_mywishTime")
    return true
end

function wishSubcell:onEnter()  
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end

    me.registGuiClickEventByName(self,"Button_augury",function (node)
        me.showMessageDialog("需要我为你占卜一下宝藏位置吗？",function (args)
            if args == "ok" then
                NetMan:send(_MSG.activity_aurgury())
            end   
        end)
    end) 

    me.registGuiClickEventByName(self,"Button_wish",function (node)
        local wpc = wishPopupCell:create("wishPopupCell.csb")
        mainCity.promotionView:addChild(wpc)
        me.showLayer(wpc, "bg_frame")
    end) 

    me.registGuiClickEventByName(self,"Button_box",function (node)
        NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))
    end) 

    me.registGuiClickEvent(self.Panel_touchPos, function (node)
        if self.targetPos then
            LookMap(self.targetPos, "promotionView")
        end
    end)

    self:setNodeBalls()
    self:setPosPanel(user.activityDetail)
    self.modelkey = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_AURGURY) then
            showTips("占卜成功，宝藏坐标更新!")
            self:setPosPanel(msg.c)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_WISH) then
            self:setNodeBalls()
        elseif checkMsg(msg.t,MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_WISH then
                self:setNodeBalls()
            end
        end
    end)
    me.doLayout(self,me.winSize)
end

function wishSubcell:popupReward(msg)
    local i = {}
    i[#i+1] = {}
    i[#i]["defId"] = msg.c.id
    i[#i]["itemNum"] = msg.c.num
    i[#i]["needColorLayer"] = true
    getItemAnim(i)
end

function wishSubcell:setNodeBalls()
    self.Panel_pearls:removeAllChildren()
    for key, var in pairs(user.activityDetail.synHave) do 
        local Image_pearl_item = me.assignWidget(self,"Image_pearl_item"):clone()
        Image_pearl_item:setVisible(true)
        Image_pearl_item:loadTexture("item_"..var[1]..".png", me.plistType)
        me.assignWidget(Image_pearl_item, "Text_num"):setString("x"..var[2])
        if me.toNum(var[2]) == 0 then
            me.setButtonDisable(self.Button_box,false)
        end
        Image_pearl_item:setPosition(key%2*80+50, self.Panel_pearls:getContentSize().height-math.floor((key-1)/2)*50-35)
        self.Panel_pearls:addChild(Image_pearl_item)
    end

    self.Text_wishNum:setString("许愿珠x5")
    self.Text_auguryNum:setString("x1")
    self.Text_myAuguryNum:setString("x"..user.activityDetail.haveNum)
    self.Text_box_wishNum:setString("许愿珠x1")
    self.Text_mywishTime:setString("活动时间:"..me.GetInSecTime(user.activityDetail.openDate/1000, true).."-"..me.GetInSecTime(user.activityDetail.endDate/1000, true))
end

function wishSubcell:setPosPanel(pos)
    if me.isValidStr(pos.x) and me.isValidStr(pos.y) then
        self.targetPos = pos
        self.Panel_touchPos:removeAllChildren()
        local richStr = "<txt0016,ffffff>我的宝藏藏在&<txt0016,7dcc5e>".."("..pos.x..","..pos.y..")".."&<txt0016,ffffff>点击前往吧&"
        local rt = mRichText:create(richStr, 300 )
        rt:setAnchorPoint(cc.p(0.5,0.5))
        rt:setPosition(cc.p(self.Panel_touchPos:getContentSize().width/2, self.Panel_touchPos:getContentSize().height/2))
        self.Panel_touchPos:addChild(rt)
    else
        self.targetPos = nil
        self.Panel_touchPos:removeAllChildren()
        local richStr = "<txt0016,ffffff>暂无宝藏，可以点击占卜查看有无最新的宝藏&"
        local rt = mRichText:create(richStr, 300 )
        rt:setAnchorPoint(cc.p(0.5,0.5))
        rt:setPosition(cc.p(self.Panel_touchPos:getContentSize().width/2, self.Panel_touchPos:getContentSize().height/2))
        self.Panel_touchPos:addChild(rt)
    end
    self.Text_myAuguryNum:setString("x"..user.activityDetail.haveNum)
end

function wishSubcell:onExit()
    UserModel:removeLisener(self.modelkey)
    print("wishSubcell:onExit()")
end
