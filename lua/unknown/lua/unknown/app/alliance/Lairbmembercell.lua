 --联盟创建 
Lairbmembercell = class("Lairbmembercell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
Lairbmembercell.__index = Lairbmembercell
function Lairbmembercell:create(...)
    local layer = Lairbmembercell.new(...)
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
function Lairbmembercell:ctor()  
  
end
function Lairbmembercell:init()   
    self.pTime = nil
    local Image_mine = me.assignWidget(self,"Image_mine")
    -- Image_mine:setScale9Enabled(true)
    -- Image_mine:ignoreContentAdaptWithSize(false)
    -- Image_mine:setCapInsets(cc.rect(29, 29, 31, 31))
    -- Image_mine:setContentSize(cc.size(1158, 103))
    return true
end
function Lairbmembercell:setData(pData,pUid)
    if pData~= nil then     
       me.clearTimer(self.pTime)
    -- 名称
      local pM_M_anme = me.assignWidget(self,"m_m_cell_name")
      pM_M_anme:setString(pData["name"])
    -- 等级
      local pM_M_level = me.assignWidget(self,"m_m_cell_level")
      pM_M_level:setString(pData["level"])
   -- 战斗力
      local pM_M_Fight = me.assignWidget(self,"m_m_cell_fight")
      pM_M_Fight:setString(pData["power"])
   -- 贡献
      local pM_M_Contribution = me.assignWidget(self,"m_m_cell_contribution")
      pM_M_Contribution:setString(pData["contribution"])
   -- 职位
      local pM_M_Postion = me.assignWidget(self,"m_m_cell_postion")
      pM_M_Postion:setString(me.alliancedegree(pData["degree"]))
       if pData["degree"] == 1 and user.familyabdicatetime > 0 then        
         me.assignWidget(self,"m_m_cell_hand_lord"):setString("禅让："..me.formartSecTime(user.familyabdicatetime))
         me.assignWidget(self,"m_m_cell_hand_lord"):setVisible(true)
         
         if user.familyMember["degree"] == 1 then
            me.assignWidget(self,"m_m_cell_appoint_button"):setVisible(false)
            me.assignWidget(self,"m_m_cell_cancel_button"):setVisible(true)
         end
         self.pCancelTime = user.familyabdicatetime        
         self.pTime = me.registTimer(-1,function(dt)
             if self.pCancelTime == 0 then
                 me.clearTimer(self.pTime)            
             end
             self.pCancelTime = self.pCancelTime -1
             me.assignWidget(self,"m_m_cell_hand_lord"):setString("禅让："..me.formartSecTime(self.pCancelTime))
             me.assignWidget(self,"m_m_cell_hand_lord"):setVisible(true)                      
            end,1)
      else
         me.assignWidget(self,"m_m_cell_hand_lord"):setVisible(false)
         me.assignWidget(self,"m_m_cell_appoint_button"):setVisible(true)
         me.assignWidget(self,"m_m_cell_cancel_button"):setVisible(false)
      end
      -- 离线时间
      local pOfflineTime = me.assignWidget(self,"m_m_cell_time")
   -- 坐标
      local pMyData = user.familyMember
      local pMyDegree = pMyData["degree"]
      
      local pM_M_Coordinate = me.assignWidget(self,"m_m_cell_coordinate")
      pM_M_Coordinate:setString("("..pData["x"]..","..pData["y"]..")")
      if pMyDegree == 4 then
         pM_M_Coordinate:setVisible(false)
      else
         pM_M_Coordinate:setVisible(true)
      end
   -- 任命按钮
     me.registGuiClickEventByName(self,"m_m_cell_appoint_button",function(node)

     end)
     if me.toNum(pUid) == me.toNum(pData.uid) then
        me.assignWidget(self,"Image_mine"):setVisible(true)
        pOfflineTime:setString("在线")
     else
        me.assignWidget(self,"Image_mine"):setVisible(false)
        if me.toNum(pData["offlineTime"]) == 0 then
           pOfflineTime:setString("在线")
        else
          pOfflineTime:setString(getTime(me.toNum(pData["offlineTime"])/1000))
        end
        
     end
     --self:setDegree(pData,pUid)
    end  
end
function Lairbmembercell:setApplyData(pData)
      if pData~= nil then
      dump(pData)
    -- 名称
      local pM_M_anme = me.assignWidget(self,"m_m_cell_name")
      pM_M_anme:setString(pData["name"])
    -- 等级
      local pM_M_level = me.assignWidget(self,"m_m_cell_level")
      pM_M_level:setString(pData["level"])
   -- 战斗力
      local pM_M_Fight = me.assignWidget(self,"m_m_cell_fight")
      pM_M_Fight:setString(pData["power"])
   -- 坐标
      local pM_M_Coordinate = me.assignWidget(self,"m_m_cell_coordinate")   

      pM_M_Coordinate:setString( math.floor( cc.pGetDistance(cc.p(pData.x,pData.y),cc.p(user.x,user.y)) ) )

      if pData["inviteStatus"] == 1 then -- 已邀请
          me.assignWidget(self,"m_m_cell_apply"):setVisible(true)
          me.assignWidget(self,"m_m_cell_appoint_button"):setVisible(false)
      else
          me.assignWidget(self,"m_m_cell_apply"):setVisible(false)
          me.assignWidget(self,"m_m_cell_appoint_button"):setVisible(true)
      end
    end  
end 
function Lairbmembercell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function Lairbmembercell:onExit()  
     me.clearTimer(self.pTime)
end

