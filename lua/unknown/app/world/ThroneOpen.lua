 --[Comment]
--jnmo
ThroneOpen = class("ThroneOpen",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
ThroneOpen.__index = ThroneOpen
function ThroneOpen:create(...)
    local layer = ThroneOpen.new(...)
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
ThroneOpen.OPEN = 1 -- 开放
ThroneOpen.CLOSE = 2 -- 关闭
function ThroneOpen:ctor()   
    print("ThroneOpen ctor") 
end
function ThroneOpen:init()   
    print("ThroneOpen init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    

    return true
end
function ThroneOpen:setType(pType)
    if pType == ThroneOpen.OPEN then
       me.assignWidget(self,"Panel_explain"):setVisible(true)
       me.assignWidget(self,"Panel_Throne_occupy"):setVisible(false)
       local Throne_icon =  me.createSprite("wangzuo_beijing_xikangqing.png")
       me.assignWidget(self,"Panel_image_up"):addChild(Throne_icon)
       me.graySprite(Throne_icon)
       self:setStr()
    elseif pType == ThroneOpen.CLOSE then
       me.assignWidget(self,"Panel_explain"):setVisible(false)
       me.assignWidget(self,"Panel_Throne_occupy"):setVisible(true)
       local Occupy_alliance_name = me.assignWidget(self,"Occupy_alliance_name") 
       local Image_3 = me.assignWidget(self,"Image_3")
       if user.throne_morleRank.Thronr_type == 1 then
          Occupy_alliance_name:setString("无")
          Image_3:loadTexture("wangzuo_tubiao_zhegnduo.png",me.plistType)
       elseif  user.throne_morleRank.Thronr_type == 2 or user.throne_morleRank.Thronr_type == 3 then
          Occupy_alliance_name:setString(user.throne_morleRank.OccupyFamily)
          Image_3:loadTexture("wangzuo_tubiao_zhegnduo_2.png",me.plistType)
       end
       local pThroneConfig = cfg[CfgType.THRONE_DEF][1]
       local pText = me.assignWidget(self,"Text_9")
       pText:setString(pThroneConfig["fightDes"])

       local pMoraleTab = {}
       for key, var in pairs(user.throne_morleRank.MorleRank) do
           table.insert(pMoraleTab,var)
       end
       self:TableOccupy(pMoraleTab)        
    end
end
function ThroneOpen:setStr()
    local pThroneConfig = cfg[CfgType.THRONE_DEF][1]["preDes"] 
    local pTabStr = me.split(pThroneConfig,"|")
    local pNode = me.assignWidget(self,"Panel_Text")
    pNode:removeAllChildren()
    local pTotalHeight = 0
    for key, var in pairs(pTabStr) do
        local pStrNum = getStringLength(var)
        local pHeight = math.ceil(pStrNum / 43) *23
        local pWidth = 480
        local pText = me.assignWidget(self,"Text_Throne"):clone()
        pText:setString(var)
        pText:setAnchorPoint(cc.p(0,1))
        pText:setPosition(cc.p(0,pTotalHeight))
        pText:setContentSize(cc.size(pWidth,pHeight)) 
        pNode:addChild(pText)
        pTotalHeight = pTotalHeight - pHeight
    end
    
end
function ThroneOpen:onEnter()
    print("ThroneOpen onEnter") 
	me.doLayout(self,me.winSize)  
end
function ThroneOpen:onEnterTransitionDidFinish()
	print("ThroneOpen onEnterTransitionDidFinish") 
end
function ThroneOpen:onExit()
    print("ThroneOpen onExit")    
end
function ThroneOpen:close()
    self:removeFromParentAndCleanup(true)  
end

function ThroneOpen:TableOccupy(pTab)
       local pNum = #pTab
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
      
        return 580, 40
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local Panel_cell_rank = me.assignWidget(self,"Panel_cell_rank"):clone():setVisible(true)
            Panel_cell_rank:setAnchorPoint(cc.p(0,0))
            Panel_cell_rank:setPosition(cc.p(0, 0))
            self:setRankCell(Panel_cell_rank,pTab[idx+1],idx+1)                                        
            cell:addChild(Panel_cell_rank)
        else 
           local Panel_cell_rank = me.assignWidget(cell,"Panel_cell_rank")           
           self:setRankCell(Panel_cell_rank,pTab[idx+1],idx+1)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(580, 200))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(3, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel_tabel_"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData() 
end
function ThroneOpen:setRankCell(pNode,pData,pRankNum)
     if pNode then
        local rank_name = me.assignWidget(pNode,"rank_name")
        rank_name:setString(pRankNum.."."..pData["FamilyName"])

        local LoadingBar_1 = me.assignWidget(pNode,"LoadingBar_1")
        LoadingBar_1:setPercent(pData.PeopleHeart/user.throne_morleRank.PeopleHeartM*100)

        local Text_morle_num = me.assignWidget(pNode,"Text_morle_num")
        Text_morle_num:setString(pData.PeopleHeart.."/"..user.throne_morleRank.PeopleHeartM)
     end
end