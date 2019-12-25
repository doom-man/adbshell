-- [Comment]
-- jnmo
defSoldierHelp = class("defSoldierHelp", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
defSoldierHelp.__index = defSoldierHelp
function defSoldierHelp:create(...)
    local layer = defSoldierHelp.new(...)
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
function defSoldierHelp:ctor()
    print("defSoldierHelp ctor")

end


function defSoldierHelp:init()
    print("defSoldierHelp init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end

function defSoldierHelp:onEnter()
    print("defSoldierHelp onEnter")
    me.doLayout(self, me.winSize)
end
function defSoldierHelp:onEnterTransitionDidFinish()
    print("defSoldierHelp onEnterTransitionDidFinish")
end
function defSoldierHelp:onExit()

end
function defSoldierHelp:close()
    self:removeFromParent()
end


