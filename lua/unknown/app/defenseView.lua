defenseView = class("defenseView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
defenseView.__index = defenseView
function defenseView:create(...)
    local layer = defenseView.new(...)
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
function defenseView:ctor()
end
function defenseView:init()
    self.Text_desc = me.assignWidget(self, "Text_desc")
    self.Text_defNum = me.assignWidget(self, "Text_defNum")
    self.LoadingBar_defense = me.assignWidget(self, "LoadingBar_defense")
    self.Text_bLeftTitle = me.assignWidget(self, "Text_bLeftTitle")
    self.Text_bLeftDesc = me.assignWidget(self, "Text_bLeftDesc")
    self.Text_desc = me.assignWidget(self, "Text_bRightTitle")
    self.Text_defNum = me.assignWidget(self, "Text_bRightDesc")
    self.Text_diamonds = me.assignWidget(self, "Text_diamonds")
    self.Text_upLeftTime = me.assignWidget(self, "Text_upLeftTime")

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    me.registGuiClickEventByName(self, "Button_ask", function(node)
        showTips("暂时未开放")
    end )

    me.registGuiClickEventByName(self, "Button_fire", function(node)
        showTips("灭火")
    end )
    me.registGuiClickEventByName(self, "Button_imm", function(node)
        showTips("立即达成")
    end )
    me.registGuiClickEventByName(self, "Button_powerup", function(node)
        showTips("加强城防")
    end )
   
    return true
end
function defenseView:initData()
    self.Text_defNum:setString("--/--")
end
function defenseView:onEnter()
    print("defenseView:onEnter()")
    self:initData()
end
function defenseView:onEnterTransitionDidFinish()
end
function defenseView:onExit()
    print("defenseView:onExit()")
end
function defenseView:close()
    print("defenseView:close()")
    self:removeFromParentAndCleanup(true)
end

