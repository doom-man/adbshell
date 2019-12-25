-- [Comment]
-- jnmo
defSoldierTechLevelUpLayer = class("defSoldierTechLevelUpLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
defSoldierTechLevelUpLayer.__index = defSoldierTechLevelUpLayer
function defSoldierTechLevelUpLayer:create(...)
    local layer = defSoldierTechLevelUpLayer.new(...)
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
function defSoldierTechLevelUpLayer:ctor()
    print("defSoldierTechLevelUpLayer ctor")
end
function defSoldierTechLevelUpLayer:init()
    print("defSoldierTechLevelUpLayer init")
    me.registGuiClickEventByName(self, "btn_cancel", function(node)
        self:close()
    end )
    self.Text_Title = me.assignWidget(self, "Text_Title")
    self.pro_bg = me.assignWidget(self, "pro_bg")
    self.nlist_1 = me.assignWidget(self, "nlist_1")
    self.btn_ok= me.registGuiClickEventByName(self, "btn_ok", function(node)
         NetMan:send(_MSG.guard_tech_up(self.val.id))
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知        
        if checkMsg(msg.t, MsgCode.MSG_GUARD_TECH_UP_LEVLE) then                    
            self:initWithData(self.idx, user.guard_tech[self.idx],self.vdata )              
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_STRENGTH)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2+50))
            me.runningScene():addChild(pCityCommon, me.ANIMATION) 
        elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) or
            checkMsg(msg.t, MsgCode.SHOP_BUY) then
            self:initWithData(self.idx, user.guard_tech[self.idx],self.vdata )      
        end
    end )
    return true
end
function defSoldierTechLevelUpLayer:initWithData(idx, val, vdata)
    print("defSoldierTechLevelUpLayer onEnter")
    self.idx = idx
    self.val = val
    self.vdata = vdata
    local data = cfg[CfgType.ARMYTECH][tonumber(self.val.id)]
    self.Text_Title:setString(data.name .. " Lv." .. data.level)
    if data.next and data.next > 0 then
        local descs = string.gsub(data.glass, ';', '|')
        descs = me.split(descs, "|")
        local height_idx = 1
        local height = 44
        local val = me.split(data.desc, "|")
        local glass = cfg[CfgType.ARMYTECH][data.next].glass
        glass = string.gsub(glass, ';', '|')
        local next_desc = me.split(glass, "|")
        if descs then
            self.pro_bg:removeAllChildren()
            for key, var in pairs(descs) do
                local desc_cell = me.assignWidget(self, "Text_Tech_Pro_Clone"):clone()
                desc_cell:setVisible(true)
                local pro = me.assignWidget(desc_cell, "pro")
                local arrow = me.assignWidget(desc_cell, "arrow")
                local ps = me.split(var, ":")
                local next_ps = me.split(next_desc[key], ":")
                if tonumber(vdata[ps[1]].isPercent) == 1 then
                    me.assignWidget(desc_cell, "Text_Pro"):setString(val[key] .. " " .. tonumber(ps[2]) * 100 .. "%")
                    pro:setString(next_ps[2] * 100 .. "%")
                else
                    me.assignWidget(desc_cell, "Text_Pro"):setString(val[key] .. " " .. ps[2])
                    pro:setString(next_ps[2])
                end
                arrow:setPositionX(me.assignWidget(desc_cell, "Text_Pro"):getContentSize().width)
                pro:setPositionX(arrow:getContentSize().width+arrow:getPositionX())
                self.pro_bg:addChild(desc_cell)
                desc_cell:setPosition(180, 307 - height_idx * height)
                height_idx = height_idx + 1
                me.assignWidget(desc_cell, "Image_tech_bg"):setVisible(height_idx % 2 == 0)
            end
        end
        local needs = me.split(data.need, ",")
        self.nlist_1:removeAllChildren()
        for key, var in pairs(needs) do
            local tItem = me.createNode("bNeedConvageItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
            local idata = me.split(var, ":")
            local infoBg = me.assignWidget(bItem, "infoBg")
            infoBg:loadTexture("ui_xl_info_cell.png", me.localType)
            infoBg:setContentSize(320, 28)
            infoBg:setPositionX(12)
            infoBg:setVisible(key % 2 == 1)
            ticon:loadTexture(getItemIcon(tonumber(idata[1])), me.localType)
            self.nlist_1:pushBackCustomItem(bItem)
            local rtype = "food"
            local b = false
            if tonumber(idata[1]) == 9001 then
                rtype = "food"
                b = user.food >= tonumber(idata[2])
                tdesc:setString(user.food .. "/" .. idata[2])
            elseif tonumber(idata[1]) == 9002 then
                rtype = "wood"
                b = user.wood >= tonumber(idata[2])
                tdesc:setString(user.wood .. "/" .. idata[2])
            elseif tonumber(idata[1]) == 9003 then
                rtype = "stone"
                b = user.stone >= tonumber(idata[2])
                tdesc:setString(user.stone .. "/" .. idata[2])
            elseif tonumber(idata[1]) == 9004 then
                rtype = "gold"
                b = user.gold >= tonumber(idata[2])
                tdesc:setString(user.gold .. "/" .. idata[2])
            else
                local debrisCount = 0
                for k, v in pairs(user.pkg) do
                    if v.defid == tonumber(idata[1]) then
                        debrisCount = debrisCount + v.count
                    end
                end
                rtype = "item"
                b = debrisCount >= tonumber(idata[2])
                tdesc:setString(debrisCount .. "/" .. idata[2])
            end
            me.assignWidget(bItem, "optBtn"):setVisible(b == false)
            if b == false then
                me.registGuiClickEventByName(bItem, "optBtn", function(node)
                    if CUR_GAME_STATE == GAME_STATE_CITY then
                        if rtype == "item" then
                            local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
                            me.runningScene():addChild(getWayView, me.MAXZORDER)
                            me.showLayer(getWayView, "bg")
                            getWayView:setData(idata[1])
                        else
                            local tmpView = recourceView:create("rescourceView.csb")
                            tmpView:setRescourceType(rtype)
							tmpView:setRescourceNeedNums(tonumber(idata[2]))
                            me.runningScene():addChild(tmpView, me.MAXZORDER)
                            me.showLayer(tmpView, "bg")
                        end
                    else
                        showTips("领主大人，请切换至内城!")
                    end
                end )
                tdesc:setColor(COLOR_RED)
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
            else
                tdesc:setColor(COLOR_GREEN)
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
            end
        end
        me.assignWidget(self, "Text_MaxLevel"):setVisible(false)
    else
        me.assignWidget(self, "Text_MaxLevel"):setVisible(true)

        local descs = string.gsub(data.glass, ';', '|')
        descs = me.split(descs, "|")
        local height_idx = 1
        local height = 44
        local val = me.split(data.desc, "|")
        if descs then
            self.pro_bg:removeAllChildren()
            for key, var in pairs(descs) do
                local desc_cell = me.assignWidget(self, "Text_Tech_Pro_Clone"):clone()
                desc_cell:setVisible(true)
                local pro = me.assignWidget(desc_cell, "pro")
                local ps = me.split(var, ":")
                if tonumber(vdata[ps[1]].isPercent) == 1 then
                    me.assignWidget(desc_cell, "Text_Pro"):setString(val[key] .. " " .. tonumber(ps[2]) * 100 .. "%")
                    pro:setString("")
                else
                    me.assignWidget(desc_cell, "Text_Pro"):setString(val[key] .. " " .. ps[2])
                    pro:setString("")
                end
                pro:setPositionX(me.assignWidget(desc_cell, "Text_Pro"):getContentSize().width)
                self.pro_bg:addChild(desc_cell)
                desc_cell:setPosition(180, 307 - height_idx * height)
                height_idx = height_idx + 1
                me.assignWidget(desc_cell, "Image_tech_bg"):setVisible(height_idx % 2 == 0)
            end
        end
    end
    me.setButtonDisable(self.btn_ok, data.next and data.next > 0)
end
function defSoldierTechLevelUpLayer:onEnter()
    print("defSoldierTechLevelUpLayer onEnter")
    me.doLayout(self, me.winSize)
end
function defSoldierTechLevelUpLayer:onEnterTransitionDidFinish()
    print("defSoldierTechLevelUpLayer onEnterTransitionDidFinish")
end
function defSoldierTechLevelUpLayer:onExit()
    print("defSoldierTechLevelUpLayer onExit")
    UserModel:removeLisener(self.modelkey)  
end
function defSoldierTechLevelUpLayer:close()
    self:removeFromParent()
end

