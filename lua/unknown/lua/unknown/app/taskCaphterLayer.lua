-- [Comment]
-- jnmo
taskCaphterLayer = class("taskCaphterLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
taskCaphterLayer.__index = taskCaphterLayer
function taskCaphterLayer:create(...)
    local layer = taskCaphterLayer.new(...)
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
function taskCaphterLayer:ctor()
    print("taskCaphterLayer ctor")
end
function taskCaphterLayer:init()
    print("taskCaphterLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.Button_Allget = me.registGuiClickEventByName(self, "Button_Allget", function(node)
        if user.taskCaphterDataTitle.status == 2 then
            NetMan:send(_MSG.task_caphter_get_title())
            self:close()
        end
    end )
    self.Image_jz_lm = me.assignWidget(self, "Image_jz_lm")
    self.Image_jz_name = me.assignWidget(self, "Image_jz_name")
    self.Image_jz = me.assignWidget(self, "Image_jz")
    self.Text_jz_desc = me.assignWidget(self, "Text_jz_desc")
    self.Button_get = me.assignWidget(self, "Button_get")
    self.list_bottom = me.assignWidget(self, "list_bottom")
    self.closeEvt = me.RegistCustomEvent("taskCaphterLayerClose",function (args)
         self:close()
    end)
    return true
end
function taskCaphterLayer:initWithData()
    local data = cfg[CfgType.CAPHTER_TITLE][user.taskCaphterDataTitle.id]
    self.Image_jz_lm:loadTexture("ui_zjrw_xtext_0" .. user.taskCaphterDataTitle.id .. ".png", me.plistType)
    self.Image_jz:loadTexture("ui_zjrw_text_0" .. user.taskCaphterDataTitle.id .. ".png", me.plistType)
    self.Image_jz_name:loadTexture("ui_zjrw_ctext_0" .. data.icon .. ".png", me.plistType)
    self.Image_jz_lm:ignoreContentAdaptWithSize(true)
    self.Image_jz:ignoreContentAdaptWithSize(true)
    self.Image_jz_name:ignoreContentAdaptWithSize(true)
    self.Text_jz_desc:setString(data.desc)
    self:initTaskTable()
    self.list_bottom:removeAllChildren()
    local rewards = me.split(data.reward, ",")
    for key, var in ipairs(rewards) do
        local ds = me.split(var, "|")
        local cell = me.assignWidget(self,"Button_item"):clone()
        cell:setVisible(true)
        local pCfgData = cfg[CfgType.ETC][tonumber(ds[1])]
        me.assignWidget(cell, "Goods_Icon"):loadTexture("item_"..pCfgData.icon..".png",me.localType)
        me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(pCfgData.quality),me.localType)
        me.assignWidget(cell, "label_num"):setString(ds[2])    
        self.list_bottom:pushBackCustomItem(cell)
        me.assignWidget(cell, "num_bg"):setVisible(true)    
        local btnBg = me.assignWidget(cell, "Goods_Icon")
        btnBg:setSwallowTouches(false)
        btnBg.id = tonumber(ds[1])
        btnBg.num = tonumber(ds[2])
        me.registGuiClickEvent(btnBg, function(node)
            showPromotion(node.id,node.num)
        end )
    end
    me.setButtonDisable(self.Button_Allget, user.taskCaphterDataTitle.status == 2)
end
function taskCaphterLayer:initTaskTable()
    self.listdata = user.taskCaphterData
    self.cellindex = nil
    local iNum = #self.listdata
    self.guideIndex = nil
    local function scrollViewDidScroll(view)
        -- print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        -- print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 881, 90
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = self.listdata[idx + 1]
        local def = cfg[CfgType.CAPHTER_TASK][data.id]
        local function getcall(node)
            if data.status == 2 then
                NetMan:send(_MSG.task_caphter_get_task(node.data.id))
                me.setButtonDisable(node, false)
                if guideHelper.guideIndex == 18 then
                    guideHelper.setGuideIndex(19)                    
                    guideHelper.saveGuideIndex()
                    if self.guideIndex then
                        local guide = guideView:getInstance()
                        local cell = self.TableView:cellAtIndex(self.guideIndex)
                        local btn = me.assignWidget(cell, "Button_Go")
                        guide:showGuideViewCellBtn(cell, btn, true, true, function()                            
                        end , nil, false)
                        addToCurrentView(guide)
                        guideHelper.removeWaitLayer()
                        guideHelper.setGuideIndex(20) 
                    end
                end
            end
        end
        local function gocall(node)
            guideHelper.nextStep()         
            TaskHelper.taskCaphterJump(node.def)            
            self:close()
        end
        if nil == cell then
            cell = cc.TableViewCell:new()
            local itemClone = me.assignWidget(self, "chapter_cell"):clone()
            itemClone:setTag(23)
            local Text_Cell_Name = me.assignWidget(itemClone, "Text_Cell_Name")
            local Image_state = me.assignWidget(itemClone, "Image_state")
            local Text_Cell_Process = me.assignWidget(itemClone, "Text_Cell_Process")
            local Button_Get = me.assignWidget(itemClone, "Button_Get")
            local Image_complete = me.assignWidget(itemClone, "Image_complete")
            local Button_Go = me.assignWidget(itemClone, "Button_Go")
            itemClone:setPosition(440, 45)
            cell:addChild(itemClone)
            Text_Cell_Name:setString(def.gole)
            local awards = me.split(def.awards, ",")
            for var = 1, 3 do
                local item = me.assignWidget(itemClone, "item" .. var)
                item:setVisible(false)
                local item_num = me.assignWidget(itemClone, "item_num" .. var)
                item_num:setVisible(false)
            end
            if awards then
                for key, var in pairs(awards) do
                    local sg = me.split(var, "|")
                    local item = me.assignWidget(itemClone, "item" .. key)
                    item:setVisible(true)
                    local item_num = me.assignWidget(itemClone, "item_num" .. key)
                    item_num:setVisible(true)
                    item:loadTexture(getItemIcon(tonumber(sg[1])), me.localType)
                    item_num:setString(sg[2])
                end
            end
            me.registGuiClickEvent(Button_Get, getcall)
            me.registGuiClickEvent(Button_Go, gocall)
            Button_Get.data = data
            Button_Go.def = def

            Text_Cell_Process:setString("[" .. data.value .. "/" .. data.maxValue .. "]")
            if data.status == 1 then
                Button_Get:setVisible(false)
                Button_Go:setVisible(true)
                Image_complete:setVisible(false)
                Image_state:setVisible(false)
            elseif data.status == 2 then
                Button_Get:setVisible(true)
                Button_Go:setVisible(false)
                Image_complete:setVisible(false)
                Image_state:setVisible(true)
                if guideHelper.guideIndex == 17 then
                    self.cellindex = idx
                end
            elseif data.status == 3 then
                Button_Get:setVisible(false)
                Button_Go:setVisible(false)
                Image_complete:setVisible(true)
                Image_state:setVisible(true)
            elseif data.status == 0 then
                Button_Get:setVisible(false)
                Button_Go:setVisible(false)
                Image_complete:setVisible(false)
                Image_state:setVisible(false)
            end

        else
            local itemClone = cell:getChildByTag(23)
            local Text_Cell_Name = me.assignWidget(itemClone, "Text_Cell_Name")
            local Image_state = me.assignWidget(itemClone, "Image_state")
            local Text_Cell_Process = me.assignWidget(itemClone, "Text_Cell_Process")
            local Button_Get = me.assignWidget(itemClone, "Button_Get")
            local Image_complete = me.assignWidget(itemClone, "Image_complete")
            local Button_Go = me.assignWidget(itemClone, "Button_Go")
            Text_Cell_Name:setString(def.gole)
            local awards = me.split(def.awards, ",")
            Button_Get.data = data
            Button_Go.data = data
            Text_Cell_Process:setString("[" .. data.value .. "/" .. data.maxValue .. "]")
            for var = 1, 3 do
                local item = me.assignWidget(itemClone, "item" .. var)
                item:setVisible(false)
                local item_num = me.assignWidget(itemClone, "item_num" .. var)
                item_num:setVisible(false)
            end
            if awards then
                for key, var in pairs(awards) do
                    local sg = me.split(var, "|")
                    local item = me.assignWidget(itemClone, "item" .. key)
                    item:setVisible(true)
                    local item_num = me.assignWidget(itemClone, "item_num" .. key)
                    item_num:setVisible(true)
                    item:loadTexture(getItemIcon(tonumber(sg[1])), me.localType)
                    item_num:setString(sg[2])
                end
            end
            me.registGuiClickEvent(Button_Get, getcall)
            me.registGuiClickEvent(Button_Go, gocall)
            if data.status == 1 then
                Button_Get:setVisible(false)
                Button_Go:setVisible(true)
                Image_complete:setVisible(false)
                Image_state:setVisible(false)
            elseif data.status == 2 then
                Button_Get:setVisible(true)
                Button_Go:setVisible(false)
                Image_complete:setVisible(false)
                Image_state:setVisible(true)
            elseif data.status == 3 then
                Button_Get:setVisible(false)
                Button_Go:setVisible(false)
                Image_complete:setVisible(true)
                Image_state:setVisible(true)
            elseif data.status == 0 then
                Button_Get:setVisible(false)
                Button_Go:setVisible(false)
                Image_complete:setVisible(false)
                Image_state:setVisible(false)
            end
        end
        --引导指向建造军营
        if def.id == 2 then
            self.guideIndex = idx
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end
    if self.TableView == nil then
        tableView = cc.TableView:create(cc.size(881, 450))
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:setPosition(0, 3)
        tableView:setDelegate()
        me.assignWidget(self, "tableview_node"):addChild(tableView)
        -- registerScriptHandler functions must be before the reloadData funtion
        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self.TableView = tableView
    end
    self.TableView:reloadData()
    me.DelayRun( function(args)
        if self.cellindex then
            local guide = guideView:getInstance()
            local cell = self.TableView:cellAtIndex(self.cellindex)
            local btn = me.assignWidget(cell, "Button_Get")
            guide:showGuideViewCellBtn(cell, btn, true, true, function()                    
            end , nil, false)
            addToCurrentView(guide)
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.removeWaitLayer()
            self.cellindex = nil
        end
        if self.guideIndex then
            if guideHelper.guideIndex == 20 then
                local guide = guideView:getInstance()
                local cell = self.TableView:cellAtIndex(self.guideIndex)
                local btn = me.assignWidget(cell, "Button_Go")
                guide:showGuideViewCellBtn(cell, btn, true, true, function()                   
                end , nil, false)
                addToCurrentView(guide)
                guideHelper.removeWaitLayer()
            end
        end
    end )
end
function taskCaphterLayer:onEnter()
    print("taskCaphterLayer onEnter")
    me.doLayout(self, me.winSize)
    self:initWithData()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.TASK_CAPHTER_TITLE) then
            -- 完成任务
            self:initWithData()
        elseif checkMsg(msg.t, MsgCode.TASK_CAPHTER_DATA) then
            self:initTaskTable()
        elseif checkMsg(msg.t, MsgCode.TASK_CAPHTER_DATA_UPDATA) then
            self:initTaskTable()
        end
    end )
end
function taskCaphterLayer:onEnterTransitionDidFinish()
    print("taskCaphterLayer onEnterTransitionDidFinish")
end
function taskCaphterLayer:onExit()
    print("taskCaphterLayer onExit")
    UserModel:removeLisener(self.modelkey)
    me.RemoveCustomEvent(self.closeEvt)
end
function taskCaphterLayer:close()
    self:removeFromParent()
end
