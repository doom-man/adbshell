kingdomView_foundation_donate = class("kingdomView_foundation_donate", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
kingdomView_foundation_donate.__index = kingdomView_foundation_donate
function kingdomView_foundation_donate:create(...)
    local layer = kingdomView_foundation_donate.new(...)
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
function kingdomView_foundation_donate:ctor()
    print("kingdomView_foundation_donate:ctor()")
end
function kingdomView_foundation_donate:init()
    self.selectNum = 0
    self.totalNum = 0
    self.selectItemId = 0
    self.Panel_items = me.assignWidget(self,"Panel_items")
    self.Text_workNum = me.assignWidget(self,"Text_workNum")
    self.Slider_worker = me.assignWidget(self,"Slider_worker")
    self.Button_comfirm = me.assignWidget(self,"Button_comfirm")
    me.registGuiClickEvent(self.Button_comfirm,function ()
        NetMan:send(_MSG.kingdom_donate_item(self.selectItemId,self.selectNum))
    end)

    --监听滑动条信息
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local percent = sender:getPercent() / 100
            local curNum = math.floor(percent*self.totalNum)
            self:setDonateNum(curNum,self.totalNum)
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)
    self.btn_reduce = me.assignWidget(self,"btn_reduce")
    self.btn_add = me.assignWidget(self,"btn_add")
    me.registGuiClickEvent(self.btn_add,function ()
        self.selectNum = self.selectNum +1
        self:setDonateNum(self.selectNum)
    end)    
    me.registGuiClickEvent(self.btn_reduce,function ()
        self.selectNum = self.selectNum - 1
        self:setDonateNum(self.selectNum)
    end)
    me.registGuiClickEvent(me.assignWidget(self,"close"),function (node)
        self:close()
    end)
    return true
end
function kingdomView_foundation_donate:close()
    self.pNode.donateSubcell = nil
    self:removeFromParentAndCleanup(true)
end
function kingdomView_foundation_donate:onEnter()
    me.doLayout(self,me.winSize)  
    self:setTableView()
end
function kingdomView_foundation_donate:setItemListData(data,update)
    self.listData = data
    if update then
        self.tableView:reloadData()
        if #self.listData > 0 then
            self.preIndex = 1
            if self.preCell then
                me.assignWidget(self.preCell,"Image_light"):setVisible(true)
            end
            local itemInfo = self.listData[1]
            self:setDonateNum(1,itemInfo.count, itemInfo.defId)
        else
            self:close()
        end
    end
end
function kingdomView_foundation_donate:setFatherNode(node)
    self.pNode = node
end
function kingdomView_foundation_donate:onEnterTransitionDidFinish()
end
function kingdomView_foundation_donate:onExit()
    print("kingdomView_foundation_donate:onExit()")
end

function kingdomView_foundation_donate:setDonateNum(curNum, totalNum, itemId)
    if totalNum then
        self.totalNum = totalNum    
    end
    self.selectNum = curNum
    if curNum <= 0  then
        self.selectNum = 0
    elseif curNum >= self.totalNum then
        self.selectNum = self.totalNum
    end

    if self.totalNum >0 then
        self.Slider_worker:setPercent(self.selectNum / self.totalNum * 100)
        self.Text_workNum:setString(self.selectNum)
    else
        self.Text_workNum:setString(0)
        self.Slider_worker:setPercent(0)
    end
    if itemId then
        self.selectItemId = itemId
    end
    local donateInfo = cfg[CfgType.KINGDOM_DONATE][self.selectItemId]
    if donateInfo then
        me.assignWidget(self,"Text_desc_left"):setString("国库可获得水晶："..donateInfo.nationCoin*self.selectNum)
        me.assignWidget(self,"Text_desc_right"):setString("可获得个人贡献："..donateInfo.playerCon*self.selectNum)
    end    
    me.buttonState(self.Button_comfirm,me.toNum(self.selectNum)>0)
end

function kingdomView_foundation_donate:setTableView()
    local function tableCellTouched(table, cell)
        if self.preCell ~= nil then
            me.assignWidget(self.preCell,"Image_light"):setVisible(false)
        end
        self.cellIdx = cell:getIdx()
        local itemInfo = self.listData[self.cellIdx+1]
        self.preCell = cell
        me.assignWidget(self.preCell,"Image_light"):setVisible(true)
        self:setDonateNum(1,itemInfo.count, itemInfo.defId)
    end

    local function cellSizeForTable(table, idx)
        return 130, 150
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        local itemInfo = self.listData[idx+1]
        local itemDef = cfg[CfgType.ETC][itemInfo.defId]
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item =  me.createNode("useToolsItem.csb")
            local layer = me.assignWidget(item, "Panel_cell"):clone()
            cell:addChild(layer)  
            if self.preCell == nil and idx == 0 then
                self.preCell = cell
                self.cellIdx = idx+1
                me.assignWidget(self.preCell,"Image_light"):setVisible(true)
                self:setDonateNum(1,itemInfo.count, itemInfo.defId)
            end
        else
            cell:setTag(idx+1)   
            if self.preIndex == idx+1 then
                me.assignWidget(self.preCell,"Image_light"):setVisible(true)
            end  
        end    
        me.assignWidget(cell,"Text_itemName"):setString(itemDef.name)
        me.assignWidget(cell,"Text_Num"):setString(itemInfo.count)
        me.assignWidget(cell,"Image_item"):loadTexture("item_"..itemDef.icon..".png")
        me.assignWidget(cell,"Image_itemBg"):loadTexture(getQuality(itemDef["quality"]), me.localType)
        me.assignWidget(cell,"Button_item"):setSwallowTouches(false)
        return cell
    end

    function numberOfCellsInTableView(table)
        return #self.listData
    end

    self.tableView = cc.TableView:create(cc.size(self.Panel_items:getContentSize().width,self.Panel_items:getContentSize().height))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 0)
    self.tableView:setDelegate()
    self.Panel_items:addChild(self.tableView)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:reloadData()
end