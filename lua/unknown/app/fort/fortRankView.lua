--[Comment]
--jnmo
fortRankView = class("fortRankView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
fortRankView.__index = fortRankView
function fortRankView:create(...)
    local layer = fortRankView.new(...)
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
function fortRankView:ctor()   
    print("fortRankView ctor") 
end
function fortRankView:init()   
    print("fortRankView init")
	me.registGuiClickEventByName(self,"Button_cancel",function (node)
        self:close()     
    end)    
    local pData = user.fortheroHistoryRankList
    self.mRankList = {}
     
    if pData["heroid"] ~= 0 then
       me.assignWidget(self,"Node_up"):setVisible(true)
      for key, var in pairs(pData["RankList"]) do
        table.insert(self.mRankList,var)
      end
      me.assignWidget(self,"not_exper_rank"):setVisible(#self.mRankList <= 0)
      local pHeroName = me.assignWidget(self,"exper_name")
      pHeroName:setString(pData["heroName"])

      local pTime = me.assignWidget(self,"Rank_time")
      pTime:setString(me.GetSecRankTime(pData["time"]*1000))

      local pHeroConfig = cfg[CfgType.HERO][pData["heroid"]]
      
      local pKillNum = me.assignWidget(self,"kill_num")
      pKillNum:setString(pData["killNum"].."/"..pHeroConfig["bossnum"])

      self:initExperTab()
    else
       me.assignWidget(self,"Node_up"):setVisible(false)
       me.assignWidget(self,"not_exper_rank"):setVisible(true)
    end

    return true
end
function fortRankView:initExperTab()  
    local pNum = #self.mRankList
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
     
    end
    local function cellSizeForTable(table, idx)     
        return 1167, 60
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pExperCell = me.assignWidget(self,"rank_cell"):clone():setVisible(true)
            self:setExper(pExperCell,self.mRankList[idx+1])
            pExperCell:setPosition(cc.p(0, 0))
            cell:addChild(pExperCell)
            me.assignWidget(pExperCell, "img_mask"):setVisible(idx % 2 == 0)
        else 
           local pExperCell = me.assignWidget(cell,"rank_cell")
           self:setExper(pExperCell,self.mRankList[idx+1])
           me.assignWidget(pExperCell, "img_mask"):setVisible(idx % 2 == 0)
        end

        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(1167, 496))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0.5, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "table_node"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()   
    self.mTableView = tableView

    -- 选中
    for i, v in ipairs(self.mRankList) do
      if tostring(v.id) == tostring(user.uid) then
        self:setPointpitch(i, pNum)
        break
      end
    end
end
function fortRankView:setExper(pNode,pData)
   if pData then
       -- 排名
       dump(pData)
       local pRnakIng = me.assignWidget(pNode,"R_cell_rank")
       pRnakIng:setString(pData["Ranking"])      
       local pRankIcon = me.assignWidget(pNode,"R_cell_rank_icon")
       local pRank = pData["Ranking"]
       if pRank == 1 then
          pRankIcon:setVisible(true)
          pRnakIng:setVisible(false)
          pRankIcon:loadTexture("paihang_diyiming.png",me.localType)
       elseif pRank == 2 then
          pRankIcon:setVisible(true)
          pRnakIng:setVisible(false)
          pRankIcon:loadTexture("paihang_dierming.png",me.localType)
       elseif pRank == 3 then
          pRankIcon:setVisible(true)
          pRnakIng:setVisible(false)
          pRankIcon:loadTexture("paihang_disanming.png",me.localType)
       else
          pRankIcon:setVisible(false)
          pRnakIng:setVisible(true)
       end  

       local pRankname = me.assignWidget(pNode,"R_cell_name")
       pRankname:setString(pData["name"])

       local pRankLevel = me.assignWidget(pNode,"R_cell_level")
       pRankLevel:setString(pData["level"])

       local pRankDamage = me.assignWidget(pNode,"R_cell_Damage_num")
       pRankDamage:setString(pData["HurtPercent"])

       local pRankExper = me.assignWidget(pNode,"R_cell_exoper_num")
       pRankExper:setString(pData["Integal"])
   end
end
function fortRankView:setPointpitch(pTag,pTabNum)
    pTag = me.toNum(pTag)
    local pPointX = 0
    local pPointY = (pTabNum - pTag) * 60
    self.pPitchHint = me.assignWidget(self,"rank_pitch_hint"):clone()         
    self.pPitchHint:setVisible(true)
    self.pPitchHint:setPosition(cc.p(pPointX, pPointY))
    self.pPitchHint:setLocalZOrder(10)
    self.mTableView:addChild(self.pPitchHint)
end
function fortRankView:onEnter()
    print("fortRankView onEnter") 
	me.doLayout(self,me.winSize)  
end
function fortRankView:onEnterTransitionDidFinish()
	print("fortRankView onEnterTransitionDidFinish") 
end
function fortRankView:onExit()
    print("fortRankView onExit")    
end
function fortRankView:close()
    self:removeFromParentAndCleanup(true)  
end
