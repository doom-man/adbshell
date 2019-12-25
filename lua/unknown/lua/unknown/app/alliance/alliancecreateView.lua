-- 联盟创建 2015-12-14
alliancecreateView = class("alliancecreateView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
alliancecreateView.__index = alliancecreateView
function alliancecreateView:create(...)
    local layer = alliancecreateView.new(...)
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
 
function alliancecreateView:ctor()
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    -- 获取联盟列表
    NetMan:send(_MSG.getListFamily())
    -- 获取退盟之后的CD
    NetMan:send(_MSG.getAllianceCd())
    -- 获取邀请列表，计算小红点
    NetMan:send(_MSG.requestListFamily())
end
function alliancecreateView:close()
    self:removeFromParentAndCleanup(true)
end
function alliancecreateView:init()
    self.pAllianceList = { }
    self.joinCd = me.assignWidget(self, "joinCd")

    local function callFunc(event, sender)
        if event == "changed" then
            --
        end
    end
    self.listEb = me.addInputBox(420, 30, 20, nil, callFunc, cc.EDITBOX_INPUT_MODE_ANY, "请输入联盟名称")
    self.listEb:setAnchorPoint(0.5, 0.5)
    self.listEb:setPosition(cc.p(227.5, 24))
    self.listEb:setPlaceholderFontColor(cc.c3b(0x5a, 0x5a, 0x5a))
    self.listEb:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    me.assignWidget(self, "Image_9"):addChild(self.listEb)

    -- 创建联盟
    self.btn_create = me.registGuiClickEventByName(self, "Button_alliance_create", function(node)
        local view = AllianceCreateNewView:create("AllianceCreateNewView.csb")
        self:addChild(view, me.MAXZORDER)
        me.showLayer(view, "img_bg")
    end)

    -- 联盟邀请
    self.alliance_anvite_hint = me.assignWidget(self, "alliance_anvite_hint")
    self.btn_anvite = me.registGuiClickEventByName(self, "Button_alliance_anvite", function(node)
        local view = AllianceInviteNewView:create("AllianceInviteNewView.csb")
        self:addChild(view, me.MAXZORDER)
        me.showLayer(view, "img_bg")
        self.alliance_anvite_hint:setVisible(false)
    end )
    
    return true
end

function alliancecreateView:setAllianceType()
    -- 联盟列表
    me.assignWidget(self, "Node_tab_list"):removeAllChildren()
    self:setAlliancelist()
    local pTab = user.familyList
    self.pAllianceList = { }
    for key, var in pairs(pTab) do
        table.insert(self.pAllianceList, var)
    end
    if table.maxn(self.pAllianceList) ~= 0 then
        self:initTable(self.pAllianceList)
    end
end
function alliancecreateView:allianceApply(pName)
    if me.isValidStr(pName) then
         NetMan:send(_MSG.applyFamilyByName(pName))
    else
        showTips("联盟名称不能为空")
    end
end
-- 联盟申请
function alliancecreateView:setAlliancelist()
    --    self.allianceLName = nil   -- 联盟申请的名称
    -- 输入联盟名称输入框
    --     local pInputLName = me.assignWidget(self,"application_input")
    --      local function alliance_name_list_input_regist_callback(sender,eventType)
    --        if eventType == ccui.TextFiledEventType.attach_with_ime then
    --            local textField = sender
    --            textField:runAction(cc.MoveBy:create(0.225,cc.p(0, 20)))

    --        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
    --            local textField = sender
    --            textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))      -- 输入完成触屏

    --        elseif eventType == ccui.TextFiledEventType.insert_text then
    --            self.allianceLName = sender:getString()                          -- 输入完成

    --        elseif eventType == ccui.TextFiledEventType.delete_backward then
    --            self.allianceLName = sender:getString()
    --        end
    --    end
    --    pInputLName:addEventListener(alliance_name_list_input_regist_callback)

    -- 申请按钮
    local pApplicationButton = me.assignWidget(self, "application_Button")
    me.registGuiClickEvent(pApplicationButton, function(node)
        if self.listEb:getText() ~= nil then
            self:allianceApply(self.listEb:getText())
        else
            showTips("申请的联盟名称不能为空")
        end
    end )
end
function alliancecreateView:initTable(pMailFiTab)
    local iNum = #pMailFiTab
    local pHeight = 345
    local pNode = me.assignWidget(self, "Node_tab_list")
    local pType = true
    
    local function cellSizeForTable(table, idx)
        return 1158, 70
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pAllianceCell = alliancecrcell:create(self, "alliance_cr_cell")
            pAllianceCell:setVisible(true)
            pAllianceCell:setData(pMailFiTab[idx + 1], pType)
            me.assignWidget(pAllianceCell, "Panel_16"):setVisible(idx % 2 ~= 0)
            -- 联盟申请
            local pButtonAdd = me.assignWidget(pAllianceCell, "Button_Application_add")
            pButtonAdd:setTag(idx + 1)
            local pBuutonList = me.registGuiClickEventByName(pAllianceCell, "Button_Application_add", function(node)
                local pIdx = node:getTag()
                NetMan:send(_MSG.applyFamily(pMailFiTab[pIdx]["uid"]))
                -- 申请联盟

            end )
            pBuutonList:setSwallowTouches(false)
            pAllianceCell:setPosition(cc.p(0, 0))
            cell:addChild(pAllianceCell)
        else
            local pAllianceCell = me.assignWidget(cell, "alliance_cr_cell")
            pAllianceCell:setData(pMailFiTab[idx + 1], pType)
            me.assignWidget(pAllianceCell, "Panel_16"):setVisible(idx % 2 ~= 0)
            local pButtonAdd = me.assignWidget(pAllianceCell, "Button_Application_add")
            pButtonAdd:setTag(idx + 1)  
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end
    local tableView = cc.TableView:create(cc.size(1158, pHeight))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 95))
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

function alliancecreateView:update(msg)
    -- 创建联盟成功
    if checkMsg(msg.t, MsgCode.FAMILY_CREATE) then
        self:close()
        NetMan:send(_MSG.getFamilyInfor())
    -- 创建联盟失败
    elseif checkMsg(msg.t, MsgCode.FAMILY_CREATE_ERROR) then
        -- local alertId=msg.c.alertId -- 440失败
        -- local alertId=msg.c.alertId -- 450-家族名字不匹配 451-家族公告不匹配 408-钻石不足
        -- if  alertId == 450 then
        --     print("家族名字不匹配")
        --     showTips("联盟名字不匹配")
        -- elseif alertId==451 then
        --     print("家族公告不匹配")
        --     showTips("家族公告不匹配")
        -- elseif alertId ==503 then
        --     print("金币不足")
        --     showTips("金币不足")
        -- elseif alertId == 563 then
        --     print("还不能创建或加入联盟")
        --     showTips("还不能创建或加入联盟")
        -- end
    -- 获取联盟列表
    elseif checkMsg(msg.t, MsgCode.FAMILY_LIST) then
        self:setAllianceType()
    -- 申请加入联盟（需要等待盟主同意）
    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY) then
        self:setAllianceType()
    -- 自己同意某个联盟邀请 或者 申请加入联盟(直接入盟成功)
    elseif checkMsg(msg.t, MsgCode.FAMILY_INIT) then
        self:close()
    -- 申请加入联盟失败
    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY_ERROR) then
        -- local alertId=msg.c.alertId -- 440失败
        --  if  alertId == 440 then
        --      showTips("等级或者战力不足")
        --  end
    -- 获取退盟之后的CD
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_CD) then
        self.recvTime = os.time()
        self:showCdTime(msg)
    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST_LIST) then
        -- 小红点
        local pTab = user.familyRequestList
        if table.maxn(pTab) > 0 then
            self.alliance_anvite_hint:setVisible(true)
        else
            self.alliance_anvite_hint:setVisible(false)
        end
    end
end
function alliancecreateView:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)
    -- 联盟好处提示页面
    local view = AllianceTipView:create("AllianceTipView.csb")
    self:addChild(view, me.MAXZORDER)
    me.showLayer(view, "img_bg")
end
function alliancecreateView:onExit()
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    me.clearTimer(self.timer)
end

function alliancecreateView:showCdTime(msg)
    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end
    if msg then
        if msg.c.time then
            self.cdCountDown = msg.c.time
            if self.cdCountDown > 0 then
                local cdText = self.joinCd
                if cdText then
                    cdText:setString(me.formartSecTime(self.cdCountDown))
                    cdText:setVisible(true)
                    local t = 1
                    self.timer = me.registTimer(-1, function(dt)
                        local time = self.cdCountDown - t
                        if time >= 0 then
                            cdText:setString(me.formartSecTime(time))
                            t = t + 1
                        else
                            me.clearTimer(self.timer)
                            self.timer = nil
                            self.joinCd:setVisible(false)
                        end
                    end , 1)
                end
            end
        end
    else
        if self.cdCountDown and self.recvTime then
            local restTime = self.cdCountDown -(os.time() - self.recvTime)
            if restTime > 0 then
                local cdText = self.joinCd
                if cdText then
                    cdText:setString(me.formartSecTime(restTime))
                    cdText:setVisible(true)
                    local t = 1
                    self.timer = me.registTimer(-1, function(dt)
                        local time = restTime - t
                        if time >= 0 then
                            cdText:setString(me.formartSecTime(time))
                            t = t + 1
                        else
                            me.clearTimer(self.timer)
                            self.timer = nil
                            self.joinCd:setVisible(false)
                        end
                    end , 1)
                end
            end
        end
    end
end