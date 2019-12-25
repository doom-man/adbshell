--[Comment]
--jnmo
kingdomView_Cross = class("kingdomView_Cross",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
kingdomView_Cross.__index = kingdomView_Cross
function kingdomView_Cross:create(...)
    local layer = kingdomView_Cross.new(...)
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
function kingdomView_Cross:ctor()   
    print("kingdomView_Cross ctor") 
    self.mTime = nil
    self.mNode = nil
end
function kingdomView_Cross:init()   
    print("kingdomView_Cross init")
	me.registGuiClickEventByName(self,"fixLayout",function (node)
      --  self:close()     
    end)    
    self.mTable = {}
    for key, var in pairs(user.Cross_PolicyData_Military) do
        var.NotOpen = 0
        table.insert(self.mTable,var)
    end
    
    for var  =1 ,2 do
        local pData = {}
        pData.NotOpen = var
        table.insert(self.mTable,pData)
    end
    self.mTime = me.registTimer(-1,function (dt)
         for key, var in pairs(self.mTable) do
             if var.NotOpen == 0  then
                if var.Time > 0 then
                var.Time = var.Time -1
                end                
             end      
         end
    end,1)
    self:setTable(self.mTable)
    return true
end
function kingdomView_Cross:setCity(pNode)
    self.mNode = pNode
end
function kingdomView_Cross:setTable(pTable)
    local pNum = #pTable
    local iNum = (pNum / 2)
    if (pNum %2) ~= 0 then
       iNum = iNum +1
    end
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
 
    end

    local function cellSizeForTable(table, idx)
        return 970, 285
    end

    local function tableCellAtIndex(table, idx)         
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, 1 do
                local Cross_one = kingdomView_Cross_Cell:create(self,"Panel_cell")
                Cross_one:setVisible(true)
                Cross_one:setTag(var)
                Cross_one:Cross_Cell(self.mTable[(idx)*2+var])
                local Cross_one_enter = me.assignWidget(Cross_one,"Cross_one_enter")
                Cross_one_enter:setTag((idx)*2+var)             
                me.registGuiClickEvent(Cross_one_enter, function(node)                   
                    print("Cross_one_enter"..node:getTag())                     
                    local pData = self.mTable[node:getTag()] 

                    if user.Cross_Sever_Status == mCross_Sever and CUR_GAME_STATE == GAME_STATE_CITY then     
                       if self.mNode then
                          self.mNode:close()
                       end                  
                       mainCity:cloudClose( function(node)
                       local loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                       me.runScene(loadlayer)
                       end)
                    else
                        if pData.status == 1 then                      
                           NetMan:send(_MSG.getNetBattleDataMsg())
                           First_City = true
                           if self.mNode then
                              self.mNode:close()
                           end  
                           if pWorldMap and pWorldMap.kmv then
                              pWorldMap.kmv:close()
                           end  
                        elseif pData.status == 0 then
                           showTips("活动未开启")  
                        elseif pData.status == 2 then
                           showTips("活动已结束")      
                        end                
                    end                 
                end)
                local Cross_one_rank_button = me.assignWidget(Cross_one,"Cross_one_rank_button")
                Cross_one_rank_button:setTag((idx)*2+var)    
                me.registGuiClickEvent(Cross_one_rank_button, function(node)                   
                   print("Cross_one_rank_button"..node:getTag())  
                    
                end)
                local Cross_one_reward_Button = me.assignWidget(Cross_one,"Cross_one_reward_Button")
                Cross_one_reward_Button:setTag((idx)*2+var)    
                me.registGuiClickEvent(Cross_one_reward_Button, function(node)                   
                   print("Cross_one_reward_Button"..node:getTag())
                   local pData = self.mTable[node:getTag()]   
                   NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.RankRewardType,pData.id))
                end)
                local Cross_one_explian = me.assignWidget(Cross_one,"Cross_one_explian")
                Cross_one_explian:setTag((idx)*2+var)    
                me.registGuiClickEvent(Cross_one_explian, function(node)                   
                   print("Cross_one_explian"..node:getTag())
                   local pData = self.mTable[node:getTag()]
                   if self.mNode then
                      self.mNode:Cross_des(pData.id) 
                   else
                       if pWorldMap and pWorldMap.kmv then
                          pWorldMap.kmv:Cross_des(pData.id)
                       end  
                   end                     
                end)
                local Button_out = me.assignWidget(Cross_one,"Button_out")
                Button_out:setTag((idx)*2+var)    
                me.registGuiClickEvent(Button_out, function(node)                   
                   print("Cross_one_explian"..node:getTag())
                    if self.mNode then
                       self.mNode:close()
                    else
                    if pWorldMap and pWorldMap.kmv then
                       pWorldMap.kmv:close()
                     end    
                    end
                   GMan():send(_MSG.Cross_Sever_onExit())              
                end)
                Cross_one:setAnchorPoint(cc.p(0,0))
                Cross_one:setPosition(cc.p((var)*490,0))
                Cross_one_enter:setSwallowTouches(false)
                Cross_one_rank_button:setSwallowTouches(false)
                Cross_one_reward_Button:setSwallowTouches(false)
                Cross_one_explian:setSwallowTouches(false)
                Button_out:setSwallowTouches(false)
                cell:addChild(Cross_one)
            end  
        else 
           for var = 1, 1 do
               local Cross_one = cell:getChildByTag(var)
               local Cross_one_enter = me.assignWidget(Cross_one,"Cross_one_enter")
               Cross_one_enter:setTag((idx)*2+var) 
               local Cross_one_rank_button = me.assignWidget(Cross_one,"Cross_one_rank_button")
               Cross_one_rank_button:setTag((idx)*2+var)                
               local Cross_one_reward_Button = me.assignWidget(Cross_one,"Cross_one_reward_Button")
               Cross_one_reward_Button:setTag((idx)*2+var)    
               local Cross_one_explian = me.assignWidget(Cross_one,"Cross_one_explian")
               Cross_one_explian:setTag((idx)*2+var) 
               local Button_out = me.assignWidget(Cross_one,"Button_out")
               Button_out:setTag((idx)*2+var)                                      
               Cross_one:Cross_Cell(self.mTable[(idx)*2+var])
           end
 
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(970, 576))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(5, 0)
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

function kingdomView_Cross:onEnter()
    print("kingdomView_Cross onEnter") 
	--me.doLayout(self,me.winSize)  
end
function kingdomView_Cross:onEnterTransitionDidFinish()
	print("kingdomView_Cross onEnterTransitionDidFinish") 
end
function kingdomView_Cross:onExit()
    print("kingdomView_Cross onExit")  
    me.clearTimer(self.mTime)  
end
function kingdomView_Cross:close()
    self:removeFromParentAndCleanup(true)  
end
