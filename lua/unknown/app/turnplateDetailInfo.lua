-- [Comment]
-- jnmo
turnplateDetailInfo = class("turnplateDetailInfo", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
turnplateDetailInfo.__index = turnplateDetailInfo
function turnplateDetailInfo:create(...)
    local layer = turnplateDetailInfo.new(...)
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
function turnplateDetailInfo:ctor()
    print("turnplateDetailInfo ctor")
end
function turnplateDetailInfo:init()
    print("turnplateDetailInfo init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.list = me.assignWidget(self, "list")
    return true
end
function turnplateDetailInfo:initWithData(data)
    local datas = { }
    for key, var in pairs(data) do
        if var.value == var.max then
            table.insert(datas, var)
        else
            table.insert(datas, 1, var)
        end
    end
    local tmp = me.assignWidget(self, "ImageView_Bg")
    for key, var in pairs(datas) do
        local item = tmp:clone():setVisible(true)
        local Text_title = me.assignWidget(item, "Text_title")
        local Text_itemNum = me.assignWidget(item, "Text_itemNum")
        local bg_cell = me.assignWidget(item, "bg_cell")
        Text_title:setString(var.desc)
        Text_itemNum:setString(var.value .. "/" .. var.max)
        self.list:pushBackCustomItem(item)
        bg_cell:setVisible(key%2==0)
    end
end
function turnplateDetailInfo:onEnter()
    print("turnplateDetailInfo onEnter")
    me.doLayout(self, me.winSize)
end
function turnplateDetailInfo:onEnterTransitionDidFinish()
    print("turnplateDetailInfo onEnterTransitionDidFinish")
end
function turnplateDetailInfo:onExit()
    print("turnplateDetailInfo onExit")
end
function turnplateDetailInfo:close()
    self:removeFromParent()
end
