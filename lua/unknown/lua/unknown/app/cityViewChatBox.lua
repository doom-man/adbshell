local cityViewChatBox = class("cityViewChatBox",function (...)
     local arg = {...}
    if table.getn(arg) == 2 then    
        return me.assignWidget(arg[1], arg[2])
    else
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return cc.CSLoader:createNode(arg[1])
    end
end)
function cityViewChatBox:create(...)
    local layer = cityViewChatBox.new(...)
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


function cityViewChatBox:ctor(...)

    self.chatData={}
end


function cityViewChatBox:onEnter()
    self.listener = UserModel:registerLisener( function(msg)

        if checkMsg(msg.t, MsgCode.FAMLIY_CHAT_INFO) or checkMsg(msg.t, MsgCode.WORLD_CHAT_INFO) or 
            checkMsg(msg.t, MsgCode.CAMOP_CHAT_INFO) or checkMsg(msg.t, MsgCode.CROSS_CHAT_INFO) then
            local stype=0
            if checkMsg(msg.t, MsgCode.FAMLIY_CHAT_INFO) then
                stype=1
            elseif checkMsg(msg.t, MsgCode.WORLD_CHAT_INFO) then
                stype=3
            elseif checkMsg(msg.t, MsgCode.CAMOP_CHAT_INFO) then
                stype=5
            elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_INFO) then
                stype=4
            end
            local str = rebuildChatString(msg.c.content, msg.c.noticeId)
            if msg.c.noticeId then
                str = string.gsub(str, "&", "")
                str = string.gsub(str, "(<)(.-)(>)", "")
            end
            str = msg.c.name.."："..str
            chatMsg = {stype=stype, data=str}

            if #self.chatData < 2 then
                self.chatData[#self.chatData + 1] = {stype=stype,familyName=msg.c.shorName, data=str}
            else
                table.insert(self.chatData, #self.chatData + 1, {stype=stype,familyName=msg.c.shorName, data=str})
                table.remove(self.chatData, 1)
            end

            self:fillSimpleChatPanel()
        elseif checkMsg(msg.t, MsgCode.CROSS_CHAT_TRUMPET) then
            local str = rebuildChatString(msg.c.ct)
            if #self.chatData < 2 then
                self.chatData[#self.chatData + 1] = {stype=2,familyName=msg.c.shorName, data=str}
            else
                table.insert(self.chatData, #self.chatData + 1, {stype=2,familyName=msg.c.shorName, data=str})
                table.remove(self.chatData, 1)
            end
            self:fillSimpleChatPanel()
         elseif checkMsg(msg.t, MsgCode.GET_CHAT_RECORD) then
            self:initChatData()
            self:fillSimpleChatPanel()
        end
    end )

   self:initChatData()
   self:fillSimpleChatPanel()

end


function cityViewChatBox:onExit()
    if self.listener then
        UserModel:removeLisener(self.listener)
        self.listener=nil
    end
end

function cityViewChatBox:initChatData()
    local allData = {}
    local tmp = {{stype=1,d=user.msgFamilyInfo},
                 {stype=3,d=user.msgWorldInfo},
                 {stype=5,d=user.msgCampInfo},
                 {stype=4,d=user.msgCrossInfo},
                 {stype=2,d=user.msgTrumpetInfo}
                 }
    for _, v in ipairs(tmp) do 
        local mLen = #v.d
        local start = mLen>2 and mLen-1 or 1
        for i=start, mLen do
            local msg = v.d[i]
            local str = rebuildChatString(msg.content, msg.noticeId)
            if msg.noticeId then
                str = string.gsub(str, "&", "")
                str = string.gsub(str, "(<)(.-)(>)", "")
            end
            if v.stype~=2 then
                str = msg.name.."："..str
            end
            table.insert(allData, {stype=v.stype,familyName=msg.shorName, data=str, date=msg.date})
        end
    end
    table.sort(allData, function(a,b)
        return a.date<b.date
    end)
    tmp=nil
    local mLen = #allData
    local start = mLen>2 and mLen-1 or 1
    for i=start, mLen do
        table.insert(self.chatData, allData[i])
    end
    allData=nil
end


function cityViewChatBox:fillSimpleChatPanel()
    local chatLen = #self.chatData
    if chatLen==0 then return end

    self.chatCon1:setVisible(true)
    self.chatCon2:setVisible(false)

    local data = self.chatData[chatLen]
    local con=self:makeMsg(self.chatCon1, data)
    if chatLen>1 then
        con:setPosition(0,-20)

        self.chatCon2:setVisible(true)
        data = self.chatData[chatLen-1]
        local con1=self:makeMsg(self.chatCon2, data)
        con1:setPosition(0,0)
    else
        con:setPosition(0,-13)
    end
end



function cityViewChatBox:init()
    self.chatSimpleCon = me.assignWidget(self, "chatSimpleCon")
    self.chatCon1 = me.assignWidget(self.chatSimpleCon, "chatCon1")
    self.chatCon2 = me.assignWidget(self.chatSimpleCon, "chatCon2")
    me.registGuiClickEvent(self.chatSimpleCon, handler(self, self.openChatWin))

    return true
end

function cityViewChatBox:openChatWin()
    local chatView = weChatView:create("chatView.csb")
    me.runningScene():addChild(chatView, me.MAXZORDER)
    --me.showLayer(chatView, "bg_frame")
end



function cityViewChatBox:makeMsg(con, data)
    local label = con:getChildByName("head")
    if label==nil then
        label = cc.Label:createWithSystemFont("", "", 16)
        label:setAnchorPoint(cc.p(0, 1))
        label:setPositionY(38)
        label:setName("head")
        label:setTextColor(cc.c4b(255,188,58,255))
        con:addChild(label)
    end
    local lineLen = 37
    if data.familyName then
        label:setString("["..data.familyName.."]")
        lineLen=lineLen-self:strLen(data.familyName)
    else
        label:setString("")
        lineLen=lineLen-1
    end
    --[[
    local stype=data.stype
    if stype==1 then
        label:setString("【联盟】")
        label:setTextColor(cc.c4b(27,197,234,255))
    elseif stype==2 then
        label:setString("【系统】")
        label:setTextColor(cc.c4b(244,25,25,255))
    elseif stype==3 then
        label:setString("【世界】")
        label:setTextColor(cc.c4b(33,243,58,255))
    elseif stype==4 then
        label:setString("【跨服】")
        label:setTextColor(cc.c4b(218,51,228,255))
    elseif stype==5 then
        label:setString("【阵营】")
        label:setTextColor(cc.c4b(248,220,33,255))
    end
    ]]
    
    local str1, str2
    if data.str1==nil then
        str1, str2 =self:strSplit(data.data, lineLen)
        data.str1=str1
        data.str2=str2
    else
        str1=data.str1
        str2=data.str2
    end
    if str2~=nil then
        str1=str1.."..."
    end
    local txt1 = con:getChildByName("txt1")
    if txt1==nil then
        txt1 = cc.Label:createWithSystemFont(str1, "", 16)
        txt1:setAnchorPoint(cc.p(0, 1))
        txt1:setTextColor(cc.c4b(255,233,189,255))
        txt1:setName("txt1")
        con:addChild(txt1)
    else
        txt1:setString(str1)
    end
    txt1:setPosition(label:getContentSize().width, 38)
    --[[
    local txt2 = con:getChildByName("txt2")
    if txt2==nil then
        txt2 = cc.Label:createWithSystemFont("", "", 16)
        txt2:setAnchorPoint(cc.p(0, 1))
        txt2:setTextColor(cc.c4b(255,233,189,255))
        txt2:setPosition(0, 19)
        txt2:setName("txt2")
        con:addChild(txt2)
    end
    if str2~=nil then
        txt2:setString(str2)
        txt2:setVisible(true)
        con.lines=2
    else
        txt2:setVisible(false)
        con.lines=1
    end
    ]]
    return con
end

function cityViewChatBox:strLen(str)
    local cnNum = 0
    local function isASCII_Code(i)
        if i >= 0 and i <= 127 then
            return true
        end
        return false
    end
    local t=0
    for i = 1, string.len(str) do
        if string.byte(str, i) and isASCII_Code(string.byte(str, i)) then
            t=t+1
        elseif string.byte(str, i) then
            cnNum = cnNum + 1
            if cnNum%3==0 then
                t=t+2
            end
        end
    end
    return t
end

function cityViewChatBox:strSplit(str, splitLen)
    local cnNum = 0
    local function isASCII_Code(i)
        if i >= 0 and i <= 127 then
            return true
        end
        return false
    end
    local t=0
    for i = 1, string.len(str) do
        if string.byte(str, i) and isASCII_Code(string.byte(str, i)) then
            t=t+1
        elseif string.byte(str, i) then
            cnNum = cnNum + 1
            if cnNum%3==0 then
                t=t+2
            end
        end
        if t>=splitLen then
            local str1 = string.sub(str, 1, i)
            local str2 = string.sub(str, i+1)
            return str1, str2
        end
    end
    return str, nil
end

return cityViewChatBox