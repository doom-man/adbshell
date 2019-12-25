-- 联盟帮助
allianceHelpView = class("allianceHelpView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
allianceHelpView.__index = allianceHelpView
function allianceHelpView:create(...)
    local layer = allianceHelpView.new(...)
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
function allianceHelpView:ctor()  
    me.registGuiClickEventByName(self,"Button_cancel",function (node)
            self:close()    
    end)
    self.closeEmpty = false
end
function allianceHelpView:setCloseEmpty()
    self.closeEmpty = true
end
function allianceHelpView:close()
    if self.closeEmpty == false then
        self.allianceview = allianceview:create("alliance/allianceview.csb")                  
          if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity:addChild(self.allianceview, me.MAXZORDER)
            mainCity.allianceExitview = self.allianceview 
         else
            pWorldMap:addChild(self.allianceview, me.MAXZORDER)
            pWorldMap.allianceExitview = self.allianceview 
         end    
         me.showLayer(self.allianceview, "bg_frame")            
    end
    self:removeFromParentAndCleanup(true)
end
function allianceHelpView:init()   
    print("allianceHelpView:init()")
    
   
    self:setData()
    return true
end
function allianceHelpView:setData()
    local pHelpData = user.familyHelpList
    local pHelpBData = user.familyBeHelpList
 --   dump(pHelpData)
--    dump(pHelpBData)
    local pMyUid = user.uid
    local pLeftHelpData = {}
    local pRightHelpData = {}
    for key, var in pairs(pHelpBData) do
       
         table.insert(pLeftHelpData,var)
    end
    for key, var in pairs(pHelpData) do
      table.insert(pRightHelpData,var)
    end
    -- 一键帮助    
    me.registGuiClickEventByName(self,"a_r_all_help_Button",function (node)   
         if table.maxn(pRightHelpData)~=0 then       
            NetMan:send(_MSG.allHelp())   --  一键帮助     
         end
    end)    
     if table.maxn(pLeftHelpData)~=0 then
        me.assignWidget(self,"alliance_left_node"):removeAllChildren()
        self:initLeftTable(pLeftHelpData)
       else
        me.assignWidget(self,"alliance_left_node"):removeAllChildren()
     end
--     dump(pRightHelpData)
      if table.maxn(pRightHelpData)~=0 then
        me.assignWidget(self,"alliance_right_Node"):removeAllChildren()
        self:initRightTable(pRightHelpData)
     --   dump(pRightHelpData)
       else
         me.assignWidget(self,"alliance_right_Node"):removeAllChildren()
     end
end
--
function allianceHelpView:initLeftTable(pMailFiTab)
    local iNum  = #pMailFiTab
    local pHeight = 0
  
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
      
    end

    local function cellSizeForTable(table, idx)
        return 459, 128 + 5
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
          cell = cc.TableViewCell:new()
          local pAllianceHelpLeftCell = allianceHelpLeftCell:create(self,"a_h_left_cell")
          pAllianceHelpLeftCell:setVisible(true)
          pAllianceHelpLeftCell:setAnchorPoint(cc.p(0.5, 0))
          pAllianceHelpLeftCell:setPosition(cc.p(229.5, 5))    
          pAllianceHelpLeftCell:setData(pMailFiTab[idx+1])      
          cell:addChild(pAllianceHelpLeftCell)                                 
          else
          local pAllianceHelpLeftCell = me.assignWidget(cell,"a_h_left_cell")       
          pAllianceHelpLeftCell:setData(pMailFiTab[idx+1])         
        end  
        return cell
    end

    function numberOfCellsInTableView(table)
        
        return iNum
    end

    tableView = cc.TableView:create(cc.size(459, 580 - 50))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "alliance_left_node"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()     

end

-- 右
function allianceHelpView:initRightTable(pMailFiTab)
    local iNum  =#pMailFiTab
    local pHeight = 0
  
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
      
    end

    local function cellSizeForTable(table, idx)
        return 689, 128 + 5
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        
        local cell = table:dequeueCell()        
        if nil == cell then
           cell = cc.TableViewCell:new()
          local pAllianceHelpRightCell = allianceHelpRightCell:create(self,"a_h_right_cell")
          pAllianceHelpRightCell:setAnchorPoint(cc.p(0.5, 0))
          pAllianceHelpRightCell:setPosition(cc.p(344.5, 5))
          pAllianceHelpRightCell:setVisible(true)   
          pAllianceHelpRightCell:setData(pMailFiTab[idx+1])    
          local pButtonHelp = me.assignWidget(pAllianceHelpRightCell,"a_h_right_help_Button")
          pButtonHelp:setTag(idx+1)
           me.registGuiClickEvent(pButtonHelp,function (node)
                local pIdx = node:getTag()
              --  print("")
                NetMan:send(_MSG.setHelp(pMailFiTab[pIdx]["uid"],pMailFiTab[pIdx]["roleUid"]))   --  帮助
              --  me.tableClear(user.familyHelpList)   -- 联盟数据置空
           end)
          pButtonHelp:setSwallowTouches(false)                
          cell:addChild(pAllianceHelpRightCell)                                 
          else
          local pAllianceHelpRightCell = me.assignWidget(cell,"a_h_right_cell")
          pAllianceHelpRightCell:setData(pMailFiTab[idx+1])   
          local pButtonHelp = me.assignWidget(pAllianceHelpRightCell,"a_h_right_help_Button")
          pButtonHelp:setTag(idx+1)
        end  
        return cell
    end

    function numberOfCellsInTableView(table)
        
        return iNum
    end

    tableView = cc.TableView:create(cc.size(689, 580 - 50 - 105))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self,"alliance_right_Node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()     

 --   self.pTableFight = tableView
end
function allianceHelpView:update(msg)
    if checkMsg(msg.t, MsgCode.FAMILY_HELP_LIST) then            -- 联盟帮助
       self:setData()
    elseif checkMsg(msg.t, MsgCode.FAMILY_HELP_ALL) then         -- 一键帮助
       self:setData()
    elseif checkMsg(msg.t, MsgCode.BULID_HELP_REMOVE) then
       self:removeHelpData()
       self:setData()
       --self.pTableFight:reloadData() 
    end
end
function allianceHelpView:removeHelpData()
    me.tableClear(pRigh)
    for key, var in pairs(user.bulidId) do
      local pHelp = user.familyHelpList[key]
     if pHelp ~= nil then
         user.familyHelpList[key] = nil          
       end
     end    
     if mainCity and mainCity.buildingMoudles and table.nums(user.familyHelpList) == 0 then
         local cBuildMoudle = mainCity.buildingMoudles[user.centerBuild.index]
         if cBuildMoudle then
            cBuildMoudle:hideHelpBtn()
         end 
      end      
end

function allianceHelpView:onEnter()   
    print("allianceHelpView:onEnter()")
	me.doLayout(self,me.winSize)  
     self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
end
function allianceHelpView:onExit()  
    print("allianceHelpView:onExit()")
   UserModel:removeLisener(self.modelkey) -- 删除消息通知
end

