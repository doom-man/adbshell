--[Comment]
--jnmo
expchageLayer = class("expchageLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
expchageLayer.__index = expchageLayer
function expchageLayer:create(...)
    local layer = expchageLayer.new(...)
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
function expchageLayer:ctor()   
    print("expchageLayer ctor") 
end
function expchageLayer:init()   
    print("expchageLayer init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)  
    me.registGuiClickEventByName(self,"Button_E10",function (node)
       NetMan:send(_MSG.expchagegem(1000))
    end)  
    me.registGuiClickEventByName(self,"Button_E1",function (node)
       NetMan:send(_MSG.expchagegem(100))
    end)  
    me.registGuiClickEventByName(self,"Button_E50",function (node)
       NetMan:send(_MSG.expchagegem(5000))
    end)  

    me.assignWidget(self, "ybTxt"):setString(user.paygem)
    me.assignWidget(self, "zsTxt"):setString(user.diamond)

    self.listener = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.ROLE_GEM_UPDATE) then
            me.assignWidget(self, "zsTxt"):setString(user.diamond)
        elseif checkMsg(msg.t, MsgCode.ROLE_PAYGEM_UPDATE) then
            me.assignWidget(self, "ybTxt"):setString(user.paygem)
        end
    end) 

    return true
end
function expchageLayer:onEnter()
    print("expchageLayer onEnter") 
	me.doLayout(self,me.winSize)  
end
function expchageLayer:onEnterTransitionDidFinish()
	print("expchageLayer onEnterTransitionDidFinish") 
end
function expchageLayer:onExit()
    UserModel:removeLisener(self.listener)
    print("expchageLayer onExit")    
end
function expchageLayer:close()
    self:removeFromParent()  
end
