 --联盟创建 
captiveMemberCell = class("captiveMemberCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
captiveMemberCell.__index = captiveMemberCell
function captiveMemberCell:create(...)
    local layer = captiveMemberCell.new(...)
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
function captiveMemberCell:ctor()  
   
end
function captiveMemberCell:init()   
    return true
end
function captiveMemberCell:setData(pData)
    if pData~= nil then
       local pTimesLabel = me.assignWidget(self,"m_c_cell_times")
       local pTimes = cfg[CfgType.BUILDING][pData["clv"]]["era"]
        local pStr = "黑暗时代"
        if pTimes == 0  then
            pStr = "黑暗时代"     
        elseif pTimes == 1 then
            -- 封建
            pStr = "封建时代"
        elseif pTimes == 2 then
            -- 城堡
             pStr = "城堡时代"
        elseif pTimes == 3 then
            -- 帝王
            pStr = "帝王时代"
        end
      pTimesLabel:setString(pStr)
    -- 名称
      me.assignWidget(self,"m_c_cell_name"):setString(pData.name)
    -- 所属联盟
      me.assignWidget(self,"m_c_cell_unionName"):setString(pData.fname or "--")
   -- 领地数量
      me.assignWidget(self,"m_c_cell_num"):setString(pData.landSize)
   -- 坐标
      me.assignWidget(self,"m_c_cell_coordinate"):setString("("..pData.x..","..pData.y..")")
    end  
end

function captiveMemberCell:onEnter()   
end

function captiveMemberCell:onExit()  

end