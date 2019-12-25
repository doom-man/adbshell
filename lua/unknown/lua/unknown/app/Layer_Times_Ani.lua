--[Comment]
--jnmo
Layer_Times_Ani = class("Layer_Times_Ani",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
Layer_Times_Ani.__index = Layer_Times_Ani
function Layer_Times_Ani:create(...)
    local layer = Layer_Times_Ani.new(...)
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
function Layer_Times_Ani:ctor()   
    print("Layer_Times_Ani ctor") 
end
function Layer_Times_Ani:init()   
    print("Layer_Times_Ani init")
   
    return true
end
function Layer_Times_Ani:playTimesAni(time)
    self.sk = sp.SkeletonAnimation:create("animation/ui_anim_shidai_01.json", "animation/ui_anim_shidai_01.atlas", 1)
    me.assignWidget(self, "fixLayout"):addChild(self.sk)
    self.sk:setPosition(me.winSize.width / 2, me.winSize.height/2)
    self.sk:setAnimation(0, "animation"..time, false)  
    self.sk:registerSpineEventHandler(function (event)     
        me.assignWidget(mainCity, "Button_Troop"):loadTexture("tiem_flag" .. getCenterBuildingTime() .. ".png", me.localType) 
        me.DelayRun(function (args)
            if not Queue.isEmpty(UserModel.msgControlQueue) then
                     local msg = Queue.pop(UserModel.msgControlQueue)
                     UserModel:reviceData(msg,mCross_Sever_Out,true)
            end
        end,1)
        self:close()
    end, sp.EventType.ANIMATION_EVENT)
end
function Layer_Times_Ani:onEnter()
    print("Layer_Times_Ani onEnter") 
	me.doLayout(self,me.winSize)  
end
function Layer_Times_Ani:onEnterTransitionDidFinish()
	print("Layer_Times_Ani onEnterTransitionDidFinish") 
end
function Layer_Times_Ani:onExit()
    print("Layer_Times_Ani onExit")    
end
function Layer_Times_Ani:close()
    self:removeFromParent()  
end
