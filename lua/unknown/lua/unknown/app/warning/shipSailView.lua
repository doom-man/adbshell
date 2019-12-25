shipSailView = class("shipSailView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)

function shipSailView:create(...)
    local layer = shipSailView.new(...)
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

function shipSailView:ctor()
    self.shipSailData = table.values (user.shipSailData.taskData)
end

function shipSailView:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function shipSailView:onExit()
    if self.netListener then
        UserModel:removeLisener(self.netListener)
    end
end

function shipSailView:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION_INIT) then
        -- 刷新远征任务
        if user.shipSailData.taskFs <= 0 then
            self.textRefreshDiamond:setString ("免费")
        else
            self.textRefreshDiamond:setString ("100")
        end

        self.shipSailData = table.values (user.shipSailData.taskData)
        local offset = self.sailTableView:getContentOffset()
        self.sailTableView:reloadData()
        self.sailTableView:setContentOffset(offset)
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION_UPDATE) then
        -- 召回
        if user.shipSailData.taskData[msg.c.id].taskStatus == 0 and
            user.shipSailData.taskData[msg.c.id].taskStatusOld == 1 then
            showTips ("召回战舰成功")
        end
        -- 加速
        if user.shipSailData.taskData[msg.c.id].taskStatus == 2 and
            user.shipSailData.taskData[msg.c.id].taskStatusOld == 1 then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_TASK)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 100))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
        end
        self.shipSailData = table.values (user.shipSailData.taskData)
        local offset = self.sailTableView:getContentOffset()
        self.sailTableView:reloadData()
        self.sailTableView:setContentOffset(offset)
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_EXPEDITION) then
        self:updateSailTimes ()
    end
    disWaitLayer ()
end

function shipSailView:init()
    print("shipSailView init")
    me.doLayout(self, me.winSize)

    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )

    me.registGuiClickEventByName(self, "btn_help", function(sender)
        local str = "航海说明\n派遣空闲中的战舰去完成航海任务，任务会消耗一定的弹药和时间，完成后就可以领取大量奖励，还有一定概率获得额外奖励！\n\n任务难度\n航海任务星级越高，航海任务难度越大，航海时间越长，获得的奖励也会更多，任务最高为5星，升级战舰可以解锁更高星级的航海任务\n\n任务品质\n相同难度航海任务从低到高按白、绿、蓝分为3个品质，品质越高的任务奖励越丰厚！"
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithStr(str, wd)
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end )

    me.registGuiClickEventByName(self, "btn_refresh", function(node)
        -- 刷新任务
        NetMan:send(_MSG.ship_expedition_refresh())
        showWaitLayer ()
    end )

    self.textSailTimes = me.assignWidget(self, "text_sail_count")
    self.textPierLv = me.assignWidget(self, "text_level_pier")
    self.textPier = me.assignWidget(self, "text_pier")
    self.textPierTask = me.assignWidget(self, "text_pier_task")
    self.textRefreshDiamond = me.assignWidget(self, "text_diamond")

    if user.shipSailData.taskFs <= 0 then
        self.textRefreshDiamond:setString ("免费")
    else
        self.textRefreshDiamond:setString ("100")
    end

    local lv = 1
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if def.type == cfg.BUILDING_TYPE_BOAT then
            lv = def.level
        end
    end
    local nextLv = math.floor(lv / 5 + 1) * 5
--    if nextLv >= 30 then
--        nextLv = 30
--        self.textPierLv:setVisible (false)
--        self.textPier:setVisible (false)
--        self.textPierTask:setVisible (false)
--    else
--        self.textPier:setVisible (true)
--        self.textPierTask:setVisible (true)
--        self.textPierLv:setVisible (true)
--    end
--    self.textPierLv:setString (tostring (nextLv))

    local nodeSailTb = me.assignWidget(self,"node_sail_table")

    local tableViewSize = cc.size (1140, 136)

    local function scrollViewDidScroll(view)
    end

    local function scrollViewDidZoom(view)
    end

    local function tableCellTouched(taskTable, cell)
    end

    local function cellSizeForTable(taskTable, idx)
        return tableViewSize.width, tableViewSize.height
    end

    local function numberOfCellsInTableView(taskTable)
        return #self.shipSailData
    end

    local function tableCellAtIndex(taskTable, idx)
        local sailDataIdx = idx + 1
        local cell = taskTable:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            local shipSailCell = shipSailCell:create("warning/shipSailCell.csb")
            shipSailCell:setPosition (cc.p (tableViewSize.width / 2, tableViewSize.height / 2))
            cell:addChild (shipSailCell)
            cell.shipSailCell = shipSailCell

            cell.shipSailCell:setSailTaskData (self.shipSailData[sailDataIdx])
            cell.shipSailCell:updateView ()
        else
            cell.shipSailCell:setSailTaskData (self.shipSailData[sailDataIdx])
            cell.shipSailCell:updateView ()
        end
        return cell
    end
    self.sailTableView = cc.TableView:create(cc.size(1140,430))
    self.sailTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.sailTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.sailTableView:setDelegate()
    self.sailTableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.sailTableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.sailTableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.sailTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.sailTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.sailTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.sailTableView:reloadData()
    nodeSailTb:addChild(self.sailTableView)

    self:updateSailTimes ()

    return true
end

function shipSailView:updateSailTimes()
    local strSailTimes = (user.shipSailData.taskMax-user.shipSailData.taskTm) .. "/" .. user.shipSailData.taskMax
    self.textSailTimes:setString (strSailTimes)
end
