--[Comment]
--jnmo
pointTroopsLayer = class("pointTroopsLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
pointTroopsLayer.__index = pointTroopsLayer
function pointTroopsLayer:create(...)
    local layer = pointTroopsLayer.new(...)
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
function pointTroopsLayer:ctor()   
    print("pointTroopsLayer ctor") 
end
function pointTroopsLayer:init()   
    print("pointTroopsLayer init")
	  me.registGuiTouchEventByName(self,"fixLayout",function (node,event)
           if event == ccui.TouchEventType.began then 
                node:setSwallowTouches(false)
                self:close()
            end
end)     
    return true
end
function pointTroopsLayer:onEnter()
    print("pointTroopsLayer onEnter") 
	me.doLayout(self,me.winSize)  
end
function pointTroopsLayer:onEnterTransitionDidFinish()
	print("pointTroopsLayer onEnterTransitionDidFinish") 
end
function pointTroopsLayer:onExit()
    print("pointTroopsLayer onExit")    
end
function pointTroopsLayer:close()
    local a1 = cc.MoveTo:create(0.2,cc.p(320,0))
     local function Aniend(args)
        self:stopAllActions()
        self:removeFromParentAndCleanup(true)
     end
     local call = cc.CallFunc:create(Aniend)
     local seq = cc.Sequence:create(a1,call)
     self:runAction(seq)
end

