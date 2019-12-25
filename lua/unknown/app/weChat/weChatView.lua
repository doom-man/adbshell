weChatView = class("weChatView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
weChatView._index = weChatView

weChatView.trumpetType_Blue = 901  -- 蓝色
weChatView.trumpetType_Yellow = 902 -- 黄色
weChatView.trumpetType_Purple = 903 -- 紫色
weChatView.costDiamondNum = 0

lastSendChatMsgTime = 0
lastCampChatMsgTime = 0
lastCrossChatMsgTime = 0
lastCampChatMsgTime = 0
function weChatView:create(csb)
    local layer = weChatView.new(csb)
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

function weChatView:ctor()
    print("weChatView ctor")
     self.isShow = false
end

function weChatView:showChatView()
    self.fixLayout:stopAllActions()
    
    if self.isShow==false then
        local callback = cc.CallFunc:create(function()
            me.assignWidget(self, "maskLayer"):setSwallowTouches(false)
        end)
        self.isShow = true
        self.fixLayout:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(0, 0)), callback))
    else
        self.isShow = false
        local callback = cc.CallFunc:create(function()
            self:close()
        end)
        self.fixLayout:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-775, 0)), callback))
    end
end

function weChatView:init()
    print("weChatView init")
    self.chat_world = me.assignWidget(self, "chat_world")
    self.chat_system = me.assignWidget(self, "chat_system")
    self.chat_union = me.assignWidget(self, "chat_union")
    self.chat_camp = me.assignWidget(self, "chat_camp")
    -- 阵营
    self.chat_trumpet = me.assignWidget(self, "chat_trumpet")
    -- 全服
    self.chat_cross = me.assignWidget(self, "chat_Cross")
    -- 跨服
    self.bg_input = me.assignWidget(self, "bg_input")
    -- 普通聊天框
    self.bg_input_Cross = me.assignWidget(self, "bg_input_Cross")
    -- 跨服聊天框
    self.Text_trumpet_msg = me.assignWidget(self, "Text_trumpet_msg")
    self.Button_crosss_yellow = me.assignWidget(self.bg_input_Cross, "Button_crosss_yellow")
    self.Button_crosss_blue = me.assignWidget(self.bg_input_Cross, "Button_crosss_blue")
    self.Button_crosss_purple = me.assignWidget(self.bg_input_Cross, "Button_crosss_purple")
    self.Buttons_cross = { }
    self.Buttons_cross[weChatView.trumpetType_Yellow] = self.Button_crosss_yellow
    self.Buttons_cross[weChatView.trumpetType_Blue] = self.Button_crosss_blue
    self.Buttons_cross[weChatView.trumpetType_Purple] = self.Button_crosss_purple
    -- self.TextField_msg = me.assignWidget(self, "TextField_msg")
    if user.Cross_Sever_Status == mCross_Sever_Out then
        self.chat_camp:setVisible(false)
        self.chat_cross:setVisible(false)
    else
        self.chat_camp:setVisible(true)
        self.chat_cross:setVisible(true)
    end

    self.joinUnionBtn = me.assignWidget(self, "joinUnionBtn")
    me.registGuiClickEvent(self.joinUnionBtn, function(node, event)
        local alliancecreateView = alliancecreateView:create("alliance/alliancecreate.csb")
        me.runningScene():addChild(alliancecreateView, me.MAXZORDER)
    end )

    self.preRichTxt600 = mRichText:create("", 447)
    self.preRichTxt600:retain()
    self.preRichTxt800 = mRichText:create("", 790)
    self.preRichTxt800:retain()

    self.tableView = nil
    self.Panel_Info = me.assignWidget(self, "Panel_Info")
    self.bg_right = me.assignWidget(self, "bg_right")
    self.Button_send = me.assignWidget(self, "Button_send")
    self.Button_trumpet_send = me.assignWidget(self, "Button_trumpet_send")
    self.Text_countdown = me.assignWidget(self, "Text_countdown")
    self.Button_send_unit = me.assignWidget(self, "Button_send_unit")
    self.currentNode = nil
    -- 当前分页
    self.listener = nil
    self.selecetData = nil
    -- 选择查看的玩家数据
    local function msgEbCallFunc(eventType, sender)
        if eventType == "began" then
            if self.tableView and self.tableView.setTouchEnabled then
                self.tableView:setTouchEnabled(false)
            end
        elseif eventType == "return" then
            if self.tableView and self.tableView.setTouchEnabled then
                self.tableView:setTouchEnabled(true)
            end
        end
    end
    self.msgEb = me.addInputBox(366.90, 47, 20, nil, msgEbCallFunc, cc.EDITBOX_INPUT_MODE_ANY, "发送内容不能超过60字")
    self.msgEb:setMaxLength(60)
    self.msgEb:setAnchorPoint(0, 0)
    self.msgEb:setPosition(20.25,22)
    self.msgEb:setFontColor(cc.c3b(82,72,55))
    me.assignWidget(self, "bg_input"):addChild(self.msgEb)

    me.registGuiTouchEventByName(self, "chat_world", function(node, event)
        if event ~= ccui.TouchEventType.ended or self.currentNode == node then
            return
        end
        self:setChannel(node)
        self:initChat()
    end )
    me.registGuiClickEvent(self.chat_system, function(node)
        self:setChannel(node)
        self:initChat()
    end )
    me.registGuiTouchEventByName(self, "chat_union", function(node, event)
        if event ~= ccui.TouchEventType.ended or self.currentNode == node then
            return
        end
        self:setChannel(node)
    end )
    me.registGuiTouchEventByName(self, "chat_camp", function(node, event)
        if event ~= ccui.TouchEventType.ended or self.currentNode == node then
            return
        end
        self:setChannel(node)
        self:initChat()
    end )
    me.registGuiTouchEventByName(self, "chat_Cross", function(node, event)
        if event ~= ccui.TouchEventType.ended or self.currentNode == node then
            return
        end
        self:setChannel(node)
        self:initChat()
    end )
    me.registGuiTouchEventByName(self, "chat_trumpet", function(node, event)
        if event ~= ccui.TouchEventType.ended or self.currentNode == node then
            return
        end
        self:flushPackageTrumpet()
        self:setChannel(node)
        self:initChat()
    end )

    me.registGuiClickEventByName(self, "closeBtn", function(node)
        self:showChatView()
    end )

    me.registGuiClickEventByName(self, "bg_input_Cross", function(node)
        self:popupChat_CrossView(self.Buttons_cross[self.currentTrumpetType])
    end )

    for key, var in pairs(self.Buttons_cross) do
        me.registGuiClickEvent(var, function(node)
            self:popupChat_CrossView(node)
        end )
    end

    local function sendChatMsg(node_)
        local sendMsg = self.msgEb:getText()
        if node_ == self.Button_trumpet_send then
            sendMsg = self.Text_trumpet_msg:getString()
        else
            sendMsg = self.msgEb:getText()
        end
        sendMsg = me.filter_spec_chars(sendMsg)
        if sendMsg == "" or sendMsg == nil then
            showTips("没有可以发送的内容")
            return false
        end
        if string.len(sendMsg) > 180 then
            showTips("发送内容不能超过60字")
            return false
        end
        if node_ == self.Button_send then
            if self.currentNode == self.chat_world then
                NetMan:send(_MSG.worldChat(sendMsg))
            elseif self.currentNode == self.chat_camp then
                GMan():send(_MSG.Camp_Chat_Info(sendMsg))
            elseif self.currentNode == self.chat_cross then
                GMan():send(_MSG.Cross_Chat_Info(sendMsg))
            end
        elseif node_ == self.Button_send_unit then
            NetMan:send(_MSG.famliyChat(sendMsg))
        elseif node_ == self.Button_trumpet_send then
            if self.Text_trumpet_msg:getTag() == 0 then
                showTips("没有可以发送的内容")
                return
            end
            if self.trumpetQuilty[self.currentTrumpetType] > 0 then
                self.Text_trumpet_msg:setTextColor(COLOR_GRAY)
                self.Text_trumpet_msg:setTag(0)
                self.Text_trumpet_msg:setString("发送内容不能超过60字")
                NetMan:send(_MSG.Cross_Chat_Trumpet(self.currentTrumpetType % 10, sendMsg))
            else
                local tipsTxt_trumppet = ""
                if self.currentTrumpetType == weChatView.trumpetType_Blue then
                    tipsTxt_trumppet, weChatView.costDiamondNum = "蓝喇叭", "10"
                elseif self.currentTrumpetType == weChatView.trumpetType_Yellow then
                    tipsTxt_trumppet, weChatView.costDiamondNum = "黄喇叭", "20"
                elseif self.currentTrumpetType == weChatView.trumpetType_Purple then
                    tipsTxt_trumppet, weChatView.costDiamondNum = "紫喇叭", "50"
                end
                local tipsTxt = tipsTxt_trumppet .. "不足，本次发言需要消耗" .. weChatView.costDiamondNum .. "钻石，是否继续？"
                me.showMessageDialog(tipsTxt, function(args)
                    if args == "ok" then
                        if user.diamond >= me.toNum(weChatView.costDiamondNum) then
                            self.Text_trumpet_msg:setTextColor(COLOR_GRAY)
                            self.Text_trumpet_msg:setTag(0)
                            self.Text_trumpet_msg:setString("发送内容不能超过60字")
                            NetMan:send(_MSG.Cross_Chat_Trumpet(self.currentTrumpetType % 10, sendMsg))
                        else
                            showTips("钻石不足!")
                        end
                    end
                end )
            end
        end
        self.msgEb:setText("")
        return true
    end

    me.registGuiClickEventByName(self, "Button_send_unit", function(node)
        sendChatMsg(self.Button_send_unit)
    end )
    me.registGuiClickEventByName(self, "Button_trumpet_send", function(node)
        sendChatMsg(self.Button_trumpet_send)
    end )
    me.registGuiClickEventByName(self, "Button_send", function(node)
        if sendChatMsg(self.Button_send) then
            if self.currentNode == self.chat_world then
                lastSendChatMsgTime = me.sysTime()
            elseif self.currentNode == self.chat_camp then
                lastCampChatMsgTime = me.sysTime()
            elseif self.currentNode == self.chat_cross then
                lastCrossChatMsgTime = me.sysTime()
            end
        end
    end )

    self.chatCountDownTimer = me.registTimer(-1, function(dt)
        self:updateCountdown(dt)
    end )

    self.fixLayout = me.assignWidget(self, "fixLayout")
   
    return true
end

function weChatView:onEnter()
    print("weChatView:onEnter()")
    self:initChat()
    self:initTableView()
    self:setChannel(self.chat_world)
    self.listener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.GET_CHAT_RECORD) then
            self:resetTableView()
        elseif self.currentNode == self.chat_union and checkMsg(msg.t, MsgCode.FAMLIY_CHAT_INFO) then
            self:resetTableView()
        elseif self.currentNode == self.chat_world and checkMsg(msg.t, MsgCode.WORLD_CHAT_INFO) then
            self:resetTableView()
        elseif self.currentNode == self.chat_camp and checkMsg(msg.t, MsgCode.CAMOP_CHAT_INFO) then
            self:resetTableView()
        elseif self.currentNode == self.chat_cross and checkMsg(msg.t, MsgCode.CROSS_CHAT_INFO) then
            self:resetTableView()
        elseif self.currentNode == self.chat_trumpet and checkMsg(msg.t, MsgCode.CROSS_CHAT_TRUMPET) then
            self:flushPackageTrumpet()
            self:resetTableView()
        end
    end )
    self.close_event = me.RegistCustomEvent("weChatView", function(evt)
        self:close()
    end )
    me.doLayout(self, me.winSize)
    self.fixLayout:setPositionX(-775)
    print(self.fixLayout:getPositionX())
    me.DelayRun(function()
        self:showChatView()
    end, 0.1)

end

-- 弹出跨服小喇叭输入窗
function weChatView:popupChat_CrossView(tpye_)
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
    local Panel_trumpetView = me.assignWidget(self, "Panel_trumpetView"):clone()
    me.doLayout(Panel_trumpetView, me.winSize)
    Panel_trumpetView:setTouchEnabled(true)
    Panel_trumpetView:setSwallowTouches(true)
    self.layout:addChild(Panel_trumpetView)
    Panel_trumpetView:setVisible(true)
    Panel_trumpetView:setAnchorPoint(cc.p(0.5, 0.5))
    Panel_trumpetView:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    me.registGuiClickEvent(me.assignWidget(Panel_trumpetView, "close_trumpet"), function()
        self.layout:removeFromParent()
        self.layout = nil
    end )
    local Text_trumpetType = me.assignWidget(Panel_trumpetView, "Text_trumpetType")
    local Text_leftTrumpet = me.assignWidget(Panel_trumpetView, "Text_leftTrumpet")
    if tpye_ == self.Button_crosss_blue then
        Text_trumpetType:setString("蓝喇叭")
        self.currentTrumpetType = weChatView.trumpetType_Blue
        Text_leftTrumpet:setString("剩余蓝喇叭:" .. self.trumpetQuilty[self.currentTrumpetType])
    elseif tpye_ == self.Button_crosss_yellow then
        Text_trumpetType:setString("黄喇叭")
        self.currentTrumpetType = weChatView.trumpetType_Yellow
        Text_leftTrumpet:setString("剩余黄喇叭:" .. self.trumpetQuilty[self.currentTrumpetType])
    elseif tpye_ == self.Button_crosss_purple then
        Text_trumpetType:setString("紫喇叭")
        self.currentTrumpetType = weChatView.trumpetType_Purple
        Text_leftTrumpet:setString("剩余紫喇叭:" .. self.trumpetQuilty[self.currentTrumpetType])
    end
    local trumpetEb = me.addInputBox(470, 239, 24, nil, msgEbCallFunc, cc.EDITBOX_INPUT_MODE_ANY, "发送内容不能超过60字")
    trumpetEb:setMaxLength(60)
    trumpetEb:setAnchorPoint(0, 0)
    me.assignWidget(Panel_trumpetView, "TextField_msg_trumpet"):addChild(trumpetEb)
    me.registGuiClickEvent(me.assignWidget(Panel_trumpetView, "Button_trumpet"), function()
        -- 发送信息
        if string.len(trumpetEb:getText()) > 180 then
            showTips("发送内容不能超过60字")
            return false
        end
        self.Text_trumpet_msg:setTextColor(COLOR_WHITE)
        self.Text_trumpet_msg:setTag(1)
        self.Text_trumpet_msg:setString(trumpetEb:getText())
        self.layout:removeFromParent()
        self.layout = nil
    end )
end
function weChatView:updateCountdown(dt)
    if self.currentNode == self.chat_world then
        if (me.sysTime() - lastSendChatMsgTime) / 1000 > 10 then
            self:setButtonsend()
        else
            self:setButtonCountdown(math.floor(10 -(me.sysTime() - lastSendChatMsgTime) / 1000))
        end
        self.bg_input:setVisible(true)
    elseif self.currentNode == self.chat_camp then
        -- 阵营
        -- lastCampChatMsgTime
        if (me.sysTime() - lastCampChatMsgTime) / 1000 > 10 then
            self:setButtonsend()
        else
            self:setButtonCountdown(math.floor(10 -(me.sysTime() - lastCampChatMsgTime) / 1000))
        end
        self.bg_input:setVisible(true)
    elseif self.currentNode == self.chat_cross then
        -- 阵营
        -- lastCrossChatMsgTime
        if (me.sysTime() - lastCrossChatMsgTime) / 1000 > 10 then
            self:setButtonsend()
        else
            self:setButtonCountdown(math.floor(10 -(me.sysTime() - lastCrossChatMsgTime) / 1000))
        end
        self.bg_input:setVisible(true)
    elseif self.currentNode == self.chat_system then
        -- 系统
        self.bg_input:setVisible(false)
    end
end
function weChatView:initChat()
    if self.currentNode == self.chat_world then
        self.bg_input:setVisible(true)
    elseif self.currentNode == self.chat_camp then
        -- 阵营
        -- lastCampChatMsgTime
        self:setButtonsend()
        self.bg_input:setVisible(true)
    elseif self.currentNode == self.chat_cross then
        -- 阵营
        -- lastCrossChatMsgTime
        self:setButtonsend()
        self.bg_input:setVisible(true)
    elseif self.currentNode == self.chat_system then
        -- 系统
        self.bg_input:setVisible(false)
    end
end
function weChatView:setButtonsend()
    me.setButtonDisable(self.Button_send, true)
    self.Text_countdown:setString("发 送")
    self.Text_countdown:setColor(cc.c4b(255, 255, 255, 255))
end 
function weChatView:setButtonCountdown(t)
    me.setButtonDisable(self.Button_send, false)
    self.Text_countdown:setString(t)
    self.Text_countdown:setColor(me.convert3Color_("E57F12"))
end 
function weChatView:initTableView()
    local cellw = 557
    local cellh = 110
    local function cellSizeForTable(table, idx)
        local d=nil
        if self.currentNode ~= self.chat_system then
            d = self:getMsgTypeData()[me.toNum(idx + 1)]
        else
            d=mNoticeInfo[self:getMsgTypeNum() - idx]
        end
        if d.lineHeight==nil then
            local text=nil
            if self.currentNode ~= self.chat_system then
                if d.noticeId then
                    text = rebuildChatString(d.content, d.noticeId)
                elseif d.uid and d.uid == 0 then

                    text = rebuildChatString(d.content, nil, d.uid)
                else
                    text = rebuildChatString(d.content)
                end
            else
                text, _ = getInforStr(mNoticeInfo[self:getMsgTypeNum() - idx])
            end
            local rsize
            if d.head and d.head > 0 then
                self.preRichTxt600:setString(parsePosition(text, 13, nil, 13, nil, true))
                rsize = self.preRichTxt600:getContentSize()
                d.lineHeight=111+(rsize.height-55>0 and rsize.height-55+5 or 0)
            else
                --self.preRichTxt800:setString(text)
                --rsize = self.preRichTxt800:getContentSize()
                --d.lineHeight=145+rsize.height-25+10
                d.lineHeight=111
            end
        end        
        return cellw, d.lineHeight
    end
    function numberOfCellsInTableView(table)
        return self:getMsgTypeNum()
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item = me.assignWidget(self, "Button_item"):clone()
            item:setVisible(true)
            item:setAnchorPoint(cc.p(0, 0))
            item:setPosition(cc.p(0, 0))
            cell:addChild(item)
        end
        local str = ""
        local img_head = me.assignWidget(cell, "img_head")
        img_head:ignoreContentAdaptWithSize(true)
        img_head:setVisible(false)
        local img_head_up = me.assignWidget(cell, "img_head_up")

        local roleTitle = me.assignWidget(cell, "roleTitle")
        local Text_RoleTitle = me.assignWidget(roleTitle, "Text_RoleTitle")
        local degree = me.assignWidget(cell, "degree")
        local Text_worldDegree = me.assignWidget(degree, "Text_worldDegree")
        local Text_Alliance = me.assignWidget(cell, "Text_Alliance")
        local Text_Name = me.assignWidget(cell, "Text_Name")
        local Image_vip = me.assignWidget(cell,"Image_vip")
        local vip = me.assignWidget(cell,"vip")    
        roleTitle:setVisible(false)
        Text_Alliance:setVisible(false)
        Text_Name:setVisible(false)
        
        degree:setVisible(false)
        local ofw = 95.76
        if self.currentNode ~= self.chat_system then
            img_head_up:setVisible(true)

            local d = self:getMsgTypeData()[me.toNum(idx + 1)]
            local item = me.assignWidget(cell, "Button_item")
            item:setTag(d.uid)
            item:setPosition(cc.p(0, d.lineHeight-117))
            -- 头像
            if d.head and d.head > 0 then
                img_head:setVisible(true)
                local cfg = cfg[CfgType.ROLE_HEAD]
                img_head:loadTexture(cfg[d.head].icon..".png", me.localType)
                me.resizeImage(img_head, 110, 110)
            end
            if d.worldDegree and d.worldDegree>0 then
                degree:setVisible(true)
                local tmpDef = cfg[CfgType.KINGDOM_OFFICER][d.worldDegree]
                Text_worldDegree:setString(tmpDef.icon)
            end
            
            local aname = ""
            if me.isValidStr(d.camp) then
                aname = aname .. d.camp
            end
            if (d.shorName and d.degree) then
                aname = aname .. "[" .. d.shorName .. "]" .. me.alliancedegree(d.degree)
            end
            if me.isValidStr(aname) then
                Text_Alliance:setVisible(true)
                Text_Alliance:setString(aname)
                Text_Alliance:setPositionX(ofw)
                ofw = ofw + Text_Alliance:getContentSize().width
            end

            local rnmae = ""
            if d.uid == user.uid then
                rnmae = "我"
                ofw = 95.76
                Text_Name:setTextColor(me.convert3Color_("e4cb79"))                
                Text_Alliance:setVisible(false)                
            else
                ofw = ofw + 3
                rnmae = d.name
                Text_Name:setTextColor(me.convert3Color_("e4cb79"))
            end
            Image_vip:setVisible(d.vip>0)
            vip:setString(d.vip)
            Text_Name:setVisible(true)
            Text_Name:setString(rnmae)
            Text_Name:setPosition(ofw, 87)
            local timestr = me.assignWidget(cell, "Text_status")
            timestr:setTextColor(me.convert3Color_("787d78"))
            timestr:setString(getTime(d.date / 1000))
            timestr:setPositionY(99.59)

            ofw = ofw + Text_Name:getContentSize().width
            if d.title and d.title > 0 then
                roleTitle:setVisible(true)
                local c ,_ = me.getColorByQuality(cfg[CfgType.ROLE_TITLE][tonumber(d.title)].quality)
                Text_RoleTitle:setTextColor(c)
                Text_RoleTitle:setString("☆" .. cfg[CfgType.ROLE_TITLE][tonumber(d.title)].name .. "☆")
                roleTitle:setPositionX(ofw+12)
            end 

            --[[
            local rtx = mRichText:create(str, 600)
            rtx:setTag(0xff2345)
            rtx:setPosition(10, 100)
            me.assignWidget(cell, "Button_item"):addChild(rtx)
            ]]
            local contentCol = "f8f0d2"
            local text = nil
            if d.noticeId and d.noticeId == 1004 then
                -- 天降红包，不用解析坐标
                text = rebuildChatString(d.content, d.noticeId)
            elseif d.noticeId and(d.noticeId == weChatView.trumpetType_Purple or d.noticeId == weChatView.trumpetType_Blue or d.noticeId == 1005 or d.noticeId == 1002 or d.noticeId == 1003 or d.noticeId == 1011 or d.noticeId == 1012) then
                -- 需要解析坐标
                text = parseRichtText(rebuildChatString(d.content, d.noticeId), 13, nil, 13)
            elseif d.noticeId and (d.noticeId == 1006 or d.noticeId == 1007 or d.noticeId == 1008 or d.noticeId == 1009 or d.noticeId == 1010 )then
                text = parseRichtText(rebuildChatString(d.content, d.noticeId), 13, nil, 13)
            elseif d.uid and d.uid == 0 then
                -- 系统消息的解析
                text = parseRichtText(rebuildChatString(d.content, nil, d.uid), 13, nil, 13)
            else
                text = parsePosition(rebuildChatString(d.content), 13, nil, 13, contentCol, true)
            end
            local line = me.assignWidget(cell, "line")
            local talkBg = me.assignWidget(cell, "talkBg")
            talkBg:removeAllChildren()
            local cell_bg = me.assignWidget(cell, "cell_bg")
            cell_bg:removeAllChildren()

            local rt, rsize
            --if d.head and d.head > 0 then
                talkBg:setVisible(true)

                rt = mRichText:create(text, 447, nil, 0)
                rt:setAnchorPoint(cc.p(0, 1))
                rsize = rt:getContentSize()
                rt:setPosition(0, 55 )

                line:setPositionY(7.50-(d.lineHeight-109))

                rt:setTouchEnabled(false)
                rt:setTag(55555)
                talkBg:addChild(rt)
            --[[else
                talkBg:setVisible(true)

                rt = mRichText:create(text, 447, nil, 0)
                rsize = rt:getContentSize()
                rt:setPosition(0, 45)
                rt:setTouchEnabled(false)
                rt:setTag(55555)
                talkBg:addChild(rt)
            end
            ]]
            
        else
            img_head:setVisible(false)
            img_head_up:setVisible(false)

            local talkBg = me.assignWidget(cell, "talkBg")
            talkBg:setVisible(false)
            talkBg:removeAllChildren()

            local item = me.assignWidget(cell, "Button_item")
            item:setPosition(cc.p(0, 0))

            local line = me.assignWidget(cell, "line")
            line:setPositionY(7.50)

            Text_Name:setVisible(true)
            Text_Name:setString("系统")
            Text_Name:setPosition(8.48, 100)
            Text_Name:setTextColor(me.convert3Color_("3986d9"))
            Image_vip:setVisible(false)
            local cell_bg = me.assignWidget(cell, "cell_bg")
            cell_bg:removeAllChildren()
            local nstr, time = getInforStr(mNoticeInfo[self:getMsgTypeNum() - idx])
            local timestr = me.assignWidget(cell, "Text_status")
            timestr:setString(me.GetSecTime(time))
            timestr:setPositionY(93)

            local rt = mRichText:create(nstr, 525, nil, 0)
            rt:setAnchorPoint(cc.p(0, 1))
            local rsize = rt:getContentSize()
            rt:setTouchEnabled(false)
            rt:setPosition(14, 76)
            rt:setTag(55555)
            cell_bg:addChild(rt)
            --[[
            Text_Name:setVisible(true)
            Text_Name:setString("系统")
            Text_Name:setPosition(Text_Name:getContentSize().width / 2 + 5, 108)
            Text_Name:setTextColor(me.convert3Color_("491e07"))
            Image_vip:setVisible(false)
            local talkBg = me.assignWidget(cell, "talkBg")
            talkBg:removeAllChildren()

            local nameBg = me.assignWidget(cell, "nameBg")
            nameBg:setPosition(Text_Name:getPositionX(), 108)

            local d=mNoticeInfo[self:getMsgTypeNum() - idx]
            local item = me.assignWidget(cell, "Button_item")
            item:setPosition(cc.p(0, d.lineHeight-145+10))

            local line = me.assignWidget(cell, "line")
            local nstr, time = getInforStr(d)
            local timestr = me.assignWidget(cell, "Text_status")
            timestr:setString(me.GetSecTime(time))
            timestr:setPositionY(95)
            local rt = mRichText:create(nstr, 790, nil, 0)

            local rsize = rt:getContentSize()
            rt:setTouchEnabled(false)
            talkBg:setPosition(Text_Name:getPositionX(), 85)
            talkBg:setContentSize(cc.size(800, rsize.height+70))
            rt:setPosition(7, 35/2+16 )
            rt:setTag(55555)
            line:setPositionY(-8-(rsize.height+35-57+8))
            talkBg:addChild(rt)
            ]]
        end
        return cell
    end
    local function tableCellTouched(table, cell)
        if self.currentNode ~= self.chat_system then            
            local index = cell:getIdx() + 1
            local d = self:getMsgTypeData()[index]            
            if d.uid ~= user.uid then
                local rt = me.assignWidget(cell, "talkBg"):getChildByTag(55555)
                local pos = rt:getTargetPos()
                self:popupChooseView(index, pos,d.noticeId == 1002 or d.noticeId == 1005 or d.noticeId == 1003
                or d.noticeId == 1006 or d.noticeId == 1007 or d.noticeId == 1011 or d.noticeId == 1012)
            else
                local rt = me.assignWidget(cell, "talkBg"):getChildByTag(55555)
                local pos = rt:getTargetPos()
                if pos then
                    LookMap(pos, "weChatView")
                end
            end
        end
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(563, 553))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(3, 3)
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        self.bg_right:addChild(self.tableView)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
end
local cell_height = 140
function weChatView:resetTableView()
    self.tableView:reloadData()
    if self:getMsgTypeNum() * 110 >= self.tableView:getViewSize().height then
        self.tableView:setContentOffset(cc.size(0, self:getMsgTypeNum() * 110))
    end
end
function weChatView:onExit()
    print("weChatView:onExit()")
    self.preRichTxt600:release()
    self.preRichTxt800:release()

    me.RemoveCustomEvent(self.close_event)
    me.clearTimer(self.chatCountDownTimer)
    if self.listener then
        UserModel:removeLisener(self.listener)
    end
    -- 移除英雄形象缓存
    local TextureCache = cc.Director:getInstance():getTextureCache()
    for k, v in pairs(cfg[CfgType.ROLE_IMAGE]) do
        local str = v.icon..".png"
        TextureCache:removeTextureForKey(str)
    end
end
function weChatView:setChannel(node_)
    if self.currentNode == node_ or self.tableView == nil then
        return
    end
    
    me.assignWidget(self.chat_world, "bg_pitch"):setVisible(node_ == self.chat_world)
    me.assignWidget(self.chat_union, "bg_pitch"):setVisible(node_ == self.chat_union)
    me.assignWidget(self.chat_camp, "bg_pitch"):setVisible(node_ == self.chat_camp)
    me.assignWidget(self.chat_cross, "bg_pitch"):setVisible(node_ == self.chat_cross)
    me.assignWidget(self.chat_trumpet, "bg_pitch"):setVisible(node_ == self.chat_trumpet)
    me.assignWidget(self.chat_system, "bg_pitch"):setVisible(node_ == self.chat_system)
    self.bg_input:setVisible(node_ ~= self.chat_trumpet)
    self.bg_input_Cross:setVisible(false)
    self.currentNode = node_
    self.Button_send:setVisible(self.currentNode == self.chat_world or self.currentNode == self.chat_camp or self.currentNode == self.chat_cross)
    self.Button_send_unit:setVisible(self.currentNode == self.chat_union)

    local oldNode = self.currentNode
    self.currentNode=nil
    if node_ == self.chat_system then
        self.tableView:reloadData()
        self.tableView:initWithViewSize(cc.size(563, 657))
        self.tableView:setPosition(3, -102)
    else
        self.tableView:reloadData()
        self.tableView:initWithViewSize(cc.size(563, 553))
        self.tableView:setPosition(3, 3)
    end

    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.joinUnionBtn:setVisible(false)
    if node_ == self.chat_union and user.familyUid == 0 then
        self.joinUnionBtn:setVisible(true)
        self:resetTableView()
        return
    end

    self.currentNode=oldNode
    self:resetTableView()
end
function weChatView:getMsgTypeNum()
    if self.currentNode == self.chat_union then
        return #user.msgFamilyInfo
    elseif self.currentNode == self.chat_world then
        return #user.msgWorldInfo
    elseif self.currentNode == self.chat_camp then
        return #user.msgCampInfo
    elseif self.currentNode == self.chat_cross then
        return #user.msgCrossInfo
    elseif self.currentNode == self.chat_trumpet then
        return #user.msgTrumpetInfo
    elseif self.currentNode == self.chat_system then
        return #mNoticeInfo
    else
        return 0
    end
end

function weChatView:getMsgTypeData()
    if self.currentNode == self.chat_world then
        return user.msgWorldInfo
    elseif self.currentNode == self.chat_union then
        return user.msgFamilyInfo
    elseif self.currentNode == self.chat_camp then
        return user.msgCampInfo
    elseif self.currentNode == self.chat_cross then
        return user.msgCrossInfo
    elseif self.currentNode == self.chat_trumpet then
        return user.msgTrumpetInfo
    elseif self.currentNode == self.chat_system then
        return mNoticeInfo
    else
        return {}
    end
end

-- 弹出查看界面
-- function weChatView:popupBtnView(index_)
--    if user.msgWorldInfo[index_].uid == user.uid then
--        return
--    end

--    if self.layout == nil then
--        self.layout = ccui.Layout:create()
--        self.layout:setContentSize(cc.size(me.winSize.width,me.winSize.height))
--        self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
--        self.layout:setAnchorPoint(cc.p(0,0))
--        self.layout:setPosition(cc.p(0,0))
--        self.layout:setSwallowTouches(true)
--        self.layout:setTouchEnabled(true)
--        self:addChild(self.layout,me.MAXZORDER)
--    end
--    local popupBtn = me.assignWidget(self, "Panel_PopupBtn"):clone()
--    self.layout:addChild(popupBtn)
--    popupBtn:setVisible(true)
--    popupBtn:setAnchorPoint(cc.p(0.5,0.5))
--    popupBtn:setPosition(cc.p(me.winSize.width/2,me.winSize.height/2))

--    me.registGuiTouchEvent(self.layout,function (node,event)
--        if event ~= ccui.TouchEventType.ended then
--                        return
--        end
--        self.layout:removeFromParent()
--        self.layout = nil
--        self.selecetData = nil
--    end)

--    if self.currentNode == self.chat_world and user.msgWorldInfo[index_] then
--        local tmpData = user.msgWorldInfo[index_]
--        self.selecetData = MsgData.new(tmpData.uid,tmpData.name,tmpData.date,tmpData.content,tmpData.familyName,tmpData.degree,tmpData.fightNum)
--    elseif self.currentNode == self.chat_union and user.msgFamilyInfo[index_] then
--        local tmpData = user.msgFamilyInfo[index_]
--        self.selecetData = MsgData.new(tmpData.uid,tmpData.name,tmpData.date,tmpData.content,tmpData.familyName,tmpData.degree,tmpData.fightNum)
--    end
-- end

-- 写邮件
function weChatView:popupMailView()
    local pType = mCross_Sever_Out
    if self.currentNode == self.chat_world or self.currentNode == self.chat_union then
        pType = mCross_Sever_Out
    elseif self.currentNode == self.chat_camp or self.currentNode == self.chat_cross then
        pType = mCross_Sever
    end
    local mail = sendMailCell:create("sendMailCell.csb")
    mail:setData(self.selecetData.uid, self.selecetData.name, pType)
    self:addChild(mail)
    self.layout:removeFromParent()
    self.layout = nil
    self.selecetData = nil
end
function weChatView:popupChooseView(index_, pos_,converge_)
    self.selecetData = self:getMsgDataByIndex(index_)
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
    local choose = me.assignWidget(self, "Panel_Choose"):clone()
    choose:setTouchEnabled(true)
    choose:setSwallowTouches(true)
    self.layout:addChild(choose)
    choose:setVisible(true)
    choose:setAnchorPoint(cc.p(0.5, 0.5))
    choose:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    me.registGuiTouchEvent(self.layout, function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.layout:removeFromParent()
        self.layout = nil
    end )
    local Button_jump = me.registGuiClickEventByName(choose, "Button_jump", function()
        self.layout:removeFromParent()
        self.layout = nil
        LookMap(pos_, "weChatView")
    end )
    Button_jump:setVisible(pos_ ~= nil)
    
    -- 形象
    local cfg_image = cfg[CfgType.ROLE_IMAGE]
    local img_hero = me.assignWidget(choose, "img_hero")
    img_hero:ignoreContentAdaptWithSize(true)
    img_hero:loadTexture(cfg_image[self.selecetData.image].icon..".png", me.localType)
    -- 名称
    local img_fap = me.assignWidget(choose, "img_fap")
    local text_name = me.assignWidget(img_fap, "text_name")
    text_name:setString(self.selecetData.name)
    -- 战力
    local text_fap = me.assignWidget(img_fap, "text_fap")
    text_fap:setString(me.toNum(self.selecetData.fightNum))

    me.registGuiTouchEvent(self.layout, function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.layout:removeFromParent()
        self.layout = nil
        self.selecetData = nil
    end )
    local Button_jh = me.registGuiClickEventByName (choose, "Button_jh", function()
            local converge = convergeView:create("convergeView.csb")
            converge:showBattleView()
            if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                 mainCity:addChild(converge,me.MAXZORDER)
            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP and pWorldMap then
                pWorldMap:addChild(converge,me.MAXZORDER)
            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE and pWorldMap then
                pWorldMap:addChild(converge,me.MAXZORDER)
            end
            self.layout:removeFromParent()
            self.layout = nil
    end )
    Button_jh:setVisible( converge_ )
    local Button_mail = me.assignWidget(choose, "Button_mail")
    me.registGuiClickEvent(Button_mail, function()
        self.layout:removeAllChildren()
        self:popupMailView()
    end)
    Button_jh:ignoreContentAdaptWithSize(false)
    Button_jh:setContentSize(271, 68)
    Button_jump:ignoreContentAdaptWithSize(false)
    Button_jump:setContentSize(271, 68)
    Button_mail:ignoreContentAdaptWithSize(false)
    Button_mail:setContentSize(271, 68)

    -- 修正战力位置
    local posY = 255
    for i, v in ipairs({Button_jh, Button_jump}) do
        if not v:isVisible() then
            posY = posY - 70
        end
    end
    img_fap:setPositionY(posY)
end

function weChatView:isHidePanel_Info(index_)
    if self.currentNode == self.chat_camp or self.currentNode == self.chat_trumpet or self.currentNode == self.chat_cross then
        return true
    elseif self.currentNode == self.chat_union then
        if user.msgFamilyInfo[index_] and user.msgFamilyInfo[index_].uid == user.uid then
            return true
        end
    elseif self.currentNode == self.chat_world then
        if user.msgWorldInfo[index_] and user.msgWorldInfo[index_].uid == user.uid then
            return true
        end
    elseif self.currentNode == self.chat_camp then
        if user.msgCampInfo[index_] and user.msgCampInfo[index_].uid == user.uid then
            return true
        end
    elseif self.currentNode == self.chat_cross then
        if user.msgCrossInfo[index_] and user.msgCrossInfo[index_].uid == user.uid then
            return true
        end
    end
    return false
end
function weChatView:getMsgDataByIndex(index_)
    local tmpMsgData = nil
    if self.currentNode == self.chat_world and user.msgWorldInfo[index_] then
        local tmpData = user.msgWorldInfo[index_]
        tmpMsgData = MsgData.new(tmpData.uid, tmpData.name, tmpData.date, tmpData.content, tmpData.familyName, tmpData.degree, tmpData.fightNum)
        tmpMsgData.title = tmpData.title or 0
        tmpMsgData.image = tmpData.image or 0
        tmpMsgData.vip = tmpData.vip or 0
        tmpMsgData.fightNum = tmpData.fightNum
    elseif self.currentNode == self.chat_union and user.msgFamilyInfo[index_] then
        local tmpData = user.msgFamilyInfo[index_]
        tmpMsgData = MsgData.new(tmpData.uid, tmpData.name, tmpData.date, tmpData.content, tmpData.familyName, tmpData.degree, tmpData.fightNum, tmpData.type)
        tmpMsgData.title = tmpData.title or 0
        tmpMsgData.image = tmpData.image or 0
        tmpMsgData.vip = tmpData.vip or 0
        tmpMsgData.fightNum = tmpData.fightNum
    elseif self.currentNode == self.chat_camp and user.msgCampInfo[index_] then
        local tmpData = user.msgCampInfo[index_]
        tmpMsgData = MsgData.new(tmpData.uid, tmpData.name, tmpData.date, tmpData.content, tmpData.familyName, tmpData.degree, tmpData.fightNum)
        tmpMsgData.title = tmpData.title or 0
        tmpMsgData.image = tmpData.image or 0
        tmpMsgData.vip = tmpData.vip or 0
        tmpMsgData.fightNum = tmpData.fightNum
    elseif self.currentNode == self.chat_cross and user.msgCrossInfo[index_] then
        local tmpData = user.msgCrossInfo[index_]
        tmpMsgData = MsgData.new(tmpData.uid, tmpData.name, tmpData.date, tmpData.content, tmpData.familyName, tmpData.degree, tmpData.fightNum)
        tmpMsgData.title = tmpData.title or 0
        tmpMsgData.image = tmpData.image or 0
        tmpMsgData.vip = tmpData.vip or 0
        tmpMsgData.fightNum = tmpData.fightNum
    end
    
    return tmpMsgData
end

-- 个人信息界面 
function weChatView:popupInfoView(index_)
    if self:isHidePanel_Info() == true then
        return
    end

    self.selecetData = self:getMsgDataByIndex(index_)
    if self.selecetData == nil then
        return
    end

    if self.selecetData.uid == 0 then
        return
    end

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

    local info = me.assignWidget(self, "Panel_Info"):clone()
    info:setTouchEnabled(true)
    info:setSwallowTouches(true)
    self.layout:addChild(info)
    info:setVisible(true)
    info:setAnchorPoint(cc.p(0.5, 0.5))
    info:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    me.assignWidget(info, "Text_name"):setString(self.selecetData.name)
    me.assignWidget(info, "fightNum"):setVisible(self.selecetData.fightNum ~= nil)
    if self.selecetData.fightNum then
        me.assignWidget(info, "fightNum"):setString(me.toNum(self.selecetData.fightNum))
    end
    me.assignWidget(info, "Text_union"):setVisible(self.selecetData.familyName ~= nil)
    if self.selecetData.familyName then
        me.assignWidget(info, "Text_union"):setString("联盟：" .. self.selecetData.familyName)
    end
    me.assignWidget(info, "Text_dep"):setVisible(self.selecetData.degree ~= nil)
    if self.selecetData.degree then
        me.assignWidget(info, "Text_dep"):setString("职位：" .. me.alliancedegree(self.selecetData.degree))
    end

    me.registGuiTouchEvent(self.layout, function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.layout:removeFromParent()
        self.layout = nil
        self.selecetData = nil
    end )

    me.registGuiClickEvent(me.assignWidget(info, "Button_mail"), function()
        self.layout:removeAllChildren()
        self:popupMailView()
    end )
end

function weChatView:flushPackageTrumpet()
    if self.trumpetQuilty ~= nil then
        table.remove(self.trumpetQuilty)
        self.trumpetQuilty = nil
    end
    self.trumpetQuilty = { }
    self.trumpetQuilty[weChatView.trumpetType_Yellow] = 0
    self.trumpetQuilty[weChatView.trumpetType_Blue] = 0
    self.trumpetQuilty[weChatView.trumpetType_Purple] = 0
    for key, var in pairs(user.pkg) do
        local def = var:getDef()
        if me.toNum(def.id) == weChatView.trumpetType_Yellow or me.toNum(def.id) == weChatView.trumpetType_Blue or me.toNum(def.id) == weChatView.trumpetType_Purple then
            self.trumpetQuilty[me.toNum(def.id)] = self.trumpetQuilty[me.toNum(def.id)] + var.count
        end
    end
    for key, var in pairs(self.Buttons_cross) do
        me.assignWidget(var, "Text_trumpet"):setString("x" .. self.trumpetQuilty[key])
    end
    self.currentTrumpetType = weChatView.trumpetType_Blue
    -- 默认消费weChatView.trumpetType_Yellow道具
    for key, var in pairs(self.trumpetQuilty) do
        if me.toNum(var) > 0 then
            self.currentTrumpetType = key
            break
        end
    end
end

function weChatView:close()
    if self.listener then
        UserModel:removeLisener(self.listener)
    end
    self:removeFromParent()
end