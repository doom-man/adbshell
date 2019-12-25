turnplateSubcell = class("turnplateSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
turnplateSubcell.__index = turnplateSubcell
function turnplateSubcell:create(...)
    local layer = turnplateSubcell.new(...)
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
function turnplateSubcell:ctor()
    print("turnplateSubcell:ctor()")
    self.itemDatas = nil --抽奖物品
    self.rewarders = nil --获奖名单
    self.itemNodes = {}  --itemNode节点集合
    self.playerNodes = {} --获奖玩家节点集合
    self.timeOrigin = nil  --转盘
    self.turnSwitch = nil
    self.timeOrigin_P = nil --指针
    self.turnSwitch_P = nil
    self.targetIndex = 0
    self.preIndex = 1
    self.targetNum = 0
    self.animSwtich = false     --转盘动画
    self.animRewarder = false --获奖人名单动画
    self.pTouchPitch = true
    self.lastRotationOff = 0 --随机的角度

    self.rotating = false
end
function turnplateSubcell:onEnter()
    print("turnplateSubcell:onEnter()")
    me.doLayout(self,me.winSize)  
end
function turnplateSubcell:init()
    print("turnplateSubcell:init()")
    self.Button_star = me.assignWidget(self,"Button_star")
    self.Image_pointer = me.assignWidget(self,"Image_pointer")
    self.Image_turnplate = me.assignWidget(self,"Image_turnplate")
    self.Text_activityScore = me.assignWidget(self,"Text_activityScore")
    self.Node_descri = me.assignWidget(self,"Node_descri")
    self.Panel_player = me.assignWidget(self,"Panel_player")
    self.preIndex = 1

    me.registGuiClickEventByName(self, "Button_question", function()
        NetMan:send(_MSG.getVigourInfo())    -- 详情
    end)
    me.registGuiClickEventByName(self,"fixLayout",function (node)  
       if self.rotating == true then     
            self:stopAllAnim()
            self:rotationAnimEnd()
            --self.Image_pointer:setVisible(false)

            -- 方法1，重置转盘
            self.Image_turnplate:setRotation(0)
            self.Image_pointer:setRotation((self.targetIndex - 1) * 45)
            self.lastRotationOff = 0
            self.preIndex = self.targetIndex
            -- 方法2，不重置转盘
            --[[
            local r1 = self.Image_turnplate:getRotation()
            print("转盘角度1", r1)
            r1 = 360 - r1 % 360
            print("转盘角度2", r)
            local r2 = (self.targetIndex - 1) * 45 - r1
            self.Image_pointer:setRotation(r2)
            self.lastRotationOff = 0
            self.preIndex = self.targetIndex
            --]]
       end
    end)
    me.registGuiClickEventByName(self, "Button_star", function(node)
        if me.toNum(user.activityDetail_trunplate.activityNum) < 200 then
            showTips("积分不足")
            return
        end
        self.Button_star:setEnabled(false)
        self.animSwtich = true
        self.animRewarder = true
        NetMan:send(_MSG.updateActivityDetail(user.activityDetail_trunplate.activityId))
        self.rotating = true
        self.Image_pointer:setVisible(true)
    end)
    for i = 1, 8 do
        self.playerNodes[#self.playerNodes+1]=me.assignWidget(self,"Node_player_"..i)
        self.itemNodes[#self.itemNodes+1]=me.assignWidget(self,"Node_"..i)
    end
    return true
end
function turnplateSubcell:popupReward()
    local item = self.itemDatas[self.targetIndex]
    local i = {}
    i[#i+1] = {}
    i[#i]["defId"] = item[1]
    i[#i]["itemNum"] = self.targetNum
    i[#i]["needColorLayer"] = true
    getItemAnim(i)
end
function turnplateSubcell:rotationAnimEnd(node_)
    self.Button_star:setEnabled(true)
    local night = me.assignWidget(self.itemNodes[self.targetIndex],"Image_night")
    local fi = cc.FadeIn:create(0.5)
    night:runAction(fi)
    self:addNewRewarders()
    self:popupReward()
    self.animSwtich = false
    self.pTouchPitch = true
    self.rotating = false
end
function turnplateSubcell:rotationToTarget(node_)
    local tmpIndex = 0
    if self.preIndex - self.targetIndex >=0 then
        tmpIndex = me.toNum(8-self.preIndex + self.targetIndex)
    else
        tmpIndex = me.toNum(self.targetIndex-self.preIndex)
    end
    
    --获得一个随机的小角度
    local tmpR = math.floor(me.rand()%18)
    if tmpR%2==0 then
        tmpR = -tmpR
    end

    local rotT = cc.RotateBy:create(0.6,(tmpIndex)*45-self.lastRotationOff+tmpR)
    self.lastRotationOff = tmpR

    local call = cc.CallFunc:create(function ()
        self:rotationAnimEnd()
    end)
    seq = cc.Sequence:create(rotT,call)
    node_:runAction(seq)
    self.preIndex = self.targetIndex
end
function turnplateSubcell:rotationAnim(node_,time_,switch_)
    local rot = nil
    if node_ == self.Image_turnplate then
        rot = cc.RotateBy:create(time_,-360)
    else
        rot = cc.RotateBy:create(time_,360)
    end
    local call = cc.CallFunc:create(function ()
        if switch_ == false then
            time_ = time_-0.2
            if time_ <= 0.1 then
                time_ = 0.1
                switch_ = true
                local rep = cc.Repeat:create(rot,8)
                local seq = cc.Sequence:create(rep,cc.CallFunc:create(function ()
                    self:rotationAnim(node_,time_,switch_)
                end))
                node_:runAction(seq)
                return
            end
        else
            time_ = time_+0.3
            if time_ >= 1.5 then
                node_:stopAllActions()
                if node_ == self.Image_pointer then
                    self:rotationToTarget(node_)
                end
                return    
            end
        end
        node_:stopAllActions()
        self:rotationAnim(node_,time_,switch_)
    end)
    local seq = cc.Sequence:create(rot,call)
    node_:runAction(seq)
end
--奖品道具
function turnplateSubcell:setItemData()
    for key, var in pairs(self.itemNodes) do
        local itemNode = me.assignWidget(var,"Button_item")
        if itemNode == nil then
            itemNode = me.assignWidget(self,"Button_item"):clone()
            var:addChild(itemNode)
            itemNode:setTag(key)
            itemNode:setVisible(true)
        end
        if self.itemDatas and self.itemDatas[key] then
            local etc = cfg[CfgType.ETC][self.itemDatas[key][1]]
            me.assignWidget(itemNode, "label_num"):setString(user.activityDetail_trunplate.list[key][2])
            me.assignWidget(itemNode, "Goods_Icon"):loadTexture("item_"..etc.icon..".png",me.localType)
            me.assignWidget(itemNode, "Image_quality"):loadTexture(getQuality(etc.quality),me.localType)
            me.registGuiClickEventByName(itemNode, "Button_item", function(node)    
                if self.pTouchPitch  then
                    local pTag = me.toNum(node:getTag())
                    local pData = self.itemDatas[pTag]                         
                    local defId =pData[1]
                    local pNum = user.activityDetail_trunplate.list[pTag][2]
                    showPromotion(defId,pNum)
                end           
          end )
        end
    end
end
function turnplateSubcell:getRichTextItem(data_)
    local etc = cfg[CfgType.ETC][me.toNum(data_.itemId)]     
    local rgb = getQualityColor(etc.quality)
    local str =  "<txt0014,ffffff>"..data_.name.."&<txt0014,ffae00>获得&<txt0014,"..rgb..">"..etc.name.." x"..data_.itemNumber.."&"
    return mRichText:create(str,400)
end
function turnplateSubcell:addNewRewarders() 
    if user.activityDetail_trunplate.rewardersQueue == nil or Queue.count(user.activityDetail_trunplate.rewardersQueue) <= 0 then
        return
    end
    self.animRewarder = true
    -- 已有的获奖人员整体下移
    for key, var in pairs(self.Panel_player:getChildren()) do
        local tag = me.toNum(var:getTag())
        local anim = nil
        if tag <= 100 then
            local tmpNode = self.playerNodes[tag+1]
            local nextPosX,nextPosY = 0,0
            if tmpNode then
                nextPosX,nextPosY = tmpNode:getPosition()
                anim = cc.MoveTo:create(0.5,cc.p(nextPosX,nextPosY))
            else
                local move = cc.MoveBy:create(0.5,cc.p(-30,-30))
                local call = cc.CallFunc:create(function ()
                    var:removeFromParentAndCleanup(true)
                    var = nil
                end)
                anim = cc.Sequence:create(move,call)
            end
            var:setTag(tag+1)
            var:runAction(anim)
        end
    end

    -- 增加新加的获奖人员
    local newData = Queue.pop(user.activityDetail_trunplate.rewardersQueue)
    if newData == nil then
        __G__TRACKBACK__("newData is nil !!")
        return
    end
    local tmpNode = self.playerNodes[1]
    local richTxt = self:getRichTextItem(newData)
    self.Panel_player:addChild(richTxt)
    local nx,ny = tmpNode:getPosition()
    richTxt:setPosition(cc.p(nx,ny+30))
    richTxt:setAnchorPoint(cc.p(0,0.5))
    richTxt:setTag(1)
    local moveTo = cc.MoveTo:create(0.5,cc.p(nx,ny))
    local del = cc.DelayTime:create(0.75)
    local callF = cc.CallFunc:create(function ()
        self.animRewarder = false
        self:addNewRewarders() 
    end)
    local finalSeq = cc.Sequence:create(moveTo,del,callF)
    richTxt:runAction(finalSeq)
end
--获奖名单设置
function turnplateSubcell:setRewarders()
    if user.activityDetail_trunplate.rewardersQueue == nil or Queue.count(user.activityDetail_trunplate.rewardersQueue) <= 0 then
        return
    end
    for i = 1, Queue.count(user.activityDetail_trunplate.rewardersQueue) do
        local data = Queue.pop(user.activityDetail_trunplate.rewardersQueue)
        local tmpNode = self.playerNodes[i]
        if data and tmpNode then 
            local richTxt = self:getRichTextItem(data)
            self.Panel_player:addChild(richTxt)
            local nx,ny = tmpNode:getPosition()
            richTxt:setPosition(cc.p(nx,ny))
            richTxt:setAnchorPoint(cc.p(0,0.5))
            richTxt:setTag(i)
        end
    end
end
function turnplateSubcell:onEnter()
    print("turnplateSubcell:onEnter()")
    me.doLayout(self,me.winSize)  
    self.itemDatas = user.activityDetail_trunplate.list   
    self.Text_activityScore:setString(user.activityDetail_trunplate.activityNum)

    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail_trunplate.activityId)]
    if activity and activity.desc then
        local rt = mRichText:create(activity.desc,305)
        rt:setPosition(0,0)
        rt:setAnchorPoint(cc.p(0,1))
        self.Node_descri:addChild(rt)
    end
    self:setItemData()
    self:setRewarders()
    self.modelkey = UserModel:registerLisener(function(msg) -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.alertId == 568 then
               showTips("积分不足") 
               return
            end
            if msg.c.activityId == ACTIVITY_ID_TURNPLATE then
                self.pTouchPitch = false
                self.timeOrigin,self.turnSwitch = 1,false
                self.timeOrigin_P,self.turnSwitch_P = 1,false
                self.Button_star:setEnabled(false)
                if self.targetIndex ~= 0 then
                    local night = me.assignWidget(self.itemNodes[self.targetIndex],"Image_night")
                    local fo = cc.FadeOut:create(0.2)
                    night:runAction(fo)
                end
                self:rotationAnim(self.Image_turnplate,self.timeOrigin,self.turnSwitch)
                self:rotationAnim(self.Image_pointer,self.timeOrigin_P,self.turnSwitch_P)
                self.targetIndex = self:getIndexByItemId(msg.c.itemId)
                self.targetNum = msg.c.itemNumber
                if msg.c.vigour then
                    user.activityDetail_trunplate.activityNum = msg.c.vigour
                    self.Text_activityScore:setString(user.activityDetail_trunplate.activityNum)            
                end
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_DARW_RECORD) then
--            if msg.c.vigour then
--                user.activityDetail_trunplate.activityNum = msg.c.vigour
--                self.Text_activityScore:setString(user.activityDetail_trunplate.activityNum)            
--            end
            if self.animRewarder == false then
                self:addNewRewarders()
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_VIGOUR_INFO) then
            local detailInfo = turnplateDetailCell:create("turnplateDetail.csb")
            detailInfo:setDetailData(msg.c)
            detailInfo:hideInfoBtn()
            me.runningScene():addChild(detailInfo,me.MAXZORDER)
            me.showLayer(detailInfo, "bg")
        end
    end)
end
function turnplateSubcell:getIndexByItemId(itemId_)
    for key, var in pairs(self.itemDatas) do
        if var[1] == itemId_ then
            return me.toNum(key)
        end
    end
end
function turnplateSubcell:stopAllAnim()
    self.Image_turnplate:stopAllActions()
    self.Image_pointer:stopAllActions()
    if self.itemNodes[self.targetIndex] then
        self.itemNodes[self.targetIndex]:stopAllActions()
    end
end
function turnplateSubcell:onExit()
    print("turnplateSubcell:onExit()")
    self:stopAllAnim()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
