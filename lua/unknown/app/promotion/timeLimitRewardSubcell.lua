timeLimitRewardSubcell = class("timeLimitRewardSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
timeLimitRewardSubcell.__index = timeLimitRewardSubcell

timeLimitRewardSubcell.singleRewardType = 1
timeLimitRewardSubcell.totalRewardType = 2
timeLimitRewardSubcell.singleNewYearRewardType = 3
timeLimitRewardSubcell.totalNewYearRewardType = 4
function timeLimitRewardSubcell:create(...)
    local layer = timeLimitRewardSubcell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end

function timeLimitRewardSubcell:setRewardType(typeid,rewards,callback)
    self.rewardType = typeid
    self.cb = callback
    me.tableClear(self.rewardDatas)
    self.rewardDatas = {}
    for key, var in pairs(rewards) do
        local  data = {}
        data["rank"] = key
        data["items"] = var
        self.rewardDatas[#self.rewardDatas+1] = data
    end

    local function sortFunc(pa, pb)
        if me.toNum(pa["rank"]) < me.toNum(pb["rank"]) then
            return true                      
        end
    end
    table.sort(self.rewardDatas,sortFunc)
end

function timeLimitRewardSubcell:ctor()
    print("timeLimitRewardSubcell:ctor()")
end

function timeLimitRewardSubcell:setButton(button, b)
    button:setBright(b)
    --[[
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c4b(189,166,123, 255))
    else
        title:setTextColor(cc.c4b(233,220,175, 255))
    end
    ]]
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function timeLimitRewardSubcell:init()
    me.registGuiClickEventByName(self,"close",function ()
        if self.cb ~= nil then
            self.cb()
            self.cb = nil
        end
        self:removeFromParent()
    end)
    self.Button_stage = me.registGuiClickEventByName(self,"Button_stage",function ()
        if self.rewardType ~= timeLimitRewardSubcell.singleRewardType then
            NetMan:send(_MSG.CheckActivity_Limit_Reward(timeLimitRewardSubcell.singleRewardType))
            self:setButton(self.Button_stage, false)
            self:setButton(self.Button_total, true)
        end
    end)
    self.Button_total = me.registGuiClickEventByName(self,"Button_total",function ()
        if self.rewardType ~= timeLimitRewardSubcell.totalRewardType then
            NetMan:send(_MSG.CheckActivity_Limit_Reward(timeLimitRewardSubcell.totalRewardType))
            self:setButton(self.Button_stage, true)
            self:setButton(self.Button_total, false)
        end
    end)
    print("timeLimitRewardSubcell:init()")
    self:setButton(self.Button_stage, false)
    self:setButton(self.Button_total, true)
    return true
end
function timeLimitRewardSubcell:onEnter()  
    if table.nums(self.rewardDatas) <=0 then
        __G__TRACKBACK__("self.rewardDatas 数据为空！")
        return 
    end

    self:setRewardInfos()
    me.doLayout(self,me.winSize)
end

function timeLimitRewardSubcell:setRewardInfos()
    local function getRankNum(idx)
        rank = ""
        local curData = self.rewardDatas[me.toNum(idx)]
        local preDta = self.rewardDatas[me.toNum(idx-1)]
        if preDta ~= nil then
            if me.toNum(curData.rank) == me.toNum(preDta.rank)+1 then
                rank = "排名:"..curData.rank
            else
                local preNum = preDta.rank+1
                rank = "排名:"..me.toStr(preNum).."-"..curData.rank
            end
        else
            rank = "排名:"..curData.rank
        end
        return rank
    end

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
        return 752, 165
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
            node:setPositionX(6)
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Panel_cell")
        end

        local img_mask = me.assignWidget(node, "img_mask")
        img_mask:setVisible(idx % 2 ~= 0)
        img_mask:setOpacity(60)

        me.assignWidget(node,"Panel_items"):removeAllChildren()
        local data = self.rewardDatas[me.toNum(idx+1)]
        local rank = getRankNum(idx+1)        
        local item_index = 0
        me.assignWidget(node,"Text_rank"):setString(rank)
        for inKey, inVar in pairs(data.items) do
            local id,num = inVar[1],inVar[2]
            local item = me.assignWidget(self,"Button_item"):clone()
            item:setVisible(true)
            local def = cfg[CfgType.ETC][id] 
            item:setPosition(cc.p(item_index*118+75,63))
            item:setTag(item_index)
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

function timeLimitRewardSubcell:onExit()
end