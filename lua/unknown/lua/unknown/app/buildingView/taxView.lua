--联盟要塞 
taxView = class("taxView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
taxView.__index = taxView
function taxView:create(...)
    local layer = taxView.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function taxView:ctor()  
     me.registGuiClickEventByName(self,"close",function(node)
       self:close()
     end)
     me.registGuiClickEventByName(self,"fixLayout",function(node)
       self:close()
     end)
end
function taxView:close()
  self:removeFromParentAndCleanup(true)
  mainCity.tax = nil
end
function taxView:init()
    print("taxView init")
    self.cding = false
    self.bg = me.assignWidget(self, "bg")
    self.forceTaxBtn = me.assignWidget(self,"forceTaxBtn")
    self.freeTaxBtn = me.assignWidget(self,"freeTaxBtn")
    self.oneKeyBtn = me.assignWidget(self, "oneKeyBtn")
    self.Button_question = me.assignWidget(self,"Button_question")
    self.Text_actityScore = me.assignWidget(self,"Text_actityScore")
    self.nowTime = me.sysTime()


    local function taxBtnCallBack(node)
        if self.newCount > 0 then 
            if node == self.freeTaxBtn and self.currentScore < me.toNum(self.freeNeed) then
                showTips("当前活动积分不足")
                return                                
            end
            if node == self.forceTaxBtn and user.diamond < me.toNum(self.payNeed) then
                showTips("当前钻石不足")
                return                                
            end
            if node == self.oneKeyBtn and self.quickTimes <= 0 then
                showTips("当前活动积分不足")
                return
            end
            if node == self.oneKeyBtn then
                local box = MessageBox:create("MessageBox.csb")
                box:setText(string.format("确认消耗%s征收积分，进行%s次征收吗？", self.quickNeedScore, self.quickTimes))
                box:register(function(name)
                    if name == "ok" and not self.isOneKeying then
                        self.isOneKeying = true
                        self.forceTaxBtn:setTouchEnabled(false)
                        self.freeTaxBtn:setTouchEnabled(false)
                        self.oneKeyBtn:setTouchEnabled(false)
                        self:cdAnimation(node)
                    end
                end)
                self:addChild(box, me.ANIMATION)
            else
                self.forceTaxBtn:setTouchEnabled(false)
                self.freeTaxBtn:setTouchEnabled(false)
                self.oneKeyBtn:setTouchEnabled(false)
                self:cdAnimation(node)
            end
        else
            showTips("征收次数已用完")
        end               
    end

    me.registGuiClickEvent(self.forceTaxBtn,function(node)
        taxBtnCallBack(node)
    end)   

    me.registGuiClickEventByName(self, "taxJump",function(node)
        local cstate = roleBuffLayer:create("cityStateView.csb",nil, 3)
        me.popLayer(cstate, "bg_frame")
    end)
   
    me.registGuiClickEvent(self.freeTaxBtn,function(node)
        taxBtnCallBack(node)
    end)
    
    me.registGuiClickEvent(self.oneKeyBtn,function(node)
        taxBtnCallBack(node)
    end)
 
    me.registGuiClickEvent(self.Button_question,function(node)
        NetMan:send(_MSG.taxDetail())    -- 详情
    end)   
    return true
end
function taxView:initWithData(data)   
    self.maxCount = data.maxCount
    self.countTime = data.freeCountTime
    self.newCount = data.maxCount - data.newFreeCount - data.newPayCount
    self.payNeed = data.payNeed
    self.freeNeed = data.freeNeed
    self.quickNeedScore = data.quickNeedScore
    self.quickTimes = data.quickTimes
    self.currentScore = data.score
--    self.payCount = data.payMaxCount - data.payCount
--    self.payCost = data.payCost
    self.resInfo = data.info
    self.Text_actityScore:setString(data.score)
    me.assignWidget(self,"restTime"):setString(self.newCount)
    if self.newCount > 0 then   
       if self.cding then 
            self.forceTaxBtn:setTouchEnabled (false)
            self.freeTaxBtn:setTouchEnabled(false)
       end
       me.assignWidget(self,"rest"):setString("今日征收次数:")
       me.assignWidget(self,"restTime"):setString(self.newCount)
    end

    me.assignWidget(self,"cost_score"):setString("x"..self.quickNeedScore)
    me.assignWidget(self,"cost_activity"):setString("x"..self.freeNeed)  
    me.assignWidget(self,"cost"):setString("x"..self.payNeed)  
    me.assignWidget(self,"rest"):setVisible(self.newCount > 0)
    me.assignWidget(self,"noTimes"):setVisible(self.newCount <= 0)
    me.assignWidget(self,"foodNum"):setString(self.resInfo[1])
    me.assignWidget(self,"woodNum"):setString(self.resInfo[2])
    me.assignWidget(self,"stoneNum"):setString(self.resInfo[3])
    me.assignWidget(self,"goldNum"):setString(self.resInfo[4])
end
function taxView:initTaxLogTable(tb, isLoading)
    if self.taxLogTable then 
        self.taxLogTable:removeAllChildren()
        me.assignWidget(self,"taxLogBg"):removeChildByTag(1)
    end
    local num = #tb
    if isLoading then 
        num = num - 1
    end

    local function cellSizeForTable(table, idx)
        return 1086, 65
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
          cell = cc.TableViewCell:new()
          local logCell = me.assignWidget(self,"logCell"):clone()
          self:setLogCell(logCell,tb[num-idx]) 
          logCell:setAnchorPoint(0,0)  
          logCell:setVisible(true)
          logCell:setPosition(cc.p(2,0))           
          cell:addChild(logCell)                                       
        else
          local logCell = me.assignWidget(cell,"logCell")
          self:setLogCell(logCell,tb[num-idx])
        end  
        return cell
    end

    local function numberOfCellsInTableView(table)        
        return num
    end
    self.taxLogTable = cc.TableView:create(cc.size(1188,123))
    self.taxLogTable:setTag(1)
    self.taxLogTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.taxLogTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.taxLogTable:setPosition(cc.p(4,6))
    self.taxLogTable:setDelegate()
    me.assignWidget(self,"taxLogBg"):addChild(self.taxLogTable)  

    self.taxLogTable:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.taxLogTable:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.taxLogTable:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.taxLogTable:reloadData()  
end

function taxView:onEnter()      
	me.doLayout(self,me.winSize) 
    
    -- 记录初始资源数量
    local resNumList = {food = user.food, wood = user.wood, stone = user.stone, gold = user.gold}
    self.modelkey = UserModel:registerLisener(function(msg) -- 注册消息通知
        if checkMsg(msg.t, MsgCode.CITY_TAX_DETAIL) then
            local detailInfo = turnplateDetailCell:create("turnplateDetail.csb")
            detailInfo:setDetailData(msg.c)
            mainCity:addChild(detailInfo,me.MAXZORDER)
            me.assignWidget(detailInfo,"bg"):setPosition(cc.p(me.winSize.width/2, me.winSize.height/2))
            me.showLayer(detailInfo, "bg")
        elseif checkMsg(msg.t, MsgCode.CITY_TAX_GET) then
            self:setLog2(msg.c)
            local logStr = SharedDataStorageHelper():getTaxLog()
            if logStr and logStr ~= "" then 
                local logInfo = me.split(logStr, ";")
                self:initTaxLogTable(logInfo)
            end
        elseif checkMsg(msg.t, MsgCode.ROLE_RESOURCE_UPDATE) then
            local tempList = {}
            local function executeAction(node, idx, pos)
                if #tempList == idx then
                    getItemAnim_itemLayer:setTouchEnabled(true)
                end
                local spawn = cc.Spawn:create(
                    cc.MoveTo:create(0.5, pos),
                    cc.ScaleTo:create(0.5, 0)
                )
                node:runAction(cc.Sequence:create(spawn, cc.CallFunc:create(function()
                    if #tempList == idx then
                        if getItemAnim_itemLayer and not tolua.isnull(getItemAnim_itemLayer) then
                            getItemAnim_itemLayer:removeFromParentAndCleanup(true)
                            getItemAnim_itemLayer = nil
                        end
                        getItemAnim_itemQueue = nil
                        singleItem = nil
                    end
                end)))
            end
            local addFood = msg.c.food - resNumList.food
            if addFood > 0 then
                table.insert(tempList, {
                    defId = 9001,
                    itemNum = addFood,
                    cb = function(node, idx)
                        local x, y = mainCity.food_label:getPosition()
                        local pos_world = mainCity.ui_bar:convertToWorldSpace(cc.p(x - 20, y))
                        local pos_local = getItemAnim_itemLayer:convertToNodeSpace(pos_world)
                        executeAction(node, idx, pos_local)
                    end,
                })
                resNumList.food = msg.c.food
            end
            local addWood = msg.c.wood - resNumList.wood
            if addWood > 0 then
                table.insert(tempList, {
                    defId = 9002,
                    itemNum = addWood,
                    cb = function(node, idx)
                        local x, y = mainCity.lumber_label:getPosition()
                        local pos_world = mainCity.ui_bar:convertToWorldSpace(cc.p(x - 20, y))
                        local pos_local = getItemAnim_itemLayer:convertToNodeSpace(pos_world)
                        executeAction(node, idx, pos_local)
                    end,
                })
                resNumList.wood = msg.c.wood
            end
            local addStone = msg.c.stone - resNumList.stone
            if addStone > 0 then
                table.insert(tempList, {
                    defId = 9003,
                    itemNum = addStone,
                    cb = function(node, idx)
                        local x, y = mainCity.stone_label:getPosition()
                        local pos_world = mainCity.ui_bar:convertToWorldSpace(cc.p(x - 20, y))
                        local pos_local = getItemAnim_itemLayer:convertToNodeSpace(pos_world)
                        executeAction(node, idx, pos_local)
                    end,
                })
                resNumList.stone = msg.c.stone
            end
            local addGold = msg.c.gold - resNumList.gold
            if addGold > 0 then
                table.insert(tempList, {
                    defId = 9004,
                    itemNum = addGold,
                    cb = function(node, idx)
                        local x, y = mainCity.gold_label:getPosition()
                        local pos_world = mainCity.ui_bar:convertToWorldSpace(cc.p(x - 20, y))
                        local pos_local = getItemAnim_itemLayer:convertToNodeSpace(pos_world)
                        executeAction(node, idx, pos_local)
                    end,
                })
                resNumList.gold = msg.c.gold
            end
            if #tempList > 0 then
                getItemAnim(tempList)
                if getItemAnim_itemLayer and not tolua.isnull(getItemAnim_itemLayer) then
                    getItemAnim_itemLayer:setTouchEnabled(false)
                end
            end
        end
    end)
    print("taxView onEnter")

    -- 城镇中心等级
    local centerLv = user.centerBuild:getDef().level
    if centerLv < 15 then
        self.oneKeyBtn:setVisible(false)
        local bgSize = self.bg:getContentSize()
        self.forceTaxBtn:setPositionX(bgSize.width / 2 - 200)
        self.freeTaxBtn:setPositionX(bgSize.width / 2 + 200)
    end

    -- 征收记录
    if self.newCount == self.maxCount then 
       SharedDataStorageHelper():setTaxLog("")
    end
    local logStr = SharedDataStorageHelper():getTaxLog()
    if logStr and logStr ~= "" then 
        local logInfo = me.split(logStr, ";")
        self:initTaxLogTable(logInfo)
    end
end
function taxView:onExit() 
    print("taxView onExit") 
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    me.clearTimer(self.cdTimer)
end


function taxView:cdAnimation(node)
    if restTime then 
        self.cdPercent = restTime / 1000 * 100
    else 
        self.cdPercent = 0 
    end
    self.cding = true
    self.cdTimer = me.registTimer(-1,function()
        self.cdPercent = self.cdPercent + 5/3
        if self.cdPercent > 100 then 
            me.clearTimer(self.cdTimer)
            me.assignWidget(self,"LoadingBar"):setContentSize(cc.size(0, 21.21))
            self.cding = false
            if node == self.freeTaxBtn then
                NetMan:send(_MSG.taxGet(nil, 0))
            elseif node == self.forceTaxBtn then
                NetMan:send(_MSG.taxGet(1, nil))
            elseif node == self.oneKeyBtn then
                NetMan:send(_MSG.taxGet(nil, 1))
                self.isOneKeying = false
            end
            self.freeTaxBtn:setTouchEnabled(true)
            self.forceTaxBtn:setTouchEnabled(true)
            self.oneKeyBtn:setTouchEnabled(true)
       else
            me.assignWidget(self,"LoadingBar"):setContentSize(cc.size((self.cdPercent/100)*841.39, 21.21))
        end
    end,0)     
end

function taxView:setLog(resInfo)
    if resInfo then 
        local str = SharedDataStorageHelper():getTaxLog()
        local strTime = os.date("%H:%M:%S")
        str = str..strTime.."|"..resInfo[1].."|"..resInfo[2].."|"..resInfo[3].."|"..resInfo[4]..";"
        SharedDataStorageHelper():setTaxLog(str)   
    end   
end

function taxView:setLog2(info)
    if info then
        local str = SharedDataStorageHelper():getTaxLog()
        local strTime = me.formartServerTime(info.tm / 1000)
        str = str..strTime.."|"
        local tempList = {"food", "wood", "stone", "gold"}
        local tempStr = info.times > 1 and (" x "..info.times) or ""
        for i, v in ipairs(tempList) do
            if i == #tempList then
                str = str..info[v]..tempStr..";"
            else
                str = str..info[v]..tempStr.."|"
            end
        end
        SharedDataStorageHelper():setTaxLog(str)
    end   
end

function taxView:setLogCell(widget,data)
    if widget and data then 
        local infoTb = me.split(data,"|")
        me.assignWidget(widget,"logTime"):setString(infoTb[1])
        me.assignWidget(widget,"fNum"):setString(infoTb[2])
        me.assignWidget(widget,"wNum"):setString(infoTb[3])
        me.assignWidget(widget,"sNum"):setString(infoTb[4])
        me.assignWidget(widget,"gNum"):setString(infoTb[5])
        widget:setVisible(true)
    end
end