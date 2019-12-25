-- 侦查
mailInvestInfor = class("mailInvestInfor",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
mailInvestInfor.__index = mailInvestInfor
function mailInvestInfor:create(...)
    local layer = mailInvestInfor.new(...)
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
function mailInvestInfor:ctor()  
    me.registGuiClickEventByName(self,"Button_cancel",function (node)
             self:close()    
    end)  
end
function mailInvestInfor:close()
      self:removeFromParentAndCleanup(true)
end
function mailInvestInfor:init()   
   
 --   self:setUI()
    return true
end
function mailInvestInfor:setData(pData)
   dump(me.cjson.decode(pData["content"][1]))
end
function mailInvestInfor:setUI(pData)
    
    local pSpyData = pData["content"]
    
   -- dump(pSpyData)
    local pName = me.assignWidget(self,"m_inves_Rival_name")  -- 名字
    pName:setString(pSpyData["defender"])

    local pPoint = me.assignWidget(self,"m_inves_Rival_point") -- 坐标
    pPoint:setString("("..pSpyData["x"]..","..pSpyData["y"]..")")
    pPoint:setPosition(cc.p(pName:getPositionX()+pName:getContentSize().width/2+5,pPoint:getPositionY()))
 --  dump(pData)
    if pData.npc ~= nil and pData.npc == false then
       me.assignWidget(self,"mail_arch_hint"):setVisible(false)
    else
       me.assignWidget(self,"mail_arch_hint"):setVisible(true)
    end
    local pTatolNum = 0
    local pWidth = me.assignWidget(self,"m_i_resoure_bg"):getContentSize().width  -- 宽度
    -- 计算高度
    -- 资源高度 
    local pResoureNum = 0
    if pData.item ~= nil then
       pResoureNum = #pData["item"]
    end
    local pResoureH = me.assignWidget(self,"m_i_resoure_bg"):getContentSize().height + pResoureNum*61
    if pResoureNum ==0  then
         pResoureH = 0
         else
         pTatolNum = pTatolNum + 1
    end
    -- 城防高度
    local pDefenceNum = 0
    if pData.trap ~= nil then       
        if pData["trap"].num == nil then
            pDefenceNum = #pData["trap"]
        else
           pDefenceNum = 1
        end
    end    
    local pDefenceH = me.assignWidget(self,"m_i_defence_bg"):getContentSize().height + pDefenceNum*61
    if pDefenceNum ==0  then
         pDefenceH = 0
         else
         pTatolNum = pTatolNum + 1
    end

    -- 防御部队的高度
    local pForceNum = 0
    if pData.army ~= nil then    
        if pData["army"].num == nil then
           pForceNum = #pData["army"] 
        else
           pForceNum = 1
        end
    end
    local pForeceH = me.assignWidget(self,"m_i_force_bg"):getContentSize().height + pForceNum*61
    if pForceNum ==0  then
        else
         pTatolNum = pTatolNum + 1
    end
    
    -- 箭塔
    local pTower = 0
    if pData.tower ~= nil then
       pTower = #pData["tower"]
    end
    local pArrowH = 0
    
    if pTower ~= 0 then
       pArrowH = me.assignWidget(self,"m_i_arrow_bg"):getContentSize().height+20
    end
    
   
    -- 军事
    local pMilitaryNum = 0
    if pData.property ~= nil then
       
       for key, var in pairs(pData["property"]) do
           local pPData = cfg[CfgType.LORD_INFO][var[1]]
           if pPData then       
            pMilitaryNum = pMilitaryNum +1
           end
       end           
    end
    local pMailitaryHeight = 0
    local pMilitaryH = me.assignWidget(self,"m_i_military_bg"):getContentSize().height +pMilitaryNum*61
    if pMilitaryNum ==0  then
         else
         pTatolNum = pTatolNum + 1
    end
    local pMiddle = 5
    -- 总高度
    local pHeightTotal = pResoureH + pDefenceH + pForeceH + pArrowH + pMilitaryH + pMiddle*(pTatolNum)+pMailitaryHeight
    if pHeightTotal < 515 then
     pHeightTotal = 515        
    end
    
    --pHeightTotal = 480

    local pScrollView = cc.ScrollView:create()    
    pScrollView:setViewSize(cc.size(pWidth,535))
    pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pScrollView:setLocalZOrder(10)
    pScrollView:setAnchorPoint(cc.p(0,0))
    pScrollView:setPosition(cc.p(0,0))
    pScrollView:setContentSize(cc.size(pWidth,pHeightTotal))
    pScrollView:setContentOffset(cc.p(0,(-(pHeightTotal-535))))
    me.assignWidget(self,"border"):addChild(pScrollView)
    
    local pNode = cc.Node:create()
    pNode:setContentSize(cc.size(pWidth,pHeightTotal))
    pNode:setAnchorPoint(cc.p(0,0))
    pNode:setPosition(cc.p(0,0))
    pScrollView:addChild(pNode)

--    local pLayer = cc.LayerColor:create(cc.c3b(223,123,88))
--    pLayer:setContentSize(cc.size(pWidth,pHeightTotal))
--    pLayer:setAnchorPoint(cc.p(0,0))
--    pLayer:setPosition(cc.p(0,0))
--    pNode:addChild(pLayer)
     pHeightTotal = pHeightTotal -5
    if pResoureNum >0 then
         self:setResoure(pScrollView,pResoureH,(pHeightTotal),pData["item"])
         pHeightTotal = pHeightTotal - pResoureH -pMiddle
    end
    if pDefenceNum >0 then
        self:setDefence(pScrollView,pDefenceH,pHeightTotal,pData["trap"])
        pHeightTotal = pHeightTotal - pDefenceH - pMiddle
    end
    if pForceNum >0 then
        --pHeightTotal = pHeightTotal -10
         self:setForce(pScrollView,pForeceH,pHeightTotal,pData["army"])
         pHeightTotal = pHeightTotal - pForeceH - pMiddle
    end   
    if pTower ~= 0 then
         pHeightTotal = pHeightTotal
         self:setArrow(pScrollView,pArrowH,pHeightTotal,pData["tower"])
         pHeightTotal = pHeightTotal - pArrowH - pMiddle
    end
  
    if pMilitaryNum >0 then
       self:setMilitary(pScrollView,pMilitaryH,pHeightTotal,pData["property"])
    end
    
end
-- 资源
function mailInvestInfor:setResoure(pNode,pResoureH,pHeightTotal,pData)
    local pWidth = me.assignWidget(self,"m_i_resoure_bg"):getContentSize().width
    
    local pResNode = me.assignWidget(self,"m_i_resoure_Node"):clone():setVisible(true)
    pResNode:setAnchorPoint(cc.p(0,0))
    pResNode:setPosition(cc.p(0,pHeightTotal+5))
    pNode:addChild(pResNode)

    for var = 1 , #pData do
         local pCellNode = me.assignWidget(self,"m_i_resoure_cell_wire"):clone():setVisible(true) 
         pCellNode:setPosition(cc.p(pCellNode:getPositionX(),-(40+(var-1)*61)))
         pResNode:addChild(pCellNode)
         me.assignWidget(pCellNode, "cellBg"):setVisible(var%2~=0)

         local pCfgData = cfg[CfgType.ETC][pData[var][1]]
        
      --   dump(pCfgData)     
         local pIcon = me.assignWidget(pCellNode,"m_i_resoure_cell_icon")          -- 图标
         pIcon:loadTexture("item_"..pCfgData["icon"]..".png",me.plistType)

         local pNameLabel = me.assignWidget(pCellNode,"m_i_resoure_cell_name")
         pNameLabel:setString(pCfgData["name"])

         local pNumLabel = me.assignWidget(pCellNode,"m_i_resoure_cell_num")
         pNumLabel:setString(pData[var][2])
    end
end
-- 城防
function mailInvestInfor:setDefence(pNode,pDefenceH,pHeightTotal,pData)
     local pWidth = me.assignWidget(self,"m_i_defence_bg"):getContentSize().width
     local pDefNode = me.assignWidget(self,"m_i_defence_Node"):clone():setVisible(true)
     pDefNode:setAnchorPoint(cc.p(0,0))
     pDefNode:setPosition(cc.p(0,pHeightTotal))
     pNode:addChild(pDefNode)

    if pData.num == nil then    
       for var= 1,#pData do
          local pCellNode = me.assignWidget(self,"m_i_defence_cell_wire"):clone():setVisible(true)
          pCellNode:setPosition(cc.p(pCellNode:getPositionX(),-(40+(var-1)*61)))
          pDefNode:addChild(pCellNode)

          me.assignWidget(pCellNode, "cellBg"):setVisible(var%2~=0)

          local pCfgData = cfg[CfgType.CFG_SOLDIER][pData[var][1]]
          local pIcon = me.assignWidget(pCellNode,"m_i_defence_cell_icon")          -- 图标
          pIcon:loadTexture(pCfgData["icon"]..".png",me.plistType)

          local pNameLabel = me.assignWidget(pCellNode,"m_i_defence_cell_name")
          pNameLabel:setString(pCfgData["name"])

          local pNumLabel = me.assignWidget(pCellNode,"m_i_defence_cell_num")
          pNumLabel:setString(pData[var][2])
      end 
    else
          local pCellNode = me.assignWidget(self,"m_i_defence_cell_wire"):clone():setVisible(true)
          pCellNode:setPosition(cc.p(pCellNode:getPositionX(),-40))
          pDefNode:addChild(pCellNode)
       
          me.assignWidget(pCellNode,"m_i_defence_cell_icon"):setVisible(false)          -- 图标
        

          local pNameLabel = me.assignWidget(pCellNode,"m_i_defence_cell_name")
          pNameLabel:setString("未知")

          local pNumLabel = me.assignWidget(pCellNode,"m_i_defence_cell_num")
          pNumLabel:setString(pData.num)
    end   
end
-- 防御部队
function mailInvestInfor:setForce(pNode,pForeceH,pHeightTotal,pData)
   --  dump(pData)
    local pWidth = me.assignWidget(self,"m_i_force_bg"):getContentSize().width

    local pForNode = me.assignWidget(self,"m_i_force_Node"):clone():setVisible(true)
    pForNode:setAnchorPoint(cc.p(0,0))
    pForNode:setPosition(cc.p(0,pHeightTotal))
    pNode:addChild(pForNode)

    local pBg = me.assignWidget(pForNode,"m_i_force_bg"):setContentSize(cc.size(pWidth,pForeceH))
    pBg:setPosition(cc.p(0,0))
    if pData.num == nil then
       for var = 1 ,#pData  do
          local pCellNode = me.assignWidget(self,"m_i_force_cell_wire"):clone():setVisible(true)
           pCellNode:setPosition(cc.p(pCellNode:getPositionX(),-(40+(var-1)*61)))
           pForNode:addChild(pCellNode)

           me.assignWidget(pCellNode, "cellBg"):setVisible(var%2~=0)

          local pCfgData = cfg[CfgType.CFG_SOLDIER][pData[var][1]]
          local pIcon = me.assignWidget(pCellNode,"m_i_force_cell_icon")          -- 图标
          pIcon:loadTexture(pCfgData["icon"]..".png",me.plistType)          

          local pNameLabel = me.assignWidget(pCellNode,"m_i_force_cell_name")
          pNameLabel:setString(pCfgData["name"])

          local pNumLabel = me.assignWidget(pCellNode,"m_i_force_cell_num")
          pNumLabel:setString(pData[var][2])
      end       
    else
          local pCellNode = me.assignWidget(self,"m_i_force_cell_wire"):clone():setVisible(true)
          pCellNode:setPosition(cc.p(pCellNode:getPositionX(),-40))
          pForNode:addChild(pCellNode)

          me.assignWidget(pCellNode,"m_i_force_cell_icon"):setVisible(false)

          local pNameLabel = me.assignWidget(pCellNode,"m_i_force_cell_name")
          pNameLabel:setString("未知")

          local pNumLabel = me.assignWidget(pCellNode,"m_i_force_cell_num")
          pNumLabel:setString(pData.num)
    end
   
end
-- 箭塔
function mailInvestInfor:setArrow(pNode,pArrowH,pHeightTotal,pData)
   dump(pData)
   local pArrNode = me.assignWidget(self,"m_i_arrow_node"):clone():setVisible(true)
   pArrNode:setPosition(cc.p(0,pHeightTotal))
   pNode:addChild(pArrNode)
   if #pData ~= 0 then    
   dump(pData)
   dump(user.countryId)
--   dump(cfg[CfgType.BUILDING])
    -- 箭塔图标
    local pCfgData = cfg[CfgType.BUILDING][pData[1]]

    local pIcon = me.assignWidget(pArrNode,"m_i_arrow_icon")          -- 图标
    pIcon:loadTexture(buildIcon(pCfgData),me.plistType)
    -- 等级
    local pLevelLabel = me.assignWidget(pArrNode,"m_i_arrow_level")
    pLevelLabel:setString(pCfgData.level)
    -- 攻击力
    local pFighting = me.assignWidget(pArrNode,"m_i_arrow_fighting")
    pFighting:setString(pData[2])

        -- 攻击力
    local pFightingNum = me.assignWidget(pArrNode,"m_i_arrow_fight_num")
    pFightingNum:setString(pData[3])
   end
end
-- 军事
function mailInvestInfor:setMilitary(pNode,pMilitaryH,pHeightTotal,pData)
   local pWidth = me.assignWidget(self,"m_i_military_bg"):getContentSize().width

   local pMilNode = me.assignWidget(self,"m_i_military_Node"):clone():setVisible(true)
   pMilNode:setPosition(0,pHeightTotal)
   pNode:addChild(pMilNode)

--   dump(cfg[CfgType.LORD_INFO])   
--   dump(pData)
   local pNumHeight =1
   for key, var in pairs(pData) do
       local pPData = cfg[CfgType.LORD_INFO][var[1]]
        if pPData then              
         local pCellNode = me.assignWidget(self,"m_i_military_cell_Node"):clone():setVisible(true)
         pCellNode:setPosition(cc.p(pCellNode:getPositionX(),-(40+(pNumHeight-1)*61)))
         pMilNode:addChild(pCellNode) 
         
         me.assignWidget(pCellNode, "cellBg"):setVisible(pNumHeight%2~=0)
                   
          -- 名称
         local pName = me.assignWidget(pCellNode,"m_i_military_name")
         pName:setString(pPData["name"])
         local pNumType = ""
         local pNum = 0 
         if me.toNum(pPData["isPercent"]) == 1  then
              pNum = var[2]*100
              pNumType = "%"
         else
             pNum = var[2]
         end
         -- 加成
         local pParcent = me.assignWidget(pCellNode,"m_i_military_num")
         pParcent:setString(pNum..pNumType)
       
         pNumHeight = pNumHeight + 1
       end
   end
   
   
end

function mailInvestInfor:onEnter()   
	me.doLayout(self,me.winSize)  
end
function mailInvestInfor:onExit()  
end

