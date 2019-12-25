--[Comment]
--jnmo
kingdom_Cross_Score_rank = class("kingdom_Cross_Score_rank",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
kingdom_Cross_Score_rank.__index = kingdom_Cross_Score_rank
function kingdom_Cross_Score_rank:create(...)
    local layer = kingdom_Cross_Score_rank.new(...)
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
kingdom_Cross_Score_rank.CROSS_SCORE_RANK = 12
function kingdom_Cross_Score_rank:ctor()   
    print("kingdom_Cross_Score_rank ctor") 
end
function kingdom_Cross_Score_rank:init()   
    print("kingdom_Cross_Score_rank init")
	me.registGuiClickEventByName(self,"Button_cancel",function (node)
        self:close()     
    end)    
    self:setTable(user.CrossScoreRank)
    return true
end
function kingdom_Cross_Score_rank:setTable(pTable)
    local iNum = #pTable

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
 
    end

    local function cellSizeForTable(table, idx)
        return 1100, 80
    end

    local function tableCellAtIndex(table, idx)         
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local rank_cell = me.assignWidget(self,"rank_cell"):clone():setVisible(true)

            self:RankCell(rank_cell,pTable[idx+1],idx+1)
          
            cell:addChild(rank_cell)
        else 
           local rank_cell = me.assignWidget(cell,"rank_cell")
           self:RankCell(rank_cell,pTable[idx+1],idx+1)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(1100, 480))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(5, 5)
    tableView:setDelegate()
    me.assignWidget(self, "Panel_Table"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)    
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end
function kingdom_Cross_Score_rank:RankCell(node,data,index)
    if data then
       dump(data)
        index = me.toNum(index)
         me.assignWidget(node,"R_cell_rank"):setVisible(false)
        local pRankIcon = me.assignWidget(node,"R_cell_rank_icon"):setVisible(true)
        if index == 1 then
            pRankIcon:loadTexture("paihang_diyiming.png",me.localType)
        elseif index == 2 then
            pRankIcon:loadTexture("paihang_dierming.png",me.localType)
        elseif index == 3 then
            pRankIcon:loadTexture("paihang_disanming.png",me.localType)
        else
            me.assignWidget(node,"R_cell_rank"):setString(me.toStr(index)):setVisible(true)
            me.assignWidget(node,"R_cell_rank_icon"):setVisible(false)
        end

        local R_cell_name = me.assignWidget(node,"R_cell_name")
        R_cell_name:setString(data.rname)

        local R_cell_Sever_name = me.assignWidget(node,"R_cell_Sever_name")
        R_cell_Sever_name:setString(data.Severid.."区".."("..data.SeverName..")")

        local R_cell_level = me.assignWidget(node,"R_cell_level")
        R_cell_level:setString("lv."..data.level)

        local R_cell_Score = me.assignWidget(node,"R_cell_Score")
        R_cell_Score:setString(data.score)
    end
end
function kingdom_Cross_Score_rank:onEnter()
    print("kingdom_Cross_Score_rank onEnter") 
	me.doLayout(self,me.winSize)  
end
function kingdom_Cross_Score_rank:onEnterTransitionDidFinish()
	print("kingdom_Cross_Score_rank onEnterTransitionDidFinish") 
end
function kingdom_Cross_Score_rank:onExit()
    print("kingdom_Cross_Score_rank onExit")    
end
function kingdom_Cross_Score_rank:close()
    self:removeFromParentAndCleanup(true)  
end
