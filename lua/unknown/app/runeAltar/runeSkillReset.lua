runeSkillReset = class("runeSkillReset", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
runeSkillReset.__index = runeSkillReset
function runeSkillReset:create(...)
    local layer = runeSkillReset.new(...)

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
        else
        print("---------------------->>>>")
    end
    return nil
end

function runeSkillReset:ctor()
    self.view_name = "runeSkillReset"
end

function runeSkillReset:setData(data)
    self.data = data

    local skillBase1 = cfg[CfgType.RUNE_SKILL][self.data.runeSkillId]
    local skillIco = me.assignWidget(self.skillPanel1, "skillIco")
    local skillLv = me.assignWidget(self.skillPanel1, "skillLv")
    skillIco:loadTexture("juexing_"..skillBase1.icon..".png", me.localType)
    skillLv:loadTexture("runeAwaken"..skillBase1.level..".png", me.localType)
    self.skillPanel1:loadTexture("runeAwakenbox"..skillBase1.rank..".png", me.localType)
    skillIco:ignoreContentAdaptWithSize(true)
    skillLv:ignoreContentAdaptWithSize(true)
    self.skillDesc1:setString(skillBase1.desc)
    self.skillName1:setString(skillBase1.name)

    if self.data.nextRuneSkillId==0 then
        me.setButtonDisable(self.replaceBtn, false)
        me.Helper:grayImageView(self.skillPanel2) 
        me.assignWidget(self.skillPanel2, "skillIco"):setVisible(false)
        me.assignWidget(self.skillPanel2, "skillLv"):setVisible(false)
        me.assignWidget(self.skillPanel2, "lock"):setVisible(true)
        self.skillDesc2:setString("")
        self.skillName2:setString("")
    else
        me.setButtonDisable(self.replaceBtn, true)

        me.assignWidget(self.skillPanel2, "lock"):setVisible(false)
        me.Helper:normalImageView(self.skillPanel2) 

        local skillBase2 = cfg[CfgType.RUNE_SKILL][self.data.nextRuneSkillId]

        skillIco = me.assignWidget(self.skillPanel2, "skillIco")
        skillLv = me.assignWidget(self.skillPanel2, "skillLv")
        skillIco:loadTexture("juexing_"..skillBase2.icon..".png", me.localType)
        skillLv:loadTexture("runeAwaken"..skillBase2.level..".png", me.localType)
        self.skillPanel2:loadTexture("runeAwakenbox"..skillBase2.rank..".png", me.localType)
        skillIco:ignoreContentAdaptWithSize(true)
        skillLv:ignoreContentAdaptWithSize(true)
        self.skillDesc2:setString(skillBase2.desc)
        self.skillName2:setString(skillBase2.name)
        skillIco:setVisible(true)
        skillLv:setVisible(true)
    end
    
    --材料数量
    self.luckyStone1:setTextColor(cc.c3b(121,255,44))
    self.stoneEnough=true
    local stone = self:getPkgItemById(885)
    local count=0
    if stone~=nil then
        count = stone.count
    end
    self.luckyStone1:setString(count)
    self.luckyStone2:setString("/1")
    self.luckyStone2:setPositionX(self.luckyStone1:getPositionX()+self.luckyStone1:getContentSize().width)
    if count<1 then
        self.luckyStone1:setTextColor(cc.c3b(255,0,0))
        self.stoneEnough=false
    end
end

function runeSkillReset:getPkgItemById(id)
    for key, var in pairs(user.materBackpack) do
        --print("var.defid = "..var.defid)
        if tonumber(var.defid) == tonumber(id) then
            return var
        end
    end
    return nil
end

function runeSkillReset:init()
    print("runeSkillReset:init() ")
    me.doLayout(self, me.winSize)

    
    self.skillPanel1 = me.assignWidget(self, "skill1")
    self.skillPanel2 = me.assignWidget(self, "skill2")
    self.skillDesc1 = me.assignWidget(self, "skillDesc1")
    self.skillDesc2 = me.assignWidget(self, "skillDesc2")
    self.skillName1 = me.assignWidget(self, "skillName1")
    self.skillName2 = me.assignWidget(self, "skillName2")

    self.luckyStone1 = me.assignWidget(self, "luckyStone1")
    self.luckyStone2 = me.assignWidget(self, "luckyStone2")

    self.replaceBtn = me.registGuiClickEventByName(self, "replaceBtn", function(node)
        local function confirm(str)
            if str=="ok" then
                showWaitLayer()
                NetMan:send(_MSG.Rune_skill_replace(self.data.id))
            end
        end
        me.showMessageDialog("确定替换重置后的技能吗？", confirm)
    end )

    self.resetBtn = me.registGuiClickEventByName(self, "resetBtn", function(node)
        if self.stoneEnough==false then
            showTips("圣物幸运石不足")
            return
        end

        showWaitLayer()
        NetMan:send(_MSG.Rune_skill_reset(self.data.id, false))
    end )

    self.addBtn = me.registGuiClickEventByName(self, "addBtn", function(node)
        local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
        me.runningScene():addChild(getWayView, me.MAXZORDER)
        me.showLayer(getWayView, "bg")
        getWayView:setData(885)
        if self.parentView~=nil then
            self.parentView:close()
        end
        self:close()
    end )

    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        --self:removeMtrInfoView()
        self:close()
    end )

    return true
end



function runeSkillReset:close()
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
end

function runeSkillReset:onEnter()

    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
--    self.close_event = me.RegistCustomEvent("runeSkillReset",function (evt)
--        self:close()
--    end)
    --runeComposeView:removeFromParent()
end
function runeSkillReset:onExit()
    UserModel:removeLisener(self.netListener)
    me.RemoveCustomEvent(self.close_event)
end

function runeSkillReset:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_AWAKEN_REQUEST) then
        disWaitLayer()

        self.runeAdded=nil

        local runeInfo = user.runeBackpack[msg.c.awakenRuneId]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.data.plan]
            runeInfo = nowEquip[self.data.index]
        end
        self:setData(runeInfo)
        showTips("觉醒成功")
        --if self.parentView ~= nil then  --更新上级页面上阶圣器数量
        --    self.parentView:reComplexCacl()
        --end
    elseif checkMsg(msg.t, MsgCode.RUNE_SKILL_RESET) or checkMsg(msg.t, MsgCode.RUNE_SKILL_REPLACE) then
        disWaitLayer()
        local runeInfo = user.runeBackpack[msg.c.runeId]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.data.plan]
            runeInfo = nowEquip[self.data.index]
        end
        self:setData(runeInfo)
        if checkMsg(msg.t, MsgCode.RUNE_SKILL_RESET) then
            showTips("重置成功")
        else
            showTips("替换成功")
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or  
           checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or 
           checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
           checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then -- 背包数量改变
        self:setData(self.data)
    end
end


function runeSkillReset:setParentView(parent)
    self.parentView = parent
end