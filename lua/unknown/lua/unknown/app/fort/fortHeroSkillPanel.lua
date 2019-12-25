 --[Comment]
--jnmo
fortHeroSkillPanel = class("fortHeroSkillPanel",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
fortHeroSkillPanel.__index = fortHeroSkillPanel
fortHeroSkillPanel.moveToUp = 1
fortHeroSkillPanel.moveToBottom = 0
fortHeroSkillPanel.moving = 2
function fortHeroSkillPanel:create(...)
    local layer = fortHeroSkillPanel.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function fortHeroSkillPanel:ctor()   
    print("fortHeroSkillPanel ctor") 
end
local boxnum = 3
function fortHeroSkillPanel:init()   
    print("fortHeroSkillPanel init")
    self.Button_left = me.assignWidget(self,"Button_left")
    self.Button_right = me.assignWidget(self,"Button_right")
    self.Panel_skillScoll = me.assignWidget(self,"Panel_skillScoll")
    self.Panel_heroSkill = me.assignWidget(self,"Panel_heroSkill")
    self.Node_skillSample = me.assignWidget(self, "Node_skillSample")
    self.Node_skillSample:setVisible(false)

    self.AnimStatus = fortHeroSkillPanel.moveToBottom
    self.tableWidth, self.cellSizeH, self.cellSizeW = 776, 130, 130
    self.skillTotalNum = 6
    self.timers = {}
    self.pCheckBox = { }
    self.skillType = 1    
    local function callback2_(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            if self.skillType ~= sender.id then
                self.skillType = sender.id
                self:initSkillList()            
                for var = 1, boxnum do
                    if var == sender.id then
                        self.pCheckBox[var]:setSelected(true)
                        self.pCheckBox[var]:setTouchEnabled(false)
                        me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c4b(0xe9, 0xdc, 0xaf, 0xff))
                    else
                        self.pCheckBox[var]:setSelected(false)
                        self.pCheckBox[var]:setTouchEnabled(true)
                        me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c4b(0x84, 0x7b, 0x6c, 0xff))
                    end
                    me.setWidgetCanTouchDelay(self.pCheckBox[var], 0.5)
                end
            else
                sender:setSelected(true)
            end
        else
            for var = 1, boxnum do
                if var == sender.id then
                    self.pCheckBox[var]:setSelected(true)
                    self.pCheckBox[var]:setTouchEnabled(false)
                    me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c4b(0xe9, 0xdc, 0xaf, 0xff))
                else
                    self.pCheckBox[var]:setSelected(false)
                    self.pCheckBox[var]:setTouchEnabled(true)
                    me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c4b(0x84, 0x7b, 0x6c, 0xff))
                end
            end
        end
    end
    for var = 1, boxnum do
        self.pCheckBox[var] = me.assignWidget(self, "cbox" .. var)
        self.pCheckBox[var]:addEventListener(callback2_)
        self.pCheckBox[var].id = var
        if self.skillType == self.pCheckBox[var].id then
            self.pCheckBox[var]:setSelected(true)
            self.pCheckBox[var]:setTouchEnabled(false)
        else
            self.pCheckBox[var]:setSelected(false)
            self.pCheckBox[var]:setTouchEnabled(true)
        end
    end 
    return true
end
function fortHeroSkillPanel:onEnter()
    print("fortHeroSkillPanel onEnter") 
    me.registGuiClickEvent(self.Button_left,function (node)
        self:scrollByButton(node)
    end)
    me.registGuiClickEvent(self.Button_right,function (node)
        self:scrollByButton(node)
    end)

    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_USE_SKILL) then
            self:initSkillList()            
        end
    end)
    self:initSkillList()            
end
function fortHeroSkillPanel:scrollByButton(btn)
    local pOffsize = self.tableView:getContentOffset()
    if btn == self.Button_left then
        pOffsize.x = pOffsize.x+self.cellSizeW
        if pOffsize.x >= 0 then
            pOffsize.x = 0
        end        
    elseif btn == self.Button_right then
        pOffsize.x = pOffsize.x-self.cellSizeW
        if pOffsize.x <= self.tableWidth - self.skillTotalNum*self.cellSizeW then
            pOffsize.x = self.tableWidth - self.skillTotalNum*self.cellSizeW
        end   
    end
    self.tableView:setContentOffset(pOffsize,true)
end
function fortHeroSkillPanel:openHeroSkillAnim()
    if self.AnimStatus == fortHeroSkillPanel.moveToBottom then
        self:setVisible(true)
        self.AnimStatus = fortHeroSkillPanel.moveToUp
        self:stopAllActions()
        local moveto = cc.MoveTo:create(0.2, cc.p(self.Panel_heroSkill:getPositionX(),0))   
        self.Panel_heroSkill:runAction(moveto)
    end
end
function fortHeroSkillPanel:closeHeroSkillAnim()
    if self.AnimStatus == fortHeroSkillPanel.moveToUp then
        self.AnimStatus = fortHeroSkillPanel.moving
        self.Panel_heroSkill:stopAllActions()
        local moveto = cc.MoveTo:create(0.1, cc.p(self.Panel_heroSkill:getPositionX(),-250))   
        local call = cc.CallFunc:create(function ()
            self.AnimStatus = fortHeroSkillPanel.moveToBottom
            self:close()
        end)
        local seq = cc.Sequence:create(moveto, call)
        self.Panel_heroSkill:runAction(seq)
    end
end
function fortHeroSkillPanel:setStar(pStarNum,pNode)
    if me.toNum(pStarNum) <= 0 then
        return
    end    
    for var = 1 ,me.toNum(pStarNum) do
        local star = ccui.ImageView:create("shengjiang_tubiao_xingxing_huang.png",me.localType)
        star:setPosition(cc.p(me.toNum(var-1) * 30,0))
        pNode:addChild(star)
    end
end
function fortHeroSkillPanel:onEnterTransitionDidFinish()
	print("fortHeroSkillPanel onEnterTransitionDidFinish") 
end
function fortHeroSkillPanel:onExit()
    UserModel:removeLisener(self.modelkey)
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
    end
    self.timers = nil
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        pWorldMap.Panel_heroSkill = nil
    elseif CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity.Panel_heroSkill = nil
    end
    print("fortHeroSkillPanel onExit")    
end
function fortHeroSkillPanel:close()
    self:removeFromParentAndCleanup(true)  
end
function fortHeroSkillPanel:setCellInfo(cell)
    local btn = me.assignWidget(cell,"Button_heroSkill")
        
    local data = nil
    if self.skillType == 1 then
        data = user.heroSkillList[btn:getTag()]
    elseif self.skillType == 2 then
        data = user.totemSkillList[btn:getTag()]
    elseif self.skillType == 3 then
        data = user.worldSkillList[btn:getTag()]
    end
    if data == nil then
        return 
    end
    
    local cd = 0
    if data.sysT and data.tm > 0 then
        local sysTime = math.floor(me.sysTime()/1000)-data.sysT
        cd = data.tm - sysTime
    end

    local skillDef = cfg[CfgType.HERO_SKILL][me.toNum(data.id)]
    me.assignWidget(cell,"Button_heroSkill"):loadTextureNormal(getHeroSkillIcon(skillDef.skillicon), me.plistType)
    me.assignWidget(cell,"Image_skillCD"):setVisible(cd > 0)
    me.assignWidget(cell,"Button_heroSkill"):ignoreContentAdaptWithSize(false)
    me.assignWidget(cell,"Button_heroSkill"):setContentSize(120, 120)

    if cd > 0 then
        me.assignWidget(cell,"Text_countDown"):setString(me.formartSecTime(cd))
        if self.timers["index_"..btn:getTag()] == nil then
            self.timers["index_"..btn:getTag()] = me.registTimer(-1,function ()
                if cd <=0 then
                    cd = 0
                    me.clearTimer(self.timers["index_"..btn:getTag()])
                    me.assignWidget(cell,"Image_skillCD"):setVisible(cd > 0)
                end
                me.assignWidget(cell,"Text_countDown"):setString(me.formartSecTime(cd))
                cd = cd-1
            end,1)
        end
    end
    me.assignWidget(cell,"Panel_stars"):removeAllChildren()
    setHeroSkillStars(me.assignWidget(cell,"Panel_stars"), skillDef.star)
end
function fortHeroSkillPanel:initSkillList()
--    dump(user.heroSkillList)
    self.skilldatas = nil
    if self.skillType == 1 then
        if #user.heroSkillList > self.skillTotalNum then
            self.skillTotalNum = #user.heroSkillList
        end
        self.skilldatas = user.heroSkillList
    elseif self.skillType == 2 then
        if #user.totemSkillList  > self.skillTotalNum then
            self.skillTotalNum = #user.totemSkillList
        end
        self.skilldatas = user.totemSkillList
    elseif self.skillType == 3 then
        if #user.worldSkillList  > self.skillTotalNum then
            self.skillTotalNum = #user.worldSkillList
        end
        self.skilldatas = user.worldSkillList
    end
    local function cellSizeForTable(table, idx)
        return self.cellSizeW, self.cellSizeH
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local pSingleCell = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            pSingleCell = me.assignWidget(self.Node_skillSample, "Panel_skillSample"):clone()
            pSingleCell:setVisible(true)
            local Button_heroSkill = me.assignWidget(pSingleCell,"Button_heroSkill")
            Button_heroSkill:setSwallowTouches(false)
            me.registGuiClickEvent(Button_heroSkill, function(node)
                if  self.skilldatas[node:getTag()] then
                    local fhu = fortHeroUseSkillView:create("Layer_HeroUseSkillView.csb")
                    fhu:setData(self.skilldatas[node:getTag()])
                    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                        pWorldMap:addChild(fhu)
                    elseif CUR_GAME_STATE == GAME_STATE_CITY then
                        mainCity:addChild(fhu)
                    end
                end
            end)
            
            cell:addChild(pSingleCell)
            pSingleCell:setSwallowTouches(false)
            pSingleCell:setAnchorPoint(cc.p(0.5,0.5))
            pSingleCell:setPosition(self.cellSizeW / 2, self.cellSizeH / 2)
        else
            pSingleCell = cell:getChildByName("Panel_skillSample")
            local btn = me.assignWidget(cell,"Button_heroSkill")
            if self.timers["index_"..btn:getTag()] ~= nil then
                me.clearTimer(self.timers["index_"..btn:getTag()])
                self.timers["index_"..btn:getTag()] = nil
            end

        end
        me.assignWidget(pSingleCell,"Button_heroSkill"):setTag(idx + 1)
        me.assignWidget(pSingleCell,"Panel_locked"):setVisible(self.skilldatas[idx + 1] == nil)
        me.assignWidget(pSingleCell,"Panel_unlocked"):setVisible(self.skilldatas[idx + 1] ~= nil)
        me.assignWidget(pSingleCell,"Panel_unlocked"):setSwallowTouches(false)
        self:setCellInfo(pSingleCell)
        return cell
    end

    function numberOfCellsInTableView(table)
        return self.skillTotalNum
    end
    
    function scrollViewDidScroll(table)
        local pOffest = table:getContentOffset()
        me.buttonState(self.Button_left,pOffest.x < 0)
        if self.skillTotalNum*self.cellSizeW < self.tableWidth or pOffest.x <= self.tableWidth - self.skillTotalNum*self.cellSizeW then
            me.buttonState(self.Button_right,false)
        else
            me.buttonState(self.Button_right,true)
        end
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(self.tableWidth, self.cellSizeH))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self.tableView:setPosition(0, 0)
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        self.Panel_skillScoll:addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    local offPos = self.tableView:getContentOffset()
    self.tableView:reloadData()
    if offPos then
        self.tableView:setContentOffset(cc.p(offPos.x,0))
    end
end