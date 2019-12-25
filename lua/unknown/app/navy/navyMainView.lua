navyMainView = class("navyMainView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
navyMainView.__index = navyMainView
function navyMainView:create(...)
    local layer = navyMainView.new(...)
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
function navyMainView:ctor()
    print("navyMainView:ctor()")
end
function navyMainView:enterBuildView()
    self:switchButtons(self.Button_build)
    self.Panel_bottom:removeAllChildren()
    local nb = navyBuildSubView:create("navyBuildSubView.csb")
    self.Panel_bottom:addChild(nb)
end
function navyMainView:enterUpgradeView()
    self:switchButtons(self.Button_upgrade)
    self.Panel_bottom:removeAllChildren()
    local nu = navyUpgradeSubView:create("navyUpgradeSubView.csb")
    self.Panel_bottom:addChild(nu)
end
function navyMainView:enterTechView()
    self:switchButtons(self.Button_tech)
    self.Panel_bottom:removeAllChildren()
    local nt = navyTechSubView:create("navyTechSubView.csb")
    self.Panel_bottom:addChild(nt)
end
function navyMainView:switchButtons(node)
    me.setButtonDisable(self.Button_tech,node ~= self.Button_tech)
    me.setButtonDisable(self.Button_upgrade,node ~= self.Button_upgrade)
    me.setButtonDisable(self.Button_build,node ~= self.Button_build)
end
function navyMainView:init()
    print("navyMainView:init()")
    self.Button_build=me.assignWidget(self,"Button_build")
    self.Button_upgrade=me.assignWidget(self,"Button_upgrade")
    self.Button_tech=me.assignWidget(self,"Button_tech")
    self.Panel_bottom = me.assignWidget(self,"Panel_bottom")
    return true
end
function navyMainView:update(msg)
    print("navyMainView:update(msg)")
    if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST) then
        print("!!!")
    end
end

function navyMainView:onEnter()
    print("navyMainView:onEnter()")
    me.doLayout(self,me.winSize)

--    self.close_event = me.RegistCustomEvent("navyMainView",function (evt)
--        self:close()
--    end)

    me.registGuiClickEvent(self.Button_build,function (node)
        showTips("暂未开放,尽请期待!")
        self:enterBuildView()
    end)
    me.registGuiClickEvent(self.Button_upgrade,function (node)
        showTips("暂未开放,尽请期待!")
        self:enterUpgradeView()
--        NetMan:send(_MSG.worldHeroIdentifyList())
    end)
    me.registGuiClickEvent(self.Button_tech,function (node)
        showTips("暂未开放,尽请期待!")
        self:enterTechView()
--        NetMan:send(_MSG.worldHeroSoldier())
    end)

    me.registGuiClickEventByName(self,"close",function (node)
        self:close()
    end)

    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"navyMainView")

    self:enterBuildView()
end
function navyMainView:onEnterTransitionDidFinish()
    print("navyMainView:onEnterTransitionDidFinish()")
end
function navyMainView:onExit()
    print("navyMainView:onExit()")
    me.RemoveCustomEvent(self.close_event)
    UserModel:removeLisener(self.modelkey)
end
function navyMainView:close()
    self:removeFromParentAndCleanup(true)
end
