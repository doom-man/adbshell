buildLevelUpLayer = class(" buildLevelUpLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )

buildLevelUpLayer.__index = buildLevelUpLayer
function buildLevelUpLayer:create(...)
    local layer = buildLevelUpLayer.new(...)
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
function buildLevelUpLayer:ctor()
    print(" buildLevelUpLayer ctor")
    self.optBtn_imme = nil
    self.optBtn_lvup = nil
    self.icon = nil
    self.name = nil
    self.desc = nil
    self.levelupDesc = nil
    -- 将要建造的地基id
    self.EvtLisenter = nil
    self.bMeet = false
    self.farmerEnough = false
    self.notEnoughMin = false
    self.needFarmerMin = 0
    self.needFarmerMax = 0
    self.curSelectFarmer = 0
    self.minFarmerTime = 0
    self.maxFarmerTime = 0
    self.listener = nil
end
function buildLevelUpLayer:init()
    print(" buildLevelUpLayer init")

    me.registGuiTouchEventByName(self, "fixLayout", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        me.DelayRun(function (node)
                self:close()
        end)        
    end )

    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    
    local function callback_imme(node)
--        dump(self)
        -- if  self.EvtLisenter then
        local evt = { }
        evt.cmd = "imme"
        evt.data = self.bdata
        if user.building[evt.data.index] == nil then
            --  UserModel:addStructDateLine(evt.data.index,evt.data.id,evt.data.time)
            local function diamondUse1()
                NetMan:send(_MSG.buildingStruct(evt.data.shopId, evt.data.index, self.curSelectFarmer, 1))
            end
            local needDiamond = tonumber(self.ndiamond:getString()) or 0 
            if user.diamond<needDiamond then
                diamondNotenough(needDiamond, diamondUse1)  
            else
                if needDiamond > 0 then
                    -- 确认弹窗
                    diamondCostMsgBox(needDiamond, function()
                        diamondUse1()
                    end)
                else
                    diamondUse1()
                end
            end
        else
            if self.toftid then 
                local building = mainCity.buildingMoudles[self.toftid]
                if building.isResBuilding then
                   building.gainBtn:setVisible(false)  
                   if building.resInfo then                                                  
                       building.resInfo = nil
                       if building:getDef().type == "food" then 
                         building:foodParticl()
                       elseif building:getDef().type == "stone" then 
                         building:stoneParticl()
                       elseif building:getDef().type == "lumber" then
                         building:woodParticl()
                       end
                       mainCity:ResUIAction(1)
                       mainCity:setActionNum(1,self.toftid)
                       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_FOOD_HARVEST,false)
                       NetMan:send(_MSG.getResource(self.toftid))
                    end
                end 
            end      
               
            local function diamondUse()
                NetMan:send(_MSG.buildingUpLevel(evt.data.index, self.curSelectFarmer, 1))
            end
            local needDiamond = tonumber(self.ndiamond:getString()) or 0 
            if user.diamond<needDiamond then
                diamondNotenough(needDiamond, diamondUse)  
            else
                if needDiamond > 0 then
                    -- 确认弹窗
                    diamondCostMsgBox(needDiamond, function()
                        diamondUse()
                    end)
                else
                    diamondUse()
                end
            end
        end
        --   self.EvtLisenter(evt)
        -- end
    end
    self.optBtn_imme =
    -- 注册点击事件
    me.registGuiClickEventByName(self, "optBtn_imme", callback_imme)
    self.optBtn_lvup =
    -- 注册点击事件
    me.registGuiClickEventByName(self, "optBtn_lvup", function(node)
        local evt = { }
        evt.cmd = "lvup"
        evt.data = self.bdata
        --  me.LogTable(evt,"registGuiClickEventByName =========")
        if user.building[evt.data.index] == nil then
            --    UserModel:addStructDateLine(evt.data.index,evt.data.id,evt.data.time)
            NetMan:send(_MSG.buildingStruct(evt.data.shopId, evt.data.index, self.curSelectFarmer))
        else
          if self.toftid then
                local building = mainCity.buildingMoudles[self.toftid]
                if building.isResBuilding then
                   building.gainBtn:setVisible(false)  
                   if building.resInfo then                                                    
                       building.resInfo = nil
                       if building:getDef().type == "food" then 
                         building:foodParticl()
                       elseif building:getDef().type == "stone" then 
                         building:stoneParticl()
                       elseif building:getDef().type == "lumber" then
                         building:woodParticl()
                       end
                       mainCity:ResUIAction(1)
                       mainCity:setActionNum(1,self.toftid)
                       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_FOOD_HARVEST,false)
                       NetMan:send(_MSG.getResource(self.toftid))
                    end
                end 
          end
          NetMan:send(_MSG.buildingUpLevel(evt.data.index, self.curSelectFarmer))
        end
    end )
    self.ndiamond = me.assignWidget(self, "ndiamond")
    self.ntime = me.assignWidget(self, "ntime")
    self.icon = me.assignWidget(self, "icon")
    self.name = me.assignWidget(self, "name")
    self.desc = me.assignWidget(self, "desc")
    self.levelupDesc = me.assignWidget(self, "levelupDesc")
    self.nlist_1 = me.assignWidget(self, "nlist_1")
    self.nlist_2 = me.assignWidget(self, "nlist_2")
    self.btn_allot = me.assignWidget(self, "btn_allot")
    me.registGuiClickEvent(self.btn_allot, function(node)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.bshopBox then
            mainCity.bshopBox:close()
        end
        local allot = allotLayer:create("allotLayer.csb")
        allot:initialize()
        mainCity:addChild(allot, me.MAXZORDER)
        me.showLayer(allot, "bg")
    end )
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    self.maxfarmer_num = me.assignWidget(self, "maxfarmer_num")
    self.slider_bar = me.assignWidget(self, "Slider_farmer")
    self.farmer_need = me.assignWidget(self,"farmer_need")

    
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent() / 100
            local tempfarmer = math.floor(percent *self.needFarmerMax)
            if self.curSelectFarmer ~= tempfarmer then
                self.curSelectFarmer = tempfarmer
                self:resetFarmerStatus(self.curSelectFarmer)
            end    
        end
    end

    local function sliderTouchEvent(sender,eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended and self.farmerEnough == false then
            self.farmerEnough = true    
            
            if self.notEnoughMin == true then
                self.curSelectFarmer = self.needFarmerMin
            else
                self.curSelectFarmer = user.idlefarmer
            end
            slider:setPercent(self.curSelectFarmer/self.needFarmerMax*100) 
            self.notEnoughMin = false
            self.ntime:setString(me.formartSecTime(self:getBuildTime(self.curSelectFarmer)))
            self.editBox:setText(self.curSelectFarmer)
            self.editBox:setFontColor(cc.c3b(231, 216, 155))
            me.setButtonDisable(self.optBtn_lvup, self.bMeet and self.farmerEnough)
            me.setButtonDisable(self.optBtn_imme, self.canImme and self.farmerEnough)
        end
    end

    self.slider_bar:addEventListener(sliderEvent)
    self.slider_bar:addTouchEventListener(sliderTouchEvent)
    self.nextLevel = me.assignWidget(self, "nextLevel")
    self.icon:setVisible(false)
    return true
end
function buildLevelUpLayer:resetFarmerStatus(curFarmer)
    self.curSelectFarmer = curFarmer
    if self.curSelectFarmer > user.idlefarmer then
        self.editBox:setFontColor(COLOR_RED)
        self.farmerEnough = false
        self.notEnoughMin = false        
        showTips(TID_BUILDUP_NOT_ENOUGH)
    elseif self.curSelectFarmer < self.needFarmerMin then 
        self.editBox:setFontColor(COLOR_RED)
        self.farmerEnough = false
        self.notEnoughMin = true
        showTips(TID_BUILDUP_NEEDLEAST..self.needFarmerMin)
    else
        self.editBox:setFontColor(cc.c3b(231, 216, 155))
        self.farmerEnough = true
        self.notEnoughMin = false
    end
    self.ntime:setString(me.formartSecTime(self:getBuildTime(self.curSelectFarmer)))
    self.editBox:setText(self.curSelectFarmer)
    me.setButtonDisable(self.optBtn_lvup, self.bMeet and self.farmerEnough)
    me.setButtonDisable(self.optBtn_imme, self.canImme and self.farmerEnough)
end
function buildLevelUpLayer:initWithData(data_, toftid)
    if toftid then
        if mainCity.buildingMoudles[toftid].isResBuilding then 
          NetMan:send(_MSG.resourceBuildingInfo(toftid))
        end
    end
    self.bdata = data_
    self.toftid = toftid
    local self = self
    self.cthread = coroutine.create( function()
        self:initForBuild(true)
    end )
    self.schid = me.coroStart(self.cthread)
end
function buildLevelUpLayer:addEvtLisenter(l_)
    self.EvtLisenter = l_
end
function buildLevelUpLayer:getBuildTime(fNum)
    --[[
     local x1 = 1/self.minFarmerTime/self.needFarmerMin
     local x2 = (self.curSelectFarmer - self.needFarmerMin)/(self.needFarmerMax - self.needFarmerMin)
     local x3 = 1/self.maxFarmerTime/self.needFarmerMax - 1/self.minFarmerTime/self.needFarmerMin
     local x4 = 1/(x1+x2*x3)/self.curSelectFarmer
     print(x4)
     return  x4
]]
    local x1 =(self.minFarmerTime - self.maxFarmerTime) *(fNum - self.needFarmerMin) / (self.needFarmerMax - self.needFarmerMin)
    local tmpBuildTime = (self.minFarmerTime - x1)*getTimePercentByPropertyValue("BuildTime")
    return math.floor(tmpBuildTime)
end
function buildLevelUpLayer:initForBuild(isThread_)
    if not self.bdata then
        error("bdata is nil")
        return
    end
    local def = self.bdata:getDef()
     me.LogTable(def,"----------initForBuild----------")
    if not def then
        return
    end
    print("------")
    local price = { }
    price.food = def.food
    price.wood = def.wood
    price.stone = def.stone
    price.gold = def.gold
    price.time = math.max( def.time2 - (user.propertyValue["FreeTime"] or 0 ),0)
    price.index = 1
    local allCost = getGemCost(price)
    print("allCost  "..allCost)
    self.nextLevel:setString(def.level)
    if math.ceil(allCost) == 0 then
        self.ndiamond:setString("免费")
    else
        self.ndiamond:setString(math.ceil(allCost))
    end
    self.needFarmerMin = me.toNum(def.farmer)
    self.needFarmerMax = me.toNum(def.maxfarmer)
    self.minFarmerTime = me.toNum(def.time)
    self.maxFarmerTime = me.toNum(def.time2)
    self.curSelectFarmer = math.min(user.idlefarmer, self.needFarmerMax)
    self.slider_bar:setPercent(self.curSelectFarmer/self.needFarmerMax*100)
    if self.curSelectFarmer < self.needFarmerMin then
        self.editBox:setFontColor(COLOR_RED)
        self.farmerEnough = false
    else
        self.editBox:setFontColor(cc.c3b(222, 176, 122))
        self.farmerEnough = true
    end
    self.editBox:setText(self.curSelectFarmer)
    self.maxfarmer_num:setString("/" .. self.needFarmerMax)
    self.bMeet = true
    me.setButtonDisable(self.optBtn_lvup, true)
    self.name:setString(def.name)
    self.desc:setString(def.desc)
    self.levelupDesc:setString(def.nextlvdes)
    self.ntime:setString(me.formartSecTime(self:getBuildTime(self.curSelectFarmer)))
    if self.curSelectFarmer < self.needFarmerMin then
        self.ntime:setString(me.formartSecTime(self:getBuildTime(self.needFarmerMin)))
    end    
    self.icon:loadTexture(buildIcon(def), me.plistType)
    self.icon:setVisible(true)
    me.resizeImage(self.icon,500,260)
    self.iconk = me.assignWidget(self,"iconk")
 --   self.icon:setPosition(self.icon:getContentSize().width/2,10)
 --   me.doLayout(self.iconk,self.iconk:getContentSize())
 --   me.doLayout(self,me.winSize)
    self.nlist_2:removeAllChildren()
    self.nlist_1:removeAllChildren()
    local needbuilddata = def.buildLevel
    self.canImme = true
    local tt=0
    if me.isValidStr(needbuilddata) then
        local t = me.split(needbuilddata, ":")
        tt=#t
        for key, var in pairs(t) do
--            print("need building id " .. var)
            local ndata = cfg[CfgType.BUILDING][me.toNum(var)]
            local tItem = me.createNode("bLevelUpNeedItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
            local infoBg = me.assignWidget(bItem, "infoBg")
            if key%2==0 then
                infoBg:setVisible(false)
            end

            ticon:loadTexture(buildSmallIcon(ndata), me.plistType)
            if bHaveLevelBuilding(ndata.type, ndata.level) then
                tdesc:setColor(COLOR_GREEN)
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                toptBtn:setVisible(false)
            else
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                tdesc:setColor(COLOR_RED)
                toptBtn:setVisible(true)
                toptBtn:setTitleText(TID_BUTTON_JUMPTO)
                --建筑等级不足
                me.registGuiClickEvent(toptBtn, function(node)
                    jumpToTarget(ndata,ndata.type)
                    self:close()
                end )
                self.bMeet = false
                self.canImme = false
            end
            tcomplete:ignoreContentAdaptWithSize(false)
            tdesc:setString(ndata.name .. " " .. TID_LEVEL .. ndata.level)
            self.nlist_1:pushBackCustomItem(bItem)
            if isThread_ then
                coroutine.yield()
            end
        end
    end
    --添加农民人数条
    local tItem = me.createNode("bLevelUpNeedItem.csb")
    local bItem = me.assignWidget(tItem, "bg"):clone()
    local ticon = me.assignWidget(bItem, "icon")
    local tdesc = me.assignWidget(bItem, "desc")
    local tcomplete = me.assignWidget(bItem, "complete")
    local toptBtn = me.assignWidget(bItem, "optBtn")
    me.registGuiClickEvent(toptBtn, function(node)
        local allot = allotLayer:create("allotLayer.csb")
        allot:initialize()
        mainCity:addChild(allot, me.MAXZORDER)
        me.showLayer(allot, "bg")
    end )
    local infoBg = me.assignWidget(bItem, "infoBg")
    if tt%2~=0 then
         infoBg:setVisible(false)
    end
    ticon:loadTexture("gongyong_tubiao_gongren_1.png", me.localType)
    ticon:ignoreContentAdaptWithSize(true)
    if self.farmerEnough then
        tdesc:setColor(COLOR_GREEN)
        tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
        toptBtn:setVisible(false)
    else
        tdesc:setColor(COLOR_RED)
        tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
        toptBtn:setTitleText(TID_BUTTON_JUMPTO)
        toptBtn:setVisible(true)
    end
    self.farmer_need:setVisible(self.farmerEnough)
    tdesc:setString(TID_NEED_FAEMER..self.needFarmerMin)
    self.nlist_1:pushBackCustomItem(bItem)
    me.setButtonDisable(self.optBtn_imme, self.canImme and self.farmerEnough)

    local itemNums=0
    local function addResItems(typeKey)
        print(def[typeKey])
        if me.toNum(def[typeKey]) > 0 then
            itemNums=itemNums+1
            local ndata = def
            local tItem = me.createNode("bLevelUpNeedItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
            local infoBg = me.assignWidget(bItem, "infoBg")
            if itemNums%2==0 then
                infoBg:setVisible(false)
            end
            local resName = nil
            if typeKey == "food" then
                resName = ICON_RES_FOOD
            elseif typeKey == "wood" then
                resName = ICON_RES_LUMBER
            elseif typeKey == "stone" then
                resName = ICON_RES_STONE
            elseif typeKey == "gold" then
                resName = ICON_RES_GOLD
            end
            ticon:loadTexture(resName, me.localType)
            if def[typeKey] > user[typeKey] then
                tdesc:setColor(COLOR_RED)
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                toptBtn:setVisible(true)
                toptBtn:setTitleText(TID_BUTTON_GETMORE)
                self.bMeet = false
                me.registGuiClickEvent(toptBtn,function (node,event)
                    if event ~= ccui.TouchEventType.ended then
                        local tmpView = recourceView:create("rescourceView.csb")
                        tmpView:setRescourceType(typeKey)
                        tmpView:setRescourceNeedNums(def[typeKey])
                        mainCity:addChild(tmpView, self:getLocalZOrder())
                        me.showLayer(tmpView, "bg")
                    end
                end)
            else
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                toptBtn:setVisible(false)
                tdesc:setColor(COLOR_GREEN)
            end
            tdesc:setString(def[typeKey])
            self.nlist_2:pushBackCustomItem(bItem)
            if isThread_ then
                coroutine.yield()
            end
        end
    end
    addResItems("food")
    addResItems("wood")
    addResItems("stone")
    addResItems("gold")
    --   print("-----2222----------")
    --  print(self.bMeet)
    me.setButtonDisable(self.optBtn_lvup, self.bMeet and self.farmerEnough)
end
function buildLevelUpLayer:close()
    -- me.hideLayer(self,true,"shopbg")
    UserModel:removeLisener(self.listener)
    mainCity.bLevelUpLayer = nil
    self:removeFromParentAndCleanup(true)
end
function buildLevelUpLayer:onEnter()
    print(" buildLevelUpLayer onEnter")
    me.doLayout(self, me.winSize)
    
    self.listener = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or 
            checkMsg(msg.t, MsgCode.CITY_UPDATE) then
            self:initForBuild(false)
        end
    end)   
    if self.optBtn_lvup then
        guideHelper.nextStepByOpt(false,self.optBtn_lvup)
    end
end
function buildLevelUpLayer:onExit()
    print(" buildLevelUpLayer onExit")
    me.coroClear(self.schid)
end
function buildLevelUpLayer:createEditBox()
    local function editFiledCallBack(strEventName,pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()
            if text == nil or me.isValidStr(text) == false then
                return 
            end

            if me.isPureNumber(text) then
                if me.toNum(text) <= self.needFarmerMax then
                    if me.toNum(text) > user.idlefarmer then
                        showTips(TID_BUILDUP_NOT_ENOUGH)
                        pSender:setText(user.idlefarmer)
                    elseif me.toNum(text) < self.needFarmerMin then
                        showTips(TID_BUILDUP_NEEDLEAST..self.needFarmerMin)
                        pSender:setText(self.curSelectFarmer)
                    else
                        self.curSelectFarmer = me.toNum(text)
                    end
                else
                    showTips("超出上限")
                end                
            else
                showTips("请输入有效数字")
            end

            self.slider_bar:setPercent(self.curSelectFarmer * 100 / self.needFarmerMax)
            self:resetFarmerStatus(self.curSelectFarmer)
        end
    end
    local eb = me.addInputBox(60,40,20,"defaut.png",editFiledCallBack,cc.EDITBOX_INPUT_MODE_NUMERIC)
    eb:setPositionX(15)
    self.Node_EditBox:addChild(eb)
    return eb
end