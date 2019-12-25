runeDetailView = class("runeDetailView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeDetailView:create(...)
    local layer = runeDetailView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function runeDetailView:ctor()
end

function runeDetailView:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function runeDetailView:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeDetailView:onRevMsg(msg)
    local nowEquip = user.runeEquiped[self.runeInfo.plan]
    if checkMsg(msg.t, MsgCode.RUNE_STRENGTH) then -- 强化符文
        local runeBaseCfg = cfg[CfgType.RUNE_DATA][msg.c.defId]
        self.runeInfo = nowEquip[msg.c.index]
        self:updatePropertyList()
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.RUNE_UPDATE) or checkMsg(msg.t, MsgCode.RUNE_INFO) then -- 更新圣物
        local runeInfo = user.runeBackpack[msg.c.id]
        if runeInfo == nil then
            runeInfo = nowEquip[self.runeInfo.index]
        end
        self.runeInfo=runeInfo
        self:updatePropertyList()
    end
end

function runeDetailView:close()
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
end
function runeDetailView:init()
    print("runeDetailView init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    -- 符文icon
    self.runeIcon = runeItem:create(me.assignWidget(self, "runeIcon"), 1) 

    self.baseTxt = me.assignWidget(self, "baseTxt")
    self.appendTxt = me.assignWidget(self, "appendTxt")
   
    self.runePropList = me.assignWidget(self, "list_property")
    self.runePropList:setScrollBarEnabled (false)
    -- 强化
    self.btnStrength = me.assignWidget(self, "btn_strength")
    
    self.skillPanel = me.assignWidget(self, "skill")

    local function openSkillReset()
        if self.runeInfo.runeSkillId==0 then 
            showTips("技能没有觉醒不能重置")
            return 
        end

        local skillResetView = runeSkillReset:create("rune/runeSkillReset.csb")
        skillResetView:setParentView(self)
        me.runningScene():addChild(skillResetView, me.MAXZORDER)
        skillResetView:setData(self.runeInfo)
        me.showLayer(skillResetView, "bg")

    end
    me.registGuiClickEvent(self.skillPanel, function(node)
        openSkillReset()
    end)
    me.registGuiClickEventByName(self.skillPanel, "resetskilBtn", function(node)
        openSkillReset()
    end)

    self.btnAwaken = me.registGuiClickEventByName(self, "btnAwaken", function(node)
        if self.runeInfo.star<4 then
            showTips("4星及以上圣物才可进行觉醒")
            return
        end
        local awakenView = runeAwaken:create("rune/runeAwaken.csb")
        me.runningScene():addChild(awakenView, me.MAXZORDER)
        awakenView:setData(self.runeInfo)
        me.showLayer(awakenView, "bg")
    end)

    me.registGuiClickEventByName(self, "btn_strength", function(node)
        local function gotoRuneBackPack( ... )
            -- 背包
            local bagView = runeBagView:create("rune/runeBagView.csb")
            me.runningScene():addChild(bagView, me.MAXZORDER)
            me.showLayer(bagView, "bg")
            self:removeFromParentAndCleanup(true)
        end
        local function refreshData()
            self:updatePropertyList()
        end
        local strengthView = runeStrengthView:create("rune/runeStrengthView.csb")
        me.runningScene():addChild(strengthView, me.MAXZORDER)
        strengthView:setSelectRuneInfo(self.runeInfo)
        me.showLayer(strengthView, "bg")
        strengthView:setGotoRunePackCallback(gotoRuneBackPack)
        strengthView:setCloseCallback(refreshData)
    end)

    -- 卸下
    self.btn_puton = me.registGuiClickEventByName(self, "btn_puton", function(node)
        -- 请求卸下
        NetMan:send(_MSG.Rune_equip(self.runeInfo.index, 0, self.runeInfo.plan))
        self:removeFromParentAndCleanup(true)
    end)
    -- 替换
    self.btn_takeoff = me.registGuiClickEventByName(self, "btn_takeoff", function(node)
        local arrRuneBackpack = table.values(user.runeBackpack)
        local len=#arrRuneBackpack
        while len>0 do
            local tmp = arrRuneBackpack[len]
            if cfg[CfgType.RUNE_DATA][tmp.cfgId].type==99 then
                table.remove(arrRuneBackpack, len)
            end
            len=len-1
        end

        if #arrRuneBackpack <= 0 then
            -- 提示背包无当前选中类型的符文
            print ("背包无当前选中类型的符文")
            showTips("背包没有圣物")
        else
            local function registerConfirmChange (runeData)
                NetMan:send(_MSG.Rune_equip(self.runeInfo.index, runeData.id, self.runeInfo.plan))
                showWaitLayer ()   
                self:removeFromParentAndCleanup(true)
            end
            local function registerSelecCallback (runeData)
                local detail = runeGongfengDetail:create("rune/runeGongfengDetail.csb")
                
                    me.runningScene():addChild(detail, me.MAXZORDER)
         
                me.showLayer(detail,"bg")
                detail:setData(self.runeInfo, runeData)
                detail:registerSelecCallback(registerConfirmChange)
            end

            -- 符文选择
            local selectView = runeSelectView:create("rune/runeSelectView.csb")
            
            me.runningScene():addChild(selectView, me.MAXZORDER)
           
            me.showLayer(selectView,"bg")
            selectView:setRuneBagData(arrRuneBackpack)
            selectView:registerSelecCallback(registerSelecCallback)
        end
    end)


    -- 洗炼
    self.btn_XL = me.registGuiClickEventByName(self, "btn_XL", function(node)
        --[[
        local function registerConfirmChange (runeData)
                NetMan:send(_MSG.Rune_equip(self.runeInfo.index, runeData.id, self.runeInfo.plan))
                showWaitLayer ()   
                self:removeFromParentAndCleanup(true)
        end
        ]]
        local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]
        if runeStrengthCfg.level<10 then
            showTips("圣物强化10级开启")
            return
        end
        local xlView = runeXL:create("rune/runeXL.csb")
        me.runningScene():addChild(xlView, me.MAXZORDER)
        me.showLayer(xlView,"bg")
        xlView:setXLRuneInfo(self.runeInfo)
        ---selectView:setRuneBagData(arrRuneBackpack)
        --selectView:registerSelecCallback(registerSelecCallback)
    end)

    return true
end

function runeDetailView:hideBtn()
    me.assignWidget(self, "btn_takeoff"):setVisible(false)
    me.assignWidget(self, "btn_puton"):setVisible(false)
    me.assignWidget(self, "btn_strength"):setVisible(false)
    me.assignWidget(self, "btn_XL"):setVisible(false)
    me.assignWidget(self, "btnAwaken"):setVisible(false)

    self.skillPanel:setVisible(false)
    self.runeIcon:setPositionX(75.77)

    if self.runeInfo.runeSkillId>0 then
        self.runeIcon:setPositionY(80)
        self.runeIcon.skillPanel:setVisible(true)
        me.assignWidget(self, "skillDescPanel"):setVisible(true)
    end
end

function runeDetailView:setRuneInfo(runeInfo)
    self.runeInfo = runeInfo

    self:updatePropertyList()
end
-- 更新符文属性
function runeDetailView:updatePropertyList()
    self.runePropList:removeAllItems()

    if self.runeInfo.star>=4 then
        self.btnAwaken:setBright(true)
        self.skillPanel:setVisible(true)
        self.runeIcon:setPositionX(130.77)
        if self.runeInfo.runeSkillId==0 then
            me.Helper:grayImageView(self.skillPanel) 
            me.assignWidget(self.skillPanel, "skillIco"):setVisible(false)
            me.assignWidget(self.skillPanel, "skillLv"):setVisible(false)
            me.assignWidget(self.skillPanel, "lock"):setVisible(true)
        else
            me.Helper:normalImageView(self.skillPanel) 
            local skillIco = me.assignWidget(self.skillPanel, "skillIco")
            local skillLv = me.assignWidget(self.skillPanel, "skillLv")
            skillIco:setVisible(true)
            skillLv:setVisible(true)
            me.assignWidget(self.skillPanel, "lock"):setVisible(false)
            local skillBase = cfg[CfgType.RUNE_SKILL][self.runeInfo.runeSkillId]
            skillIco:loadTexture("juexing_"..skillBase.icon..".png", me.localType)
            skillLv:loadTexture("runeAwaken"..skillBase.level..".png", me.localType)
            self.skillPanel:loadTexture("runeAwakenbox"..skillBase.rank..".png", me.localType)
            skillIco:ignoreContentAdaptWithSize(true)
            skillLv:ignoreContentAdaptWithSize(true)
            me.assignWidget(self, "skillDescTxt"):setString(skillBase.desc)
        end
    else
        self.btnAwaken:setBright(false)
        self.skillPanel:setVisible(false)
        self.runeIcon:setPositionX(75.77)
    end
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]
    if runeStrengthCfg.level<10 then
        self.btn_XL:setBright(false)
    else
        self.btn_XL:setBright(true)
    end


    self.runeIcon:setData(self.runeInfo)
    self.runeIcon.skillPanel:setVisible(false)
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][self.runeInfo.cfgId]
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]
    local extendRuneAttCfg = cfg[CfgType.RUNE_PROPERTY]

    local baseTxt = self.baseTxt:clone():setVisible(true)
    self.runePropList:pushBackCustomItem(baseTxt)

	
	local strPropKV = runeStrengthCfg.property~=nil and string.split(runeStrengthCfg.property, ",") or {}
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        local attStr = cfg[CfgType.LORD_INFO][attKey].name .. ":+" .. (attValue*100).."%"
        local baseTxt = self.baseTxt:clone():setVisible(true)
        baseTxt:setString(attStr)
        self.runePropList:pushBackCustomItem(baseTxt)
    end

    local appendTxt = self.appendTxt:clone():setVisible(true)
    self.runePropList:pushBackCustomItem(appendTxt)
    local aptPro = getRuneStrengthAttr(runeStrengthCfg, self.runeInfo.apt)
    for k, v in ipairs(aptPro) do
        local attStr = cfg[CfgType.LORD_INFO][v.k].name .. ":+" .. v.v..v.unit
        local appendTxt = self.appendTxt:clone():setVisible(true)
        appendTxt:setString(attStr)
        self.runePropList:pushBackCustomItem(appendTxt)
    end

end

-- 跨服争霸展示
--[[
    unloadCb        -- 卸下回调
    replaceCb       -- 替换回调
--]]
function runeDetailView:showPvpView(unloadCb, replaceCb)
    self.skillPanel:setVisible(true)
    me.assignWidget(self.skillPanel, "resetskilBtn"):setVisible(false)
    me.registGuiClickEvent(self.skillPanel, function(sender)
        local skillBase1 = cfg[CfgType.RUNE_SKILL][self.runeInfo.runeSkillId]
        if skillBase1 and skillBase1.desc then
            showSimpleTips(skillBase1.desc, sender)   
        end
    end)
    self.btnAwaken:setVisible(false)
    self.btn_XL:setVisible(false)
    self.btnStrength:setVisible(false)
    local tempWidth = self.btn_puton:getParent():getContentSize().width
    self.btn_puton:setPositionX(tempWidth / 2 - 150)
    me.registGuiClickEvent(self.btn_puton, function()
        if unloadCb then
            unloadCb()
        end
        self:removeFromParent()
    end)
    self.btn_takeoff:setPositionX(tempWidth / 2 + 150)
    me.registGuiClickEvent(self.btn_takeoff, function()
        if replaceCb then
            replaceCb()
        end
        self:removeFromParent()
    end)
    -- 不在报名阶段
    if not PvpMainView.inSignUp then
        self.btn_puton:setEnabled(false)
        self.btn_takeoff:setEnabled(false)
    end
end