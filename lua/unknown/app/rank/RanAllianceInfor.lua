 --[Comment]
--jnmo
RanAllianceInfor = class("RanAllianceInfor",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
RanAllianceInfor.__index = RanAllianceInfor
function RanAllianceInfor:create(...)
    local layer = RanAllianceInfor.new(...)
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
function RanAllianceInfor:ctor()   
    print("RanAllianceInfor ctor") 
end
function RanAllianceInfor:init()   
    print("RanAllianceInfor init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function RanAllianceInfor:setData(pData)
    if pData then
       dump(pData)
       local pName = me.assignWidget(self,"Rank_alliance_name")
       pName:setString(pData["name"])

       local pLevel = me.assignWidget(self,"Rank_level")
       pLevel:setString(getLvStrByPlatform().."."..pData["level"])

       local pMember = me.assignWidget(self,"Rank_alliance_number")
       pMember:setString(pData["memberNumber"])

       local pPower = me.assignWidget(self,"Rank_alliance_fight")
       pPower:setString(pData["power"])

       local pNotice = me.assignWidget(self,"alliance_notice")
       pNotice:setString(pData["notice"])

       local owner = me.assignWidget(self,"owner")
       owner:setString(pData["ownerName"])

    end
end
function RanAllianceInfor:onEnter()
    print("RanAllianceInfor onEnter") 
	me.doLayout(self,me.winSize)  
end
function RanAllianceInfor:onEnterTransitionDidFinish()
	print("RanAllianceInfor onEnterTransitionDidFinish") 
end
function RanAllianceInfor:onExit()
    print("RanAllianceInfor onExit")    
end
function RanAllianceInfor:close()
    self:removeFromParentAndCleanup(true)  
end

