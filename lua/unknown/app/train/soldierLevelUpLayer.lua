-- [Comment]
-- jnmo
soldierLevelUpLayer = class("soldierLevelUpLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
soldierLevelUpLayer.__index = soldierLevelUpLayer
function soldierLevelUpLayer:create(...)
    local layer = soldierLevelUpLayer.new(...)
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
function soldierLevelUpLayer:ctor()
    print("soldierLevelUpLayer ctor")
    self.pSoldierMin = 1
    self.pSoldierCur = 1
    --滑条的限制开关
    self.sliderTouchSwitch = true
end
function soldierLevelUpLayer:init()
    print("soldierLevelUpLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    self.title = me.assignWidget(self, "title")
    self.food_num = me.assignWidget(self, "food_num")
    self.wood_num = me.assignWidget(self, "wood_num")
    self.stone_num = me.assignWidget(self, "stone_num")
    self.gold_num = me.assignWidget(self, "gold_num")
    self.btn_imme = me.assignWidget(self, "btn_imme")
    self.btn_train = me.assignWidget(self, "btn_train")
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()

    self.btn_reduce = me.assignWidget(self, "btn_reduce")
    self.need_time = me.assignWidget(self, "need_time")
    self.btn_add = me.assignWidget(self, "btn_add")
    self.diamond = me.assignWidget(self, "diamond")
    self.slider_bar = me.assignWidget(self, "slider_bar")
    self.s1 = me.assignWidget(self, "s1")
    self.s2 = me.assignWidget(self, "s2")
    local function addcallback(node)
        if self.pSoldierMax <= 0 then
            print("self.pSoldierMax = " .. self.pSoldierMax)
            showTips(TID_TRAIN_MAX)
            return
        end
        self.pSoldierCur = math.min(self.pSoldierMax, self.pSoldierCur + 1)
        self:updateRes()
    end
    local function reducecallback(node)
        if self.pSoldierCur <= 0 then
            return
        end
        self.pSoldierCur = math.max(self.pSoldierMin, self.pSoldierCur - 1)
        self:updateRes()
    end
    me.registGuiClickEvent(self.btn_add, addcallback)
    me.registGuiClickEvent(self.btn_reduce, reducecallback)

    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            if self.pSoldierMax <= 0 and self.sliderTouchSwitch then
                showTips(TID_TRAIN_MAX)
                self.sliderTouchSwitch = false
                return
            end
            local slider = sender
            local percent = slider:getPercent() / 100
            self.pSoldierCur = math.floor(percent * self.pSoldierMax)
            self.pSoldierCur = math.max(self.pSoldierCur, self.pSoldierMin)
            self:updateRes()
        end
    end
    local function sliderTouchEvent(sender, eventType)
        if self.pSoldierMax <= 0 and eventType == ccui.TouchEventType.ended then
            sender:setPercent(0)
            self.pSoldierCur = 0
            self:updateRes()
            self.sliderTouchSwitch = true
        end
    end
    self.slider_bar:addTouchEventListener(sliderTouchEvent)
    self.slider_bar:addEventListener(sliderEvent)
    local function traincallback(node)
        NetMan:send(_MSG.soldierLevelUp(self.data.bid, self.data.oid, self.pSoldierCur,0))
        self:close()
    end
    local function traincallback_imme(node)
        NetMan:send(_MSG.soldierLevelUp(self.data.bid, self.data.oid, self.pSoldierCur,1))
        self:close()
    end
    me.registGuiClickEvent(self.btn_train, traincallback)
    me.registGuiClickEvent(self.btn_imme, traincallback_imme)
    return true
end
function soldierLevelUpLayer:initWithData(data)
    self.data = data
    local data1 = cfg[CfgType.CFG_SOLDIER][data.oid]
    local data2 = cfg[CfgType.CFG_SOLDIER][data.nid]
    local s_bg = me.assignWidget(self.s1, "s_bg")
    local s_num = me.assignWidget(self.s1, "s_num")
    local Text_Name = me.assignWidget(self.s1, "Text_Name")
    local att = me.assignWidget(self.s1, "att")
    local def = me.assignWidget(self.s1, "def")
    local hp = me.assignWidget(self.s1, "hp")
    local weight = me.assignWidget(self.s1, "weight")
    local speed = me.assignWidget(self.s1, "speed")
    local range = me.assignWidget(self.s1, "range")
    local sicon1 = me.assignWidget(self.s1,"sicon")
    s_num:setString(data.onum)
    Text_Name:setString(data1.name)
    att:setString(data1.attack)
    def:setString(data1.defense)
    hp:setString(data1.hp)
    speed:setString(data1.speed)
    weight:setString(data1.carry)
    range:setString(data1.atkRange)
--    s_bg:removeChildByTag(0xff2321)
--    local sani = soldierMoudle:createSoldierById(data1.id)
--    sani:doAction(MANI_STATE_IDLE, DIR_LEFT_BOTTOM)
--    s_bg:addChild(sani)
--    sani:setTag(0xff2321)
--    sani:setScale(1.3)
--    sani:setPosition(80, 70)
    sicon1:ignoreContentAdaptWithSize(true)
    sicon1:loadTexture(soldierIcon(data1),me.plistType)
    local s_bg2 = me.assignWidget(self.s2, "s_bg")
    local s_num2 = me.assignWidget(self.s2, "s_num")
    local Text_Name2 = me.assignWidget(self.s2, "Text_Name")
    local att2 = me.assignWidget(self.s2, "att")
    local def2 = me.assignWidget(self.s2, "def")
    local hp2 = me.assignWidget(self.s2, "hp")
    local weight2 = me.assignWidget(self.s2, "weight")
    local speed2 = me.assignWidget(self.s2, "speed")
    local range2 = me.assignWidget(self.s2, "range")
    local sicon2 = me.assignWidget(self.s2,"sicon")
    Text_Name2:setString(data2.name)
    sicon2:ignoreContentAdaptWithSize(true)
    sicon2:loadTexture(soldierIcon(data2),me.plistType)
    s_num2:setString(data.nnum)
   
    att2:setString(data2.attack)
    def2:setString(data2.defense)
    hp2:setString(data2.hp)
    speed2:setString(data2.speed)
    weight2:setString(data2.carry)
    range2:setString(data2.atkRange)
    s_bg2:removeChildByTag(0xff2322)
--    local sani2 = soldierMoudle:createSoldierById(data2.id)
--    sani2:doAction(MANI_STATE_IDLE, DIR_LEFT_BOTTOM)
--    s_bg2:addChild(sani2)
--    sani2:setTag(0xff2322)
--    sani2:setScale(1.3)
--    sani2:setPosition(80, 70)

    self.pSoldierMax = data.tranum
    local defaultNum = self:getDefaultNum()
    self.pSoldierCur = math.min(defaultNum, self.pSoldierMax)
    if self.pSoldierMax <= 0 then
        self.slider_bar:setPercent(0)
    else
        self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
    end
    self:updateRes()
end
function soldierLevelUpLayer:createEditBox()
    local function editFiledCallBack(strEventName, pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()

            if me.isPureNumber(text) then
                if me.isValidStr(text) and me.toNum(text) <= self.pSoldierMax then
                    self.pSoldierCur = me.toNum(text)
                else
                    showTips("超出上限")
                end
            else
                showTips("请输入有效数字")
            end
            self:updateRes()
        end
    end
    local eb = me.addInputBox(100, 40, 24, "ui_jz_input.png", editFiledCallBack, cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.Node_EditBox:addChild(eb)
    return eb
end
function soldierLevelUpLayer:onEnter()
    print("soldierLevelUpLayer onEnter")
    me.doLayout(self, me.winSize)
end
function soldierLevelUpLayer:onEnterTransitionDidFinish()
    print("soldierLevelUpLayer onEnterTransitionDidFinish")
end
function soldierLevelUpLayer:onExit()
    print("soldierLevelUpLayer onExit")
end
function soldierLevelUpLayer:close()
    self:removeFromParent()
end
function soldierLevelUpLayer:updateRes()
    if self.pSoldierMax <= 0 then
        self.slider_bar:setPercent(0)
    else
        self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
    end    
    self.pSoldierMax = self.data.tranum
    
    self.pSoldierTime =  self.data.time
    
    local need_food = self.data.needFood * self.pSoldierCur
    if need_food > user.food then
        self.food_num:setTextColor(COLOR_RED)
    else
        self.food_num:setTextColor(COLOR_D4CDB9)
    end
    self.food_num:setString(need_food)
    local need_wood = self.data.needWood * self.pSoldierCur
    if need_wood > user.wood then
        self.wood_num:setTextColor(COLOR_RED)
    else
        self.wood_num:setTextColor(COLOR_D4CDB9)
    end
    self.wood_num:setString(need_wood)
    local need_stone = self.data.needStone * self.pSoldierCur
    if need_stone > user.stone then
        self.stone_num:setTextColor(COLOR_RED)
    else
        self.stone_num:setTextColor(COLOR_D4CDB9)
    end
    self.stone_num:setString(need_stone)
    local need_gold = self.data.needGold * self.pSoldierCur
    if need_gold > user.gold then
        self.gold_num:setTextColor(COLOR_RED)
    else
        self.gold_num:setTextColor(COLOR_D4CDB9)
    end
    self.gold_num:setString(need_gold)
    self.need_time:setString(me.formartSecTime(self.pSoldierTime  * self.pSoldierCur/1000))
    self.editBox:setText(self.pSoldierCur)
    -- 钻石
    local price = { }
    price.food = need_food
    price.wood = need_wood
    price.stone = need_stone
    price.gold = need_gold
    price.time =(self.pSoldierTime / 1000) * self.pSoldierCur
    price.index = 2
    local pdiamond = math.ceil(getGemCost(price))
    self.diamond:setString(pdiamond)   
    me.setButtonDisable(self.btn_train, self.pSoldierCur > 0)
    me.setButtonDisable(self.btn_imme, self.pSoldierCur > 0)
end
function soldierLevelUpLayer:getDefaultNum()
    local floor = math.floor
    local insert = table.insert
    local tb = { }
    if self.data.needFood ~= 0 then
        insert(tb, floor(user.food / self.data.needFood))
    end
    if self.data.needWood ~= 0 then
        insert(tb, floor(user.wood / self.data.needWood))
    end
    if self.data.needStone ~= 0 then
        insert(tb, floor(user.stone / self.data.needStone))
    end
    if self.data.needGold ~= 0 then
        insert(tb, floor(user.gold / self.data.needGold))
    end
    table.sort(tb, function(a, b)
        return a < b
    end )
    local num = tb[1]
    if num == 0 then
        num = 1
    end
    return num
end
