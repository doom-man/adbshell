 --[Comment]
--jnmo
RepatriateRecord = class("RepatriateRecord",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
RepatriateRecord.__index = RepatriateRecord
function RepatriateRecord:create(...)
    local layer = RepatriateRecord.new(...)
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
function RepatriateRecord:ctor()   
    print("RepatriateRecord ctor") 
end
function RepatriateRecord:init()   
    print("RepatriateRecord init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.RecordData = user.defensHistoryList        
     self:initInfoTab()
    return true
end
function RepatriateRecord:onEnter()
    print("RepatriateRecord onEnter") 
	me.doLayout(self,me.winSize)  
end
function RepatriateRecord:initInfoTab()  
 
    local pNum = #self.RecordData
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)                
        return 752, 39
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        
        local cell = table:dequeueCell()  
        local pRecordCellbg      
        if nil == cell then
          cell = cc.TableViewCell:new()
          pRecordCellbg = me.assignWidget(self,"relief_cell"):clone():setVisible(true)
          self:RecordCell(pRecordCellbg,self.RecordData[idx+1])
          pRecordCellbg:setAnchorPoint(cc.p(0, 0))
          pRecordCellbg:setPosition(cc.p(0, 0))    
          cell:addChild(pRecordCellbg)
        else
          pRecordCellbg = me.assignWidget(cell,"relief_cell")
          self:RecordCell(pRecordCellbg,self.RecordData[idx+1])
        end  
        local img_mask = me.assignWidget(cell, "img_mask")
        if idx%2==0 then
            --pRecordCellbg:loadTexture("alliance_alpha_bg.png", me.localType)
            img_mask:setVisible(true)
        else
            --pRecordCellbg:loadTexture("rank_cell_bg.png", me.localType)
            img_mask:setVisible(false)
        end
        return cell
    end
    function numberOfCellsInTableView(table)       
        return pNum
    end

    tableView = cc.TableView:create(cc.size(752, 413))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self,"Panel_table"):addChild(tableView)
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
function RepatriateRecord:RecordCell(pRecordCell,pData) 
    local pName = me.assignWidget(pRecordCell,"relief_name") 
    pName:setString(pData["name"])

    local pArmyNumlabel = me.assignWidget(pRecordCell,"relief_army_num")
    pArmyNumlabel:setString(pData["num"])

    local pTime = me.assignWidget(pRecordCell,"relief_time")
    pTime:setString(me.GetSecTime(pData["time"]*1000))
end
function RepatriateRecord:onEnterTransitionDidFinish()
	print("RepatriateRecord onEnterTransitionDidFinish") 
end
function RepatriateRecord:onExit()
    print("RepatriateRecord onExit")    
end
function RepatriateRecord:close()
    self:removeFromParentAndCleanup(true)  
end

