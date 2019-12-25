--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
runeBreakBatch = class("runeBreakBatch", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
runeBreakBatch.__index = runeBreakBatch

function runeBreakBatch:create(...)
    local layer = runeBreakBatch.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end

function runeBreakBatch:ctor()

end



function runeBreakBatch:init()
    
    for i=1, 3 do
        local p = me.assignWidget(me.assignWidget(self, "cell"..i), "panel")
        p.id=i
        me.registGuiClickEvent(p, handler(self, self.clickCheck))
        me.assignWidget(p,"cbox"):setTouchEnabled(false)
    end
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)
    me.registGuiClickEventByName(self, "okBtn", handler(self, self.ok))

    return true
end

function runeBreakBatch:ok()
    for i=1, 3 do
        local p = me.assignWidget(me.assignWidget(self, "cell"..i), "panel")
        local checkBox = me.assignWidget(p, "cbox")
        if checkBox:isSelected() then
            NetMan:send(_MSG.Rune_resolve(nil, i+2))
            self:close()
            return
        end
    end
    showTips("请选择要分解的星级")
end

function runeBreakBatch:clickCheck(node)
    id = node.id
    for i=1, 3 do
        local p = me.assignWidget(me.assignWidget(self, "cell"..i), "panel")
        local checkBox = me.assignWidget(p, "cbox")
        checkBox:setSelected(false)
        if i==id then
            checkBox:setSelected(true)
        end
    end
end

function runeBreakBatch:onEnter()
    
    me.doLayout(self,me.winSize)
end


function runeBreakBatch:onExit()
    print("runeBreakBatch:onExit()")
end
function runeBreakBatch:close()
    self:removeFromParentAndCleanup(true)
    
end

