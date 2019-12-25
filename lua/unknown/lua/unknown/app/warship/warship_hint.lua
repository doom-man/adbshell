--[Comment]
--jnmo
warship_hint = class("warship_hint",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
warship_hint.__index = warship_hint
function warship_hint:create(...)
    local layer = warship_hint.new(...)
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
function warship_hint:ctor()   
    print("warship_hint ctor") 
    self.ShipHint = 0 -- 0 提示 1 不提示
    self.listener = nil
end
function warship_hint:init()   
    print("warship_hint init")
    self.ShipHint = mWarshipHint  
	me.registGuiClickEventByName(self,"fixLayout",function (node)
         me.hideLayer(self,true,"fixLayout")    
    end)    

    me.registGuiClickEventByName(self,"btn_ok",function (node)
         if self.listener then           
            self.listener("ok")
         end
         mWarshipHint = self.ShipHint
         SharedDataStorageHelper():setWarshipHint(self.ShipHint)
          me.hideLayer(self,true,"fixLayout")
         -- self.close()
    end)

     me.registGuiClickEventByName(self,"btn_cancel",function (node)
        me.hideLayer(self,true,"fixLayout")
    end)
    local Image_hint = me.assignWidget(self,"Image_11")
    if self.ShipHint == 0 then
       Image_hint:setVisible(false)
    else
       Image_hint:setVisible(true) 
    end
   
    me.registGuiTouchEventByName(self,"Text_2",function (node, event)   
       if event == ccui.TouchEventType.ended then        
            if self.ShipHint == 1 then
               self.ShipHint = 0
              -- mWarshipHint = self.ShipHint
               Image_hint:setVisible(false)            
            else
               self.ShipHint = 1
            --   mWarshipHint = self.ShipHint
               Image_hint:setVisible(true)
           --    SharedDataStorageHelper():setWarshipHint(self.ShipHint)
            end
        end
    end)

    return true
end
function warship_hint:register(listener)
    if listener then        
       self.listener = listener   
    end
end

function warship_hint:onEnter()
    print("warship_hint onEnter") 
	me.doLayout(self,me.winSize)  
end
function warship_hint:onEnterTransitionDidFinish()
	print("warship_hint onEnterTransitionDidFinish") 
end
function warship_hint:onExit()
    print("warship_hint onExit")    
end
function warship_hint:close()
    self:removeFromParentAndCleanup(true)  
end
