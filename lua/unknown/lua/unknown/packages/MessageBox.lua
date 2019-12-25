--
-- Author: jnmo
-- Date: 2015-02-07 23:01:53
--
MessageBox = class("MessageBox", function(csb)
    return cc.CSLoader:createNode(csb)
end )
MessageBox.__index = MessageBox
function MessageBox:create(csb)
    local layer = MessageBox.new(csb)
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
function MessageBox:ctor()
    print("MessageBox ctor")
    self.eName_ = nil
    self.info = nil
end
function MessageBox:init()
    self.closeBtn = me.assignWidget(self, "btn_cancel")
    self.fixLayout = me.assignWidget(self, "fixLayout")
    local this = self
    local function closecallback(node, event)
        -- body
        if event == ccui.TouchEventType.ended then
            if self.listener then
                self.listener("close")
            end
            me.hideLayer(self, true, "fixLayout")
        end
    end
    if self.closeBtn then
        self.closeBtn:addTouchEventListener(closecallback)
    else
        self.fixLayout:addTouchEventListener(closecallback)
    end
    self.okBtn = me.assignWidget(self, "btn_ok")
    local function okcallback(node, event)
        -- body
        if event == ccui.TouchEventType.ended then
            if self.listener then
                self.listener("ok")
            end
            me.hideLayer(self, true, "fixLayout")
        end
    end
    self.okBtn:addTouchEventListener(okcallback)
    self.info = me.assignWidget(self, "msg")
    self.msgBox = me.assignWidget(self, "msgBox")
    me.doLayout(self, me.winSize)
    return true
end
function MessageBox:setButtonMode(m)
    m = m or 0
    if m == 1 then
        if self.closeBtn then
            self.closeBtn:setVisible(false)
        end
        self.okBtn:setPositionX(self.msgBox:getContentSize().width / 2 + self.okBtn:getContentSize().width / 2)
    end
end
function MessageBox:setText(t, color, fontsize)
    self.info:setString(t)
    local c = color or "ffffff"
    local s = fontsize or 24
    self.info:setColor(me.convert3Color_(c))
    self.info:setFontSize(s)
end
function MessageBox:register(listener)
    if listener then
        self.listener = listener
    else
        self:setButtonMode(1)
    end
end
function MessageBox:onEnter()
    print("MessageBox onEnter")
end
function MessageBox:onExit()
    print("MessageBox onExit")
end