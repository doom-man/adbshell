 --[Comment]
--jnmo
ThroneStrategy = class("ThroneStrategy",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
ThroneStrategy.__index = ThroneStrategy
function ThroneStrategy:create(...)
    local layer = ThroneStrategy.new(...)
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
function ThroneStrategy:ctor()   
    print("ThroneStrategy ctor") 
    self.mId = 1
end
function ThroneStrategy:init()   
    print("ThroneStrategy init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self:setStrategy()
    return true
end
function ThroneStrategy:onEnter()
    print("ThroneStrategy onEnter") 
	me.doLayout(self,me.winSize)  
end
function ThroneStrategy:onEnterTransitionDidFinish()
	print("ThroneStrategy onEnterTransitionDidFinish") 
end
function ThroneStrategy:onExit()
    print("ThroneStrategy onExit")  
    if self.mTime then
       me.clearTimer(self.mTime)
       self.mTime = nil
    end  
end
function ThroneStrategy:setStrategy()
     local pData = user.throne_Strategy
     local pTable ={}
     for key, var in pairs(pData.Strategy) do
         table.insert(pTable,var)
     end
     dump(pData)
     local launch_count_down = me.assignWidget(self,"launch_count_down")
     launch_count_down:setVisible(false)
     self.pCountdown = pData.countdown
     if self.mTime then
        me.clearTimer(self.mTime)
        self.mTime = nil
     end  
     self.mTime = me.registTimer(-1, function(dt)
         for key, var in pairs(pTable) do
             local pTime = var.strgCD
             if pTime > 0 then
                var.strgCD = pTime - 1
              end
          end   
          if self.pCountdown > 0 then
             self.pCountdown = self.pCountdown -1
             launch_count_down:setString(me.formartSecTime(self.pCountdown))
             launch_count_down:setVisible(true)
             me.setButtonDisable(self.Button_launch,false)
          else
             launch_count_down:setVisible(false)
             me.setButtonDisable(self.Button_launch,true)
          end                  
      end,1)

      self.Button_launch =  me.registGuiClickEventByName(self,"Button_launch",function (node)
          NetMan:send(_MSG.worldthronestartegystart(self.mId)) 
          pWorldMap.ThroneStratAniBool = true

      end)
     me.assignWidget(self, "Panel_table"):removeAllChildren()
     self.selectImg = nil
     self:setTable(pTable)
     if #pTable >0 then
        self:setResoure(self.mId)
     end 
end
local green_color = me.convert3Color_("#67ff02")
local red_color = me.convert3Color_("#ff0202")
function ThroneStrategy:setResoure(pId)
     local resource = cfg[CfgType.THRONE_STRATEGY][pId]["resource"]
      local resourceTab = me.split(resource,",")
      local food_num = me.assignWidget(self,"food_num")
      food_num:setString(resourceTab[1])
      if me.toNum(user.food) > me.toNum(resourceTab[1]) then
         food_num:setTextColor(green_color)
      else
         food_num:setTextColor(red_color)
      end
      local wood_num = me.assignWidget(self,"wood_num")
      wood_num:setString(resourceTab[2])
      if me.toNum(user.wood) > me.toNum(resourceTab[2]) then
         wood_num:setTextColor(green_color)
      else
         wood_num:setTextColor(red_color)
      end
      local stone_num = me.assignWidget(self,"stone_num")
      stone_num:setString(resourceTab[3])
       if me.toNum(user.stone) > me.toNum(resourceTab[3]) then
         stone_num:setTextColor(green_color)
      else
         stone_num:setTextColor(red_color)
      end
      local gold_num = me.assignWidget(self,"gold_num")
      gold_num:setString(resourceTab[4])
     if me.toNum(user.gold) > me.toNum(resourceTab[4]) then
         gold_num:setTextColor(green_color)
      else
         gold_num:setTextColor(red_color)
      end
end
function ThroneStrategy:setTable(pTable)
    self.pNum =  #pTable
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pId = cell:getIdx()+1
        self.mId = pId 
        self:setResoure(pId)    
        self.selectImg:setPosition(cc.p(self:getCellPoint(pId,self.pNum)))     
    end
    local function cellSizeForTable(table, idx) 
         
        return 1172,120
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local Panel_cell = StrategyCell:create(self, "Panel_cell")   
            Panel_cell:setPosition(cc.p(20,0))
            Panel_cell:setAnchorPoint(cc.p(0,0))
            Panel_cell:setData(pTable[idx+1])
            cell:addChild(Panel_cell)
        else 
           local Panel_cell = me.assignWidget(cell,"Panel_cell")
           Panel_cell:setData(pTable[idx+1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return self.pNum
    end

    tableView = cc.TableView:create(cc.size(1172, 453))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel_table"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData() 
    self.selectImg = ccui.ImageView:create()            
    self.selectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
    self.selectImg:setScale9Enabled(true)
    self.selectImg:ignoreContentAdaptWithSize(false)
    self.selectImg:setCapInsets(cc.rect(17, 17, 8, 8))
    self.selectImg:setContentSize(cc.size(1145, 138))
    self.selectImg:setPosition(self:getCellPoint(self.mId,self.pNum))
    self.selectImg:setLocalZOrder(10)
    tableView:addChild(self.selectImg)
end
 
function ThroneStrategy:getCellPoint(pTag,TableNum)
    pTag = me.toNum(pTag)
    self.pCellId = pTag
    local pPointX = 582
    local pPointY =(TableNum- pTag)*120+57.5
    return pPointX,pPointY
end
function ThroneStrategy:close()
    pWorldMap.ThroneStrategy = nil
    self:removeFromParentAndCleanup(true)  
end

