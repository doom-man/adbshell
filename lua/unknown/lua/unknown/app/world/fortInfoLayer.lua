fortInfoLayer = class("fortInfoLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
fortInfoLayer.__index = fortInfoLayer
function fortInfoLayer:create(...)
    local layer = fortInfoLayer.new(...)
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
function fortInfoLayer:ctor()   
    print("fortInfoLayer ctor") 
end
function fortInfoLayer:init()   
    print("fortInfoLayer init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function fortInfoLayer:onEnter()
    print("fortInfoLayer onEnter") 
	me.doLayout(self,me.winSize)  
end
function fortInfoLayer:onEnterTransitionDidFinish()
	print("fortInfoLayer onEnterTransitionDidFinish") 
end
function fortInfoLayer:onExit()
    print("fortInfoLayer onExit")    
end
function fortInfoLayer:close()
        me.DelayRun(function ()
             self:removeFromParentAndCleanup(true)  
        end)     
end
