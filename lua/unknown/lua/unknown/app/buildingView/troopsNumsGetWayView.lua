troopsNumsGetWayView = class("troopsNumsGetWayView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
function troopsNumsGetWayView:create(...)
    local layer = troopsNumsGetWayView.new(...)
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

function troopsNumsGetWayView:ctor()
end

function troopsNumsGetWayView:onEnter()
    self.listener = UserModel:registerLisener( function(msg)
        
    end )
end

function troopsNumsGetWayView:onExit()
    UserModel:removeLisener(self.listener)
end

function troopsNumsGetWayView:init()

    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        if self.callback then
            self.callback()
        end
        self:removeFromParentAndCleanup(true)

    end )

    self:initTable()
    return true
end

function troopsNumsGetWayView:initTable()
    self.tableView = nil
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end
    local function cellSizeForTable(table, idx)
        return 600, 96
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = self.listData[idx + 1]
        if nil == cell then
            cell = cc.TableViewCell:new()

            local leftCell = me.assignWidget(self, "cell_bg"):clone():setVisible(true)
            me.assignWidget(leftCell, "btn_puton"):setTag(idx + 1)
            cell:addChild(leftCell)
            me.registGuiClickEvent(me.assignWidget(leftCell, "btn_puton"), handler(self, self.onClickTarget))
            me.assignWidget(leftCell, "btn_puton"):setSwallowTouches(false)

            self:fillData(leftCell, data)
        else
            local leftCell = cell:getChildByTag(idx + 1)
            if leftCell == nil then
                leftCell = me.assignWidget(self, "cell_bg"):clone():setVisible(true)
                cell:addChild(leftCell)
                me.registGuiClickEvent(me.assignWidget(leftCell, "btn_puton"), handler(self, self.onClickTarget))
                me.assignWidget(leftCell, "btn_puton"):setSwallowTouches(false)
            end
            me.assignWidget(leftCell, "btn_puton"):setTag(idx + 1)
            self:fillData(leftCell, data)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.listData
    end

    local tableView = cc.TableView:create(cc.size(611, 338))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView = tableView

end

function troopsNumsGetWayView:fillData(leftCell, data)
    me.assignWidget(leftCell, "Text_get"):setString(data.desc)
end

function troopsNumsGetWayView:onClickTarget(node)
    local data = self.listData[node:getTag()]
    if data.class == "tiejiang" then
        self:openTiejiang()
    elseif data.class == "vip" then
        self:openVip()
    elseif data.class == "cityskin" then
        self:cityskinwin()
    end
end

-- -
-- 打开研究铁匠铺科技      
function troopsNumsGetWayView:openTiejiang()
    if CUR_GAME_STATE == GAME_STATE_CITY then
        local buildData = mainCity.buildingMoudles[3004]
        if buildData then
            local tv = techView:getInstance()
            tv:initData(buildData:getDef().id, 3004)
            me.runningScene():addChild(tv, me.MAXZORDER)
            me.showLayer(tv, "bg")
        else
            showTips("铁匠铺还没有建造")
        end
    elseif pWorldMap then
        me.dispatchCustomEvent("WORLDMAP_JUMP_TECHVIEW")
        local guide = guideView:getInstance()
        if guide.anim ~= nil then
            guide:close()
            guide = guideView:getInstance()
        end
        guide:showGuideView(pWorldMap.homeBtn, false, false)
        pWorldMap:addChild(guide, me.GUIDEZODER)
        self:close()
   end
end

-- -
-- 打开VIP界面
function troopsNumsGetWayView:openVip()
    local vipview = vipView:create("vipView.csb")
    me.runningScene():addChild(vipview, me.MAXZORDER)
    me.showLayer(vipview, "bg")
end

-- -
-- 城池皮肤商店
function troopsNumsGetWayView:cityskinwin()
    local data = user.building[4001]
    if data.def.level>=5 then
        NetMan:send(_MSG.initShop(SKINSHOP))
        local shop = citySkinShop:create("citySkinShop.csb")
        me.popLayer(shop)
    else
        showTips("主城5级开启")
    end
end

function troopsNumsGetWayView:setData()
    self.listData = { 
        {id=1, desc="研究铁匠铺科技", class="tiejiang"},
        {id=2, desc="提升VIP等级", class="vip"},
        {id=3, desc="获得城池皮肤", class="cityskin"},
    }

    self.tableView:reloadData()

end

function troopsNumsGetWayView:setCloseCallback(callback)
    self.callback = callback
end

function troopsNumsGetWayView:close()
    self:removeFromParentAndCleanup(true)  
end