--[Comment]
--jnmo
allianceInvite = class("allianceInvite",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
allianceInvite.__index = allianceInvite
function allianceInvite:create(...)
    local layer = allianceInvite.new(...)
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
function allianceInvite:ctor()   
    print("allianceInvite ctor") 
end
function allianceInvite:init()   
    print("allianceInvite init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    me.registGuiClickEventByName(self,"Button_add_alliance",function (node)
          if user.diamond < 200  then
            showTips("钻石不足")
        else
            NetMan:send(_MSG.inviteAllFamily())         
            self:close()       
        end    
              
    end)    
   
    return true
end
function allianceInvite:onEnter()
    print("allianceInvite onEnter") 
	me.doLayout(self,me.winSize)  
end
 
function allianceInvite:onEnterTransitionDidFinish()
	print("allianceInvite onEnterTransitionDidFinish") 
end
function allianceInvite:onExit()
    print("allianceInvite onExit")    
end
function allianceInvite:close()
    self:removeFromParentAndCleanup(true)  
end
