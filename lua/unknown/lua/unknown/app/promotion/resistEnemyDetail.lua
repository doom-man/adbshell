resistEnemyDetail = class("resistEnemyDetail", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
resistEnemyDetail.__index = resistEnemyDetail
function resistEnemyDetail:create(...)
    local layer = resistEnemyDetail.new(...)
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
function resistEnemyDetail:ctor()
    self.soldierData = {}
    self.schid = nil
end
function resistEnemyDetail:init()

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end
function resistEnemyDetail:initData(data)
    me.assignWidget(self, "Text_Title"):setString(data.name)
    self.soldierData = data.army
    local count=0
    local cellPanel = me.assignWidget(self, "cellpanel")
    local listview = me.assignWidget(cellPanel, "ListView1")
    listview:removeAllItems()
    for key, var in pairs(data.army) do
        count=count+var[2]      

        local soldierData =  cfg[CfgType.CFG_SOLDIER][var[1]]
        local item = me.assignWidget(cellPanel, "soldierItem"):clone():setVisible(true)
        me.assignWidget(item, "Text_name"):setString(soldierData.name)
        me.assignWidget(item, "Text_num"):setString(var[2])
        me.assignWidget(item, "Text_type"):setString(soldierType[me.toStr(soldierData.smallType)])
        me.assignWidget(item, "item_icon"):loadTexture(soldierIcon(soldierData), me.plistType)
        listview:pushBackCustomItem(item)
    end
    me.assignWidget(cellPanel, "Text_soldier_num"):setString(count)

    if data.shipId>0 then
        local cellPanel = me.assignWidget(self, "cellpanel1")
        local listview = me.assignWidget(cellPanel, "ListView1")
        listview:removeAllItems()
        local item = me.assignWidget(cellPanel, "shipItem"):clone():setVisible(true)

        local shipData = cfg[CfgType.SHIP_DATA][data.shipId] 
        me.assignWidget(item, "Text_name"):setString(shipData.name)
        me.assignWidget(item, "item_icon"):loadTexture("zhanjian_tupian_zhanjian_"..shipData.icon..".png")
        listview:pushBackCustomItem(item)
    end
end

function resistEnemyDetail:onEnter()
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_RESIST_ENEMY_DETAIL) then
             self:initData(msg.c)
        end
    end )
end
function resistEnemyDetail:onExit()
    print("resistEnemyDetail:onExit()")
    UserModel:removeLisener(self.modelkey)
end
function resistEnemyDetail:close()
    print("resistEnemyDetail:close()")
    self:removeFromParentAndCleanup(true)
end