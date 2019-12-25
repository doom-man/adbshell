 --训练界面士兵ITEM
mapSignCell = class("mapSignCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2]):clone()
    end
end)
mapSignCell.__index = mapSignCell 
function mapSignCell:create(...)
    local layer = mapSignCell.new(...)
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
function mapSignCell:ctor()   
   -- print("mapSignCell ctor") 
    
end
function mapSignCell:init()   
    print("mapSignCell init")   
    self.Text_sName = me.assignWidget(self,"Text_sName")
    return true
end
function mapSignCell:initWithData(data)
  if data ~= nil then
     local pPint = me.assignWidget(self,"Text_sCrood")
     pPint:setString("("..data["X"]..","..data["Y"]..")")
     self.Text_sName:setString(data.name)
     if data.types == POINT_STRONG_HOLD then
        me.assignWidget(self,"Button_close"):setVisible(false)
        me.assignWidget(self,"s_icon"):loadTexture("judian_tubiao_judian_judian.png",me.plistType)
     else
        me.assignWidget(self,"Button_close"):setVisible(true)
         me.assignWidget(self,"s_icon"):loadTexture("waicheng_tubiao_biaoji_xiao.png",me.plistType)
     end

     if data.types == POINT_STRONG_HOLD then
        me.assignWidget(self,"armyIcon"):setVisible(true)
        local nums=0
        for _, v in ipairs(data.army) do
            nums=nums+v[2]
        end
        if nums>0 then
            me.assignWidget(self,"army_num"):setString(nums)
        else
            me.assignWidget(self,"armyIcon"):setVisible(false)
        end
     else
        me.assignWidget(self,"armyIcon"):setVisible(false)
     end
  --   local crood = cc.p(me.toNum(data["X"]),me.toNum(data["Y"]))
  --   local celldata = pWorldMap:getCellDataByCrood(crood)
--     if celldata then
--            if celldata.pointType==POINT_CITY then
--                self.Text_sName:setString(celldata:getOwnerData().name)
--            elseif celldata.pointType == POINT_POST then
--                self.Text_sName:setString(celldata:getOwnerData().name.."-贸易驿站")
--            elseif celldata.pointType == POINT_STRONG_HOLD then              
--             --   self.Text_sName:setString(celldata.strongHoldName)
--            else
--                local event = getMapConfigData(crood)
--                if event then
--                    self.Text_sName:setString(event.name)
--                end
--            end
--     else
--        local event = getMapConfigData(crood)
--        if event then
--        self.Text_sName:setString(event.name)
--        end
--     end
--     if data.name ~= nil then
--        self.Text_sName:setString(data.name)
--        me.assignWidget(self,"Button_close"):setVisible(false)
--     end
  end
end
function mapSignCell:onEnter()
  --  print("mapSignCell onEnter")	
end
function mapSignCell:onExit()
  --  print("mapSignCell onExit")    
end

