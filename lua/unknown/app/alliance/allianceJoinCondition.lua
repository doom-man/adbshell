-- 设置联盟加入条件 
allianceJoinCondition = class("allianceJoinCondition", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1], arg[2])
        return pCell:clone():setVisible(true)
    end
end )
allianceJoinCondition.__index = allianceJoinCondition
function allianceJoinCondition:create(...)
    local layer = allianceJoinCondition.new(...)
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

function allianceJoinCondition:ctor()
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
end
function allianceJoinCondition:close()
    self:removeFromParentAndCleanup(true)
end

function allianceJoinCondition:initData(parent, userLevel, userFight)
    self.userLevel = userLevel
    self.userFight = userFight
    self.parent = parent
end

function allianceJoinCondition:init()
    print("allianceJoinCondition init")

    local function levelEbFunc(eventType, sender)
        if eventType == "changed" then
            local lv = me.toNum(sender:getText())
            if lv and type(lv) == "number" then
                if lv > 30 then
                    showTips("超出最大等级")
                    sender:setText("30")
                end
            else
                showTips("请输入数字")
                sender:setText("")
            end
        elseif eventType == "return" then
            if sender:getText() then
                self.userLevel = me.toNum(sender:getText())
            end
        end
    end
    self.levelEb = me.addInputBox(204, 42, 24, nil, levelEbFunc, cc.EDITBOX_INPUT_MODE_NUMERIC, "1-30级")
    self.levelEb:setAnchorPoint(0, 0)
    self.levelEb:setPlaceholderFontColor(me.convert3Color_("ecc27e"))
    self.levelEb:setFontColor(cc.c3b(0xec, 0xc2, 0x7e))
    
    me.assignWidget(self, "i_a_input_lowest_level_bg"):addChild(self.levelEb)

    local function fightEbFunc(eventType, sender)
        if eventType == "changed" then
            local fapNum = me.toNum(sender:getText())
            if fapNum and type(fapNum) == "number" then

            else
                showTips("请输入数字")
                sender:setText("")
            end
        elseif eventType == "return" then
            if sender:getText() then
                self.userFight = me.toNum(sender:getText())
            end
        end
    end
    self.fightEb = me.addInputBox(204, 42, 24, nil, fightEbFunc, cc.EDITBOX_INPUT_MODE_NUMERIC, "最低战力")
    self.fightEb:setAnchorPoint(0, 0)
    self.fightEb:setMaxLength(10)
    self.fightEb:setPlaceholderFontColor(me.convert3Color_("ecc27e"))
    self.fightEb:setFontColor(cc.c3b(0xec, 0xc2, 0x7e))
    me.assignWidget(self, "i_a_input_lowest_fight_bg"):addChild(self.fightEb)

    -- 确定按钮
    me.registGuiClickEventByName(self, "Button_1", function(node)
        if   self.levelEb:getText()  and  self.fightEb:getText() then
            self.userLevel = me.toNum(self.levelEb:getText())
            self.userFight = me.toNum(self.fightEb:getText())
            local pData = user.famliyInit
            if self.userLevel==nil then
                self.userLevel=pData.minLevel
            end
            if self.userFight==nil then
                self.userFight=pData.minPower
            end
            NetMan:send(_MSG.setFamily(self.userLevel, self.userFight))
        else
           showTips("请输入条件等级和战斗力")
            -- 设置加入联盟条件
        end
    end )

    return true
end
function allianceJoinCondition:onEnter()
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        self:update(msg)
    end )
end
function allianceJoinCondition:onExit()
    print("allianceJoinCondition onExit")
    UserModel:removeLisener(self.modelkey)
end

function allianceJoinCondition:update(msg)
    if checkMsg(msg.t, MsgCode.FAMILY_SET_RESTRI) then
        local pData = user.famliyInit
        if pData ~= nil then
            pData["minLevel"] = self.userLevel
            pData["minPower"] = self.userFight
        end
        self.parent:updateJoinCondition()
        showTips("设置成功")
        self:close()
    end
end

