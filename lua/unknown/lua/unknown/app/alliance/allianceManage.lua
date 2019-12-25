-- 联盟要塞 
allianceManage = class("allianceManage", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1], arg[2])
        return pCell:clone():setVisible(true)
    end
end )
allianceManage.__index = allianceManage
function allianceManage:create(...)
    local layer = allianceManage.new(...)
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
CHANAGE_SHORT_NAME = 1
CHANAGR_NAME = 2
CHANAGE_NOTICE = 3
function allianceManage:ctor()
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.state = CHANAGE_SHORT_NAME
end
function allianceManage:close()
    self:removeFromParentAndCleanup(true)
end
function allianceManage:init()
    print("allianceManage init")
    local costTb = me.split(cfg[CfgType.CFG_CONST][27].data, ":")
    if costTb then
        self.simpleCost = me.toNum(costTb[1])
        self.nameCost = me.toNum(costTb[2])
    end
    self.Button_short_name = me.registGuiClickEventByName(self, "Button_short_name", function(node)
        me.setButtonDisable(self.Button_short_name, false)
        me.assignWidget(self.Button_short_name, "Text_title"):setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
        me.assignWidget(self.Button_short_name, "Text_title"):enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))

        me.setButtonDisable(self.Button_name, true)
        me.assignWidget(self.Button_name, "Text_title"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        me.assignWidget(self.Button_name, "Text_title"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))

        me.setButtonDisable(self.Button_notice, true)
        me.assignWidget(self.Button_notice, "Text_title"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        me.assignWidget(self.Button_notice, "Text_title"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))

        self.simpleEb:setMaxLength(3)
        self.state = CHANAGE_SHORT_NAME
        self.cellBody:setVisible(true)
        self.decBody:setVisible(false)
        self.simpleEb:setPlaceHolder("只能输入字母,数字")
        me.assignWidget(self.cellBody, "payNum"):setString("x" .. self.simpleCost)
    end )
    self.Button_name = me.registGuiClickEventByName(self, "Button_name", function(node)
        me.setButtonDisable(self.Button_short_name, true)
        me.assignWidget(self.Button_short_name, "Text_title"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        me.assignWidget(self.Button_short_name, "Text_title"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))

        me.setButtonDisable(self.Button_name, false)
        me.assignWidget(self.Button_name, "Text_title"):setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
        me.assignWidget(self.Button_name, "Text_title"):enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))

        me.setButtonDisable(self.Button_notice, true)
        me.assignWidget(self.Button_notice, "Text_title"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        me.assignWidget(self.Button_notice, "Text_title"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))

        self.state = CHANAGR_NAME
        self.simpleEb:setMaxLength(12)
        self.cellBody:setVisible(true)
        self.decBody:setVisible(false)
        self.simpleEb:setPlaceHolder("只能输入字母,数字和汉字")
        me.assignWidget(self.cellBody, "payNum"):setString("x" .. self.nameCost)
    end )
    self.Button_notice = me.registGuiClickEventByName(self, "Button_notice", function(node)
        me.setButtonDisable(self.Button_short_name, true)
        me.assignWidget(self.Button_short_name, "Text_title"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        me.assignWidget(self.Button_short_name, "Text_title"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))

        me.setButtonDisable(self.Button_name, true)
        me.assignWidget(self.Button_name, "Text_title"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        me.assignWidget(self.Button_name, "Text_title"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))

        me.setButtonDisable(self.Button_notice, false)
        me.assignWidget(self.Button_notice, "Text_title"):setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
        me.assignWidget(self.Button_notice, "Text_title"):enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))

        self.decEb:setString(self.notice)
        self.state = CHANAGE_NOTICE
        self.cellBody:setVisible(false)
        self.decBody:setVisible(true)
    end )
    me.setButtonDisable(self.Button_short_name, false)
    me.setButtonDisable(self.Button_name, true)
    me.setButtonDisable(self.Button_notice, true)
    self.cellBody = me.assignWidget(self, "cellBody")
    self.cellBody:setVisible(true)
    self.decBody = me.assignWidget(self, "decBody")
    self.decBody:setVisible(false)
    self.simpleEb = me.addInputBox(383, 54, 20, nil, nil, cc.EDITBOX_INPUT_MODE_ANY, "只能输入字母,数字")
    self.simpleEb:setAnchorPoint(0, 0)    
    self.simpleEb:setMaxLength(6)
    me.assignWidget(self.cellBody, "textBg"):addChild(self.simpleEb)
    self.simpleEb:setPlaceholderFontColor(cc.c3b(0xec, 0xc2, 0x7e))
    self.simpleEb:setFontColor(cc.c3b(0xec, 0xc2, 0x7e))
    self.state = CHANAGE_SHORT_NAME
    me.assignWidget(self.cellBody, "payNum"):setString("x" .. self.simpleCost)

    me.registGuiClickEventByName(self.cellBody, "doBtn", function(node)
        if self.state == CHANAGE_SHORT_NAME then
            if self.simpleCost then
                if self.simpleCost > user.diamond then
                    showTips("钻石不足", "ff0000")
                    return
                end
            end
            local str = self.simpleEb:getText()
            if str == "" then
                showTips("联盟简称不能为空", "ff0000")
            end
            NetMan:send(_MSG.updateNoticeFamily(2, str))
        elseif self.state == CHANAGR_NAME then
            if self.nameCost then
                if self.nameCost > user.diamond then
                    showTips("钻石不足", "ff0000")
                    return
                end
            end
            local str = self.simpleEb:getText()
            if #str < 3 then
                showTips("联盟名字不能少于3个字符", "ff0000")
                return             
            end

            NetMan:send(_MSG.updateNoticeFamily(1, str))
        end
    end )

    self.notice = nil
    if CUR_GAME_STATE == GAME_STATE_CITY then
        self.notice = mainCity.allianceview.Notice
    else
        self.notice = pWorldMap.allianceview.Notice
    end
    self.decEb = me.assignWidget(self.decBody,"decInput")   
    self.decEb:setEnabled(false)  
    me.registGuiClickEventByName(self.decBody, "editorBtn", function(node)
        self.decEb:setString(self.notice)
        self.decEb:setEnabled(true)
        me.assignWidget(self.decBody, "editorBtn"):setEnabled(false)
        me.assignWidget(self.decBody, "saveBtn"):setEnabled(true)
    end )
    me.registGuiClickEventByName(self.decBody, "saveBtn", function(node)
        local str = self.decEb:getString()
        self.decEb:setString(str)
        NetMan:send(_MSG.updateNoticeFamily(3, str))
    end )

    return true
end
function allianceManage:onEnter()
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        self:update(msg)
    end )
end
function allianceManage:onExit()
    print("allianceManage onExit")
    UserModel:removeLisener(self.modelkey)
end

function allianceManage:update(msg)
    if checkMsg(msg.t, MsgCode.FAMILY_NOTICE_EDIT) then
        if msg.c.notice == true then
            showTips("修改成功")
            if CUR_GAME_STATE == GAME_STATE_CITY then
                mainCity:openAllianceViewAgain()
            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:openAllianceViewAgain()
            end
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_NOT_INFOR_HINT) then
        if msg.c.alertId == 450 then
            showTips("名字不合法", "ff0000")
        end
    end
end

