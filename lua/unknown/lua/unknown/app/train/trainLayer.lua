-- 训练
trainLayer = class("trainLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
trainLayer.__index = trainLayer
function trainLayer:create(...)
    local layer = trainLayer.new(...)
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
function trainLayer:ctor()
    print("trainLayer ctor")
    self.selectSoldierData = nil
    self.data = nil
    self.selectIdx = -1

    -- 生产上限数量
    self.totalNum = 0
    -- 最小生产的士兵数
    self.pSoldierMin = 1
    -- 已经生产完毕的士兵
    self.pSoldierFinish = 0
    -- 当前选择生产的士兵数
    self.pSoldierCur = 1
    -- 最大能生产的士兵数
    self.pSoldierMax = 100
    --- 当前选择士兵训练时间
    self.pSoldierTime = 0
    -- 当前建筑物的tofid
    self.buildTofid = 0
    self.curtime = 0
    -- 滑条的限制开关
    self.sliderTouchSwitch = true

    self.timer = nil

    -- 每个cell的坐标，用于任务和新手的跳转
    self.lData = nil
    self.tableView = nil
    self.cellSize = nil
end
function trainLayer:init()
    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.Node_normal = me.assignWidget(self, "Node_normal")
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
    self.border = me.assignWidget(self, "border")
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.Node_training = me.assignWidget(self, "Node_training")
    self.Text_soilderName = me.assignWidget(self, "Text_soilderName")
    self.Button_speedup = me.assignWidget(self, "Button_speedup")
    self.Text_speedDiamond = me.assignWidget(self, "Text_speedDiamond")
    self.LoadingBar_time = me.assignWidget(self, "LoadingBar_time")
    self.Text_singleTime = me.assignWidget(self, "Text_singleTime")
    self.Text_trapNum = me.assignWidget(self, "Text_trapNum")
    self.Text_totalTime = me.assignWidget(self, "Text_totalTime")

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
        NetMan:send(_MSG.prodSoldier(self.selectSoldierData.id, self.pSoldierCur, self.data.index))
    end

    local function diamondUse()
        NetMan:send(_MSG.prodSoldier(self.selectSoldierData.id, self.pSoldierCur, self.data.index, 1))
    end
            
    local function traincallback_imme(node)
        local needDiamond = tonumber(self.diamond:getString())
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

    local function traincallback_speedup(node)
        local needDiamond = 0
        local building = mainCity.buildingMoudles[self.buildTofid]
        if building then
            needDiamond = building:getImmeCost() or 0
        end
        if needDiamond > 0 then
            -- 确认弹窗
            diamondCostMsgBox(needDiamond, function()
                NetMan:send(_MSG.buildQuickGem(self.buildTofid))
                self:close()
            end)
        else
            NetMan:send(_MSG.buildQuickGem(self.buildTofid))
            self:close()
        end
    end

    me.registGuiClickEvent(self.btn_train, traincallback)
    me.registGuiClickEvent(self.btn_imme, traincallback_imme)
    me.registGuiClickEvent(self.Button_speedup, traincallback_speedup)

    self.Text_workersType = me.assignWidget(self,"Text_workersType")
    self.Text_FarmerNum = me.assignWidget(self,"Text_FarmerNum")
    self.curIdleFarmer = user.idlefarmer 
--    me.registGuiClickEventByName(self, "addBtn", function(node)
--        self:openAllotPopover(node)
--    end )
--    me.registGuiClickEventByName(self, "addBtn1", function(node)
--        self:openAllotPopover(node)
--    end )

    return true
end


function trainLayer:openAllotPopover(node)
    local bdata = node.bdata
    local allotPopLayer = allotPopOver:create("allotPopover.csb")
    allotPopLayer:initWithData(bdata, self)
    mainCity:addChild(allotPopLayer,me.MAXZORDER)
    me.showLayer(allotPopLayer,"bg")
end

function trainLayer:setWorkersInfo(visable)

    local data= user.building[self.buildTofid]
    local buildDef = cfg[CfgType.BUILDING][me.toNum(techDataMgr.getCurbuildId())]

    local def = data:getDef()
    self.Text_FarmerNum:setString(data.worker.."/"..def.inmaxfarmer)
--    if data.worker<def.inmaxfarmer then
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn1"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+6)
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(false)
--    else
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+6)
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(false)
--    end
end

function trainLayer:updateUI(bindex,curWorker)
    local data= user.building[bindex]
    local def = data:getDef()
    self.Text_FarmerNum:setString(curWorker.."/"..def.inmaxfarmer)
--    if curWorker<def.inmaxfarmer then
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn1"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+6)
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(false)
--    else
--        local addBtn = me.assignWidget(self,"addBtn")
--        addBtn:setVisible(true)
--        addBtn.bdata = data
--        me.assignWidget(self,"addBtn"):setPositionX(self.Text_FarmerNum:getPositionX()+self.Text_FarmerNum:getContentSize().width+6)
--        local addBtn = me.assignWidget(self,"addBtn1")
--        addBtn:setVisible(false)
--    end
end

-- 制造(陷阱)的数据组装
function trainLayer:initListDataForProduce(def)
    self.pSoldierFinish = 0
    local cfgstr = def.show
    local pDataNum = user.soldierData
    if cfgstr then
        local tb = me.split(cfgstr, ",")
        if tb then
            local ldata = { }
            for key, var in pairs(tb) do
                local tmp = me.split(var, ":")
                ldata[key] = { }
                ldata[key].sid = tmp[1]
                ldata[key].level = tmp[2]
                local pNum = 0
                if pDataNum ~= nil then
                    if pDataNum[me.toNum(tmp[1])] ~= nil then
                        pNum = pDataNum[me.toNum(tmp[1])]["num"]
                    end
                end
                ldata[key].num = pNum
                self.pSoldierFinish = self.pSoldierFinish + pNum
            end
            self:initList(ldata)
        end
    end
end

-- 训练的数据组装
function trainLayer:initListDataForTrain(def)
    local cfgstr = def.show
    local pDataNum = user.soldierData
    if cfgstr then
        local tb = me.split(cfgstr, ",")
        if tb then
            local ldata = { }
            for key, var in pairs(tb) do
                local temp = me.split(var, ":")
                ldata[key] = { }
                ldata[key].sid = temp[1]
                ldata[key].level = temp[2]
                local pNum = 0
                if pDataNum ~= nil then
                    if pDataNum[me.toNum(temp[1])] ~= nil then
                        pNum = pDataNum[me.toNum(temp[1])]["num"]
                    end
                end
                ldata[key].num = pNum
            end
            self:initList(ldata)
        end
    end
end

function trainLayer:initWithData(data, tofid, curtime)
    self.buildTofid = tofid
    self.data = data
    self.curtime = curtime
    local def = self.data:getDef()
    self.title:setString(def.name)
    if def.type == cfg.BUILDING_TYPE_DOOR then
        self:initListDataForProduce(def)
    else
        self:initListDataForTrain(def)
    end
    print('trainLayer init data')
    self:setWorkersInfo(true)
end

function trainLayer:initList(data)
    local iNum = #data
    self.globalItems = me.createNode("Node_trainItem.csb")
    self.globalItems:retain()
    self.lData = data
    local function tableCellTouched(table, cell)
        --        print("cell touched at index: " .. cfg[CfgType.CFG_SOLDIER][me.toNum(data[cell:getIdx() + 1].sid)].name)
        if self.selectIdx ~= cell:getIdx() and me.toNum(data[cell:getIdx() + 1].level) <= 0 then
            self.selectImg:setPosition(cell:getPositionX() + self.selectImg:getContentSize().width / 2, cell:getPositionY() + self.selectImg:getContentSize().height / 2 - 5)
            if self.data.state == BUILDINGSTATE_NORMAL.key then
                self.selectSoldierData = cfg[CfgType.CFG_SOLDIER][me.toNum(data[cell:getIdx() + 1].sid)]
                self:updateRes()
                local defaultNum = self:getDefaultNum()
                self.pSoldierCur = math.min(defaultNum, self.pSoldierMax)
                if self.pSoldierMax <= 0 then
                    self.slider_bar:setPercent(0)
                else
                    self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
                end
                self:updateRes()
                self.selectIdx = cell:getIdx()
               

            end
        end
    end

    local function cellSizeForTable(table, idx)
        self.cellSize = cc.size(241, 287)
        return self.cellSize.width, self.cellSize.height
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local def = cfg[CfgType.CFG_SOLDIER][me.toNum(data[idx + 1].sid)]
        local label = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item = trainSoldierItem:create(self.globalItems, "trainItem")
            self.itemWidth = item:getContentSize().width
            item.traindata = data
            item:initWithData(def, data[idx + 1], self.data)
            item:setPosition(item:getContentSize().width / 2 + 5, item:getContentSize().height / 2)
            cell:addChild(item)
        else
            local item = me.assignWidget(cell, "trainItem")
            item:initWithData(def, data[idx + 1], self.data)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    self.tableView = cc.TableView:create(cc.size(1163, 300))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.tableView:setPosition(2, 10)
    self.tableView:setDelegate()
    self.border:addChild(self.tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()
    self.selectImg = ccui.ImageView:create()
    self.selectImg:loadTexture("bingying_beijing_fangzheng_xuanzhe.png", me.localType)
    self.tableView:addChild(self.selectImg, 2)

    -- 默认选择当前能造的最多士兵
    local defaultIdx = -1
    for key, var in ipairs(data) do
        if me.toNum(var.level) ~= 0 then break end
        defaultIdx = defaultIdx + 1
    end
    if defaultIdx > 3 then
        self.tableView:setContentOffset(cc.p(-(defaultIdx - 3) *(self.itemWidth + 1), 0))
    end
    local tcell = self.tableView:cellAtIndex(defaultIdx)
    self.selectImg:setPosition(tcell:getPositionX() + self.selectImg:getContentSize().width / 2, tcell:getPositionY() + self.selectImg:getContentSize().height / 2 - 5)
    self.selectSoldierData = cfg[CfgType.CFG_SOLDIER][me.toNum(data[defaultIdx + 1].sid)]
    self:updateRes()

    local defaultNum = self:getDefaultNum()
    self.pSoldierCur = math.min(defaultNum, self.pSoldierMax)
    if self.pSoldierMax <= 0 then
        self.slider_bar:setPercent(0)
    else
        self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
    end
    self:updateRes()
end 

function trainLayer:updateRes()
    if self.pSoldierMax <= 0 then
        self.slider_bar:setPercent(0)
    else
        self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
    end

    local def = self.data:getDef()
    -- 得到当前陷阱的数量
    local function getTrapNumText(bid)
        if def.type == cfg.BUILDING_TYPE_DOOR then
            local d = user.produceSoldierLockData[bid]
            self.pSoldierMax = d.tnum
            if self.pSoldierMax <= 0 then
                self.pSoldierCur = 0
            end
            self.totalNum = d.totalNum
            local tmp = me.split(def.ext, ",")
            self.Text_trapNum:setVisible(true)
            local total = self.pSoldierFinish
            self.Text_trapNum:setString("陷阱：" .. total .. "/" .. self.totalNum)
            if self.pSoldierCur + total > self.totalNum then
                self.pSoldierCur = self.totalNum - total
                self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
            end
        elseif def.type == cfg.BUILDING_TYPE_WONDER then
            self.Text_trapNum:setVisible(true)
            local d = user.produceSoldierLockData[bid]
            self.Text_trapNum:setString("奇迹兵：" .. d.curWonder .. "/" .. d.wonderMax)
            if self.pSoldierCur + d.curWonder > d.wonderMax then
                self.pSoldierCur = d.wonderMax - d.curWonder
                if self.pSoldierCur<0 then
                    self.pSoldierCur=0
                end
                self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
            end        
        else
            self.Text_trapNum:setVisible(true)
            local d = user.produceSoldierLockData[bid]
            self.Text_trapNum:setString("普通兵：" .. d.curWonder .. "/" .. d.wonderMax)
            if self.pSoldierCur + d.curWonder > d.wonderMax then
                self.pSoldierCur = d.wonderMax - d.curWonder
                if self.pSoldierCur<0 then
                    self.pSoldierCur=0
                end
                self.slider_bar:setPercent(self.pSoldierCur * 100 / self.pSoldierMax)
            end    
        end
    end
    -- 根据当前工作状态显示UI
    self.Node_normal:setVisible(self.data.state == BUILDINGSTATE_NORMAL.key)
    self.Node_training:setVisible(self.data.state ~= BUILDINGSTATE_NORMAL.key)
    if self.data.state == BUILDINGSTATE_NORMAL.key then
        getTrapNumText(self.data.index)
        local d = user.produceSoldierLockData[self.data.index]
        self.pSoldierMax = d.tnum
        if table.nums(d.list) > 0 then
            self.pSoldierTime = d.list[self.selectSoldierData.id].num / 1000
        end
        local need_food = self.selectSoldierData.food * self.pSoldierCur
        if need_food > user.food then
            self.food_num:setTextColor(COLOR_RED)
        else
            self.food_num:setTextColor(COLOR_D4CDB9)
        end
        self.food_num:setString(need_food)
        local need_wood = self.selectSoldierData.wood * self.pSoldierCur
        if need_wood > user.wood then
            self.wood_num:setTextColor(COLOR_RED)
        else
            self.wood_num:setTextColor(COLOR_D4CDB9)
        end
        self.wood_num:setString(self.selectSoldierData.wood * self.pSoldierCur)
        local need_stone = self.selectSoldierData.stone * self.pSoldierCur
        if need_stone > user.stone then
            self.stone_num:setTextColor(COLOR_RED)
        else
            self.stone_num:setTextColor(COLOR_D4CDB9)
        end
        self.stone_num:setString(self.selectSoldierData.stone * self.pSoldierCur)
        local need_gold = self.selectSoldierData.gold * self.pSoldierCur
        if need_gold > user.gold then
            self.gold_num:setTextColor(COLOR_RED)
        else
            self.gold_num:setTextColor(COLOR_D4CDB9)
        end
        self.gold_num:setString(self.selectSoldierData.gold * self.pSoldierCur)
        self.need_time:setString(me.formartSecTime((self.pSoldierTime / 1000) * self.pSoldierCur))
        --        self.num:setString(self.pSoldierCur)
        
        -- 钻石
        local price = { }
        price.food = need_food
        -- self.selectSoldierData.food*self.pSoldierCur
        price.wood = need_wood
        -- self.selectSoldierData.wood*self.pSoldierCur
        price.stone = need_stone
        -- self.selectSoldierData.stone*self.pSoldierCur
        price.gold = need_gold
        -- self.selectSoldierData.gold*self.pSoldierCur
        price.time =(self.pSoldierTime / 1000) * self.pSoldierCur
        price.index = 2
        local pdiamond = math.ceil(getGemCost(price))
        self.diamond:setString(pdiamond)
        self.editBox:setText(self.pSoldierCur)
    else
        local function getGemNum()
            local building = mainCity.buildingMoudles[self.buildTofid]
            local cost = 0
            if building then
                return building:getImmeCost()
            end
        end
        getTrapNumText(self.buildTofid)
        local pdata = user.produceSoldierData[self.buildTofid]
        local produce_time =(pdata.time - pdata.ptime) / 1000 - self.curtime
        local total_time = mainCity.buildingMoudles[self.buildTofid]:getTrainTotalTime()    
        local pNum = pdata.num
        dump(pdata)
        self.Text_soilderName:setString(pdata:getDef().name .. " x" .. pNum)
        if self.timer == nil then
            self.timer = me.registTimer(-1, function(dt)
                pdata = user.produceSoldierData[self.buildTofid]
                if pdata == nil then
                    print("user.produceSoldierData[" .. self.buildTofid .. "]" .. "is  nil !!!!!")
                    self:close()
                    return
                elseif pNum == pdata.num and pdata.num > 0 then
                    produce_time = produce_time - dt
                    total_time = total_time - dt
                    local per = math.floor(100 - produce_time * 100 /(pdata.time / 1000))
                    self.Text_totalTime:setString("剩余总时间：" .. me.formartSecTime(total_time))
                    self.LoadingBar_time:setPercent(per)
                    if pdata:getDef().bigType == 99 then
                        self.Text_singleTime:setString("制造中..." .. self.LoadingBar_time:getPercent() .. "%")
                    else
                        if pdata.stype == 1 then
                            self.Text_singleTime:setString("升级中..." .. self.LoadingBar_time:getPercent() .. "%")
                        else
                            self.Text_singleTime:setString("训练中..." .. self.LoadingBar_time:getPercent() .. "%")
                        end
                    end
                elseif (pNum - pdata.num) == 1 and pdata.num > 0 then
                    pNum = pdata.num
                    print("self.selectSoldierData.name = " .. self.selectSoldierData.name)
                    self.Text_soilderName:setString(self.selectSoldierData.name .. " x" .. pNum)
                    produce_time = dt +(pdata.time - pdata.ptime) / 1000
                    self.LoadingBar_time:setPercent(0)
                end
                self.Text_speedDiamond:setString(getGemNum())
            end , 0)
        end
        
    end
    me.setButtonDisable(self.btn_train, self.pSoldierCur > 0)
    me.setButtonDisable(self.btn_imme, self.pSoldierCur > 0)
end
function trainLayer:close()
    me.clearTimer(self.timer)
    self.timer = nil
    mainCity.train = nil
    self:removeFromParentAndCleanup(true)
    print("trainLayer:close")
end

function trainLayer:onEnter()
    print("trainLayer onEnter")
    me.doLayout(self, me.winSize)
    -- 任务或者新人引导的跳转
    if TaskHelper.getArmyID() then
        me.DelayRun(self:setGuideView(), 0.01)
    end
end
function trainLayer:createEditBox()
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
function trainLayer:setGuideView()
    local soldierID = TaskHelper.getArmyID()
    for key, var in pairs(self.lData) do
        local def = cfg[CfgType.CFG_SOLDIER][me.toNum(var.sid)]
        if me.toNum(def.id) == me.toNum(soldierID) then
            local offIndex = me.toNum(key)
            if offIndex <= 3 then
                self.tableView:setContentOffset(cc.p(0, 0), true)
            elseif offIndex >= #self.lData - 3 then
                self.tableView:setContentOffset(cc.p(1090 - self.cellSize.width *(#self.lData), 0), true)
            else
                self.tableView:setContentOffset(cc.p(- self.cellSize.width *(offIndex - 3), 0), true)
            end
            me.DelayRun( function()
                if mainCity.train == nil then
                    return
                end
                local tcell = self.tableView:cellAtIndex(offIndex - 1)
                local guide = guideView:getInstance()
                guide = guideView:getInstance()
                guide:showGuideView(self.btn_train, false, false, nil, nil, true)
                mainCity:addChild(guide, me.GUIDEZODER)
            end , 0.3 / #self.lData * offIndex)
            break
        end
    end
end

function trainLayer:onExit()
    me.clearTimer(self.timer)
    TaskHelper.setArmyID(nil)
    mainCity.train = nil
    self.timer = nil
    if self.globalItems then self.globalItems:release() end
    print("trainLayer onExit")
end

function trainLayer:getDefaultNum()
    local floor = math.floor
    local insert = table.insert
    local tb = { }

    if self.selectSoldierData.food ~= 0 then
        insert(tb, floor(user.food / self.selectSoldierData.food))
    end
    if self.selectSoldierData.wood ~= 0 then
        insert(tb, floor(user.wood / self.selectSoldierData.wood))
    end
    if self.selectSoldierData.stone ~= 0 then
        insert(tb, floor(user.stone / self.selectSoldierData.stone))
    end
    if self.selectSoldierData.gold ~= 0 then
        insert(tb, floor(user.gold / self.selectSoldierData.gold))
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