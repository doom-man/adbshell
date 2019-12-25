--[Comment]
--jnmo
pvpRewardView = class("pvpRewardView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
pvpRewardView.__index = pvpRewardView
function pvpRewardView:create(...)
    local layer = pvpRewardView.new(...)
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
function pvpRewardView:ctor()   
    print("pvpRewardView ctor") 
end
function pvpRewardView:init()   
    print("pvpRewardView init")   
    me.registGuiClickEventByName(self,"close",function ()
        if self.cb ~= nil then
            self.cb()
            self.cb = nil
        end
        self:removeFromParent()
    end)
    self.Button_stage = me.registGuiClickEventByName(self,"Button_stage",function ()
           self:setButton(self.Button_total,true) 
           self:setButton(self.Button_stage,false)           
           self.RankType = 21           
           NetMan:send(_MSG.CheckActivity_Limit_Reward(self.RankType))     
    end)
    self.Button_stage:setTitleText("每日奖励")
    self.Button_total = me.registGuiClickEventByName(self,"Button_total",function ()
           self:setButton(self.Button_total,false) 
           self:setButton(self.Button_stage,true)           
           self.RankType = 22           
           NetMan:send(_MSG.CheckActivity_Limit_Reward(self.RankType))
       
    end)
    self.Button_total:setTitleText("赛季奖励")
    return true
end
function pvpRewardView:setRewardType(typeid,rewards,callback)
    self.RankType = typeid
    self.cb = callback
    me.tableClear(self.rewardDatas)
    self.rewardDatas = {}
    for key, var in pairs(rewards) do
        local  data = {}
        if me.toNum(var["bg"]) == me.toNum(var["ed"]) then
            data["rank"] =  me.toNum(var["bg"]).."名"
        else
            data["rank"] =  me.toNum(var["bg"]) .."-".. me.toNum(var["ed"]).."名"
        end        
        data["items"] = var["rw"]
        self.rewardDatas[#self.rewardDatas+1] = data
    end
--    local function sortFunc(pa, pb)
--        if me.toNum(pa["rank"]) < me.toNum(pb["rank"]) then
--            return true                      
--        end
--    end
--    table.sort(self.rewardDatas,sortFunc)
     
   if self.RankType == 21 then 
          self:setButton(self.Button_stage,false)
    elseif self.RankType == 22 then 
          self:setButton(self.Button_total,false)
    end
end
function pvpRewardView:setButton(button,b)
    button:setBright(b)
    if b then
       button:setTitleColor(cc.c4b(212,197,180,255))        
    else
       button:setTitleColor(cc.c4b(235,228,198,255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function pvpRewardView:onEnter()  
    if table.nums(self.rewardDatas) <=0 then
        __G__TRACKBACK__("self.rewardDatas 数据为空！")
        return 
    end

    self:setRewardInfos()
    me.doLayout(self,me.winSize)
end
function pvpRewardView:setRewardInfos()

    local function contains(node, x, y)     
        local point = cc.p(x,y)
        local pRect = cc.rect(0,0,node:getContentSize().width,node:getContentSize().height)  
        local locationInNode = node:convertToNodeSpace(point)     -- 世界坐标转换成节点坐标
        return cc.rectContainsPoint(pRect, locationInNode)      
    end
  
    local function numberOfCellsInTableView(table_)
        return table.nums(self.rewardDatas)
    end

    local function cellSizeForTable(table, idx)
        return 509, 130
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil

        local function setSingleCellInfo(item,def,num)
            me.assignWidget(item,"Image_quality"):loadTexture(getQuality(def.quality), me.localType)
            me.assignWidget(item,"Goods_Icon"):loadTexture("item_"..def.icon..".png",me.localType)
            me.assignWidget(item,"label_num"):setString(num)
        end
        
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Panel_cell"):clone()
            node:setSwallowTouches(false)
            me.assignWidget(node,"Panel_items"):setSwallowTouches(false)
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Panel_cell")
        end
        me.assignWidget(node,"Panel_items"):removeAllChildren()
        local data = self.rewardDatas[me.toNum(idx+1)]
        local rank = data["rank"]  
        local item_index = 0
        me.assignWidget(node,"Text_rank"):setString(rank)
        for inKey, inVar in pairs(data.items) do
            local id,num = inVar[1],inVar[2]
            local item = me.assignWidget(self,"Button_item"):clone()
            item:setVisible(true)
--            dump(inVar)
            local def = cfg[CfgType.ETC][id] 
            if def == nil then
                dump(inVar)
            end
            item:setPosition(cc.p(item_index*95,0))
            item:setTag(item_index)
--            dump(def)
            setSingleCellInfo(item,def,num)
            me.assignWidget(node,"Panel_items"):addChild(item)
            me.registGuiClickEventByName(item,"Button_item",function (node)
                local pTouch = node:getTouchBeganPosition()                  
                local pNode = me.assignWidget(self, "Panel_table")
                local pPoint = contains(pNode,pTouch.x,pTouch.y)                    
                if pPoint then
                    showPromotion(id,num)
                end
            end)
            me.assignWidget(item,"Button_item"):setSwallowTouches(false)
            item_index = item_index+1
        end

        return cell
    end

    local function tableCellTouched(table, cell)
    end

    if self.tableView == nil then
        local Panel_table = me.assignWidget(self,"Panel_table")
        self.tableView = cc.TableView:create(cc.size(Panel_table:getContentSize().width, Panel_table:getContentSize().height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(0, 0)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        Panel_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()    
end
function pvpRewardView:onEnterTransitionDidFinish()
	print("pvpRewardView onEnterTransitionDidFinish") 
end
function pvpRewardView:onExit()
    print("pvpRewardView onExit")    
end
function pvpRewardView:close()
    self:removeFromParent()  
end
