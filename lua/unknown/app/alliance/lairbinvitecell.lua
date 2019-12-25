 lairbinvitecell = class("lairbinvitecell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
         local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
lairbinvitecell.__index = lairbinvitecell
function lairbinvitecell:create(...)
    local layer = lairbinvitecell.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function lairbinvitecell:ctor()  
   
end
function lairbinvitecell:init()   
    return true
end
function lairbinvitecell:setData(pData)
     if pData ~= nil then
     dump(pData)
       -- 名字
       local pName = me.assignWidget(self,"i_a_name")
       pName:setString(pData["name"])

       -- 等级
       local plevel = me.assignWidget(self,"i_a_level")
       plevel:setString(pData["level"])

       -- 战力
       local pFight = me.assignWidget(self,"i_a_fight")
       pFight:setString(pData["power"])

       -- 坐标
       local pPoint = me.assignWidget(self,"i_a_coordiate")
       pPoint:setString("("..pData["x"]..","..pData["y"]..")")      
     end
end
function lairbinvitecell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function lairbinvitecell:onExit()  
end

