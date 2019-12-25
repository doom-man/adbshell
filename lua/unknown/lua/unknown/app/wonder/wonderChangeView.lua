-- 训练
wonderChangeView = class("wonderChangeView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
wonderChangeView.__index = wonderChangeView
function wonderChangeView:create(...)
    local layer = wonderChangeView.new(...)
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
function wonderChangeView:ctor()
    print("wonderChangeView ctor")
    self.selectWonderDef = nil
    self.selectIdx = -1
    --当前建筑物的tofid
    self.buildTofid = 0
    --当前奇迹def
    self.oldWonderDef = nil
    --最小工人数
    self.minFarmer = 0
    --最大工人数 
    self.maxFarmer = 0
    --当前选择工人数
    self.curSelectFarmer = 0
    --工人不足
    self.farmerEnough = false

    self.bMeet = false
    self.canImme = false
end
function wonderChangeView:init()
    self.Slider_farmer = me.assignWidget(self,"Slider_farmer")
    self.btn_change = me.assignWidget(self,"btn_change")
    self.btn_imme = me.assignWidget(self,"btn_imme")
    self.ImageView_wonders = me.assignWidget(self,"ImageView_wonders")
    self.diamond = me.assignWidget(self,"diamond")
    self.need_time = me.assignWidget(self,"need_time")
    self.nlist_1 = me.assignWidget(self,"nlist_1")
    self.nlist_2 = me.assignWidget(self,"nlist_2")
    self.nlist_2:setScrollBarPositionFromCornerForVertical(cc.p(3, 7));
    self.farmer_num = me.assignWidget(self,"farmer_num")
    self.maxfarmer_num = me.assignWidget(self,"maxfarmer_num")
    self.btn_allot = me.assignWidget(self,"btn_allot")
    local function numEbCallBack(eventType,sender)
       if eventType == "began" then
          self.farmer_num:setVisible(false)
          self.maxfarmer_num:setVisible(false)
          sender:setText(self.curSelectFarmer)
       elseif eventType == "changed" then 
         if sender:getText() and sender:getText() ~= "" then
          if me.toNum(sender:getText()) > self.maxFarmer then 
             showTips("超出最大工人数")
             sender:setText( math.min(self.maxFarmer,user.idlefarmer))
          elseif me.toNum(sender:getText()) < self.minFarmer then 
             showTips("最少需要"..self.minFarmer.."个工人")
             sender:setText(self.minFarmer)
          elseif me.toNum(sender:getText()) > user.idlefarmer then 
             showTips("空闲工人数不够")
             sender:setText(user.idlefarmer)
          end
         end
        elseif eventType == "return" then 
           if sender:getText() and sender:getText() ~= "" then 
               print("eventType")
               self.curSelectFarmer = me.toNum(sender:getText())
               self.farmerEnough = true
               sender:setText("")
               self.farmer_num:setString(self.curSelectFarmer)
               self.farmer_num:setVisible(true)
               self.maxfarmer_num:setVisible(true)
               self.Slider_farmer:setPercent(self.curSelectFarmer/self.maxFarmer*100)
               self:updateGemAndTime()
               me.setButtonDisable(self.btn_change, self.bMeet and self.farmerEnough)
               me.setButtonDisable(self.btn_imme, self.canImme and self.farmerEnough)
           else
              self.farmer_num:setVisible(true)
              self.maxfarmer_num:setVisible(true)
           end
        end
    end
    self.farmerNumEb = me.addInputBox(100,30,24,nil,numEbCallBack,cc.EDITBOX_INPUT_MODE_NUMERIC,"")
    self.farmerNumEb:setFontColor(cc.c3b(222, 176, 122))
    self.farmerNumEb:setAnchorPoint(0,0)
    me.assignWidget(self,"Image_5"):addChild(self.farmerNumEb)
    
    me.registGuiClickEvent(self.btn_allot, function(node)
        local allot = allotLayer:create("allotLayer.csb")
        allot:initialize()
        mainCity:addChild(allot, me.MAXZORDER)
        me.showLayer(allot, "bg")
    end )

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    local tmp_notEnoughMin = false
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then            
            local percent = sender:getPercent() / 100                        
            local tempfarmer = math.floor(percent *self.maxFarmer)
            if self.curSelectFarmer ~= tempfarmer then
                self.curSelectFarmer = tempfarmer
                if self.curSelectFarmer > user.idlefarmer then
                    self.farmer_num:setTextColor(COLOR_RED)
                    self.farmerEnough = false
                    tmp_notEnoughMin = false
                    showTips(TID_BUILDUP_NOT_ENOUGH)
                elseif self.curSelectFarmer < self.minFarmer then 
                    self.farmer_num:setTextColor(COLOR_RED)
                    self.farmerEnough = false
                    tmp_notEnoughMin = true
                    showTips(TID_BUILDUP_NEEDLEAST..self.minFarmer)
                else
                    self.farmer_num:setTextColor(COLOR_WHITE)
                    self.farmerEnough = true
                    tmp_notEnoughMin = false
                end
                self:updateGemAndTime()
                self.farmer_num:setString(self.curSelectFarmer)
                me.setButtonDisable(self.btn_change, self.bMeet and self.farmerEnough)
                me.setButtonDisable(self.btn_imme, self.canImme and self.farmerEnough)
            end    
        end
    end
    local function sliderTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended and tmp_notEnoughMin then
            tmp_notEnoughMin = false
            self.farmerEnough = true    
            sender:setPercent(self.minFarmer/self.maxFarmer*100) 
            self.curSelectFarmer = math.floor(sender:getPercent() / 100 *self.maxFarmer)  
            self:updateGemAndTime()
            self.farmer_num:setString(self.curSelectFarmer)
            self.farmer_num:setTextColor(COLOR_WHITE)
            me.setButtonDisable(self.btn_change, self.bMeet and self.farmerEnough)
            me.setButtonDisable(self.btn_imme, self.canImme and self.farmerEnough)
        end
    end
    self.Slider_farmer:addTouchEventListener(sliderTouchEvent)
    self.Slider_farmer:addEventListener(sliderEvent)

    local function changecallback(node)
        NetMan:send(_MSG.changeWonder(self.curSelectFarmer,0,self.data.index,self.selectWonderDef.id))
        print("changecallback")
    end

    local function changecallback_imme(node)
        NetMan:send(_MSG.changeWonder(self.curSelectFarmer,1,self.data.index,self.selectWonderDef.id))
        print("changecallback_imme")
    end
    me.registGuiClickEvent(self.btn_change, changecallback)
    me.registGuiClickEvent(self.btn_imme, changecallback_imme)

    return true
end

--奇迹的数据组装
function wonderChangeView:initListDataForChange(def)
    self.oldWonderDef = def
    local ldata = {}
    for key, var in pairs(cfg[CfgType.BUILDING]) do
        if me.toNum(self.oldWonderDef.countryId) == me.toNum(var.countryId) and 
        self.oldWonderDef.type == var.type and 
        me.toNum(self.oldWonderDef.level) == me.toNum(var.level) and 
        me.toNum(self.oldWonderDef.id) ~= me.toNum(var.id) then
            ldata[#ldata+1] = var
        end
    end   
    ldata[#ldata+1] = self.oldWonderDef
    self:initList(ldata)
end

function wonderChangeView:initWithData(data,tofid,curtime)
    self.buildTofid = tofid
    self.data = data
    self.curtime = curtime
    local def = self.data:getDef()
    self:initListDataForChange(def)
end

function wonderChangeView:initList(data)
    local iNum = #data
    self.globalItems = me.createNode("Node_wonderItem.csb")
    self.globalItems:retain()
    local function tableCellTouched(table, cell)
        if self.selectIdx ~= cell:getIdx() then
            local newDef = data[cell:getIdx() + 1]
            if me.toNum(newDef.id) ~= me.toNum(self.oldWonderDef.id) then
                self.selectImg:setPosition(cell:getPositionX() + self.selectImg:getContentSize().width/2-1, cell:getPositionY() + self.selectImg:getContentSize().height/2-1)
                self.selectWonderDef = newDef
                self:updateRes()
                self.selectIdx = cell:getIdx()
            end
        end
    end

    local function cellSizeForTable(table, idx)
        return 290, 260
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local def = data[idx + 1]
        local label = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item = wonderChangeItem:create(self.globalItems, "wonderItem")
            item:initWithData(data[idx+1], self.oldWonderDef)
            item:setPosition(item:getContentSize().width / 2+5, item:getContentSize().height / 2+2)
            cell:addChild(item)
        else
            local item = me.assignWidget(cell, "wonderItem")
            item:initWithData(data[idx+1],self.oldWonderDef)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    local tableView = cc.TableView:create(cc.size(1165, 260))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(1, 0)
    tableView:setDelegate()
    self.ImageView_wonders:addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.selectImg = ccui.ImageView:create()
    self.selectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
    self.selectImg:setScale9Enabled(true)
    self.selectImg:ignoreContentAdaptWithSize(false)
    self.selectImg:setCapInsets(cc.rect(57, 57, 56, 56))
    self.selectImg:setContentSize(cc.size(290, 260))
    tableView:addChild(self.selectImg, -1)
    self.selectImg:setScale(1.02)
    local tcell = tableView:cellAtIndex(0)
    self.selectImg:setPosition(tcell:getPositionX() + self.selectImg:getContentSize().width/2-1, tcell:getPositionY() + self.selectImg:getContentSize().height/2-1)
    self.selectWonderDef = data[1]
    self:updateRes()
end 

function wonderChangeView:updateGemAndTime()
    local price = { }
    price.food = self.selectWonderDef.food
    price.wood = self.selectWonderDef.wood
    price.stone = self.selectWonderDef.stone
    price.gold = self.selectWonderDef.gold
    price.time = math.max( self.selectWonderDef.time2 - (user.propertyValue["FreeTime"] or 0),0)
    price.index = 1
    local allCost = getGemCost(price)
    if math.ceil(allCost) == 0 then
        self.diamond:setString("免费")
    else
        self.diamond:setString(math.ceil(allCost))
    end
    self.need_time:setString(me.formartSecTime(getCurFarmerBuildCostTime(self.curSelectFarmer,self.selectWonderDef)))
end

function wonderChangeView:updateRes()
   --根据当前工作状态显示UI
    self.nlist_1:removeAllChildren()
    self.nlist_2:removeAllChildren()
    self.canImme = true
    self.bMeet = true
    --需要当前建筑物的数据显示
    if me.isValidStr(self.selectWonderDef.buildLevel) then
        local t = me.split(self.selectWonderDef.buildLevel, ":")
        for key, var in pairs(t) do
            local ndata = cfg[CfgType.BUILDING][me.toNum(var)]
            local tItem = me.createNode("bLevelUpNeedItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
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
                    jumpToTarget(ndata)
                    self:close()
                end )
                self.bMeet = false
                self.canImme = false
            end
            tdesc:setString(ndata.name .. " " .. TID_LEVEL .. ndata.level)
            self.nlist_1:pushBackCustomItem(bItem)
        end
    end

    --工人数的数据显示
    self.minFarmer = self.selectWonderDef.farmer
    self.maxFarmer = self.selectWonderDef.maxfarmer
    self.curSelectFarmer = math.min(user.idlefarmer, self.maxFarmer)
    self.Slider_farmer:setPercent(self.curSelectFarmer/self.maxFarmer*100)
    if self.curSelectFarmer < self.minFarmer then
        self.farmer_num:setTextColor(COLOR_RED)
        self.farmerEnough = false
    else
        self.farmer_num:setTextColor(COLOR_WHITE)
        self.farmerEnough = true
    end
    self.farmer_num:setString(self.curSelectFarmer)
    self.maxfarmer_num:setString("/" .. self.maxFarmer)

    --矿木石等资源的数据显示
    local function addResItem(def,typeKey,icon)
        if def[typeKey] > 0 then
            local tItem = me.createNode("bLevelUpNeedItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            tcomplete:setPositionX(263)
            local toptBtn = me.assignWidget(bItem, "optBtn")
            toptBtn:setPositionX(421)
            ticon:loadTexture(icon, me.localType)
            me.registGuiClickEvent(toptBtn,function(node)
                local resView = recourceView:create("rescourceView.csb")
                resView:setRescourceType(typeKey)
				resView:setRescourceNeedNums(def[typeKey])
                self:addChild(resView)
                me.showLayer(resView, "bg")
            end)
            if def[typeKey] > user[typeKey] then
                tdesc:setColor(COLOR_RED)
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                toptBtn:setVisible(true)
                toptBtn:setTitleText(TID_BUTTON_GETMORE)
                self.bMeet = false
            else
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                toptBtn:setVisible(false)
                tdesc:setColor(COLOR_GREEN)
            end
            tdesc:setString(def[typeKey])
            self.nlist_2:pushBackCustomItem(bItem)
        end
    end

    addResItem(self.selectWonderDef,"food",ICON_RES_FOOD)
    addResItem(self.selectWonderDef,"wood",ICON_RES_LUMBER)
    addResItem(self.selectWonderDef,"stone",ICON_RES_STONE)
    addResItem(self.selectWonderDef,"gold",ICON_RES_GOLD)
    self:updateGemAndTime()
end

function wonderChangeView:close()
    print("wonderChangeView:close")
    self:removeFromParentAndCleanup(true)
end

function wonderChangeView:onEnter()
    print("wonderChangeView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or 
            checkMsg(msg.t, MsgCode.CITY_UPDATE) then
            self:updateRes()
        end
    end ,"wonderChangeView")
end

function wonderChangeView:onExit()
    print("wonderChangeView onExit")
    UserModel:removeLisener(self.modelkey)
    if self.globalItems then self.globalItems:release() end
end
