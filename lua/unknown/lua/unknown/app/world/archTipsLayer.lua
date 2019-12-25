--[Comment]
--jnmo
archTipsLayer = class("archTipsLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
archTipsLayer.__index = archTipsLayer
function archTipsLayer:create(...)
    local layer = archTipsLayer.new(...)
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
function archTipsLayer:ctor()   
    print("archTipsLayer ctor") 
end
function archTipsLayer:init()   
    print("archTipsLayer init")
    self.closebtn = me.registGuiClickEventByName(self,"close",function (node)
        if not Queue.isEmpty(UserModel.msgControlQueue) then
                  local msg = Queue.pop(UserModel.msgControlQueue)
                  UserModel:reviceData(msg,mCross_Sever_Out,true)
        end  
        guideHelper.setGuideIndex(guideHelper.guide_End)      
        self:close()     
    end)
    self.btntitle = me.assignWidget(self,"btntitle") 
    if pWorldMap then
         if pWorldMap.mapOptmenuView and pWorldMap.mapOptmenuView:isVisible() == true then
            pWorldMap.mapOptmenuView:hide()
        end
    end 
    return true
end
function archTipsLayer:onEnter()
    print("archTipsLayer onEnter") 
	me.doLayout(self,me.winSize)  
     local xtime = 5
      self.btntitle:setString(xtime)
      self.timer = me.registTimer(5,function (dt,b)
              xtime = xtime - 1
              self.btntitle:setString(xtime)
              if b then
                   me.setButtonDisable(self.closebtn,true)
                   self.btntitle:setString("确 定")
                   guideHelper.removeWaitLayer()
              end
      end,1)
      me.setButtonDisable(self.closebtn,false)
end
function archTipsLayer:onEnterTransitionDidFinish()
	print("archTipsLayer onEnterTransitionDidFinish") 
end
function archTipsLayer:onExit()
    print("archTipsLayer onExit")    
    me.clearTimer(self.timer)
end
function archTipsLayer:close()
    self:removeFromParent()  
end

