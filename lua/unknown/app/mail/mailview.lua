-- 邮件 2015-12-7

mailview = class("mailview", function(...)
    local arg = { ...}
    if table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    else
        return cc.CSLoader:createNode(arg[1])
    end
end )
mailview.__index = mailview
function mailview:create(...)
    local layer = mailview.new(...)
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



mailview.MAILPERSONAL = 1        -- 个人邮件
mailview.MAILSYSTEM = 2           -- 系统消息   
mailview.MAILFIGHT = 3            -- 战斗战报 
mailview.MAILSPY = 4              -- 侦查战报
mailview.MAILINFORTION = 6         -- 消息
mailview.MAILUNION = 5         -- 联盟
mailview.MAILHEROLEVEL = 8         -- 英雄试炼战报
mailview.MAILRESIST = 9         -- 抵御蛮族战报
mailview.needGuide = true -- 是否需要引导

mailview.PERSOANLTYPE = 1 -- 本地保存的邮件

mailview.NetManSever = 10 -- 游戏服务器
mailview.NetBattleManSever = 11 -- 跨服服务器

mailview.MAILDIGORE = 20  -- 遗迹秘宝 挖矿

mailview.MAILSHIPPVP = 10 -- 战舰竞技

mailview.PVP = 30    -- 跨服争霸

function mailview:ctor(...)
    print("mailview:ctor() ")
    _, mailType = ...
    self.mMailData = nil
    local lastMainType = SharedDataStorageHelper():getUserMailType()
    -- 邮件类型
    print("lastMainType", lastMainType)
    -- if lastMainType and lastMainType ~= 0 then
    --    self.MailType = lastMainType
    -- else
    self.MailType = 3
    -- end
    if mailType ~= nil then
        self.MailType = mailType
    end
    if self.MailType == mailview.MAILHEROLEVEL then
        me.assignWidget(self, "backpack_title"):setString("征服战报")
    elseif self.MailType == mailview.MAILDIGORE then
        me.assignWidget(self, "backpack_title"):setString("战报")
    elseif self.MailType == mailview.MAILSHIPPVP then
        me.assignWidget(self, "backpack_title"):setString("战报")
    end
    if guideHelper.getGuideIndex() == guideHelper.guideReport + 1 then
        -- 如果是引导查看战报，就强制切换成战报类型
        self.MailType = 3
    end

    self.mUid = 0
    -- 查看邮件的uid
    self.mBool = false
    -- 查看邮件详细信息
    self.mailNum = 0
    -- 领取邮件动画
    self.pTime = nil
    -- 普通邮件的数量
    self.CurrentSever = mailview.NetManSever
end
function mailview:SeverType()
    self.SeverNetMan = NetMan
    if user.Cross_Sever_Status == mCross_Sever then
        self.SeverNetMan = netBattleMan
        self.CurrentSever = mailview.NetBattleManSever
        self.SeverButton:setVisible(true)
        self.SeverButton:setTitleText("跨服")
    else
        self.SeverNetMan = NetMan
        self.CurrentSever = mailview.NetManSever
        self.SeverButton:setVisible(false)
        if mMailCross == mailview.NetBattleManSever then
            me.tableClear(user.mailList)
        end
    end
    if mMailCross == mailview.NetManSever then
        self.SeverButton:setTitleText("本服")
    elseif mMailCross == mailview.NetBattleManSever then
        -- 跨服服务器
        self.SeverButton:setTitleText("跨服")
    end
end
function mailview:close()
    mMailCross = self.CurrentSever
    if mainCity and mainCity.mailview then
        mainCity.mailview = nil
    end
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
    guideHelper.nextStepByOpt()
end
function mailview:init()
    print("mailview:ctor() ")
    self.mFightTableView = nil
    self.mSpyTableView = nil
    self.pPersoalMailTab = { }
    self.pUnionMailTab = { }
    self.pFightMailTab = { }
    self.pSpyMailTab = { }
    self.pSysMailTab = { }

    self.pMailTab = { }
    self:initSystemUITable()

    self.pBattleTab = { }
    self:initBattleUITable()

    self.pSpyTab = { }
    self:initSpyUITable()


    self.infoTab = { }
    self:initInfoTab()

    self.SeverButton = me.assignWidget(self, "Button_Cross_sever")
    self:SeverType()
    -- 选择链接的服务器
    self.RoleAllButton = me.assignWidget(self, "Button_goods_All"):setVisible(false)
    me.registGuiClickEvent(self.RoleAllButton, function(node)
        self.SeverNetMan:send(_MSG.getAllMailItem())
    end )

    me.registGuiClickEventByName(self, "Button_delete", function(node)
        self.SeverNetMan:send(_MSG.deleteMail(self.mMailData.uid))
    end )

    -- 信息
    me.assignWidget(self, "bg_under_In"):setVisible(false)
    me.assignWidget(self, "In_bg"):setVisible(true)
    self.btn_Infor = me.registGuiClickEventByName(self, "Button_mail_information", function(node)
        -- 事件信息
        self:setButton(self.btn_Infor, false)
        self:setButton(self.btn_Fight, true)
        self:setButton(self.btn_System, true)
        self:setButton(self.btn_Personal, true)
        self:setButton(self.btn_Union, true)
        self:setButton(self.btn_spy, true)
        me.assignWidget(self, "Panal_system_hint"):setVisible(false)
        self.MailType = mailview.MAILINFORTION
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self:setMailTyp()
        me.assignWidget(self, "mail_infor_hint"):setVisible(false)
    end )
    self.btn_Fight = me.registGuiClickEventByName(self, "Button_fight", function(node)
        -- 战报
        self:setButton(self.btn_Infor, true)
        self:setButton(self.btn_Fight, false)
        self:setButton(self.btn_System, true)
        self:setButton(self.btn_Personal, true)
        self:setButton(self.btn_Union, true)
        self:setButton(self.btn_spy, true)
        me.assignWidget(self, "Panal_system_hint"):setVisible(false)
        self.MailType = mailview.MAILFIGHT
        self:getServerData()
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self:setMailTyp()

        me.assignWidget(self, "mail_fight_hint"):setVisible(false)
    end )
    self.btn_spy = me.registGuiClickEventByName(self, "Button_mail_spy", function(node)
        -- 侦查
        self:setButton(self.btn_Infor, true)
        self:setButton(self.btn_spy, false)
        self:setButton(self.btn_Fight, true)
        self:setButton(self.btn_System, true)
        self:setButton(self.btn_Personal, true)
        self:setButton(self.btn_Union, true)
        me.assignWidget(self, "Panal_system_hint"):setVisible(false)
        self.MailType = mailview.MAILSPY
        self:getServerData()
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self:setMailTyp()
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        me.assignWidget(self, "mail_spy_hint"):setVisible(false)
    end )



    self.btn_System = me.registGuiClickEventByName(self, "Button_system", function(node)
        -- 系统邮件
        self:setButton(self.btn_Infor, true)
        self:setButton(self.btn_Fight, true)
        self:setButton(self.btn_Personal, true)
        self:setButton(self.btn_Union, true)
        self:setButton(self.btn_System, false)
        self:setButton(self.btn_spy, true)
        me.assignWidget(self, "Panal_system_hint"):setVisible(true)
        self.MailType = mailview.MAILSYSTEM
        self:getServerData()
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self:setMailTyp()
        me.assignWidget(self, "mail_system_hint"):setVisible(false)
    end )
    self.btn_Personal = me.registGuiClickEventByName(self, "Button_personal", function(node)
        -- 个人邮件
        self:setButton(self.btn_Infor, true)
        self:setButton(self.btn_Fight, true)
        self:setButton(self.btn_System, true)
        self:setButton(self.btn_Union, true)
        self:setButton(self.btn_Personal, false)
        self:setButton(self.btn_spy, true)
        me.assignWidget(self, "Panal_system_hint"):setVisible(false)
        self.MailType = mailview.MAILPERSONAL
        self:getServerData()
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self:setMailTyp()
        me.assignWidget(self, "mail_personal_hint"):setVisible(false)        
    end )
    self.btn_Union = me.registGuiClickEventByName(self, "Button_union", function(node)
        -- 联盟邮件
        self:setButton(self.btn_Infor, true)
        self:setButton(self.btn_Fight, true)
        self:setButton(self.btn_System, true)
        self:setButton(self.btn_Personal, true)
        self:setButton(self.btn_Union, false)
        self:setButton(self.btn_spy, true)
        me.assignWidget(self, "Panal_system_hint"):setVisible(false)
        self.MailType = mailview.MAILUNION
        self:getServerData()
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self:setMailTyp()
        me.assignWidget(self, "mail_personal_hint"):setVisible(false)
    end )

    self.btn_Herolevel = me.registGuiClickEventByName(self, "Button_herolevel", function(node)
        -- 英雄试炼
    end )

    self.btn_Digore = me.registGuiClickEventByName(self, "Button_digore", function(node)
        -- 遗迹秘宝 挖矿
    end )
    self.Button_shippvp = me.registGuiClickEventByName(self, "Button_shippvp", function(node)
        -- 战舰竞技
    end )
    self.btn_Resist = me.registGuiClickEventByName(self, "Button_resist", function(node)
        -- 抵御蛮族
        self:setButton(self.btn_Resist_other, true)
        self:setButton(self.btn_Resist, false)
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
    end )
    self.btn_Resist_other = me.registGuiClickEventByName(self, "Button_resist_other", function(node)
        -- 抵御蛮族 援助
        self:setButton(self.btn_Resist_other, false)
        self:setButton(self.btn_Resist, true)
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
    end )

    if self.MailType == 1 then
        self:setButton(self.btn_Personal, false)
    elseif self.MailType == 2 then
        self:setButton(self.btn_System, false)
        self:setMailTyp()
    elseif self.MailType == 3 then
        self:setButton(self.btn_Fight, false)
    elseif self.MailType == 4 then
        self:setButton(self.btn_spy, false)
    elseif self.MailType == 6 then
        self:setButton(self.btn_Infor, false)
    elseif self.MailType == 5 then
        self:setButton(self.btn_Union, false)
    end


    if self.MailType == mailview.MAILHEROLEVEL then
        self.btn_Infor:setVisible(false)
        self.btn_Fight:setVisible(false)
        self.btn_System:setVisible(false)
        self.btn_Personal:setVisible(false)
        self.btn_Union:setVisible(false)
        self.btn_Resist:setVisible(false)
        self.btn_spy:setVisible(false)
        self.btn_Digore:setVisible(false)
        self.Button_shippvp:setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        self.btn_Herolevel:setVisible(true)

        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
    elseif self.MailType == mailview.MAILDIGORE then
        self.btn_Infor:setVisible(false)
        self.btn_Fight:setVisible(false)
        self.btn_System:setVisible(false)
        self.btn_Personal:setVisible(false)
        self.btn_Union:setVisible(false)
        self.btn_Resist:setVisible(false)
        self.btn_spy:setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        self.btn_Herolevel:setVisible(false)
        self.btn_Digore:setVisible(true)
        self.Button_shippvp:setVisible(false)
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
    elseif self.MailType == mailview.MAILSHIPPVP then
        self.btn_Infor:setVisible(false)
        self.btn_Fight:setVisible(false)
        self.btn_System:setVisible(false)
        self.btn_Personal:setVisible(false)
        self.btn_Union:setVisible(false)
        self.btn_Resist:setVisible(false)
        self.btn_spy:setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        self.btn_Herolevel:setVisible(false)
        self.btn_Digore:setVisible(false)
        self.Button_shippvp:setVisible(true)
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
    elseif self.MailType == mailview.MAILRESIST then
        self.btn_Infor:setVisible(false)
        self.btn_Fight:setVisible(false)
        self.btn_System:setVisible(false)
        self.btn_Personal:setVisible(false)
        self.btn_Union:setVisible(false)
        self.btn_Herolevel:setVisible(false)
        self.btn_Digore:setVisible(false)
        self.Button_shippvp:setVisible(false)
        self.btn_spy:setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        self.btn_Resist:setVisible(true)
        self.btn_Resist_other:setVisible(true)
        self:setButton(self.btn_Resist, false)

        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
    else
        me.assignWidget(self, "Button_wirte_mail"):setVisible(true)
        self:setInitMail()
    end

    self.closeBtn = me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    -- 全部已读
    me.registGuiClickEventByName(self, "Button_fight_read", function(node)
        self.SeverNetMan:send(_MSG.readMail(-1, self.MailType))
        -- 读取邮件
        local pTabData = nil
        if self.MailType == mailview.MAILPERSONAL then
            -- 消息
            pTabData = self.pPersoalMailTab
        elseif self.MailType == mailview.MAILUNION then
            -- 联盟
            pTabData = self.pUnionMailTab
        elseif self.MailType == mailview.MAILSYSTEM then
            -- 系统消息
            pTabData = self.pSysMailTab
        elseif self.MailType == mailview.MAILFIGHT then
            -- 战报
            pTabData = self.pFightMailTab
        elseif self.MailType == mailview.MAILSPY then
            pTabData = self.pSpyMailTab
        end
        if pTabData ~= nil then
            for key, var in pairs(pTabData) do
                var["status"] = -1
            end
        end
        if self.mFightTableView ~= nil then
            local pOffset = self.mFightTableView:getContentOffset()
            self.mFightTableView:reloadData()
            self.mFightTableView:setContentOffset(pOffset)
        end
        if self.mSpyTableView ~= nil then
            local pOffset = self.mSpyTableView:getContentOffset()
            self.mSpyTableView:reloadData()
            self.mSpyTableView:setContentOffset(pOffset)
        end
        self:setRead()
    end )
    me.assignWidget(self, "mail_infor_hint"):setVisible(false)
    -- 写邮件
    me.registGuiClickEventByName(self, "Button_wirte_mail", function(node)
        if self.MailType == mailview.MAILPERSONAL or self.MailType == mailview.MAILUNION then
            if self.mMailData ~= nil then
                if self.mMailData["Property"] == 1 or self.MailType == mailview.MAILUNION then
                    self:MailReply(nil)
                else
                    self:MailReply(self.mMailData)
                end
            else
                self:MailReply(nil)
            end
        end
    end )
    self.SeverHint = me.assignWidget(self, "Cross_server_hint"):setVisible(false)
    me.registGuiClickEvent(self.SeverButton, function(node)
        me.tableClear(user.mailList)
        self.SeverHint:setVisible(false)
        me.assignWidget(self, "mail_fight_hint"):setVisible(false)
        me.assignWidget(self, "mail_system_hint"):setVisible(false)
        me.assignWidget(self, "mail_personal_hint"):setVisible(false)
        me.assignWidget(self, "mail_spy_hint"):setVisible(false)
        if self.CurrentSever == mailview.NetManSever then
            -- 游戏服务器
            self.SeverButton:setTitleText("跨服")
            self.SeverNetMan = netBattleMan
            self.CurrentSever = mailview.NetBattleManSever
            self:setInitMail()
        elseif self.CurrentSever == mailview.NetBattleManSever then
            -- 跨服服务器
            self.SeverButton:setTitleText("本服")
            self.SeverNetMan = NetMan
            self.CurrentSever = mailview.NetManSever
            self:setInitMail()
        end
    end )
    self:setButton(self.btn_Infor, true)
        self:setButton(self.btn_Fight, false)
        self:setButton(self.btn_System, true)
        self:setButton(self.btn_Personal, true)
        self:setButton(self.btn_Union, true)
        self:setButton(self.btn_spy, true)
    return true
end
function mailview:setInitMail()
    if self.CurrentSever == mailview.NetManSever then
        -- 游戏服务器
        self.pNewData = user.newMail.Netan
    else
        self.pNewData = user.newMail.NetBattle
    end
    -- self.pNewData = user.newMail
    self.pNewMailNum = 0
    if self.pNewData then
        for key, var in pairs(self.pNewData) do
            if var > 0 then
                self.pNewMailNum = 1
                break
            end
        end
    end
    local pBool = false
    self.pInfoNewBool = false
    self.pBattleBool = false
    self.pSysBool = false
    self.pUnionBool = false
    self.spyBool = false
    if table.maxn(user.mailList) == 0 then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        -- 获取邮件
        pBool = true
    else
        for key, var in pairs(user.mailList) do
            if var.type == mailview.MAILPERSONAL then
                -- 普通
                self.pInfoNewBool = true
            elseif var.type == mailview.MAILUNION then
                -- 联盟
                self.pUnionBool = true
            elseif var.type == mailview.MAILSYSTEM then
                -- 系统
                self.pSysBool = true
            elseif var.type == mailview.MAILFIGHT then
                -- 战斗战报和侦查战报
                self.pBattleBool = true
            elseif var.type == mailview.MAILSPY then
                self.spyBool = true
            end
        end
        if self.MailType == mailview.MAILPERSONAL then
            -- 普通
            if self.pInfoNewBool == false then
                self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                pBool = true
                -- 获取邮件
            end
        elseif self.MailType == mailview.MAILUNION then
            -- 联盟
            if self.pUnionBool == false then
                self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                pBool = true
                -- 获取邮件
            end
        elseif self.MailType == mailview.MAILSYSTEM then
            -- 系统
            if self.pSysBool == false then
                self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                pBool = true
                -- 获取邮件
            end
        elseif self.MailType == mailview.MAILFIGHT then
            -- 战斗战报和侦查战报
            if self.pBattleBool == false then
                self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                pBool = true
                -- 获取邮件
            end
        elseif self.MailType == mailview.MAILSPY then
            -- 战斗战报和侦查战报
            if self.spyBool == false then
                self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                pBool = true
                -- 获取邮件
            end
        end
    end

    if self.pNewMailNum ~= 0 then
        local pIn = self.pNewData["infoNew"]
        local pBattle = self.pNewData["battleNew"]
        local pSys = self.pNewData["sysNew"]
        local pUnion = self.pNewData["unionNew"]
        local pSpy = self.pNewData["spyNew"]
        if (pIn > 0 or pBattle > 0 or pSys > 0 or pUnion > 0 or pSpy > 0) and(pBool == false) then
            self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
            -- 获取邮件
        end

        if me.toNum(pIn) > 0 then
            if self.MailType == mailview.MAILPERSONAL then
                me.assignWidget(self, "mail_personal_hint"):setVisible(false)
                self.pNewData["infoNew"] = 0
                --  user.newMail.infoNew = 0
                -- self.pNewData = user.newMail
            else
                me.assignWidget(self, "mail_personal_hint"):setVisible(true)
            end
        end

        if me.toNum(pUnion) > 0 then
            if self.MailType == mailview.MAILUNION then
                me.assignWidget(self, "mail_union_hint"):setVisible(false)
                self.pNewData["unionNew"] = 0
                --  user.newMail.infoNew = 0
                -- self.pNewData = user.newMail
            else
                me.assignWidget(self, "mail_union_hint"):setVisible(true)
            end
        end

        if me.toNum(pBattle) > 0 then
            if self.MailType == mailview.MAILFIGHT then
                me.assignWidget(self, "mail_fight_hint"):setVisible(false)
                self.pNewData["battleNew"] = 0
                -- user.newMail.battleNew = 0
                -- self.pNewData = user.newMail
            else
                me.assignWidget(self, "mail_fight_hint"):setVisible(true)
            end
        end
        if me.toNum(pSpy) > 0 then
            if self.MailType == mailview.MAILSPY then
                me.assignWidget(self, "mail_spy_hint"):setVisible(false)
                self.pNewData["spyNew"] = 0
            else
                me.assignWidget(self, "mail_spy_hint"):setVisible(true)
                print("133331")
            end
        end
        if me.toNum(pSys) > 0 then
            if self.MailType == mailview.MAILSYSTEM then
                me.assignWidget(self, "mail_system_hint"):setVisible(false)
                self.pNewData["sysNew"] = 0
                -- user.newMail.sysNew = 0
                -- self.pNewData = user.newMail
            else
                me.assignWidget(self, "mail_system_hint"):setVisible(true)
            end
        end
    elseif pBool == false then
        self:setMailData()
    end
end
function mailview:setRead()
    local pBool = getMailHintRed()
    if pBool == true then
        me.assignWidget(self, "Button_fight_read"):setVisible(true)
    else
        me.assignWidget(self, "Button_fight_read"):setVisible(false)
    end
end

function mailview:setSpyRead()
    local pBool = getMailSpyHintRed()
    if pBool == true then
        me.assignWidget(self, "Button_fight_read"):setVisible(true)
    else
        me.assignWidget(self, "Button_fight_read"):setVisible(false)
    end
end
function mailview:setSystemRead()
    local pBool = getMailSystemHintRed()
    if pBool == true then
        me.assignWidget(self, "mail_system_hint"):setVisible(true)
    else
        me.assignWidget(self, "mail_system_hint"):setVisible(false)
    end
end
-- 查看内存中有无这种种类的新邮件，有时并更新
function mailview:getServerData()
    local pIn = 0
    local pBattle = 0
    local pSys = 0
    local pUnion = 0
    local pSpy = 0
    if self.CurrentSever == mailview.NetManSever then
        -- 游戏服务器
        self.pNewData = user.newMail.Netan
    else
        self.pNewData = user.newMail.NetBattle
    end
    -- self.pNewData = user.newMail
    self.pNewMailNum = 0
    if self.pNewData then
        for key, var in pairs(self.pNewData) do
            if var > 0 then
                self.pNewMailNum = 1
                break
            end
        end
    end
    if self.pNewMailNum ~= 0 then
        pIn = self.pNewData["infoNew"]
        pBattle = self.pNewData["battleNew"]
        pSys = self.pNewData["sysNew"]
        pUnion = self.pNewData["unionNew"]
    end

    local pBool = false
    if self.pInfoNewBool == false and self.MailType == mailview.MAILPERSONAL then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        -- 获取邮件
        pBool = true
        self:setNewMail()
    end

    if self.pUnionBool == false and self.MailType == mailview.MAILUNION then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        -- 获取邮件
        pBool = true
        self:setNewMail()
    end

    if self.pBattleBool == false and self.MailType == mailview.MAILFIGHT then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        -- 获取邮件
        pBool = true
        self:setNewMail()
    end
    if self.spyBool == false and self.MailType == mailview.MAILSPY then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        -- 获取邮件
        pBool = true
        self:setNewMail()
    end

    if self.pSysBool == false and self.MailType == mailview.MAILSYSTEM then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
        -- 获取邮件
        pBool = true
        self:setNewMail()
    end

    if pBool == false then
        if me.toNum(pIn) > 0 and self.MailType == mailview.MAILPERSONAL then
            self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
            -- 获取邮件
            self:setNewMail()
        end

        if me.toNum(pUnion) > 0 and self.MailType == mailview.MAILUNION then
            self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
            -- 获取邮件
            self:setNewMail()
        end

        if me.toNum(pBattle) > 0 and self.MailType == mailview.MAILFIGHT then
            self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
            -- 获取邮件
            self:setNewMail()
        end

        if me.toNum(pSys) > 0 and self.MailType == mailview.MAILSYSTEM then
            self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
            -- 获取邮件
            self:setNewMail()
        end
    end
end

-- 把新邮件置为0 表示没有新邮件
function mailview:setNewMail()
    dump(self.pNewData)
    if self.pNewMailNum ~= 0 then
        local pIn = self.pNewData["infoNew"]
        local pBattle = self.pNewData["battleNew"]
        local pSys = self.pNewData["sysNew"]
        local pUnion = self.pNewData["unionNew"]
        local pSpy = self.pNewData["spyNew"]
        if me.toNum(pIn) > 0 and self.MailType == mailview.MAILPERSONAL then
            -- user.newMail.infoNew = 0
            self.pNewData["infoNew"] = 0
        end

        if me.toNum(pUnion) > 0 and self.MailType == mailview.MAILUNION then
            -- user.newMail.infoNew = 0
            self.pNewData["unionNew"] = 0
        end

        if me.toNum(pBattle) > 0 and self.MailType == mailview.MAILFIGHT then
            -- user.newMail.battleNew = 0
            self.pNewData["battleNew"] = 0
        end
        if me.toNum(pSpy) > 0 and self.MailType == mailview.MAILSPY then
            -- user.newMail.battleNew = 0
            self.pNewData["spyNew"] = 0
        end
        if me.toNum(pSys) > 0 and self.MailType == mailview.MAILSYSTEM then
            -- user.newMail.sysNew = 0
            self.pNewData["sysNew"] = 0
        end
    end
end
-- 获取得到了邮件
function mailview:setMailData()
    local pMail = user.mailList
    me.tableClear(self.pPersoalMailTab)
    me.tableClear(self.pUnionMailTab)
    -- 邮件数据置空
    me.tableClear(self.pSysMailTab)
    -- 邮件数据置空
    me.tableClear(self.pFightMailTab)
    me.tableClear(self.pSpyMailTab)

    -- 邮件数据置空
    for key, var in pairs(pMail) do
        if var.type == mailview.MAILPERSONAL then
            -- 个人
            self.pInfoNewBool = true
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_personal_hint"):setVisible(true)
            end
            table.insert(self.pPersoalMailTab, 1, var)
        elseif var.type == mailview.MAILUNION then
            -- 联盟
            self.pUnionBool = true
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_union_hint"):setVisible(true)
            end
            table.insert(self.pUnionMailTab, 1, var)
        elseif var.type == mailview.MAILSYSTEM then
            -- 系统
            if var["status"] == 0 then
                me.assignWidget(self, "mail_system_hint"):setVisible(true)
            end
            self.pSysBool = true
            table.insert(self.pSysMailTab, 1, var)
        elseif var.type == mailview.MAILFIGHT then
            -- 战斗战报和侦查战报
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_fight_hint"):setVisible(true)
            end
            self.pBattleBool = true
            table.insert(self.pFightMailTab, 1, var)
        elseif var.type == mailview.MAILSPY then
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_spy_hint"):setVisible(true)
                print("22222")
            end
            self.spyBool = true
            table.insert(self.pSpyMailTab, 1, var)
        end
    end
    -- if table.maxn(user.sendMail) == 0 then
    --    local pData = SharedDataStorageHelper():getWroteMail()
    --    self:setPersoanl()
    -- else
    --    self:setPersoanl()
    -- end
    self:setMailTyp()

end


-- 获取英雄试炼邮件
function mailview:herolevelMailData(msg)
    user.mailHeroLevelList = { }
    me.tableClear(self.pFightMailTab)
    for k, v in pairs(msg.c.list) do
        if msg.c.type == mailview.MAILHEROLEVEL then
            local var = mailData.new(v)
            -- 战斗战报和侦查战报
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_fight_hint"):setVisible(true)
            end
            self.pBattleBool = true
            table.insert(self.pFightMailTab, 1, var)
            user.mailHeroLevelList[v.uid] = var
        end
    end
    -- if table.maxn(user.sendMail) == 0 then
    --    local pData = SharedDataStorageHelper():getWroteMail()
    --    self:setPersoanl()
    -- else
    --    self:setPersoanl()
    -- end
    self:setMailTyp()

end

-- 获取遗迹挖矿邮件
function mailview:digoreMailData(msg)
    user.mailDigoreList = { }
    me.tableClear(self.pFightMailTab)
    for k, v in pairs(msg.c.list) do
        if msg.c.type == mailview.MAILDIGORE then
            local var = mailData.new(v)
            -- 战斗战报和侦查战报
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_fight_hint"):setVisible(true)
            end
            self.pBattleBool = true
            table.insert(self.pFightMailTab, 1, var)
            user.mailDigoreList[v.uid] = var
        end
    end
    -- if table.maxn(user.sendMail) == 0 then
    --    local pData = SharedDataStorageHelper():getWroteMail()
    --    self:setPersoanl()
    -- else
    --    self:setPersoanl()
    -- end
    self:setMailTyp()

end

function mailview:shipPvpMailData(msg)
    user.mailShipPvpList = { }
    me.tableClear(self.pFightMailTab)
    for k, v in pairs(msg.c.list) do
        if msg.c.type == mailview.MAILSHIPPVP then
            local var = mailData.new(v)
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_pvp_hint"):setVisible(true)
            end
            self.pBattleBool = true
            table.insert(self.pFightMailTab, 1, var)
            user.mailShipPvpList[v.uid] = var
        end
    end
    self:setMailTyp()
end

-- 获取抵御蛮族邮件
function mailview:resistMailData(msg)
    user.mailResistList = { }
    me.tableClear(self.pFightMailTab)
    for k, v in pairs(msg.c.list) do
        if msg.c.type == mailview.MAILRESIST then
            local var = mailData.new(v)
            -- 战斗战报和侦查战报
            if var["status"] ~= -1 then
                me.assignWidget(self, "mail_fight_hint"):setVisible(true)
            end
            self.pBattleBool = true
            table.insert(self.pFightMailTab, 1, var)
            user.mailResistList[v.uid] = var
        end
    end
    -- if table.maxn(user.sendMail) == 0 then
    --    local pData = SharedDataStorageHelper():getWroteMail()
    --    self:setPersoanl()
    -- else
    --    self:setPersoanl()
    -- end
    self:setMailTyp()

end

function mailview:setPersoanl()
    local pType = mCross_Sever_Out
    if self.CurrentSever == mailview.NetManSever then
        -- 游戏服务器
        pType = mCross_Sever_Out
    elseif self.CurrentSever == mailview.NetBattleManSever then
        -- 游戏服务器
        pType = mCross_Sever
    end
    for key, var in pairs(user.sendMail) do
        if var["rname"] ~= nil and pType == var["CrossType"] then
            local pMsg = { }
            local pcontent = { }
            pMsg.type = 1
            pMsg.time =(me.toNum(var["date"]) / 1000)
            pMsg.title = var["title"]
            pMsg.source = var["rname"]
            pMsg.process = mailview.PERSOANLTYPE
            -- 自己发邮件
            pMsg.content = var["content"]
            local pData = mailData.new(pMsg)
            table.insert(self.pPersoalMailTab, 1, pData)
        end
    end
end
function mailview:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
        title:enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))
    else
        title:setTextColor(cc.c3b(236,200,77))
        title:enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
    end
    local icon = me.assignWidget(button, "icon")
    if icon then
        local nameStr = icon:getComponent("ComExtensionData"):getCustomProperty()
        if b then
            icon:setTexture(nameStr .. "2.png")
        else
            icon:setTexture(nameStr .. "1.png")
        end
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
-- 选择邮件消息类型
function mailview:setMailTyp()
    self.RoleAllButton:setVisible(false)
    me.assignWidget(self,"Image_fujian_bg"):setVisible(true)
    me.assignWidget(self,"Text_fujian"):setVisible(true)
    if self.MailType == mailview.MAILINFORTION then
        -- 消息
        me.assignWidget(self, "bg_under_In"):setVisible(false)
        me.assignWidget(self, "In_bg"):setVisible(false)
        me.assignWidget(self, "bg_under_fight"):setVisible(false)
        me.assignWidget(self, "Button_fight_read"):setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        me.assignWidget(self, "bg_under_spy"):setVisible(false)

        self.mFightTableView:setVisible(false)
        self.infotableView:setVisible(true)

        if table.maxn(mNoticeInfo) == 0 then
            me.assignWidget(self, "In_bg"):setVisible(true)
            self.infoTab = { }
        else
            me.assignWidget(self, "bg_under_fight"):setVisible(true)
            me.assignWidget(self, "In_bg"):setVisible(false)
            local function NoticeCom(pa, pb)
                return me.toNum(pa["time"]) > me.toNum(pb["time"])
            end
            table.sort(mNoticeInfo, NoticeCom)
            self.infoTab = mNoticeInfo
        end
        self.infotableView:reloadData()

        self.pBattleTab = { }
        self.mFightTableView:reloadData()
    elseif self.MailType == mailview.MAILFIGHT or self.MailType == mailview.MAILDIGORE
        or self.MailType == mailview.MAILHEROLEVEL or self.MailType == mailview.MAILRESIST
        or self.MailType == mailview.MAILSHIPPVP
    then
        -- 普通战报   、英雄试炼战报、抵御蛮族战报、遗迹挖矿
        me.assignWidget(self, "bg_under_In"):setVisible(false)
        me.assignWidget(self, "bg_under_fight"):setVisible(true)
        me.assignWidget(self, "Button_fight_read"):setVisible(true)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        me.assignWidget(self, "In_bg"):setVisible(false)
        me.assignWidget(self, "mail_fight_hint"):setVisible(false)
        me.assignWidget(self, "bg_under_spy"):setVisible(false)
        self.mFightTableView:setVisible(true)
        self.infotableView:setVisible(false)
        self:setRead()
        if table.maxn(self.pFightMailTab) == 0 then
            self.pBattleTab = { }
            self.mailNum = 0
            self.mFightTableView:reloadData()
            me.assignWidget(self, "In_bg"):setVisible(true)
            me.assignWidget(self, "Button_fight_read"):setVisible(false)
        else
            self.mailNum = #self.pFightMailTab
            local function MailTab(pa, pb)
                return me.toNum(pa["uid"]) > me.toNum(pb["uid"])
            end
            table.sort(self.pFightMailTab, MailTab)
            self.pBattleTab = self.pFightMailTab
            self.mFightTableView:reloadData()
            if mailview.needGuide then
                mailview.needGuide = false
                local cell = self.mFightTableView:cellAtIndex(0)
                local img = me.assignWidget(cell, "Image_bg")
                guideHelper.nextStepByOpt(false, img, self.mFightTableView)
            end
        end

        self.infoTab = { }
        self.infotableView:reloadData()
    elseif self.MailType == mailview.MAILSPY then
        me.assignWidget(self, "bg_under_In"):setVisible(false)
        me.assignWidget(self, "bg_under_fight"):setVisible(false)
        me.assignWidget(self, "Button_fight_read"):setVisible(true)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        me.assignWidget(self, "In_bg"):setVisible(false)
        me.assignWidget(self, "mail_spy_hint"):setVisible(false)
        me.assignWidget(self, "bg_under_spy"):setVisible(true)
        self:setSpyRead()
        if table.maxn(self.pSpyMailTab) == 0 then
            self.pSpyTab = { }
            self.mailNum = 0
            self.mSpyTableView:reloadData()
            me.assignWidget(self, "In_bg"):setVisible(true)
            me.assignWidget(self, "Button_fight_read"):setVisible(false)
        else
            self.mailNum = #self.pFightMailTab
            local function MailTab(pa, pb)
                return me.toNum(pa["uid"]) > me.toNum(pb["uid"])
            end
            table.sort(self.pSpyMailTab, MailTab)
            self.pSpyTab = self.pSpyMailTab
            self.mSpyTableView:reloadData()
            if mailview.needGuide then
                mailview.needGuide = false
                local cell = self.mSpyTableView:cellAtIndex(0)
                local img = me.assignWidget(cell, "Image_bg")
                guideHelper.nextStepByOpt(false, img, self.mSpyTableView)
            end
        end

        self.infoTab = { }
        self.infotableView:reloadData()
    elseif self.MailType == mailview.MAILSYSTEM then
        -- 系统消息
        me.assignWidget(self, "bg_under_In"):setVisible(true)
        me.assignWidget(self, "In_bg"):setVisible(false)
        me.assignWidget(self, "bg_under_fight"):setVisible(false)
        me.assignWidget(self, "Button_fight_read"):setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(false)
        -- me.assignWidget(self, "Image_1"):removeAllChildren()
        me.assignWidget(self, "mail_system_hint"):setVisible(false)
        me.assignWidget(self, "bg_under_spy"):setVisible(false)
        --  self:setSystemRead()

        self.pPitchNum = 1
        if table.maxn(self.pSysMailTab) == 0 then
            me.assignWidget(self, "bg_under_In"):setVisible(false)
            me.assignWidget(self, "In_bg"):setVisible(true)
            self.pMailTab = { }
            self.mailNum = 0
        else
            local function MailTab(pa, pb)
                return me.toNum(pa["time"]) > me.toNum(pb["time"])
            end
            table.sort(self.pSysMailTab, MailTab)
            self.mailNum = #self.pSysMailTab
            self.pMailTab = self.pSysMailTab
            self:setInfortion(self.pMailTab[self.pPitchNum])
        end
        self.mInTableView:reloadData()

        me.assignWidget(self, "Panal_system_hint"):setVisible(true)
        self:AllGoods()
    elseif self.MailType == mailview.MAILPERSONAL then
        -- 个人邮件
        me.assignWidget(self, "bg_under_In"):setVisible(true)
        me.assignWidget(self, "In_bg"):setVisible(false)
        me.assignWidget(self, "bg_under_fight"):setVisible(false)
        me.assignWidget(self, "Button_fight_read"):setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(true)
        me.assignWidget(self, "mail_personal_hint"):setVisible(false)
        me.assignWidget(self, "bg_under_spy"):setVisible(false)
        -- me.assignWidget(self, "Image_1"):removeAllChildren()
        me.assignWidget(self,"Image_fujian_bg"):setVisible(false)
        me.assignWidget(self,"Text_fujian"):setVisible(false)
        self.pPitchNum = 1
        if table.maxn(self.pPersoalMailTab) == 0 then
            me.assignWidget(self, "bg_under_In"):setVisible(false)
            me.assignWidget(self, "In_bg"):setVisible(true)
            self.pMailTab = { }
            self.mailNum = 0
        else
            local function MailTab(pa, pb)
                return me.toNum(pa["time"]) > me.toNum(pb["time"])
            end
            table.sort(self.pPersoalMailTab, MailTab)
            self.mailNum = #self.pPersoalMailTab
            self.pMailTab = self.pPersoalMailTab
            self:setInfortion(self.pMailTab[self.pPitchNum])
        end
        self.mInTableView:reloadData()
    elseif self.MailType == mailview.MAILUNION then
        -- 联盟邮件
        me.assignWidget(self, "bg_under_In"):setVisible(true)
        me.assignWidget(self, "In_bg"):setVisible(false)
        me.assignWidget(self, "bg_under_fight"):setVisible(false)
        me.assignWidget(self, "Button_fight_read"):setVisible(false)
        me.assignWidget(self, "Button_wirte_mail"):setVisible(true)
        me.assignWidget(self, "mail_union_hint"):setVisible(false)
        me.assignWidget(self, "bg_under_spy"):setVisible(false)
        -- me.assignWidget(self, "Image_1"):removeAllChildren()
        me.assignWidget(self,"Image_fujian_bg"):setVisible(false)
        me.assignWidget(self,"Text_fujian"):setVisible(false)
        self.pPitchNum = 1
        if table.maxn(self.pUnionMailTab) == 0 then
            me.assignWidget(self, "bg_under_In"):setVisible(false)
            me.assignWidget(self, "In_bg"):setVisible(true)
            self.pMailTab = { }
            self.mailNum = 0
        else
            local function MailTab(pa, pb)
                return me.toNum(pa["time"]) > me.toNum(pb["time"])
            end
            table.sort(self.pUnionMailTab, MailTab)
            self.mailNum = #self.pUnionMailTab
            self.pMailTab = self.pUnionMailTab
            self:setInfortion(self.pMailTab[self.pPitchNum])
        end
        self.mInTableView:reloadData()
    end
end
-- 消息详情面板
function mailview:setInfortion(pData)
    if pData ~= nil then
        self:MailRead(pData)
        -- 领取
        me.assignWidget(self, "Text_1"):setString("发件人")
        local pButton = me.assignWidget(self, "Button_goods")
        local pDelete = me.assignWidget(self, "Button_delete"):setVisible(false)
        pDelete:setPosition(1011.15, 82)
        local pDrawButton = me.assignWidget(self, "goods_draw"):setVisible(false)
        self.mMailData = pData
        -- dump(pData)
        local pConentStr = ""
        if self.MailType == mailview.MAILSYSTEM then
            -- 系统消息
            if pData["status"] ~= -2 then
                pButton:setVisible(true)
                pDrawButton:setVisible(false)
            else
                pButton:setVisible(false)
                pDrawButton:setVisible(true)
            end
            if pData["nvalue"] < 1 then
                pConentStr = pData["content"][1]
            end
            -- me.assignWidget(self, "Sprite_5"):setVisible(true)
            me.assignWidget(pButton, "image_title"):setString("领取")
        elseif self.MailType == mailview.MAILPERSONAL then
            if me.toNum(pData["roleuid"]) == user.uid then
                me.assignWidget(pButton, "image_title"):setString("回复")
                pButton:setVisible(false)
                pDelete:setVisible(true)
                pConentStr = pData["content"]
                me.assignWidget(self, "Text_1"):setString("收件人")
            else
                me.assignWidget(pButton, "image_title"):setString("回复")
                pConentStr = pData["content"][1]
                pButton:setVisible(true)
                pDelete:setVisible(true)
                pDelete:setPosition(852.30, 82)
                me.registGuiClickEventByName(self, "Button_pople_info", function(node)
                    if self.mMailData["roleuid"] ~= 0 then
                        self.SeverNetMan:send(_MSG.roleInfor(self.mMailData["roleuid"]))
                        showWaitLayer()
                    end

                end )
            end

            -- me.assignWidget(self, "Sprite_5"):setVisible(false)
        elseif self.MailType == mailview.MAILUNION then
            pConentStr = pData["content"][1]
            pDelete:setVisible(true)
            pButton:setVisible(false)
            -- me.assignWidget(self, "Sprite_5"):setVisible(false)
        end
        me.registGuiClickEvent(pButton, function(node)
            if self.MailType == mailview.MAILPERSONAL then
                -- if self.mMailData["Property"] ~= 1 then
                self:MailReply(self.mMailData)
                --   end
            elseif self.MailType == mailview.MAILSYSTEM then
                self:MailReceiv(self.mMailData)
            end
        end )
        -- 标题
        local pIn_Title_label = me.assignWidget(self, "In_Title_label")
        pIn_Title_label:setString(pData["title"])
        if self.MailType == mailview.MAILPERSONAL then
            if me.toNum(pData["roleuid"]) == user.uid then
                if pData.title == "" then
                    pIn_Title_label:setString("寄给" .. pData.source .. "的邮件")
                end
            else
                if pData.title == "" then
                    pIn_Title_label:setString("来自" .. pData.source .. "的邮件")
                end
            end
        end
        -- 发件人
        local pIn_people_label = me.assignWidget(self, "In_people_label")
        pIn_people_label:setString(pData["source"])
        if self.MailType == mailview.MAILSYSTEM then
            pIn_people_label:setString("系统123213")
            printInfo("Pareto")

        end
        -- 时间
        local pIn_Time_label = me.assignWidget(self, "In_Time_label")
        pIn_Time_label:setString(me.GetInSecTime(pData["time"]))
        -- 消息内容
        me.assignWidget(self, "ListView_1"):removeAllItems()
        local pScale = pIn_Time_label:getScale()
        --                pConentStr = "<txt0020,ce8247>我看你的行数对不上1123,123解放军解发发发&<txt0016,f40047>9999,9fd9dag994,838877271939939&"
        if self.MailType == mailview.MAILSYSTEM then
            local startPos, _ =string.find(pConentStr, "<(%w-),(%x-)>(.-)&")
            if startPos==nil then
                pConentStr = "<txt0018,4f2115>" .. parseRichtText(pConentStr) .. "&"
            else
                pConentStr = parseRichtText(pConentStr)
            end
        elseif self.MailType == mailview.MAILPERSONAL or self.MailType == mailview.MAILUNION then
            pConentStr = parsePosition(rebuildChatString(pConentStr), nil, nil, nil, nil, true)
        end
        local pConentlabel = mRichText:create(pConentStr, 650 * pScale)
        pConentlabel:registCallback( function(pos_)
            LookMap(pos_, "mailview")
        end )
        local pLayar = cc.LayerColor:create(cc.c3b(244, 144, 0))
        pLayar:setContentSize(cc.size())
        me.assignWidget(self, "ListView_1"):pushBackCustomItem(pConentlabel)

        -- 附件
        if self.MailType == mailview.MAILSYSTEM then
            -- 系统消息
            print("PARETO")
            printInfo("Pareto")
            local pGoodsData = pData["itemList"]
            me.assignWidget(self, "Node_Goods"):setScrollBarEnabled(false)
            me.assignWidget(self, "Node_Goods"):removeAllItems()
            if pGoodsData ~= nil then
                if pData["status"] == -2 then
                    pButton:setVisible(false)
                    pDrawButton:setVisible(false)
                    pDelete:setVisible(true)
                else
                    pButton:setVisible(true)
                    pDrawButton:setVisible(false)
                    pDelete:setVisible(false)
                end
                local i = 1
                for key, var in pairs(pGoodsData) do
                    local y = 0
                    --                    if key > 4 then
                    --                       y = 4
                    --                    end
                    local pGoodsIcon = me.assignWidget(self, "In_goods_icon"):clone()
                    pGoodsIcon:loadTexture(self:getGoodsIcon(var[1]), me.localType)
                    --pGoodsIcon:setPosition(cc.p(80 *(i - y - 1) * pGoodsIcon:getScale(), 0))
                    pGoodsIcon:setVisible(true)
                    me.resizeImage(pGoodsIcon, 80, 80)
                    me.assignWidget(self, "Node_Goods"):pushBackCustomItem(pGoodsIcon)
                    local pGoodsNum = me.assignWidget(self, "In_goods_num"):clone()
                    pGoodsNum:enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(1, -1))
                    pGoodsNum:setString("x" .. var[2])
                    pGoodsNum:setPosition(cc.p(40, -5))
                    pGoodsNum:setVisible(true)
                    pGoodsIcon:addChild(pGoodsNum)
                    i = i + 1
                end
            else
                pDelete:setVisible(true)
                pButton:setVisible(false)
            end
        else
            me.assignWidget(self, "Node_Goods"):removeAllItems()
        end
    end
end
function mailview:MailReply(pData)
    if self.MailType == mailview.MAILUNION then
        if not(user.familyDegree and(user.familyDegree == 1 or user.familyDegree == 2)) then
            showTips("只有盟主或副盟主能发送邮件")
            return
        end
    end

    if pData then
        local pType = mCross_Sever_Out
        if self.CurrentSever == mailview.NetManSever then
            -- 游戏服务器
            pType = mCross_Sever_Out
        elseif self.CurrentSever == mailview.NetBattleManSever then
            -- 游戏服务器
            pType = mCross_Sever
        end
        local mail = sendMailCell:create("sendMailCell.csb")
        mail:setData(pData["uid"], pData["source"], pType)
        mail:setMailType(self.MailType)
        mail:setParentNode(self)
        self:addChild(mail)
    else
        local mail = sendMailCell:create("sendMailCell.csb")
        mail:setMailType(self.MailType)
        mail:setParentNode(self)
        self:addChild(mail)
    end
end
function mailview:getGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_" .. pCfgData["icon"] .. ".png"
    return pIconStr
end
function mailview:MailRead(pData)
    if pData ~= nil then
        if pData["status"] == 0 then
            self.SeverNetMan:send(_MSG.readMail(pData["uid"]))
            -- 读取邮件
            pData["status"] = -1
        end
    end
end
-- 领取附件
function mailview:MailReceiv(pData)
    if pData ~= nil then
        if pData["status"] ~= -2 then
            self.SeverNetMan:send(_MSG.getMailItem(pData["uid"]))
            -- 领取邮件附件
        end
    end
end
-- 战报
function mailview:initBattleUITable()

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pPitchData = self.pBattleTab[cell:getIdx() + 1]
        if pPitchData ~= nil then
            if pPitchData["type"] == 3 then
                self.mUid = pPitchData["uid"]
                self.mBool = true
                self:MailRead(pPitchData)
                if self.MailType == mailview.MAILHEROLEVEL then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, 8))
                elseif self.MailType == mailview.MAILDIGORE then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, mailview.MAILDIGORE))
                elseif self.MailType == mailview.MAILSHIPPVP then
                    self.SeverNetMan:send(_MSG.msg_ship_refit_pvp_mailinfo(self.mUid))
                elseif self.MailType == mailview.MAILRESIST then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, 9))
                else
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1))
                end
                -- 获取战斗战报邮件
                local pOffect = self.mFightTableView:getContentOffset()
                self.mFightTableView:reloadData()
                self.mFightTableView:setContentOffset(pOffect)
                self:setRead()
            elseif pPitchData["type"] == 4 then
                self.mUid = pPitchData["uid"]
                self.mInBool = true
                self:MailRead(pPitchData)
                self.SeverNetMan:send(_MSG.loadMailSpyReport(self.mUid))
                -- 获取侦查战报邮件
                local pOffect = self.mFightTableView:getContentOffset()
                self.mFightTableView:reloadData()
                self.mFightTableView:setContentOffset(pOffect)
                self:setSpyRead()
            end
        end
    end

    local function cellSizeForTable(table, idx)
        return 1167, 175
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local mailFightCell = mailFightCell:create("mail/mailFightcell.csb")
            mailFightCell:setTag(324)
            mailFightCell:setData(self.pBattleTab[idx + 1])
            mailFightCell:setMailType(self.MailType)
            local pButton = me.assignWidget(mailFightCell, "Button_point")
            pButton:setTag(idx + 1)
            me.registGuiClickEvent(pButton, function(node)
                local pIndx = me.toNum(node:getTag())
                local pData = self.pBattleTab[pIndx]
                local pX = 0
                local pY = 0
                if pData["type"] == 3 then
                    pX = pData["x"]
                    pY = pData["y"]
                elseif pData["type"] == 4 then
                    local pSpyData = pData["content"]
                    pX = pSpyData["x"]
                    pY = pSpyData["y"]
                end
                local pType = mCross_Sever_Out
                if self.CurrentSever == mailview.NetManSever then
                    -- 游戏服务器
                    pType = mCross_Sever_Out
                elseif self.CurrentSever == mailview.NetBattleManSever then
                    -- 跨服服务器
                    pType = mCross_Sever
                end
                if user.Cross_Sever_Status == pType then
                    self:setLookMap(cc.p(pX, pY))
                else
                    showTips("不支持本次跳转")
                end

            end )
            pButton:setSwallowTouches(true)
            cell:addChild(mailFightCell)
        else
            local mailFightCell = cell:getChildByTag(324)
            mailFightCell:setData(self.pBattleTab[idx + 1])
            mailFightCell:setMailType(self.MailType)
            local pButton = me.assignWidget(mailFightCell, "Button_point")
            pButton:setTag(idx + 1)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)

        return #self.pBattleTab
    end

    local tableView = cc.TableView:create(cc.size(1167, 534))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(12, 0)
    tableView:setDelegate()
    me.assignWidget(self, "bg_under_fight"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.mFightTableView = tableView
end
function mailview:initSpyUITable()

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pPitchData = self.pSpyTab[cell:getIdx() + 1]
        if pPitchData ~= nil then
            if pPitchData["type"] == 3 then
                self.mUid = pPitchData["uid"]
                self.mBool = true
                self:MailRead(pPitchData)

                if self.MailType == mailview.MAILHEROLEVEL then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, 8))
                elseif self.MailType == mailview.MAILDIGORE then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, mailview.MAILDIGORE))
                elseif self.MailType == mailview.MAILSHIPPVP then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, mailview.MAILSHIPPVP))
                elseif self.MailType == mailview.MAILRESIST then
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1, 9))
                else
                    self.SeverNetMan:send(_MSG.getMailBattleReport(self.mUid, 1))
                end
                -- 获取战斗战报邮件
                local pOffect = self.mSpyTableView:getContentOffset()
                self.mSpyTableView:reloadData()
                self.mSpyTableView:setContentOffset(pOffect)
                self:setRead()
            elseif pPitchData["type"] == 4 then
                self.mUid = pPitchData["uid"]
                self.mInBool = true
                self:MailRead(pPitchData)
                self.SeverNetMan:send(_MSG.loadMailSpyReport(self.mUid))

                -- 获取侦查战报邮件
                local pOffect = self.mSpyTableView:getContentOffset()
                self.mSpyTableView:reloadData()
                self.mSpyTableView:setContentOffset(pOffect)
                self:setSpyRead()
            end
        end
    end

    local function cellSizeForTable(table, idx)
        return 1167, 175
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local mailFightCell = mailFightCell:create("mail/mailFightcell.csb")
            mailFightCell:setTag(324)
            mailFightCell:setData(self.pSpyTab[idx + 1])
            mailFightCell:setMailType(self.MailType)
            local pButton = me.assignWidget(mailFightCell, "Button_point")
            pButton:setTag(idx + 1)
            me.registGuiClickEvent(pButton, function(node)
                local pIndx = me.toNum(node:getTag())
                local pData = self.pSpyTab[pIndx]
                local pX = 0
                local pY = 0
                if pData["type"] == 3 then
                    pX = pData["x"]
                    pY = pData["y"]
                elseif pData["type"] == 4 then
                    local pSpyData = pData["content"]
                    pX = pSpyData["x"]
                    pY = pSpyData["y"]
                end
                local pType = mCross_Sever_Out
                if self.CurrentSever == mailview.NetManSever then
                    -- 游戏服务器
                    pType = mCross_Sever_Out
                elseif self.CurrentSever == mailview.NetBattleManSever then
                    -- 跨服服务器
                    pType = mCross_Sever
                end
                if user.Cross_Sever_Status == pType then
                    self:setLookMap(cc.p(pX, pY))
                else
                    showTips("不支持本次跳转")
                end

            end )
            pButton:setSwallowTouches(true)
            cell:addChild(mailFightCell)
        else
            local mailFightCell = cell:getChildByTag(324)
            mailFightCell:setData(self.pSpyTab[idx + 1])
            mailFightCell:setMailType(self.MailType)
            local pButton = me.assignWidget(mailFightCell, "Button_point")
            pButton:setTag(idx + 1)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)

        return #self.pSpyTab
    end

    local tableView = cc.TableView:create(cc.size(1167, 534))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(12, 0)
    tableView:setDelegate()
    me.assignWidget(self, "bg_under_spy"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.mSpyTableView = tableView
end
function mailview:setLookMap(pos)
    local pStr = "是否跳转到坐标" .. "(" .. pos.x .. "," .. pos.y .. ")"
    me.showMessageDialog(pStr, function(args)
        if args == "ok" then
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:RankSkipPoint(pos)
                self:close()
            elseif canJumpWorldMap() then
                mainCity:cloudClose( function(node)
                    print("跳转外城")
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    if user.Cross_Sever_Status == mCross_Sever_Out then
                        loadlayer = loadWorldMap:create("loadScene.csb")
                    elseif user.Cross_Sever_Status == mCross_Sever then
                        loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                    end
                    loadlayer:setWarningPoint(pos)
                    me.runScene(loadlayer)
                end )
                me.DelayRun( function()
                    self:close()
                end )
            end
        end
    end )
end
function mailview:initSystemUITable()

    self.pPitchNum = 1
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        self.pPitchNum = cell:getIdx() + 1
        local pOffest = self.mInTableView:getContentOffset()
        self:setInfortion(self.pMailTab[self.pPitchNum])
        self.mInTableView:reloadData()
        self.mInTableView:setContentOffset(pOffest)
    end

    local function cellSizeForTable(table, idx)
        return 350, 113
    end

    local function tableCellAtIndex(table, idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pPitchBool = false
            local mailInCell = mailInCell:create("mail/mailIncell.csb")
            mailInCell:setTag(325)
            if self.pPitchNum ==(idx + 1) then
                pPitchBool = true
                self:setInfortion(self.pMailTab[idx + 1])
            else
                pPitchBool = false
            end
            mailInCell:setData(self.pMailTab[idx + 1], pPitchBool)
            cell:addChild(mailInCell)
        else
            local mailInCell = cell:getChildByTag(325)
            local pPitchBool = false
            if self.pPitchNum ==(idx + 1) then
                pPitchBool = true
            else
                pPitchBool = false
            end
            mailInCell:setData(self.pMailTab[idx + 1], pPitchBool)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
        return #self.pMailTab
    end

    local tableView = cc.TableView:create(cc.size(352, 517))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(4, 0)
    tableView:setDelegate()
    me.assignWidget(self, "Image_1"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.mInTableView = tableView
end
function mailview:initInfoTab()
    self.globalItems = me.createNode("Node_table_enent_cell_bg.csb")
    self.globalItems:retain()
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 1139, 125
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pEventInforCell = EventInforCell:create(self.globalItems, "table_enent_cell_bg")
            pEventInforCell:setAnchorPoint(cc.p(0, 0))
            pEventInforCell:setPosition(cc.p(0, 0))
            pEventInforCell:setData(self.infoTab[idx + 1])
            --      pEventInforCell:setData(pMailFiTab[12])
            cell:addChild(pEventInforCell)
        else
            local pEventInforCell = me.assignWidget(cell, "table_enent_cell_bg")
            pEventInforCell:setData(self.infoTab[idx + 1])
        end
        return cell
    end

    local function numberOfCellsInTableView(table)

        return #self.infoTab
    end

    local tableView = cc.TableView:create(cc.size(1167, 534))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(12, 0)
    tableView:setDelegate()
    me.assignWidget(self, "bg_under_fight"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.infotableView = tableView
end
-- 有新邮件更新邮件
function mailview:getupDatamail()
    if self.SeverType == mailview.NetManSever then
        -- 游戏服务器
        self.pNewData = user.newMail.Netan
    else
        self.pNewData = user.newMail.Netan
    end
    -- self.pNewData = user.newMail
    local pIn = self.pNewData["infoNew"]
    local pBattle = self.pNewData["battleNew"]
    local pSys = self.pNewData["sysNew"]
    local pUnion = self.pNewData["unionNew"]

    if me.toNum(pIn) > 0 and self.MailType == mailview.MAILPERSONAL then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
        -- 获取邮件
        self:setNewMail()
    end

    if me.toNum(pBattle) > 0 and self.MailType == mailview.MAILFIGHT then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
        -- 获取邮件
        self:setNewMail()
    end

    if me.toNum(pSys) > 0 and self.MailType == mailview.MAILSYSTEM then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
        -- 获取邮件
        self:setNewMail()
    end

    if me.toNum(pUnion) > 0 and self.MailType == mailview.MAILSYSTEM then
        self.SeverNetMan:send(_MSG.mailList(self.MailType, 1))
        -- 获取邮件
        self:setNewMail()
    end
end
-- 个人信息界面 
function mailview:popupInfoView(pData)
    if pData then
        if self.layout == nil then
            self.layout = ccui.Layout:create()
            self.layout:setContentSize(cc.size(me.winSize.width, me.winSize.height))
            self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
            self.layout:setAnchorPoint(cc.p(0, 0))
            self.layout:setPosition(cc.p(0, 0))
            self.layout:setSwallowTouches(true)
            self.layout:setTouchEnabled(true)
            self:addChild(self.layout, me.MAXZORDER)
        end
        self.mRoleData = pData
        local info = me.assignWidget(self, "Panel_Info"):clone()
        info:setTouchEnabled(true)
        info:setSwallowTouches(true)
        self.layout:addChild(info)
        info:setVisible(true)
        info:setAnchorPoint(cc.p(0.5, 0.5))
        info:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
        me.assignWidget(info, "Text_name"):setString(pData["name"])
        me.assignWidget(info, "fightNum"):setVisible(pData.fightPower ~= nil)
        if pData.fightPower then
            me.assignWidget(info, "fightNum"):setString(me.toNum(pData.fightPower))
        end
        me.assignWidget(info, "Text_union"):setVisible(pData.familyName ~= nil)
        if pData.familyName then
            me.assignWidget(info, "unionTxt"):setString(pData.familyName)
        end
        me.assignWidget(info, "Text_dep"):setVisible(pData.degree ~= nil)
        if pData.degree then
            me.assignWidget(info, "depTxt"):setString("职位：" .. me.alliancedegree(pData.degree))
        end

        me.registGuiTouchEvent(self.layout, function(node, event)
            if event ~= ccui.TouchEventType.ended then
                return
            end
            self.layout:removeFromParent()
            self.layout = nil

        end )
    end
end
function mailview:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_MAIL_NEW) then
        -- 有新邮件

        if CUR_GAME_STATE == GAME_STATE_CITY then
            me.assignWidget(mainCity, "mail_red_hint"):setVisible(false)
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            me.assignWidget(pWorldMap, "mail_red_hint"):setVisible(false)
        end
        for key, var in pairs(msg.c.list) do
            local ptype = me.toNum(var[1])
            local num = me.toNum(var[2])
            if ptype == self.MailType then
                if num > self.mailNum then
                    self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                elseif ptype == mailview.MAILPERSONAL and num > self.pNewData["infoNew"] then
                    self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                elseif ptype == mailview.MAILUNION and num > self.pNewData["unionNew"] then
                    self.SeverNetMan:send(_MSG.mailList(self.MailType, 0))
                end
            end

            if num > 0 then
                if ptype == mailview.MAILPERSONAL and ptype ~= self.MailType then
                    me.assignWidget(self, "mail_personal_hint"):setVisible(true)
                elseif ptype == mailview.MAILFIGHT and ptype ~= self.MailType then
                    me.assignWidget(self, "mail_fight_hint"):setVisible(true)
                elseif ptype == mailview.MAILSYSTEM and ptype ~= self.MailType then
                    me.assignWidget(self, "mail_system_hint"):setVisible(true)
                elseif ptype == mailview.MAILUNION and ptype ~= self.MailType then
                    me.assignWidget(self, "mail_union_hint"):setVisible(true)
                elseif ptype == mailview.MAILSPY and ptype ~= self.MailType then
                    me.assignWidget(self, "mail_spy_hint"):setVisible(true)
                    print("111111")
                end
            end
        end
        if (msg.c.tp and msg.c.tp == 1 and self.SeverType == mailview.NetBattleManSever) or(msg.c.tp == nil and self.SeverType == mailview.NetManSever) then
            -- 本服务器有邮件更新
            self:getupDatamail()
        else
            self.SeverHint:setVisible(true)
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_DELETE) then
        if self.MailType == mailview.MAILPERSONAL or self.MailType == mailview.MAILSYSTEM or self.MailType == mailview.MAILUNION then
            user.mailList[msg.c.uid] = nil

            local index = 0
            for k, v in ipairs(self.pMailTab) do
                if v.uid == msg.c.uid then
                    table.remove(self.pMailTab, k)
                    index = k
                    break
                end
            end
            if index == 0 then return end
            if index - 1 < 1 then
                if index > #self.pMailTab then
                    me.assignWidget(self, "bg_under_In"):setVisible(false)
                else
                    self.pPitchNum = index
                    self:setInfortion(self.pMailTab[self.pPitchNum])
                end
            else
                self.pPitchNum = index - 1
                self:setInfortion(self.pMailTab[self.pPitchNum])
            end

            local offset = self.mInTableView:getContentOffset()
            self.mInTableView:reloadData()

            local size = self.mInTableView:getContentSize()
            if offset.y < 480 - size.height then
                offset.y = 480 - size.height
            elseif offset.y > 0 then
                offset.y = 0
            end
            self.mInTableView:setContentOffset(offset)

        end
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_INFO) then
        if self.MailType == mailview.MAILHEROLEVEL then
            self:herolevelMailData(msg)
        elseif self.MailType == mailview.MAILDIGORE then
            self:digoreMailData(msg)
        elseif self.MailType == mailview.MAILSHIPPVP then
            self:shipPvpMailData(msg)
        elseif self.MailType == mailview.MAILRESIST then
            self:resistMailData(msg)
        else
            self:setMailData()
        end
        -- 得到邮件数据
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_ADD) then

    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_GET) then

    elseif checkMsg(msg.t, MsgCode.ROLE_VIEW_PLAYER_INFO) then
        -- 个人信息
        self:popupInfoView(msg.c)
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_GET_ITEM) then
        if self.mMailData["itemList"] ~= nil then
            local pGoodsData = { }
            for key, var in pairs(self.mMailData["itemList"]) do
                table.insert(pGoodsData, 1, var)
            end
            self:setMailProp(pGoodsData)
        end

        self.mMailData["status"] = -2
        self:setInfortion(self.mMailData)
        self:setSystemRead()
        self:AllGoods()
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_ALL_GET_ITEM) then
        self:RoleAllMail(msg.c.uids)
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_BATTTLE_REPORT) then
        if self.mBool == true then
            self.mBool = false
            local pMail = user.mailList
            local mail
            if msg.c.mtype == 8 then
                mail = user.mailHeroLevelList[self.mUid]
                mail["loseArmy"] = nil
            elseif msg.c.mtype == mailview.MAILDIGORE then
                mail = user.mailDigoreList[self.mUid]
            elseif msg.c.mtype == mailview.MAILSHIPPVP then
                mail = user.mailShipPvpList[self.mUid]
            elseif msg.c.mtype == 9 then
                mail = user.mailResistList[self.mUid]
            else
                mail = pMail[self.mUid]
            end
            self.pFightInfor = mailFightInfor:create("mail/mailFightInfor.csb")
            self.pFightInfor:setMailType(self.MailType)
            self.pFightInfor:setData(mail, self.SeverNetMan)
            self:addChild(self.pFightInfor, me.MAXZORDER);
            me.showLayer(self.pFightInfor, "bg_frame")
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_MAIL_SPY_REPORT) then
        if self.mInBool == true then
            self.mInBool = false
            local pMail = user.mailList
            local mail = pMail[self.mUid]
            local pSpyData = mail["content"]
            dump(pSpyData)
            if pSpyData["rType"] == 1 then
                local pmailInvestInfor = mailInvestInfor:create("mail/mailInvestInfor.csb")
                pmailInvestInfor:setUI(mail)
                self:addChild(pmailInvestInfor, me.MAXZORDER);
                me.showLayer(pmailInvestInfor, "bg_frame")
            else
                local pStr = "你被" .. pSpyData["attacker"] .. "侦查"
                showTips(pStr)
            end
        end
    end
end
function mailview:setMailProp(pGoodsData)
    if pGoodsData then
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end
        self.mGoodsData = { }
        for key, var in pairs(pGoodsData) do
            table.insert(self.mGoodsData, 1, var)
        end
        self.pReardsNum = #self.mGoodsData
        self.pIndx = 1
        me.GoodsSpecific(self, self:getGoodsIcon(self.mGoodsData[self.pIndx][1]), self.mGoodsData[self.pIndx][2])
        self.pIndx = self.pIndx + 1
        if self.pReardsNum > 1 then
            self.pTime = me.registTimer(-1, function(dt)
                me.GoodsSpecific(self, self:getGoodsIcon(self.mGoodsData[self.pIndx][1]), self.mGoodsData[self.pIndx][2])
                if self.pIndx == self.pReardsNum then
                    me.clearTimer(self.pTime)
                    self.pTime = nil
                end
                self.pIndx = self.pIndx + 1
            end , 0.5)
        end
    end
end
function mailview:AllGoods()
    if self.MailType == mailview.MAILSYSTEM then
        self.RoleAllButton:setVisible(false)
        local pBool = false
        for key, var in pairs(self.pSysMailTab) do
            if var["status"] ~= -2 and var["itemList"] ~= nil then
                pBool = true
                break
            end
        end
        if pBool then
            self.RoleAllButton:setVisible(true)
        end
    end
end
function mailview:RoleAllMail(list)
    local pDoods = { }
    for key, var in pairs(list) do
        for keySy, varSy in pairs(self.pSysMailTab) do
            if varSy["uid"] == me.toNum(var) then
                varSy["status"] = -2
                for keyG, varG in pairs(varSy["itemList"]) do
                    table.insert(pDoods, 1, varG)
                end

            end
        end
    end
    self:setMailProp(pDoods)
    self:setInfortion(self.mMailData)
    self:setSystemRead()
    self:AllGoods()
end
function mailview:onEnter()
    self.close_event = me.RegistCustomEvent("mailview", function(evt)
        self:close()
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)
end
function mailview:onExit()
    if self.MailType then
        SharedDataStorageHelper():setUserMailType(self.MailType)
    end
    me.clearTimer(self.pTime)
    me.RemoveCustomEvent(self.close_event)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    if self.globalItems then self.globalItems:release() end

end
