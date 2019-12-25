-- [Comment]
-- jnmo
serverListLayer = class("serverListLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
serverListLayer.__index = serverListLayer
function serverListLayer:create(...)
    local layer = serverListLayer.new(...)
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
function serverListLayer:ctor()
    print("serverListLayer ctor")
    self.pPitchId = 1
end
function serverListLayer:init()
    print("serverListLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self:initLeftList()
    return true
end
function serverListLayer:onEnter()
    print("serverListLayer onEnter")
    me.doLayout(self, me.winSize)
end

function serverListLayer:sendConnect(sid)
    me.dispatchCustomEvent("choose_server", sid)
    self:close()
end
-- 构建服务器列表
function serverListLayer:setServerList(index)
    -- 最近登录
    if index == 1 then
        self.serverList = { }
        if isWindowsPlatform() or isIosPlatform() then
           user.sdkid =   SharedDataStorageHelper():getUserAccountNEW()
        end
        if me.isValidStr(user.sdkid) then
            local msg = SharedDataStorageHelper():loadLastServerList(user.sdkid)
            if me.isValidStr(msg) then
                local lastserver = me.cjson.decode(msg)
                local tmp = { }
                for key, var in pairs(lastserver) do
                    table.insert(tmp, var)
                end
                table.sort(tmp, function(a, b)
                    return a.time > b.time
                end )
                for key, var in pairs(tmp) do
                    for k, v in pairs(user.servsers) do
                        if tonumber(var.sid) == tonumber(v.sid) then
                            table.insert(self.serverList, v)
                            break
                        end
                    end
                end
            end
        else
            self.pPitchId = 2
            self:initLeftList()
        end
    else
        local num = #user.servsers
        local row = math.floor(num / 10)
        if #user.servsers % 10 ~= 0 then
            row = math.ceil(num / 10)
        end
        self.serverList = { }
        for var = math.min((row -(index - 2)) * 10, #user.servsers),(row -(index - 1)) * 10 + 1, -1 do
            table.insert(self.serverList, user.servsers[var])
        end
    end

    local function numberOfCellsInTableView(table)
        local num = math.floor(#self.serverList / 2)
        if #self.serverList % 2 ~= 0 then
            num = math.ceil(#self.serverList / 2)
        end
        return num
    end

    local function cellSizeForTable(table, idx)
        return 883, 103
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local leftIndex = idx * 2 + 1
        local rightIndex = idx * 2 + 2
        local leftData = self.serverList[leftIndex]
        local rightData = self.serverList[rightIndex]
        if nil == cell then
            cell = cc.TableViewCell:new()
            if leftData then
                local leftCell = servserCell:create("serverCell.csb")
                leftCell:setPosition(16, 0)
                leftCell:initWithData(leftData, function(index_)
                    self:sendConnect(index_)
                end )
                leftCell:setTag(111)
                cell:addChild(leftCell)
            end

            if rightData then
                local rightCell = servserCell:create("serverCell.csb")
                rightCell:setPosition(450, 0)
                rightCell:initWithData(rightData, function(index_)
                    self:sendConnect(index_)
                end )
                rightCell:setTag(222)
                cell:addChild(rightCell)
            end
        else
            local leftCell = cell:getChildByTag(111)
            local rightCell = cell:getChildByTag(222)
            if leftCell and leftData then
                leftCell:setVisible(true)
                leftCell:initWithData(leftData, function(index_)
                    self:sendConnect(index_)
                end )
            elseif leftCell then
                leftCell:setVisible(false)
            end
            if rightCell and rightData then
                rightCell:setVisible(true)
                rightCell:initWithData(rightData, function(index_)
                    self:sendConnect(index_)
                end )
            elseif rightCell then
                rightCell:setVisible(false)
            end
        end
        return cell
    end
    if self.tableView then
        self.tableView:removeFromParent()
        self.tableView = nil
    end
    self.tableView = cc.TableView:create(cc.size(883, 578))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(0, 0)
    self.tableView:setAnchorPoint(cc.p(0, 0))
    self.tableView:setDelegate()
    me.assignWidget(self, "Panel_right"):addChild(self.tableView)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()
end
function serverListLayer:initLeftList()

    local function numberOfCellsInTableView(table)
        local num = math.floor(#user.servsers / 10)
        if #user.servsers % 10 ~= 0 then
            num = math.ceil(#user.servsers / 10)
        end
        num = num + 1
        return num
    end
    local function tableCellTouched(table, cell)

        if self.pPitchId ~=(cell:getIdx() + 1) then
            self.pPitchId = cell:getIdx() + 1
            local pOffest = self.tableView_left:getContentOffset()
            self.tableView_left:reloadData()
            self.tableView_left:setContentOffset(pOffest)
            if self.pPitchId == 1 and not me.isValidStr(user.sdkid) then
                showTips("暂无最近登录服务器数据")
            end
            self:setServerList(self.pPitchId)
        end
    end
    local function cellSizeForTable(table, idx)
        return 263, 78
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            local leftCell = serverGroupCell:create(self, "serItem")
            leftCell:setPosition(0, 0)
            leftCell:initData(idx + 1, self.pPitchId == idx + 1)
            cell:addChild(leftCell)
        else
            local leftCell = me.assignWidget(cell, "serItem")
            leftCell:setPosition(0, 0)
            leftCell:initData(idx + 1, self.pPitchId == idx + 1)
        end
        return cell
    end
    if self.tableView_left == nil then
        self.tableView_left = cc.TableView:create(cc.size(278, 580))
        self.tableView_left:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_left:setPosition(2, 0)
        self.tableView_left:setAnchorPoint(cc.p(0, 0))
        self.tableView_left:setDelegate()
        me.assignWidget(self, "Panel_left"):addChild(self.tableView_left)
        self.tableView_left:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_left:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_left:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_left:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView_left:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_left:reloadData()
    self:setServerList(self.pPitchId)
end
function serverListLayer:onEnterTransitionDidFinish()
    print("serverListLayer onEnterTransitionDidFinish")
end
function serverListLayer:onExit()
    print("serverListLayer onExit")
end
function serverListLayer:close()
    self:removeFromParent()
end
