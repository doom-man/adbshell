navyBuildSubView = class("navyBuildSubView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
navyBuildSubView.__index = navyBuildSubView
function navyBuildSubView:create(...)
    local layer = navyBuildSubView.new(...)
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
function navyBuildSubView:ctor()
    print("navyBuildSubView:ctor()")
end

function navyBuildSubView:init()
    print("navyBuildSubView:init()")
    return true
end
function navyBuildSubView:update(msg)
    print("navyBuildSubView:update(msg)")
    if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST) then
        print("!!!")
    end
end
  
function navyBuildSubView:onEnter()
    print("navyBuildSubView:onEnter()")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"navyBuildSubView")  
end

function navyBuildSubView:onEnterTransitionDidFinish()
    print("navyBuildSubView:onEnterTransitionDidFinish()")
end

function navyBuildSubView:onExit()
    print("navyBuildSubView:onExit()")
    UserModel:removeLisener(self.modelkey)
end
function navyBuildSubView:close()
    self:removeFromParentAndCleanup(true)
end
