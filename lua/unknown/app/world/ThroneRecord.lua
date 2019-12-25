 --[Comment]
--jnmo
ThroneRecord = class("ThroneRecord",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
ThroneRecord.__index = ThroneRecord
function ThroneRecord:create(...)
    local layer = ThroneRecord.new(...)
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
function ThroneRecord:ctor()   
    print("ThroneRecord ctor") 
end
function ThroneRecord:init()   
    print("ThroneRecord init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)   
  
    local pTable = {}       
    for key, var in pairs(user.throne_InitData) do
       local pStr = getStringmRichSub(var.str)
       local pStrLen = getStringLength(pStr)
        local pHeight = 50
        if pStrLen > 40 then
           pHeight  =75
        end
        var.Height = pHeight
        table.insert(pTable,1,var)
    end   
    self:setTable(pTable)
    return true
end
function ThroneRecord:onEnter()
    print("ThroneRecord onEnter") 
	me.doLayout(self,me.winSize)  
end
function ThroneRecord:onEnterTransitionDidFinish()
	print("ThroneRecord onEnterTransitionDidFinish") 
end
function ThroneRecord:onExit()
    print("ThroneRecord onExit")    
end
function ThroneRecord:close()
    self:removeFromParentAndCleanup(true)  
end
function ThroneRecord:setTable(pTable)
    local pNum = #pTable
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pId = cell:getIdx()+1           
    end
    local function cellSizeForTable(table, idx) 
        local pData = pTable[idx+1]
        return 757,pData.Height
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local Panel_cell = me.assignWidget(self,"Panel_cell"):clone():setVisible(true)
            Panel_cell:setPosition(cc.p(0,0))
            Panel_cell:setAnchorPoint(cc.p(0,0))
            self:setRecordCell(Panel_cell,pTable[idx+1],idx+1)
--            local pLayer =  cc.LayerColor:create(me.convert3Color_("#322e25"),600-pTable[idx+1],pTable[idx+1])
--            pLayer:setPosition(cc.p(0,0))
--            pLayer:setAnchorPoint(cc.p(0,0))          
--            cell:addChild(pLayer)
             cell:addChild(Panel_cell)
        else 
           local Panel_cell = me.assignWidget(cell,"Panel_cell")
           self:setRecordCell(Panel_cell,pTable[idx+1],idx+1)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(757, 467))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(3, 0))
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
end
function ThroneRecord:setRecordCell(pNode,pData,pId) 
    if pNode then
       local pBg = me.assignWidget(pNode,"Record_one_bg")
       if pId%2 == 1 then
          pBg = me.assignWidget(pNode,"Record_two_bg"):setVisible(true)
          me.assignWidget(pNode,"Record_one_bg"):setVisible(false)
       else  
          pBg = me.assignWidget(pNode,"Record_one_bg"):setVisible(true)
          pBg:setOpacity(80)
          me.assignWidget(pNode,"Record_two_bg"):setVisible(false)
       end
       pBg:setContentSize(cc.size(749,pData.Height))
  
       local pTime = me.assignWidget(pNode,"Text_time")
       pTime:setPosition(cc.p(pTime:getPositionX(),pData.Height/2))
       pTime:setString(getTime(pData.time))

       me.assignWidget(pNode,"Panel_content"):removeAllChildren()
       me.assignWidget(pNode,"Panel_content"):setPosition(cc.p(me.assignWidget(pNode,"Panel_content"):getPositionX(),pData.Height/2))
       local pContent = mRichText:create(pData.str,621)
     
      pContent:setAnchorPoint(cc.p(0,0.5))
      pContent:setPosition(cc.p(0,0))
      me.assignWidget(pNode,"Panel_content"):addChild(pContent)    
    end
end