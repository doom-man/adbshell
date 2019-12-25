medalSubcell = class("medalSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
medalSubcell.__index = medalSubcell
function medalSubcell:create(...)
    local layer = medalSubcell.new(...)
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

function medalSubcell:ctor()
    print("medalSubcell:ctor()")
end
function medalSubcell:init()
    self.Panel_touch = me.assignWidget(self,"Panel_touch")
    self.Panel_touch:setVisible(false)
    print("medalSubcell:init()")
    return true
end
function medalSubcell:onEnter()  
    me.assignWidget(self, "Panel_item"):setVisible(false)
    self.Panel_table = me.assignWidget(self,"Panel_table")
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(Panel_richText:getContentSize().width/2,Panel_richText:getContentSize().height/2)
        rich:setAnchorPoint(cc.p(0.5,0.5))
        Panel_richText:addChild(rich)
    end
    
    me.registGuiClickEvent(me.assignWidget(self,"Button_rank"),function ()
        NetMan:send(_MSG.rankList(rankView.PROMITION_MEDAL ))
    end)

    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            self:setInfo()
            self:setTableView()
        end
    end)
    self:setTableView()
    self:setInfo()
end

function medalSubcell:setInfo()
    me.assignWidget(self,"Text_MedelNum"):setString("我的武勋 "..user.activityDetail.wuXunNm)    
    me.assignWidget(self,"Text_activityTime"):setString("活动时间:"..me.GetInSecTime(math.floor(user.activityDetail.openDate/1000),true).." - "..me.GetInSecTime(math.floor(user.activityDetail.endDate/1000),true))    
end

function medalSubcell:setTableView()
    self.listData = user.activityDetail.list
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 782,138
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Panel_item"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Panel_item")
        end
        local cfgId = cfg[CfgType.DRAGON_BOAT][self.listData[me.toNum(idx+1)].defId].itemId
        local def = cfg[CfgType.ETC][cfgId]
        if self.listData[me.toNum(idx+1)] and def then
            me.registGuiClickEventByName(node,"Button_detail",function ()
                showPromotion(def.id,1)
            end)
            me.assignWidget(node,"Image_item"):loadTexture(getQuality(def.quality),me.plistType)
            me.assignWidget(node,"Image_icon"):loadTexture(getItemIcon(def.id),me.plistType)
            me.assignWidget(node,"Limit_num"):setString("剩"..self.listData[me.toNum(idx+1)].limit)
            me.assignWidget(node,"Text_describe"):setString(def.describe)
            me.assignWidget(node,"Text_title"):setString(def.name)
            local defMedalName = cfg[CfgType.ETC][self.listData[me.toNum(idx+1)].price[1][1]].name
            local defMedalNum = self.listData[me.toNum(idx+1)].price[1][2]
            me.assignWidget(node,"Text_medalCost"):setString(defMedalNum)
            if self.listData[me.toNum(idx+1)].price[2] then
                local defDiamondName = cfg[CfgType.ETC][self.listData[me.toNum(idx+1)].price[2][1]].name
                local defDiamondNum = self.listData[me.toNum(idx+1)].price[2][2]
                me.assignWidget(node,"Text_diamondCost"):setString(defDiamondNum)                
            end
            me.assignWidget(node,"Text_diamondCost"):setVisible(self.listData[me.toNum(idx+1)].price[2] ~= nil)
            if self.listData[me.toNum(idx+1)].limit == 0 then --已完毕
                me.assignWidget(node,"Button_get"):setVisible(false)
                me.assignWidget(node,"Image_got"):setVisible(true)
            elseif self.listData[me.toNum(idx+1)].limit > 0 or self.listData[me.toNum(idx+1)].limit == -1 then --可兑换
                me.assignWidget(node,"Image_got"):setVisible(false)
                me.assignWidget(node,"Button_get"):setVisible(true)
                me.setButtonDisable(me.assignWidget(node,"Button_get"),true)
                me.registGuiClickEventByName(node,"Button_get",function ()
                    self.tableOffPos = self.tableView:getContentOffset()
                    me.setButtonDisable(me.assignWidget(node,"Button_get"),fasle)
                    NetMan:send(_MSG.Medal_Exchange(self.listData[me.toNum(idx+1)].defId))
                end)
            end
            me.assignWidget(node,"num_bg"):setVisible(self.listData[me.toNum(idx+1)].limit ~= -1)
        end
        return cell
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(self.Panel_table:getContentSize().width,self.Panel_table:getContentSize().height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setAnchorPoint(cc.p(0.5,0.5))
        self.tableView:setPosition(cc.p(0,0))
        self.Panel_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()
    if self.tableOffPos ~= nil then
        self.Panel_touch:setVisible(true)
        self.tableView:setContentOffset(self.tableOffPos)
        me.DelayRun(function ()
            self.Panel_touch:setVisible(false)
        end,1)
    end
end

function medalSubcell:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
