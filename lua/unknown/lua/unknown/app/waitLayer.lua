--[Comment]
--等待界面
waitLayer = class("waitLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
waitLayer.__index = waitLayer
function waitLayer:create(...)
    local layer = waitLayer.new(...)
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
function waitLayer:ctor()   
    print("waitLayer ctor") 
end
function waitLayer:init()   
    print("waitLayer init")
    self.aniVisiabled = false
    self.tips = nil
    return true
end
function waitLayer:onEnter()
    print("waitLayer onEnter") 
	me.doLayout(self,me.winSize)  
    local img = me.assignWidget(self,"Image_Load")
    local a = cc.RotateBy:create(1,360)
    local a1 = cc.Sequence:create(a)
    local a2 = cc.RepeatForever:create(a1)
    img:runAction(a2)
    img:setVisible(self.aniVisiabled)

    
    me.registGuiTouchEvent(me.assignWidget(self,"fixLayout"),function (node,event)
        if event ~= ccui.TouchEventType.ended then
            return
        end 
        if self.tips ~= nil  then
            showTips(self.tips)
        end
    end)
end
function waitLayer:onEnterTransitionDidFinish()
	print("waitLayer onEnterTransitionDidFinish") 
end
function waitLayer:onExit()
    print("waitLayer onExit")    
end
function waitLayer:close()
    self:removeFromParentAndCleanup(true)  
end
function waitLayer:hideAni(visiable_)
    self.aniVisiabled = not visiable_
    me.assignWidget(self,"Image_Load"):setVisible(self.aniVisiabled)
end
function waitLayer:setTipsInfo(str_)
    self.tips = str_
end