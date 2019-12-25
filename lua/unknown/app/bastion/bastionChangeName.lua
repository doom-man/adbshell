-- [Comment]
-- jnmo
bastionChangeName = class("bastionChangeName", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
bastionChangeName.__index = bastionChangeName
function bastionChangeName:create(...)
    local layer = bastionChangeName.new(...)
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
function bastionChangeName:ctor()
    print("bastionChangeName ctor")
end
function bastionChangeName:init()
    print("bastionChangeName init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.Text_Price = me.assignWidget(self, "Text_Price")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.BASTION_GET_PRICE) then
            self.curx = msg.c.x
            self.cury = msg.c.y
            self.price = msg.c.need
            if self.price == 0 then
                self.Text_Price:setString("免费")
            else
            self.Text_Price:setString(self.price)
            end
        end
    end )
    -- self.name_input = me.assignWidget(self, "name_input")
    -- self.name_input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- self.name_input:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    local edit_box = me.addInputBox(140, 30, 20, nil, nil, cc.EDITBOX_INPUT_MODE_ANY, "名字上限6个字")
    edit_box:setMaxLength(6)
    edit_box:setAnchorPoint(0.5, 0.5)
    edit_box:setPosition(cc.p(191.5, 27))
    edit_box:setPlaceholderFontColor(cc.c3b(0x5a, 0x5a, 0x5a))
    edit_box:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    me.assignWidget(self, "img_edit_box"):addChild(edit_box)
    self.edit_box = edit_box

    me.registGuiClickEventByName(self, "btn_ok", function(node)
        if self.price <= user.diamond then
            if me.isValidStr(self.edit_box:getText()) then               
                    NetMan:send(_MSG.bastion_changeName(self.curx,self.cury,self.edit_box:getText()))
                    self:close()                
            else
                showTips("请输入新的据点名字")
            end
        else
            askToRechage(0)
        end
    end )
    return true
end
function bastionChangeName:onEnter()
    print("bastionChangeName onEnter")
    me.doLayout(self, me.winSize)
end
function bastionChangeName:onEnterTransitionDidFinish()
    print("bastionChangeName onEnterTransitionDidFinish")
end
function bastionChangeName:onExit()
    print("bastionChangeName onExit")
    UserModel:removeLisener(self.modelkey)
end
function bastionChangeName:close()
    self:removeFromParent()
end
