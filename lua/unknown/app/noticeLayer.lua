--[Comment]
--jnmo
noticeLayer = class("noticeLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
noticeLayer.__index = noticeLayer
function noticeLayer:create(...)
    local layer = noticeLayer.new(...)
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
noticeLayer.TABLEHEIGHT = 50
function noticeLayer:initWithStr(data)
--   local list = me.assignWidget(self,"ListView_1")
--   list:removeAllChildren()
--   local rt = mRichText:create(str,510,nil,10)
--   list:pushBackCustomItem(rt)
    me.assignWidget(self, "Panel_table"):setVisible(true)
    me.assignWidget(self, "ListView_1"):setVisible(false)
    self.TableHeight = { }
    self.LaunchTab = { }
    self.mData = { }
    self.pPeopleNum = 0
    for key, var in pairs(data.countx) do  
        local rt = mRichText:create(var.count, 758)
        local pHeight = rt:getContentSize().height
        table.insert(self.mData, var)
        table.insert(self.TableHeight,pHeight)    
        table.insert(self.LaunchTab, 1)
        self.pPeopleNum = self.pPeopleNum + 1
    end
    self:initInfoTab()
end
function noticeLayer:oldInit(str)
    me.assignWidget(self, "Panel_table"):setVisible(false)
    me.assignWidget(self, "ListView_1"):setVisible(true)
    local list = me.assignWidget(self,"ListView_1")
    list:removeAllChildren()
    local rt = mRichText:create(str, 758, nil, 10)
    list:pushBackCustomItem(rt)
end
function noticeLayer:ctor()   
    print("noticeLayer ctor") 
end
function noticeLayer:init()   
    print("noticeLayer init")
	me.registGuiClickEventByName(self,"fixLayout",function (node)
        self:close()     
    end)  
    me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)  
    return true
end
function noticeLayer:initInfoTab()
    self.tableView = nil
    local pNum = #self.TableHeight
    local pHeight = 460
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
            local pIndex = cell:getIdx() + 1
            local pLaunch = self.LaunchTab[pIndex]
            local pOffset = self.tableView:getContentOffset()
            local pOffsetNew = cc.p(0, 0)

            if pLaunch == 1 then
                for var = 1, self.pPeopleNum do
                    self.LaunchTab[var] = 1
                end
                self.LaunchTab[pIndex] = 2
                local pOffsetY =(- pNum +(pIndex - 1)) * noticeLayer.TABLEHEIGHT + pHeight - self.TableHeight[pIndex]
                if pNum * noticeLayer.TABLEHEIGHT + self.TableHeight[pIndex] < pHeight then
                    pOffsetY = pHeight -(pNum * noticeLayer.TABLEHEIGHT + self.TableHeight[pIndex])
                else
                    pOffsetY = math.min(pOffsetY, 0)
                end
                pOffsetNew = cc.p(0, pOffsetY)
            else
                self.LaunchTab[pIndex] = 1
                if pNum * noticeLayer.TABLEHEIGHT < pHeight then
                    pOffsetNew = cc.p(0,(pHeight - pNum * noticeLayer.TABLEHEIGHT))
                else
                    pOffsetNew = cc.p(0, math.min(0, pOffset.y + self.TableHeight[pIndex]))
                end
            end
            self.tableView:reloadData()
            self.tableView:setContentOffset(pOffsetNew)
    end

    local function cellSizeForTable(table, idx)      
        local pX = noticeLayer.TABLEHEIGHT
        local pLaunch = self.LaunchTab[idx + 1]
        if pLaunch == 2 then
            pX = pX + self.TableHeight[idx + 1]
        end
        return 758, pX
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pCell = me.assignWidget(self,"Panel_cell"):clone():setVisible(true)
            
            self:setCell(pCell,self.mData[idx+1],idx+1)
            local pLaunch = self.LaunchTab[idx + 1]
            local pHeight = noticeLayer.TABLEHEIGHT
            if pLaunch == 2 then
                pHeight = pHeight + self.TableHeight[idx + 1]
            end
            pCell:setPosition(cc.p(0, pHeight))
            pCell:setAnchorPoint(cc.p(0, 1))
            cell:addChild(pCell)
        else
            local pCell = me.assignWidget(cell, "Panel_cell")
            self:setCell(pCell,self.mData[idx+1],idx+1)
            local pLaunch = self.LaunchTab[idx + 1]
            local pHeight = noticeLayer.TABLEHEIGHT
            if pLaunch == 2 then
                pHeight = pHeight + self.TableHeight[idx + 1]
            end
            pCell:setPosition(cc.p(0, pHeight))
            pCell:setAnchorPoint(cc.p(0, 1))
            
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(758, 460))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate() 
    me.assignWidget(self, "Panel_table"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView = tableView
end
function noticeLayer:setCell(node,data,idx)
     local rtitle = mRichText:create(data.title)
     rtitle:setAnchorPoint(cc.p(0, 1))
     rtitle:setPositionX(30)
     local Panel_title = me.assignWidget(node,"Panel_title"):setVisible(true)
     Panel_title:removeAllChildren()
     Panel_title:addChild(rtitle)

     local title_icon = me.assignWidget(node,"Image_4"):setVisible(true)
     title_icon:setAnchorPoint(cc.p(0.5,0.5))
     title_icon:setPosition(cc.p(rtitle:getContentSize().width + 50, -12))

     local rcount = mRichText:create(data.count, 758)
     rcount:setAnchorPoint(cc.p(0,1))
     rcount:setPosition(cc.p(60, -35))
     local Panel_count = me.assignWidget(node,"Panel_count"):setVisible(true)
     Panel_count:removeAllChildren()
     Panel_count:addChild(rcount)
     local pLaunch = self.LaunchTab[idx]
     if pLaunch == 1 then
        Panel_count:setVisible(false)
        title_icon:setRotation(0)
     else
        Panel_count:setVisible(true)
        title_icon:setRotation(90)
     end
end
function noticeLayer:onEnter()
    print("noticeLayer onEnter") 
	me.doLayout(self,me.winSize)  
end
function noticeLayer:onEnterTransitionDidFinish()
	print("noticeLayer onEnterTransitionDidFinish") 
end
function noticeLayer:onExit()
    print("noticeLayer onExit")    
end
function noticeLayer:close()
    self:removeFromParent()  
end
