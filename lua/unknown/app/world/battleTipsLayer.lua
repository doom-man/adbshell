--[Comment]
--jnmo
battleTipsLayer = class("battleTipsLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
battleTipsLayer.__index = battleTipsLayer
function battleTipsLayer:create(...)
    local layer = battleTipsLayer.new(...)
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
function battleTipsLayer:ctor()   
    print("battleTipsLayer ctor") 
end
function battleTipsLayer:init()   
    print("battleTipsLayer init")
	self.closebtn = me.registGuiClickEventByName(self,"close",function (node)
        guideHelper.setGuideIndex(guideHelper.guideIndex+1)
        guideHelper.nextTaskStep()
        self:close()     
    end)    
    self.btntitle = me.assignWidget(self,"btntitle")
    return true
end
function battleTipsLayer:onEnter()
    print("battleTipsLayer onEnter") 
	me.doLayout(self,me.winSize)  
--    if guideHelper.guideIndex == guideHelper.guideConquest+2 then
--        local guide = guideView:getInstance()
--        guide:showGuideView(self.closebtn,true,true,function ()
--        end,"zhucheng_waicheng_anniu_zhengchang.png",false)
--        addToCurrentView(guide)
--    end
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
function battleTipsLayer:onEnterTransitionDidFinish()
	print("battleTipsLayer onEnterTransitionDidFinish") 
end
function battleTipsLayer:onExit()
    print("battleTipsLayer onExit")    
    me.clearTimer(self.timer)
end
function battleTipsLayer:close()
    self:removeFromParent()  
end

