navyUpgradeSubView = class("navyUpgradeSubView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
navyUpgradeSubView.__index = navyUpgradeSubView
function navyUpgradeSubView:create(...)
    local layer = navyUpgradeSubView.new(...)
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
function navyUpgradeSubView:ctor()
    print("navyUpgradeSubView:ctor()")
end

function navyUpgradeSubView:init()
    print("navyUpgradeSubView:init()")
    return true
end
function navyUpgradeSubView:update(msg)
    print("navyUpgradeSubView:update(msg)")
    if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST) then
        print("!!!")
    end
end
  
function navyUpgradeSubView:onEnter()
    print("navyUpgradeSubView:onEnter()")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"navyUpgradeSubView")  
end

function navyUpgradeSubView:onEnterTransitionDidFinish()
    print("navyUpgradeSubView:onEnterTransitionDidFinish()")
end

function navyUpgradeSubView:onExit()
    print("navyUpgradeSubView:onExit()")
    UserModel:removeLisener(self.modelkey)
end
function navyUpgradeSubView:close()
    self:removeFromParentAndCleanup(true)
end
