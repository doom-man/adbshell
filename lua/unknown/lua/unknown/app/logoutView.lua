logoutView = class("logoutView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
logoutView.__index = logoutView
function logoutView:create(...)
    local layer = logoutView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:enterTransitionFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function logoutView:ctor()
    print("logoutView ctor")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        self:close()
    end )
end

function logoutView:close()
    self:removeFromParentAndCleanup(true)
end

function logoutView:init()
    print("logoutView init")
    me.assignWidget(self,"account"):setString(user.uid)
    self.logoutBtn = me.registGuiClickEventByName(self,"logoutBtn",function(node)  
       me.showMessageDialog("是否确定退出游戏？",function (evt)
            if evt == "ok" then
                   if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                       --jjGameSdk.logoutSdk()
                       me.Helper:endGame()
                   end
            end
      end)     
    end)
    self.logoutBtn :setTitleText("退出游戏")
    return true
end
function logoutView:onEnter()
    print("logoutView onEnter")
    me.doLayout(self,me.winSize)
end
function logoutView:enterTransitionFinish()
end
function logoutView:onExit()
    print("logoutView onExit")
end
