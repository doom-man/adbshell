
-- [Comment]
-- jnmo
netBattleCell = class("netBattleCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
netBattleCell.__index = netBattleCell
function netBattleCell:create(...)
    local layer = netBattleCell.new(...)
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
function netBattleCell:ctor()
    print("netBattleCell ctor")
end
function netBattleCell:init()
    print("netBattleCell init")
    self.Text_time = me.assignWidget(self, "Text_time")
    self.Button_sign = me.registGuiClickEventByName(self,"Button_sign",function (node)
            if user.centerBuild:getDef().level >= 15 then
                NetMan:send(_MSG.updateActivityDetail(self.activity_id))
                me.setButtonDisable(self.Button_sign,false)
                self.Button_sign:setTitleText("已报名")
                showTips("报名成功")
            else
                showTips("城镇中心不足15级")    
            end
    end)
    self.Node_middle = me.assignWidget(self,"Node_middle")
    
    return true
end
function netBattleCell:initActivity(id)
    self.activity_id = id
    local data = user.activityDetail

    local Panel_richText = me.assignWidget(self, "Panel_richText")
    local rich = mRichText:create(data.desc, Panel_richText:getContentSize().width)
    rich:setPosition(0, Panel_richText:getContentSize().height)
    rich:setAnchorPoint(cc.p(0, 1))
    Panel_richText:addChild(rich)
    me.setButtonDisable(self.Button_sign, not data.reged)
    if data.reged then
        self.Button_sign:setTitleText("已报名")
    end
    self.Text_time:setString(me.GetSecTime(data.openDate) .. "-" .. me.GetSecTime(data.endDate))
    if data.list  and #data.list > 0  then
          self:setTableView(data.list)
    end
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_NETBATTLE  then
                self:setTableView(msg.c.list)
            end
        end
    end )
end
function netBattleCell:setTableView(data)
    self.listData = data
    self.mNum = #self.listData

    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 886, 60
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "netbattle_cell"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "netbattle_cell")
            node:setVisible(true)
        end
        local tmp = self.listData[me.toNum(idx + 1)]
        if tmp then
            local bg_cell = me.assignWidget(node, "cell_rank_bg")
            local R_cell_rank_icon = me.assignWidget(node, "R_cell_rank_icon")
            local R_cell_rank = me.assignWidget(node, "R_cell_rank")
            local R_cell_name = me.assignWidget(node, "R_cell_server")
         
            R_cell_rank_icon:setVisible(true)
            R_cell_rank:setVisible(false)
            if idx + 1 == 1 then
                R_cell_rank_icon:loadTexture("paihang_diyiming.png", me.localType)
            elseif idx + 1 == 2 then
                R_cell_rank_icon:loadTexture("paihang_dierming.png", me.localType)
            elseif idx + 1 == 3 then
                R_cell_rank_icon:loadTexture("paihang_disanming.png", me.localType)
            else
                R_cell_rank:setString(me.toStr(idx + 1))
                R_cell_rank_icon:setVisible(false)
                R_cell_rank:setVisible(true)
            end
            R_cell_name:setString(tmp.name)     
            if idx % 2 == 0 then
                bg_cell:setVisible(false)
            else
                bg_cell:setVisible(true)
            end
        end
--        if tonumber(tmp.item[1]) == tonumber(user.uid) then
--            self.rank_num = idx + 1
--        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self.Node_middle, "Image_table")
        self.tableView = cc.TableView:create(cc.size(886, 250))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(5, 5))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end
function netBattleCell:onEnter()
    print("netBattleCell onEnter")
    me.doLayout(self, me.winSize)
end
function netBattleCell:onEnterTransitionDidFinish()
    print("netBattleCell onEnterTransitionDidFinish")
end
function netBattleCell:onExit()
    print("netBattleCell onExit")
    UserModel:removeLisener(self.modelkey)
end
function netBattleCell:close()
    self:removeFromParent()
end
