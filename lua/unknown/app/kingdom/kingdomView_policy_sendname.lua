kingdomView_policy_sendname = class("kingdomView_policy_sendname", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )

kingdomView_policy_sendname.__index = kingdomView_policy_sendname
function kingdomView_policy_sendname:create(...)
    local layer = kingdomView_policy_sendname.new(...)
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
function kingdomView_policy_sendname:ctor()
    print("kingdomView_policy_sendname:ctor()")
end
function kingdomView_policy_sendname:init()
    print("kingdomView_policy_sendname:init()")
    me.doLayout(self,me.winSize)  
    self.Image_sel = me.assignWidget(self,"Image_sel")
    self.Button_ok = me.assignWidget(self,"Button_ok")
    self.Image_input = me.assignWidget(self,"Image_input")
    self.Text_title = me.assignWidget(self, "Text_title")
    me.registGuiClickEvent(me.assignWidget(self,"close"),function (node)
        self:close()
    end)

    me.registGuiClickEvent(self.Button_ok,function (node)
        if me.isValidStr(self.msgEb:getText()) and self.defId then
            NetMan:send(_MSG.kingdom_policy_publish(self.defId, self.msgEb:getText()))
        end
    end)
    
    self.msgEb = me.addInputBox(self.Image_input:getContentSize().width, self.Image_input:getContentSize().height, 28,nil,msgEbCallFunc,cc.EDITBOX_INPUT_MODE_ANY,"请输入名字")
    self.msgEb:setMaxLength(15)
    self.msgEb:setAnchorPoint(0,0)
    self.Image_input:addChild(self.msgEb)

    return true
end
function kingdomView_policy_sendname:update(msg)
    if checkMsg(msg.t, MsgCode.KINGDOM_NATIONAL_POLICY_PUBLISH) then
        self:close()
    end
end
function kingdomView_policy_sendname:onEnter()
    print("kingdomView_policy_sendname:onEnter()")
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomView_policy_sendname")
    local tmpDef = cfg[CfgType.KINGDOM_POLICY][self.defId]
    self.Text_title:setString(tmpDef.name)
end
function kingdomView_policy_sendname:setDefData(defId)
    self.defId = defId
end
function kingdomView_policy_sendname:onEnterTransitionDidFinish()
    print("kingdomView_policy_sendname:onEnterTransitionDidFinish()")
end
function kingdomView_policy_sendname:onExit()
    UserModel:removeLisener(self.modelkey)
    print("kingdomView_policy_sendname:onExit()")
end
function kingdomView_policy_sendname:close()
    self:removeFromParentAndCleanup(true)
end