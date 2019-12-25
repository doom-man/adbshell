kingdomView_officer_hire = class("kingdomView_officer_hire", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )

kingdomView_officer_hire.__index = kingdomView_officer_hire
kingdomView_officer_hire.status_check = 0
kingdomView_officer_hire.status_hire = 1
function kingdomView_officer_hire:create(...)
    local layer = kingdomView_officer_hire.new(...)
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
function kingdomView_officer_hire:ctor()
    print("kingdomView_officer_hire:ctor()")
end
function kingdomView_officer_hire:init()
    print("kingdomView_officer_hire:init()")
    self.degree = nil
    self.Text_title = me.assignWidget(self,"Text_title")
    self.Text_property_1 = me.assignWidget(self,"Text_property_1")
    self.Text_property_2 = me.assignWidget(self,"Text_property_2")
    self.Text_property_3 = me.assignWidget(self,"Text_property_3")
    self.Text_propertys = {}
    self.Text_propertys[#self.Text_propertys+1] = self.Text_property_1
    self.Text_propertys[#self.Text_propertys+1] = self.Text_property_2
    self.Text_propertys[#self.Text_propertys+1] = self.Text_property_3
    self.Text_diamond = me.assignWidget(self,"Text_diamond")
    self.Panel_diamod = me.assignWidget(self,"Panel_diamod")
    self.Button_right = me.assignWidget(self,"Button_right")
    self.Panel_property = me.assignWidget(self,"Panel_property")
    self.Button_left = me.assignWidget(self,"Button_left")
    self.Image_input = me.assignWidget(self,"Image_input")
    self.Text_aotuCD = me.assignWidget(self,"Text_aotuCD")
    self.Text_aotuCD:setVisible(false)
    self.Button_alliance = me.assignWidget(self,"Button_alliance")
    self.Button_left_comfire = me.assignWidget(self,"Button_left_comfire")
    self.Button_right_cancel = me.assignWidget(self,"Button_right_cancel")

    me.registGuiClickEvent(self.Button_alliance,function ()
        if self.defData.id == 1 then --没有国王
            if user.kingdom_OfficerData.kingId==nil and user.kingdom_OfficerData.identity==false then  --盟主可以任命国王
                showTips("只有获胜的盟主可以任命国王")
                return
            elseif user.kingdom_OfficerData.kingId ~= nil then
                showTips("国王已存在")
                return
            end
        elseif user.kingdom_OfficerData.kingId ~= user.uid then
            showTips("只有国王可以任命官员")
            return
        end

        NetMan:send(_MSG.getListMember())
    end)
    me.registGuiClickEvent(self.Button_left,function ()
        if me.isValidStr(self.msgEb:getText()) then
            NetMan:send(_MSG.kingdom_name_check(self.msgEb:getText(),self.degree))
        else
            showTips("请选择官员")
        end
    end)
    me.registGuiClickEvent(self.Button_right,function () --解任
        if me.isValidStr(self.msgEb:getText()) and self.degree then
            NetMan:send(_MSG.kingdom_admin_officer(self.msgEb:getText(),self.degree,2))
        end
    end)
    me.registGuiClickEvent(self.Button_left_comfire,function ()--任命
        if me.isValidStr(self.msgEb:getText()) and self.degree then
            me.buttonState(self.Button_left_comfire,false)
            NetMan:send(_MSG.kingdom_admin_officer(self.msgEb:getText(),self.degree,1))
            if self.btnAutoTimer == nil then
                self.btnAutoTimer = me.registTimer(-1,function ()
                    me.clearTimer(self.btnAutoTimer)
                    self.btnAutoTimer = nil
                    me.buttonState(self.Button_left_comfire,true)
                end,2)
            end
        else
            showTips("请选择官员")
        end
    end)
    me.registGuiClickEvent(self.Button_right_cancel,function ()
        self:setStatus(kingdomView_officer_hire.status_check)
    end)

    me.registGuiClickEvent(me.assignWidget(self,"close"),function (node)
        self:close()
    end)

    local function msgEbCallFunc(eventType,sender)
       if eventType == "return" then 
            me.buttonState(self.Button_left_comfire,me.isValidStr(self.msgEb:getText()))
       end
    end
    self.msgEb = me.addInputBox(self.Image_input:getContentSize().width, self.Image_input:getContentSize().height, 22,nil,msgEbCallFunc,cc.EDITBOX_INPUT_MODE_ANY,"请输入名字")
    self.msgEb:setFontColor(cc.c3b(236,194,126))
    self.msgEb:setMaxLength(15)
    self.msgEb:setAnchorPoint(0,0)
    self.Image_input:addChild(self.msgEb)
    self.msgEb:setVisible(false)
    return true
end
function kingdomView_officer_hire:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) then
        me.tableClear(self.memberList)
        self.memberList = {}
        for key, var in pairs(msg.c.list) do
            if self.defData.id ~= 1 then
                if me.toNum(user.uid) ~= me.toNum(var.uid) then --非国王
                    self.memberList[#self.memberList+1]  = {["uid"] = var.uid,["name"] = var.name}
                end
            else
                self.memberList[#self.memberList+1]  = {["uid"] = var.uid,["name"] = var.name}
            end
        end
        self:openFamilyList()
    elseif checkMsg(msg.t, MsgCode.KINGDOM_ADMIN_OFFICER) then --任命/解任
        disWaitLayer()
        self:close()
    elseif checkMsg(msg.t, MsgCode.KINGDOM_NAME_CHECK) then --名字检测
        if msg.c==nil then
            self:showPrompt(self.msgEb:getText(), self.defData.name)
        end
    end
end
function kingdomView_officer_hire:openFamilyList()
    if self.layout == nil then
        self.layout = ccui.Layout:create() 
        self.layout:setContentSize(cc.size(me.winSize.width,me.winSize.height))
        self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        self.layout:setBackGroundColor(cc.c3b(0,0,0))
        self.layout:setBackGroundColorOpacity(165)
        self.layout:setAnchorPoint(cc.p(0,0))
        self.layout:setPosition(cc.p(0,0))
        self.layout:setSwallowTouches(true)  
        self.layout:setTouchEnabled(true)
        self:addChild(self.layout,me.MAXZORDER)
    end
    local list = me.assignWidget(self, "Panel_list"):clone()
    self.layout:addChild(list,me.MAXZORDER)
    list:setVisible(true)
    list:setAnchorPoint(cc.p(0.5,0.5))
    list:setPosition(cc.p(me.winSize.width/2,me.winSize.height/2))

    local function closeList()
        self.tableView:removeFromParent()
        self.tableView= nil
        self.layout:removeFromParent()
        self.layout = nil
    end
    me.registGuiClickEvent(me.assignWidget(list,"close_0"),function (node)
        closeList()
    end)

    me.registGuiTouchEvent(self.layout,function (node,event)
        if event ~= ccui.TouchEventType.ended then
            return
        end 
        closeList()
    end)

   local function cellSizeForTable(table, idx)
        return 431, 75
    end
    function numberOfCellsInTableView(table)
        return #self.memberList
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item = me.assignWidget(self,"Panel_cell"):clone()
            item:setVisible(true)
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            cell:addChild(item)  
        end
        if self.memberList[idx+1] then
            me.assignWidget(cell,"Text_cell_name"):setString(self.memberList[idx+1].name)
        else
            __G__TRACKBACK__("idx = "..idx .." is  nil !!!! ")
        end
        
        return cell
    end
    local function tableCellTouched(table, cell)    
        local data = self.memberList[cell:getIdx()+1]
        self.officerName = data.name
        self.msgEb:setText(self.officerName)
        me.buttonState(self.Button_left_comfire,true)
        me.DelayRun(function ()
            self.tableView:removeFromParent()
            self.tableView= nil
            self.layout:removeFromParent()
            self.layout = nil
        end,0.1)
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(431,489))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(1,0)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        me.assignWidget(self.layout,"Panel_table"):addChild(self.tableView)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end
function kingdomView_officer_hire:setData(defData, serData)
    self.defData, self.serData = defData, serData
end
function kingdomView_officer_hire:onEnter()
    me.doLayout(self,me.winSize)  
    print("kingdomView_officer_hire:onEnter()")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomView_officer_hire")
    self:setStatus(kingdomView_officer_hire.status_check)    
end
function kingdomView_officer_hire:setTableProperty()
    local function cellSizeForTable(table, idx)
        return 777, 36
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local buffid = self.buffIds[idx+1]
        local tmpDef = cfg[CfgType.KINGDOM_BUFF][me.toNum(buffid)]
        if nil == cell then
            cell = cc.TableViewCell:new()
            local layer = me.assignWidget(self,"Panel_cell_property"):clone()
            cell:addChild(layer)
            layer:setPosition(cc.p(0,0))
            layer:setVisible(true)
            me.assignWidget(layer,"Text_property"):setString(tmpDef.desc)
        else
            me.assignWidget(cell,"Text_property"):setString(tmpDef.desc)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return #self.buffIds
    end

    self.tableView_Property = cc.TableView:create(cc.size(self.Panel_property:getContentSize().width,self.Panel_property:getContentSize().height))
    self.tableView_Property:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView_Property:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView_Property:setPosition(0, 0)
    self.tableView_Property:setDelegate()
    self.Panel_property:addChild(self.tableView_Property)
    self.tableView_Property:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView_Property:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView_Property:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView_Property:reloadData()
end
function kingdomView_officer_hire:setStatus(status)
    self.Text_diamond:setString(me.toNum(cfg[CfgType.THRONE_DEF][1].appointmentNeed))
    self.Text_title:setString("")
    self.degree = self.defData.id
    
    if self.defData then
        self.buffIds = me.split(self.defData.buffId,",")
        self.Text_title:setString(self.defData.name)
        self:setTableProperty()
    end

    self.Panel_diamod:setVisible(false)
    self.msgEb:setTouchEnabled(false)
    --[[
    if self.serData and self.serData.degree == 1 and (user.kingdom_OfficerData.identity == false or me.isValidStr(self.serData.name)) then --非盟主 点开任命国王 或国王已经有人当选 特殊处理
        me.buttonState(self.Button_left,false)
        self.Button_alliance:setVisible(false)
    elseif user.kingdom_OfficerData.kingId == user.uid then
        me.buttonState(self.Button_left,true)
        self.Button_alliance:setVisible(true)
    else
        me.buttonState(self.Button_left,false)
        self.Button_alliance:setVisible(false)
    end
    ]]
    if self.serData then
        self.msgEb:setText(self.serData.name)
        self.msgEb:setVisible(true)
        self.msgEb:setTouchEnabled(true)
    end            

    if self.defData.id == 1 and user.kingdom_OfficerData.kingId==nil then --没有国王
        self.Text_aotuCD:setVisible(true)
        if self.timer == nil and me.isValidStr(user.kingdom_OfficerData.autoCountDown) then
            self.Text_aotuCD:setString("自动任命盟主:"..me.formartSecTime(user.kingdom_OfficerData.autoCountDown))
            self.timer = me.registTimer(-1,function ()
                self.Text_aotuCD:setString("自动任命盟主:"..me.formartSecTime(user.kingdom_OfficerData.autoCountDown))
                user.kingdom_OfficerData.autoCountDown = user.kingdom_OfficerData.autoCountDown - 1
            end,1,"kingdomView_officer_hire")
        end
        if user.kingdom_OfficerData.identity==true then  --盟主可以任命国王
            me.buttonState(self.Button_left,true)
            self.msgEb:setVisible(true)
            self.msgEb:setTouchEnabled(true)
        end
    else
        if user.kingdom_OfficerData.kingId ~= user.uid or self.serData then --不是国王 或者已设置官员
            me.buttonState(self.Button_left,false)
        elseif user.kingdom_OfficerData.kingId == user.uid then
            me.buttonState(self.Button_left,true)
            self.msgEb:setVisible(true)
            self.msgEb:setTouchEnabled(true)
        end
    end

    --[[
    self.msgEb:setText("")
    self.msgEb:setVisible(true)
    if user.kingdom_OfficerData.kingId ~= user.uid then
        me.buttonState(self.Button_left, true)
        self.Button_alliance:setVisible(true)
        self.msgEb:setTouchEnabled(true)
        if self.serData then
            self.msgEb:setText(self.serData.name)
        end
        return
    else
        me.buttonState(self.Button_left, false)
        self.Button_alliance:setVisible(false)
        self.msgEb:setVisible(false)
        return
    end
    ]]
    --[[
    local function switchBtns()
        if self.serData and self.serData.degree == 1 and (user.kingdom_OfficerData.identity == false or me.isValidStr(self.serData.name)) then --非盟主 点开任命国王 或国王已经有人当选 特殊处理
            self.Button_left:setVisible(true)
            self.Button_right:setVisible(true)
            me.buttonState(self.Button_left,false)
            me.buttonState(self.Button_right,false)
            self.Button_left_comfire:setVisible(false)
            self.Button_right_cancel:setVisible(false)
            self.Button_alliance:setVisible(false)
        else
            self.Button_left:setVisible(status == kingdomView_officer_hire.status_check)
            self.Button_right:setVisible(status == kingdomView_officer_hire.status_check)
            self.Button_left_comfire:setVisible(status ~= kingdomView_officer_hire.status_check)
            self.Button_right_cancel:setVisible(status ~= kingdomView_officer_hire.status_check)
            self.Button_alliance:setVisible(status ~= kingdomView_officer_hire.status_check)            
        end
        local tmp = self.msgEb:getText()
        me.buttonState(self.Button_left_comfire,me.isValidStr(tmp))
    end

    if status == kingdomView_officer_hire.status_check then
        self.Panel_diamod:setVisible(false)
        self.msgEb:setTouchEnabled(false)
        switchBtns(status)
        if self.serData then
            self.msgEb:setText(self.serData.name)
            self.msgEb:setVisible(true)
            me.buttonState(self.Button_left,false)
            if self.serData.degree == 1 and (user.kingdom_OfficerData.identity == false or me.isValidStr(self.serData.name)) then
                me.buttonState(self.Button_right,false)
            else
                me.buttonState(self.Button_right,user.kingdom_OfficerData.kingId == user.uid)
            end
        else            
            self.Text_aotuCD:setVisible(self.defData.id == 1)
            self.Panel_diamod:setVisible(self.defData.id ~= 1)
            if self.timer == nil and me.isValidStr(user.kingdom_OfficerData.autoCountDown) then
                self.Text_aotuCD:setString("自动任命盟主:"..me.formartSecTime(user.kingdom_OfficerData.autoCountDown))
                self.timer = me.registTimer(-1,function ()
                    self.Text_aotuCD:setString("自动任命盟主:"..me.formartSecTime(user.kingdom_OfficerData.autoCountDown))
                    user.kingdom_OfficerData.autoCountDown = user.kingdom_OfficerData.autoCountDown - 1
                end,1,"kingdomView_officer_hire")
            end
            self.msgEb:setVisible(false)
            self.msgEb:setText("")
            if self.defData.id == 1 then
                me.buttonState(self.Button_left,user.kingdom_OfficerData.identity)
                me.buttonState(self.Button_right,false)
            else
                me.buttonState(self.Button_left,user.kingdom_OfficerData.kingId == user.uid)
                me.buttonState(self.Button_right,false)
            end
        end
    elseif status == kingdomView_officer_hire.status_hire then
        self.Panel_diamod:setVisible(true)
        self.Text_aotuCD:setVisible(false)
        switchBtns(status)
        self.msgEb:setText("")
        self.msgEb:setVisible(true)
        self.msgEb:setTouchEnabled(true)
        if self.serData then
            self.msgEb:setText(self.serData.name)
        end
    end
    ]]
end

function kingdomView_officer_hire:showPrompt(name, degree)
    local function continue(str)
        if str=="ok" then
            NetMan:send(_MSG.kingdom_admin_officer(self.msgEb:getText(),self.degree,1))
            showWaitLayer()
        end
    end
    local box = MessageBox:create("MessageBox.csb")
    local str="<txt0018,D4CDB9>将玩家&<txt0018,00FF00>"..name.."&<txt0018,D4CDB9>任命为&<txt0018,00FF00>"..degree.."&<txt0018,D4CDB9>，任命成功后本次活动期间不可修改，是否确认任命？&"
    local richTxt = mRichText:create(str, 539)
    richTxt:setPosition(40, 232)
    me.assignWidget(box,"msgBox"):addChild(richTxt)
    me.assignWidget(box, "msg"):setVisible(false)
    box:register(continue)
    box:setButtonMode(nil)
    cc.Director:getInstance():getRunningScene():addChild(box, MESSAGE_ORDER)
    me.showLayer(box, "msgBox")

end

function kingdomView_officer_hire:onEnterTransitionDidFinish()
    print("kingdomView_officer_hire:onEnterTransitionDidFinish()")
end
function kingdomView_officer_hire:onExit()
    me.clearTimer(self.timer)
    me.clearTimer(self.btnAutoTimer)
    print("kingdomView_officer_hire:onExit()")
end
function kingdomView_officer_hire:close()
    UserModel:removeLisener(self.modelkey)
    self:removeFromParentAndCleanup(true)
end