sendMailCell = class("sendMailCell ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
sendMailCell._index = sendMailCell

function sendMailCell:create(csb)
    local layer = sendMailCell.new(csb)
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

function sendMailCell:ctor()
    self.balabala = "" --邮件内容
    self.title = "" --邮件标题
    self.layout = nil
    self.tableView = nil
    self.memberList = {}
    self.mailName = ""
    self.pParent = nil
    self.mType = mCross_Sever_Out -- 游戏服
end

function sendMailCell:init()
    print("sendMailCell init")
    self.TextField_balabla = me.assignWidget(self, "TextField_balabla")
    self.TextField_title = me.assignWidget(self, "TextField_title")
    self.TextField_name = me.assignWidget(self, "TextField_name")
    
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    me.registGuiClickEventByName(self,"Button_list",function (node)
        if user.familyUid == 0 then
            showTips("您还未加入任何联盟")
            return 
        end
        if #self.memberList <= 0 then
            NetMan:send(_MSG.getListMember())
        else
            self:openFamilyList()
        end
    end)
    me.registGuiClickEventByName(self, "Button_send", function(node)
        if self.TextField_name:getString() == "" then
            showTips("请填写收件人")
            return
        end
        local pTilte = self.title
        local fromAutoTitle = false
        if self.title == "" then
            fromAutoTitle = true
            self.title = ""
        end
        if pTilte == "" then
           self.Sendtitle = "寄给"..self.TextField_name:getString().."的邮件"
        else
           self.Sendtitle = pTilte
        end
        if getStringLength(self.title) > 25 and  fromAutoTitle == false then
            showTips("标题不能超过12字")
            return 
        end
        
        if getStringLength(self.balabala) == 0  then          
            showTips("邮件内容不能为空")
            return
        end
    
        if getStringLength(self.balabala) > 200 then
            showTips("发送内容不能超过100字")
            return 
        end
        dump(self.mType)
        if self.mType == mCross_Sever_Out then
            if self.mailType==mailview.MAILUNION then
                NetMan:send(_MSG.unionMail(self.title,self.balabala))
            else
                NetMan:send(_MSG.chatMail(self.TextField_name:getString(),self.title,self.balabala))
            end 
        elseif self.mType == mCross_Sever then
           netBattleMan:send(_MSG.chatMail(self.TextField_name:getString(),self.title,self.balabala))
        end
        showWaitLayer()
    end )
    

    self.TextField_title:addEventListener(function (sender, eventType)
        if eventType == ccui.TextFiledEventType.insert_text then
            self.title = sender:getString()
        elseif eventType == ccui.TextFiledEventType.delete_backward then
            self.title = sender:getString()
        end
    end)
    local y = self.TextField_balabla:getParent():getPositionY()
    local x = self.TextField_balabla:getParent():getPositionX()
    self.TextField_balabla:addEventListener(function (sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
--            sender:getParent():runAction(cc.MoveTo:create(0.225, cc.p(x, 
--            me.winSize.height/2

--            )))
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
             --sender:getParent():runAction(cc.MoveTo:create(0.175, cc.p(x, y)))
        elseif eventType == ccui.TextFiledEventType.insert_text then
            self.balabala = sender:getString()
        elseif eventType == ccui.TextFiledEventType.delete_backward then
            self.balabala = sender:getString()
        end
    end)    
    return true
end
function sendMailCell:sendMailCallBack(msg)
    if msg.c.alertId and me.toNum(msg.c.alertId) == 557 then
        showTips("玩家不存在")
    elseif msg.c.alertId and me.toNum(msg.c.alertId) == 558 then
        showTips("不能给自己发邮件")
    elseif msg.c.alertId and me.toNum(msg.c.alertId) == 463 then
        showTips("含非法字符")
    elseif msg.c.alertId and me.toNum(msg.c.alertId) == 202 then
        showTips("名字长度不正确")
    elseif msg.c.alertId and me.toNum(msg.c.alertId) == 996 then
        showTips("主城等级不足10级")
    elseif msg.c.alertId and me.toNum(msg.c.alertId) == 997 then
        showTips("您已被禁言")
    elseif msg.c.alertId and me.toNum(msg.c.alertId) == 559 then
        showTips("发送成功")
        --保存本地一份
        --SharedDataStorageHelper():setWroteMail(self.TextField_name:getString(),self.Sendtitle,self.balabala,me.sysTime(),self.mType)
        --if self.pParent ~= nil then
        --    self.pParent:setMailData()
        --end
        self:removeFromParent()         
    end
end

function sendMailCell:setMailType(mailType)
    self.mailType = mailType
    if self.mailType==mailview.MAILPERSONAL then
        me.assignWidget(self, "Button_list"):setVisible(true)
        self.TextField_name:setEnabled(true)
    elseif self.mailType==mailview.MAILUNION then
        me.assignWidget(self, "Button_list"):setVisible(false)
        if self.mailName=="" then
            self.mailName = "联盟全体成员"
        end
        self.TextField_name:setEnabled(false)
    end
end

function sendMailCell:setData(uid_,name_,pType)
    self.mailName = name_
    dump(pType)
    self.mType = pType
--    self.playerUid = uid_
end
function sendMailCell:setParentNode(node)
      self.pParent = node
end
function sendMailCell:onEnter()
    print("sendMailCell:onEnter()")
    self.TextField_name:setString(self.mailName)
    self.lisener = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) then
            self:receiveListData(msg)
            self:openFamilyList()
         elseif checkMsg(msg.t, MsgCode.CHAT_MAIL) or checkMsg(msg.t, MsgCode.UNION_MAIL) then
            disWaitLayer()
            self:sendMailCallBack(msg)
        end
    end)
    me.doLayout(self,me.winSize)  
end

function sendMailCell:receiveListData(msg)
    for key, var in pairs(msg.c.list) do
        if me.toNum(user.uid) ~= me.toNum(var.uid) then
            self.memberList[#self.memberList+1]  = {["uid"] = var.uid,["name"] = var.name}
        end
    end
end

function sendMailCell:onExit()
    UserModel:removeLisener(self.lisener) -- 删除消息通知
end

function sendMailCell:openFamilyList()
    if self.layout == nil then
        self.layout = ccui.Layout:create() 
        self.layout:setContentSize(cc.size(me.winSize.width,me.winSize.height))
        self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        self.layout:setBackGroundColor(cc.c3b(0,0,0))
        self.layout:setBackGroundColorOpacity(165)
        self.layout:setAnchorPoint(cc.p(0,0))
        self.layout:setPosition(cc.p(0,0))
        self.layout:setSwallowTouches(true)  
        self.layout:setTouchEnabled(true)
        self:addChild(self.layout,me.MAXZORDER)
    end
    local list = me.assignWidget(self, "Panel_list"):clone()
    self.layout:addChild(list,me.MAXZORDER)
    list:setVisible(true)
    list:setAnchorPoint(cc.p(0.5,0.5))
    list:setPosition(cc.p(me.winSize.width/2,me.winSize.height/2))

    me.registGuiTouchEvent(self.layout,function (node,event)
        if event ~= ccui.TouchEventType.ended then
            return
        end 
        self:closeList()
    end)
    me.registGuiClickEventByName(self.layout,"close_0",function (node)
        self:closeList()
    end)
    self:initTableList()
end

function sendMailCell:closeList()
    self.tableView:removeFromParent()
    self.tableView= nil
    self.layout:removeFromParent()
    self.layout = nil
end

function sendMailCell:initTableList()
   local function cellSizeForTable(table, idx)
        return 431, 75
    end
    function numberOfCellsInTableView(table)
        return #self.memberList
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item = me.assignWidget(self,"Panel_cell"):clone()
            item:setVisible(true)
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            cell:addChild(item)  
        end
        local data = self.memberList[idx+1]
        me.assignWidget(cell,"Text_cell_name"):setString(data.name)
        return cell
    end
    
    local function tableCellTouched(table, cell)    
        local data = self.memberList[cell:getIdx()+1]
        self.mailName = data.name
        self.TextField_name:setString(self.mailName)
--        self.playerUid = data.uid
        me.DelayRun(function ()
            self:closeList()
        end,0.1)
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(431,489))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(1,0)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        me.assignWidget(self.layout,"Panel_table"):addChild(self.tableView)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end