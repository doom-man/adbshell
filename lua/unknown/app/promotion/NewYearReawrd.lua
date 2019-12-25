 NewYearReawrd = class("NewYearReawrd",function(...)
    return cc.CSLoader:createNode(...)
end)
NewYearReawrd.__index = NewYearReawrd

 
NewYearReawrd.singleNewYearRewardType = 3
NewYearReawrd.totalNewYearRewardType = 4
NewYearReawrd.singleDragonBoatType = 5
NewYearReawrd.totalDragonBoatType = 6
function NewYearReawrd:create(...)
    local layer = NewYearReawrd.new(...)
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

function NewYearReawrd:setRewardType(typeid,rewards,callback)
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
     
   if self.RankType == NewYearReawrd.singleNewYearRewardType or self.RankType == NewYearReawrd.singleDragonBoatType then 
          self:setButton(self.Button_stage,false)
    elseif self.RankType == NewYearReawrd.totalNewYearRewardType or self.RankType == NewYearReawrd.totalDragonBoatType then 
          self:setButton(self.Button_total,false)
    end
end

function NewYearReawrd:ctor()
    print("NewYearReawrd:ctor()")
end
function NewYearReawrd:init()
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
           if self.RankType == NewYearReawrd.singleNewYearRewardType or self.RankType == NewYearReawrd.totalNewYearRewardType then
                self.RankType = NewYearReawrd.singleNewYearRewardType
           elseif self.RankType == NewYearReawrd.singleDragonBoatType or self.RankType == NewYearReawrd.totalDragonBoatType then
                self.RankType = NewYearReawrd.singleDragonBoatType
           end
           NetMan:send(_MSG.CheckActivity_Limit_Reward(self.RankType))     
    end)
    me.assignWidget(self.Button_stage, "Text_title"):setString("每日积分排行")
    self.Button_total = me.registGuiClickEventByName(self,"Button_total",function ()
           self:setButton(self.Button_total,false) 
           self:setButton(self.Button_stage,true) 
           if self.RankType == NewYearReawrd.singleNewYearRewardType or self.RankType == NewYearReawrd.totalNewYearRewardType then
                self.RankType = NewYearReawrd.totalNewYearRewardType
           elseif self.RankType == NewYearReawrd.singleDragonBoatType or self.RankType == NewYearReawrd.totalDragonBoatType then
                self.RankType = NewYearReawrd.totalDragonBoatType
           end
           NetMan:send(_MSG.CheckActivity_Limit_Reward(self.RankType))
       
    end)
    me.assignWidget(self.Button_total, "Text_title"):setString("总积分排行")
    print("NewYearReawrd:init()")
    self.Button_total:setVisible(user.activityDetail.show)
    return true
end

function NewYearReawrd:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c4b(189,166,123, 255))
    else
        title:setTextColor(cc.c4b(233,220,175, 255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function NewYearReawrd:onEnter()  
    if table.nums(self.rewardDatas) <=0 then
        __G__TRACKBACK__("self.rewardDatas 数据为空！")
        return 
    end

    self:setRewardInfos()
    me.doLayout(self,me.winSize)
end

function NewYearReawrd:setRewardInfos()
    local tableSize = me.assignWidget(self,"Panel_table"):getContentSize()

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
        return tableSize.width, 134 + 5
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

        -- 底板
        local img_mask = me.assignWidget(node, "Image_14")
        img_mask:setVisible(idx % 2 ~= 0)
        img_mask:setOpacity(60)

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
            item:setPosition(cc.p(95 + item_index * 122, 62))
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
        self.tableView = cc.TableView:create(tableSize)
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

function NewYearReawrd:onExit()
end