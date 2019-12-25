treatView = class("treatView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
treatView.__index = treatView
treatView.instance = nil

function treatView:getInstance()
    if treatView.instance == nil then
        print("create new treat view !!!! ")
        treatView.instance = treatView:create("treatLayer.csb")
    end
    return treatView.instance
end

function treatView:create(...)
    local layer = treatView.new(...)
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
TREAT_TYPE_SERVER = 0
TREAT_TYPE_NETSERVER = 1
function treatView:ctor()
    print("treatView ctor")
    self.allData = nil
    self.tableView = nil
    self.timer = nil
end

function treatView:init()
    print("treatView init")
    me.registGuiClickEventByName(self, "close", function()
        self:close()
    end )

    local selAll = false
    me.registGuiClickEventByName(self, "Button_All", function()
        selAll = false
        for key, var in pairs(self.allData) do
            if var.curNum ~= var.num then
                selAll = true
                break
            end
        end

        for key, var in pairs(self.allData) do
            if selAll then
                var.curNum = var.num
            else
                var.curNum = 0
            end
        end
        self:initList()
        self:updateRes()
    end )

    me.registGuiClickEventByName(self, "Button_Treat", function()
        local army = { }
        local curNum = 0
        for key, var in pairs(self.allData) do
            local temp = { }
            temp.id = var.defId
            temp.num = var.curNum
            curNum = curNum + var.curNum
            if var.curNum > 0 then
                table.insert(army, temp)
            end
        end
        if curNum > 0 then
            NetMan:send(_MSG.revertSoldier(army, 0, self.treatType))
            self:close()
        else
            showTips("请选择伤兵数量", "FF0000")
        end
    end )
    me.registGuiClickEventByName(self, "Button_Fast", function()
        local army = { }
        local curNum = 0
        for key, var in pairs(self.allData) do
            local temp = { }
            temp.id = var.defId
            temp.num = var.curNum
            curNum = curNum + var.curNum
            if var.curNum > 0 then
                table.insert(army, temp)
            end
        end
        if curNum > 0 then
            local function diamondUse()
                if self:getTreatState() == BUILDINGSTATE_WORK_TREAT.key then
                    NetMan:send(_MSG.buildQuickGem(self.tofid))
                else
                    NetMan:send(_MSG.revertSoldier(army, 1,self.treatType))
                end
                self:close()
            end
            local needDiamond = tonumber(self.Text_Diamond:getString())
            if user.diamond < needDiamond then
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
        else
            showTips("请选择伤兵数量", "FF0000")
        end
    end )

    self.Text_TroopsNum = me.assignWidget(self, "Text_TroopsNum")
    self.border = me.assignWidget(self, "border")
    self.Text_MarchTime = me.assignWidget(self, "Text_MarchTime")
    self.Text_food = me.assignWidget(self, "Text_food")
    self.Text_mood = me.assignWidget(self, "Text_mood")
    self.Text_stone = me.assignWidget(self, "Text_stone")
    self.Text_gold = me.assignWidget(self, "Text_gold")
    self.Text_Diamond = me.assignWidget(self, "Text_Diamond")
    self.Node_treating = me.assignWidget(self, "Node_treating")
    self.Node_res = me.assignWidget(self, "Node_res")
    self.Text_leftTime = me.assignWidget(self, "Text_leftTime")
    self.Image_leftTime = me.assignWidget(self, "Image_leftTime")
    self.Button_All = me.assignWidget(self, "Button_All")
    self.Button_Treat = me.assignWidget(self, "Button_Treat")
    self.Button_server = me.registGuiClickEventByName(self, "Button_server", function()
        if table.nums(user.desableSoldiers) <= 0  then
            showTips("暂无本服伤兵")
            return
        end
        if self.block then
            showTips("正在治疗中")
            return 
        end
        if self.treatType ~= TREAT_TYPE_SERVER then
            self.treatType = TREAT_TYPE_SERVER
            for key, var in pairs(user.desableSoldiers) do
                var.curNum = 0
            end
            for key, var in pairs(user.desableSoldiers_c) do
                var.curNum = 0
            end
            self.allData = nil
            self:initList()
            self:updateRes()
        end
    end )
    self.Button_netserver = me.registGuiClickEventByName(self, "Button_netserver", function()
        if table.nums(user.desableSoldiers_c) <= 0 then
            showTips("暂无跨服伤兵")
            return
        end
        if self.block then
            showTips("正在治疗中")
            return 
        end
        if self.treatType ~= TREAT_TYPE_NETSERVER then
            self.treatType = TREAT_TYPE_NETSERVER
            for key, var in pairs(user.desableSoldiers) do
                var.curNum = 0
            end
            for key, var in pairs(user.desableSoldiers_c) do
                var.curNum = 0
            end
            self.allData = nil
            self:initList()
            self:updateRes()
        end
    end )
    
    self.rateTxt = me.assignWidget(self, "rateTxt")
    self.rateTxt:setVisible(false)
    
    return true
end
function treatView:setBuildTofid(bid_,ctype,block)
    self.tofid = bid_
    self.treatType = ctype
    self.block = block or false
end
function treatView:getProduceTime()
    local bMoudles = mainCity:getBuildingMoudles()
    local buildObj = bMoudles[self.tofid]
    if buildObj then
        return buildObj:getProduceTime()
    else
        __G__TRACKBACK__("user.building[" .. self.tofid .. "] is nil !!!! ")
    end
    return nil
end
function treatView:getTreatState()
    local state = nil
    if user.building[self.tofid] then
        state = user.building[self.tofid].state
    else
        __G__TRACKBACK__("user.building[" .. self.tofid .. "[.state is nil !!!!! ")
    end
    return state
end
function treatView:initList()

    if self.treatType == TREAT_TYPE_SERVER then
        self.Button_server:loadTextureNormal("ui_ty_button_select.png", me.localType)
        self.Button_netserver:loadTextureNormal("ui_ty_button_unselect.png", me.localType)
        me.assignWidget(self.Button_server,"image_title"):setTextColor(cc.c3b(189,166,123))
        me.assignWidget(self.Button_netserver,"image_title"):setTextColor(cc.c3b(146,138,109))
    elseif self.treatType == TREAT_TYPE_NETSERVER then
        self.Button_server:loadTextureNormal("ui_ty_button_unselect.png", me.localType)
        self.Button_netserver:loadTextureNormal("ui_ty_button_select.png", me.localType)
        me.assignWidget(self.Button_server,"image_title"):setTextColor(cc.c3b(146,138,109))
        me.assignWidget(self.Button_netserver,"image_title"):setTextColor(cc.c3b(189,166,123))
    end
    self.Button_server:setContentSize(cc.size(196, 69))
    self.Button_netserver:setContentSize(cc.size(196, 69))

    if self.allData == nil then
        self.allData = { }
        if self.treatType == TREAT_TYPE_SERVER then
            if self:getTreatState() == BUILDINGSTATE_WORK_TREAT.key then
                local function isTreating(defId_)
                    if user.revertingSoldiers[self.tofid] then
                        for key, var in pairs(user.revertingSoldiers[self.tofid].army) do
                            if me.toNum(var.defId) == me.toNum(defId_) then
                                return var
                            end
                        end
                    end
                    return nil
                end
                local tmpData = nil
                for key, var in pairs(user.desableSoldiers) do
                    tmpData = isTreating(key)
                    if tmpData == nil then
                        table.insert(self.allData, 1, var)
                    else
                        table.insert(self.allData, #self.allData + 1, tmpData)
                    end
                end
            else
                for key, var in pairs(user.desableSoldiers) do
                    table.insert(self.allData, var)
                end
            end
        elseif self.treatType == TREAT_TYPE_NETSERVER then
            if self:getTreatState() == BUILDINGSTATE_WORK_TREAT.key then
                local function isTreating(defId_)
                    if user.revertingSoldiers_c[self.tofid] then
                    for key, var in pairs(user.revertingSoldiers_c[self.tofid].army) do
                        if me.toNum(var.defId) == me.toNum(defId_) then
                            return var
                        end
                    end
                    end
                    return nil
                end
                local tmpData = nil
                for key, var in pairs(user.desableSoldiers_c) do
                    tmpData = isTreating(key)
                    if tmpData == nil then
                        table.insert(self.allData, 1, var)
                    else
                        table.insert(self.allData, #self.allData + 1, tmpData)
                    end
                end
            else
                for key, var in pairs(user.desableSoldiers_c) do
                    table.insert(self.allData, var)
                end
            end
        end
    end

    local function cellSizeForTable(table, idx)
        return 1162, 135
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local soldierdata = self.allData[idx + 1]
        local label = nil
        if nil == cell and soldierdata then
            cell = cc.TableViewCell:new()
            local item = treatCell:create(me.createNode("Node_Treat_Item.csb"), "expedItem")
            item:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
            item:initWithData(soldierdata, idx + 1)
            cell:addChild(item)
            item:setParent(self)

            me.assignWidget(item, "shangbingIco"):setVisible(true)
            local slider = me.assignWidget(item, "Slider_Soldier")
            local Button_Reduce = me.assignWidget(item, "Button_Reduce")
            local Button_Add = me.assignWidget(item, "Button_Add")
            local Button_icon = me.assignWidget(item, "Button_icon")
            if self:getTreatState() == BUILDINGSTATE_WORK_TREAT.key then
                slider:setEnabled(false)
                Button_Reduce:setTouchEnabled(false)
                Button_Add:setTouchEnabled(false)
                Button_icon:setTouchEnabled(false)
            else
                slider:setEnabled(true)
                slider:setTouchEnabled(true)
                Button_Reduce:setTouchEnabled(true)
                Button_Add:setTouchEnabled(true)
                Button_icon:setTouchEnabled(true)
            end
        else
            local item = me.assignWidget(cell, "expedItem")
            item:setParent(self)
            item:initWithData(soldierdata)
            local slider = me.assignWidget(item, "Slider_Soldier")
            local Button_Reduce = me.assignWidget(item, "Button_Reduce")
            local Button_Add = me.assignWidget(item, "Button_Add")
            local Button_icon = me.assignWidget(item, "Button_icon")
            if self:getTreatState() == BUILDINGSTATE_WORK_TREAT.key then
                slider:setEnabled(false)
                Button_Reduce:setTouchEnabled(false)
                Button_Add:setTouchEnabled(false)
                Button_icon:setTouchEnabled(false)
            else
                slider:setEnabled(true)
                slider:setTouchEnabled(true)
                Button_Reduce:setTouchEnabled(true)
                Button_Add:setTouchEnabled(true)
                Button_icon:setTouchEnabled(true)
            end
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return #self.allData
    end

    if self.tableView then
        self.tableView:reloadData()
    else
        self.tableView = cc.TableView:create(cc.size(1162, 329))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.border:addChild(self.tableView)
        self.tableView:setPosition(cc.p(7, 5))
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self.tableView:reloadData()
    end
end
-- 得到钻石数量
function treatView:getPrice(curTime_)
    local gold = 0
    local food = 0
    local wood = 0
    local stone = 0
    local totalCur = 0
    local const = me.split(cfg[CfgType.CFG_CONST][43].data,",")
    for key, var in pairs(self.allData) do
        local def = var:getDef()
        local tmpNum = tonumber(const[1])
        -- 伤兵修复的资料折扣
        if self.treatType == TREAT_TYPE_NETSERVER then
            tmpNum = tonumber(const[2])
        
        end
        food = food + var.curNum * def.food / tmpNum
        gold = gold + var.curNum * def.gold / tmpNum
        wood = wood + var.curNum * def.wood / tmpNum
        stone = stone + var.curNum * def.stone / tmpNum
        totalCur = totalCur + var.curNum
    end

    local price = { }
    price.food = food
    price.wood = wood
    price.stone = stone
    price.gold = gold
    if self.treatType == TREAT_TYPE_SERVER then
            local xpro =  1 - user.propertyValue["ZiLiaoDiscount"] 
            price.food = math.ceil( price.food * xpro)
            price.wood = math.ceil( price.wood * xpro)
            price.stone = math.ceil( price.stone * xpro)
            price.gold = math.ceil( price.gold * xpro)
    end
    if curTime_ then
        price.time = curTime_
    else
        local xtech = user.propertyValue["TreatTime"] or 0
        price.time =(1 +(totalCur - 1) * 2) *(1 - xtech /(1 + xtech))
        print(price.time, totalCur)
    end
    price.index = 2
    return price
end
-- 得到当前治疗伤兵的总数
function treatView:getTotalCur()
    local totalNum = 0
    for key, var in pairs(self.allData) do
        totalNum = totalNum + var.curNum
    end
    return me.toNum(totalNum)
end
function treatView:updateRes()
    if self:getTreatState() == BUILDINGSTATE_WORK_TREAT.key then
        self.Node_res:setVisible(false)
        self.Node_treating:setVisible(true)
        self.Image_leftTime:setVisible(false)
        me.buttonState(self.Button_All, false)
        me.buttonState(self.Button_Treat, false)
        local bTitle = me.assignWidget(self.Button_All, "image_title")
        bTitle:setColor(me.convert3Color_("7F7F7F"))
        bTitle = me.assignWidget(self.Button_Treat, "image_title")
        bTitle:setColor(me.convert3Color_("7F7F7F"))
        if self.treatType == TREAT_TYPE_SERVER then 
            self.Text_TroopsNum:setString(self:getTotalCur() .. "/" .. user.treatNumAdd)
        elseif self.treatType == TREAT_TYPE_NETSERVER then 
            self.Text_TroopsNum:setString(self:getTotalCur() .. "/无上限") 
        end
        if self.timer == nil then
            local curTime = self:getProduceTime()
            self.timer = me.registTimer(-1, function(dt)
                if curTime <= 0 then
                    self:close()
                else
                    curTime = curTime - dt
                    if curTime <= 0 then
                        curTime = 0
                    end
                    self.Text_leftTime:setString("剩余时间：" .. me.formartSecTime(curTime))
                    local price = self:getPrice(curTime)
                    local allCost = getGemCost(price)
                    self.rateTxt:setVisible(false)
                    if allCost>0 and user.propertyValue["ZiLiaoDiscount"]>0 then
                        self.rateTxt:setVisible(true)
                        self.rateTxt:setString("已享受伤兵资源优惠："..(user.propertyValue["ZiLiaoDiscount"]*100).."%")
                    end
                    self.Text_Diamond:setString(math.ceil(allCost))
                end
            end , 1)
        end
    else
        self.Node_res:setVisible(true)
        self.Node_treating:setVisible(false)
        self.Image_leftTime:setVisible(true)
        me.buttonState(self.Button_All, true)
        me.buttonState(self.Button_Treat, true)
        local bTitle = me.assignWidget(self.Button_All, "image_title")
        bTitle:setColor(me.convert3Color_("ffffff"))
        bTitle = me.assignWidget(self.Button_Treat, "image_title")
        bTitle:setColor(me.convert3Color_("ffffff"))

        if self.treatType == TREAT_TYPE_SERVER then 
            self.Text_TroopsNum:setString(self:getTotalCur() .. "/" .. user.treatNumAdd)
        elseif self.treatType == TREAT_TYPE_NETSERVER then 
            self.Text_TroopsNum:setString(self:getTotalCur() .. "/无上限") 
        end
        local price = self:getPrice()
        -- 各种资源
        self.Text_food:setString(math.floor(price.food))
        if math.floor(price.food) > user.food then
            self.Text_food:setTextColor(COLOR_RED)
        else
            self.Text_food:setTextColor(COLOR_GREEN)
        end
        self.Text_mood:setString(math.floor(price.wood))
        if math.floor(price.wood) > user.wood then
            self.Text_mood:setTextColor(COLOR_RED)
        else
            self.Text_mood:setTextColor(COLOR_GREEN)
        end
        self.Text_stone:setString(math.floor(price.stone))
        if math.floor(price.stone) > user.stone then
            self.Text_stone:setTextColor(COLOR_RED)
        else
            self.Text_stone:setTextColor(COLOR_GREEN)
        end
        self.Text_gold:setString(math.floor(price.gold))
        if math.floor(price.gold) > user.gold then
            self.Text_gold:setTextColor(COLOR_RED)
        else
            self.Text_gold:setTextColor(COLOR_GREEN)
        end
        local allCost = getGemCost(price)
        self.Text_Diamond:setString(math.ceil(allCost))
        if math.ceil(allCost) > user.diamond then
            self.Text_Diamond:setTextColor(COLOR_RED)
        else
            self.Text_Diamond:setTextColor(COLOR_YELLOW)
        end
        self.rateTxt:setVisible(false)
        if allCost>0 and user.propertyValue["ZiLiaoDiscount"]>0 then
            self.rateTxt:setVisible(true)
            self.rateTxt:setString("已享受伤兵资源优惠："..(user.propertyValue["ZiLiaoDiscount"]*100).."%")
        end
        self:setCurTime()
    end
end
function treatView:setCurTime()
    local totalTime = 0
    local totalCur = self:getTotalCur()
    if totalCur ~= 0 then
        totalTime = 1 +(totalCur - 1) * 2
        totalTime = totalTime *(1 -(user.propertyValue["TreatTime"] /(1 + user.propertyValue["TreatTime"])))
        print(totalTime, totalCur)
        self.Text_MarchTime:setString(me.formartSecTime(totalTime))
    else
        self.Text_MarchTime:setString(me.formartSecTime(0))
    end
end
function treatView:close()
    print("treatView:close()")
    me.clearTimer(self.timer)
    self.timer = nil
    self:removeFromParentAndCleanup(true)
end
function treatView:onEnter()
    print("treatView onEnter")
    me.doLayout(self, me.winSize)
    for key, var in pairs(user.desableSoldiers) do
        var.curNum = 0
    end
    for key, var in pairs(user.desableSoldiers_c) do
        var.curNum = 0
    end
    self:initList()
    self:updateRes()
end

function treatView:onExit()
    print("treatView onExit")
    me.clearTimer(self.timer)
    self.timer = nil
    treatView.instance = nil
    self.allData = nil
end
