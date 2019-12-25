weekySignSubcell = class("weekySignSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
weekySignSubcell.__index = weekySignSubcell

function weekySignSubcell:create(...)
    local layer = weekySignSubcell.new(...)
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

function weekySignSubcell:ctor()
    print("weekySignSubcell:ctor()")
end
function weekySignSubcell:init()
    print("weekySignSubcell:init()")
    self.Panel_table = me.assignWidget(self,"Panel_table")
    self.extrasPanels = {}
    self.extrasPanels[#self.extrasPanels+1] = me.assignWidget(self,"Panel_blue")
    self.extrasPanels[#self.extrasPanels+1] = me.assignWidget(self,"Panel_green")
    self.extrasPanels[#self.extrasPanels+1] = me.assignWidget(self,"Panel_purple")
    return true
end
function weekySignSubcell:onEnter()  
    self.activityDef = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if self.activityDef and self.activityDef.desc then
        local Panel_richText = me.assignWidget(self,"text_conent")
        local rich = mRichText:create(self.activityDef.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end

    self.modelkey = UserModel:registerLisener(function(msg) -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WEEKY_SIGN) then
            
        elseif checkMsg(msg.t, MsgCode.WEEKY_SIGN_REWARD) then
            for key, var in pairs(user.activityDetail.rewards) do
                if var.weekId == msg.c.rewardWeek then
                    local i = {}
                    i[#i+1] = {}
                    i[#i]["defId"] = var.itemId
                    i[#i]["itemNum"] = 1
                    i[#i]["needColorLayer"] = true
                    getItemAnim(i)
                end
            end
            for key, var in pairs(user.activityDetail.extras) do
                if var.weekId == msg.c.rewardWeek/10 then
                    local i = {}
                    i[#i+1] = {}
                    i[#i]["defId"] = var.itemId
                    i[#i]["itemNum"] = 1
                    i[#i]["needColorLayer"] = true
                    getItemAnim(i)
                end
            end
            user.activityDetail.records[#user.activityDetail.records+1] = {}
            user.activityDetail.records[#user.activityDetail.records].weekId = msg.c.rewardWeek
            self:panelItems()
            self:rewardsItems()
        end
    end)
    
    self:panelItems()
    self:rewardsItems()
end

function weekySignSubcell:getRewardState(weekdId)
    for key, var in pairs(user.activityDetail.records) do
        if weekdId == me.toNum(var.weekId) then
            return true
        end
    end
    return false
end

function weekySignSubcell:rewardsItems()
    for key, var in pairs(user.activityDetail.extras) do
        local  weekNum = me.toNum(var.weekId)
        local  itemId = me.toNum(var.itemId)
        local panel = self.extrasPanels[me.toNum(key)]
        local Panel_ani = me.assignWidget(panel,"Panel_ani")
        Panel_ani:removeAllChildren()        
        local Button_item = me.assignWidget(panel,"Button_item")
        me.assignWidget(panel,"Text_buttonTitle"):setString("累计"..weekNum.."周")
        me.registGuiClickEvent(Button_item,function ()
            if self:getRewardState(weekNum*10) then --已领取
                    local gdc = giftDetailCell:create("giftDetailCell.csb")
                    local def = cfg[CfgType.ETC][itemId]
                    gdc:setItemData(def.useEffect)
                    mainCity:addChild(gdc,me.MAXZORDER)                        
            else
                if user.activityDetail.weekNum == 3 and user.activityDetail.currentWeek >= weekNum then --写死，已完成可领取
                    NetMan:send(_MSG.Weeky_Sign_Reward(weekNum,1))    
                else --未完成，预览
                    local gdc = giftDetailCell:create("giftDetailCell.csb")
                    local def = cfg[CfgType.ETC][itemId]
                    gdc:setItemData(def.useEffect)
                    mainCity:addChild(gdc,me.MAXZORDER)                        
                end
            end
        end)
        if self:getRewardState(weekNum*10) then
            me.assignWidget(panel,"Image_done"):setVisible(true)
        else
            if user.activityDetail.weekNum == 3 and user.activityDetail.currentWeek >= weekNum then
                local ani = createArmature("keji_jiesuo")
                Panel_ani:addChild(ani)
                ani:setPosition(Panel_ani:getContentSize().width/2, Panel_ani:getContentSize().height/2)
                ani:getAnimation():play("donghua")
            end
            me.assignWidget(panel,"Image_done"):setVisible(false)
        end
    end    
end

function weekySignSubcell:panelItems()
    self.Panel_table:setVisible(true)

    local function cellSizeForTable(table, idx)
        return 200, 240
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item =  me.createNode("Layer_WeekySign.csb")
            local layer = me.assignWidget(item, "Panel_base"):clone()
            cell:addChild(layer)
            cell:setTag(idx+1)
            layer:setSwallowTouches(false)
            local Panel_itemIcon = me.assignWidget(cell,"Panel_itemIcon")
            Panel_itemIcon:setSwallowTouches(false)
            me.registGuiClickEvent(Panel_itemIcon, function ()
                if self:getRewardState(user.activityDetail.rewards[cell:getTag()].weekId) then --已领取
                    local gdc = giftDetailCell:create("giftDetailCell.csb")
                    local def = cfg[CfgType.ETC][user.activityDetail.rewards[cell:getTag()].itemId]
                    gdc:setItemData(def.useEffect)
                    mainCity:addChild(gdc,me.MAXZORDER)                        
--                    showPromotion(user.activityDetail.rewards[cell:getTag()].itemId,1)
                else
                    if user.activityDetail.weekNum == 3 and user.activityDetail.rewards[cell:getTag()].weekId == user.activityDetail.currentWeek then --写死，已完成可领取
                        NetMan:send(_MSG.Weeky_Sign_Reward(cell:getTag(),0))    
                    else --未完成，预览
                        local gdc = giftDetailCell:create("giftDetailCell.csb")
                        local def = cfg[CfgType.ETC][user.activityDetail.rewards[cell:getTag()].itemId]
                        gdc:setItemData(def.useEffect)
                        mainCity:addChild(gdc,me.MAXZORDER)                        
--                        showPromotion(user.activityDetail.rewards[cell:getTag()].itemId,1)
                    end
                end
            end)
        else
            cell:setTag(idx+1)
        end
        local Panel_base = me.assignWidget(cell, "Panel_base")
        local Panel_itemIcon = me.assignWidget(Panel_base,"Panel_itemIcon")
        Panel_itemIcon:removeAllChildren()
        Panel_itemIcon:setSwallowTouches(false)
        local isCurrentWeek = me.toNum(user.activityDetail.currentWeek) == me.toNum(user.activityDetail.rewards[me.toNum(idx)+1].weekId)
        if self:getRewardState(user.activityDetail.rewards[me.toNum(idx)+1].weekId) then --已领取
            me.assignWidget(Panel_base,"Image_done"):setVisible(true)
            me.assignWidget(cell,"Text_preview"):setVisible(true)
            me.assignWidget(cell,"Text_doing"):setVisible(false)
            me.assignWidget(cell,"Text_doing_d"):setVisible(false)
            me.assignWidget(cell,"Text_preview"):setString("已领取")
        else
            me.assignWidget(Panel_base,"Image_done"):setVisible(false)
            me.assignWidget(cell,"Text_preview"):setString("奖励预览")
            me.assignWidget(cell,"Text_preview"):setVisible(not isCurrentWeek)
            me.assignWidget(cell,"Text_doing"):setVisible(isCurrentWeek)
            me.assignWidget(cell,"Text_doing_d"):setVisible(isCurrentWeek)
            if isCurrentWeek then
                me.assignWidget(cell,"Text_doing"):setString("今日完成任务"..user.activityDetail.dayNum.."/4")
                me.assignWidget(cell,"Text_doing_d"):setString("累计完成"..user.activityDetail.weekNum.."/3天")
                me.assignWidget(cell,"Image_bg"):loadTexture("huodong_beijing_qiaodao_leiji_liang.png",me.plistType)
            else
                me.assignWidget(cell,"Image_bg"):loadTexture("huodong_beijing_qiaodao_leiji.png",me.plistType)
            end
            if user.activityDetail.weekNum == 3 and user.activityDetail.rewards[me.toNum(idx)+1].weekId == user.activityDetail.currentWeek then --写死，已完成可领取
                local ani = createArmature("keji_jiesuo")
                Panel_itemIcon:addChild(ani)
                ani:setPosition(Panel_itemIcon:getContentSize().width/2, Panel_itemIcon:getContentSize().height/2)
                ani:getAnimation():play("donghua")
            end
        end
        me.assignWidget(cell,"Text_week"):setString("第"..me.toNum(user.activityDetail.rewards[me.toNum(idx)+1].weekId).."周")
        me.assignWidget(cell,"Image_itemIcon"):loadTexture(getItemIcon(user.activityDetail.rewards[me.toNum(idx)+1].itemId))
        return cell
    end

    function numberOfCellsInTableView(table)
        return #user.activityDetail.rewards
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(780, 240))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(0, 1)
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        self.Panel_table:addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function weekySignSubcell:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
