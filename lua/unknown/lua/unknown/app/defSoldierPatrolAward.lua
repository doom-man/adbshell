--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
defSoldierPatrolAward = class("defSoldierPatrolAward", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
defSoldierPatrolAward.__index = defSoldierPatrolAward

function defSoldierPatrolAward:create(...)
    local layer = defSoldierPatrolAward.new(...)
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

function defSoldierPatrolAward:ctor()

end



function defSoldierPatrolAward:init()
    
    self.ItemPanel = me.assignWidget(self, "ItemPanel")
    self.listView = me.assignWidget(self, "ListView")
    self.listView:setScrollBarPositionFromCornerForVertical(cc.p(2, 2))
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)

    self.awardBtn = me.assignWidget(self, "awardBtn")
    me.registGuiClickEvent(self.awardBtn, function()
        if self.data.status<2 then
            showTips("结束巡逻后可领取奖励")
        else
            NetMan:send(_MSG.guard_patrol_get())
            self:close()
        end
    end)

    return true
end

function defSoldierPatrolAward:setData(data)
    self.listView:removeAllItems()
    self.data = data
    if self.data.status<2 then
        --self.awardBtn:setVisible(false)
        self.awardBtn:setBright(false)
    else
        --self.awardBtn:setVisible(true)
        self.awardBtn:setBright(true)
    end
    if self.data.items==nil then return end

    table.sort(self.data.items, function(a, b)
                                    if a[1] > b[1] then
                                        return true
                                    end
    end)
    local itemPanel = nil
    local w=0
    for key, var in ipairs(self.data.items) do
        if (key-1)%5==0 then
            w=0
            itemPanel = self.ItemPanel:clone():setVisible(true)
            self.listView:pushBackCustomItem(itemPanel)
        end
        item = BackpackCell:create("backpack/backpackcell.csb")
        var.defid=var[1]
        var.count=var[2]
        item:setScale(0.7)
        item:setUI(var)  
        item:setAnchorPoint(0, 0)   
        item:setPosition(w*138+42, 0)  
        local btnBg = me.assignWidget(item,"Button_bg")
        me.registGuiClickEvent(btnBg,function ()
            showPromotion(var[1],var[2])
        end)  
        btnBg:setSwallowTouches(false)
        if var[2]==1 then
            me.assignWidget(item, "num_bg"):setVisible(false)
        end
        itemPanel:addChild(item)
        w=w+1
    end
    
end

function defSoldierPatrolAward:onEnter()
    
    me.doLayout(self,me.winSize)
end


function defSoldierPatrolAward:onExit()
    print("defSoldierPatrolAward:onExit()")
end
function defSoldierPatrolAward:close()
    self:removeFromParentAndCleanup(true)
    
end

