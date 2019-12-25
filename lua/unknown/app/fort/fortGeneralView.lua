fortGeneralView = class("fortGeneralView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
fortGeneralView.__index = fortGeneralView
function fortGeneralView:create(...)
    local layer = fortGeneralView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function fortGeneralView:ctor()
    print("fortGeneralView:ctor()")
end
function fortGeneralView:enterFortIdentify()
    self:switchButtons(self.Button_general)
    self.Panel_bottom:removeAllChildren()
    local fifv = fortIdentifyView:create("fortIdentifyView.csb")
    self.Panel_bottom:addChild(fifv)   
end
function fortGeneralView:enterfortExperiment()
    self:switchButtons(self.Button_fort)
    self.Panel_bottom:removeAllChildren()
    local pfortExperiment = fortExperiment:create("fortExperiment.csb")
    pfortExperiment:initInfo()
    self.Panel_bottom:addChild(pfortExperiment)   
end
function fortGeneralView:enterFortRecruit()   
    self:switchButtons(self.Button_order)
    self.Panel_bottom:removeAllChildren()
    local fortRecruit  = fortrecruit:create("fortRecruit.csb")
    self.Panel_bottom:addChild(fortRecruit)
end
function fortGeneralView:switchButtons(node)
    local btns = {self.Button_order, 
    --self.Button_general,
     self.Button_fort}
    for key, var in ipairs(btns) do
        if node ~= var then
            var:setEnabled(true)
            me.assignWidget(var, "nameTxt"):setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
            me.assignWidget(var, "nameTxt"):enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))
        else  
            var:setEnabled(false)  
            me.assignWidget(var,"nameTxt"):setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
            me.assignWidget(var,"nameTxt"):enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
        end
    end
end
function fortGeneralView:init()
    print("fortGeneralView:init()")
    self.Button_fort=me.assignWidget(self,"Button_fort") --要塞试炼
    self.Button_general=me.assignWidget(self,"Button_general") -- 名将图鉴
    self.Button_order=me.assignWidget(self,"Button_order") --要塞指令
    self.Panel_bottom = me.assignWidget(self,"Panel_bottom")
    return true
end
function fortGeneralView:update(msg)
    print("fortGeneralView:update(msg)")
    if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST) then
        self:enterFortIdentify()
    elseif checkMsg(msg.t, MsgCode.WORLF_FORT_HERO_SOLDIER) then
        self:enterFortRecruit()   
    end
end
  
function fortGeneralView:onEnter()
    print("fortGeneralView:onEnter()")
    me.doLayout(self,me.winSize)  
    self.close_event = me.RegistCustomEvent("fortGeneralView",function (evt)
        self:close()
    end)

    me.registGuiClickEvent(self.Button_fort,function (node)
        self:enterfortExperiment()
    end)
    me.registGuiClickEvent(self.Button_general,function (node)
     --   NetMan:send(_MSG.worldHeroIdentifyList())
    end)
    me.registGuiClickEvent(self.Button_order,function (node)   
        NetMan:send(_MSG.worldHeroSoldier())   
    end)

    me.registGuiClickEventByName(self,"close",function (node)        
        self:close()
    end)

    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"fortGeneralView")  

    self:enterfortExperiment()  
    
end
function fortGeneralView:onEnterTransitionDidFinish()
    print("fortGeneralView:onEnterTransitionDidFinish()")
end
function fortGeneralView:onExit()
    print("fortGeneralView:onExit()")
    me.RemoveCustomEvent(self.close_event)
    UserModel:removeLisener(self.modelkey)
end
function fortGeneralView:close()
    pWorldMap:setParentHero()
    self:removeFromParentAndCleanup(true)
end
