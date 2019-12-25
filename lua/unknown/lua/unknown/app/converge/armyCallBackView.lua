--[Comment]
--jnmo
armyCallBackView = class("armyCallBackView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
armyCallBackView.__index = armyCallBackView
function armyCallBackView:create(...)
    local layer = armyCallBackView.new(...)
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
function armyCallBackView:ctor()   
    print("armyCallBackView ctor") 
end
function armyCallBackView:init()   
    print("armyCallBackView init")
    self.used = false
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.Panel_items = me.assignWidget(self,"Panel_items")
    

    return true
end
function armyCallBackView:onEnter()
    print("armyCallBackView onEnter")     
    self:setPanelItems()
	me.doLayout(self,me.winSize)  
end
function armyCallBackView:onEnterTransitionDidFinish()
	print("armyCallBackView onEnterTransitionDidFinish") 
end
function armyCallBackView:onExit()
    print("armyCallBackView onExit")    
end
function armyCallBackView:close()
    if pWorldMap then
        pWorldMap.av = nil
    end
    self:removeFromParentAndCleanup(true)  
end
function armyCallBackView:setCurrentData(armyId,itemId,cb)
    self.armyId = armyId
    self.itemId = itemId
    self.cb = cb
end
function armyCallBackView:setPanelItems()
    local offY = 105
    if self:getTargetItemNum() > 0 then
        local pItemTools = me.assignWidget(self,"Panel_useItem"):clone()
        pItemTools:setVisible(true)
        pItemTools:setPosition(cc.p(0,self.Panel_items:getContentSize().height-offY))
        local tmp = self:setItemDatas(pItemTools,false)
        self.Panel_items:addChild(pItemTools)
        offY = offY*2
    end

    local pItemQuick = me.assignWidget(self,"Panel_useItem"):clone()
    pItemQuick:setVisible(true)
    self:setItemDatas(pItemQuick,true)
    self.Panel_items:addChild(pItemQuick)
    pItemQuick:setPosition(cc.p(0,self.Panel_items:getContentSize().height-offY))

end
function armyCallBackView:getUsed()
    return self.used
end
function armyCallBackView:setUsed(used)
    self.used = used
end
function armyCallBackView:setItemDatas(item,quick)
    if quick then -- 使用钻石
        me.assignWidget(item,"Button_use"):setTitleText("购买并使用")
        me.assignWidget(item,"Button_use"):setPosition(cc.p(508,38))
        me.assignWidget(item,"Button_use"):loadTextureNormal("jhuo_goumai_anniu_zhengchang.png",me.localType)
        me.assignWidget(item,"Button_use"):loadTexturePressed("jhuo_goumai_anniu_anxia.png",me.localType)
    else
        me.assignWidget(item,"Button_use"):loadTextureNormal("jhuo_goumai_anniu_hs_zhengchang.png",me.localType)
        me.assignWidget(item,"Button_use"):loadTexturePressed("jhuo_goumai_anniu_hs_anxia.png",me.localType)
        me.assignWidget(item,"Button_use"):setTitleText("使用")
        
        me.assignWidget(item,"Text_itemNum"):setString(self:getTargetItemNum())
        me.assignWidget(item,"Button_use"):setPosition(cc.p(508,50))
    end

    local def = cfg[CfgType.ETC][self.itemId]
    me.assignWidget(item,"Text_item_title"):setString(def.name)
    me.assignWidget(item,"Text_descr"):setString(def.describe)
    me.assignWidget(item,"Image_itemQulity"):loadTexture(getQuality(def.quality))
    
    me.assignWidget(item,"Image_itemIcon"):loadTexture("item_"..def.icon..".png",me.localType)
    me.assignWidget(item,"Image_shadow_down"):setVisible(not quick)
    me.assignWidget(item,"Image_diamond"):setVisible(quick)
    me.assignWidget(item,"Text_diamond"):setVisible(quick)
    local diamondNum = 0
    if self.itemId == 71 then --高级召回
        diamondNum = cfg[CfgType.CFG_CONST][31].data
    elseif self.itemId == 72 then -- 立即召回
        diamondNum = cfg[CfgType.CFG_CONST][32].data
    end
    
    me.assignWidget(item,"Text_diamond"):setString(" x"..diamondNum)
    local checkBox = me.assignWidget(self, "checkBox")
    me.registGuiClickEventByName(item,"Button_use",function (node)
        if self.cb then --使用钻石
            self:setUsed(true)
            self.cb(quick)
            if checkBox:isSelected() then
                local date = os.date("%Y-%m-%d")
                cc.UserDefault:getInstance():setStringForKey("armycallback_MessageDialog", date)
                cc.UserDefault:getInstance():flush()
            end
            self:close()
        end
    end)
end
function armyCallBackView:getTargetItemNum()
    local itemNm = 0
    for key, var in pairs(user.pkg) do
            local def = var:getDef()
            if me.toNum(def.id) == me.toNum(self.itemId) then
                itemNm = itemNm+var.count
            end
    end
    return me.toNum(itemNm)
end