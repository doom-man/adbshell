--[Comment]
--jnmo
MessageBoxVip = class("MessageBoxVip",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
MessageBoxVip.__index = MessageBoxVip
function MessageBoxVip:create(...)
    local layer = MessageBoxVip.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function MessageBoxVip:ctor()   
    print("MessageBoxVip ctor") 
end
function MessageBoxVip:init()   
    print("MessageBoxVip init")
	me.registGuiClickEventByName(self,"btn_cancel",function (node)
        self:close()     
    end)    
    me.registGuiClickEventByName(self,"btn_ok",function (node)
        if self.exp <= user.paygem then
            NetMan:send(_MSG.viplevelup())
        else
            askToRechage(1)
        end
        self:close()     
    end)  
    self.msg = me.assignWidget(self,"msg")
    self.Image_1 = me.assignWidget(self,"Image_1")
    self.msg_0 = me.assignWidget(self,"msg_0")
    self.vip = me.assignWidget(self,"vip")
    self.gem = me.assignWidget(self,"gem")
    return true
end
function MessageBoxVip:initWithData(exp,level)
    self.exp = exp
    self.gem:setString(exp)
    self.vip:setString(level)
    me.DelayRun(function (args)
    if self.exp <= user.paygem then
        self.gem:setString(exp):setTextColor(me.convert3Color_("00ff00"))
    else
        self.gem:setString(exp):setTextColor(me.convert3Color_("ff0000"))
    end
    me.putNodeOnRight(self.Image_1,self.gem,0,cc.p(0,2))
    me.putNodeOnRight(self.gem,self.msg_0,0,cc.p(0,2))
    me.putNodeOnRight(self.msg_0,self.vip,0,cc.p(0,2))
end)
end
function MessageBoxVip:onEnter()
    print("MessageBoxVip onEnter") 
	me.doLayout(self,me.winSize)  
end
function MessageBoxVip:onEnterTransitionDidFinish()
	print("MessageBoxVip onEnterTransitionDidFinish") 
end
function MessageBoxVip:onExit()
    print("MessageBoxVip onExit")    
end
function MessageBoxVip:close()
    self:removeFromParent()  
end
