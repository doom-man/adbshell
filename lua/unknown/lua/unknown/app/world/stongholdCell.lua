--[Comment]
--jnmo
stongholdCell = class("stongholdCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
stongholdCell.__index = stongholdCell
function stongholdCell:create(...)
    local layer = stongholdCell.new(...)
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
function stongholdCell:ctor()   
    print("stongholdCell ctor") 
end
function stongholdCell:init()   
    print("stongholdCell init")

    return true
end
function stongholdCell:setData(pData)  
    if pData then
        local pIcon = me.assignWidget(self,"R_tronsfer_icon")
        if pData.pType == strongholdlist.CITY then
           pIcon:loadTexture("judian_tubiao_judian_zhucheng.png",me.plistType)
        else
           pIcon:loadTexture("judian_tubiao_judian_judian.png",me.plistType)
        end

        local pName = me.assignWidget(self,"R_tromnsfer_name")
        pName:setString(pData.name)

        local pDistance = me.assignWidget(self,"R_tromnsfer_distance")
        pDistance:setString(pData.distance)

        local pArmyNum = me.assignWidget(self,"R_tronsfer_num")
        pArmyNum:setString(pData.armyNum)
    end
end
function stongholdCell:onEnter()
    print("stongholdCell onEnter") 
	--me.doLayout(self,me.winSize)  
end
function stongholdCell:onEnterTransitionDidFinish()
	print("stongholdCell onEnterTransitionDidFinish") 
end
function stongholdCell:onExit()
    print("stongholdCell onExit")    
end

