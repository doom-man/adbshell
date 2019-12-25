kingdom_cross_rewards = class("kingdom_cross_rewards",function(...)
    return cc.CSLoader:createNode(...)
end)
kingdom_cross_rewards.__index = kingdom_cross_rewards

kingdom_cross_rewards.RankRewardType = 7 -- 排名奖励
kingdom_cross_rewards.totalRewardType = 8 -- 沦陷奖励
kingdom_cross_rewards.countryRewardType = 13 -- 区服奖励
kingdom_cross_rewards.personRewardType = 14 -- 个人奖励
function kingdom_cross_rewards:create(...)
    local layer = kingdom_cross_rewards.new(...)
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

function kingdom_cross_rewards:setRewardType(typeid,id,rewards,callback)
    self.rewardType = typeid
    self.cb = callback
    self.id = id
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

function kingdom_cross_rewards:ctor()
    print("kingdom_cross_rewards:ctor()")
end

function kingdom_cross_rewards:setButton(button, b)
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
function kingdom_cross_rewards:init()
    me.registGuiClickEventByName(self,"close",function ()
        if self.cb ~= nil then
            self.cb()
            self.cb = nil
        end
        self:removeFromParent()
    end)
    self.Button_stage = me.registGuiClickEventByName(self,"Button_stage",function ()
        
        self:setButton(self.Button_stage, false)
        self:setButton(self.Button_total, true)
        self:setButton(self.Button_country, true)
        self:setButton(self.Button_person, true)

        if self.rewardType ~= kingdom_cross_rewards.RankRewardType then
            NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.RankRewardType))
        end
    end)
    self.Button_total = me.registGuiClickEventByName(self,"Button_total",function ()
        self:setButton(self.Button_stage, true)
        self:setButton(self.Button_total, false)
        self:setButton(self.Button_country, true)
        self:setButton(self.Button_person, true)

        if self.rewardType ~= kingdom_cross_rewards.totalRewardType then
            NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.totalRewardType))
        end
    end)
    self.Button_country = me.registGuiClickEventByName(self,"Button_country",function ()
        
        self:setButton(self.Button_stage, true)
        self:setButton(self.Button_total, true)
        self:setButton(self.Button_country, false)
        self:setButton(self.Button_person, true)

       if self.rewardType ~=  kingdom_cross_rewards.countryRewardType then
          NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.countryRewardType))
       end
    end)
    self.Button_person = me.registGuiClickEventByName(self,"Button_person",function ()
        self:setButton(self.Button_stage, true)
        self:setButton(self.Button_total, true)
        self:setButton(self.Button_country, true)
        self:setButton(self.Button_person, false)

       if self.rewardType ~=  kingdom_cross_rewards.personRewardType then
          NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.personRewardType))
       end
    end)

    self:setButton(self.Button_stage, true)
    self:setButton(self.Button_total, true)
    self:setButton(self.Button_country, false)
    self:setButton(self.Button_person, true)
    print("kingdom_cross_rewards:init()")
    return true
end
function kingdom_cross_rewards:onEnter()  
    if table.nums(self.rewardDatas) <=0 then
        __G__TRACKBACK__("self.rewardDatas 数据为空！")
        return 
    end
    self:setRewardInfos()
    me.doLayout(self,me.winSize)
end

function kingdom_cross_rewards:setRewardInfos()
    local function getRankNum(data)
        rank = ""      
        if data ~= nil then
            if me.toNum(data.bg) == me.toNum(data.ed) then
                rank = me.toNum(data.bg)
            else
                rank = me.toNum(data.bg).."-"..me.toNum(data.ed)
            end      
        end
        return rank,me.toNum(data.bg) == me.toNum(data.ed)
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
        return 1164, 134 + 5
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
        me.assignWidget(node,"Image_14"):setVisible(idx%2==0)
        me.assignWidget(node,"Image_14"):setOpacity(60)
        me.assignWidget(node,"Panel_items"):removeAllChildren()
        local data = self.rewardDatas[me.toNum(idx+1)]
        local rank,beq = getRankNum(data.items)        
        local item_index = 0
        local Text_10 = me.assignWidget(node,"Text_Rank_txt")
        local Text_rank = me.assignWidget(node,"Text_rank")
        local Image_rank = me.assignWidget(node,"Image_rank")
        if beq and self.rewardType ~= kingdom_cross_rewards.totalRewardType then
             if tonumber(rank) == 1 then
                Image_rank:setVisible(true)
                Text_10:setVisible(false)
                Image_rank:loadTexture("paihang_diyiming.png",me.localType)
             elseif tonumber(rank) == 2 then 
                Image_rank:setVisible(true)
                Text_10:setVisible(false)
                Image_rank:loadTexture("paihang_dierming.png",me.localType)
             elseif tonumber(rank) == 3 then
                Image_rank:setVisible(true)
                Text_10:setVisible(false)
                Image_rank:loadTexture("paihang_disanming.png",me.localType)
            elseif tonumber(rank) == 4 then
                Image_rank:setVisible(true)
                Text_10:setVisible(false)
                Image_rank:loadTexture("paihang_disiming.png",me.localType)
             else
                Image_rank:setVisible(false)
                Text_10:setVisible(true)
             end
        elseif beq == false and self.rewardType ~= kingdom_cross_rewards.totalRewardType then
             Image_rank:setVisible(false)
             Text_10:setVisible(true)
        end
        if self.rewardType == kingdom_cross_rewards.RankRewardType or self.rewardType == kingdom_cross_rewards.countryRewardType then
           Text_10:setString("排名：")
           Text_rank:setString(rank)
        elseif self.rewardType == kingdom_cross_rewards.personRewardType then
           Text_10:setString("积分：")
           Text_rank:setString(data.items.bg)
        else
           Text_10:setString("沦陷：")
           Text_rank:setString(rank.."个区")
        end

        for inKey, inVar in pairs(data.items.rw) do
            local id,num = inVar[1],inVar[2]
            local item = me.assignWidget(self,"Button_item"):clone()
            item:setVisible(true)
            local def = cfg[CfgType.ETC][id] 
            item:setPosition(cc.p(65 + item_index* 122, 62))
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

function kingdom_cross_rewards:onExit()
end
