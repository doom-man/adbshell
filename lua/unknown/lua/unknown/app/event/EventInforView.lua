EventInforView = class("EventInforView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
EventInforView.__index = EventInforView
function EventInforView:create(...)
    layer = EventInforView.new(...)
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
function EventInforView:ctor()  
       me.registGuiClickEventByName(self,"Button_cancel",function (node)
         self:close()    
    end) 
end
function EventInforView:close()    
    self:removeFromParentAndCleanup(true)         
end
function EventInforView:init() 
  -- dump(mNoticeInfo)
    local function NoticeCom(pa,pb)
          return me.toNum(pa["time"]) > me.toNum(pb["time"])
    end
          
    table.sort(mNoticeInfo,NoticeCom)
    self:initTable(mNoticeInfo)
    return true
end
function EventInforView:initTable(pMailFiTab)
    local iNum  = #pMailFiTab
  
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
      
    end

    local function cellSizeForTable(table, idx)
        return 1097, 120
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        
        local cell = table:dequeueCell()        
        if nil == cell then
           cell = cc.TableViewCell:new()
          local pEventInforCell = EventInforCell:create(self,"table_enent_cell_bg")
          pEventInforCell:setData(pMailFiTab[idx+1]) 
   --      pEventInforCell:setData(pMailFiTab[12])
           cell:addChild(pEventInforCell)                                 
          else
          local pEventInforCell = me.assignWidget(cell,"table_enent_cell_bg")
          pEventInforCell:setData(pMailFiTab[idx+1])   
        end  
        return cell
    end

    function numberOfCellsInTableView(table)
        
        return iNum
    end

    tableView = cc.TableView:create(cc.size(1108,540))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(20, 19)
    tableView:setDelegate()
    me.assignWidget(self,"Node_Table"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()     
end

function EventInforView:onEnter()   
    self.close_event = me.RegistCustomEvent("EventInforView",function (evt)
        self:close()
    end)
	me.doLayout(self,me.winSize)  
end
function EventInforView:onExit()
    me.RemoveCustomEvent(self.close_event)  
    print("EventInforView:onExit()   !!")
end
