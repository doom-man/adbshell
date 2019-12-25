--[Comment]
--jnmo
strongholdlist = class("strongholdlist",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
strongholdlist.__index = strongholdlist
function strongholdlist:create(...)
    local layer = strongholdlist.new(...)
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
strongholdlist.STONGHOLD = 1 -- 据点
strongholdlist.CITY = 2 -- 主城
function strongholdlist:ctor()   
    print("strongholdlist ctor") 
    self.ori = cc.p(0,0)
    self.tag = cc.p(0,0)
    self.mArmy = nil
    self.mStrongHoldData = nil --据点
    self.mStrongHoldData_other = nil --另一个据点(出发点)
    self.mStrongholdType = 0
    self.mMaxArmy = 0
    self.TeamId = 0
    self.mbossType = 0
end
function strongholdlist:init()   
    print("strongholdlist init")
    self.Next_bg = me.assignWidget(self,"Next_bg"):setVisible(false)
    self.Button_mobilize = me.assignWidget(self,"Button_mobilize"):setVisible(false)
    self.ArmyBool = false
    --  me.assignWidget(self,"fixLayout"):setSwallowTouches(true)
      me.registGuiTouchEventByName(self, "fixLayout", function(node, event)             
        if event == ccui.TouchEventType.began then
            node:setSwallowTouches(true)
            local Right_bg = false
            local pNext_bg = false 
            local pTouch = node:getTouchBeganPosition()
            local pNode = me.assignWidget(self,"Right_bg")
            Right_bg = self:contains(pNode,pTouch.x,pTouch.y)                  
            if self.ArmyBool then
               local pNode = me.assignWidget(self,"Next_bg")
               pNext_bg = self:contains(pNode,pTouch.x,pTouch.y)    
            end  
            if self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
                 if Right_bg == false then
                   me.DelayRun(function (args)
                    self:close()    
                   end) 
                 end
            else
                if Right_bg == false and pNext_bg == false then
                 self:close()              
               end   
            end   
        elseif event == ccui.TouchEventType.moved then
          
        elseif event == ccui.TouchEventType.ended then
              Right_bg = false
              pNext_bg = false 
              
        elseif event == ccui.TouchEventType.canceled then
            
        end
    end )
    
    me.registGuiClickEvent(self.Button_mobilize,function (node)         
        if self.mType == EXPED_STATE_MOBILIZE then
            pWorldMap:showMobilize(self.ori,self.tag, self.mType,self.mArmy,self.mStrongHoldData,self.mStrongholdType,self.mStrongHoldData_other)
        elseif self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
            ConvergeExped(self.ori,self.tag,self.mArmy,self.mMaxArmy,self.mType, 0, self.TeamId,self.surplusTime,self.conergeType )
        else
            pWorldMap:setWorldArmy(self.mArmy,self.mStrongholdType,self.mbossType)
            GMan():send(_MSG.worldMapPath(self.ori.x,self.ori.y,self.tag.x, self.tag.y, self.mType))           
        end
         self:close()
    end)        
    return true
end
function strongholdlist:setButtonText()
    if self.mType == EXPED_STATE_PILLAGE then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("探 索")
    elseif self.mType == EXPED_STATE_OCC  then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("出 征")
    elseif self.mType == EXPED_STATE_STATION  then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("驻 军")
    elseif self.mType == EXPED_STATE_ARCH  then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("考 古")
    elseif self.mType == EXPED_STATE_MOBILIZE  then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("调 动")
    elseif self.mType == STRONG_ARMY_RETURN  then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("撤 回")
    elseif self.mType == TEAM_ARMY_JOIN or self.mType == THRONE_TEAM_JOIN then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("选择出发点")
    elseif self.mType == TEAM_ARMY_DEFENS then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("选择出发点")
    elseif self.mType == BOSS_OCCUPATION then
        me.assignWidget(self.Button_mobilize, "text_title_btn"):setString("试 炼")
    end   
end
-- 判断是否点击在节点中
function strongholdlist:contains(node, x, y)     
        local point = cc.p(x,y)
        local pRect = cc.rect(0,0,node:getContentSize().width,node:getContentSize().height)  
        local locationInNode = node:convertToNodeSpace(point)     -- 世界坐标转换成节点坐标
        return cc.rectContainsPoint(pRect, locationInNode)      
end
function strongholdlist:setConverge(MaxArmy,TeamId,surplusTime, conergeType) 
    self.mMaxArmy = MaxArmy  
    self.TeamId = TeamId
    self.surplusTime = surplusTime
    self.conergeType = conergeType
    me.assignWidget(self,"Right_bg"):setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    if self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
       self.Button_mobilize:setVisible(true)
       self.Button_mobilize:setPosition(cc.p(640,79))
    end
end
function strongholdlist:setCpData(ptag,pType,pData,bossType)
     self.tag = ptag        
     self.mType = pType
     self.mStrongHoldData = pData
     dump(bossType)
     self.mbossType = bossType 
     if self.mType ~= TEAM_ARMY_JOIN and self.mType ~= TEAM_ARMY_DEFENS and self.mType ~= THRONE_TEAM_JOIN then
          pWorldMap:lookMapAt(self.tag.x,self.tag.y, 0)
          me.assignWidget(self,"Panel_converge"):setVisible(false)
     else
          me.assignWidget(self,"Panel_converge"):setVisible(true)          
     end  
     self:StongHoldData()
     self:StongHoldTable()

     for key, var in pairs(self.StongHoldlist) do
        if key ~= 1 then
           local pCityData = self.StongHoldlist[1]
           if me.toNum(pCityData.distance) <me.toNum(var.distance) and pCityData.armyNum ~= 0 then
                self.pTouchTab:setPosition(self:getCellPoint(0,self.mNum))
                self.pTouchTab:setVisible(true)
                if self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
                   self:setConvergeStong(1)
                else
                   self:ArmyData(1)
                end
                return
           else
                 self.pTouchTab:setPosition(self:getCellPoint(key-1,self.mNum))
                 self.pTouchTab:setVisible(true)
                 if self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
                    self:setConvergeStong(key)
                 else
                    self:ArmyData(key)
                 end
                 return
           end
          
        end
     end
     self.pTouchTab:setPosition(self:getCellPoint(0,self.mNum))
     self.pTouchTab:setVisible(true)
     if self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
        self:setConvergeStong(1)
     else
        self:ArmyData(1)
     end     
end
-- 据点列表数据
function strongholdlist:StongHoldData()
     self.StongHoldlist = {}
     for key, var in pairs(gameMap.bastionData) do 
         if self.tag.x ~= var.pos.x or self.tag.y ~= var.pos.y  then
             if var.army ~= nil and table.maxn(var.army) ~= 0 then          
                local pArmyNum = var:getArmyNum()
                if pArmyNum > 0  then
                   local pStongHold = self:GetStongHold(var.id,var.pos.x,var.pos.y,var.name,pArmyNum,strongholdlist.STONGHOLD)  
                   table.insert(self.StongHoldlist,1,pStongHold)    
                end                       
             end
         else
             if self.mType == EXPED_STATE_STATION  then
                if var.army ~= nil and table.maxn(var.army) ~= 0 then          
                    local pArmyNum = var:getArmyNum()
                    if pArmyNum > 0  then
                        local pStongHold = self:GetStongHold(var.id,var.pos.x,var.pos.y,var.name,pArmyNum,strongholdlist.STONGHOLD)  
                        table.insert(self.StongHoldlist,1,pStongHold)    
                    end                       
                end
             else
              --  self.mStrongHoldData = var -- 调兵到据点的数据
             end
             
         end           
     end   
      function HoldDistance(pa,pb)
         if me.toNum(pa.distance) < me.toNum(pb.distance) then
            return true
         end
      end
      table.sort(self.StongHoldlist,HoldDistance)
      local armyNum = 0
      for key, var in pairs(user.soldierData) do 
            if var:getDef().bigType ~= 99 then     
              armyNum = armyNum + var.num 
            end
      end 
    
      local pStongHold = self:GetStongHold(0,user.x,user.y,user.name,armyNum,strongholdlist.CITY)
      table.insert(self.StongHoldlist,1,pStongHold)

end
function strongholdlist:GetStongHold(strongHoldId,x,y,name,armyNum,pType)
     local pStongHold = {}
     local pX = math.abs(x-self.tag.x)
     local pY = math.abs(y-self.tag.y)
     pStongHold.strongHoldId = strongHoldId 
     pStongHold.distance = string.format("%.1f", cc.pGetDistance(cc.p(x,y),cc.p(self.tag.x,self.tag.y)))
     pStongHold.pType = pType
     pStongHold.name = name
     pStongHold.ori = cc.p(x,y)
     pStongHold.armyNum = armyNum
     return pStongHold
end
function strongholdlist:setConvergeStong(pTag)
    local pStrongHold = self.StongHoldlist[pTag]
    if pStrongHold.pType == strongholdlist.CITY then
       self.mArmy = user.soldierData
    else
       local pStrongHoldData = gameMap.bastionData[pStrongHold.strongHoldId] 
       self.mArmy = pStrongHoldData:getarmydata()      
    end
    self.ori = pStrongHold.ori
    self:setButtonText()
end
function strongholdlist:ArmyData(pTag)
    self.Next_bg = me.assignWidget(self,"Next_bg"):setVisible(true)
    self.Button_mobilize = me.assignWidget(self,"Button_mobilize"):setVisible(true)
    self.ArmyBool = true
    self:setButtonText()
    me.assignWidget(self, "Next_Node"):removeAllChildren()
    local pStrongHold = self.StongHoldlist[pTag]    
    local pNot_Army = me.assignWidget(self,"not_army")
    pNot_Army:setVisible(false)

    self.ori = pStrongHold.ori   
    local Paths_ = {}
    Paths_.ori = self.ori
    Paths_.tag = self.tag
    if self.path == nil then
       self.path = expedPath:create(Paths_,1,true)
    else
       self.path:purge()
       self.path = expedPath:create(Paths_,1,true)
    end
    if pStrongHold.pType == strongholdlist.CITY then
        self.mStrongHoldData_other= nil
        self.mStrongholdType = strongholdlist.CITY
        local sData = {}
        for key, var in pairs(user.soldierData) do 
            if var:getDef().bigType ~= 99 then     
              table.insert(sData,var)
            end
        end
        self.mArmy = user.soldierData
        if table.maxn(sData) ~= 0 then
           self:ArmyTable(sData)
        else
           pNot_Army:setVisible(true)
        end      
    else     
        self.mStrongholdType = strongholdlist.STONGHOLD  
        local pStrongHoldData = gameMap.bastionData[pStrongHold.strongHoldId] 
        local pArmy = pStrongHoldData:getarmydata()      
        local sData = {}
        for key, var in pairs(pArmy) do
            var:getDef()
            table.insert(sData,var)
        end
        self.mArmy = pArmy
        self.mStrongHoldData_other = pStrongHoldData
        self:ArmyTable(sData)          
    end
    local pStrong_name = me.assignWidget(self,"Strong_name")
    pStrong_name:setString(pStrongHold.name)

    local pDistance = me.assignWidget(self,"strong_distance")
    pDistance:setString(pStrongHold.distance)

    local pArmyNum = me.assignWidget(self,"Army_num")
    pArmyNum:setString(pStrongHold.armyNum)
end
function strongholdlist:lookTroops(msg)
      me.assignWidget(self,"Panel_converge"):setVisible(false)
      me.assignWidget(self,"Right_bg"):setVisible(false)
      me.assignWidget(self,"Next_bg"):setVisible(true)
      me.assignWidget(self,"Strong_name"):setString("部队")
      me.assignWidget(self,"Text_40"):setVisible(false)
      self.ArmyBool = true
      local pArmy = {}
      local ArmyNum = 0
      for key, var in pairs(msg.c.army) do
           local soldierData = soldierData.new(var[1], var[2]) 
           soldierData:getDef()           
           table.insert(pArmy,soldierData)
            ArmyNum = ArmyNum + var[2]
      end  
      me.assignWidget(self,"Army_num"):setString(ArmyNum)
      self:ArmyTable(pArmy)  
      
end
-- 据点
function strongholdlist:StongHoldTable()
    
    local iNum = #self.StongHoldlist
    self.mNum = iNum
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pTag = cell:getIdx()
        self.pTouchTab:setPosition(self:getCellPoint(pTag,iNum))
        self.pTouchTab:setVisible(true)
        if self.mType == TEAM_ARMY_JOIN or self.mType == TEAM_ARMY_DEFENS or self.mType == THRONE_TEAM_JOIN then
           self:setConvergeStong(pTag+1)
        else
           self:ArmyData(pTag+1)
        end
    end

    local function cellSizeForTable(table, idx)
        return 297, 110
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pStongholdCell = stongholdCell:create(self, "Right_stor_cell")
            pStongholdCell:setAnchorPoint(cc.p(0.5, 0.5))
            pStongholdCell:setPosition(cc.p(297 / 2, 110 / 2))   
            pStongholdCell:setData(self.StongHoldlist[idx+1])                  
            cell:addChild(pStongholdCell)
        else
            local pStongholdCell = me.assignWidget(cell,"Right_stor_cell")
            pStongholdCell:setData(self.StongHoldlist[idx+1])             
        end
        return cell
    end

    function numberOfCellsInTableView(table)

        return iNum
    end

    tableView = cc.TableView:create(cc.size(297, 285))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 10))
    tableView:setDelegate()
    me.assignWidget(self, "Right_stor_cell_Node"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    self.pTouchTab = ccui.ImageView:create("beibao_xuanzhong_guang.png",me.plistType)
    self.pTouchTab:setContentSize(cc.size(297, 120))
    self.pTouchTab:setScale9Enabled(true)
    self.pTouchTab:setCapInsets(cc.rect(20, 20, 1, 1))
    self.pTouchTab:setPosition(self:getCellPoint(0, iNum))
    self.pTouchTab:setLocalZOrder(10)
    self.pTouchTab:setVisible(false)
    tableView:addChild(self.pTouchTab)
end
function strongholdlist:getCellPoint(pTag,iNum) 
    local pPointX = 297 / 2
    local pPointY = (iNum - pTag) * 110 - 55
    return pPointX,pPointY
end
-- 军队
function strongholdlist:ArmyTable(ArmyData)
    
    local iNum = #ArmyData
  
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        
    end

    local function cellSizeForTable(table, idx)
        return 193, 228
    end

    local function tableCellAtIndex(table, idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pstongholdArmyCell = stongholdArmyCell:create(self, "ArmyCell")
            pstongholdArmyCell:setAnchorPoint(cc.p(0, 0))
            pstongholdArmyCell:setPosition(cc.p(0, 0))   
            pstongholdArmyCell:setData(ArmyData[idx+1])                  
            cell:addChild(pstongholdArmyCell)
        else
            local pstongholdArmyCell = me.assignWidget(cell,"ArmyCell")
            pstongholdArmyCell:setData(ArmyData[idx+1])             
        end
        return cell
    end

    function numberOfCellsInTableView(table)

        return iNum
    end

    tableView = cc.TableView:create(cc.size(830, 228))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(100, 15))
    tableView:setDelegate()
    me.assignWidget(self, "Next_Node"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
   
end

function strongholdlist:onEnter()
    print("strongholdlist onEnter") 
	me.doLayout(me.assignWidget(self,"fixLayout"),me.winSize)  
end
function strongholdlist:onEnterTransitionDidFinish()
	print("strongholdlist onEnterTransitionDidFinish") 
end
function strongholdlist:onExit()
    print("strongholdlist onExit")    
end
function strongholdlist:close()
    if self.path then
        self.path:purge()
    end
    self:removeFromParentAndCleanup(true)  
end
 
