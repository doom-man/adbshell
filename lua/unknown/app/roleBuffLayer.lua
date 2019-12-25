-- [Comment]
-- jnmo
roleBuffLayer = class("roleBuffLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    else
        return cc.CSLoader:createNode(arg[1])
    end
end )
roleBuffLayer.__index = roleBuffLayer
function roleBuffLayer:create(...)
    local layer = roleBuffLayer.new(...)
    if layer then
        local _, _, from = ...
        if layer:init(from) then
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
BUFF_TYPE_BATTLE = 1
BUFF_TYPE_DEV = 2
BUFF_TYPE_INTERIOR = 3
BUFF_TYPE_POLICY = 4
BUFF_TYPE_UNION = 5
function roleBuffLayer:ctor()
    print("roleBuffLayer ctor")
    self.cdtimes = {}
    self.chooseIndex = BUFF_TYPE_BATTLE
end
function roleBuffLayer:init(from)
    print("roleBuffLayer init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.Button_Battle = me.registGuiClickEventByName(self, "Button_Battle", function(node)
        -- 个人排名
        self:setButton(self.Button_Battle, false)
        self:setButton(self.Button_Dev, true)
        self:setButton(self.Button_Interior, true)
        self:setButton(self.Button_policy, true)
        self:setButton(self.Button_union, true)
        self.chooseIndex = BUFF_TYPE_BATTLE
        self.pPitchId = 1 
        self:initBuff()
    end )
    self.Button_Dev = me.registGuiClickEventByName(self, "Button_Dev", function(node)
        -- 个人排名
        self:setButton(self.Button_Battle, true)
        self:setButton(self.Button_Dev, false)
        self:setButton(self.Button_Interior, true)
        self:setButton(self.Button_policy, true)
        self:setButton(self.Button_union, true)
        self.chooseIndex = BUFF_TYPE_DEV
        self.pPitchId = 1 
        self:initBuff()
    end )
    self.Button_Interior = me.registGuiClickEventByName(self, "Button_Interior", function(node)
        -- 个人排名
        self:setButton(self.Button_Battle, true)
        self:setButton(self.Button_Dev, true)
        self:setButton(self.Button_Interior, false)
        self:setButton(self.Button_policy, true)
        self:setButton(self.Button_union, true)
        self.chooseIndex = BUFF_TYPE_INTERIOR
        self.pPitchId = 1 
        self:initBuff()
    end )
    self.Button_policy = me.registGuiClickEventByName(self, "Button_policy", function(node)
        self:setButton(self.Button_Battle, true)
        self:setButton(self.Button_Dev, true)
        self:setButton(self.Button_Interior, true)
        self:setButton(self.Button_policy, false)
        self:setButton(self.Button_union, true)
        self.chooseIndex = BUFF_TYPE_POLICY
        self.pPitchId = 1 
        self:initBuff()
    end )
    self.Button_union = me.registGuiClickEventByName(self, "Button_union", function(node)
        self:setButton(self.Button_Battle, true)
        self:setButton(self.Button_Dev, true)
        self:setButton(self.Button_Interior, true)
        self:setButton(self.Button_policy, true)
        self:setButton(self.Button_union, false)
        self.chooseIndex = BUFF_TYPE_UNION
        self.pPitchId = 1 
        self:initBuff()
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ROLE_BUFF_UPDATE) then
            self:initBuff()
        elseif checkMsg(msg.t, MsgCode.WORLD_THRONE_BUFFER) then
            self:initWorldThroneBuff(msg.c)
        end
    end )
    if from==3 then
        self.chooseIndex = BUFF_TYPE_INTERIOR
        self:setButton(self.Button_Battle, true)
        self:setButton(self.Button_Dev, true)
        self:setButton(self.Button_Interior, false)
        self:setButton(self.Button_policy, true)
        self:setButton(self.Button_union, true)
    else
        self.chooseIndex = BUFF_TYPE_BATTLE
        self:setButton(self.Button_Battle, false)
        self:setButton(self.Button_Dev, true)
        self:setButton(self.Button_Interior, true)
        self:setButton(self.Button_policy, true)
        self:setButton(self.Button_union, true)
    end
    self.pPitchId = 1 
    self:initBuff()    
    return true
end
function roleBuffLayer:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(me.convert3Color_("b1955f"))
    else
        title:setTextColor(me.convert3Color_("7c5f36"))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end


function roleBuffLayer:initBuff()
    for key, var in pairs(self.cdtimes) do
        me.clearTimer(var)
    end 
    self.cdtimes = {}
    local datas = cfg[CfgType.CITY_BUFF]
    local pTaskTab = { }
    local tabMap = { }
    for key, var in pairs(datas) do
        if tonumber(var.type) == self.chooseIndex then
            tabMap[var.stype] = var
        end
    end
    for key, var in pairs(tabMap) do
        if user.Role_Buff[var.stype] and user.Role_Buff[var.stype][self.chooseIndex] then
            var = datas[user.Role_Buff[var.stype][self.chooseIndex].defid]
            var.countDown = user.Role_Buff[var.stype][self.chooseIndex].countDown  
        else
             var.countDown = nil
        end
        table.insert(pTaskTab, var)
    end
    local function comp(a,b)
       return a.id < b.id
    end
    table.sort(pTaskTab,comp)
                
    self:setRightList(pTaskTab[self.pPitchId].stype,pTaskTab[self.pPitchId].item)
    self.curChooseData = pTaskTab[self.pPitchId]
    local list_left = me.assignWidget(self,"list_left")
    list_left:removeAllChildren()
    self.listItems = {}
    for key, var in ipairs(pTaskTab) do
            local tmp = me.assignWidget(self, "stateCell")
            tmp:setVisible(true)
            pTaskCell = tmp:clone()
            pTaskCell.idx = key
            local def = var
            local task_cell_bg_pitch = me.assignWidget(pTaskCell, "selectImg")
            local name = me.assignWidget(pTaskCell, "name")
            local desc = me.assignWidget(pTaskCell, "desc")
            local icon = me.assignWidget(pTaskCell, "icon")
            local load_bar_bg = me.assignWidget(pTaskCell, "load_bar_bg")
            local loadbar = me.assignWidget(pTaskCell, "loadbar")
            local time = me.assignWidget(pTaskCell, "time")

            icon:loadTexture("city_buff_" .. def.icon .. ".png", me.localType)

            name:setString(def.name)    
            if def.countDown then
                local ctime =(def.countDown - me.sysTime()) / 1000
                load_bar_bg:setVisible(true)
                loadbar:setPercent((ctime) * 100 / def.duration)
                time:setString(me.formartSecTime(ctime))            
                self.cdtimes[key] = me.registTimer(-1, function(dt)
                    if ctime > 0 then
                        ctime = ctime - dt
                        time:setString(me.formartSecTime(ctime))
                        loadbar:setPercent((ctime) * 100 / def.duration)
                    end
                end , 1)
                local itemdata = cfg[CfgType.ETC][tonumber(def.item)]
                if self.chooseIndex ~= BUFF_TYPE_POLICY and self.chooseIndex ~= BUFF_TYPE_UNION then
                    desc:setString(itemdata.describe)
                else
                    desc:setString(def.desc)
                end
            else
                desc:setString(def.desc)
                load_bar_bg:setVisible(false)
            end
            me.registGuiClickEvent(pTaskCell,function (node)
                  if self.pPitchId ~= node.idx then
                        me.assignWidget(self.listItems[self.pPitchId],"selectImg"):setVisible(false)
                        self.pPitchId = node.idx                 
                        me.assignWidget(self.listItems[self.pPitchId],"selectImg"):setVisible(true)
                        self:setRightList(pTaskTab[self.pPitchId].stype, pTaskTab[self.pPitchId].item)
                        self.curChooseData = pTaskTab[self.pPitchId]
                  end
            end)
            if key == self.pPitchId then               
                task_cell_bg_pitch:setVisible(true)
            else
                task_cell_bg_pitch:setVisible(false)
            end
            self.listItems[key] = pTaskCell
            list_left:pushBackCustomItem(pTaskCell)
    end   
end
function roleBuffLayer:setRightList(stype, item)
    local pTaskTab = { }

    if self.chooseIndex == BUFF_TYPE_UNION then
        item = tonumber(item)
        for key, var in pairs(cfg[CfgType.FAMILY_POLICY]) do
            if var.id == item then 
                table.insert(pTaskTab, var)
            end
        end
    elseif self.chooseIndex ~= BUFF_TYPE_POLICY then
        for key, var in pairs(cfg[CfgType.CITY_BUFF]) do
            if var.stype == stype and var.type==self.chooseIndex then                
                table.insert(pTaskTab, var)
            end
        end
    else
        item = tonumber(item)
        for key, var in pairs(cfg[CfgType.KINGDOM_POLICY]) do
            if var.id == item then 
                table.insert(pTaskTab, var)
            end
        end
    end

    local iNum = #pTaskTab
    local function scrollViewDidScroll(view)
        -- print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        -- print("scrollViewDidZoom")
    end
    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 649, 155
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local def = pTaskTab[idx + 1]
        local pTaskCell = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local tmp = me.assignWidget(self, "Image_Node")
            tmp:setVisible(true)
            pTaskCell = tmp:clone()
            pTaskCell:setTag(23)
            pTaskCell:setPosition(0, 0)
            cell:addChild(pTaskCell)
        else
            pTaskCell = cell:getChildByTag(23)
        end

        local Text_title = me.assignWidget(pTaskCell, "Text_title")
        local Text_desc = me.assignWidget(pTaskCell, "Text_desc")
        local Image_itemIcon = me.assignWidget(pTaskCell, "Image_itemIcon")
        local Image_itemQulity = me.assignWidget(pTaskCell, "Image_itemQulity")
        local Upper_num = me.assignWidget(pTaskCell, "Upper_num")
        local Image_diamond = me.assignWidget(pTaskCell, "Image_diamond")
        local Text_diamondNum = me.assignWidget(pTaskCell, "Text_diamondNum")
        local Text_own = me.assignWidget(pTaskCell, "Text_own")
        local Image_shadow_top = me.assignWidget(pTaskCell, "Image_shadow_top")
        local Text_btnTitle = me.assignWidget(pTaskCell, "Text_btnTitle")

        if self.chooseIndex == BUFF_TYPE_POLICY then
            Text_title:setString(def.name)
            Text_desc:setString(def.desc)
            Image_itemIcon:loadTexture("guoce_tb_"..def.icon..".png")
            Image_shadow_top:setVisible(false)
            Upper_num:setVisible(false)
            Image_diamond:setVisible(false)
            me.assignWidget(pTaskCell, "Button_use"):setVisible(false)
            me.assignWidget(pTaskCell, "Button_jump"):setVisible(true)
            Image_itemIcon:setScale(1.27)
            me.registGuiClickEventByName(pTaskCell, "Button_jump", function(node)
                self:close()
                if user.Cross_Sever_Status == mCross_Sever then
                        showTips("跨服中，无法操作")
                        return
                end
                mainCity:cloudClose( function(node)
                    NetMan:send(_MSG.worldthronecreate())  --请求王座状态数据
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    loadlayer:setWarningPoint(cc.p(600,600))
                    loadlayer:setOpenOpt(2)
                    me.runScene(loadlayer)
                end )
            end)
            return cell
        elseif self.chooseIndex == BUFF_TYPE_UNION then
            Text_title:setString(def.name)
            Text_desc:setString(def.desc)
            Image_itemIcon:loadTexture("city_buff_"..def.icon..".png")
            Image_shadow_top:setVisible(false)
            Upper_num:setVisible(false)
            Image_diamond:setVisible(false)
            me.assignWidget(pTaskCell, "Button_use"):setVisible(false)
            me.assignWidget(pTaskCell, "Button_jump"):setVisible(true)
            Image_itemIcon:setScale(1.27)
            me.registGuiClickEventByName(pTaskCell, "Button_jump", function(node)
                NetMan:send(_MSG.alliancePolicyLIST())  
                if me.runningScene():getChildByName("alliancePolicy")~=nil then return end
                local converge = alliancePolicy:create("alliancePolicy.csb")
                me.runningScene():addChild(converge, me.MAXZORDER)
                me.showLayer(converge, "bg")
            end)
            return cell
        end

        local itemdata = cfg[CfgType.ETC][tonumber(def.item)]
        local curItemData = nil
        local Button_use = me.registGuiClickEventByName(pTaskCell, "Button_use", function(node)
            if self.curChooseData.countDown and self.curChooseData.countDown > 0 then
                me.showMessageDialog("使用该道具会覆盖当前效果，是否确认？", function(evt)
                    if evt == "ok" then
                        if curItemData and curItemData.count then
                            NetMan:send(_MSG.userCityBuffItem(curItemData.defid))
                        else
                            if user.diamond >= tonumber(itemdata.diamondPrice or 0) then
                                me.showMessageDialog("确定花费"..itemdata.diamondPrice..  "钻石购买当前道具？", function(e)
                                    if e == "ok" then
                                        NetMan:send(_MSG.userCityBuffItem(itemdata.id))
                                    end
                                end)
                            else
                                askToRechage(0)
                            end
                        end
                    end
                end )
            else
                if curItemData and curItemData.count then
                       NetMan:send(_MSG.userCityBuffItem(curItemData.defid))
                else
                    if user.diamond >= tonumber(itemdata.diamondPrice or 0) then
                        me.showMessageDialog("确定花费"..itemdata.diamondPrice..  "钻石购买当前道具？", function(e)
                                    if e == "ok" then
                                        NetMan:send(_MSG.userCityBuffItem(itemdata.id))
                                    end
                        end)
                    else
                        askToRechage(0)
                    end
                end
            end
        end )
        Text_title:setString(itemdata.name)
        Text_desc:setString(itemdata.describe)
        Image_itemIcon:loadTexture(getItemIcon(tonumber(def.item)), me.localType)
        Image_itemQulity:loadTexture(getQuality(itemdata["quality"]), me.localType)
        for key, var in pairs(user.pkg) do
            if tonumber(var.defid) == tonumber(def.item) then
                curItemData = var
                break;
            end
        end
        if curItemData and curItemData.count then
            Image_shadow_top:setVisible(true)
            Upper_num:setString(curItemData.count)
            Text_btnTitle:setString("使用")
            Image_diamond:setVisible(false)
            Text_own:setVisible(true)
            Text_own:setString("拥有:" .. curItemData.count)
        else
            Image_shadow_top:setVisible(false)
            Upper_num:setVisible(false)
            Text_btnTitle:setString("购买并使用")
            Image_diamond:setVisible(true)
            Text_own:setVisible(false)
            Text_diamondNum:setString(itemdata.diamondPrice or 0)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return iNum
    end
    me.assignWidget(self, "Node_Table_Right"):removeAllChildren()
    local tableView = cc.TableView:create(cc.size(649, 560))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(0, 0)
    tableView:setDelegate()
    me.assignWidget(self, "Node_Table_Right"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end
function roleBuffLayer:onEnter()
    print("roleBuffLayer onEnter")
    me.doLayout(self, me.winSize)
end
function roleBuffLayer:onEnterTransitionDidFinish()
    print("roleBuffLayer onEnterTransitionDidFinish")
end
function roleBuffLayer:onExit()
    print("roleBuffLayer onExit")
    for key, var in pairs(self.cdtimes) do
        me.clearTimer(var)
    end
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function roleBuffLayer:close()
    self:removeFromParent()
end
