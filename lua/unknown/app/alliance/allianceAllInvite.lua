--[Comment]
--jnmo
allianceAllInvite = class("allianceAllInvite",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
allianceAllInvite.__index = allianceAllInvite
function allianceAllInvite:create(...)
    local layer = allianceAllInvite.new(...)
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
function allianceAllInvite:ctor()   
    print("allianceAllInvite ctor") 
end
function allianceAllInvite:init()   
    print("allianceAllInvite init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    
    return true
end
function allianceAllInvite:onEnter()
    print("allianceAllInvite onEnter") 
	me.doLayout(self,me.winSize)  
end
function allianceAllInvite:setData(pData)
      dump(pData)
     if pData then
        local pAllianceName = me.assignWidget(self,"Rank_alliance_name")
        pAllianceName:setString(pData["name"])

        local pAlliancelord = me.assignWidget(self,"alliance_name")
        pAlliancelord:setString(pData["ownerName"])

        local pFight = me.assignWidget(self,"allinace_fight")
        pFight:setString(me.toNum(pData["power"]))

        local pMember = me.assignWidget(self,"Rank_alliance_number")
        pMember:setString(pData["memberNumber"].."/"..pData["maxMember"])

        local pNotice = me.assignWidget(self,"alliance_invite_Text")
        pNotice:setString("你收到来自"..pData["ownerName"].."的邀请，你可以查看该联盟的信息，并决定是否加入他们")

        me.registGuiClickEventByName(self,"Button_add_alliance",function (node)
            self:close()  
            NetMan:send(_MSG.agreeFamily(pData["uid"],true))   -- 同意联盟邀请   
        end)  
     end
      
end
function allianceAllInvite:onEnterTransitionDidFinish()
	print("allianceAllInvite onEnterTransitionDidFinish") 
end
function allianceAllInvite:onExit()
    print("allianceAllInvite onExit")    
end
function allianceAllInvite:close()
    self:removeFromParentAndCleanup(true)  
end
