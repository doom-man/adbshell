--[Comment]
--jnmo
kingdomView_foundation_award = class("kingdomView_foundation_award",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2]):clone()
        pCell:setVisible(true)
        return pCell 
    end
end)
kingdomView_foundation_award.__index = kingdomView_foundation_award
function kingdomView_foundation_award:create(...)
    local layer = kingdomView_foundation_award.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function kingdomView_foundation_award:ctor()   
    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    -- 注册点击事件
    me.registGuiClickEventByName(self, "Button_comfirm", function(node)
        self:close()
    end )
    self.cell1 = me.assignWidget(self, "Panel_res")

    self.cell2 = me.assignWidget(self, "Panel_res1")
end
function kingdomView_foundation_award:init()   

	
    return true
end

function kingdomView_foundation_award:setData(data)   
    me.assignWidget(self.cell1,"Text_food"):setString(data.salary.food)
    me.assignWidget(self.cell1,"Text_wood"):setString(data.salary.wood)
    me.assignWidget(self.cell1,"Text_stone"):setString(data.salary.stone)
    me.assignWidget(self.cell1,"Text_gold"):setString(data.salary.gold)

    if data.ext then
        self.cell2:setVisible(true)
        me.assignWidget(self.cell2,"Text_food"):setString(data.ext.food)
        me.assignWidget(self.cell2,"Text_wood"):setString(data.ext.wood)
        me.assignWidget(self.cell2,"Text_stone"):setString(data.ext.stone)
        me.assignWidget(self.cell2,"Text_gold"):setString(data.ext.gold)
    else
        self.cell2:setVisible(false)
    end
end

function kingdomView_foundation_award:onEnter()
    print("kingdomView_foundation_award onEnter") 
	  
end
function kingdomView_foundation_award:onEnterTransitionDidFinish()
	print("kingdomView_foundation_award onEnterTransitionDidFinish") 
end
function kingdomView_foundation_award:onExit()

end
function kingdomView_foundation_award:close()
    self:removeFromParentAndCleanup(true)  
end


