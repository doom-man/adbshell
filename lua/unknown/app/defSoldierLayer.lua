-- [Comment]
-- jnmo
defSoldierLayer = class("defSoldierLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
defSoldierLayer.__index = defSoldierLayer
function defSoldierLayer:create(...)
    local layer = defSoldierLayer.new(...)
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
function defSoldierLayer:ctor()
    print("defSoldierLayer ctor")
end
function defSoldierLayer:init()
    print("defSoldierLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_Setting", function(node)
        if user.guard_patrol_status==1 then
            showTips("部队正巡逻中")
            return
        end
        local choose = defSoldierChoose:create("defSoldierChoose.csb")
        choose:setData(self.data)
        choose:setMaxTroopsNums(self.maxTroopsNum)
		choose:initList()
        me.popLayer(choose)
    end )
    self.Button_Tech = me.registGuiClickEventByName(self, "Button_Tech", function(node)
        me.assignWidget(self.Button_Tech,"redpoint"):setVisible(false)
        local tech = defSoldierTechLayer:create("defSoldierTechLayer.csb")
        me.popLayer(tech)
        NetMan:send(_MSG.guard_tech_init())
    end )
    me.registGuiClickEventByName(self, "Button_Patrol", function(node)
        local patrol = defSoldierPatrol:create("defSoldierPatrol.csb")
        me.popLayer(patrol)
        NetMan:send(_MSG.guard_patrol_init())
    end )
    me.registGuiClickEventByName(self, "Button_Help", function(node)
        local help = defSoldierHelp:create("defSoldierHelp.csb")
        me.popLayer(help)
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_GUARD_ARMY_INIT) then
            self.patrolStatus = msg.c.status
            self.data = msg.c
            if msg.c.list then
                self:setCellsView(msg.c.list)
            end
            if msg.c.army then
                self.maxTroopsNum = msg.c.max
                self:setSoldierCellsView(msg.c.army)
            end
            self:checkTechRedPoint()
        end
    end )
    self.ListView_cells = me.assignWidget(self, "ListView_cells")
    self.viewData = { }
    for key, var in pairs(cfg[CfgType.LORD_INFO]) do
        self.viewData[var.key] = var
    end
    self.Text_NON = me.assignWidget(self,"Text_NON")
    self.Text_Max = me.assignWidget(self,"Text_Max")
    self.wlist = me.assignWidget(self,"list")

    return true
end
function defSoldierLayer:checkTechRedPoint()
    if self.data.red then   
        me.assignWidget(self.Button_Tech,"redpoint"):setVisible(true)
    else
        me.assignWidget(self.Button_Tech,"redpoint"):setVisible(false)
    end
end
function defSoldierLayer:setCellsView(data)
    self.ListView_cells:removeAllChildren()
    if #data==0 then
        me.assignWidget(self,"Text_NON_0"):setVisible(true)
    else
        me.assignWidget(self,"Text_NON_0"):setVisible(false)
    end
    local index = 1
    for inKey, inVar in pairs(data) do
        local contentCell = cc.CSLoader:createNode("overlordItemView.csb")
        local cItem = me.assignWidget(contentCell, "ImageView_Bg"):clone()
        local techdata = self.viewData[inVar.name]
        local Text_itemName = me.assignWidget(cItem, "Text_itemName")
        local Text_itemNum = me.assignWidget(cItem, "Text_itemNum")
        Text_itemName:setVisible(true)
        Text_itemNum:setVisible(true)
        if inVar.type==1 then
            Text_itemName:setString("禁卫军" .. techdata.name)
        else
            Text_itemName:setString(techdata.name)
        end
        if tonumber(techdata.isPercent) == 1 then
            Text_itemNum:setString(inVar.value * 100 .. "%")
        else
            Text_itemNum:setString(inVar.value)
        end
        self.ListView_cells:pushBackCustomItem(cItem)
        index = index + 1
        local itemPng = "ui_ty_cell_bg.png"
        if index % 2 == 0 then
            itemPng = "alliance_alpha_bg.png"
        end
        me.assignWidget(cItem, "ImageView_Bg"):loadTexture(itemPng, me.localType)
    end
end
function defSoldierLayer:setSoldierCellsView(data)
    self.Text_NON:setVisible( table.nums(data) == 0)
    self.wlist:removeAllChildren()
    local width_list = 634
    local height_list = 531
    local spw = 3
    local sph = 6
    local index = 0
    local h = 0
    local m = 3
    -- 一行3个
    local globalItems = me.createNode("Node_soldierItem.csb")
    globalItems:retain()    
    
    local num = #data
    user.guardSoldier = {}
    local sum = 0
    for key, var in pairs(data) do
            local sdata = soldierData.new(tonumber(var[1]),tonumber(var[2]))
            user.guardSoldier[tonumber(var[1])] = sdata
            local def = sdata:getDef()
            item = me.assignWidget(globalItems, "soldierItem_guard"):clone()
            item:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
            me.assignWidget(item, "Text_name"):setString(def.name)
            me.assignWidget(item, "Text_num"):setString(var[2])
            me.assignWidget(item, "Text_type"):setString(soldierType[me.toStr(def.smallType)])
            me.assignWidget(item, "Text_type"):enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(1, -1)) 
            me.assignWidget(item, "item_icon"):loadTexture(soldierIcon(def), me.plistType)
            self.wlist:addChild(item)
            if user.guard_patrol_status==1 then
                me.Helper:grayImageView(item)
            else
                me.Helper:normalImageView(item)
            end
            local iSize = item:getContentSize()
            local i = 0
            if num % m ~= 0 then
                i = 1
            end
            sum = sum + tonumber(var[2])
            local height =(math.floor(num / m) + i) *(iSize.height + sph)
            if height < height_list then
                height = height_list
            end
            item:setPosition((iSize.width + spw) *(index % m + 1) - iSize.width / 2,
            height - math.floor(index / m) *(iSize.height + sph) - iSize.height / 2 - sph)
            index = index + 1
            self.wlist:setInnerContainerSize(cc.size(width_list, height))          
    end
    globalItems:release()
    self.Text_Max:setString("入驻上限:".. sum.."/"..self.maxTroopsNum)
end
function defSoldierLayer:onEnter()
    print("defSoldierLayer onEnter")
    me.doLayout(self, me.winSize)
end
function defSoldierLayer:onEnterTransitionDidFinish()
    print("defSoldierLayer onEnterTransitionDidFinish")
end
function defSoldierLayer:onExit()
    print("defSoldierLayer onExit")
    UserModel:removeLisener(self.modelkey)
end
function defSoldierLayer:close()
    self:removeFromParent()
end


