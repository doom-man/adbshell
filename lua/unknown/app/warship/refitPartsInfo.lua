-- [Comment]
-- jnmo
refitPartsInfo = class("refitPartsInfo", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
refitPartsInfo.__index = refitPartsInfo
function refitPartsInfo:create(...)
    local layer = refitPartsInfo.new(...)
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
function refitPartsInfo:ctor()
    print("refitPartsInfo ctor")
end
function refitPartsInfo:init()
    print("refitPartsInfo init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_Un", function(node)
        NetMan:send(_MSG.msg_ship_refit_unequip(self.shipId, self.armourIndex))
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_Level", function(node)
        NetMan:send(_MSG.msg_ship_refit_levelup(self.shipId, self.data.id))
    end )
    self.list = me.assignWidget(self, "list")
    self.icon = me.assignWidget(self, "icon")
    self.desc = me.assignWidget(self, "desc")
    self.desc_level = me.assignWidget(self, "desc_level")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    return true
end
function refitPartsInfo:initPartsInfo(data, shipId, armourIndex)
    self.data = data
    self.shipId = shipId
    self.armourIndex = armourIndex
    local curDef = cfg[CfgType.SHIP_REFIX_SKILL][self.data.defid]
    self.icon:loadTexture(getRefitIcon(curDef.id), me.localType)
    self.icon:setVisible(true)
    self.desc:setString(curDef.desc)
    self.Text_Name:setString(curDef.name)
    self.list:removeAllChildren()
    if curDef.nextId then
        self.desc_level:setString(cfg[CfgType.SHIP_REFIX_SKILL][curDef.nextId].desc)
        local ns = me.split(curDef.needItem, ",")
        for key, var in pairs(ns) do
            local is = me.split(var, ":")
            local id = tonumber(is[1])
            local num = tonumber(is[2])
            local tItem = me.createNode("bLevelUpNeedItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
            local infoBg = me.assignWidget(bItem, "infoBg")
            if key % 2 == 0 then
                infoBg:setVisible(false)
            end
            local resName = nil
            local en = false
            if id == 9001 then
                resName = ICON_RES_FOOD
                if num <= user.food then
                    en = true
                end
            elseif id == 9002 then
                resName = ICON_RES_LUMBER
                if num <= user.wood then
                    en = true
                end
            elseif id == 9003 then
                resName = ICON_RES_STONE
                if num <= user.stone then
                    en = true
                end
            elseif id == 9004 then
                resName = ICON_RES_GOLD
                if num <= user.gold then
                    en = true
                end
            else
                resName = getItemIcon(id)
                if num <= getItemNum(id) then
                    en = true
                end
            end
            ticon:loadTexture(resName, me.localType)
            ticon.id = id
            me.registGuiClickEvent(ticon, function(node)
                showPromotion(node.id, num)
            end )
            if en == false then
                tdesc:setColor(COLOR_RED)
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                toptBtn:setVisible(true)
                toptBtn:setTitleText(TID_BUTTON_GETMORE)
                toptBtn.id = id
                me.registGuiClickEvent(toptBtn, function(node, event)
                    if node.id == 9001 or node.id == 9002 or node.id == 9003 or node.id == 9004 then
                        local tmpView = recourceView:create("rescourceView.csb")
                        tmpView:setRescourceType(id)
                        tmpView:setRescourceNeedNums(num)
                        me.popLayer(tmpView)
                    else
                        -- 获取资源
                    end
                end )
            else
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                toptBtn:setVisible(false)
                tdesc:setColor(COLOR_GREEN)
            end
            tdesc:setString(num .. "/" .. getItemNum(id))
            self.list:pushBackCustomItem(bItem)
        end
    end
end
function refitPartsInfo:onEnter()
    print("refitPartsInfo onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_LEVELUP) then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_LEVELUP_COMPLETE)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
            local data = { }
            data.id = msg.c.armourId
            data.defid = msg.c.shipComboSkillId
            local curDef = cfg[CfgType.SHIP_REFIX_SKILL][data.defid]
            if curDef.nextid then
                self:initPartsInfo(data, msg.c.shipId, self.armourIndex)
            else
                self:close()
            end
        end
    end )
end
function refitPartsInfo:onEnterTransitionDidFinish()
    print("refitPartsInfo onEnterTransitionDidFinish")
end
function refitPartsInfo:onExit()
    print("refitPartsInfo onExit")
    UserModel:removeLisener(self.modelkey)
end
function refitPartsInfo:close()
    self:removeFromParent()
end
