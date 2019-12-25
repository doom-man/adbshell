-- 战报兵种损失详情
mailFightarm = class("mailFightarm", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
mailFightarm.__index = mailFightarm
function mailFightarm:create(...)
    local layer = mailFightarm.new(...)
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
function mailFightarm:ctor()
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
end
function mailFightarm:close()
    self:removeFromParentAndCleanup(true)
end
function mailFightarm:init()
    return true
end

function mailFightarm:setPvpMailData(mailData)
    self.mailData = mailData
end

function mailFightarm:setarmData(pData, pSever)
    self.CurrentSver = pSever
    if pData ~= nil then
        self.mUid = pData["uid"]
        if self.mailType == mailview.MAILHEROLEVEL then
            self.CurrentSver:send(_MSG.getMailBattleReport(self.mUid, 2, 8))
            -- 获取邮件
		elseif self.mailType == mailview.MAILRESIST then
			self.CurrentSver:send(_MSG.getMailBattleReport(self.mUid, 2, 9))
        elseif self.mailType == mailview.MAILDIGORE then
			self.CurrentSver:send(_MSG.getMailBattleReport(self.mUid, 2, 20))
        elseif self.mailType == mailview.PVP then
            self.CurrentSver:send(_MSG.get_pvp_war_report_detail(self.mUid, 2))
        else
            self.CurrentSver:send(_MSG.getMailBattleReport(self.mUid, 2))
            -- 获取邮件
        end

        local pMyData = nil
        local pRaivl = nil
        local pMStr = "进攻方"
        local pRStr = "防守方"
        if pData["rType"] == 1 or pData["rType"] == 3 then
            pMyData = pData["attacker"]
            pRaivl = pData["defender"]
        elseif pData["rType"] == 2 or pData["rType"] == 4 then
            pMyData = pData["defender"]
            pRaivl = pData["attacker"]
            pMStr = "防守方"
            pRStr = "进攻方"
        end
        -- 我
        local pMattacker = me.assignWidget(self, "Text_1")
        pMattacker:setString(pMStr)
        local pMName = me.assignWidget(self, "m_s_our_name")
        pMName:setString("(" .. pMyData["name"] .. ")")
        -- 对手
        local pRattacker = me.assignWidget(self, "Text_3")
        pRattacker:setString(pRStr)
        local pRName = me.assignWidget(self, "m_s_other_name")
        pRName:setString("(" .. pRaivl["name"] .. ")")
    end
end
function mailFightarm:initFight(pMailFiTab, pId, pHpBool)
    local iNum = #pMailFiTab
    local pNode = nil
    if pId == 1 then
        pNode = me.assignWidget(self, "Node_m_s_ourpar")
    else
        pNode = me.assignWidget(self, "Node_m_s_otherside")
    end

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 540, 128
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pMailFightarmCell = mailFightarmCell:create(self, "m_s_i_cell")
            pMailFightarmCell:setVisible(true)
            pMailFightarmCell:setAnchorPoint(cc.p(0, 0))
            pMailFightarmCell:setPosition(cc.p(0, 0))
            pMailFightarmCell:setDataFIFUI(pMailFiTab[idx + 1], pHpBool)
            cell:addChild(pMailFightarmCell)
        else
            local pMailFightarmCell = me.assignWidget(cell, "m_s_i_cell")
            pMailFightarmCell:setVisible(true)
            pMailFightarmCell:setAnchorPoint(cc.p(0, 0))
            pMailFightarmCell:setPosition(cc.p(0, 0))
            pMailFightarmCell:setDataFIFUI(pMailFiTab[idx + 1], pHpBool)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end
    local tableView = cc.TableView:create(cc.size(370, 405))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(3.5, 8)
    tableView:setDelegate()
    pNode:addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function mailFightarm:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_MAIL_BATTTLE_REPORT) or checkMsg(msg.t, MsgCode.PVP_WAR_REPORT_DETAIL) then
        local pMail = user.mailList

        local mail
        if msg.c.mtype == 8 then
            mail = user.mailHeroLevelList[self.mUid]
		elseif msg.c.mtype == 9 then
			mail = user.mailResistList[self.mUid]
        elseif msg.c.mtype == 20 then
			mail = user.mailDigoreList[self.mUid]

        elseif msg.c.mtype == mailview.MAILSHIPPVP then         
            mail = user.mailShipPvpList[self.mUid]
        -- 跨服争霸
        elseif msg.c.mtype == 21 then
            mail = self.mailData
            mail.attacker.fullinfo = msg.c.attacker
            mail.defender.fullinfo = msg.c.defender
            mail.attacker.fullinfoship = msg.c.attackerShip
            mail.defender.fullinfoship = msg.c.defenderShip

        else
            mail = pMail[self.mUid]
        end
        for var = 1, 2 do
            local pSData = nil
            local pShipData = nil
            local pFightType = false
            -- 1进攻 2 防御 ，3 集火进攻，4 集火防御
            if var == 1 then
                if mail["rType"] == 1 then
                    pSData = mail["attacker"]["fullinfo"]
                    pShipData = mail["attacker"]["fullinfoship"] or nil
                elseif mail["rType"] == 3 then
                    pSData = mail["attacker"]["fullinfo"]
                elseif mail["rType"] == 2 then
                    pSData = mail["defender"]["fullinfo"]
                    pShipData = mail["defender"]["fullinfoship"] or nil
                elseif mail["rType"] == 4 then
                    pSData = mail["defender"]["fullinfo"]
                end
            elseif var == 2 then
                pFightType = true
                if mail["rType"] == 1 then
                    pSData = mail["defender"]["fullinfo"]
                    pShipData = mail["defender"]["fullinfoship"] or nil
                elseif mail["rType"] == 3 then
                    pSData = mail["defender"]["fullinfo"]
                elseif mail["rType"] == 2 then
                    pSData = mail["attacker"]["fullinfo"]
                    pShipData = mail["attacker"]["fullinfoship"] or nil
                elseif mail["rType"] == 4 then
                    pSData = mail["attacker"]["fullinfo"]
                end
            end
            if pFightType then
                if pMail.FightType == 1 then
                    me.assignWidget(self, "m_s_fight_type"):setString("自己或目标免战中......未发生战斗")
                elseif pMail.FightType == 2 then
                    me.assignWidget(self, "m_s_fight_type"):setString("无部队")
                end
                me.assignWidget(self, "m_s_fight_type"):setVisible(false)
                if mail["rType"] > 2 then
                    self:converge(pSData, var)
                else
                    local pBool = false
                    if mail["FighType"] == 5 then
                        pBool = true
                    end
                    if mail.gArmy then
                        if var == 1 then
                            if mail["rType"] == 2 or mail["rType"] == 4 then
                                local temps = { }
                                local p1 = { }
                                p1.name = mail.gArmy.name
                                p1.army = mail["defender"]["fullinfo"]
                                local p2 = { }
                                p2.name = "禁卫军"
                                p2.army = mail.gArmy.army
                                table.insert(temps, p1)
                                table.insert(temps, p2)
                                self:converge(temps, var)
                            else
                                local mFightData = self:setData(pSData, pShipData)
                                self:initFight(mFightData, var, pBool)
                            end
                        else
                            if mail["rType"] == 1 or mail["rType"] == 3 then
                                local temps = { }
                                local p1 = { }
                                p1.name = mail.gArmy.name
                                p1.army = mail["defender"]["fullinfo"]
                                table.insert(temps, p1)
                                local p2 = { }
                                p2.name = "禁卫军"
                                p2.army = mail.gArmy.army
                                table.insert(temps, p2)
                                self:converge(temps, var)
                            else
                                local mFightData = self:setData(pSData, pShipData)
                                self:initFight(mFightData, var, pBool)
                            end
                        end

                    else
                        local mFightData = self:setData(pSData, pShipData)
                        self:initFight(mFightData, var, pBool)
                    end
                end
            else
                me.assignWidget(self, "m_s_fight_type"):setVisible(false)
                if mail["rType"] > 2 then
                    self:converge(pSData, var)
                else
                    if mail.gArmy then
                        if var == 1 then
                            if mail["rType"] == 2 or mail["rType"] == 4 then
                                local temps = { }
                                local p1 = { }
                                p1.name = mail.gArmy.name
                                p1.army = mail["defender"]["fullinfo"]
                                local p2 = { }
                                p2.name = "禁卫军"
                                p2.army = mail.gArmy.army
                                table.insert(temps, p1)
                                table.insert(temps, p2)
                                self:converge(temps, var)
                            else
                                local mFightData = self:setData(pSData, pShipData)
                                self:initFight(mFightData, var, pBool)
                            end
                        else
                            if mail["rType"] == 1 or mail["rType"] == 3 then
                                local temps = { }
                                local p1 = { }
                                p1.name = mail.gArmy.name
                                p1.army = mail["defender"]["fullinfo"]
                                local p2 = { }
                                p2.name = "禁卫军"
                                p2.army = mail.gArmy.army
                                table.insert(temps, p1)
                                table.insert(temps, p2)
                                self:converge(temps, var)
                            else
                                local mFightData = self:setData(pSData, pShipData)
                                self:initFight(mFightData, var, pBool)
                            end
                        end
                    else
                        local mFightData = self:setData(pSData, pShipData)
                        self:initFight(mFightData, var, false)
                    end
                end
            end
        end
    end
end
function mailFightarm:setData(pSData, pShipData)
    local mFightData = { }
    if pShipData then
        local pData = { }
        pData.pType = 1
        -- 战舰
        pData.Fdata = pShipData
        table.insert(mFightData, pData)
    end
    if pSData then
        for key, var in pairs(pSData) do
            local pData = { }
            pData.pType = 2
            -- 士兵
            pData.Fdata = var
            table.insert(mFightData, pData)
        end
    end
    return mFightData
end
function mailFightarm:converge(pData, pId)
    local pNode = me.assignWidget(self, "Node_m_s_ourpar")
    if pId == 1 then
        pNode = me.assignWidget(self, "Node_m_s_ourpar")
    else
        pNode = me.assignWidget(self, "Node_m_s_otherside")
    end
    local pHeight = 0
    local pWidth = 373
    for key, var in pairs(pData) do
        pHeight = pHeight + 55
        if var.ship then
            pHeight = pHeight + 125
        end
        for key, var in pairs(var.army) do
            pHeight = pHeight + 125
        end
    end

    local pScrollView = cc.ScrollView:create()
    pScrollView:setViewSize(cc.size(pWidth, 418))
    pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pScrollView:setLocalZOrder(10)
    pScrollView:setAnchorPoint(cc.p(0, 0))
    pScrollView:setPosition(cc.p(2, 0))
    pScrollView:setContentSize(cc.size(pWidth, pHeight))
    pScrollView:setContentOffset(cc.p(0,(-(pHeight - 418))))
    pNode:addChild(pScrollView)

    local pNum = 0
    for key, var in pairs(pData) do

        pNum = pNum + 55
        local pConver = me.assignWidget(self, "converge_cell"):clone():setVisible(true)
        pConver:setAnchorPoint(cc.p(0, 0))
        local pConName = me.assignWidget(pConver, "converge_name")
        pConName:setString(var.name)
        pConver:setPosition(cc.p(0, pHeight - pNum))
        pScrollView:addChild(pConver)

        if var.ship then
            local pWData = { }
            pWData.pType = 1
            -- 士兵
            pWData.Fdata = var.ship
            pNum = pNum + 125
            local pMailFightarmCell = mailFightarmCell:create(self, "m_s_i_cell")
            pMailFightarmCell:setVisible(true)
            pMailFightarmCell:setAnchorPoint(cc.p(0, 0))
            pMailFightarmCell:setPosition(cc.p(2, pHeight - pNum))
            pMailFightarmCell:setDataFIFUI(pWData)
            pScrollView:addChild(pMailFightarmCell)
        end

        for key, var in pairs(var.army) do
            pNum = pNum + 125
            local pData = { }
            pData.pType = 2
            -- 士兵
            pData.Fdata = var
            local pMailFightarmCell = mailFightarmCell:create(self, "m_s_i_cell")
            pMailFightarmCell:setVisible(true)
            pMailFightarmCell:setAnchorPoint(cc.p(0, 0))
            pMailFightarmCell:setPosition(cc.p(2, pHeight - pNum))
            pMailFightarmCell:setDataFIFUI(pData)
            pScrollView:addChild(pMailFightarmCell)
        end
    end
end

function mailFightarm:setMailType(mailType)
    self.mailType = mailType
end

function mailFightarm:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)
end
function mailFightarm:onExit()
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end

