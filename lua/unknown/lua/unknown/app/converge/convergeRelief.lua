--[Comment]
--jnmo
convergeRelief = class("convergeRelief",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
convergeRelief.__index = convergeRelief
function convergeRelief:create(...)
    local layer = convergeRelief.new(...)
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
convergeRelief.TABLEHEIGHT = 165 + 5
function convergeRelief:ctor()   
    print("convergeRelief ctor") 
    self.pTime = nil
end
function convergeRelief:init()   
    print("convergeRelief init")
	   
    me.registGuiClickEventByName(self,"Button_help_recold",function (node)                   
            GMan():send(_MSG.worldTeamDefensHistory())
    end)
    

    return true
end
function convergeRelief:setHaveAid()
    if user.CityteamArmysoliderNum > 0 then
      me.assignWidget(self,"converge_hint"):setVisible(false)
      me.assignWidget(self,"Panel_7"):setVisible(true)
      me.assignWidget(self,"relief_army_num"):setVisible(true)

      local pArmyNunlabel = me.assignWidget(self,"relief_army_num")
      pArmyNunlabel:setString("援军数量："..user.CityteamArmysoliderNum.."/"..user.CityteamArmyMaxSoliderNum)
      me.clearTimer(self.pTime)
      self.TableHeight = {}
      self.LaunchTab = {}     
      self.mArmyData = {}
      local pAddBool = true
      local pOpenBool = true
      self.pPeopleNum = 0
      dump(user.teamCityArmyInfoData)
      for key, var in pairs(user.teamCityArmyInfoData) do
          local pArmyNum = math.ceil((#var.army)/3)
          if var.shipId ~= 0 then
             pArmyNum = pArmyNum + 1
          end
          local pHeight = 80 + pArmyNum*105      
          table.insert(self.TableHeight,pHeight)
          table.insert(self.mArmyData,var)
          table.insert(self.LaunchTab,1)
          self.pPeopleNum = self.pPeopleNum +1
      end
      if table.maxn(self.mArmyData) ~= 0 then
         self.pTime = me.registTimer(-1,function(dt)
            for key, var in pairs(self.mArmyData) do             
                 if var.counttime > 0 then
                      var.counttime = var.counttime - 1
                 end                    
             end
         end,1)
      end

      self:initInfoTab()
    else
        me.assignWidget(self,"Panel_7"):setVisible(false)
        me.assignWidget(self,"relief_army_num"):setVisible(false)
        me.assignWidget(self,"converge_hint"):setVisible(true)
    end
end
function convergeRelief:initInfoTab()  
    self.tableView = nil
    local pNum = #self.mArmyData
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
      --[[
                local pIndex = cell:getIdx() + 1
                local pLaunch = self.LaunchTab[pIndex]
                local pOffset = self.tableView:getContentOffset()
                local pOffsetNew = cc.p(0,0)
                if pLaunch == 1 then
                    for var = 1 ,self.pPeopleNum do
                       self.LaunchTab[var] = 1
                    end  
                    self.LaunchTab[pIndex] = 2
                    local pOffsetY =(-pNum+(pIndex-1))*convergeRelief.TABLEHEIGHT + 364 - self.TableHeight[pIndex]
                    if pNum*convergeRelief.TABLEHEIGHT + self.TableHeight[pIndex] < 364 then
                       pOffsetY = 364 - (pNum*convergeRelief.TABLEHEIGHT + self.TableHeight[pIndex])
                    else
                       pOffsetY = math.min(pOffsetY,0)
                    end
                    
                    pOffsetNew = cc.p(0,pOffsetY)
                else
                   self.LaunchTab[pIndex] = 1
                   if pNum*convergeRelief.TABLEHEIGHT < 364 then
                      pOffsetNew = cc.p(0,(364 - pNum*convergeRelief.TABLEHEIGHT))
                   else
                      pOffsetNew = cc.p(0,math.min(0,pOffset.y + self.TableHeight[pIndex])) 
                   end                  
                end 
                self.tableView:reloadData()
                self.tableView:setContentOffset(pOffsetNew)
        --]]
        local idx = cell:getIdx() + 1
        local tempHeight = self.TableHeight[idx]
        if self.LaunchTab[idx] == 1 then
          self.LaunchTab[idx] = 2
          local offset = self.tableView:getContentOffset()
          self.tableView:reloadData()
          self.tableView:setContentOffset(cc.p(offset.x, offset.y - tempHeight))
        else
          self.LaunchTab[idx] = 1
          local offset = self.tableView:getContentOffset()
          self.tableView:reloadData()
          self.tableView:setContentOffset(cc.p(offset.x, offset.y + tempHeight))
        end
    end

    local function cellSizeForTable(table, idx)  
        local pLaunch = self.LaunchTab[idx+1] 
        local pX = convergeRelief.TABLEHEIGHT
        if pLaunch == 2 then
            pX = pX + self.TableHeight[idx+1] 
        end                 
        return 1140, pX
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)        
        local cell = table:dequeueCell()        
        if nil == cell then
          cell = cc.TableViewCell:new()
          local pconvergeReliefCell = convergeReliefCell:create(self,"con_relief_cell")
          local pLaunch = self.LaunchTab[idx+1]
          local pHeight = convergeRelief.TABLEHEIGHT
          local pArmyHeight = 0
          if pLaunch == 2  then
             pArmyHeight = self.TableHeight[idx+1] 
             pHeight = pHeight + self.TableHeight[idx+1] 
          end
          pconvergeReliefCell:setDate(self.mArmyData[idx+1],pArmyHeight)
          pconvergeReliefCell:setPosition(cc.p(0, pHeight))
          pconvergeReliefCell:setAnchorPoint(cc.p(0, 1))
          local pLaunchButton = me.assignWidget(pconvergeReliefCell,"Button_army_info")
          pLaunchButton:setTag(idx+1)
          me.registGuiClickEvent(pLaunchButton,function (node)
                local pIndex = node:getTag()
                print("pIndex"..pIndex) 
--                local pLaunch = self.LaunchTab[pIndex]
--                local pOffset = self.tableView:getContentOffset()
--                local pOffsetNew = cc.p(0,0)
--                if pLaunch == 1 then
--                    for var = 1 ,self.pPeopleNum do
--                       self.LaunchTab[var] = 1
--                    end  
--                   self.LaunchTab[pIndex] = 2
--                    local pOffsetY =(-pNum+(pIndex-1))*convergeRelief.TABLEHEIGHT + 364 - self.TableHeight[pIndex]
--                    if pNum*convergeRelief.TABLEHEIGHT + self.TableHeight[pIndex] < 364 then
--                       pOffsetY = 364 - (pNum*convergeRelief.TABLEHEIGHT + self.TableHeight[pIndex])
--                    else
--                       pOffsetY = math.min(pOffsetY,0)
--                    end

--                    pOffsetNew = cc.p(0,pOffsetY)
--                else
--                   self.LaunchTab[pIndex] = 1
--                   if pNum*convergeRelief.TABLEHEIGHT < 364 then
--                      pOffsetNew = cc.p(0,(364 - pNum*convergeRelief.TABLEHEIGHT))
--                   else
--                      pOffsetNew = cc.p(0,math.min(0,pOffset.y + self.TableHeight[pIndex])) 
--                   end                  
--                end 
--                self.tableView:reloadData()
--                self.tableView:setContentOffset(pOffsetNew)
          end)
          pLaunchButton:setSwallowTouches(true)
          pLaunchButton:setTouchEnabled(false)
          cell:addChild(pconvergeReliefCell)
        else
          local pconvergeReliefCell = me.assignWidget(cell,"con_relief_cell")
          local pLaunch = self.LaunchTab[idx+1]
          local pHeight = convergeRelief.TABLEHEIGHT
          local pArmyHeight = 0
          if pLaunch == 2  then
             pArmyHeight = self.TableHeight[idx+1] 
             pHeight = pHeight + self.TableHeight[idx+1] 
          end
          pconvergeReliefCell:setDate(self.mArmyData[idx+1],pArmyHeight)
          pconvergeReliefCell:setPosition(cc.p(0,pHeight))
          pconvergeReliefCell:setAnchorPoint(cc.p(0,1))
          local pLaunchButton = me.assignWidget(pconvergeReliefCell,"Button_army_info")
          pLaunchButton:setTag(idx+1)
--          me.registGuiClickEvent(pLaunchButton,function (node)
--                self.tableView:reloadData()  
--                local pOffset = self.tableView:getContentOffset()
--                self.tableView:setContentOffset(pOffset)
--          end)
        end  
        return cell
    end
    function numberOfCellsInTableView(table)       
        return pNum
    end

    tableView = cc.TableView:create(cc.size(1140, 460))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self,"Node_5"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()     
    self.tableView = tableView
end
function convergeRelief:update(msg)
       if checkMsg(msg.t, MsgCode.WORLD_TEAM_REJECT_ARMY) then
          GMan():send(_MSG.worldTeamCityArmy())
       elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CITY_ARMY_WAIT) then             
          GMan():send(_MSG.worldTeamCityArmy())
       elseif checkMsg(msg.t, MsgCode.ROLE_DEFENS_HISTORY) then             
          local RepatriateRecord = RepatriateRecord:create("convergeReliefRecord.csb")                   
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
               pWorldMap:addChild(RepatriateRecord,me.MAXZORDER)
            else
               mainCity:addChild(RepatriateRecord,me.MAXZORDER)
            end                     
       end
end
function convergeRelief:onEnter()
    print("convergeRelief onEnter") 
	--me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function convergeRelief:onEnterTransitionDidFinish()
	print("convergeRelief onEnterTransitionDidFinish") 
end
function convergeRelief:onExit()
    print("convergeRelief onExit")   
    UserModel:removeLisener(self.modelkey) 
    me.clearTimer(self.pTime)
end
function convergeRelief:close()
    self:removeFromParentAndCleanup(true)  
end


