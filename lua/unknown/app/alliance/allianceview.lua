allianceview = class("allianceview", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
allianceview.__index = allianceview
function allianceview:create(...)
    local layer = allianceview.new(...)
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
function allianceview:ctor()
    print("allianceview:ctor()")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
end

function allianceview:close()
    self:removeFromParentAndCleanup(true)
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity.allianceExitview = nil
    else
        pWorldMap.allianceExitview = nil
    end
end
function allianceview:init()
    self.helpBool = false
    self:setUI()
    return true
end
function allianceview:setUpdataUI()
    NetMan:send(_MSG.getFamilyInfor())
end
function allianceview:setUI()
    local pData = user.famliyInit
    self.Notice = nil
    self.Panel_buttons = me.assignWidget(self, "Panel_buttons")
    me.assignWidget(self, "Image_attacked"):setVisible(CaptiveMgr:isCaptured())
    if pData ~= nil then
        -- 联盟名称
        local pAllianceName = me.assignWidget(self, "alliance_name")
        pAllianceName:setString( "[" ..pData["shortname"].. "]".. pData["name"])
        -- 盟主名称
        local pOwnerName = me.assignWidget(self, "alliance_owner_name")
        pOwnerName:setString(pData["ownerName"])
        -- 联盟战斗力
        local pallianceFight = me.assignWidget(self, "alliance_fight")
        pallianceFight:setString(pData["power"])
        -- 联盟等级
        local pallianceLevel = me.assignWidget(self, "alliance_level")
        pallianceLevel:setString("Lv." .. pData["level"])
        -- 联盟经验label
        local pallianceExpLabel = me.assignWidget(self, "alliance_exp_label")
        pallianceExpLabel:setString(pData["exp"] .. "/" .. pData["levelExp"])
        -- 联盟经验进度
        local pallianceExpLoa = me.assignWidget(self, "alliance_exp_LoadingBar")
        pallianceExpLoa:setPercent(me.toNum(pData["exp"]) / me.toNum(pData["levelExp"]) * 100)

        -- 联盟成员
        local pallianceMemberNum = me.assignWidget(self, "alliance_member_num")
        pallianceMemberNum:setString(pData["memberNumber"] .. "/" .. pData["maxMember"])

        -- 联盟公告
        local allianceannouncement = me.assignWidget(self, "alliance_announcement")
        allianceannouncement:setString(pData["notice"])
        self.Notice = pData["notice"]
    end

    -- 联盟贡献提示
    me.registGuiClickEventByName(self, "btn_contribution_tip", function(node)
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        local wd = node:convertToWorldSpace(cc.p(50, -85))
        stips:initWithStr("可通过PVP、联盟帮助、联盟科技捐献、提升自身建筑或科技等级获取联盟贡献，联盟贡献在退出联盟时清零。", wd)
        me.popLayer(stips)
    end)
    local pData1 = user.familyMember
    dump(user.familyMember)
    -- dump(pData1)
    if pData1 ~= nil then   
        -- 我的职位
        local userposition = me.assignWidget(self, "alliance_position")
        userposition:setString(me.alliancedegree(pData1["degree"]))

        -- 我的贡献
        local usercontribution_num = me.assignWidget(self, "clliance_ contribution_num")
        usercontribution_num:setString(pData1["contribution"])
        -- 我的帮助次数
        --   local userHelpNum = me.assignWidget(self,"alliance_help_num")
        --    userHelpNum:setString(pData1["helpNumber"].."/"..pData1["maxHelp"])
        if pData1["degree"] < 3 then
            me.assignWidget(self, "Button_amend_notice"):setVisible(true)
        end
        if pData1["degree"] > 2 then
            me.assignWidget(self, "Button_manage"):setVisible(false)
            me.assignWidget(self, "Button_amend_notice"):setVisible(false)
        end
    end

    -- 管理
    me.registGuiClickEventByName(self, "Button_alliance_manage", function(node)
        me.tableClear(user.familyMemberList)
        -- 联盟数据置空
        NetMan:send(_MSG.getListMember())
        -- 获取联盟列表
    end )
    -- 联盟建筑物
    --    me.registGuiClickEventByName(self,"Button_build",function (node)

    --        end)
    -- 联盟商店
    --    me.registGuiClickEventByName(self,"Button_shop",function (node)

    --    end)
    -- 联盟帮助
    me.registGuiClickEventByName(self, "Button_help", function(node)
        NetMan:send(_MSG.helpListFamily())
        -- 联盟帮助
        self.helpBool = true
    end )
    me.registGuiClickEventByName(self, "Button_manage", function(node)
        local manage = allianceManage:create("allianceManage.csb")
        -- 联盟管理
        self:addChild(manage)
        me.showLayer(manage, "bg")
    end )

    -- 联盟科技
    self.Button_alliance_tech = me.registGuiClickEventByName(self, "Button_alliance_tech", function(node)
        NetMan:send(_MSG.getFamily_Alliance())
    end )
    me.assignWidget(self.Button_alliance_tech, "Image_attacked"):setVisible(CaptiveMgr:isCaptured())

    -- 联盟战争
    me.registGuiClickEventByName(self, "Button_alliance_battle", function(node)
        local converge = convergeView:create("convergeView.csb")
        converge:showFlag(false)
        self:addChild(converge)
        me.showLayer(converge, "bg")
    end )

    -- 联盟日志
    me.registGuiClickEventByName(self, "Button_log", function(node)
        NetMan:send(_MSG.allianceLog())
    end )
    -- 联盟邮件
    me.registGuiClickEventByName(self, "Button_mail", function(node)
        self.mailview = mailview:create("mailview.csb", 5,1)
        me.runningScene():addChild(self.mailview, me.MAXZORDER);
        me.showLayer(self.mailview, "bg_frame")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity.mailview = self.mailview
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            pWorldMap.mailview = self.mailview
        end
    end )
    
    -- 联盟要塞
    me.registGuiClickEventByName(self, "Button_fort", function(node)
        if user.Cross_Sever_Status == mCross_Sever then
            showTips("跨服不开启此功能")
        else
            NetMan:send(_MSG.getFortList())  
        end
    end )

    -- 联盟政策
    local btn_policy = me.registGuiClickEventByName(self, "Button_policy", function(node)
        NetMan:send(_MSG.alliancePolicyLIST())  
        if self:getChildByName("alliancePolicy")~=nil then return end
        local converge = alliancePolicy:create("alliancePolicy.csb")
        self:addChild(converge)
        me.showLayer(converge, "bg")
    end )

    -- 联盟战报
    --    me.registGuiClickEventByName(self,"Button_fight",function (node)

    --    end)

    -- 修改公告
    me.registGuiClickEventByName(self, "Button_amend_notice", function(node)
        me.assignWidget(self, "Node_notice_emend"):setVisible(false)
        me.assignWidget(self, "alliance_cement_node"):setVisible(true)

        local pNoticeInput = me.assignWidget(self, "alliance_input")
        pNoticeInput:setString(self.Notice)

        local function alliance_Notice_input_regist_callback(sender, eventType)
            if eventType == ccui.TextFiledEventType.attach_with_ime then
                local textField = sender
               -- textField:runAction(cc.MoveBy:create(0.225, cc.p(0, 20)))
            elseif eventType == ccui.TextFiledEventType.detach_with_ime then
                local textField = sender
              --  textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))
                -- 输入完成触屏
            elseif eventType == ccui.TextFiledEventType.insert_text then
                self.Notice = sender:getString()
                -- 输入完成
                if self.userLevel ~= nil and self.userFight ~= nil then
                end
            elseif eventType == ccui.TextFiledEventType.delete_backward then
                self.Notice = sender:getString()
            end
        end
        pNoticeInput:addEventListener(alliance_Notice_input_regist_callback)
        me.registGuiClickEventByName(self, "Button_notice_save", function(node)
            NetMan:send(_MSG.updateNoticeFamily(3, self.Notice))
            -- 修改联盟公告
        end )

    end)

    -- 调整按钮位置
    self:fixBtnPos()
end

-- 动态调整按钮位置，使其居中
function allianceview:fixBtnPos()
    local btnList = {}
    local nameList = {
        "Button_alliance_battle", "Button_alliance_tech",
        "Button_fort", "Button_help",
        "Button_manage", "Button_log",
        "Button_mail", "Button_policy"
    }
    for i, v in ipairs(nameList) do
        local btn = me.assignWidget(self.Panel_buttons, v)
        if btn:isVisible() then
            table.insert(btnList, btn)
        end
    end
    local posList = {}
    -- 按钮水平距离
    local space = 120
    local startX = self.Panel_buttons:getContentSize().width / 2 + (#btnList % 2 == 0 and -space / 2 or 0)
    for i = 1, #btnList do
        local x = startX + (-1)^i * math.ceil((i - 1) / 2) * space
        local y = 78
        table.insert(posList, cc.p(x, y))
    end
    table.sort(posList, function(a, b)
        return a.x < b.x
    end)
    for i, v in ipairs(posList) do
        btnList[i]:setPosition(v)
    end
end

function allianceview:getFight(pFighting)
    local pStr = ""
    local pStrNum = math.floor(string.len(pFighting) / 3)
    local pStrNum1 = string.len(pFighting) % 3
    if string.len(pFighting) > 3 then
        if pStrNum1 ~= 0 then
            pStr = pStr .. string.sub(pFighting, 1, pStrNum1)
        end
        for var = 1, pStrNum do
            local pStr1 = string.sub(pFighting,((var - 1) * 3 + 1) + pStrNum1,((var - 1) * 3 + 1) + 2 + pStrNum1)
            if string.len(pStr) ~= 0 then
                pStr = pStr .. "," .. pStr1
            else
                pStr = pStr1
            end
        end
    else
        pStr = pFighting
    end
end
function allianceview:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) then
        -- 联盟成员列表
        self:close()
        self.lairdmanageview = lairdmanageview:create("alliance/lairdmanage.csb")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity:addChild(self.lairdmanageview, me.MAXZORDER)
            mainCity.allianceExitview = self.lairdmanageview
        else
            pWorldMap:addChild(self.lairdmanageview, me.MAXZORDER)
            pWorldMap.allianceExitview = self.lairdmanageview
        end
        me.showLayer(self.lairdmanageview, "bg_frame")
    elseif checkMsg(msg.t, MsgCode.FAMILY_NOTICE_EDIT) then
        --  修改联盟公告
        me.assignWidget(self, "Node_notice_emend"):setVisible(true)
        me.assignWidget(self, "alliance_cement_node"):setVisible(false)

        local allianceannouncement = me.assignWidget(self, "alliance_announcement")
        allianceannouncement:setString(self.Notice)
    elseif checkMsg(msg.t, MsgCode.FAMILY_HELP_LIST) then
        --  联盟帮助
        if self.helpBool then
            self:close()
            local pAllianceHelp = allianceHelpView:create("alliance/alliancehelp.csb")
            if CUR_GAME_STATE == GAME_STATE_CITY then
                mainCity:addChild(pAllianceHelp, me.MAXZORDER)
                mainCity.allianceExitview = pAllianceHelp
            else
                pWorldMap:addChild(pAllianceHelp, me.MAXZORDER)
                pWorldMap.allianceExitview = pAllianceHelp
            end
            me.showLayer(pAllianceHelp, "bg_frame")
            self.helpBool = false
        end
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_LOG) then
        local allianceLogView = allianceLogView:create("alliance/allianceLogView.csb")
        allianceLogView:initWithData(msg.c.list)
        self:addChild(allianceLogView)
        me.showLayer(allianceLogView, "bg")
    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER_ESC) then
        self:close()
    elseif checkMsg(msg.t, MsgCode.FAMILY_INIT) then
        self:setUI()
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_GIVEN) then
        if allianceTechView.techViewInstance == nil then
            local allianceView = allianceTechView:getInstance()
            -- 联盟科技
            allianceView:initData()
            self:addChild(allianceView)
            me.showLayer(allianceView, "bg")
        end
    elseif checkMsg(msg.t, MsgCode.FAMILY_FORT_LIST) then
        local allianceFort = allianceFortView:create("alliance/allianceFortView.csb")
        self:addChild(allianceFort)
        me.showLayer(allianceFort, "bg_frame")
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_RENIVE_HINT) then
        self:setAllianceHint()   
    end
end
function allianceview:setAllianceHint()
     local pHint = user.allianceConvergeHint.attack + user.allianceConvergeHint.defener
    if pHint > 0 then
        me.assignWidget(self, "allianceConvergeHint"):setVisible(true)
    else
        me.assignWidget(self, "allianceConvergeHint"):setVisible(false)      
    end
end
function allianceview:onEnter()
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end)
    self.close_event = me.RegistCustomEvent("allianceview", function(evt)
        self:close()
    end)
    -- 小红点
    self:setAllianceHint()
end
function allianceview:onExit()
    print("allianceview:onExit()")
    me.RemoveCustomEvent(self.close_event)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
