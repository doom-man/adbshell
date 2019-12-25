plunderWorldSubcell = class("plunderWorldSubcell", function(...)
    return cc.CSLoader:createNode(...)
end )
plunderWorldSubcell.__index = plunderWorldSubcell
function plunderWorldSubcell:create(...)
    local layer = plunderWorldSubcell.new(...)
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

function plunderWorldSubcell:ctor()
    print("plunderWorldSubcell:ctor()")
end
function plunderWorldSubcell:init()
    print("plunderWorldSubcell:init()")
    return true
end
function plunderWorldSubcell:onEnter()
    me.assignWidget(self, "Image_itemBg"):setVisible(false)
    me.assignWidget(self, "Panel_item"):setVisible(false)
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        local rich = mRichText:create(activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0, Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0, 1))
        Panel_richText:addChild(rich)
    end

    -- 活动倒计时
    local Text_countDown = me.assignWidget(self, "Text_countDown")
    local leftT = user.activityDetail.cd -(me.sysTime() / 1000 - user.activityDetail.startTime / 1000)
    if leftT <= 0 then
        Text_countDown:setString("活动时间结束")
    else
        Text_countDown:setString("活动倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动时间结束")
            end
            Text_countDown:setString("活动倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
    end

    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_PLUNDER then
                self:setTableView()

                if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_PLUNDER)] == 1 then
                    -- 移除小红点
                    self:removeRedPoint()
                end
            end
        end
    end )
    self:setTableView()
    me.doLayout(self, me.winSize)
end

function plunderWorldSubcell:itemIsGot(indexId)
    for key, var in pairs(user.activityDetail.gls) do
        if me.toNum(indexId) == me.toNum(key) then
            return true
        end
    end
    return false
end

-- 移除小红点
function plunderWorldSubcell:removeRedPoint()

    local listData = user.activityDetail.list
    for _, v in ipairs(listData) do
        if me.toNum(user.activityDetail.num) > me.toNum(v.num) then
            if self:itemIsGot(v.index) == false then
                -- 还有能领取的
                return
            end
        end
    end
    removeRedpoint(ACTIVITY_ID_PLUNDER)
end

function plunderWorldSubcell:setTableView()
    self.listData = { }

    for key, var in pairs(user.activityDetail.list) do
        if self:itemIsGot(var.index) == false then
            table.insert(self.listData, var)
        end
    end
    for key, var in pairs(user.activityDetail.list) do
        if self:itemIsGot(var.index) == true then
            table.insert(self.listData, var)
        end
    end
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 833, 122
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
            node:setVisible(true)
        end
        local tmp = self.listData[me.toNum(idx + 1)]
        if tmp then
            if me.toNum(user.activityDetail.num) <= me.toNum(tmp.num) then
                -- 不能领取
                me.assignWidget(node, "Text_plunderNum"):setString(user.activityDetail.num .. "/" .. tmp.num)
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(false)
                me.assignWidget(node, "cell_bg"):setVisible(idx%2==0)
                local btn = me.assignWidget(node, "Button_get")
                btn:setVisible(true)
                me.assignWidget(btn,"image_title"):setString("未达成")
                btn:setTitleColor(COLOR_EXPED_GRAY)
                me.setButtonDisable(btn, false)
            elseif self:itemIsGot(tmp.index) == true then
                -- 已经领取过
                me.assignWidget(node, "Text_plunderNum"):setString(tmp.num .. "/" .. tmp.num)
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_guoqi.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(true)
                me.assignWidget(node, "Button_get"):setVisible(false)
            else
                -- 能领取
                me.assignWidget(node, "Text_plunderNum"):setString(tmp.num .. "/" .. tmp.num)
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(false)
                local btn = me.assignWidget(node, "Button_get")
                me.registGuiClickEventByName(node, "Button_get", function()
                    NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, tmp.index))
                end )
                btn:setVisible(true)
                me.assignWidget(btn,"image_title"):setString("领 取")
                btn:setTitleColor(COLOR_WHITE)
                me.setButtonDisable(btn, true)
            end

            local itemPanel = me.assignWidget(node, "Panel_itemIcon")
            itemPanel:removeAllChildren()
            local indexX = 0
            for key, var in pairs(tmp.reward) do
                local item = me.assignWidget(self, "Image_itemBg"):clone()
                item:setVisible(true)
                local etc = cfg[CfgType.ETC][me.toNum(var[1])]
                me.assignWidget(item, "Image_itemBg"):loadTexture(getQuality(etc.quality))
                me.assignWidget(item, "Image_item"):loadTexture(getItemIcon(etc.id))
                me.assignWidget(item, "Text_Num"):setString(var[2])
                me.assignWidget(item, "Button_item"):setSwallowTouches(false)
                me.registGuiClickEventByName(item, "Button_item", function()
                    showPromotion(var[1], var[2])
                end )
                itemPanel:addChild(item)
                item:setAnchorPoint(cc.p(0, 0.5))
                item:setPosition(indexX * 135, itemPanel:getContentSize().height / 2)
                indexX = indexX + 1
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self, "Image_table")
        self.tableView = cc.TableView:create(cc.size(833, 375))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(1, 1))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function plunderWorldSubcell:onExit()
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
