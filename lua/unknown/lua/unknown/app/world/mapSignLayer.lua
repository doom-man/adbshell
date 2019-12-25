mapSignLayer = class("mapSignLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
mapSignLayer.__index = mapSignLayer
function mapSignLayer:create(...)
    local layer = mapSignLayer.new(...)
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
function mapSignLayer:ctor()   
    print("mapSignLayer ctor") 
    self.visitor = nil
end
function mapSignLayer:setVisitor(v)
       self.visitor = v
end
function mapSignLayer:init()   
    print("mapSignLayer init")  
    me.registGuiTouchEventByName(self,"fixLayout",function (node,event)
           if event == ccui.TouchEventType.began then 
                node:setSwallowTouches(false)
                self:close()
            end
end)  
    self.Text_mCrood = me.assignWidget(self,"Text_mCrood")
    self.Text_mName = me.assignWidget(self,"Text_mName")
    me.registGuiClickEventByName(self,"majorCity",function (node)
           if self.visitor then 
                self.visitor:lookMapAt(user.majorCityCrood.x,user.majorCityCrood.y)
           else
            print("怎么会")
           end 
end)
     
     self:setMarkerData()
     self:initList()
    return true
end
function mapSignLayer:setMarkerData()
      self.mMarker = {}
     for key, var in pairs(mMapTablepoint) do
         table.insert(self.mMarker, 1, var)
     end
      for key, var in pairs(gameMap.bastionData) do 
          local pTabPoint = { }
          pTabPoint.X = var.pos.x
          pTabPoint.Y = var.pos.y
          pTabPoint.name = var.name
          pTabPoint.army = var.army
          pTabPoint.types = POINT_STRONG_HOLD
          table.insert(self.mMarker, 1, pTabPoint)
     end
end
-- tableViews数据填充
function mapSignLayer:initList()
    self.globalItems = me.createNode("Node_mapSignItem.csb")
    self.globalItems:retain()
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
    --    table:onTouchBegan()
        local idx = cell:getIdx() +1
       
        local point = self.mMarker[idx]
      
        if point then
            pWorldMap:lookMapAt(point.X,point.Y)
            pWorldMap:LookMapAtSing(point.X,point.Y)
        end
    end

    local function cellSizeForTable(table, idx)
        return 310, 63
    end
    
    local function tableCellAtIndex(table, idx)
        -- print(idx)              
        local cell = table:dequeueCell()        
        if nil == cell then
           cell = cc.TableViewCell:new()
            local pMapSignCell =  mapSignCell:create(self.globalItems,"mapSignItem")
            pMapSignCell:setPosition(cc.p(135+25,32))
            pMapSignCell:initWithData(self.mMarker[idx+1])                    
            local pButtonClose = me.assignWidget(pMapSignCell,"Button_close")
            pButtonClose:setTag(idx+1)                                                                               
            me.registGuiClickEvent(pButtonClose,function (node)
                   self:removetab(me.toNum(node:getTag()))                   
                end)               
            pButtonClose:setSwallowTouches(false) 
            
            cell:addChild(pMapSignCell)                                           
        else
              local pMapSignCell = me.assignWidget(cell, "mapSignItem")
              me.assignWidget(pMapSignCell,"Button_close"):setTag(idx+1)             
              pMapSignCell:initWithData(self.mMarker[idx+1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        
        return #self.mMarker
    end

    self.tableView = cc.TableView:create(cc.size(311,251))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 0)
    self.tableView:setAnchorPoint(cc.p(0,0))
    self.tableView:setDelegate()
    me.assignWidget(self, "Panel_List"):addChild( self.tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()
  
end
function mapSignLayer:removetab(idx)
    local pOffest = self.tableView:getContentOffset()
    pOffest = cc.p(pOffest.x,pOffest.y+60)
    me.assignWidget(self, "Panel_List"):removeAllChildren() 
    local point = self.mMarker[idx]
--    WorldMapView.SignPoints[me.getIdByCoord(cc.p(point.X,point.Y))] = false 
--    table.remove(mMapTablepoint,idx)  
    pWorldMap:removeMapPoint(cc.p(point.X,point.Y))     
    self:setMarkerData()
    self:initList()
    if #self.mMarker >4 then        
        if #self.mMarker -4 < idx then
         self.tableView:setContentOffset(cc.p(0,0))
         else     
         self.tableView:setContentOffset(pOffest)
        end   
    else
        self.tableView:setContentOffset(cc.p(0,(4-#self.mMarker)*63))         
    end    
    SharedDataStorageHelper():setMapPoint(user.uid)
end
function mapSignLayer:close()
     local a1 = cc.MoveTo:create(0.2,cc.p(320,0))
     local function Aniend(args)
        self:stopAllActions()
        self:removeFromParentAndCleanup(true)

     end
     local call = cc.CallFunc:create(Aniend)
     local seq = cc.Sequence:create(a1,call)
     self:runAction(seq)
end
function mapSignLayer:initCoordSign()
    self.Text_mCrood:setString("("..user.majorCityCrood.x..","..user.majorCityCrood.y..")")
    self.Text_mName:setString(user.name)
    
    local armyNum = 0
    for key, var in pairs(user.soldierData) do 
        if var:getDef().bigType ~= 99 then     
           armyNum = armyNum + var.num 
        end
    end 
    me.assignWidget(self,"army_num"):setString(armyNum)
end
function mapSignLayer:onEnter()
    print("mapSignLayer onEnter") 
	me.doLayout(self,me.winSize)  
    self:initCoordSign()
end
function mapSignLayer:onExit()
    print("mapSignLayer onExit")  
    if self.globalItems then self.globalItems:release() end  
end
