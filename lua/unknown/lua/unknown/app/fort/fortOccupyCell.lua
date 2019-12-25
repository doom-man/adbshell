 --[Comment]
--jnmo
fortOccupyCell = class("fortOccupyCell",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）      
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
fortOccupyCell.__index = fortOccupyCell
function fortOccupyCell:create(...)
    local layer = fortOccupyCell.new(...)
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
function fortOccupyCell:ctor()   
    print("fortOccupyCell ctor") 
end
function fortOccupyCell:init()   
     
    return true
end
function fortOccupyCell:setData(pData)
     if pData then     
        local pConfigData = GFortData()[pData["id"]]  
        local pIcon = me.assignWidget(self,"fort_cell_icon")
        pIcon:loadTexture("waicheng_yaosai_shijie_"..pConfigData["icon"]..".png",me.plistType)
        me.resizeImage(pIcon,80,80)
        local pName = me.assignWidget(self,"fort_cell_name")
        local pPos = me.assignWidget(self,"fort_cell_pos")
        pName:setString(pConfigData["name"])
        local cr = pData:getCrood()
        pPos:setString("("..cr.x..","..cr.y..")")
        local pFortData = user.fortWorldData[pData["id"]]    
        if pFortData == nil then    -- 未占领
              pName:setTextColor(cc.c4b(255,255,255,255)) 
        else                
              if pFortData["mine"] == 1 then -- 自己联盟占领
                   pName:setTextColor(cc.c4b(57,142,182,255))          
              elseif pFortData["mine"] == 0 then -- 敌对占领
                   pName:setTextColor(cc.c4b(184,61,61,255))   
              end             
         end                             
     end
end
function fortOccupyCell:onEnter()
    print("fortOccupyCell onEnter") 
	--me.doLayout(self,me.winSize)  
end
function fortOccupyCell:onEnterTransitionDidFinish()
	print("fortOccupyCell onEnterTransitionDidFinish") 
end
function fortOccupyCell:onExit()
    print("fortOccupyCell onExit")    
end
function fortOccupyCell:close()
    self:removeFromParentAndCleanup(true)  
end

