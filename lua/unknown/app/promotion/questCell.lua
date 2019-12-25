-- [Comment]
-- jnmo
questCell = class("questCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
questCell.__index = questCell
function questCell:create(...)
    local layer = questCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function questCell:ctor()
    print("questCell ctor")
    self.lists = { }
    self.curIdx = 1
    self.answers = { }
end
function questCell:init()
    print("questCell init")
    self.Button_pre = me.registGuiClickEventByName(self, "Button_pre", function(node)
        self.curIdx = self.curIdx - 1
        self:initIndex(self.curIdx)
    end )
    self.Button_next = me.registGuiClickEventByName(self, "Button_next", function(node)
        local aid = nil
        for key, var in pairs(self.lists) do
            local cbox = me.assignWidget(var, "cbox")
            print(cbox:isSelected())
            if cbox:isSelected() == true then
                aid = key
                self.answers[self.curIdx] = key
                print("aid = " .. aid)
            end
        end
        NetMan:send(_MSG.question(self.curIdx, aid))
        if #self.data.qustion > self.curIdx then
            self.curIdx = self.curIdx + 1
            self:initIndex(self.curIdx)
        else
            for key, var in pairs(self.lists) do
                var:removeFromParent()
            end
            self.Button_pre:setVisible(false)
            self.Button_next:setVisible(false)
            self.Text_desc:setVisible(false)
            self.Text_Quest:setVisible(false)
            self.Text_Finish:setVisible(true)
        end
    end )
    self.Text_Quest = me.assignWidget(self, "Text_Quest")
    self.Image_Item = me.assignWidget(self, "Image_Item")
    self.Image_frame = me.assignWidget(self, "Image_frame")
    self.Text_time = me.assignWidget(self, "Text_Time")
    self.Text_desc = me.assignWidget(self, "Text_desc")
    self.Text_Finish = me.assignWidget(self, "Text_Finish")

--    if user.activityDetail.activityId==ACTIVITY_ID_QUEST and user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_QUEST)]==1 then
--        removeRedpoint(ACTIVITY_ID_QUEST)
--    end
    removeRedpoint(user.activityDetail.activityId)
    return true
end
function questCell:initActivity(data)
    self.data = data
    self.Text_time:setString(me.GetSecTime(data.openDate) .. "-" .. me.GetSecTime(data.endDate))
    if data.finish == 0 then
        local idx = 1
        for key, var in pairs(self.data.qustion) do
            if var.uAnswer == 0 then
                idx = key
                break
            end
        end
        self.curIdx = idx
        self:initIndex(self.curIdx)
        self.Text_Finish:setVisible(false)
    else
        self.Button_pre:setVisible(false)
        self.Button_next:setVisible(false)
        self.Text_desc:setVisible(false)
        self.Text_Quest:setVisible(false)
        self.Text_Finish:setVisible(true)
    end
end
function questCell:initIndex(idx)
    for key, var in pairs(self.lists) do
        var:removeFromParent()
    end
    if self.data.qustion then
        local def = self.data.qustion[idx]
        local max = #self.data.qustion
        self.Text_Quest:setString(idx .. "/" .. max .. "." .. def.title)
        me.setButtonDisable(self.Button_pre, idx > 1)
        local ofy = self.Text_Quest:getPositionY()
        local h = 10
        local function select_call(node, event)
            print("event = " .. event)
            if event == ccui.TouchEventType.ended then
                local haveChoose = false
                for key, var in pairs(self.lists) do
                    local cbox = me.assignWidget(var, "cbox")
                    cbox:setSelected(cbox == node)
                    if cbox == node then
                        haveChoose = true
                    end
                end
                me.setButtonDisable(self.Button_next, haveChoose)
            end
        end
        me.setButtonDisable(self.Button_next, false)
        for key, var in pairs(def.answer) do
            self.lists[key] = self.Image_Item:clone()
            self.lists[key]:setVisible(true)
            self.lists[key]:setPositionY(ofy - key *(self.lists[key]:getContentSize().height + h) + self.lists[key]:getContentSize().height / 2)
            me.assignWidget(self.lists[key], "Text_QuestCell"):setString(var)
            local cbox = me.assignWidget(self.lists[key], "cbox")
            cbox:setSelected(false)
            print(self.answers[idx], def.uAnswer)
            if self.answers[idx] then
                cbox:setSelected(self.answers[idx] == key)
                me.setButtonDisable(self.Button_next, true)
            else
                if def.uAnswer == 0 then
                    cbox:setSelected(self.answers[idx] == key or false)
                    me.setButtonDisable(self.Button_next, self.answers[idx] == key)
                elseif def.uAnswer == key then
                    cbox:setSelected(self.answers[idx] == key or true)
                    me.setButtonDisable(self.Button_next, true)
                end
            end
            me.registGuiTouchEvent(cbox, select_call)
            self.Image_frame:addChild(self.lists[key])
        end

    end
end
function questCell:onEnter()
    print("questCell onEnter")
    me.doLayout(self, me.winSize)
end
function questCell:onEnterTransitionDidFinish()
    print("questCell onEnterTransitionDidFinish")
end
function questCell:onExit()
    print("questCell onExit")
end
function questCell:close()
    self:removeFromParent()
end

