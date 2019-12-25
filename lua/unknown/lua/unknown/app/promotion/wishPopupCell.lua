wishPopupCell = class("wishPopupCell",function(...)
    return cc.CSLoader:createNode(...)
end)
wishPopupCell.__index = wishPopupCell

function wishPopupCell:create(...)
    local layer = wishPopupCell.new(...)
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

function wishPopupCell:ctor()
    print("wishPopupCell:ctor()")
end

function wishPopupCell:init()
    print("wishPopupCell:init()")
    self.currentId = nil
    self.Panel_rewards = me.assignWidget(self,"Panel_rewards")
    self.Button_wish = me.assignWidget(self,"Button_wish")    
    self.Node_item = me.assignWidget(self,"Node_item")
    self.Image_base = me.assignWidget(self,"Image_base")
    self.Node_balls = {}
    self.needNum = 5
    self.preSelNode = nil
    for var = 1, 7 do
        self.Node_balls[#self.Node_balls+1] = me.assignWidget(self.Image_base,"Node_ball_"..var)
    end    
    return true
end

function wishPopupCell:onEnter()  
    me.registGuiClickEvent(self.Button_wish, function (node)
        if self.currentId then
            NetMan:send(_MSG.activity_wish(self.currentId))
        end
    end)
    me.registGuiClickEventByName(self,"close", function (node)
        self:removeFromParentAndCleanup(true)
    end) 
    me.assignWidget(self.Button_wish,"Text_ballNum"):setString("许愿珠x"..self.needNum)
    self:setNodeBalls(1)

    self.modelkey = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_WISH) then
            self:setNodeBalls(self.preIndex)
        end
    end)

    me.doLayout(self,me.winSize)
end

function wishPopupCell:refreshRewards(index)
    self.Panel_rewards:removeAllChildren()
    self.currentId = user.activityDetail.synHave[index][1]
    local pCfigData = cfg[CfgType.WISH_LUCK][self.currentId]
    local rewards = me.split(pCfigData.reward,",")
    for key, var in pairs(rewards) do
        local str = me.split(var,":")
        local name = cfg[CfgType.ETC][me.toNum(str[1])].name
        local num = str[2]
        local txt = ccui.Text:create(name.." x"..num,"",24)
        self.Panel_rewards:addChild(txt)
        txt:setAnchorPoint(0.5,0.5)
        txt:setPosition(self.Panel_rewards:getContentSize().width/2, self.Panel_rewards:getContentSize().height-key*45+20)
    end
end

function wishPopupCell:setNodeBalls(index)
    local Node_item = me.assignWidget(self,"Node_item")
    for key, var in pairs(self.Node_balls) do
        local itemData = user.activityDetail.synHave[key]
        local Panel_item = me.assignWidget(Node_item,"Panel_item"):clone()
        self.Image_base:addChild(Panel_item)
        me.assignWidget(Panel_item,"Image_ball"):loadTexture("item_"..itemData[1]..".png", me.plistType)
        me.assignWidget(Panel_item,"Text_num"):setString(itemData[2].."/"..self.needNum)
        if me.toNum(itemData[2]) < 5 then
            me.assignWidget(Panel_item,"Text_num"):setTextColor(COLOR_RED)
        else
            me.assignWidget(Panel_item,"Text_num"):setTextColor(COLOR_WHITE)
        end
        Panel_item:setPosition(var:getPositionX(),var:getPositionY())
        Panel_item:setVisible(true)
        me.assignWidget(Panel_item,"Panel_item"):setTag(key)
        if key == index then
            self.preSelNode = Panel_item
            self.preIndex = index
            self:refreshRewards(index)
            me.assignWidget(Panel_item,"Image_sel"):setVisible(true) 
        end
        me.registGuiClickEventByName(Panel_item, "Panel_item",function (node)
            if self.preSelNode ~= nil then
                me.assignWidget(self.preSelNode,"Image_sel"):setVisible(false)
            end
            self.preSelNode = node
            me.assignWidget(self.preSelNode,"Image_sel"):setVisible(true)
            self.preIndex = node:getTag()
            self:refreshRewards(node:getTag())
        end)
    end
end

function wishPopupCell:onExit()
    UserModel:removeLisener(self.modelkey)
    print("wishPopupCell:onExit()")
end
