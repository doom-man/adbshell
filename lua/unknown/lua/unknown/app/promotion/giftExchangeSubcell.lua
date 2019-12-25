giftExchangeSubcell = class("giftExchangeSubcell", function(...)
    return cc.CSLoader:createNode(...)
end )
giftExchangeSubcell.__index = giftExchangeSubcell
function giftExchangeSubcell:create(...)
    local layer = giftExchangeSubcell.new(...)
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

function giftExchangeSubcell:ctor()
    print("giftExchangeSubcell:ctor()")
end
function giftExchangeSubcell:init()
    print("giftExchangeSubcell:init()")
    return true
end
function giftExchangeSubcell:onEnter()
    print("giftExchangeSubcell:onEnter()")
    me.doLayout(self, me.winSize)
    self.Image_input = me.assignWidget(self, "Image_input")
    self.msgEb = me.addInputBox(463, 58, 28, nil, nil, cc.EDITBOX_INPUT_MODE_ANY, "请输入兑换码")
    self.msgEb:setMaxLength(30)
    self.msgEb:setAnchorPoint(0, 0.5)
    self.msgEb:setPosition(8, self.Image_input:getContentSize().height / 2)
    self.Image_input:addChild(self.msgEb)

    local function sendExchangeCode()
        if self.msgEb:getText() == "" or self.msgEb:getText() == nil then
            showTips("兑换码不能为空")
            return false
        end
        me.buttonState(me.registGuiClickEventByName(self, "Button_exchange"), false)
        NetMan:send(_MSG.sendExchangeCode(self.msgEb:getText()))
        return true
    end

    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.EXCHANGE_ACTIVITY) then
            self.msgEb:setText("")
            me.buttonState(me.registGuiClickEventByName(self, "Button_exchange"), true)
            me.registGuiClickEventByName(self, "Button_exchange", function(node)
                sendExchangeCode()
            end )
        end
    end )
    
    me.registGuiClickEventByName(self, "Button_exchange", function(node)
        sendExchangeCode()
    end )
end
function giftExchangeSubcell:onExit()
    print("giftExchangeSubcell:onExit()")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
