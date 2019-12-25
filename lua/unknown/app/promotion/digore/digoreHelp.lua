-- [Comment]
-- jnmo
digoreHelp = class("digoreHelp", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
digoreHelp.__index = digoreHelp
function digoreHelp:create(...)
    local layer = digoreHelp.new(...)
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
function digoreHelp:ctor()
    print("digoreHelp ctor")

end


function digoreHelp:init()
    print("digoreHelp init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end

function digoreHelp:onEnter()
    print("digoreHelp onEnter")
    me.doLayout(self, me.winSize)
end
function digoreHelp:onEnterTransitionDidFinish()
    print("digoreHelp onEnterTransitionDidFinish")
end
function digoreHelp:onExit()

end
function digoreHelp:close()
    self:removeFromParent()
end


