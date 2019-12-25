payView = class("payView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
payView.__index = payView
function payView:create(...)
    local layer = payView.new(...)
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
function payView:ctor()
    print("payView ctor")
    self.data = nil

end

function payView:close()
    self:removeFromParentAndCleanup(true)
end
function payView:init()
    print("payView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "appleBtn", function(node)
        payMgr:getInstance():getOrderId(ORDER_SOURCE_APPLE)
    end )
    me.registGuiClickEventByName(self, "aliBtn", function(node)

        payMgr:getInstance():getOrderId(ORDER_SOURCE_ALIPY)
    end )
    me.registGuiClickEventByName(self, "wechatBtn", function(node)

        payMgr:getInstance():getOrderId(ORDER_SOURCE_WEIXIN)
    end )
    return true
end
function payView:initWithData(data)    
    self.data = data
end
function payView:onEnter()
    print("payView onEnter")
    me.doLayout(self, me.winSize)
end
function payView:enterTransitionFinish()
end
function payView:onExit()
    print("payView onExit")
end