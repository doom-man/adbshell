runeSearch = class("runeSearch", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
runeSearch.__index = runeSearch

function runeSearch:create(...)
    local layer = runeSearch.new(...)
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

function runeSearch:ctor()
    print("runeSearch:ctor()")
    self.tableView = nil
    self.listData = {}
    self.selCellId = nil --当前所在什么子界面
    self.turnplateNode = nil --大转盘的子界面
    self.taskGuideIndex = nil --跳转到固定id
end
function runeSearch:init()
    
    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("animation/EnlistBg.plist")
    cache:addSpriteFrames("animation/EnlistFront.plist")

    self.Image_left = me.assignWidget(self, "Image_left")
    self.Panel_right = me.assignWidget(self, "Panel_right")
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)
    self.evetn_guide = me.RegistCustomEvent("run_search_guide",function (evt)
        guideHelper.nextStepByOpt(false,self.closeBtn)
    end)
    return true
end

function runeSearch:revInitList(msg)
    me.tableClear(self.listData)
    self.listData= msg.c.list
    if #self.listData>0 then
        NetMan:send(_MSG.Rune_search_right_data(self.listData[1].id))
    end

    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 265, 91
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "table_cell"):clone()
            cell:addChild(node)
        else
            node =me.assignWidget(cell, "table_cell")
        end
        node:setVisible(true)

        local tmp = self.listData[me.toNum(idx+1)]
        if tmp then
            local ImageView_cell_select = me.assignWidget(node, "ImageView_cell_select")
            local pIcon = me.assignWidget(node,"icon")
            pIcon:loadTexture("relic/rune_search_icon"..tmp.id..".png", me.localType)
            pIcon:ignoreContentAdaptWithSize(true)
            local ImageView_new = me.assignWidget(node, "ImageView_new")
            local nameTxt = me.assignWidget(node,"nameTxt")
            nameTxt:setString(tmp.name)

            if self.selCellId == me.toNum(tmp.id) then
                ImageView_cell_select:loadTexture("huodong_anniu_kuang2.png",me.plistType)
                nameTxt:setTextColor(cc.c3b(255, 254, 171))
            else
                ImageView_cell_select:loadTexture("huodong_anniu_kuang1.png",me.plistType)
                nameTxt:setTextColor(cc.c3b(166, 138, 118))
            end
            ImageView_cell_select:ignoreContentAdaptWithSize(true)
        
        else
            node:setVisible(false)
        end
        return cell
    end

    local function tableCellTouched(table, cell)
        local data = self.listData[cell:getIdx()+1]
        if self.selCellId == data.id then
            return
        end

        NetMan:send(_MSG.Rune_search_right_data(me.toNum(data.id)))
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(272,570))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(6, 4)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        self.Image_left:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function runeSearch:setSelectTableCell(msgId_)
    local function getCellByid(id_)
        for key, var in pairs(self.listData) do
            if me.toNum(var.id) == me.toNum(id_) then
                local cell = self.tableView:cellAtIndex(me.toNum(key)-1)
                return cell
            end
        end
    end

    if self.selCellId ~= nil and self.selCellId ~= msgId_ then
       local lastCell = getCellByid(self.selCellId)
       if lastCell then
           local ImageView= me.assignWidget(lastCell, "ImageView_cell_select")
           ImageView:loadTexture("huodong_anniu_kuang1.png",me.plistType)
           ImageView:ignoreContentAdaptWithSize(true)

           local nameTxt = me.assignWidget(lastCell,"nameTxt")
           nameTxt:setTextColor(cc.c3b(166, 138, 118))
       end
    end

    self.selCellId = msgId_
    local lastCell = getCellByid(self.selCellId)
    if lastCell then
        local ImageView =me.assignWidget(lastCell, "ImageView_cell_select")
        ImageView:loadTexture("huodong_anniu_kuang2.png",me.plistType)
        ImageView:ignoreContentAdaptWithSize(true)
        local nameTxt = me.assignWidget(lastCell,"nameTxt")
        nameTxt:setTextColor(cc.c3b(255, 254, 171))
    end
end

function runeSearch:removePanel_right()
    for key, var in pairs(self.Panel_right:getChildren()) do
        if self.turnplateNode ~= var then
            var:removeFromParentAndCleanup(true)
        else
            self.turnplateNode:setVisible(false)
        end
    end
end

function runeSearch:revInitDetail(msg)
    if msg.c.id == nil then
        print("msg.c.activityId == nil !!!")
        return
    end
    self:setSelectTableCell(msg.c.id)

    if self.rightNode==nil then
        self.Panel_right:removeAllChildren()
        self.rightNode = runeSearchRight:create("rune/runeSearchRight.csb")
        self.Panel_right:addChild(self.rightNode)
    end
    self.recvDetailData = msg.c
    self.rightNode:setData(msg.c, self:getItem(78), self:getItem(79))
end

function runeSearch:showSearchResult(msg)
    local searchRS = runeSearchResult:create("rune/runeSearchResult.csb")
    me.runningScene():addChild(searchRS, me.MAXZORDER)
    me.showLayer(searchRS,"bg")
    searchRS:setData(self.recvDetailData, self:getItem(78), self:getItem(79))
    searchRS:setItemData(msg)
    -- 设置关闭回调，避免同时点击到搜寻结果页面上的搜寻按钮和底层的搜寻按钮
    searchRS:setCloseCallback(function()
        local searchOneBtn, searchTenBtn = self.rightNode:getSearchBtns()
        me.setWidgetCanTouchDelay(searchOneBtn, 0.5)
        me.setWidgetCanTouchDelay(searchTenBtn, 0.5)
    end)
end


function runeSearch:setViewTypeID(typeid)
    self.typeid = typeid
end

function runeSearch:onEnter()
    print("runeSearch:onEnter()")

    --发送活动接口
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)
    end)
    me.DelayRun(function ()
        NetMan:send(_MSG.Rune_search_left_list())
    end)
    self.close_event = me.RegistCustomEvent("runeSearch",function (evt)
        self:close()
    end)
    me.doLayout(self,me.winSize)
end

function runeSearch:getItem(itemId)
    local obj = {id=itemId, name="", count=0}
    obj.name=cfg[CfgType.ETC][itemId].name
    for key, var in pairs(user.pkg) do
       if tonumber(var.defid) == itemId then
           obj.count=obj.count+var.count
       end
    end
    return obj
end

function runeSearch:setTaskGuideIndex(index)
    self.taskGuideIndex = index
end
function runeSearch:update(msg)
    if checkMsg(msg.t, MsgCode.RUNE_SEARCH_LEFT_LIST) then
        self:revInitList(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_SEARCH_RIGHT_INIT) then
        self:revInitDetail(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_SEARCH_REQUEST) then
        disWaitLayer()
        self:showSearchResult(msg)
    end
end
function runeSearch:onExit()
    me.RemoveCustomEvent(self.close_event)
    print("runeSearch:onExit()")
end
function runeSearch:close()
    print("runeSearch:close()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    self:removeFromParentAndCleanup(true)
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity.runeSearch = nil
    else
        pWorldMap.runeSearch = nil
    end
    self.turnplateNode = nil
end

