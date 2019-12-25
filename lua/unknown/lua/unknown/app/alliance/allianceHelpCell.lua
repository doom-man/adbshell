 -- 联盟帮助 Cell
 allianceHelpLeftCell = class("allianceHelpLeftCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
allianceHelpLeftCell.__index = allianceHelpLeftCell
function allianceHelpLeftCell:create(...)
    local layer = allianceHelpLeftCell.new(...)
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
function allianceHelpLeftCell:ctor()  
   
end
function allianceHelpLeftCell:init()   
    return true
end
function allianceHelpLeftCell:setData(pData)
   if pData~= nil then
   dump(pData)
      local pStr = ""
      local pBuidData =cfg[CfgType.BUILDING]
      local pBuidName =""
      if pData["ptype"] == 1 then   
         pStr = "升级"
         pBuidName = pBuidData[pData["defId"]]["name"]
      elseif pData["ptype"] == 2 then  
         pStr = "建设"
         pBuidName = pBuidData[pData["defId"]]["name"]
      elseif pData["ptype"] == 3 then   
        pStr ="恢复"
        pBuidName="伤兵"
      end
        
      me.assignWidget(self, "Text_15"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))
      local pTitle = me.assignWidget(self,"a_h_left_title")
      pTitle:setString("帮助我"..pStr..pBuidName)
      pTitle:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))

      local pHelpLabel = me.assignWidget(self,"a_h_left_num")
      pHelpLabel:setString(pData["helpNumber"].."/"..pData["countHelpNumber"])
      pHelpLabel:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))

      local pLoadingBar = me.assignWidget(self,"LoadingBar_help")
      pLoadingBar:setPercent(pData["helpNumber"]/pData["countHelpNumber"]*100)
   end
end
function allianceHelpLeftCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function allianceHelpLeftCell:onExit()  
end


-- 右的Cell

allianceHelpRightCell = class("allianceHelpRightCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
allianceHelpRightCell.__index = allianceHelpRightCell
function allianceHelpRightCell:create(...)
    local layer = allianceHelpRightCell.new(...)
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
function allianceHelpRightCell:ctor()  
   
end
function allianceHelpRightCell:init()   
    return true
end
function allianceHelpRightCell:setData(pData)
     if pData~= nil then
     dump(pData)
      local pStr = ""
      local pBuidData =cfg[CfgType.BUILDING]
      local pBuidName =""
      if pData["ptype"] == 1 then   
         pStr = "升级"
         pBuidName = pBuidData[pData["defId"]]["name"]
      elseif pData["ptype"] == 2 then  
         pStr = "建设"
         pBuidName = pBuidData[pData["defId"]]["name"]
      elseif pData["ptype"] == 3 then   
        pStr ="恢复"
        pBuidName="伤兵"
      end

      local pName = me.assignWidget(self,"a_h_right_name")
      pName:setString(pData["name"])
      pName:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))
      -- 内容
      local pCenter = me.assignWidget(self,"a_h_right_center")
      pCenter:setString("帮助我"..pStr..pBuidName)
      pCenter:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))
      -- 帮助次数
      local pHelpNum = me.assignWidget(self,"a_h_right_num"):setVisible(false)
      pHelpNum:setString(pData["helpNumber"].."/"..pData["countHelpNumber"])
      pHelpNum:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))
     end
end
function allianceHelpRightCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function allianceHelpRightCell:onExit()  
end
