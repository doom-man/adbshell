exilePrompt = class("exilePrompt",function (...)
     local arg = {...}
    if table.getn(arg) == 2 then    
        return arg[1]:getChildByName(arg[2])
    else
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return cc.CSLoader:createNode(arg[1])
    end
end)
exilePrompt.__index = exilePrompt
function exilePrompt:create(...)
    local layer = exilePrompt.new(...)
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

function exilePrompt:ctor(...)   
    print("exilePrompt ctor") 
    _, _, self.cp = ...
end
function exilePrompt:init()   
    print("exilePrompt init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)   
    me.registGuiClickEventByName(self,"btn1",function (node)
        self:close()     
    end)    
    
    local celldata = pWorldMap:getCellDataByCrood(self.cp)
    local ldata = celldata:getOwnerData()

    self.exileBtn = me.assignWidget(self, "btn2")
    me.registGuiClickEvent(self.exileBtn, function(node)
        NetMan:send(_MSG.Lord_exile(ldata.uid)) 
        if pWorldMap.mapOptmenuView ~= nil then
            pWorldMap.mapOptmenuView:setVisible(false)
        end
        self:close()
    end)
    if user.familyDegree and(user.familyDegree == 1 or user.familyDegree == 2) then
        self.exileBtn:setBright(true)
        self.exileBtn:setTouchEnabled(true)
    else
        self.exileBtn:setBright(false)
        self.exileBtn:setTouchEnabled(false)
    end

    
    self.playerNameTxt = me.assignWidget(self, "playerName")
    self.playerNameTxt:setString(ldata.name)

    return true
end


function exilePrompt:onEnter()
    print("exilePrompt onEnter") 
	me.doLayout(self,me.winSize)  

    me.assignWidget(self, "symbolTxt"):setPositionX(self.playerNameTxt:getPositionX()+self.playerNameTxt:getContentSize().width+2)

end
function exilePrompt:onEnterTransitionDidFinish()
	print("exilePrompt onEnterTransitionDidFinish") 
end
function exilePrompt:onExit()
    print("exilePrompt onExit")    
end
function exilePrompt:close() 
    self:removeFromParentAndCleanup(true) 
    
end

