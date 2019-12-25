armyCellView = class("armyCellView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
armyCellView.__index = armyCellView
function armyCellView:create(...)
    local layer = armyCellView.new(...)
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

function armyCellView:ctor()
    self.cellData = nil
    self.tableView = nil
    print("armyCellView ctor")
end

function armyCellView:init()
    self.Text_soldier = me.assignWidget(self, "Text_soldier")
    self.Text_soldier_num = me.assignWidget(self, "Text_soldier_num")
    self.Panel_table = me.assignWidget(self, "Panel_table")
    return true
end

function armyCellView:initWithData(data_, bguard)
    self.bguard=bguard
    if self.cellData == nil then
        self.cellData = { }
        local totalNum = 0
        local typeName = nil
        for key, var in pairs(data_) do
            if typeName == nil then
                local def = var:getDef()
                typeName = soldierBigType[me.toStr(def.bigType)]
            end
            totalNum = totalNum + var.num
            table.insert(self.cellData, #self.cellData + 1, var)
        end
        if bguard then
            self.Text_soldier:setString("禁卫军")
        else
            self.Text_soldier:setString(typeName)
        end
        self.Text_soldier_num:setString(totalNum)

    end
    table.sort(self.cellData, function(a, b)
        return a:getDef().id > b:getDef().id
    end )
end
function armyCellView:initCell()
    local iNum = table.nums(self.cellData)
    local function cellSizeForTable(table, idx)
        return 240, 287
    end
    self.globalItems = me.createNode("Node_soldierItem.csb")
    self.globalItems:retain()
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = self.cellData[idx + 1]
        local def = data:getDef()
        local item = nil
        local function info_call(node)
                local info = soldierInfoLayer:create("soldlierInfoLayer.csb")
                info:initWithData(node.data:getDef(),node.data)
                -- mainCity:addChild(info,me.MAXZORDER)
                me.popLayer(info)
                me.showLayer(info,"bg")
        end
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = me.assignWidget(self.globalItems, "soldierItem"):clone()
            item:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
            me.assignWidget(item, "Text_name"):setString(def.name)
            me.assignWidget(item, "Text_num"):setString(data.num)
            me.assignWidget(item, "Text_type"):setString(soldierType[me.toStr(def.smallType)])
            me.assignWidget(item, "item_icon"):loadTexture(soldierIcon(def), me.plistType)
            local infoBtn  = me.registGuiClickEventByName(item,"Image_Tips",info_call)
            infoBtn.data = data
            cell:addChild(item)
        else
            item = me.assignWidget(cell, "soldierItem")
            me.assignWidget(item, "Text_name"):setString(def.name)
            me.assignWidget(item, "Text_num"):setString(data.num)
            me.assignWidget(item, "Text_type"):setString(soldierType[me.toStr(def.smallType)])
            me.assignWidget(item, "item_icon"):loadTexture(soldierIcon(def), me.plistType)
            local infoBtn  = me.registGuiClickEventByName(item,"Image_Tips",info_call)
            infoBtn.data = data
        end
        local qiansanBtn = me.registGuiClickEventByName(item, "qiansanBtn", function(node)
            local BackpackUse = armyDissolveLayer:create("backpack/armyDissolve.csb")
            me.runningScene():addChild(BackpackUse, me.MAXZORDER);
            BackpackUse:setData(node.data)
            me.showLayer(BackpackUse, "bg")
        end )
        qiansanBtn.data = data
        qiansanBtn:setVisible(user.centerBuild:getDef().level >= 7)
        if self.bguard==true then
            qiansanBtn:setVisible(false)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    if self.tableView == nil then
        local width = self.Panel_table:getContentSize().width
        local height = self.Panel_table:getContentSize().height
        self.tableView = cc.TableView:create(cc.size(width, height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self.tableView:setPosition(0, 0)
        self.tableView:setDelegate()
        self.Panel_table:addChild(self.tableView)
        self.Panel_table:setSwallowTouches(false)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self.tableView:reloadData()
    end
end

function armyCellView:onEnter()
    print("armyCellView:onEnter()")
    self:initCell()
end

function armyCellView:onEnterTransitionDidFinish()
end

function armyCellView:onExit()
    print("armyCellView:onExit()")
    if self.globalItems then self.globalItems:release() end
end

