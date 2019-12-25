-- [Comment]
-- jnmo
sumPayRankCell = class("sumPayRankCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
sumPayRankCell.__index = sumPayRankCell
function sumPayRankCell:create(...)
    local layer = sumPayRankCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function sumPayRankCell:ctor()
    print("sumPayRankCell ctor")
    self.rank_num = 0
end
function sumPayRankCell:init()
    print("sumPayRankCell init")
    self.Text_time = me.assignWidget(self, "Text_Time")
    self.Node_middle_Rank = me.assignWidget(self, "Node_middle_Rank")
    self.Node_middle_Gift = me.assignWidget(self, "Node_middle_Gift")
    self.Rank_num = me.assignWidget(self, "Rank_num")
    self.Button_RANK = me.registGuiClickEventByName(self, "Button_RANK", function(node)

        me.setButtonDisable(node, false)
        me.setButtonDisable(self.Button_GIFT, true)
        self.RankType = rankView.ALLIANCE
        -- NetMan:send(_MSG.rankList(rankView.ALLIANCE ))
        self.Node_middle_Rank:setVisible(true)
        self.Node_middle_Gift:setVisible(false)
    end )
    self.Button_GIFT = me.registGuiClickEventByName(self, "Button_GIFT", function(node)

        me.setButtonDisable(node, false)
        me.setButtonDisable(self.Button_RANK, true)
        self.Node_middle_Rank:setVisible(false)
        self.Node_middle_Gift:setVisible(true)
        if self.activity_id == ACTIVITY_ID_PAYRANK then
            NetMan:send(_MSG.Cross_Sever_Reward(9))
        elseif self.activity_id == ACTIVITY_ID_NET_PAYRANK then
            NetMan:send(_MSG.Cross_Sever_Reward(15))
        elseif self.activity_id == ACTIVITY_ID_COSTRANK then
            NetMan:send(_MSG.Cross_Sever_Reward(10))
        elseif self.activity_id == ACTIVITY_ID_NET_COSTRANK then
            NetMan:send(_MSG.Cross_Sever_Reward(16))
        end
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

    self.Node_middle_Rank:setVisible(true)
    self.Node_middle_Gift:setVisible(false)
    me.setButtonDisable(self.Button_RANK, false)
    me.setButtonDisable(self.Button_GIFT, true)
    self.Node_Desc1 = me.assignWidget(self,"Node_Desc1")
    self.Text_Desc2 = me.assignWidget(self,"Text_Desc2")
    return true
end
function sumPayRankCell:initActivity(id)
    self.activity_id = id
    local data = user.activityPayData[self.activity_id]
    self.Node_Desc1:removeAllChildren()
   
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(data.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        local rich = mRichText:create(activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0, Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0, 1))
        Panel_richText:addChild(rich)
    end
    self.Text_time:setString(me.GetSecTime(data.openDate) .. "-" .. me.GetSecTime(data.endDate))
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
            self:setTableView(msg)
        elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then
            self:setGiftTableView(msg)
        end
    end )
    if self.activity_id == ACTIVITY_ID_PAYRANK  then
        NetMan:send(_MSG.rankList(rankView.PAY_RANK))
        me.assignWidget(self.Button_RANK,"Text_title"):setString("充值排名")
        me.assignWidget(self.Button_GIFT,"Text_title"):setString("充值奖励")
        local rt = mRichText:create("<txt0016,ffffff>累计充值达到&<txt0016,ff0000>"..data.min.."&<txt0016,ffffff>可进入排行榜&")
        self.Node_Desc1:addChild(rt)
        self.Text_Desc2:setString("当前累计充值："..data.value)
    elseif self.activity_id == ACTIVITY_ID_COSTRANK  then
        NetMan:send(_MSG.rankList(rankView.COST_RANK))
        me.assignWidget(self.Button_RANK,"Text_title"):setString("消费排名")
        me.assignWidget(self.Button_GIFT,"Text_title"):setString("消费奖励")
        me.assignWidget( me.assignWidget(self,"Image_bar"),"Text_9_1"):setString("累计消费")
        local rt = mRichText:create("<txt0016,ffffff>累计消费达到&<txt0016,ff0000>"..data.min.."&<txt0016,ffffff>可进入排行榜&")
        self.Node_Desc1:addChild(rt)
        self.Text_Desc2:setString("当前累计消费："..data.value)
    elseif self.activity_id == ACTIVITY_ID_NET_COSTRANK then
        NetMan:send(_MSG.rankList(rankView.NET_COST_RANK))
        me.assignWidget(self.Button_RANK,"Text_title"):setString("跨服消费排名")
        me.assignWidget(self.Button_GIFT,"Text_title"):setString("跨服消费奖励")
        me.assignWidget( me.assignWidget(self,"Image_bar"),"Text_9_1"):setString("累计消费")
        me.fixFontWidth(me.assignWidget(self.Button_RANK,"Text_title"),152)
        me.fixFontWidth(me.assignWidget(self.Button_GIFT,"Text_title"),152)
        local rt = mRichText:create("<txt0016,ffffff>累计消费达到&<txt0016,ff0000>"..data.min.."&<txt0016,ffffff>可进入排行榜&")
        self.Text_Desc2:setString("当前累计消费："..data.value)
        self.Node_Desc1:addChild(rt)
    elseif self.activity_id == ACTIVITY_ID_NET_PAYRANK then
        NetMan:send(_MSG.rankList(rankView.NET_PAY_RANK))
        me.assignWidget(self.Button_RANK,"Text_title"):setString("跨服充值排名")
        me.assignWidget(self.Button_GIFT,"Text_title"):setString("跨服充值奖励")
        me.fixFontWidth(me.assignWidget(self.Button_RANK,"Text_title"),152)
        me.fixFontWidth(me.assignWidget(self.Button_GIFT,"Text_title"),152)
        local rt = mRichText:create("<txt0016,ffffff>累计充值达到&<txt0016,ff0000>"..data.min.."&<txt0016,ffffff>可进入排行榜&")
        self.Text_Desc2:setString("当前累计充值："..data.value)
        self.Node_Desc1:addChild(rt)
    end
    --   self:setTableView()
end
function sumPayRankCell:setTableView(msg)
    self.listData = msg.c.list
    self.mNum = #self.listData

    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 886, 60
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
--        if tonumber(tmp.item[1]) == tonumber(user.uid) then
--            self.rank_num = idx + 1
--        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self.Node_middle_Rank, "Image_table")
        self.tableView = cc.TableView:create(cc.size(886, Image_table:getContentSize().height-4))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(5, 5))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
    local data = user.activityPayData[self.activity_id]
    if data.rank > 0 then
        self:setPointpitch(data.rank, self.mNum)
        me.assignWidget(self.myRank,"Rank_num"):setVisible(true)
        me.assignWidget(self.myRank,"Text_88"):setString("我的排名")
    else
        me.assignWidget(self.myRank,"Text_88"):setString("未上榜")
        me.assignWidget(self.myRank,"Rank_num"):setVisible(false)
    end
    self.Rank_num:setString(data.rank)
end
function sumPayRankCell:setGiftTableView(msg)
    dump(msg.c.award)
    local listData = msg.c.award

    local function numberOfCellsInTableView(table)
        return #listData
    end

    local function cellSizeForTable(table, idx)
        return 886, 95
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
                item:setPosition(indexX * 105, itemPanel:getContentSize().height / 2)
                indexX = indexX + 1
            end
        end
        return cell
    end
    if self.tableView_gift == nil then
        local Image_table = me.assignWidget(self.Node_middle_Gift, "Image_table")
        self.tableView_gift = cc.TableView:create(cc.size(886, 360))
        self.tableView_gift:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_gift:setDelegate()
        self.tableView_gift:setPosition(cc.p(5, 5))
        Image_table:addChild(self.tableView_gift)
        self.tableView_gift:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_gift:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_gift:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_gift:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_gift:reloadData()
end
function sumPayRankCell:setTableOffset(pIdx)
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
function sumPayRankCell:setPointpitch(pTag, pTabNum)
    pTag = me.toNum(pTag)
    local pPointX = 443
    local pPointY =(pTabNum - pTag + 1) * 60 - 30
    self.pPitchHint = ccui.ImageView:create("gongyong_xuanzhong.png", me.localType)
    self.pPitchHint:setVisible(true)
    self.pPitchHint:setScale9Enabled(true)
    self.pPitchHint:ignoreContentAdaptWithSize(false)
    self.pPitchHint:setCapInsets(cc.rect(29, 29, 31, 31))
    self.pPitchHint:setContentSize(cc.size(896, 66))
    self.pPitchHint:setPosition(cc.p(pPointX, pPointY))
    self.pPitchHint:setLocalZOrder(10)
    self.tableView:addChild(self.pPitchHint)
end

function sumPayRankCell:pitchcellhint()
    self.pPitchHint:stopAllActions()
    local a5 = cc.Blink:create(0.9, 2)
    self.pPitchHint:runAction(a5)
    self.BlinkTime = me.registTimer(2, function(dt)
        self.Blink_Bool = true
    end , 1.2)
end
function sumPayRankCell:onEnter()
    print("sumPayRankCell onEnter")
    me.doLayout(self, me.winSize)
end
function sumPayRankCell:onEnterTransitionDidFinish()
    print("sumPayRankCell onEnterTransitionDidFinish")
end
function sumPayRankCell:onExit()
    print("sumPayRankCell onExit")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function sumPayRankCell:close()
    self:removeFromParent()
end
