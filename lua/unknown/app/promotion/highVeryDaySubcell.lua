highVeryDaySubcell = class("highVeryDaySubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
highVeryDaySubcell.__index = highVeryDaySubcell
function highVeryDaySubcell:create(...)
    local layer = highVeryDaySubcell.new(...)
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

function highVeryDaySubcell:ctor()
    print("highVeryDaySubcell:ctor()")
    self.itemCells = {}
end
function highVeryDaySubcell:init()
    self.timer = nil
    print("highVeryDaySubcell:init()")
    self.scoreBoxLayer = me.assignWidget(self,"scoreBoxLayer")
    me.registGuiClickEventByName(self,"boxclose",function (args)
       self.scoreBoxLayer :setVisible(false)
    end)
    me.registGuiClickEventByName(self,"Button_9",function (args)
       self.scoreBoxLayer :setVisible(true)
    end)
    return true
end
function highVeryDaySubcell:onEnter()  
    print("highVeryDaySubcell:onEnter()") 
    local cfg = cfg[CfgType.ACTIVITY_LIST][ACTIVITY_ID_DAILY_HAPPY]
    if cfg and cfg.desc then
        local rt = mRichText:create(cfg.desc,640)
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        rt:setPosition(0,Panel_richText:getContentSize().height)
        rt:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rt)
    end

    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_DAILY_HAPPY then
                self:setViewData()
            end
        end      
    end ) 

    self:setViewData()
    me.doLayout(self,me.winSize)  
end

function highVeryDaySubcell:setViewData()
    if user.activityDetail.open == 1 then
        self:initOpenViewData()
    else
        self:initCloseViewData()
    end
end

function highVeryDaySubcell:onExit()
    print("highVeryDaySubcell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    me.clearTimer(self.timer)
end

function highVeryDaySubcell:initCloseViewData()
    self.rewardData = user.activityDetail.integralItems
    self.countdown = user.activityDetail.countdown
    me.assignWidget(self,"Image_open"):setVisible(false)
    me.assignWidget(self,"Image_close"):setVisible(true)

    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end
    
    local Image_close = me.assignWidget(self,"Image_close")
    local Panel_item = me.assignWidget(Image_close,"Panel_item_0")
    Panel_item:removeAllChildren()

    me.assignWidget(self,"activityTime_close"):setString(me.formartSecTime(self.countdown).."后开启")
    self.timer = me.registTimer(-1,function ()
        self.countdown = self.countdown - 1
        if self.countdown <= 0 then
            self.countdown = 0
        end
        me.assignWidget(self,"activityTime_close"):setString(me.formartSecTime(self.countdown).."后开启")
    end,1)

    for key, var in pairs(self.rewardData) do
        if #var.Items >= 5 then
            for index = 0, #var.Items do
                if index >= 4 then
                    break
                end
                local tIndex = #var.Items-index
                local sItem = var.Items[tIndex]
                local itemDef = cfg[CfgType.ETC][sItem.defId]
                local tmpButtonItem = me.assignWidget(self,"Button_item"):clone()
                tmpButtonItem:setVisible(true)
                Panel_item:addChild(tmpButtonItem)
                tmpButtonItem:setPosition(cc.p(me.toNum(index)*125, Panel_item:getContentSize().height/2))
                me.assignWidget(tmpButtonItem,"Image_quality"):loadTexture(getQuality(itemDef.quality),me.localType)
                me.assignWidget(tmpButtonItem,"Goods_Icon"):loadTexture("item_"..itemDef.icon..".png",me.localType)
                me.assignWidget(tmpButtonItem,"label_num"):setString(sItem.defNum)
                me.registGuiClickEvent(tmpButtonItem,function (node)
                    showPromotion(sItem.defId,sItem.defNum)
                end) 
            end
        end
    end
end

function highVeryDaySubcell:initOpenViewData()
    self.progressData = user.activityDetail.list
    self.rewardData = user.activityDetail.integralItems
    self.score = user.activityDetail.score
    self.countdown = user.activityDetail.countdown
    me.assignWidget(self,"Image_open"):setVisible(true)
    me.assignWidget(self,"Image_close"):setVisible(false)

    me.assignWidget(self,"Text_Score"):setString("我的总积分："..self.score)
    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end

    me.assignWidget(self,"activityTime_open"):setString(me.formartSecTime(self.countdown).."后结束")
    self.timer = me.registTimer(-1,function ()
        self.countdown = self.countdown - 1
        if self.countdown <= 0 then
            self.countdown = 0
        end
        me.assignWidget(self,"activityTime_open"):setString(me.formartSecTime(self.countdown).."后结束")
    end,1)
    self:initProgressTable()
    self:initRewardTable()
    self.scoreBoxLayer:setVisible(false)
end

function highVeryDaySubcell:initProgressTable()
    local function numberOfCellsInTableView(table)
        return #self.progressData
    end

    local function cellSizeForTable(table, idx)
        return 870,80
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil

        if nil == cell then
            cell = cc.TableViewCell:new()
            node = cc.CSLoader:createNode("highVeryDayProgressItem.csb")
            cell:addChild(node)
            node:setTag(5555)
        else
            node = cell:getChildByTag(5555)
        end
        local tmp = self.progressData[me.toNum(idx+1)]
        if tmp then
            local itemPanel = me.assignWidget(node,"Panel_progressItem")
            local def = cfg[CfgType.DAILY_HAPPY_ACTIVITY][tmp.smallId]
            if def == nil then
                __G__TRACKBACK__("tmp.smallId = "..tmp.smallId.." not exist!")
                return
            end
            me.assignWidget(node,"Text_name"):setString(def.stage)
            me.assignWidget(node,"Text_desc"):setString(def.desc)
            local maxNum = nil
            local preNum = 0 
            local percent = 25 --4分段的百分比
            local items = me.split(def.perAward,";")
            for key, var in pairs(items) do
                local s = me.split(var,"|")
                local addScore = me.assignWidget(node,"Text_"..me.toNum(key))
                addScore:setString("("..s[1]..")")
                if tmp.num <= me.toNum(s[1]) and maxNum == nil then
                    maxNum = me.toNum(s[1])
                    if items[me.toNum(key-1)] then
                        local preVar = items[me.toNum(key-1)]
                        local preS = me.split(preVar,"|")
                        preNum = preS[1]
                    end
                    percent = percent * me.toNum(key-1) + percent * (tmp.num-preNum)/(maxNum-preNum)
                end
                
                if tmp.num >= me.toNum(s[1]) then
                    me.assignWidget(addScore,"Text_target"):setTextColor(COLOR_GREEN)
                else
                    me.assignWidget(addScore,"Text_target"):setTextColor(me.convert3Color_("0x977653"))
                end
                me.assignWidget(addScore,"Text_target"):setString("+"..s[2])
            end

            if maxNum == nil then
                me.assignWidget(node,"LoadingBar_progress"):setPercent(100)
            else
                me.assignWidget(node,"LoadingBar_progress"):setPercent(percent)
            end
        end
        return cell
    end

    if self.tableView_Progress == nil then
        local Panel_Progress = me.assignWidget(self, "Panel_Progress")
        self.tableView_Progress = cc.TableView:create(cc.size(870,366))
        self.tableView_Progress:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_Progress:setDelegate()
        self.tableView_Progress:setPosition(cc.p(0,0))
        Panel_Progress:addChild(self.tableView_Progress)
        self.tableView_Progress:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_Progress:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_Progress:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_Progress:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView_Progress:reloadData()
end

function highVeryDaySubcell:initRewardTable()
    table.sort(self.rewardData,function(a,b)
        return a.integeral < b.integeral    
    end)

    local function numberOfCellsInTableView(table)
        return #self.rewardData
    end

    local function cellSizeForTable(table, idx)
        return 700,75
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil

        if nil == cell then
            cell = cc.TableViewCell:new()
            node = cc.CSLoader:createNode("highVeryDayRewardItem.csb")

            cell:addChild(node)
            node:setTag(5555)
            if idx%2 == 0 then
                me.assignWidget(node,"Panel_reward"):loadTexture("default.png")
            else
                me.assignWidget(node,"Panel_reward"):loadTexture("alliance_cell_bg.png")
            end
        else
            node = cell:getChildByTag(5555)
        end
        local tmp = self.rewardData[me.toNum(idx+1)]
        if tmp then
            local Panel_items = me.assignWidget(node,"Panel_items")
            Panel_items:removeAllChildren()
            me.assignWidget(node,"Text_current_score"):setString(tmp.integeral.."积分")
            for key, var in pairs(tmp.Items) do
                local itemDef = cfg[CfgType.ETC][var.defId]
                local tmpButtonItem = me.assignWidget(node,"Button_item"):clone()
                tmpButtonItem:setSwallowTouches(false)
                tmpButtonItem:setVisible(true)
                Panel_items:addChild(tmpButtonItem)
                tmpButtonItem:setPosition(cc.p(me.toNum(key*80), Panel_items:getContentSize().height/2))
                me.assignWidget(tmpButtonItem,"Image_quality"):loadTexture(getQuality(itemDef.quality),me.localType)
                me.assignWidget(tmpButtonItem,"Goods_Icon"):loadTexture("item_"..itemDef.icon..".png",me.localType)
                me.assignWidget(tmpButtonItem,"label_num"):setString(var.defNum)
                me.registGuiClickEvent(tmpButtonItem,function (node)
                    showPromotion(var.defId,var.defNum)
                end) 
            end
        end
        return cell
    end
    if self.tableView_Reward == nil then
        local Panel_item = me.assignWidget(self, "Panel_items")
        self.tableView_Reward = cc.TableView:create(cc.size(700,384))
        self.tableView_Reward:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_Reward:setDelegate()
        self.tableView_Reward:setPosition(cc.p(0,0))
        Panel_item:addChild(self.tableView_Reward)
        self.tableView_Reward:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_Reward:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_Reward:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_Reward:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView_Reward:reloadData()
end