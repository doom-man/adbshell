armyCellOut = class("armyCellOut", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
armyCellOut.__index = armyCellOut
function armyCellOut:create(...)
    local layer = armyCellOut.new(...)
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

function armyCellOut:ctor()
    self.cellData = nil
    self.tableView = nil
    print("armyCellOut ctor")
end

function armyCellOut:init()
    self.Text_soldier = me.assignWidget(self, "Text_soldier")
    self.Text_soldier_num = me.assignWidget(self, "Text_soldier_num")
    self.Panel_table = me.assignWidget(self, "Panel_table")
    self.Text_soldier_disable = me.assignWidget(self,"Text_soldier_disable")
    self.Text_soldier_tag = me.assignWidget(self,"Text_soldier_tag")
    return true
end

function armyCellOut:initWithData(data_)    
    if self.cellData == nil then
        self.cellData = { }
        local totalNum = 0
        local disableNum = 0
        local typeName = nil
        dump(data_)
        if data_.army then
            for key, var in pairs(data_.army) do
                if typeName == nil then
                    local def = var:getDef()
                    typeName = soldierBigType[me.toStr(def.bigType)]
                end
                totalNum = totalNum + var.num
                table.insert(self.cellData, #self.cellData + 1, var)
            end    
        end
        if data_.disable then 
            for key, var in pairs(data_.disable) do
                if typeName == nil then
                    local def = var:getDef()
                    typeName = soldierBigType[me.toStr(def.bigType)]
                end
                disableNum = disableNum + var.num
                table.insert(self.cellData, #self.cellData + 1, var)
            end   
        end   
        if data_.index then  
            self.Text_soldier:setString("队列".. data_.index)  
            me.assignWidget(self,"Text_soldier_num_1"):setVisible(true)
            self.Text_soldier_disable:setVisible(true)    
            self.Text_soldier_tag:setVisible(true)
        else  
            me.assignWidget(self,"Text_soldier_num_1"):setVisible(false)
            self.Text_soldier_disable:setVisible(false)
            self.Text_soldier:setString(data_.name) 
            self.Text_soldier_tag:setVisible(false)
        end
        self.Text_soldier_num:setString(totalNum)
        self.Text_soldier_disable:setString(disableNum) 
        self.Text_soldier_tag :setString("("..data_.x..","..data_.y..")")
        me.registGuiClickEvent(self.Text_soldier_tag,function (node)
            LookMap(cc.p(data_.x,data_.y) )
        end)
    end    
end
function armyCellOut:initCell()
    local iNum = table.nums(self.cellData)
    local function cellSizeForTable(table, idx)
        return 240, 287
    end
    self.globalItems = me.createNode("Node_soldierItem.csb")
    self.globalItems:retain()
    local function info_call(node)
                local info = soldierInfoLayer:create("soldlierInfoLayer.csb")
                info:initWithData(node.data:getDef(),node.data)
                -- mainCity:addChild(info,me.MAXZORDER)
                me.popLayer(info)
                me.showLayer(info,"bg")  
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = self.cellData[idx + 1]
        local def = data:getDef()
        local item = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = me.assignWidget(self.globalItems, "soldierItem"):clone()
            item:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
            me.assignWidget(item, "Text_name"):setString(def.name)
            me.assignWidget(item, "Text_num"):setString(data.num)
            me.assignWidget(item, "Text_type"):setString(soldierType[me.toStr(def.smallType)])
            me.assignWidget(item, "item_icon"):loadTexture(soldierIcon(def), me.plistType)
            me.assignWidget(item,"Image_disable"):setVisible(data.idisable ==true )
            local infoBtn  = me.registGuiClickEventByName(item,"Image_Tips",info_call)
            infoBtn.data = data
            cell:addChild(item)
        else
            item = me.assignWidget(cell, "soldierItem")
            me.assignWidget(item, "Text_name"):setString(def.name)
            me.assignWidget(item, "Text_num"):setString(data.num)
            me.assignWidget(item, "Text_type"):setString(soldierType[me.toStr(def.smallType)])
            me.assignWidget(item, "item_icon"):loadTexture(soldierIcon(def), me.plistType)
            me.assignWidget(item,"Image_disable"):setVisible(data.idisable ==true)
            local infoBtn  = me.registGuiClickEventByName(item,"Image_Tips",info_call)
            infoBtn.data = data
        end
        local qiansanBtn = me.registGuiClickEventByName(item, "qiansanBtn", function(node)
        
        end )
        
        qiansanBtn:setVisible(false)        
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

function armyCellOut:onEnter()
    print("armyCellOut:onEnter()")
    self:initCell()
end

function armyCellOut:onEnterTransitionDidFinish()
end

function armyCellOut:onExit()
    print("armyCellOut:onExit()")
    if self.globalItems then self.globalItems:release() end
end

