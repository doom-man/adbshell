armyView = class("armyView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
armyView.__index = armyView
function armyView:create(...)
    local layer = armyView.new(...)
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
function armyView:ctor()
    self.soldierData = {}
    self.schid = nil
    self.pCheckBox = {}
end
function armyView:init()
    self.Text_soldierNum = me.assignWidget(self, "Text_soldierNum")
    self.Text_trapNum = me.assignWidget(self, "Text_trapNum")
    self.Text_armyNum = me.assignWidget(self, "Text_armyNum")
    self.Text_revertNum = me.assignWidget(self, "Text_revertNum")
    self.ScrollView_cell_1 = me.assignWidget(self,"ScrollView_cell_1")
    self.Button_add = me.assignWidget(self,"Button_add")
    self.ScrollView_cell_2 = me.assignWidget(self,"ScrollView_cell_2")
    self.Image_bar_1 = me.assignWidget(self,"Image_bar_1")
    self.Image_bar_2 = me.assignWidget(self,"Image_bar_2")
    self.Text_soldierNum_out = me.assignWidget(self,"Text_soldierNum_out")
    self.Text_revertNum_out = me.assignWidget(self,"Text_revertNum_out")
    self.Text_normal = me.assignWidget(self,"Text_normal")
    self.Text_wonder = me.assignWidget(self,"Text_wonder")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEvent(self.Button_add, function(node)
        local getWayView = troopsNumsGetWayView:create("build/troopsNumsGetWayView.csb")
        me.runningScene():addChild(getWayView, me.MAXZORDER)
        me.showLayer(getWayView,"bg")
        getWayView:setData()
    end )

    local boxnum = 2
    local function callback2_(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            self.armytype = sender.id
            self:updateType()
            for var = 1, boxnum do
                if var == sender.id then
                    self.pCheckBox[var]:setSelected(true)
                    self.pCheckBox[var]:setTouchEnabled(false)
                    me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(false and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))   
                    me.assignWidget(self.pCheckBox[var], "Text_title"):enableShadow(false and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(-2, -2))
                else
                    self.pCheckBox[var]:setSelected(false)
                    self.pCheckBox[var]:setTouchEnabled(true)
                    me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(true and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))   
                    me.assignWidget(self.pCheckBox[var], "Text_title"):enableShadow(true and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(-2, -2))
                end
                me.setWidgetCanTouchDelay(self.pCheckBox[var], 0.5)
            end
        end
    end
    self.armytype = 1
    for var = 1, boxnum do
        self.pCheckBox[var] = me.assignWidget(self, "cbox" .. var)
        self.pCheckBox[var]:addEventListener(callback2_)
        self.pCheckBox[var].id = var
        if self.armytype == self.pCheckBox[var].id then
            self.pCheckBox[var]:setSelected(true)
            self.pCheckBox[var]:setTouchEnabled(false)
            me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(false and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))   
            me.assignWidget(self.pCheckBox[var], "Text_title"):enableShadow(false and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(-2, -2))
        else
            self.pCheckBox[var]:setSelected(false)
            self.pCheckBox[var]:setTouchEnabled(true)
            me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(true and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))   
            me.assignWidget(self.pCheckBox[var], "Text_title"):enableShadow(true and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(-2, -2))
        end
    end
    self:updateType()
    return true
end
function armyView:updateType()
    if self.armytype == 1 then
        self.ScrollView_cell_1:setVisible(true) 
        self.ScrollView_cell_2:setVisible(false) 
        self.Image_bar_1:setVisible(true) 
        self.Image_bar_2:setVisible(false) 
        self.Text_normal:setVisible(false)
        self.Text_wonder:setVisible(false)
    elseif self.armytype == 2 then
        self.ScrollView_cell_1:setVisible(false) 
        self.ScrollView_cell_2:setVisible(true)
        self.Image_bar_1:setVisible(false) 
        self.Image_bar_2:setVisible(true) 
        self.Text_normal:setVisible(false)
        self.Text_wonder:setVisible(false)
    end
end
function armyView:initData()
    local tmpData = armyData.sortSoldierData()
    self.soldierData = {}
    for key, var in pairs(tmpData) do
        table.insert(self.soldierData,#self.soldierData+1,var)        
    end
    self.Text_soldierNum:setString(armyData.soliderNum)
    self.Text_trapNum:setString(armyData.atkTrap.."/"..armyData.totalAtkTrap)
    self.Text_armyNum:setString(armyData.totalToops-armyData.toops.."/"..armyData.totalToops)
    self.Button_add:setPositionX(self.Text_armyNum:getPositionX()+self.Text_armyNum:getContentSize().width+2)
    self.Text_revertNum:setString("未建修道院")    
    self.Text_soldierNum_out:setString(armyData.outArmyNum)
    self.Text_revertNum_out:setString(armyData.outDisableNum)
    self.Text_normal:setString("普通兵上限："..armyData.curNormal .."/".. armyData.normalMax)
    self.Text_wonder:setString("奇迹兵上限："..armyData.curWonder .."/".. armyData.wonderMax)
    for key, var in pairs(user.building) do
        if var:getDef().type == cfg.BUILDING_TYPE_ABBEY then
            self.Text_revertNum:setString(armyData.desableSoliderNum.."/"..armyData.totalDesableSoliderNum)
            break
        end
    end
end
function armyView:initCellViews(b)
    local cellH = 365
    local iNum = table.nums(self.soldierData)
    if user.guardSoldier then 
       iNum = iNum + 1 
    end
    self.ScrollView_cell_1:setInnerContainerSize(cc.size(1170,cellH*iNum))
    self.ScrollView_cell_1:removeAllChildren()
    for i = 1, iNum do
        local item = armyCellView:create("armyCellView.csb")
        if i < iNum then 
            item:initWithData(self.soldierData[i])
        else
            item:initWithData(user.guardSoldier,true )
        end
        if self.ScrollView_cell_1:getContentSize().height < self.ScrollView_cell_1:getInnerContainerSize().height then
            item:setPosition(0, cellH*(iNum-i))
        else
            item:setPosition(0, self.ScrollView_cell_1:getContentSize().height-cellH*i)
        end
        self.ScrollView_cell_1:addChild(item)
        if b then
             coroutine.yield()
        end
    end
    iNum = table.nums(user.soldierOut) 
    self.ScrollView_cell_2:setInnerContainerSize(cc.size(1170,cellH*iNum))
    self.ScrollView_cell_2:removeAllChildren()
    for i = 1, iNum do
        local item = armyCellOut:create("armyCellView_Out.csb")    
        item:initWithData(user.soldierOut[i])   
        if self.ScrollView_cell_2:getContentSize().height < self.ScrollView_cell_2:getInnerContainerSize().height then
            item:setPosition(0, cellH*(iNum-i))
        else
            item:setPosition(0, self.ScrollView_cell_2:getContentSize().height-cellH*i)
        end
        self.ScrollView_cell_2:addChild(item)
        if b then
             coroutine.yield()
        end
    end
end
function armyView:onEnter()
    print("armyView:onEnter()")
    self:initData()
    self.cthread = coroutine.create(function ()
            self:initCellViews(true)
       end)
    self.schid = me.coroStart(self.cthread)
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.CITY_SOLDIER_UPDATE) then
             self:initData()
             self:initCellViews()
        end
    end )

    self.worldmapJumpTechviewListener = me.RegistCustomEvent("WORLDMAP_JUMP_TECHVIEW", handler(self, self.close))
end
function armyView:onExit()
    print("armyView:onExit()")
    UserModel:removeLisener(self.modelkey)
    me.RemoveCustomEvent(self.worldmapJumpTechviewListener)
end
function armyView:close()
    print("armyView:close()")
    me.coroClear(self.schid)
    self:removeFromParentAndCleanup(true)
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity.armyView = nil
    else
        pWorldMap.armyView = nil
    end
end