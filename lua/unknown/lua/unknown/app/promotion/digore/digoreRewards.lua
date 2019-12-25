digoreRewards = class("digoreRewards",function(...)
    return cc.CSLoader:createNode(...)
end)
digoreRewards.__index = digoreRewards

digoreRewards.TianRewardType = 17 -- 天榜奖励
digoreRewards.DiRewardType = 18 -- 地榜奖励
digoreRewards.RenRewardType = 19 -- 人榜奖励

function digoreRewards:create(...)
    local layer = digoreRewards.new(...)
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

function digoreRewards:setRewardType(typeid,rewards)
    self.rewardType = typeid
    me.tableClear(self.rewardDatas)
    self.rewardDatas = {}
    for key, var in pairs(rewards) do
        local  data = {}
        data["rank"] = var
        data["items"] = var.rw
        self.rewardDatas[#self.rewardDatas+1] = data
    end
end

function digoreRewards:ctor()
    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_LIMIT_REWARDS) then
            if msg.c.type==digoreRewards.TianRewardType or msg.c.type==digoreRewards.DiRewardType or msg.c.type==digoreRewards.RenRewardType then
                self:setRewardType(msg.c.type, msg.c.award)
                self:setRewardInfos()
            end
        end      
    end ) 
end

function digoreRewards:setButton(button, b)
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

function digoreRewards:init()
    me.registGuiClickEventByName(self,"close",function ()
        if self.cb ~= nil then
            self.cb()
            self.cb = nil
        end
        self:removeFromParent()
    end)
    self.Button_tian = me.registGuiClickEventByName(self,"Button_tian",function ()
        self:setButton(self.Button_tian, false)
        self:setButton(self.Button_ren, true)
        self:setButton(self.Button_di, true)

        if self.rewardType ~= digoreRewards.TianRewardType then
            NetMan:send(_MSG.CheckActivity_Limit_Reward(digoreRewards.TianRewardType))
        end
    end)
    self.Button_ren = me.registGuiClickEventByName(self,"Button_ren",function ()
        self:setButton(self.Button_tian, true)
        self:setButton(self.Button_ren, false)
        self:setButton(self.Button_di, true)

        if self.rewardType ~= digoreRewards.RenRewardType then
            NetMan:send(_MSG.CheckActivity_Limit_Reward(digoreRewards.RenRewardType))
        end
    end)
    self.Button_di = me.registGuiClickEventByName(self,"Button_di",function ()
        self:setButton(self.Button_tian, true)
        self:setButton(self.Button_ren, true)
        self:setButton(self.Button_di, false)

       if self.rewardType ~=  digoreRewards.DiRewardType then
          NetMan:send(_MSG.CheckActivity_Limit_Reward(digoreRewards.DiRewardType))
       end
    end)

    self:setButton(self.Button_tian, false)
    self:setButton(self.Button_ren, true)
    self:setButton(self.Button_di, true)

    print("digoreRewards:init()")
    return true
end
function digoreRewards:onEnter()  
    me.doLayout(self,me.winSize)
    if table.nums(self.rewardDatas) <=0 then
        return 
    end
    self:setRewardInfos()
    
end

function digoreRewards:setRewardInfos()
    local function getRankNum(node, idx)
        rank = ""
        local curData = self.rewardDatas[me.toNum(idx)]
        if curData.rank.bg==curData.rank.ed then
            me.assignWidget(node,"Text_rank"):setString("排名:"..curData.rank.bg) 
        else
            me.assignWidget(node,"Text_rank"):setString("排名:"..curData.rank.bg.."-"..curData.rank.ed)
        end
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
        getRankNum(node, idx+1) 
        --[[
        local rank = idx+1      
        
        local Text_10 = me.assignWidget(node,"Text_Rank_txt")
        local Text_rank = me.assignWidget(node,"Text_rank")
        local Image_rank = me.assignWidget(node,"Image_rank")
        if tonumber(rank) == 1 then
            Image_rank:setVisible(true)
            Text_10:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_1.png",me.localType)
        elseif tonumber(rank) == 2 then 
            Image_rank:setVisible(true)
            Text_10:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_2.png",me.localType)
        elseif tonumber(rank) == 3 then
            Image_rank:setVisible(true)
            Text_10:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_3.png",me.localType)
        
        elseif tonumber(rank) == 4 then
            Image_rank:setVisible(true)
            Text_10:setVisible(false)
            Image_rank:loadTexture("wangzuo_tubiao_paiming_4.png",me.localType)
        
        else
            Image_rank:setVisible(false)
            Text_10:setVisible(true)
        end
        Text_10:setString("排名：")
        Text_rank:setString(rank)
]]
        local item_index = 0
        for inKey, inVar in pairs(data.items) do
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

function digoreRewards:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
