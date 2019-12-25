--[Comment]
--jnmo
payShopView = class("payShopView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
payShopView.__index = payShopView
function payShopView:create(...)
    local layer = payShopView.new(...)
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
function payShopView:ctor()   
    print("payShopView ctor") 
end
function payShopView:init()   
    print("payShopView init")
	me.registGuiClickEventByName(self,"close",function (node)
        if mainCity then
            mainCity.bshopBox = nil
        end       
        self:close()     
    end)    
    for var = 1, 4 do
       local btn =  me.registGuiClickEventByName(self,"Button_"..var,function (node)
          local id = node.id
          dump()
          local pID = "1000"..id
          payMgr:getInstance():checkChooseIap(user.recharge[id])   
       end)
       btn.id = var
    end    
    return true
end
function payShopView:onEnter()
    print("payShopView onEnter") 
	me.doLayout(self,me.winSize)  
end
function payShopView:onEnterTransitionDidFinish()
	print("payShopView onEnterTransitionDidFinish") 
end
function payShopView:onExit()
    print("payShopView onExit")    
end
function payShopView:close()
    self:removeFromParent()  
end

