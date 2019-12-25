kingdomView_officer = class("kingdomView_officer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
kingdomView_officer.__index = kingdomView_officer
function kingdomView_officer:create(...)
    local layer = kingdomView_officer.new(...)
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
function kingdomView_officer:ctor()
    self.curId = 0
    self.preCell = nil
    print("kingdomView_officer:ctor()")
end
function kingdomView_officer:init()
    self.timer = nil
    self.Panel_table = me.assignWidget(self,"Panel_table")
    self.Text_notice = me.assignWidget(self,"Text_notice")
    self.Text_time = me.assignWidget(self,"Text_time")
    self.Text_alliance = me.assignWidget(self,"Text_alliance")
    self.Text_kingName = me.assignWidget(self,"Text_kingName")
    self.Panel_rename = me.assignWidget(self,"Panel_rename")
    self.Panel_king = me.assignWidget(self,"Panel_king")
    self.Text_noKingName = me.assignWidget(self,"Text_noKingName")
    me.registGuiClickEvent(self.Panel_king,function ()
        local hire = kingdomView_officer_hire:create("kingdomView_officer_hire.csb")
        local tmpDef = cfg[CfgType.KINGDOM_OFFICER][me.toNum(1)]
        local tmpSer = user.kingdom_OfficerData.list["degree_"..1]
        hire:setData(tmpDef, tmpSer)
        pWorldMap.kmv:addChild(hire)
        me.showLayer(hire,"fixLayout")
    end)
    self.Panel_input = me.assignWidget(self.Panel_rename,"Panel_input")
    self.Text_rename_diamond = me.assignWidget(self.Panel_rename,"Text_rename_diamond")
    me.registGuiClickEvent(me.assignWidget(self.Panel_rename, "Button_cancel"),function ()
        self.Panel_rename:setVisible(false)
        self.Text_notice:setVisible(true)
    end)

    me.registGuiClickEvent(me.assignWidget(self.Panel_rename, "Button_comfirm"),function ()
        if self.eb:getText() and self.eb:getText() ~= "" then 
            local len = getStringLength(self.eb:getText())
            if len < 4 then 
                showTips("宣言不能少于4个字符","ff0000")
                return
            elseif len > 100 then 
                showTips("宣言不能多于100个字符","ff0000")
                return
            end
            local tmpPrice = me.toNum(cfg[CfgType.THRONE_DEF][1].changeNeed)
            if user.diamond < tmpPrice then 
                showTips("钻石不足","ff0000")
                return
            end
        else
            showTips("请输入修改的宣言","ff0000")
        end
        NetMan:send(_MSG.kingdom_change_motto(self.eb:getText()))
    end)

    me.registGuiClickEvent(me.assignWidget(self,"Button_rename"),function (node)
        self:setManifesto()
    end)
    return true
end

--设置宣言板
function kingdomView_officer:setManifesto()
    if user.kingdom_OfficerData.updateAble == true then
        self.Text_rename_diamond:setString("免费")
    else
        self.Text_rename_diamond:setString(me.toNum(cfg[CfgType.THRONE_DEF][1].changeNeed))
    end
    self.Panel_rename:setVisible(true)
    self.Text_notice:setVisible(false)
    if self.eb == nil then
        self.eb = me.addInputBox(self.Panel_input:getContentSize().width,self.Panel_input:getContentSize().height,18,nil,nil,cc.EDITBOX_INPUT_MODE_ANY,"在此输入宣言")
        self.eb:setMaxLength(100)
        self.eb:setAnchorPoint(0,0)
        self.eb:setPlaceholderFontColor(cc.c3b (88,89,93))
        self.eb:setFontColor(cc.c3b(214,202,177))
        self.Panel_input:addChild(self.eb)
    end
end
function kingdomView_officer:update(msg)
    if checkMsg(msg.t, MsgCode.KINGDOM_ADMIN_OFFICER) then
        if self.cellIdx then
            self.tableView:updateCellAtIndex(self.cellIdx)
        end

        self:setOfficerData()
        self:setTableView()
    elseif checkMsg(msg.t, MsgCode.KINGDOM_CHANGE_MOTTO) then
        if msg.c.result and msg.c.result == 1 then
            self.Panel_rename:setVisible(false)
            self.Text_notice:setVisible(true)
            if me.isValidStr(user.kingdom_OfficerData.kingWorlds) then
                self.Text_notice:setString(user.kingdom_OfficerData.kingWorlds)    
            else
                self.Text_notice:setString("暂无宣言")
            end
        end
    elseif checkMsg(msg.t, MsgCode.KINGDOM_TYPE_DETAIL) then
        self:setOfficerData()
        self:setTableView()
    end
end
function kingdomView_officer:setOfficerData()
    me.clearTimer(self.timer)
    if me.isValidStr(user.kingdom_OfficerData.kingWorlds) then
        self.Text_notice:setString(user.kingdom_OfficerData.kingWorlds)
    else
        self.Text_notice:setString("暂无宣言")
    end
    if user.kingdom_OfficerData.list["degree_"..1] then --有无国王
        self.Text_time:setVisible(true)
        self.Text_alliance:setString( "[".. user.kingdom_OfficerData.list["degree_"..1].shortName.."]")
        self.Text_kingName:setString(user.kingdom_OfficerData.list["degree_"..1].name)
        if user.kingdom_OfficerData.countDown then
            self.Text_time:setString("任期:"..me.formartSecTime(user.kingdom_OfficerData.countDown))
        end
        self.timer = me.registTimer(-1,function ()
            self.Text_time:setString("任期:"..me.formartSecTime(user.kingdom_OfficerData.countDown))
             user.kingdom_OfficerData.countDown = user.kingdom_OfficerData.countDown - 1
        end,1,"kingdomView_officer")
    else
        self.Text_kingName:setString("暂无国王")
        self.Text_time:setVisible(false)
    end
    self.Text_alliance:setVisible(user.kingdom_OfficerData.list["degree_"..1] ~= nil)
    self.Text_kingName:setVisible(user.kingdom_OfficerData.list["degree_"..1] ~= nil)
    self.Text_noKingName:setVisible(user.kingdom_OfficerData.list["degree_"..1] == nil)
end
function kingdomView_officer:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomView_officer")
    self:setOfficerData()
    self:setTableView()
end
function kingdomView_officer:onEnterTransitionDidFinish()
end
function kingdomView_officer:onExit()
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
    print("kingdomView_officer:onExit()")
end
function kingdomView_officer:setTableView()
    print("kingdomView_officer:setTableView()")
    local function tableCellTouched(table, cell)
        self.curId = cell:getTag()
        self.cellIdx = cell:getIdx()
        local tmpDef = user.kingdom_OfficerData.defs[me.toNum(self.curId)]
        --if tmpDef.id==1 then --国王不能进入操作界面
        --    return
        --end
        if self.preCell ~= nil then
            me.assignWidget(self.preCell,"Image_night"):setVisible(false)
        end
        self.preCell = cell
        me.assignWidget(self.preCell,"Image_night"):setVisible(true)
        local hire = kingdomView_officer_hire:create("kingdomView_officer_hire.csb")
        
        local tmpSer = user.kingdom_OfficerData.list["degree_"..self.curId]
        hire:setData(tmpDef, tmpSer)
        pWorldMap.kmv:addChild(hire)
        me.showLayer(hire,"bg")
    end

    local function cellSizeForTable(table, idx)
        return 645, 70
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local item =  me.createNode("Layer_KingdomOfficer_Item.csb")
        local ic = idx%2
        local id = idx+1
        local tmpDef = user.kingdom_OfficerData.defs[me.toNum(id)]
        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:setTag(id)
            local layer = me.assignWidget(item, "Panel_base"):clone()
            cell:addChild(layer)
            me.assignWidget(layer,"Image_night"):setVisible(id == self.curId)
        else
            cell:setTag(id)
            me.assignWidget(cell,"Image_night"):setVisible(id == self.curId)
        end

        if id == self.curId then
            self.preCell = cell
        end

        if tmpDef then
            --[[
            if tmpDef.id==1 then
                me.assignWidget(cell,"Image_arrow"):setVisible(false)
            else
                me.assignWidget(cell,"Image_arrow"):setVisible(true)
            end
            ]]
            me.assignWidget(cell,"Text_officer"):setString(tmpDef.name)
            local serData = user.kingdom_OfficerData.list["degree_"..id]
            me.assignWidget(cell,"Text_name"):setString("空缺")
            me.assignWidget(cell,"Text_fight"):setString("")
            me.assignWidget(cell,"Text_lv"):setString("")
            if serData then
                me.assignWidget(cell,"Text_name"):setString(serData.name)
                me.assignWidget(cell,"Text_fight"):setString(serData.fightPower)
                me.assignWidget(cell,"Text_lv"):setString(serData.wigth)
            end
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return #user.kingdom_OfficerData.defs
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(544,589))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(0, 0)
        self.tableView:setDelegate()
        self.Panel_table:addChild( self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end