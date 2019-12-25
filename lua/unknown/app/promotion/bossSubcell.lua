bossSubcell = class("bossSubcell", function(...)
    return cc.CSLoader:createNode(...)
end )
bossSubcell.__index = bossSubcell
function bossSubcell:create(...)
    local layer = bossSubcell.new(...)
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

function bossSubcell:ctor()
    print("bossSubcell:ctor()")
    self.itemDatas = nil
    self.ScrollView_cell = nil
end
function bossSubcell:init()
    print("bossSubcell:init()")
    self.ScrollView_cell = me.assignWidget(self, "ScrollView_items")
    self.Text_time = me.assignWidget(self, "Text_time")
    self.Node_middle_Rank = me.assignWidget(self, "Node_middle_Rank")
    self.Node_middle_Gift = me.assignWidget(self, "Node_middle_Gift")
    self.Node_middle_Bar = me.assignWidget(self, "Node_middle_Bar")
    self.Image_Not_Open = me.assignWidget(self, "Image_Not_Open")
    self.Image_Opening = me.assignWidget(self, "Image_Opening")
    self.Rank_num = me.assignWidget(self, "Rank_num")
    self.curStaate = 1
    self.Button_PRank = me.registGuiClickEventByName(self, "Button_PRank", function(node)
        self:setButtonDisable(self.Button_PRank, false)
        self:setButtonDisable(self.Button_FRank, true)
        self:setButtonDisable(self.Button_GIFT, true)

        self.Node_middle_Rank:setVisible(false)
        self.Node_middle_Gift:setVisible(false)
        self.Node_middle_Bar:setVisible(true)
        self.curStaate = 1
    end )
    self.Button_FRank = me.registGuiClickEventByName(self, "Button_FRank", function(node)

        self:setButtonDisable(self.Button_PRank, true)
        self:setButtonDisable(self.Button_FRank, false)
        self:setButtonDisable(self.Button_GIFT, true)
        self.Node_middle_Bar:setVisible(false)
        self.Node_middle_Rank:setVisible(true)
        self.Node_middle_Gift:setVisible(false)
        NetMan:send(_MSG.rankList(rankView.BOSS_ACT_FAMILY_RANK))
    end )
    self.Button_GIFT = me.registGuiClickEventByName(self, "Button_GIFT", function(node)

        self:setButtonDisable(self.Button_PRank, true)
        self:setButtonDisable(self.Button_FRank, true)
        self:setButtonDisable(self.Button_GIFT, false)
        self.Node_middle_Rank:setVisible(false)
        self.Node_middle_Gift:setVisible(true)
        self.Node_middle_Bar:setVisible(false)
        self.curStaate = 3
        NetMan:send(_MSG.Cross_Sever_Reward(11))
    end )

    self.myRank = me.registGuiClickEventByName(self, "myRank", function(node)
        if self.Blink_Bool then
            if self.rank_num ~= 0 then
                self:setTableOffset(self.rank_num)
                self:pitchcellhint()
                self.Blink_Bool = false
            end
        end
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
            self:initRank(msg)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            self:initProcess()
        elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then
            self:setGiftTableView(msg)
        end
    end )
    return true
end
function bossSubcell:setGiftTableView(msg)
    dump(msg.c.award)
    local listData = msg.c.award

    local function numberOfCellsInTableView(table)
        return #listData
    end

    local function cellSizeForTable(table, idx)
        return 831, 105
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Panel_Item_Gift"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Panel_Item_Gift")
            node:setVisible(true)
        end
        local tmp = listData[me.toNum(idx + 1)]
        if tmp then
            local Image_panel = me.assignWidget(node, "Image_panel")
            local itemPanel = me.assignWidget(node, "Panel_itemIcon")
            local Text_plunderNum = me.assignWidget(node, "Text_plunderNum")
            if tmp.bg == tmp.ed then
                Text_plunderNum:setString("排名" .. tmp.bg)
            else
                Text_plunderNum:setString("排名" .. tmp.bg .. "-" .. tmp.ed)
            end
            if idx % 2 == 0 then
                Image_panel:setVisible(false)
            else
                Image_panel:setVisible(true)
            end
            itemPanel:removeAllChildren()
            local indexX = 0
            for key, var in pairs(tmp.rw) do
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
                item:setPosition(indexX * 105, itemPanel:getContentSize().height / 2-1)
                indexX = indexX + 1
            end
        end
        return cell
    end
    if self.tableView_gift == nil then
        local Image_table = me.assignWidget(self.Node_middle_Gift, "Image_table")
        self.tableView_gift = cc.TableView:create(cc.size(831, 316))
        self.tableView_gift:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_gift:setDelegate()
        self.tableView_gift:setPosition(cc.p(1, 1))
        Image_table:addChild(self.tableView_gift)
        self.tableView_gift:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_gift:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_gift:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_gift:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_gift:reloadData()
end
function bossSubcell:setCellData(cell, itemId, index)
    local cfg = cfg[CfgType.ETC][itemId]
    if cfg == nil then
        __G__TRACKBACK__("CfgType.ETC id = " .. itemId .. " is nil  !!!")
        return
    end
    me.assignWidget(cell, "Button_item"):setTag(index)
    me.assignWidget(cell, "Goods_Icon"):loadTexture("item_" .. cfg.icon .. ".png", me.localType)
    me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(cfg.quality), me.localType)
    me.registGuiClickEventByName(cell, "Button_item", function(node)
        local pTag = me.toNum(node:getTag())
        local pDefId = self.itemDatas[pTag]
        showPromotion(pDefId, nil)
    end )
end
function bossSubcell:initScrollData()
    local w = 100
    local totalW = self.ScrollView_cell:getContentSize().width
    if totalW < #self.itemDatas * w then
        totalW = #self.itemDatas * w
    end
    for key, var in pairs(self.itemDatas) do
        local cell = me.assignWidget(self, "Button_item"):clone()
        cell:setVisible(true)
        self:setCellData(cell, var, key)
        local index = me.toNum(key) -1
        cell:setAnchorPoint(cc.p(0, 0))
        cell:setPosition(cc.p(w * index+40, 80))
        self.ScrollView_cell:addChild(cell)
    end
    self.ScrollView_cell:setInnerContainerSize(cc.size(totalW, 140))
end
function bossSubcell:initActivity()
    self.itemDatas = user.activityDetail.list
    if user.activityDetail.open == 1 then
        self.Text_time:setString("活动进行中")
        self.cd = user.activityDetail.cd / 1000
        self.timer = me.registTimer(-1, function()
            if self.cd <= 0 then
                me.clearTimer(self.timer)
                self.timer = nil
            end
            self.Text_time:setString("活动进行中 距离结束" .. me.formartSecTime(self.cd) .. "(" .. user.activityDetail.timedesc .. ")")
            self.cd = self.cd - 1
        end , 1)
        -- 0 完全关闭，2是开启的间隔状态 1是正在开启
    elseif user.activityDetail.open == 0 then
        self.cd = user.activityDetail.cd
        self.Text_time:setString("开启倒计时：" .. me.formartSecTime(self.cd))
        self.timer = me.registTimer(-1, function()
            if self.cd <= 0 then
                me.clearTimer(self.timer)
                self.timer = nil
            end
            self.Text_time:setString("开启倒计时：" .. me.formartSecTime(self.cd))
            self.cd = self.cd - 1
        end , 1)

    elseif user.activityDetail.open == 2 then
        self.cd = user.activityDetail.cd
        self.Text_time:setString("等待刷新中 距离结束" .. me.formartSecTime(self.cd) .. "(" .. user.activityDetail.timedesc .. ")")
        self.timer = me.registTimer(-1, function()
            if self.cd <= 0 then
                me.clearTimer(self.timer)
                self.timer = nil
            end
            self.Text_time:setString("等待刷新中 距离结束" .. me.formartSecTime(self.cd) .. "(" .. user.activityDetail.timedesc .. ")")
            self.cd = self.cd - 1
        end , 1)
    end

    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        local rich = mRichText:create(activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0, Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0, 1))
        Panel_richText:addChild(rich)
    end

    if user.activityDetail.open == 1 or user.activityDetail.open == 2 then
        self.Image_Not_Open:setVisible(false)
        self.Image_Opening:setVisible(true)
        self:initOpening()
    elseif user.activityDetail.open == 0 then
        self.Image_Not_Open:setVisible(true)
        self.Image_Opening:setVisible(false)
        self:initScrollData()
    end

end

function bossSubcell:setButtonDisable(button, b)   
    if  button.setBright then
         button:setTouchEnabled(b)
         button:setBright(b)  
         if b==true then
            me.assignWidget(button, "btn_txt_1"):setVisible(true)
         else
            me.assignWidget(button, "btn_txt_2"):setVisible(true)
         end         
    end
end

function bossSubcell:initOpening()
    self.Node_middle_Rank:setVisible(false)
    self.Node_middle_Gift:setVisible(false)
    self.Node_middle_Bar:setVisible(true)
    self:setButtonDisable(self.Button_PRank, false)
    self:setButtonDisable(self.Button_FRank, true)
    self:setButtonDisable(self.Button_GIFT, true)
    self:initProcess()
end
function bossSubcell:initRank(msg)
    self.listData = msg.c.list
    self.mNum = #self.listData
    self.rank_num = 0
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 831, 60
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "rank_cell"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "rank_cell")
            node:setVisible(true)
        end
        local tmp = self.listData[me.toNum(idx + 1)]
        if tmp then
            local bg_cell = me.assignWidget(node, "bg_cell")
            local R_cell_rank_icon = me.assignWidget(node, "R_cell_rank_icon")
            local R_cell_rank = me.assignWidget(node, "R_cell_rank")
            local R_cell_name = me.assignWidget(node, "R_cell_name")
            local R_cell_val = me.assignWidget(node, "R_cell_val")
            R_cell_rank_icon:setVisible(true)
            R_cell_rank:setVisible(false)
            if idx + 1 == 1 then
                R_cell_rank_icon:loadTexture("paihang_diyiming.png", me.localType)
            elseif idx + 1 == 2 then
                R_cell_rank_icon:loadTexture("paihang_dierming.png", me.localType)
            elseif idx + 1 == 3 then
                R_cell_rank_icon:loadTexture("paihang_disanming.png", me.localType)
            else
                R_cell_rank:setString(me.toStr(idx + 1))
                R_cell_rank_icon:setVisible(false)
                R_cell_rank:setVisible(true)
            end
            R_cell_name:setString(tmp.item[3])
            R_cell_val:setString(tmp.item[2])
            if idx % 2 == 0 then
                bg_cell:setVisible(false)
            else
                bg_cell:setVisible(true)
            end
        end
        if tonumber(tmp.item[1]) == tonumber(user.familyUid) then
            self.rank_num = idx + 1
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self.Node_middle_Rank, "Image_table")
        self.tableView = cc.TableView:create(cc.size(831, 283))
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
    local data = user.activityPayData[self.activity_id]

    for key, var in ipairs(self.listData) do
        if tonumber(var.item[1]) == tonumber(user.familyUid) then
            self.rank_num = key
        end
    end
    if self.rank_num > 0 then
        self:setPointpitch(self.rank_num, self.mNum)
        self.Rank_num :setVisible(true)
        self.Rank_num :setString(self.rank_num)
        me.assignWidget(self.myRank, "Text_88"):setString("联盟排名")
    else
        me.assignWidget(self.myRank, "Text_88"):setString("未上榜")
        self.Rank_num :setVisible(false)
    end
    
end
function bossSubcell:setPointpitch(pTag, pTabNum)
    pTag = me.toNum(pTag)
    local pPointX = 443
    local pPointY =(pTabNum - pTag + 1) * 60 - 30
    if self.pPitchHint == nil then
        self.pPitchHint = ccui.ImageView:create("gongyong_xuanzhong.png", me.localType)
        self.pPitchHint:setVisible(true)
        self.pPitchHint:setScale9Enabled(true)
        self.pPitchHint:ignoreContentAdaptWithSize(false)
        self.pPitchHint:setCapInsets(cc.rect(29, 29, 31, 31))
        self.pPitchHint:setContentSize(cc.size(896, 66))
        self.pPitchHint:setLocalZOrder(10)
        self.tableView:addChild(self.pPitchHint)
    end
    self.pPitchHint:setPosition(cc.p(pPointX, pPointY))
end
function bossSubcell:setTableOffset(pIdx)
    if pIdx < 5 then
        self.tableView:setContentOffset(cc.p(0, -(self.mNum * 60 - 320)))
    elseif pIdx > 296 then
        self.tableView:reloadData()
        self.tableView:setContentOffset(cc.p(0, 0))
    else
        if (self.mNum - 3 - pIdx) < 0 then
            self.tableView:reloadData()
            self.tableView:setContentOffset(cc.p(0, 0))
        else
            self.tableView:reloadData()
            self.tableView:setContentOffset(cc.p(0, -(self.mNum - 3 - pIdx) * 60))
        end
    end
end
function bossSubcell:pitchcellhint()
    self.pPitchHint:stopAllActions()
    local a5 = cc.Blink:create(0.9, 2)
    self.pPitchHint:runAction(a5)
    self.BlinkTime = me.registTimer(2, function(dt)
        self.Blink_Bool = true
    end , 1.2)
end
function bossSubcell:initProcess()

    local listData = user.activityDetail.single
    local function numberOfCellsInTableView(table)
        return #listData
    end

    local function cellSizeForTable(table, idx)
        return 831, 105
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
        local tmp = listData[me.toNum(idx + 1)]
        if tmp then
            local Image_panel = me.assignWidget(node, "Image_panel")
            local itemPanel = me.assignWidget(node, "Panel_itemIcon")
            local Text_plunderNum = me.assignWidget(node, "Text_Score")
            Text_plunderNum:setString( Scientific( user.activityDetail.val )  .. "/" .. tmp.need)
            if idx % 2 == 0 then
                Image_panel:setVisible(false)
            else
                Image_panel:setVisible(true)
            end
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
                item:setPosition(indexX * 105, itemPanel:getContentSize().height / 2+7)
                indexX = indexX + 1
            end
            local getBtn = me.registGuiClickEventByName(node, "Button_Get", function(sender)
                NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, tmp.need))
            end )
            if tmp.status then
                if tmp.status == 0 then
                    me.assignWidget(getBtn, "image_title"):setString("未达成")
                    me.setButtonDisable(getBtn, true)
                    getBtn:setTouchEnabled(false)
                    getBtn:loadTextureNormal("ui_ty_button_cheng_154x56.png", me.localType)
                    Text_plunderNum:setTextColor(COLOR_D4CDB9)
                elseif tmp.status == 1 then
                    me.assignWidget(getBtn, "image_title"):setString("领取")
                    me.setButtonDisable(getBtn, true)
                    getBtn:loadTextureNormal("ui_ty_button_lv154x56.png", me.localType)
                    Text_plunderNum:setTextColor(COLOR_GREEN_FLAG)
                elseif tmp.status == 2 then
                    me.assignWidget(getBtn, "image_title"):setString("已领取")
                    me.setButtonDisable(getBtn, false)
                end
            else
                me.setButtonDisable(getBtn, false)
            end
        end
        return cell
    end
    local Image_table = me.assignWidget(self.Node_middle_Bar, "Image_table")
    Image_table:removeAllChildren()
    self.tableView_process = cc.TableView:create(cc.size(831, 316))
    self.tableView_process:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView_process:setDelegate()
    self.tableView_process:setPosition(cc.p(1, 1))
    Image_table:addChild(self.tableView_process)
    self.tableView_process:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView_process:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView_process:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView_process:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)

    self.tableView_process:reloadData()
end
function bossSubcell:onEnter()
    print("bossSubcell:onEnter()")
    me.doLayout(self, me.winSize)
    self:initActivity()

   -- if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_BOSS_NEW)] == 1 then
        -- 移除红点
        removeRedpoint(ACTIVITY_ID_BOSS_NEW)
   -- end
end
function bossSubcell:onExit()
    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    print("bossSubcell:onExit()")
end
