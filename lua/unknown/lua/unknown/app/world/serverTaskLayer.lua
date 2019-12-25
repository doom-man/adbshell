serverTaskLayer = class("serverTaskLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
serverTaskLayer.__index = serverTaskLayer

-- 当前活动id号
ACTIVITY_ID_SEVENTHLOGIN = 2 -- 7日登录


function serverTaskLayer:create(...)
    local layer = serverTaskLayer.new(...)
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

function serverTaskLayer:ctor()
    print("serverTaskLayer:ctor()")
    self.tableView = nil
    self.listData = { }
    self.selCellId = nil
    -- 当前所在什么子界面

end
function serverTaskLayer:init()
    self.Image_left = me.assignWidget(self, "Image_left")
    self.Panel_right = me.assignWidget(self, "Panel_right")
    self.Panel_Table = me.assignWidget(self, "Panel_Table")
    self.img_title = me.assignWidget(self, "img_title")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.curEvt = me.RegistCustomEvent("serverTaskLayerclose", function(rev)
        self:close()
    end )

    self.gift_item = me.createNode("gift_item.csb")
    self.gift_item:retain()
    return true
end
function serverTaskLayer:revInitList(msg)
    me.tableClear(self.listData)
    self.listData = { }
    
    for key, var in pairs(user.serverTaskList.list) do
        self.listData[#self.listData + 1] = var
      
    end
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 220, 75
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "table_cell"):clone()
            node:setContentSize(cc.size(215, 60))
            node:setPosition(0, 0)
            me.assignWidget(node, "nameTxt"):enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(2, -2))  

            cell:addChild(node)
        else
            node = me.assignWidget(cell, "table_cell")
        end
        node:setVisible(true)
        -- 小红点
        local redpoint = me.assignWidget(node, "redpoint")
        redpoint:setVisible(false)
        cell.redpoint = redpoint

        local tmp = self.listData[me.toNum(idx + 1)]
        if tmp then
            --dump(tmp)
            local nameTxt = me.assignWidget(node, "nameTxt")
            nameTxt:setString(tmp.name)
            cell.type = tonumber(tmp.type)
        else
            node:setVisible(false)
        end

        return cell
    end

    local function tableCellTouched(table, cell)
        if self.selCellId == cell.type then
            return
        end
        self:setSelectTableCell(cell.type)
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(220, 567))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(2, 1)
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        self.Image_left:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
    if #self.listData > 0 then
        -- 选中第一个
        self:setSelectTableCell(self.listData[1].type) 
    end
    -- 更新小红点
    self:updateRedPoint()
end

-- 页签小红点
function serverTaskLayer:updateRedPoint()
    for i = 1, #self.listData do
        local cell = self.tableView:cellAtIndex(i - 1)
        if cell and cell.redpoint and cell.type then
            local tempStr = "world_task_"..cell.type
            cell.redpoint:setVisible(user.UI_REDPOINT.serverTaskBtn[tempStr] == 1)
        end
    end
end

function serverTaskLayer:setRightView(msg)
    -- 修改小红点缓存
    self:modifyRedPointData(msg)
    self.Panel_Table:removeAllChildren()
    self.tableView_right = nil
    -- 成长之路
    if msg.c.type == 2 then
        self.img_title:setString("成长之路")
        local node = growWayNode:create({data = msg.c.list})
        node:setPositionY(4)
        self.Panel_Table:addChild(node)
        return
    end
    -- 天下大势
    self.img_title:setString("天下大势")
    self.msg = msg
    self.rightViewList = { }
    self.curIndex = 1
    local index= 1
    for key, var in pairs(msg.c.list) do        
        table.insert(self.rightViewList, var)
        if var.process == 1 then
            self.curIndex = index
        end        
        index = index + 1
    end
    local function numberOfCellsInTableView(table)
        return #self.rightViewList
    end

    local function cellSizeForTable(table, idx)
        return 1000, 275
    end
    local function click_call(node)
        
        local id = node.id
        print("id = "..id)
        if node.data.process == 0 then
            showTips("未开启")
        else
        NetMan:send(_MSG.world_task_name_view(id))
        local cell  = serverTaskCell:create("worldTaskCell.csb")
        me.popLayer(cell)
        end
    end
    local function item_call(node)
          showPromotion(node.itemid,node.itemnum)
    end
   
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "item_cell"):clone()
            node:setPosition(0, 0)

            cell:addChild(node)
        else
            node = me.assignWidget(cell, "item_cell")
        end
        node:setVisible(true)
        local tmp = self.rightViewList[me.toNum(idx + 1)]
        if tmp then
            --dump(tmp)
            me.registGuiClickEvent(node, click_call)
            node:setSwallowTouches(false)
            node.id = tmp.id
            node.data = tmp
            local Text_time = me.assignWidget(node, "Text_time")
            local Image_time_bg = me.assignWidget(node, "Image_time_bg")
            local Image_complete = me.assignWidget(node, "Image_complete")
            local Image_end = me.assignWidget(node, "Image_end")
            local Image_complete_bg = me.assignWidget(node, "Image_complete_bg")
            local gift = me.assignWidget(node, "gift")
            gift:removeAllChildren()
            local Text_process = me.assignWidget(node, "Text_process")
            local Text_limit = me.assignWidget(node, "Text_limit")
            local Button_get = me.assignWidget(node, "Button_get")
            local Text_target = me.assignWidget(node, "Text_target")
            local nameTxt = me.assignWidget(node, "nameTxt")
            local icon = me.assignWidget(node, "icon")
            local Image_name_list_bg = me.assignWidget(node,"Image_name_list_bg")
            nameTxt:setString(tmp.name)
            me.Helper:normalImageView(icon)    
            if tmp.status == 0 then
                   me.setButtonDisable(Button_get,false)
                   me.assignWidget(node,"Text_43"):setString("不可领取")
            elseif tmp.status == 1 then
                me.setButtonDisable(Button_get,true)
                me.assignWidget(node,"Text_43"):setString("领取")                
            elseif tmp.status == 2 then
                 me.setButtonDisable(Button_get,false)
                 me.assignWidget(node,"Text_43"):setString("已领取")
            end
            if tmp.process == 1 then                
                if tmp.time == -1 then
                     Text_time:setString("永久")
                else
                    Text_time:setString(me.formartSecTime(tmp.time / 1000))
                end
            elseif tmp.process == 0 then
                me.Helper:grayImageView(icon)
                me.setButtonDisable(Button_get,false)
                me.assignWidget(node,"Text_43"):setString("未开启")
            end
            -- reward":"9008:200,26:4
            Button_get.id = tmp.id
            Button_get.data = tmp 
            me.registGuiClickEvent(Button_get,function (node) 
                if Button_get.data.status == 1 then                           
                    NetMan:send(_MSG.world_task_get(node.id))   
                    node.data.status = 2
                    me.setButtonDisable(node,false)
                    node:setTouchEnabled(true)
                    self:setRightView(self.msg)             
                end
            end)
            Text_target:setString(tmp.desc)
            Text_limit:setString("领奖需要主城" .. tmp.level .. "级")
            if tmp.max > 10000 then
                Text_process:setString("进度:" .. Scientific( tmp.value ) .. "/" .. Scientific(tmp.max))
            else
                Text_process:setString("进度:" .. tmp.value .. "/" .. tmp.max)
            end
            Text_process:setVisible(tmp.stype == 1)
            Image_complete_bg:setVisible(tmp.process ~= 1 and tmp.process ~= 0)
            Image_complete:setVisible(tmp.process == 2)
            Image_end:setVisible(tmp.process == 3)
            Image_time_bg:setVisible(tmp.process == 1)
            Text_time:setVisible(tmp.process == 1)
   
            icon:loadTexture("world_task_" .. tmp.icon .. ".png", me.localType)
            if tmp.nameList then
                Image_name_list_bg:setVisible(true)
                Image_name_list_bg:removeAllChildren()
                local nl = me.split(tmp.nameList,",")
                me.assignWidget(node,"Text_1"):setVisible(true)
                for k, v in pairs(nl) do
                    local n = me.assignWidget(node,"Text_l1"):clone()
                    n:setVisible(true)
                    Image_name_list_bg:addChild(n)
                    n:setString(v)
                    n:setVisible(true)
                    n:setPosition(163,28 -(k-1)*24)
                end                
            else
                Image_name_list_bg:setVisible(false)
                Image_name_list_bg:removeAllChildren()
                me.assignWidget(node,"Text_1"):setVisible(false)
            end
            local index = 1
            local itemCell = me.assignWidget(self.gift_item, "Image_itemBg")
            if tmp.reward then
                local reward = me.split(tmp.reward, ",")
                for key, var in pairs(reward) do
                    local data = me.split(var, ":")
                    local item = itemCell:clone()
                    local Image_item = me.assignWidget(item, "Image_item")
                    local Text_Num = me.assignWidget(item, "Text_Num")
                    local Image_13 = me.assignWidget(item, "Image_13")
                    local Image_shxiao = me.assignWidget(item, "Image_shxiao")
                    Image_item:loadTexture(getItemIcon(data[1]), me.localType)
                    Text_Num:setString(data[2])
                    item:setVisible(true)
                    Image_shxiao:setVisible(tmp.process == 3)
                    item:setPosition(index * 103 - 45, 52)
                    gift:addChild(item)
                    item.itemid = data[1]
                    item.itemnum = data[2]
                    index = index + 1
                    me.registGuiClickEvent(item,item_call)
                end
            end
            if tmp.unlock then
                local unlock = me.split(tmp.unlock, ",")
                for key, var in pairs(unlock) do
                    local item = itemCell:clone()
                    local data = me.split(var, ":")
                    local Image_item = me.assignWidget(item, "Image_item")
                    local Text_Num = me.assignWidget(item, "Text_Num")
                    local Image_13 = me.assignWidget(item, "Image_13")
                    local Image_shxiao = me.assignWidget(item, "Image_shxiao")
                    Image_item:loadTexture(getItemIcon(data[1]), me.localType)
                    Text_Num:setString(data[2])
                    Image_shxiao:setVisible(false)
                    item:setVisible(true)
                    item:setPosition(index * 103 - 45, 52)
                    gift:addChild(item)
                    item.itemid = data[1]
                    item.itemnum = data[2]
                    index = index + 1
                    me.registGuiClickEvent(item,item_call)
                end
            end
        else
            node:setVisible(false)
        end
        return cell
    end

    local function tableCellTouched(table, cell)
        local data = self.rightViewList[cell:getIdx() + 1]
    end

    if self.tableView_right == nil then
        self.tableView_right = cc.TableView:create(cc.size(1006, 572))
        self.tableView_right:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_right:setPosition(3, 1)
        self.tableView_right:setAnchorPoint(cc.p(0, 0))
        self.tableView_right:setDelegate()
        self.Panel_Table:addChild(self.tableView_right)
        self.tableView_right:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_right:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_right:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView_right:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_right:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_right:reloadData() 
    self:setTableOffset(self.curIndex)
end
function serverTaskLayer:setTableOffset(pIdx)
	if pIdx < 3 then
		self.tableView_right:setContentOffset(cc.p(0,-(#self.rightViewList*275 - 572)))
    elseif pIdx > #self.rightViewList-2 then 
		self.tableView_right:reloadData()
		self.tableView_right:setContentOffset(cc.p(0,0))
    else
        if (#self.rightViewList-pIdx) < 0 then
			self.tableView_right:reloadData()
			self.tableView_right:setContentOffset(cc.p(0,0))
        else
			self.tableView_right:reloadData()
			self.tableView_right:setContentOffset(cc.p(0,-(#self.rightViewList- pIdx)*275))
        end
    end
end
function serverTaskLayer:setSelectTableCell(cellId)
    self.selCellId = cellId
    for i = 1, #self.listData do
        local cell = self.tableView:cellAtIndex(i - 1)
        if cell then
            local img_select = me.assignWidget(cell, "img_select")
            local table_cell = me.assignWidget(cell, "table_cell")
            if cell.type == cellId then
                img_select:setVisible(true)
                table_cell:loadTextureNormal("chengjiu_yeqian_02.png", me.localType)
                NetMan:send(_MSG.world_task_list(cellId))
            else
                table_cell:loadTextureNormal("chengjiu_yeqian_01.png", me.localType)
                img_select:setVisible(false)
            end
            table_cell:setContentSize(cc.size(215, 60))
        end 
    end
end

function serverTaskLayer:modifyRedPointData(msg)
    local showRed = 0
    for i, v in ipairs(msg.c.list) do
        if v.status == 1 then
            showRed = 1
            break
        end
    end
    local tempStr = "world_task_"..msg.c.type
    user.UI_REDPOINT.serverTaskBtn[tempStr] = showRed
    me.dispatchCustomEvent("UI_RED_POINT")
end

function serverTaskLayer:removePanel_right()
    for key, var in pairs(self.Panel_right:getChildren()) do
        if self.turnplateNode ~= var then
            var:removeFromParentAndCleanup(true)
        else
            self.turnplateNode:setVisible(false)
        end
    end
end

function serverTaskLayer:revInitDetail(msg)
    self:setRightView(msg)
end
function serverTaskLayer:onEnter()
    print("serverTaskLayer:onEnter()")
    -- 发送活动接口
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    self.close_event = me.RegistCustomEvent("serverTaskLayer", function(evt)
        self:close()
    end )
    me.doLayout(self, me.winSize)
    -- 监听小红点
    self.redPointListener = me.RegistCustomEvent("UI_RED_POINT", handler(self, self.updateRedPoint))
end
function serverTaskLayer:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_TASK_NAME_LIST) then
        self:revInitList(msg)
    elseif checkMsg(msg.t, MsgCode.WORLD_TASK_LIST) then
        self:revInitDetail(msg)
    end
end
function serverTaskLayer:onExit()
    me.RemoveCustomEvent(self.close_event)
    me.RemoveCustomEvent(self.curEvt)
    me.RemoveCustomEvent(self.redPointListener)
    self.gift_item:release()
    print("serverTaskLayer:onExit()")
end
function serverTaskLayer:close()
    print("serverTaskLayer:close()")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    self:getParent().serverTaskLayer = nil
    self:removeFromParentAndCleanup(true)
    self.turnplateNode = nil
end

