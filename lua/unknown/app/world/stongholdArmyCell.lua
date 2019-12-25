 --[Comment]
--jnmo
stongholdArmyCell = class("stongholdArmyCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
stongholdArmyCell.__index = stongholdArmyCell
function stongholdArmyCell:create(...)
    local layer = stongholdArmyCell.new(...)
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
function stongholdArmyCell:ctor()   
    print("stongholdArmyCell ctor") 
end
function stongholdArmyCell:init()   
    print("stongholdArmyCell init")

    return true
end
function stongholdArmyCell:setData(pData)
     
    if pData then 
        local pConfig = pData.def
        local pIcon = me.assignWidget(self,"N_army_icon")
        pIcon:loadTexture(soldierIcon(pConfig),me.plistType)

        local pName = me.assignWidget(self,"N_army_name")
        pName:setString(pConfig.name)

        local pNum = me.assignWidget(self,"N_army_num")
        pNum:setString(pData.num)
    end
end
function stongholdArmyCell:onEnter()
    print("stongholdArmyCell onEnter") 
	--me.doLayout(self,me.winSize)  
end
function stongholdArmyCell:onEnterTransitionDidFinish()
	print("stongholdArmyCell onEnterTransitionDidFinish") 
end
function stongholdArmyCell:onExit()
    print("stongholdArmyCell onExit")    
end


