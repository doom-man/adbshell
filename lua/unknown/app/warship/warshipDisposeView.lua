-- [Comment]
-- jnmo
warshipDisposeView = class("warshipDisposeView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warshipDisposeView.__index = warshipDisposeView
function warshipDisposeView:create(...)
    local layer = warshipDisposeView.new(...)
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
function warshipDisposeView:ctor()
    print("warshipDisposeView ctor")
    self.chooseType = nil
end
function warshipDisposeView:init()
    print("warshipDisposeView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_Skill", function(node)
        user.curSelectShipType = self.chooseType
        local warshipView = warshipView:create("warning/warshipView.csb")
        me.popLayer(warshipView)
        warshipView:setCurShipType(user.curSelectShipType)
    end )
    me.registGuiClickEventByName(self, "Button_Factory", function(node)
         local refit = warShipRefitView:create("warshipRefitView.csb")
         me.popLayer(refit)
         NetMan:send(_MSG.ship_refit())
    end )
    me.registGuiClickEventByName(self, "btn_upgrade", function(node)
        user.curSelectShipType = self.chooseType
        local warshipView = warshipView:create("warning/warshipView.csb")
        me.popLayer(warshipView)
        warshipView:setCurShipType(user.curSelectShipType)
    end )

    self.title = me.assignWidget(self, "title")
    self.image_ship = me.assignWidget(self, "image_ship")
    self.text_shipLv = me.assignWidget(self, "text_shipLv")
    self.text_exp_progress = me.assignWidget(self, "text_exp_progress")
    self.load_bar_exp = me.assignWidget(self, "load_bar_exp")
    self.list_character = me.assignWidget(self, "list_character")
    self.list_refit = me.assignWidget(self, "list_refit")
    self.Image_show_att = me.assignWidget(self, "Image_show_att")
    self.Image_show_def = me.assignWidget(self, "Image_show_def")



    self.Button_set_att = me.registGuiClickEventByName(self, "Button_set_att", function(node)
        NetMan:send(_MSG.msg_ship_refit_set_att(self.tmp[self.chooseType].defid))
    end )
    self.Button_set_def = me.registGuiClickEventByName(self, "Button_set_def", function(node)
        NetMan:send(_MSG.msg_ship_refit_set_def(self.tmp[self.chooseType].defid))
    end )
    function changeShipCallback(sender)
        if sender.btnType == 1 then
            if table.nums(self.indexs) > 1 then
                for key, var in pairs(self.indexs) do
                    if var == self.chooseType then
                        if key > 1 then
                            self.chooseType = self.indexs[key - 1]
                        else
                            self.chooseType = self.indexs[#self.indexs]
                        end
                        break
                    end
                end
            end
        else
            if table.nums(self.indexs) > 1 then
                for key, var in pairs(self.indexs) do
                    if var == self.chooseType then
                        if key < #self.indexs then
                            self.chooseType = self.indexs[key + 1]
                        else
                            self.chooseType = self.indexs[1]
                        end
                        break
                    end
                end
            end
        end
        self:initWithData(self.data)
    end
    -- 上一支战舰
    self.btnPrevShip = me.assignWidget(self, "btn_prev")
    self.btnPrevShip.btnType = 1
    -- 下一支战舰
    self.btnNextShip = me.assignWidget(self, "btn_next")
    self.btnNextShip.btnType = 2
    self.btnPrevShip:addClickEventListener(changeShipCallback)
    self.btnNextShip:addClickEventListener(changeShipCallback)
    return true
end
function warshipDisposeView:onEnter()
    print("warshipDisposeView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_GET_SHIP) then
            self:initWithData(msg.c, self.chooseType)
        end
    end )
end
function warshipDisposeView:initWithData(data, choose)
    self.data = data
    self.tmp = { }
    self.indexs = { }
    for key, var in pairs(data.list) do
        if self.chooseType == nil and choose == nil then
            if var.inOffense or var.inDefense then
                self.chooseType = var.type
            end
        end
        self.tmp[var.type] = var
        table.insert(self.indexs, var.type)
    end
    if choose then
        self.chooseType = choose
    end
    local curdata = self.tmp[self.chooseType]
    local curdef = cfg[CfgType.SHIP_DATA][tonumber(curdata.defid)]
    self.title:setString(curdef.name)
    self.image_ship:loadTexture(getWarshipImageTexture(self.chooseType), me.localType)
    me.resizeImage(self.image_ship, 566, 475)
    self.text_shipLv:setString("Lv." .. curdef.lv)
    self.text_exp_progress:setString(curdata.exp .. "/" .. curdata.maxExp)
    self.load_bar_exp:setPercent(curdata.exp * 100 / curdata.maxExp)
    self.Image_show_att:setVisible(curdata.inOffense)
    self.Image_show_def:setVisible(curdata.inDefense)
    self.Button_set_att:setVisible(not curdata.inOffense)
    self.Button_set_def:setVisible(not curdata.inDefense)
    self.list_character:removeAllChildren()
    self.list_refit:removeAllChildren()
    local function enterShipSkillCallback(sender)
        local strItemDescribe = sender.data.desc
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>" .. strItemDescribe .. "&", wd)
        me.popLayer(stips)
    end
    for var = 1, 6 do
        local v = curdata.skills[var]
        if v then
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setTouchEnabled(true)
            imageSkillIcon:setEnabled(true)
            local skillCfg = cfg[CfgType.SHIP_SKILL][tonumber(v.defId)]
            if skillCfg then
                local textrueIcon = getItemIcon(skillCfg.icon)
                imageSkillIcon:loadTexture(textrueIcon)
                local skillIconSize = imageSkillIcon:getContentSize()
                me.assignWidget(shipSkillCell, "skillLvTxt"):setString(skillCfg.lv .. "阶")
            end
            imageSkillIcon.data = skillCfg
            imageSkillIcon:addClickEventListener(enterShipSkillCallback)
            self.list_character:pushBackCustomItem(shipSkillCell)
        else
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            self.list_character:pushBackCustomItem(shipSkillCell)

            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setVisible(false)
            me.assignWidget(shipSkillCell, "Image_49"):setVisible(false)
            me.assignWidget(shipSkillCell, "skillLvTxt"):setVisible(false)
        end

    end
    local function enterShipRefitSkillCallback(sender)
        local strItemDescribe = sender.data.desc
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>" .. strItemDescribe .. "&", wd)
        me.popLayer(stips)
    end
    for var = 1, 6 do
        local v = curdata.comboSkills[var]
        if v then
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setTouchEnabled(true)
            imageSkillIcon:setEnabled(true)
            local skillCfg = cfg[CfgType.SHIP_REFIX_SKILL][tonumber(v.defId)]
            if skillCfg then
                imageSkillIcon:loadTexture(getRefitIcon(tonumber(v.defId)), me.localType)
                me.assignWidget(shipSkillCell, "skillLvTxt"):setString(skillCfg.name)
            end
            imageSkillIcon.data = skillCfg
            imageSkillIcon:addClickEventListener(enterShipRefitSkillCallback)
            self.list_refit:pushBackCustomItem(shipSkillCell)
        else
            local shipSkillCell = me.assignWidget(self, "ShipSkillCell"):clone()
            shipSkillCell:setVisible(true)
            self.list_refit:pushBackCustomItem(shipSkillCell)

            local imageSkillIcon = me.assignWidget(shipSkillCell, "skillicon")
            imageSkillIcon:setVisible(false)
            me.assignWidget(shipSkillCell, "Image_49"):setVisible(false)
            me.assignWidget(shipSkillCell, "skillLvTxt"):setVisible(false)
        end
    end
end
function warshipDisposeView:onEnterTransitionDidFinish()
    print("warshipDisposeView onEnterTransitionDidFinish")
end
function warshipDisposeView:onExit()
    print("warshipDisposeView onExit")
    UserModel:removeLisener(self.modelkey)
end
function warshipDisposeView:close()
    self:removeFromParent()
end
