-- [Comment]
-- jnmo
kingdom_Cross_rank = class("kingdom_Cross_rank", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
kingdom_Cross_rank.__index = kingdom_Cross_rank
function kingdom_Cross_rank:create(...)
    local layer = kingdom_Cross_rank.new(...)
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
function kingdom_Cross_rank:ctor()
    print("kingdom_Cross_rank ctor")
end
STATE_CUR = 1
STATE_PRE = 2

function kingdom_Cross_rank:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c4b(189,166,123, 255))
    else
        title:setTextColor(cc.c4b(233,220,175, 255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function kingdom_Cross_rank:init()
    print("kingdom_Cross_rank init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.Button_cur = me.registGuiClickEventByName(self, "Button_cur", function(node)
        self:setButton(self.Button_cur, false)
        self:setButton(self.Button_pre, true)
        NetMan:send(_MSG.Cross_Fight_Record())
    end )
    self.Button_pre = me.registGuiClickEventByName(self, "Button_pre", function(node)
        self:setButton(self.Button_cur, true)
        self:setButton(self.Button_pre, false)
        NetMan:send(_MSG.cross_rank())
    end )
    self.state = 0
    self:setButton(self.Button_cur, false)
    self:setButton(self.Button_pre, true)
    return true
end
function kingdom_Cross_rank:swichView(state)
    if self.state ~= state then
        self.state = state
    end
    me.setButtonDisable(self.Button_cur, self.state ~= STATE_CUR)
    me.setButtonDisable(self.Button_pre, self.state ~= STATE_PRE)
end
function kingdom_Cross_rank:setNowTable(pTable)
    me.assignWidget(self, "Panel_Table"):removeAllChildren()
    local iNum = #pTable

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 1152, 260
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local Panel_Now_cell = me.assignWidget(self, "In_bg"):clone():setVisible(true)
            self:Cross_NowCell(Panel_Now_cell, pTable[idx + 1])
            Panel_Now_cell:setPosition(0, 0)
            cell:addChild(Panel_Now_cell)
        else
            local Panel_Now_cell = me.assignWidget(cell, "In_bg")
            self:Cross_NowCell(Panel_Now_cell, pTable[idx + 1])
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    self.tableView = cc.TableView:create(cc.size(1152, 505))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 1)
    self.tableView:setDelegate()
    me.assignWidget(self, "Panel_Table"):addChild(self.tableView)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)

    self.tableView:reloadData()
end
function kingdom_Cross_rank:Cross_NowCell(node, data)
    if data then
        dump(data)
        local pData = me.split(data.data, ",")
        for var = 1, 4 do
            me.assignWidget(node, "Image_Cell" .. var):setVisible(false)
        end
        local pTime = me.assignWidget(node, "cell_title_now")
        -- pTime:setString("战争时间 " .. me.GetSecTime(data.begin) .. "—" .. me.GetSecTime(data.timeend))
        pTime:setString(data.name)
        for key, var in pairs(pData) do
            local pList = me.split(var, ":")
            local Image_Cell = me.assignWidget(node, "Image_Cell" .. key)
            Image_Cell:setVisible(true)
            local server = me.assignWidget(Image_Cell, "server")
            local score = me.assignWidget(Image_Cell, "score")
            local id = me.assignWidget(Image_Cell, "id")
            id:setString(pList[1])
            score:setString(pList[3])
            if pList[4] then
                server:setString(pList[2] .. "(被" .. pList[4] .. "沦陷)")
            else
                server:setString(pList[2])
            end
        end
    end
end
function kingdom_Cross_rank:update(msg)
    if checkMsg(msg.t, MsgCode.CROSS_SEVER_FIGHT_RECORD) then
        self:setNowTable(user.CrossSeverRank)
    elseif checkMsg(msg.t, MsgCode.CROSS_RANK) then
        self:setNowTable(user.CrossSeverRank)
    end
end
function kingdom_Cross_rank:onEnter()
    print("kingdom_Cross_rank onEnter")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)
end
function kingdom_Cross_rank:onEnterTransitionDidFinish()
    print("kingdom_Cross_rank onEnterTransitionDidFinish")
end
function kingdom_Cross_rank:onExit()
    print("kingdom_Cross_rank onExit")
    UserModel:removeLisener(self.modelkey)
end
function kingdom_Cross_rank:close()
    self:removeFromParentAndCleanup(true)
end
