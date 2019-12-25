-- [Comment]
-- jnmo
warShipRefitView = class("warShipRefitView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warShipRefitView.__index = warShipRefitView
function warShipRefitView:create(...)
    local layer = warShipRefitView.new(...)
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
function warShipRefitView:ctor()
    print("warShipRefitView ctor")
    self.inactivatedShip = { }
    for k, v in pairs(cfg[CfgType.SHIP_DATA]) do
        if v.lv == 1 then
            self.inactivatedShip[v.type] = v
        end
    end  
end
function warShipRefitView:init()
    print("warShipRefitView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    function changeShipCallback(sender)
        if sender.btnType == 1 then
            if user.curSelectShipType > 1 then
                if user.warshipData[user.curSelectShipType - 1] then
                    user.curSelectShipType = user.curSelectShipType - 1
                    self:updateShipView()
                end
            else
                if user.warshipData[#self.inactivatedShip] then
                    user.curSelectShipType = #self.inactivatedShip
                    self:updateShipView()
                end
            end

        else
            if user.curSelectShipType < #self.inactivatedShip then
                if user.warshipData[user.curSelectShipType + 1] then
                    user.curSelectShipType = user.curSelectShipType + 1
                    self:updateShipView()
                end
            else
                if user.warshipData[1] then
                    user.curSelectShipType = 1
                    self:updateShipView()
                end
            end
        end

    end
    -- 上一支战舰
    self.btnPrevShip = me.assignWidget(self, "btn_prev")
    self.btnPrevShip.btnType = 1
    -- 下一支战舰
    self.btnNextShip = me.assignWidget(self, "btn_next")
    self.btnNextShip.btnType = 2
    self.btnPrevShip:addClickEventListener(changeShipCallback)
    self.btnNextShip:addClickEventListener(changeShipCallback)
    self.spriteShip = me.assignWidget(self, "image_ship")
    -- 战舰名称等级
    self.textShipName = me.assignWidget(self, "title")   
    self.list = me.assignWidget(self,"list")
    
    me.registGuiClickEventByName(self,"Button_Store",function (node)
         NetMan:send(_MSG.ship_refit_bag(0,0))    
         self.bag = warShipBagView:create("shipBagView.csb")
         me.popLayer(self.bag)       
    end) 
    me.registGuiClickEventByName(self,"Button_Factory",function (node)
        NetMan:send(_MSG.msg_ship_refit_factory_order())
        local factory = warshipRefitFactoryView:create("warshipFactoryView.csb")
        me.popLayer(factory)
    end) 
    return true
end
function warShipRefitView:updateShipView()
    -- 舰船大图
    self:checkPrevAndNext()
    self.spriteShip:loadTexture(getWarshipImageTexture(user.curSelectShipType))
    me.resizeImage(self.spriteShip, 566, 475)
    print(user.curSelectShipType)
    dump(user.warshipData)
    local baseShipCfg = user.warshipData[user.curSelectShipType].baseShipCfg
    self.textShipName:setString(baseShipCfg.name)
    self:updateRightList(baseShipCfg.id)
end
function warShipRefitView:updateRightList(defid)
    self.defid = defid
    local curdata = user.shipRefixData[ tostring( defid ) ]
    self.list:removeAllChildren()
    for key, var in pairs(curdata) do
         local cell = refitPartsCell:create(self,"Image_Skill")
         cell:initWithData(var,key,self.defid)
         self.list:pushBackCustomItem(cell)
    end
end
function warShipRefitView:checkPrevAndNext()
    if user.curSelectShipType > 1 then
        if user.warshipData[user.curSelectShipType - 1] then
            self.btnPrevShip:setVisible(true)
        else
            self.btnPrevShip:setVisible(false)
        end
    else
        if user.warshipData[#self.inactivatedShip] then
            self.btnPrevShip:setVisible(true)
        else
            self.btnPrevShip:setVisible(false)
        end
    end
    if user.curSelectShipType < #self.inactivatedShip then
        if user.warshipData[user.curSelectShipType + 1] then
            self.btnNextShip:setVisible(true)
        else
            self.btnNextShip:setVisible(false)
        end
    else
        if user.warshipData[1] then
            self.btnNextShip:setVisible(true)
        else
            self.btnNextShip:setVisible(false)
        end
    end
end
function warShipRefitView:onEnter()
    print("warShipRefitView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT) then
            self:updateShipView()  
        elseif  checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_BAG) then 
          if msg.c.t == 0 and msg.c.i == 0 then
              
          else
              local choose = warShipSelectView:create("shipBagView.csb")
              choose:initChoose(msg.c.t,msg.c.i)
              me.popLayer(choose)
         end

        end
    end )
end
function warShipRefitView:onEnterTransitionDidFinish()
    print("warShipRefitView onEnterTransitionDidFinish")
end
function warShipRefitView:onExit()
    print("warShipRefitView onExit")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function warShipRefitView:close()
    self:removeFromParent()
end
